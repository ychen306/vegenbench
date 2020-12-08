#include <complex>

void cmul(std::complex<double> *__restrict__ a,
          std::complex<double> *__restrict__ b,
          std::complex<double> *__restrict__ c) {
  *c = *a * *b;
}
