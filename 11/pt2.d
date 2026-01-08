// NOTE: This code solves the problem. However, this
// solution is not optimized. Currently, this program
// takes approximately 65 ms to run. I had to use
// memoization, which leads to a lot of memory
// allocations. Can this be avoided? Later I should
// consider an alternative approach to this problem.

// cat day_11.txt | tr ' ' '\n' | wc -l
const ulong MAX_ELEMS = 8;

ulong[] readInput(in string inputPath)
{
    import std.algorithm.iteration : map, splitter;
    import std.array : appender;
    import std.conv : to;
    import std.stdio : File;

    auto arrBuilder = appender!(ulong[]);
    arrBuilder.reserve(MAX_ELEMS);
    auto file = File(inputPath, "r");
    foreach (num; file.byLine.front.splitter.map!(to!ulong))
        arrBuilder.put(num);
    return arrBuilder.data;
}

uint numDigits(in ulong num)
{
    return num < 10 ? 1 : 1 + numDigits(num / 10);
}

auto splitNumber(ulong num, in uint nDigits)
{
    import std.typecons : tuple;

    ulong rightHalf = 0;
    ulong pow10 = 1;
    foreach (_; 0 .. nDigits / 2) {
        rightHalf += (num % 10) * pow10;
        num /= 10;
        pow10 *= 10;
    }
    return tuple(num, rightHalf);
}

ulong countFromSingleStone(in ulong stoneValue, in uint numBlinks)
{
    import std.functional : memoize;

    if (numBlinks == 0)
        return 1;
    if (stoneValue == 0)
        return memoize!countFromSingleStone(1, numBlinks - 1);
    const uint nDigits = stoneValue.numDigits;
    if (nDigits % 2 == 0) {
        auto parts = splitNumber(stoneValue, nDigits);
        // dfmt off
        return memoize!countFromSingleStone(parts[0], numBlinks - 1) +
               memoize!countFromSingleStone(parts[1], numBlinks - 1);
        // dfmt on
    }
    return memoize!countFromSingleStone(stoneValue * 2024, numBlinks - 1);
}

ulong countStones(in ulong[] initArr, in uint numBlinks)
{
    import std.algorithm.iteration : reduce;

    return reduce!((a, e) => a + countFromSingleStone(e, numBlinks))(0UL, initArr);
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
    const ulong[] initArr = inputPath.readInput;
    const ulong numStones = countStones(initArr, 75);
    sw.stop;

    writeln("Number of stones: ", numStones);

    const double execTime = sw.peek.total!"usecs" / 1000.0;
    writef("Execution time (ms): %.3f\n", execTime);
}
