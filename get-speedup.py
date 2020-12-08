import subprocess

def get_perf(stdout):
  perf = {}
  for line in stdout.decode('utf8').strip().split('\n'):
    kernel, time = line.split(',')
    perf[kernel] = float(time)
  return perf

def report(test_suite):
  opt = get_perf(subprocess.check_output(['./%s' % test_suite]))
  ref = get_perf(subprocess.check_output(['./%s-ref' % test_suite]))
  for kernel, t in opt.items():
    print(kernel, ref[kernel] / t)

print('=========== DSP kernels ==============')
report('bench')

print('=========== OpenCV dot-product kernels ==============')
report('dotprod')
