const char[3] OPERATORS = ['+', '*', '|'];

struct Equation {
    ulong target;
    ulong[] nums;
}

Equation parseLine(in char[] line)
{
    import std.algorithm.iteration : map, splitter;
    import std.algorithm.searching : countUntil;
    import std.array : appender;
    import std.conv : to;

    auto idx = line.countUntil(':');
    auto target = line[0 .. idx].to!ulong;
    auto arrBuilder = appender!(ulong[]);
    foreach (num; line[idx + 2 .. $].splitter.map!(to!ulong))
        arrBuilder.put(num);
    return Equation(target, arrBuilder.data);
}

Equation[] readInput(in string inputPath)
{
    import std.array : appender;
    import std.stdio : File;

    auto arrBuilder = appender!(Equation[]);
    auto file = File(inputPath, "r");
    foreach (line; file.byLine)
        arrBuilder.put(line.parseLine);
    return arrBuilder.data;
}

uint numDigits(ulong num)
{
    if (num == 0)
        return 1;
    uint count = 0;
    while (num != 0) {
        num /= 10;
        count++;
    }
    return count;
}

ulong concatenate(ulong a, ulong b)
{
    import std.math.exponential : pow;

    return a * pow(10, b.numDigits) + b;
}

ulong applyOperator(char op, ulong a, ulong b)
{
    ulong res;
    switch (op) {
    case '+':
        res = a + b;
        break;
    case '*':
        res = a * b;
        break;
    case '|':
        res = concatenate(a, b);
        break;
    default:
        assert(false); // should be unreachable
    }
    return res;
}

bool hasSolution(in Equation equation)
{
    auto target = equation.target;
    auto nums = equation.nums;

    bool rec(in ulong val, in size_t idx)
    {
        if (idx + 1 == nums.length)
            return val == target;
        foreach (op; OPERATORS) {
            const ulong newVal = applyOperator(op, val, nums[idx + 1]);
            if (newVal > target)
                continue;
            if (rec(newVal, idx + 1))
                return true;
        }
        return false;
    }

    return rec(nums[0], 0);
}

ulong sumValidTargets(in Equation[] equations)
{
    import std.algorithm.iteration : filter, map, sum;

    return equations.filter!(hasSolution)
        .map!(e => e.target)
        .sum;
}

void main(string[] args)
{
    import core.memory : GC;
    import std.datetime.stopwatch : AutoStart, StopWatch;
    import std.stdio : writef, writeln;

    GC.disable;
    const string inputPath = args[1];
    auto sw = StopWatch(AutoStart.no);

    sw.start;
    const Equation[] equations = inputPath.readInput;
    const ulong sum = equations.sumValidTargets;
    sw.stop;

    writeln("Total calibration result: ", sum);

    const double execTime = sw.peek.total!"usecs" / 1000.0;
    writef("Execution time (ms): %.3f\n", execTime);
}
