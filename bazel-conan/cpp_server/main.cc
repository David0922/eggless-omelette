#include <crow.h>

int main() {
  crow::SimpleApp app;
  CROW_ROUTE(app, "/")
  ([]() { return "goodbye world\n"; });
  app.port(3000).multithreaded().run();
}
