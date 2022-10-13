#ifndef BIG_INT
#define BIG_INT

#include <algorithm>
#include <iomanip>  // std::setfill, std::setw
#include <iostream>
#include <sstream>
#include <string>
#include <vector>

using namespace std;

class BigInt {
  const int DIGIT_LIMIT = 9;

  uint64_t SIZE_LIMIT;

  vector<uint64_t> digits;

  BigInt() {}

  uint64_t str_to_int(const string& input, const int from, const int to) const {
    // [from, to)
    uint64_t output = 0;

    for (int i = from; i < to; ++i) output = output * 10 + (input[i] - '0');

    return output;
  }

 public:
  BigInt(const string& input) {
    for (int i = input.length(); i > 0; i -= DIGIT_LIMIT)
      digits.push_back(str_to_int(input, max(i - DIGIT_LIMIT, 0), i));

    SIZE_LIMIT = 1;

    for (int i = 0; i < DIGIT_LIMIT; ++i) SIZE_LIMIT *= 10;
  }

  BigInt operator*(const BigInt& other) const {
    BigInt res;
    uint64_t carry_on = 0;

    res.digits.assign(max(digits.size(), other.digits.size()) * 2 + 1, 0);

    for (int i = 0; i < (int)digits.size(); ++i)
      for (int j = 0; j < (int)other.digits.size(); ++j)
        res.digits[i + j] += digits[i] * other.digits[j];

    for (auto& d : res.digits) {
      d += carry_on;
      carry_on = d / SIZE_LIMIT;
      d %= SIZE_LIMIT;
    }

    while (!res.digits.empty() && res.digits.back() == 0) res.digits.pop_back();

    return res;
  }

  string str() const {
    if (digits.empty()) return "0";

    stringstream ss;
    int idx = digits.size() - 1;

    ss << digits[idx];

    while (idx--) ss << setfill('0') << setw(DIGIT_LIMIT) << digits[idx];

    return ss.str();
  }
};

#endif  // BIG_INT
