namespace mymath {

class Calculator {
 public:
  Calculator() = default;
  ~Calculator() = default;
  bool SetNum(int input);
  int GetNum() const;

 private:
  int num_;
};

}  // namespace mymath
