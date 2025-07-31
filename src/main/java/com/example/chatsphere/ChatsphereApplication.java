package com.example.chatsphere;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.ComponentScan;

@SpringBootApplication
@ComponentScan(basePackages = {"com.example.chatsphere", "com.apiservice.client"})
public class ChatsphereApplication {

	public static void main(String[] args) {
		SpringApplication.run(ChatsphereApplication.class, args);
	}

}
