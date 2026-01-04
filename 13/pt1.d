import std.regex : regex;

// grep '^$' day_13.txt | wc -l | awk '{print $1 + 1}'
const ulong MAX_PROBS = 320;

static re = regex(r"(\d+)");

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

bool isValidFraction(in int num, in int den)
{
    return (den > 0 && num >= 0 && num % den == 0) || (den < 0 && num <= 0 && (-num) % (-den) == 0);
}

void solve(in int[] nums, ref int[] solution)
{
    const int a00 = nums[0];
    const int a01 = nums[2];
    const int a10 = nums[1];
    const int a11 = nums[3];
    const int det = a00 * a11 - a01 * a10;
    if (det == 0) {
        solution[0] = -1;
        solution[1] = -1;
        return;
    }
    const int b0 = nums[4];
    const int b1 = nums[5];
    const int x0 = a11 * b0 - a01 * b1;
    const int x1 = a00 * b1 - a10 * b0;
    if (isValidFraction(x0, det) && isValidFraction(x1, det)) {
        solution[0] = x0 / det;
        solution[1] = x1 / det;
        return;
    }
    solution[0] = -1;
    solution[1] = -1;
}

int countTokens(in string inputPath)
{
    int count = 0;
    const int[] nums = inputPath.readNumbers;
    auto solution = new int[](2);
    ulong i = 0;
    while (i < nums.length) {
        solve(nums[i .. i + 6], solution);
        if (solution[0] != -1)
            count += 3 * solution[0] + solution[1];
        i += 6;
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
    const int numTokens = inputPath.countTokens;
    sw.stop;

    writeln("Number of tokens: ", numTokens);

    const double execTime = sw.peek.total!"usecs" / 1000.0;
    writef("Execution time (ms): %.3f\n", execTime);
}
