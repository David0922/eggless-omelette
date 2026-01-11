#ifndef MY_STR_H
#define MY_STR_H

#include <iostream>

class MyStr {
 public:
  MyStr(const char*);

  const char* c_str() const;

 private:
  const char* s;

  friend std::ostream& operator<<(std::ostream&, const MyStr&);
};

std::ostream& operator<<(std::ostream&, const MyStr&);

#endif /* MY_STR_H */
