package com.example.chatsphere.controller;

import com.example.chatsphere.mappings.PageMappings;
import com.example.chatsphere.service.TokenStoreService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class AppRoutesController {

    private static final Logger logger = LoggerFactory.getLogger(ApiCallController.class);
    @Autowired
    private TokenStoreService tokenStoreService;
    //Login page route
    @GetMapping({"/", "/login"})
    public String loginPage(Model model) {
        logger.info("Rendering login page");
        model.addAttribute(PageMappings.VIEW_PLACEHOLDER, PageMappings.LOGIN_VIEW);
        return PageMappings.INDEX_PAGE;
    }

    // Registration page route
    @GetMapping("/register")
    public String registerPage(Model model) {
        logger.info("Rendering registration page");
        model.addAttribute(PageMappings.VIEW_PLACEHOLDER, PageMappings.REGISTER_VIEW);
        return PageMappings.INDEX_PAGE;
    }

    // Home page route
    @GetMapping("/home")
    public String homePage(Model model) {
        logger.info("Rendering home page");
        model.addAttribute(PageMappings.VIEW_PLACEHOLDER, PageMappings.HOME_PAGE_VIEW);
        return PageMappings.INDEX_PAGE;
    }

    @GetMapping("/contact")
    public String contactPage(Model model) {
        logger.info("Rendering contact page");
        model.addAttribute("view", "contact");
        return "index";
    }

    // Error handling route
    @GetMapping("/error")
    public String handleError(Model model, @RequestParam(value = "message", required = false) String message) {
        model.addAttribute(PageMappings.VIEW_PLACEHOLDER, PageMappings.ERROR_VIEW);
        if (message != null) {
            model.addAttribute("errorMessage", message);
        }
        return PageMappings.INDEX_PAGE;
    }

    // Logout route
    @GetMapping("/logout")
    public String logout(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            // Remove from concurrent hashmap
            tokenStoreService.removeToken(session.getAttribute("userid").toString());
            // Invalidate session
            session.invalidate();
        }
        // Clear authentication context
        SecurityContextHolder.clearContext();
        return PageMappings.REDIRECT_LOGIN;
    }
}
