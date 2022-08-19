#include <crow.h>
#include <fmt/ranges.h>

#include <iostream>
#include <string>
#include <vector>

#include "lib/my_str.h"

int main() {
  std::vector<std::string> v = {"boodbye", "world"};

  fmt::print("{}\n", v);

  crow::SimpleApp app;

  CROW_ROUTE(app, "/")([]() { return MyStr("goodbye world\n").c_str(); });

  app.port(3000).multithreaded().run();
}
