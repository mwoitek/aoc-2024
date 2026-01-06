# run program M times to discard measurements
# run program N times and keep measurements
# compute average and standard deviation
# print results to file

import subprocess
import sys
from pathlib import Path
from shutil import which

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
        check=False,
    )
    return proc.returncode == 0


# compile_solution(1, 2)
