const char[2] OPERATORS = ['*', '+'];

// wc -l day_07.txt
const size_t EQUATIONS_LENGTH = 850;

// cut -d':' -f2 day_07.txt | sed 's/^ //' | awk '{print NF}' | sort -nru | head -n1
const size_t NUMS_LENGTH = 12;

struct Equation {
    ulong target;
    ulong[] nums;
}

Equation parseLine(in string line)
{
    import std.algorithm.iteration : map, splitter;
    import std.algorithm.searching : countUntil;
    import std.array : appender;
    import std.conv : to;

    auto idx = line.countUntil(':');
    auto target = line[0 .. idx].to!ulong;
    auto arrBuilder = appender!(ulong[]);
    arrBuilder.reserve(NUMS_LENGTH);
    foreach (num; line[idx + 2 .. $].splitter.map!(to!ulong))
        arrBuilder.put(num);
    return Equation(target, arrBuilder.data);
}

string[] readInput(in string inputPath)
{
    import std.array : appender;
    import std.stdio : File;

    auto arrBuilder = appender!(string[]);
    arrBuilder.reserve(EQUATIONS_LENGTH);
    auto file = File(inputPath, "r");
    foreach (line; file.byLineCopy)
        arrBuilder.put(line);
    return arrBuilder.data;
}

bool hasSolution(in Equation equation)
{
    bool rec(in ulong val, in size_t idx)
    {
        if (idx + 1 == equation.nums.length)
            return val == equation.target;
        foreach (op; OPERATORS) {
            const ulong newVal = op == '*' ? val * equation.nums[idx + 1] : val + equation.nums[idx + 1];
            if (newVal > equation.target)
                continue;
            if (rec(newVal, idx + 1))
                return true;
        }
        return false;
    }

    return rec(equation.nums[0], 0);
}

ulong sumValidTargets(in string inputPath)
{
    import std.algorithm.iteration : map;
    import std.parallelism : taskPool;

    const string[] lines = inputPath.readInput;

    ulong helper(in string line)
    {
        const Equation equation = line.parseLine;
        return hasSolution(equation) ? equation.target : 0UL;
    }

    return taskPool.reduce!"a + b"(0UL, lines.map!helper);
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
    const ulong sum = inputPath.sumValidTargets;
    sw.stop;

    writeln("Total calibration result: ", sum);

    const double execTime = sw.peek.total!"usecs" / 1000.0;
    writef("Execution time (ms): %.3f\n", execTime);
}
