"""Exercise Codex wrappers with fake credentials and launchers; no API calls."""

import json
import os
from pathlib import Path
import pty
import select
import shutil
import subprocess
import tempfile
import time
import unittest


FUNCTIONS = Path(__file__).resolve().parents[1] / "functions"
if not FUNCTIONS.is_dir():
    FUNCTIONS = Path(__file__).resolve().parents[1] / "etc/config/fish/functions"
FISH = shutil.which("fish")
KEY = "dummy-azure-credential"
ARGS = ["exec", "", "two words", "$HOME; (exit 99)", "*"]


@unittest.skipUnless(FISH, "fish is required")
class CodexFishTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.bin = Path(self.temp.name)
        launcher = self.bin / "launcher"
        launcher.write_text(
            "#!/usr/bin/env python3\n"
            "import json, os, sys\n"
            "print(json.dumps({'key': os.environ.get('AZURE_OPENAI_API_KEY'), 'args': sys.argv[1:]}))\n"
            "sys.exit(int(os.environ.get('CODEX_TEST_STATUS', '0')))\n"
        )
        launcher.chmod(0o755)
        for name, body in {
            "uname": 'printf "%s\\n" "$CODEX_TEST_OS"',
            "security": 'touch "$CODEX_TEST_SECURITY_CALLED"; printf "%s\\n" "$CODEX_TEST_KEYCHAIN_KEY"; exit "$CODEX_TEST_KEYCHAIN_STATUS"',
        }.items():
            script = self.bin / name
            script.write_text("#!/bin/sh\n" + body + "\n")
            script.chmod(0o755)
        self.env = {
            k: v for k, v in os.environ.items()
            if k not in ("AZURE_OPENAI_API_KEY", "OPENAI_API_KEY", "fish_trace", "FISH_DEBUG", "FISH_DEBUG_OUTPUT")
        }
        self.env.update(
            PATH=str(self.bin) + os.pathsep + self.env["PATH"],
            CODEX_TEST_BIN=str(launcher),
            CODEX_TEST_OS="Linux",
            CODEX_TEST_SECURITY_CALLED=str(self.bin / "security-called"),
            CODEX_TEST_KEYCHAIN_KEY="dummy-keychain-credential",
            CODEX_TEST_KEYCHAIN_STATUS="0",
            TERM="xterm",
        )
        self.prelude = f'source "{FUNCTIONS}/__codex_with_azure_key.fish"; '

    def run_fish(self, code, args=(), env=None):
        return subprocess.run(
            [FISH, "--no-config", "-c", self.prelude + code, "--", *args],
            env={**self.env, **(env or {})}, stdin=subprocess.DEVNULL,
            capture_output=True, text=True, timeout=10,
        )

    def test_supplied_keys_arguments_and_status(self):
        for operating_system in ("Linux", "Darwin"):
            for setup in (
                'set -g AZURE_OPENAI_API_KEY "$CODEX_TEST_KEY"; ',
                'set -gx AZURE_OPENAI_API_KEY "$CODEX_TEST_KEY"; ',
                '',
            ):
                result = self.run_fish(
                    setup + '__codex_with_azure_key "$CODEX_TEST_BIN" $argv', ARGS,
                    {"CODEX_TEST_OS": operating_system, "CODEX_TEST_KEY": KEY,
                     "AZURE_OPENAI_API_KEY": KEY if not setup else "", "CODEX_TEST_STATUS": "7"},
                )
                self.assertEqual(result.returncode, 7, result.stderr)
                self.assertEqual(json.loads(result.stdout), {"key": KEY, "args": ARGS})
                self.assertFalse((self.bin / "security-called").exists())
        result = self.run_fish(
            'AZURE_OPENAI_API_KEY="$CODEX_TEST_KEY" __codex_with_azure_key "$CODEX_TEST_BIN" $argv; '
            'set -q AZURE_OPENAI_API_KEY; and exit 99; exit 0', ARGS,
            {"CODEX_TEST_KEY": KEY},
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(json.loads(result.stdout), {"key": KEY, "args": ARGS})

    def test_missing_key_does_not_consume_noninteractive_input(self):
        for key in (None, ""):
            result = self.run_fish('__codex_with_azure_key "$CODEX_TEST_BIN"',
                                   env={} if key is None else {"AZURE_OPENAI_API_KEY": key})
            self.assertEqual(result.returncode, 1)
            self.assertIn("set AZURE_OPENAI_API_KEY", result.stderr)
            self.assertEqual(result.stdout, "")
            self.assertFalse((self.bin / "security-called").exists())

    def test_macos_keychain_and_failed_lookup(self):
        result = self.run_fish(
            '__codex_with_azure_key "$CODEX_TEST_BIN"; '
            'set -q AZURE_OPENAI_API_KEY; and exit 99; exit 0',
            env={"CODEX_TEST_OS": "Darwin"},
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(json.loads(result.stdout)["key"], "dummy-keychain-credential")
        self.assertTrue((self.bin / "security-called").exists())
        result = self.run_fish('__codex_with_azure_key "$CODEX_TEST_BIN"',
            env={"CODEX_TEST_OS": "Darwin", "CODEX_TEST_KEYCHAIN_KEY": "failed-lookup-output", "CODEX_TEST_KEYCHAIN_STATUS": "1"})
        self.assertEqual(result.returncode, 1)
        self.assertIn("set AZURE_OPENAI_API_KEY", result.stderr)

    def test_tracing_does_not_print_key_and_shell_value_survives(self):
        result = self.run_fish(
            'set -g fish_trace 1; set -g AZURE_OPENAI_API_KEY "$CODEX_TEST_KEY"; '
            '__codex_with_azure_key "$CODEX_TEST_BIN"; '
            'test "$AZURE_OPENAI_API_KEY" = "$CODEX_TEST_KEY"; or exit 99; '
            'test "$fish_trace" = 1; or exit 99',
            env={"CODEX_TEST_KEY": KEY},
        )
        # Inspect only the wrapper trace: setup and caller assertions legitimately reference the dummy key.
        wrapper_trace = result.stderr.split('--> set -l fish_trace', 1)[-1].split('> test', 1)[0]
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn(KEY, wrapper_trace)

    def test_wrappers_forward_binary_profile_arguments_and_exit_status(self):
        for wrapper, executable in (
            ("codex", "codex"), ("codex-azure", "codex"),
            ("codex-dev", str(Path.home() / ".cargo/bin/codex-dev/bin/codex")),
        ):
            result = self.run_fish(
                f'source "{FUNCTIONS}/codex-azure.fish"; source "{FUNCTIONS}/{wrapper}.fish"; '
                'functions --copy __codex_with_azure_key __codex_test_real; '
                'function __codex_with_azure_key; __codex_test_real "$CODEX_TEST_BIN" $argv; end; '
                f'{wrapper} $argv', ARGS,
                {"AZURE_OPENAI_API_KEY": KEY, "CODEX_TEST_STATUS": "7"},
            )
            self.assertEqual(result.returncode, 7, result.stderr)
            self.assertEqual(json.loads(result.stdout), {"key": KEY, "args": [executable, "--profile", "azure", *ARGS]})

    def test_terminal_prompt_rejects_empty_or_cancelled_input_and_keeps_key_local(self):
        for answer, expected_status in ((KEY + "\r", 0), ("\r", 1), ("\x04", 1)):
            master, slave = pty.openpty()
            process = subprocess.Popen(
                [FISH, "--no-config", "-c", self.prelude +
                 '__codex_with_azure_key "$CODEX_TEST_BIN"; set -l result $status; '
                 'set -q AZURE_OPENAI_API_KEY; and exit 99; exit $result'],
                env={**self.env, "TERM": "dumb"}, stdin=slave, stdout=slave, stderr=slave,
            )
            os.close(slave)
            output = b""
            try:
                deadline = time.monotonic() + 10
                while b"Azure OpenAI API key:" not in output and time.monotonic() < deadline:
                    if select.select([master], [], [], 0.1)[0]:
                        output += os.read(master, 65536)
                self.assertIn(b"Azure OpenAI API key:", output)
                os.write(master, answer.encode())
                while time.monotonic() < deadline:
                    if select.select([master], [], [], 0.1)[0]:
                        try:
                            output += os.read(master, 65536)
                        except OSError:
                            break
                    elif process.poll() is not None:
                        break
                self.assertIsNotNone(process.poll(), repr(output))
                self.assertEqual(process.wait(timeout=1), expected_status, output.decode())
                if expected_status == 0:
                    self.assertEqual(output.count(KEY.encode()), 1, "key must appear only in the fake launcher's output")
                else:
                    self.assertNotIn(b'"key":', output)
            finally:
                if process.poll() is None:
                    process.kill()
                    process.wait()
                os.close(master)


if __name__ == "__main__":
    unittest.main()
