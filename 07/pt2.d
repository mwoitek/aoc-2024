// NOTE: Right now, this program takes ~50 ms to run. The real bottleneck seems to
// be the backtracking algorithm that was used to solve this puzzle. Unless I try
// a different approach to this problem, I find it hard to believe that the
// execution time will go much lower. So for now this is good enough.

const char[3] OPERATORS = ['|', '*', '+'];

// wc -l day_07.txt
const size_t EQUATIONS_LENGTH = 850;

// cut -d':' -f2 day_07.txt | sed 's/^ //' | awk '{print NF}' | sort -nru | head -n1
const size_t NUMS_LENGTH = 12;

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
    arrBuilder.reserve(NUMS_LENGTH);
    foreach (num; line[idx + 2 .. $].splitter.map!(to!ulong))
        arrBuilder.put(num);
    return Equation(target, arrBuilder.data);
}

Equation[] readInput(in string inputPath)
{
    import std.array : appender;
    import std.stdio : File;

    auto arrBuilder = appender!(Equation[]);
    arrBuilder.reserve(EQUATIONS_LENGTH);
    auto file = File(inputPath, "r");
    foreach (line; file.byLine)
        arrBuilder.put(line.parseLine);
    return arrBuilder.data;
}

ulong numDigits(in ulong num)
{
    return num < 10 ? 1 : 1 + numDigits(num / 10);
}

ulong concatenate(in ulong a, in ulong b)
{
    import std.math.exponential : pow;

    return a * pow(10, b.numDigits) + b;
}

ulong applyOperator(in char op, in ulong a, in ulong b)
{
    if (op == '|')
        return concatenate(a, b);
    else if (op == '*')
        return a * b;
    else
        return a + b;
}

bool hasSolution(in Equation equation)
{
    bool rec(in ulong val, in size_t idx)
    {
        if (idx + 1 == equation.nums.length)
            return val == equation.target;
        foreach (op; OPERATORS) {
            const ulong newVal = applyOperator(op, val, equation.nums[idx + 1]);
            if (newVal > equation.target)
                continue;
            if (rec(newVal, idx + 1))
                return true;
        }
        return false;
    }

    return rec(equation.nums[0], 0);
}

ulong sumValidTargets(in Equation[] equations)
{
    import std.algorithm.iteration : map;
    import std.parallelism : taskPool;

    return taskPool.reduce!"a + b"(0UL, equations.map!(e => hasSolution(e) ? e.target : 0UL));
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
    const Equation[] equations = inputPath.readInput;
    const ulong sum = equations.sumValidTargets;
    sw.stop;

    writeln("Total calibration result: ", sum);

    const double execTime = sw.peek.total!"usecs" / 1000.0;
    writef("Execution time (ms): %.3f\n", execTime);
}
