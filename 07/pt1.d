// NOTE: To solve this puzzle, I actually generated a solution for every solvable
// problem. This is not necessary, but I did it in order to check my results. If I
// refactor my solution and remove the corresponding code, I can get to the answer
// even faster. However, this version of my program takes ~6 ms to run. So, for
// now, this code is good enough.

const char[2] OPERATORS = ['+', '*'];

ulong[][ulong] readInput(in string inputPath)
{
    import std.algorithm.iteration : map, splitter;
    import std.algorithm.searching : countUntil;
    import std.array : array;
    import std.conv : to;
    import std.stdio : File;

    ulong[][ulong] equations;
    auto file = File(inputPath, "r");
    foreach (line; file.byLine) {
        auto idx = line.countUntil(':');
        const ulong target = line[0 .. idx].to!ulong;
        ulong[] nums = line[idx + 2 .. $].splitter.map!(to!ulong).array;
        equations[target] = nums;
    }
    return equations;
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
        ops[idx--] = char.init;
        val -= deltaVal;
    }
}

char[] findSolution(in ulong target, in ulong[] nums)
{
    bool buildSolution(ref Candidate c)
    {
        if (c.isFull)
            return c.val == target;
        foreach (op; OPERATORS) {
            const ulong newVal = op == '+' ? c.val + nums[c.idx + 1] : c.val * nums[c.idx + 1];
            if (newVal > target)
                continue;
            const ulong deltaVal = newVal - c.val;
            c.add(op, deltaVal);
            if (buildSolution(c))
                return true;
            c.remove(deltaVal);
        }
        return false;
    }

    Candidate candidate = Candidate(nums);
    return buildSolution(candidate) ? candidate.ops : null;
}

ulong sumValidTargets(in ulong[][ulong] equations)
{
    import std.array : byPair;

    ulong sum = 0;
    foreach (target, nums; equations.byPair) {
        const char[] solution = findSolution(target, nums);
        sum += solution.ptr is null ? 0 : target;
    }
    return sum;
}

void main(string[] args)
{
    import std.datetime.stopwatch : AutoStart, StopWatch;
    import std.stdio : writef, writeln;

    const string inputPath = args[1];
    auto sw = StopWatch(AutoStart.no);

    sw.start;
    const ulong[][ulong] equations = inputPath.readInput;
    const ulong sum = equations.sumValidTargets;
    sw.stop;

    writeln("Total calibration result: ", sum);

    const double execTime = sw.peek.total!"usecs" / 1000.0;
    writef("Execution time (ms): %.3f\n", execTime);
}
