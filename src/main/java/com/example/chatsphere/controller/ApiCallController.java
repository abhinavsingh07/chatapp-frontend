package com.example.chatsphere.controller;

import com.example.chatsphere.dto.AuthDTO;
import com.example.chatsphere.dto.JwtResponse;
import com.example.chatsphere.dto.UserDTO;
import com.example.chatsphere.service.LoginService;
import com.example.chatsphere.mappings.PageMappings;
import com.example.chatsphere.service.TokenStoreService;
import jakarta.servlet.http.HttpSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class ApiCallController {
    private static final Logger logger = LoggerFactory.getLogger(ApiCallController.class);
    @Autowired
    private LoginService loginService;

    @Autowired
    private TokenStoreService tokenStoreService;


    @PostMapping("/authenticate")
    public String doLogin(@ModelAttribute AuthDTO authDTO, Model model, HttpSession session) {
        logger.info("Attempting to authenticate user with phone number or email: {}", authDTO.getPhoneNumberOrEmail());
        JwtResponse jwtResponse = loginService.validateCredentials(authDTO);// may throw ApiException goes to global exception handler then logic go to login page and show error
        //Storing userid plus jwtResponse in concurrent hashmap for centralized token and user details
        tokenStoreService.storeToken(jwtResponse.getId(), jwtResponse);
        //Store details to user session
        session.setAttribute("username", jwtResponse.getName());
        session.setAttribute("userid", jwtResponse.getId());
        return PageMappings.REDIRECT_HOME;
    }


    @PostMapping("/register")
    public String doRegister(@ModelAttribute UserDTO userDTO, Model model) {
        logger.info("Attempting to register user with phone number or email: {}", userDTO.getEmail());
        // Call the service to register the user
        loginService.registerUser(userDTO);
        // Redirect to login page after successful registration
        model.addAttribute("successMessage", "Registration successful! Please log in.");
        model.addAttribute(PageMappings.VIEW_PLACEHOLDER, PageMappings.REGISTER_VIEW);
        return PageMappings.INDEX_PAGE;
    }

    @GetMapping("/search")
    public void doSearch(@RequestParam String keyword) {
        logger.info("do search with keyword: {}", keyword);
//        model.addAttribute(PageMappings.VIEW_PLACEHOLDER, PageMappings.HOME_PAGE_VIEW);
//        return PageMappings.INDEX_PAGE;
    }

}