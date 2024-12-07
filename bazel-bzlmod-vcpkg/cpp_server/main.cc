#include <crow.h>
#include <fmt/ranges.h>

#include <iostream>
#include <string>
#include <vector>

int main() {
  std::vector<std::string> v = {"goodbye", "world"};

  fmt::print("{}\n", v);

  crow::SimpleApp app;

  CROW_ROUTE(app, "/")
  ([]() { return "goodbye world\n"; });

  app.port(3000).multithreaded().run();
}
