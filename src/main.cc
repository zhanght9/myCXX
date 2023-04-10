// Copyright [year] <Copyright Owner>
#include <iostream>
#include <memory>

#include "calculator.h"

int main() {
  auto test = std::make_shared<mymath::Calculator>();
  test->SetNum(10);
  std::cout << test->GetNum() << std::endl;
  return 0;
}
