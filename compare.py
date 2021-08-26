#!/usr/bin/env python3

import os
import sys
sys.path = [x for x in sys.path if "py2" not in x]
import subprocess

def get_perf(output):
    lines = output.decode('utf8').strip().split('\n')
    version = lines[0]
    flags = lines[1]
    kernel_times = {}
    kernel_times["version"] = version
    kernel_times["flags"] = flags
    geomean_times = 1
    num_times = len(lines[2:])
    for line in lines[2:]:
        kernel = ",".join(line.split(",")[0:-1])
        time = float(line.split(",")[-1])
        kernel_times[kernel] = time
        geomean_times *= time
    kernel_times["geomean"] = geomean_times ** (1.0/float(num_times))
    return kernel_times

def get_name(key):
    return "-".join(key.split("-")[1:])

if __name__ == '__main__':
    show_header = True
    req_baseline = None

    for i in range(len(sys.argv)):
        arg = sys.argv[i]
        if arg == "-h":
            show_header = False
        elif i < len(sys.argv)-1 and arg == "-b":
            req_baseline = sys.argv[i+1]

    perfs = {}
    for filename in os.listdir('.'):
        if "bench" in filename and os.path.isfile(filename) and os.access(filename, os.X_OK):
            perfs[filename] = get_perf(subprocess.check_output(["./" + filename]))

    geos = []
    speedups = {}

    for exp in perfs.keys():
        geos.append((exp, perfs[exp]["geomean"]))

    geos_sorted = sorted(geos, key = lambda x: x[1], reverse=True)
    baseline_exp_key = geos_sorted[0][0]
    max_name_len = 0

    if req_baseline is not None:
        if "bench-" not in req_baseline:
            req_baseline = "bench-" + req_baseline
        baseline_exp_key = req_baseline

    baseline_bench = perfs[baseline_exp_key]
    baseline_name = get_name(baseline_exp_key)

    for exp in geos_sorted:
        bench_key = exp[0]
        speedups[bench_key] = {}
        bench_name = get_name(bench_key)
        if len(bench_name) > max_name_len:
            max_name_len = len(bench_name)
        speedup_geomean = 1
        speedup_num = len(perfs[bench_key].keys()) - 2
        if show_header is True:
            print("{0}: {1}".format(bench_name, perfs[bench_key]["version"]))
            print("{0}  {1}\n".format(" " * len(bench_name), perfs[bench_key]["flags"]))
        for bench in perfs[bench_key].items():
            baseline_time = baseline_bench[bench[0]]
            if bench[0] != "geomean" and bench[0] != "version" and bench[0] != "flags":
                speedup = baseline_time/bench[1]
                speedups[bench_key][bench[0]] = speedup
                speedup_geomean *= speedup
        speedup_geomean = speedup_geomean ** (1.0/float(speedup_num))
        speedups[bench_key]["geomean"] = speedup_geomean

    if show_header is True:
        print("\nBaseline: {0}\n".format(baseline_name))
    max_bench_name_len = 0
    for benchmark in baseline_bench:
        if len(benchmark) > max_bench_name_len:
            max_bench_name_len = len(benchmark)
    print(" "*max_bench_name_len, end="\t")
    col_sep = "    "
    for exp in geos_sorted:
        bench_name = get_name(exp[0])
        bench_spacing = " " * (max_name_len-len(bench_name)) + col_sep
        print(bench_name, end=bench_spacing)
    print("")
    for benchmark in baseline_bench:
        if benchmark == "version" or benchmark == "flags":
            continue
        print(benchmark, end="")
        benchmark_spacing = max_bench_name_len - len(benchmark)
        print(" " * benchmark_spacing, end="\t")
        for exp in geos_sorted:
            speedup = round(speedups[exp[0]][benchmark], 3)
            speedup_spacing = " " * (max_name_len-len(str(speedup))) + col_sep
            print(speedup, end=speedup_spacing)
        print("")
