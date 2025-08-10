package com.example.chatsphere.controller;

import com.example.chatsphere.mappings.PageMappings;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class ChatHomeController {
    private static final Logger logger = LoggerFactory.getLogger(ChatHomeController.class);

    // Home page route
    @GetMapping("/home")
    public String homePage(Model model) {
        logger.info("Rendering home page");
        model.addAttribute(PageMappings.VIEW_PLACEHOLDER, PageMappings.HOME_PAGE_VIEW);
        return PageMappings.INDEX_PAGE;
    }


}
