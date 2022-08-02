package dev.mofu.playground.springboot.goodbyeworld;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@SpringBootApplication
public class GoodbyeworldApplication {

  @GetMapping("/")
  public String goodbyeWorld() {
    return "goodbye world\n";
  }

  public static void main(String[] args) {
    SpringApplication.run(GoodbyeworldApplication.class, args);
  }
}
