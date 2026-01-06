// TODO: This solution is the most inefficient I've
// implemented so far. This program takes over a second
// to run. FIND A BETTER APPROACH!!!!!

// fold -w2 day_09.txt | wc -l
const ulong MAX_FILES = 10_000;

struct Gap {
    ulong index;
    ulong length;
}

struct FileBlock {
    ulong index;
    ulong length;
    ulong prevId;
    ulong nextId;

    Gap gap(in FileBlock next)
    {
        const ulong gapIndex = index + length;
        return Gap(gapIndex, next.index - gapIndex);
    }

    ulong checksumContribution(in ulong id)
    {
        ulong contrib = 0;
        foreach (f; index .. index + length)
            contrib += f * id;
        return contrib;
    }
}

struct Disk {
    string map;
    FileBlock[] files;

    this(in string inputPath)
    {
        import std.file : readText;
        import std.string : stripRight;

        map = inputPath.readText.stripRight;
    }

    void fillFiles()
    {
        import std.algorithm.iteration : map;
        import std.array : appender;
        import std.range : enumerate;

        auto arrBuilder = appender!(FileBlock[]);
        arrBuilder.reserve(MAX_FILES);
        ulong index = 0;
        ulong prevId = ulong.max;
        ulong nextId = 1;
        foreach (j, length; this.map.map!(c => c - '0').enumerate) {
            if (j % 2 == 0)
                arrBuilder.put(FileBlock(index, length, prevId++, nextId++));
            index += length;
        }
        files = arrBuilder.data;
    }

    void moveFile(in ulong fileId)
    {
        const FileBlock file = files[fileId];
        FileBlock f1, f2;
        Gap g;
        bool foundGap = false;
        ulong nextId = 0;
        while (nextId < files.length) {
            f1 = files[nextId];
            f2 = files[f1.nextId];
            g = f1.gap(f2);
            if (g.index > file.index)
                break;
            if (g.length >= file.length) {
                foundGap = true;
                break;
            }
            nextId = f1.nextId;
        }
        if (!foundGap)
            return;
        files[file.prevId].nextId = file.nextId;
        files[file.nextId].prevId = file.prevId;
        files[fileId].index = g.index;
        files[fileId].prevId = nextId;
        files[fileId].nextId = f1.nextId;
        files[nextId].nextId = fileId;
        files[f1.nextId].prevId = fileId;
    }

    void compress()
    {
        fillFiles();
        foreach_reverse (fileId; 1 .. files.length)
            moveFile(fileId);
    }

    ulong computeChecksum()
    {
        import std.range : enumerate;

        compress();
        ulong checksum = 0;
        foreach (id, file; files.enumerate)
            checksum += file.checksumContribution(id);
        return checksum;
    }
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
    auto disk = Disk(inputPath);
    const ulong checksum = disk.computeChecksum;
    sw.stop;

    writeln("Checksum: ", checksum);

    const double execTime = sw.peek.total!"usecs" / 1000.0;
    writef("Execution time (ms): %.3f\n", execTime);
}
