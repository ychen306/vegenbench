import subprocess

def get_perf(stdout):
  perf = {}
  for line in stdout.decode('utf8').strip().split('\n'):
    kernel, time = line.split(',')
    perf[kernel] = float(time)
  return perf

opt = get_perf(subprocess.check_output(['./bench']))
ref = get_perf(subprocess.check_output(['./bench-ref']))

for kernel, t in opt.items():
  print(kernel, ref[kernel] / t)
