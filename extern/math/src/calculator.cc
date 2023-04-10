#include "calculator.h"
namespace mymath {

bool Calculator::SetNum(const int input) {
  num_ = input;
  return true;
}
int Calculator::GetNum() const { return num_; }

}  // namespace mymath
