struct Disk {
    string map;
    int[] arr;

    this(in string inputPath)
    {
        import std.file : readText;
        import std.string : stripRight;

        map = inputPath.readText.stripRight;
    }

    void buildArray()
    {
        import std.algorithm.iteration : map, sum;
        import std.range : enumerate;

        const uint arrLength = this.map.map!(c => c - '0').sum;
        arr = new int[](arrLength);
        int val;
        int id = 0;
        int i = 0;
        foreach (j, digit; this.map.map!(c => c - '0').enumerate) {
            val = j % 2 == 0 ? id++ : -1;
            foreach (_; 0 .. digit)
                arr[i++] = val;
        }
    }

    ulong moveLeftPointer(ulong left)
    {
        while (left < arr.length && arr[left] != -1)
            left++;
        return left;
    }

    ulong moveRightPointer(ulong right)
    {
        while (right < arr.length && arr[right] == -1)
            right--;
        return right;
    }

    void compress()
    {
        buildArray();
        ulong left = moveLeftPointer(0);
        ulong right = moveRightPointer(arr.length - 1);
        while (left < right) {
            arr[left] = arr[right];
            arr[right] = -1;
            left = moveLeftPointer(left);
            right = moveRightPointer(right);
        }
    }

    long computeChecksum()
    {
        compress();
        long checksum = 0;
        int i = 0;
        while (i < arr.length && arr[i] != -1)
            checksum += i * arr[i++];
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
    const long checksum = disk.computeChecksum;
    sw.stop;

    writeln("Checksum: ", checksum);

    const double execTime = sw.peek.total!"usecs" / 1000.0;
    writef("Execution time (ms): %.3f\n", execTime);
}
