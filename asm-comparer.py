#!/usr/bin/env python3

import os
import sys
import json

def extract_func(file_name, func_name):
    func_lines = []
    with open(file_name, "r") as f:
        start_func = 0
        for line in f:
            line = line.strip()
            if start_func == 0:
                if func_name in line:
                    line_eles = line.split()
                    if line_eles[0][-1] == ":":
                        start_func = 1
            elif start_func == 1:
                line_eles = []
                for line_ele in line.split():
                    if line_ele[0] == "#" or ".cfi_startproc" in line_ele:
                        break
                    line_eles.append(line_ele)
                if len(line_eles) > 0:
                    func_lines.append(" ".join(line_eles))
                if "retq" in line:
                    start_func = 2
    return func_lines

def load_inst_costs():
    inst_costs = {}
    #inst_costs["vinsertps"] = 1.0
    #inst_costs["retq"] = 0.0
    #inst_costs["vmovlhps"] = 1.0
    #inst_costs["movw"] = 1.0
    #inst_costs["vmovups"] = 0.66
    #inst_costs["vhaddps"] = 6
    #inst_costs["vpermpd"] = 3
    #inst_costs["vmovss"] = 1
    #inst_costs["vaddss"] = 4
    #inst_costs["vmovaps"] = 0.66
    #inst_costs["vpermi2ps"] = 3
    #inst_costs["vblendps"] = 1
    #inst_costs["vinsertps"] = 1
    #inst_costs["vinsertf32x4"] = 3
    #inst_costs["vaddps"] = 4
    #inst_costs["vmovshdup"] = 1
    #inst_costs["vpermilpd"] = 1
    #inst_costs["vpermilps"] = 1
    #inst_costs["vextractf128"] = 3
    #inst_costs["vextractf32x4"] = 3
    #inst_costs["vsubss"] = 4
    #inst_costs["vfmadd213ss"] = 4
    #inst_costs["vfnmadd213ss"] = 4
    #inst_costs["vmulss"] = 4
    #inst_costs["vzeroupper"] = 1
    inst_costs["vinsertps"] = 1.0
    inst_costs["retq"] = 0.0
    inst_costs["vmovlhps"] = 1.0
    inst_costs["movw"] = 2.0
    inst_costs["vmovups"] = 0.25
    inst_costs["vhaddps"] = 2
    inst_costs["vpermpd"] = 1
    inst_costs["vmovss"] = 1
    inst_costs["vaddss"] = 0.66
    inst_costs["vmovaps"] = 0.25
    inst_costs["vpermi2ps"] = 1
    inst_costs["vblendps"] = 0.33
    inst_costs["vinsertps"] = 1
    inst_costs["vinsertf32x4"] = 1
    inst_costs["vaddps"] = 0.66
    inst_costs["vmovshdup"] = 1
    inst_costs["vpermilpd"] = 1
    inst_costs["vpermilps"] = 1
    inst_costs["vextractf128"] = 1
    inst_costs["vextractf32x4"] = 2
    inst_costs["vsubss"] = 0.66
    inst_costs["vfmadd213ss"] = 0.66
    inst_costs["vfnmadd213ss"] = 0.66
    inst_costs["vmulss"] = 0.66
    inst_costs["vzeroupper"] = 1

    cma_num = {}
    with open("../vegen/sema/x86/perf.json", "r") as f:
        perf_json = json.loads(f.read())
        for inst in perf_json.items():
            inst_short_name = inst[0].split("_")[0].lower()
            if inst_short_name in inst_costs:
                continue
            inst_specific_costs = {}
            inst_arch_costs = inst[1][0]
            if len(inst[1]) > 1:
                for inst_arch in inst[1]:
                    if "Skylake" in inst_arch.keys():
                        inst_arch_costs = inst_arch
            if "Skylake" in inst_arch_costs.keys():
                inst_arch_costs = inst_arch_costs["Skylake"]
            elif "Icelake" in inst_arch_costs.keys():
                inst_arch_costs = inst_arch_costs["Icelake"]
            if inst_short_name not in inst_costs:
                avg_cost = (float(inst_arch_costs["l"]) + float(inst_arch_costs["t"])) / 2.0
                inst_costs[inst_short_name] = float(inst_arch_costs["l"])
                cma_num[inst_short_name] = 1.0
            else:
                cma_num[inst_short_name] += 1.0
                avg_cost = (float(inst_arch_costs["l"]) + float(inst_arch_costs["t"])) / 2.0
                inst_costs[inst_short_name] += (avg_cost - inst_costs[inst_short_name]) / cma_num[inst_short_name]
    return inst_costs


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Function name required")
        sys.exit(0)
    inst_costs = load_inst_costs()
    func_name = sys.argv[1]
    funcs = {}
    inst_counts = {}
    known_insts = []
    for file_name in os.listdir(os.getcwd()):
        if "kernels" in file_name and ".s" in file_name:
            file_path = os.path.join(os.getcwd(), file_name)
            funcs[file_name] = extract_func(file_path, func_name)
            inst_counts[file_name] = {}
            for line in funcs[file_name]:
                inst = line.split()[0]
                if inst not in known_insts:
                    known_insts.append(inst)
                if inst not in inst_counts[file_name]:
                    inst_counts[file_name][inst] = 0
                inst_counts[file_name][inst] += 1
    max_len = 0
    short_names = {}
    ordered_names = []
    for name in funcs.keys():
        short_name = "-".join(name.split("-")[1:])[:-2]
        if len(short_name) > max_len:
            max_len = len(short_name)
        short_names[name] = short_name
    max_len += 10

    for short_name in short_names.items():
        print("{0}{1}".format(short_name[1], " " * (max_len - len(short_name[1]))), end="")
        ordered_names.append(short_name[0])
    print("")

    for name in ordered_names:
        line = "{0}: {1}".format("insts", len(funcs[name]))
        print("{0}{1}".format(line, " " * (max_len - len(line))), end="")
    print("")

    sum_costs = {}
    for inst in known_insts:
        for name in ordered_names:
            num_insts = 0
            if name not in sum_costs:
                sum_costs[name] = 0
            if inst in inst_counts[name]:
                num_insts = inst_counts[name][inst]
            sum_costs[name] += inst_costs[inst]*num_insts
            line = "{0}: {1}*{2:.2f}={3:.2f}".format(inst, num_insts, inst_costs[inst], inst_costs[inst]*num_insts)
            print("{0}{1}".format(line, " " * (max_len - len(line))), end="")
        print("")
    for name in ordered_names:
        line = "{0}: {1}".format("sum", sum_costs[name])
        print("{0}{1}".format(line, " " * (max_len - len(line))), end="")

    print("")

