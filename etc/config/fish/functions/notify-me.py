import subprocess
import sys
import threading


def emit(text):
    sys.stderr.write(text)
    sys.stderr.flush()


def clean(text):
    return "".join(
        char
        for char in text
        if ord(char) > 31 and ord(char) != 127 and not 128 <= ord(char) <= 159
    )


def refresh(stop):
    while not stop.wait(14):
        emit("\033]9;4;3\a")


def main():
    if len(sys.argv) == 1:
        print("usage: notify-me COMMAND [ARG ...]", file=sys.stderr)
        return 2

    args = sys.argv[1:]
    title_args = []
    for arg in args:
        if arg.startswith("-"):
            break
        title_args.append(arg)
    title = clean(" ".join(title_args))
    stop = threading.Event()
    refresher = threading.Thread(target=refresh, args=(stop,), daemon=True)

    emit(f"\033]2;{title}\033\\")
    emit("\033]9;4;3\033\\")
    refresher.start()
    interrupted = False
    process = None
    try:
        process = subprocess.Popen(args)
        result = process.wait()
    except FileNotFoundError:
        result = 127
    except PermissionError:
        result = 126
    except KeyboardInterrupt:
        interrupted = True
        result = 130
    finally:
        if process is not None and process.poll() is None:
            process.terminate()
            try:
                process.wait(timeout=1)
            except subprocess.TimeoutExpired:
                process.kill()
                process.wait()
        stop.set()
        refresher.join()
        emit("\033]9;4;0\033\\")

    if result < 0:
        result = 128 - result
    if interrupted:
        emit(f"\033]9;❌ {title} interrupted\033\\")
    elif result == 0:
        emit(f"\033]9;✅ {title} finished\033\\")
    else:
        emit(f"\033]9;❌ {title} failed with status {result}\033\\")
    return result


if __name__ == "__main__":
    raise SystemExit(main())
