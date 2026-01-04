// NOTE: This solution probably can be made faster. After all, I've used dynamic
// arrays in a few places where they can be easily avoided. But this program takes
// less than 2 ms to run. So it's good enough for now.

import std.regex : regex;

// grep '^$' day_13.txt | wc -l | awk '{print $1 + 1}'
const ulong MAX_PROBS = 320;

static re = regex(r"(\d+)");

struct Problem {
    int[][] mat;
    int[] vec;

    this(in int[] nums)
    {
        mat = [[nums[0], nums[2]], [nums[1], nums[3]]];
        vec = [nums[4], nums[5]];
    }
}

int[] readNumbers(in string inputPath)
{
    import std.algorithm.iteration : map;
    import std.array : appender;
    import std.conv : to;
    import std.file : readText;
    import std.regex : matchAll;

    auto arrBuilder = appender!(int[]);
    arrBuilder.reserve(6 * MAX_PROBS);
    foreach (num; inputPath.readText.matchAll(re).map!(m => m.front.to!int))
        arrBuilder.put(num);
    return arrBuilder.data;
}

Problem[] readProblems(in string inputPath)
{
    import std.array : appender;

    auto arrBuilder = appender!(Problem[]);
    arrBuilder.reserve(MAX_PROBS);
    const int[] nums = inputPath.readNumbers;
    ulong i = 0;
    while (i < nums.length) {
        arrBuilder.put(Problem(nums[i .. i + 6]));
        i += 6;
    }
    return arrBuilder.data;
}

int determinant(in int[][] mat)
{
    return mat[0][0] * mat[1][1] - mat[0][1] * mat[1][0];
}

int[] matrixVectorMultiply(in int[][] mat, in int[] vec)
{
    return [mat[0][0] * vec[0] + mat[0][1] * vec[1], mat[1][0] * vec[0] + mat[1][1] * vec[1]];
}

bool isValidFraction(in int num, in int den)
{
    return (den > 0 && num >= 0 && num % den == 0) || (den < 0 && num <= 0 && (-num) % (-den) == 0);
}

int[] solve(in int[][] a, in int[] b)
{
    const int det = a.determinant;
    if (det == 0)
        return [-1, -1]; // no solution
    const int[][] inv = [[a[1][1], -a[0][1]], [-a[1][0], a[0][0]]];
    int[] sol = matrixVectorMultiply(inv, b);
    if (isValidFraction(sol[0], det) && isValidFraction(sol[1], det)) {
        sol[0] /= det;
        sol[1] /= det;
        return sol;
    }
    return [-1, -1]; // no non-negative integer solution
}

int countTokens(in Problem[] problems)
{
    int count = 0;
    int[] sol;
    foreach (problem; problems) {
        sol = solve(problem.mat, problem.vec);
        if (sol[0] == -1)
            continue;
        count += 3 * sol[0] + sol[1];
    }
    return count;
}

void main(string[] args)
{
    import core.memory : GC;

    GC.disable;

    import std.datetime.stopwatch : AutoStart, StopWatch;
    import std.stdio : writef, writeln;

    const string inputPath = args[1];
    auto sw = StopWatch(AutoStart.no);

    sw.start;
    const Problem[] problems = inputPath.readProblems;
    const int numTokens = problems.countTokens;
    sw.stop;

    writeln("Number of tokens: ", numTokens);

    const double execTime = sw.peek.total!"usecs" / 1000.0;
    writef("Execution time (ms): %.3f\n", execTime);
}
