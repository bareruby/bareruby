#include <cstdio>

#include "kernel.native.hpp"

void BareRuby::Kernel::puts_ovl_bool(bool value) {
  std::fputs(value ? "true\n" : "false\n", stdout);
}
