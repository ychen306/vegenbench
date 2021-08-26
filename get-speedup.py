import subprocess

def get_perf(stdout):
  perf = {}
  for line in stdout.decode('utf8').strip().split('\n'):
    line_eles = line.split(',')
    kernel = line_eles[0]
    if len(line_eles) > 2:
        for i in range(1, len(line_eles)-1):
            kernel += "," + line_eles[i]
    time = line_eles[-1]
    perf[kernel] = float(time)
  return perf

opt = get_perf(subprocess.check_output(['./bench']))
ref = get_perf(subprocess.check_output(['./bench-ref']))

geomean = 1
num_kernels = len(opt)-1
for kernel, t in opt.items():


  speedup = ref[kernel] / t
  geomean *= speedup
  print(kernel, speedup)
geomean = geomean ** (1.0/float(num_kernels))
print("geomean", geomean)
