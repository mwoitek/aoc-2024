# compute average and standard deviation
# print results to file

import subprocess
import sys
from pathlib import Path
from shutil import which
from time import sleep

ROOT_DIR = Path("~/repos/advent_of_code_2024").expanduser()


def is_command_available(cmd: str) -> bool:
    return which(cmd) is not None


def is_valid_directory(directory: Path) -> bool:
    return directory.exists() and directory.is_dir()


def is_valid_file(file: Path) -> bool:
    return file.exists() and file.is_file()


def compile_solution(day: int, part: int) -> bool:
    if not is_command_available("dmd"):
        print("Compiler dmd is not available", file=sys.stderr)
        return False

    day_dir = ROOT_DIR / f"{day:02}"
    if not is_valid_directory(day_dir):
        print(f"Invalid directory: {day_dir}", file=sys.stderr)
        return False

    solution_file = day_dir / f"pt{part}.d"
    if not is_valid_file(solution_file):
        print(f"Invalid file: {solution_file}", file=sys.stderr)
        return False

    output_file = solution_file.with_suffix(".out").name
    proc = subprocess.run(
        [
            "dmd",
            solution_file.name,
            "-O",
            "-boundscheck=off",
            "-inline",
            "-release",
            f"-of={output_file}",
        ],
        cwd=day_dir,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        check=False,
    )
    return proc.returncode == 0


def process_stdout(stdout: str) -> float:
    last_line = stdout.rstrip().split("\n")[-1]
    i = last_line.index(":")
    return float(last_line[i + 2 :])


def run_solution(day: int, part: int, discard: int = 2, keep: int = 20) -> list[float] | None:
    compiled_solution = ROOT_DIR / f"{day:02}" / f"pt{part}.out"
    if not is_valid_file(compiled_solution):
        print(f"Compiled solution could not be found: {compiled_solution}", file=sys.stderr)
        return None

    input_file = ROOT_DIR / "data" / f"day_{day:02}.txt"
    if not is_valid_file(input_file):
        print(f"Input file could not be found: {input_file}", file=sys.stderr)
        return None

    run_cmd = [f"./{compiled_solution.name}", str(input_file)]
    cwd = compiled_solution.parent

    print("Running program a few times before measuring starts... ", end="", flush=True)
    for _ in range(discard):
        subprocess.run(
            run_cmd,
            cwd=cwd,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            check=False,
        )
        sleep(1)
    print("Done.", flush=True)

    exec_times: list[float] = []

    print("Measuring execution times... ", end="", flush=True)
    for _ in range(keep):
        proc = subprocess.run(run_cmd, cwd=cwd, capture_output=True, text=True, check=False)
        sleep(2)
        exec_time = process_stdout(proc.stdout)
        exec_times.append(exec_time)
    print("Done.", flush=True)

    return exec_times


# times = run_solution(1, 2)
# if times is not None:
#     print(times)
