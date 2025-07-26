package com.example.chatsphere.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class ChatController {
    @GetMapping("/chatpage")
    public String chatPage(Model model) {
        model.addAttribute("view", "chat");
        System.out.println("PAGE CALLS...");
        return "index"; // Loads chat.jsp
    }
}