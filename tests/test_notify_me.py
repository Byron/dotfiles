import os
from pathlib import Path
import subprocess
import sys
import tempfile


script = Path(__file__).resolve().parents[1] / "etc/config/fish/functions/notify-me.py"
args = [
    "review", "--base", "main", "-c", 'model_reasoning_effort="max"',
    "", "two words", "$HOME; (exit 99)", "*",
]

with tempfile.TemporaryDirectory() as config:
    functions = Path(config) / "fish/functions"
    functions.mkdir(parents=True)
    (functions / "codex-dev.fish").write_text(
        "function codex-dev\n"
        "    printf '%s\\0' $argv\n"
        "    return $NOTIFY_ME_TEST_STATUS\n"
        "end\n"
    )
    env = {**os.environ, "XDG_CONFIG_HOME": config}
    for status in (0, 7):
        result = subprocess.run(
            [sys.executable, str(script), "codex-dev", *args],
            env={**env, "NOTIFY_ME_TEST_STATUS": str(status)},
            capture_output=True, text=True, timeout=10,
        )
        assert result.returncode == status, (result.returncode, result.stderr)
        assert result.stdout == "\0".join(args) + "\0", repr(result.stdout)
        assert "\033]2;codex-dev review\033\\" in result.stderr
        assert "\033]9;4;0\033\\" in result.stderr
        message = "✅ codex-dev review finished" if status == 0 else "❌ codex-dev review failed with status 7"
        assert f"\033]9;{message}\033\\" in result.stderr

    result = subprocess.run(
        [sys.executable, str(script), sys.executable, "-c", "raise SystemExit(23)"],
        env=env, capture_output=True, text=True, timeout=10,
    )
    assert result.returncode == 23, (result.returncode, result.stderr)

print("notify-me: Fish functions, literal arguments, notifications, and exit statuses passed")
