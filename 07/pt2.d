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

struct Candidate {
    char[] ops;
    size_t idx;
    ulong val;

    this(in ulong[] nums)
    {
        this.ops = new char[](nums.length - 1);
        this.idx = 0;
        this.val = nums[0];
    }

    bool isFull()
    {
        return ops.length == idx;
    }

    void add(in char op, in ulong deltaVal)
    {
        ops[idx++] = op;
        val += deltaVal;
    }

    void remove(in ulong deltaVal)
    {
        ops[--idx] = char.init;
        val -= deltaVal;
    }
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

char[] findSolution(in Equation equation)
{
    bool buildSolution(ref Candidate c)
    {
        if (c.isFull)
            return c.val == equation.target;
        foreach (op; OPERATORS) {
            const ulong newVal = applyOperator(op, c.val, equation.nums[c.idx + 1]);
            if (newVal > equation.target)
                continue;
            const ulong deltaVal = newVal - c.val;
            c.add(op, deltaVal);
            if (buildSolution(c))
                return true;
            c.remove(deltaVal);
        }
        return false;
    }

    Candidate c = Candidate(equation.nums);
    return buildSolution(c) ? c.ops : null;
}

ulong sumValidTargets(in Equation[] equations)
{
    ulong sum = 0;
    foreach (equation; equations) {
        const char[] solution = findSolution(equation);
        sum += solution.ptr is null ? 0 : equation.target;
    }
    return sum;
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
