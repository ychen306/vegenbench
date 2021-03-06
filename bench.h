#ifndef BENCH_H

#define BENCH_H
#include <algorithm>
#include <memory>
#include <stddef.h>
#include <string>
#include <utility>
#include <vector>

static inline uint64_t read_arm_timer() {
  int64_t virtual_timer_value;
  asm volatile("mrs %0, cntvct_el0" : "=r"(virtual_timer_value));
  return virtual_timer_value;
}

static inline uint64_t timer_begin() {
#if defined(__x86_64__) || defined(__amd64__)
  unsigned lo, hi;
  // read begin timer
  asm volatile("CPUID\n\t" /*serialize*/
               "RDTSC\n\t" /*read the clock*/
               "mov %%edx, %0\n\t"
               "mov %%eax, %1\n\t"
               : "=r"(hi), "=r"(lo)::"%rax", "%rbx", "%rcx",
                 "%rdx");
  return (uint64_t)lo | ((uint64_t)hi << 32);
#elif defined(__aarch64__)
  return read_arm_timer();
#else
#error Unsupported architecture
#endif
}

static inline uint64_t timer_end() {
#if defined(__x86_64__) || defined(__amd64__)
  unsigned lo, hi;
  // read end timer
  asm volatile("RDTSCP\n\t" /*read the clock*/
               "mov %%edx, %0\n\t"
               "mov %%eax, %1\n\t"
               "CPUID\n\t"
               : "=r"(hi), "=r"(lo)::"%rax", "%rbx", "%rcx", "%rdx");
  return (uint64_t)lo | ((uint64_t)hi << 32);
#elif defined(__aarch64__)
  return read_arm_timer();
#else
#error Unsupported architecture
#endif
}

// implementation details, users never invoke these directly
namespace detail {
template <typename F, typename Tuple, bool Done, int Total, int... N>
struct call_impl {
  static void call(F f, Tuple &t, unsigned i) {
    call_impl<F, Tuple, Total == 1 + sizeof...(N), Total, N...,
              sizeof...(N)>::call(f, t, i);
  }
};

template <typename F, typename Tuple, int Total, int... N>
struct call_impl<F, Tuple, true, Total, N...> {
  static void call(F f, Tuple &t, unsigned i) { f(std::get<N>(t).get(i)...); }
};
} // namespace detail

// user invokes this
template <typename F, typename Tuple> void call(F f, Tuple &t, unsigned i) {
  typedef typename std::decay<Tuple>::type ttype;
  detail::call_impl<F, Tuple, 0 == std::tuple_size<ttype>::value,
                    std::tuple_size<ttype>::value>::call(f, t, i);
}
template <typename T, size_t _N> struct Vec {
  using ElemTy = T;
  static constexpr size_t N = _N;

  std::unique_ptr<ElemTy[]> buf;
  void allocate(unsigned M) { buf.reset(new ElemTy[N * M]); }

  ElemTy *get(unsigned i) { return buf.get() + i * N; }
};

template <size_t I, typename... VecTypes>
void create_buffers_impl(std::tuple<VecTypes...> &buffers, unsigned iters) {
  std::get<I>(buffers).allocate(iters);
  if (I + 1 < sizeof...(VecTypes))
    create_buffers_impl<(I + 1 < sizeof...(VecTypes) ? I + 1 : I)>(buffers,
                                                                   iters);
}

template <typename... VecTypes>
void create_buffers(std::tuple<VecTypes...> &buffers, unsigned iters) {
  create_buffers_impl<0>(buffers, iters);
}

template <typename FuncTy, FuncTy Func, typename... VecTypes>
double bench(unsigned iters = 100) {
  std::tuple<VecTypes...> buffers;
  create_buffers(buffers, iters);

  constexpr unsigned trials = 128;
  constexpr unsigned warmups = 10;
  std::vector<double> timings;

  auto combine = [](unsigned lo, unsigned hi) -> uint64_t {
    return (uint64_t)lo | ((uint64_t)hi << 32);
  };

  for (int k = 0; k < trials + warmups; k++) {
    unsigned begin_lo, begin_hi, end_lo, end_hi;

    uint64_t begin = timer_begin();

    for (int i = 0; i < iters; i++)
      call(Func, buffers, i);

    uint64_t end = timer_end();
    double elapsed = end - begin;
    if (k >= warmups)
      timings.push_back(elapsed);
  }
  std::sort(timings.begin(), timings.end());
  return (timings[trials / 2] + timings[trials / 2 + 1]) / 2.0;
}

template <typename FuncTy, FuncTy Func> struct Bench {
  std::string name;
  Bench(std::string name) : name(name) {}

  template <typename... VecTypes, typename OS_TY> void run(OS_TY &os) {
    double a = bench<FuncTy, Func, VecTypes...>(200),
           b = bench<FuncTy, Func, VecTypes...>(100);
    double it_per_cyc = (a - b) / 100;
    os << name << "," << it_per_cyc << '\n';
  }
};

#define MAKE_BENCH(FUNC) Bench<decltype(FUNC), FUNC>(#FUNC)

#endif // BENCH_H
