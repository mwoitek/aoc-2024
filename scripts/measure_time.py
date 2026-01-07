# print results to file

import statistics
import subprocess
import sys
from pathlib import Path
from shutil import which
from time import sleep
from typing import cast

ROOT_DIR = Path("~/repos/advent_of_code_2024").expanduser()


def is_command_available(cmd: str) -> bool:
    return which(cmd) is not None


def is_valid_file(file: Path) -> bool:
    return file.exists() and file.is_file()


def compile_solution(day: int, part: int) -> bool:
    if not is_command_available("dmd"):
        print("Compiler dmd is not available", file=sys.stderr)
        return False

    solution_file = ROOT_DIR / f"{day:02}" / f"pt{part}.d"
    if not is_valid_file(solution_file):
        print(f"Solution file could not be found: {solution_file}", file=sys.stderr)
        return False

    output_file = solution_file.with_suffix(".out").name
    cwd = solution_file.parent

    print("Compiling solution file... ", end="")
    proc = subprocess.run(
        [
            cast("str", which("dmd")),
            solution_file.name,
            "-O",
            "-boundscheck=off",
            "-inline",
            "-release",
            f"-of={output_file}",
        ],
        cwd=cwd,
        check=False,
        stderr=subprocess.DEVNULL,
        stdout=subprocess.DEVNULL,
    )
    ok = proc.returncode == 0
    print("Done." if ok else "Failed!")

    return ok


def get_execution_time(stdout: str) -> float:
    last_line = stdout.rstrip().split("\n")[-1]
    i = last_line.index(":")
    return float(last_line[i + 2 :])


def run_solution(day: int, part: int, times: int = 20, delay: float = 2.0) -> list[float] | None:
    compiled_solution = ROOT_DIR / f"{day:02}" / f"pt{part}.out"
    if not is_valid_file(compiled_solution):
        print(f"Compiled solution could not be found: {compiled_solution}", file=sys.stderr)
        return None

    input_file = ROOT_DIR / "data" / f"day_{day:02}.txt"
    if not is_valid_file(input_file):
        print(f"Input file could not be found: {input_file}", file=sys.stderr)
        return None

    cmd = [f"./{compiled_solution.name}", str(input_file)]
    cwd = compiled_solution.parent

    exec_times: list[float] = []

    for t in range(times):
        print(f"Measuring execution times [{t + 1}/{times}]...", end="\r", flush=True)
        proc = subprocess.run(
            cmd,
            cwd=cwd,
            capture_output=True,
            text=True,
            check=False,
        )
        exec_time = get_execution_time(proc.stdout)
        exec_times.append(exec_time)
        if t < times - 1:
            sleep(delay)
    print(f"Measuring execution times [{times}/{times}]... Done.")

    return exec_times


def compute_statistics(exec_times: list[float]) -> dict[str, float]:
    n = len(exec_times)
    quartiles = statistics.quantiles(exec_times, n=4)
    std = statistics.stdev(exec_times)
    return {
        "Number of observations": n,
        "Minimum": min(exec_times),
        "25th percentile": quartiles[0],
        "Mean": statistics.fmean(exec_times),
        "Median": statistics.median(exec_times),
        "75th percentile": quartiles[-1],
        "Maximum": max(exec_times),
        "Standard deviation": std,
        "Standard error": std / n ** (1 / 2),
    }
