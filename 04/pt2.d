import std.array : appender;
import std.datetime.stopwatch : AutoStart, StopWatch;
import std.stdio : File, writef, writeln;

string[] readLines(in string inputPath)
{
    auto arrBuilder = appender!(string[])();
    auto file = File(inputPath, "r");
    foreach (line; file.byLineCopy)
        arrBuilder.put(line);
    return arrBuilder.data;
}

bool checkForwardDiagonal(in string[] lines, in size_t i, in size_t j)
{
    return (lines[i][j] == 'M' && lines[i + 1][j + 1] == 'A' && lines[i + 2][j + 2] == 'S')
        || (lines[i][j] == 'S' && lines[i + 1][j + 1] == 'A' && lines[i + 2][j + 2] == 'M');
}

bool checkBackwardDiagonal(in string[] lines, in size_t i, in size_t j)
{
    return (lines[i][j] == 'M' && lines[i + 1][j - 1] == 'A' && lines[i + 2][j - 2] == 'S')
        || (lines[i][j] == 'S' && lines[i + 1][j - 1] == 'A' && lines[i + 2][j - 2] == 'M');
}

ulong countAllMatches(in string[] lines)
{
    ulong count = 0;
    foreach (i; 0 .. lines.length - 2) {
        foreach (j; 0 .. lines[0].length - 2) {
            if (!checkForwardDiagonal(lines, i, j))
                continue;
            count += checkBackwardDiagonal(lines, i, j + 2) ? 1 : 0;
        }
    }
    return count;
}

void main(string[] args)
{
    const string inputPath = args[1];
    auto sw = StopWatch(AutoStart.no);

    sw.start;
    const string[] lines = readLines(inputPath);
    const ulong numMatches = countAllMatches(lines);
    sw.stop;

    writeln("Number of matches: ", numMatches);

    const double execTime = sw.peek.total!"usecs" / 1000.0;
    writef("Execution time (ms): %.3f\n", execTime);
}
