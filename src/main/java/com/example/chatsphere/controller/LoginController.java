package com.example.chatsphere.controller;

import com.example.chatsphere.dto.AuthDTO;
import com.example.chatsphere.dto.UserDTO;
import com.example.chatsphere.mappings.PageMappings;
import com.example.chatsphere.service.LoginService;
import com.example.chatsphere.service.TokenCookieService;
import com.example.chatsphere.util.JwtResponse;
import com.example.chatsphere.util.SuccessResponse;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.Arrays;

@Controller
public class LoginController {
    private static final Logger logger = LoggerFactory.getLogger(LoginController.class);

    private final LoginService loginService;

    private final TokenCookieService tokenCookieService;

    public LoginController(LoginService loginService, TokenCookieService tokenCookieService) {
        this.loginService = loginService;
        this.tokenCookieService = tokenCookieService;
    }

    // Login page route
    @GetMapping({ "/", "/login" })
    public String loginPage(Model model) {
        model.addAttribute(PageMappings.VIEW_PLACEHOLDER, PageMappings.LOGIN_VIEW);
        return PageMappings.INDEX_PAGE;
    }

    // Registration page route
    @GetMapping("/register")
    public String registerPage(Model model) {
        model.addAttribute(PageMappings.VIEW_PLACEHOLDER, PageMappings.REGISTER_VIEW);
        return PageMappings.INDEX_PAGE;
    }

    // Logout route
    @GetMapping("/logout")
    public String logout(HttpServletResponse response) {
        // Remove JWT token cookie and refresh token cookie
        tokenCookieService.clearAuthCookies(response);    
        logger.info("User logged out successfully");
        return PageMappings.REDIRECT_LOGIN;
    }

    // Error handling route
    @GetMapping("/error")
    public String handleError(Model model, @RequestParam(value = "message", required = false) String message) {
        model.addAttribute(PageMappings.VIEW_PLACEHOLDER, PageMappings.ERROR_VIEW);
        if (message != null) {
            model.addAttribute("errorMessage", message);
            logger.warn("Error encountered: {}", message);
        }
        return PageMappings.INDEX_PAGE;
    }

    // APIs Route
    @PostMapping("/authenticate")
    public String doLogin(@ModelAttribute AuthDTO authDTO, Model model, HttpSession session,
            HttpServletResponse response) {
        logger.debug("Authenticating user with phone/email: {}", authDTO.getPhoneNumberOrEmail());

        JwtResponse jwtResponse = loginService.validateCredentials(authDTO);
        // dont need session as all details is in token.
        //create cookies for access and refresh token and add to response.  
        tokenCookieService.writeTokenCookies(response, jwtResponse);
        logger.info("User {} authenticated successfully", jwtResponse.getId());
        return PageMappings.REDIRECT_HOME;
    }

    @PostMapping("/register")
    public String doRegister(@ModelAttribute UserDTO userDTO, Model model) {
        logger.debug("Registering user with email: {}", userDTO.getEmail());

        loginService.registerUser(userDTO);

        model.addAttribute("successMessage", "Registration successful! Please log in.");
        model.addAttribute(PageMappings.VIEW_PLACEHOLDER, PageMappings.REGISTER_VIEW);

        logger.info("User registered successfully with email: {}", userDTO.getEmail());
        return PageMappings.INDEX_PAGE;
    }

    @PostMapping("/api/authenticate")
    @ResponseBody
    public SuccessResponse<JwtResponse> authenticate(@RequestBody AuthDTO authDTO) {
        logger.debug("Authenticating API user with phone/email: {}", authDTO.getPhoneNumberOrEmail());

        JwtResponse jwtResponse = loginService.validateCredentials(authDTO);

        logger.info("API authentication successful for user: {}", jwtResponse.getId());
        return new SuccessResponse<>("200", "Authentication successful", java.util.Arrays.asList(jwtResponse));
    }

    @PostMapping("/api/register")
    @ResponseBody
    public SuccessResponse<UserDTO> register(@RequestBody UserDTO userDTO) {
        logger.debug("Registering API user with email: {}", userDTO.getEmail());

        UserDTO userResponse = loginService.registerUser(userDTO);

        logger.info("API registration successful for user: {}", userResponse.getEmail());
        return new SuccessResponse<>("200", "Registration successful! Please log in.", Arrays.asList(userResponse));
    }
}
