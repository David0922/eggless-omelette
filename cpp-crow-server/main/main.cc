#include <crow.h>

#include <iostream>

#include "lib/my_str.h"

int main() {
  crow::SimpleApp app;

  CROW_ROUTE(app, "/")([]() { return MyStr("goodbye world\n").c_str(); });

  app.port(3000).multithreaded().run();
}
