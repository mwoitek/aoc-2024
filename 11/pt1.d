// NOTE: This solution is not very optimized. However,
// part 2 forces us to implement a better solution. So
// for now this is good enough.

// cat day_11.txt | tr ' ' '\n' | wc -l
const size_t MAX_ELEMS = 8;

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

ulong[] blinkOnce(in ulong[] arr)
{
    import std.array : appender;

    auto arrBuilder = appender!(ulong[]);
    arrBuilder.reserve(2 * arr.length);
    uint nDigits;
    foreach (num; arr) {
        if (num == 0)
            arrBuilder.put(1);
        else if ((nDigits = num.numDigits) % 2 == 0) {
            auto numParts = splitNumber(num, nDigits);
            arrBuilder.put(numParts[0]);
            arrBuilder.put(numParts[1]);
        } else
            arrBuilder.put(num * 2024);
    }
    return arrBuilder.data;
}

ulong[] blink(in ulong[] arr, in uint numBlinks)
{
    ulong[] newArr = arr.blinkOnce;
    foreach (_; 1 .. numBlinks)
        newArr = newArr.blinkOnce;
    return newArr;
}

void main(string[] args)
{
    import std.datetime.stopwatch : AutoStart, StopWatch;
    import std.stdio : writef, writeln;

    const string inputPath = args[1];
    auto sw = StopWatch(AutoStart.no);

    sw.start;
    const ulong[] initArr = inputPath.readInput;
    const ulong[] finalArr = blink(initArr, 25);
    const ulong numStones = finalArr.length;
    sw.stop;

    writeln("Number of stones: ", numStones);

    const double execTime = sw.peek.total!"usecs" / 1000.0;
    writef("Execution time (ms): %.3f\n", execTime);
}
