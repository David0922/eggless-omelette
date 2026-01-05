#include <iostream>

#include "utils/math/add.h"
#include "utils/math/nop.h"

int main() {
  using utils::math::add;
  using utils::math::nop;

  std::cout << add({nop({1}).a, nop({2}).a}).c << std::endl;

  return 0;
}
