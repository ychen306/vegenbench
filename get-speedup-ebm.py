#!/usr/bin/env python

import sys
import os
import glob
import collections

def get_times(times_file_path):
    ret_dict = collections.OrderedDict()
    with open(times_file_path) as f:
        start_kernels = 0
        start_timings = 0
        for line in f.read().split("\n"):
            if len(line.strip()) == 0:
                continue
            elif "Simulation running" in line and start_kernels == 0:
                start_kernels = 1
            elif ("Writing stats to" in line or "Dumping stats" in line) and start_kernels == 1:
                start_kernels = 2
            elif "Simulation completed" in line and start_timings == 0:
                start_timings = 1
            elif "Warnings" in line and start_timings == 1:
                start_timings = 2
            elif start_kernels == 1:
                kernel = ",".join(line.split(",")[0:-1])
                time = line.split(",")[-1]
                ret_dict[kernel] = float(time)
            elif start_timings == 1:
                if "Cycles" in line and "/" not in line:
                    measure = line.split("=")[0].strip()
                    amount = line.split("=")[1].strip()
                    ret_dict[measure] = float(amount)
                elif "Insts" in line:
                    measure = line.split("=")[0].strip()
                    amount = line.split("=")[1].strip()
                    ret_dict[measure] = float(amount)
    return ret_dict


if __name__ == "__main__":
    exp_dir = None
    exp_results = {}

    if len(sys.argv) < 2:
        print("Results directory required")
        sys.exit(1)
    exp_dir = sys.argv[1]

    if not os.path.exists(exp_dir) or not os.path.isdir(exp_dir):
        print("Path must exist and be a directory")
        sys.exit(1)

    for exp_name in os.listdir(exp_dir):
        exp_path = os.path.join(exp_dir, exp_name)
        exp_title = "-".join(exp_name.split("-")[1:])
        if not os.path.isdir(exp_path):
            continue
        for f in os.listdir(exp_path): # This is because python2/3 are annoying with re on the cluster
            if "bench" in f and ".stdout" in f:
                exp_results[exp_title] = get_times(os.path.join(exp_path, f))

    results_keys = sorted(exp_results.keys())
    pairs_complete = {}
    for result_baseline in results_keys:
        if result_baseline not in pairs_complete:
            pairs_complete[result_baseline] = []
        for result_comp in results_keys:
            if result_comp not in pairs_complete:
                pairs_complete[result_comp] = []
            if result_comp in pairs_complete[result_baseline] or result_baseline in pairs_complete[result_comp]:
                continue
            if result_baseline == result_comp:
                continue
            print("{0} vs {1}".format(result_comp, result_baseline))
            geomean = 1.0
            num_exp = 0
            calc_geomean = True
            for bench in exp_results[result_baseline].keys():
                if bench == "Cycles":
                    calc_geomean = False
                    geomean = geomean ** (1.0 / num_exp)
                    print("geomean: {0}\n".format(geomean))
                uplift = exp_results[result_baseline][bench] / exp_results[result_comp][bench]
                print("{0}: {1}".format(bench, uplift))
                if calc_geomean is True:
                    geomean *= uplift
                    num_exp += 1

            print("")
            pairs_complete[result_baseline].append(result_comp)
            pairs_complete[result_comp].append(result_baseline)
