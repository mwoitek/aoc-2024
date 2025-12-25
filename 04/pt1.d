// NOTE: This code yields the correct answer, but this solution is NOT OPTIMAL.
// Since I'm using regular expressions, I have to build many strings. As a result,
// there's a lot of unnecessary copying of data. Later I should come back to this
// code and remove the regexs. I could also try to solve this problem using a more
// sophisticated search algorithm. However, since the actual input is not that
// big, I suspect that implementing such an algorithm is not worth the effort. But
// for now I'm satisfied. The code works, and it takes ~50 ms to produce the
// answer.

import std.algorithm.iteration : map, sum;
import std.algorithm.searching : count;
import std.array : appender;
import std.datetime.stopwatch : AutoStart, StopWatch;
import std.range : iota, retro;
import std.regex : matchAll, regex;
import std.stdio : File, writef, writeln;

const size_t XMAS_LENGTH = "XMAS".length;
static re = regex(r"(?=(?:XMAS)|(?:SAMX))");

string[] readRows(in string inputPath)
{
    auto arrBuilder = appender!(string[])();
    auto file = File(inputPath, "r");
    foreach (line; file.byLineCopy)
        arrBuilder.put(line);
    return arrBuilder.data;
}

string[] getColumns(in string[] rows)
{
    auto arrBuilder = appender!(string[])();
    foreach (j; 0 .. rows[0].length) {
        auto strBuilder = appender!string();
        foreach (row; rows)
            strBuilder.put(row[j]);
        arrBuilder.put(strBuilder.data);
    }
    return arrBuilder.data;
}

string getForwardDiagonal(in string[] rows, size_t i, size_t j)
{
    auto strBuilder = appender!string();
    while (i < rows.length && j < rows[0].length)
        strBuilder.put(rows[i++][j++]);
    return strBuilder.data;
}

string getBackwardDiagonal(in string[] rows, size_t i, size_t j)
{
    auto strBuilder = appender!string();
    // NOTE: The test for j looks wrong but it is OK
    while (i < rows.length && j < rows[0].length)
        strBuilder.put(rows[i++][j--]);
    return strBuilder.data;
}

string[] getForwardDiagonals(in string[] rows)
{
    auto arrBuilder = appender!(string[])();
    foreach (i; 1 .. rows.length - XMAS_LENGTH + 1)
        arrBuilder.put(getForwardDiagonal(rows, i, 0));
    foreach (j; 0 .. rows[0].length - XMAS_LENGTH + 1)
        arrBuilder.put(getForwardDiagonal(rows, 0, j));
    return arrBuilder.data;
}

string[] getBackwardDiagonals(in string[] rows)
{
    auto arrBuilder = appender!(string[])();
    foreach (i; 1 .. rows.length - XMAS_LENGTH + 1)
        arrBuilder.put(getBackwardDiagonal(rows, i, rows[0].length - 1));
    foreach (j; iota(XMAS_LENGTH - 1, rows[0].length).retro)
        arrBuilder.put(getBackwardDiagonal(rows, 0, j));
    return arrBuilder.data;
}

ulong countHorizontal(in string[] rows)
{
    return rows.map!(a => matchAll(a, re).count).sum;
}

ulong countVertical(in string[] rows)
{
    return rows.getColumns.countHorizontal;
}

ulong countDiagonal(in string[] rows)
{
    return rows.getForwardDiagonals.countHorizontal + rows.getBackwardDiagonals.countHorizontal;
}

ulong countAllMatches(in string[] rows)
{
    return rows.countHorizontal + rows.countVertical + rows.countDiagonal;
}

void main(string[] args)
{
    const string inputPath = args[1];
    auto sw = StopWatch(AutoStart.no);

    sw.start;
    const string[] rows = readRows(inputPath);
    const ulong numMatches = countAllMatches(rows);
    sw.stop;

    writeln("Number of matches: ", numMatches);

    const double execTime = sw.peek.total!"usecs" / 1000.0;
    writef("Execution time (ms): %.3f\n", execTime);
}
