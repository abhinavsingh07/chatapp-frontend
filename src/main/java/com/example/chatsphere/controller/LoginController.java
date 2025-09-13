package com.example.chatsphere.controller;

import com.example.chatsphere.dto.AuthDTO;
import com.example.chatsphere.dto.UserDTO;
import com.example.chatsphere.mappings.PageMappings;
import com.example.chatsphere.security.JwtResponse;
import com.example.chatsphere.service.LoginService;
import com.example.chatsphere.service.TokenStoreService;
import com.example.chatsphere.util.SuccessResponse;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.Arrays;

@Controller
public class LoginController {
    private static final Logger logger = LoggerFactory.getLogger(LoginController.class);

    private final TokenStoreService tokenStoreService;

    private final LoginService loginService;

    public LoginController(TokenStoreService tokenStoreService, LoginService loginService) {
        this.tokenStoreService = tokenStoreService;
        this.loginService = loginService;
    }

    // Login page route
    @GetMapping({"/", "/login"})
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
    public String logout(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            String userId = (String) session.getAttribute("userid");
            tokenStoreService.removeToken(userId);
            session.invalidate();
            logger.info("User with ID {} logged out successfully", userId);
        }
        SecurityContextHolder.clearContext();
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
    public String doLogin(@ModelAttribute AuthDTO authDTO, Model model, HttpSession session, HttpServletResponse response) {
        logger.debug("Authenticating user with phone/email: {}", authDTO.getPhoneNumberOrEmail());

        JwtResponse jwtResponse = loginService.validateCredentials(authDTO);

        Cookie jwtCookie = new Cookie("jwt", jwtResponse.getJwtToken());
        jwtCookie.setHttpOnly(false);
        jwtCookie.setPath("/");
        jwtCookie.setAttribute("SameSite", "Strict");
        response.addCookie(jwtCookie);
        //dont need session as all details is in token.
        //on jwt filter we are adding userid and username with every request.
        //session.setAttribute("username", jwtResponse.getName());
        //session.setAttribute("userid", jwtResponse.getId());

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
    public SuccessResponse<JwtResponse> authenticate(@RequestBody AuthDTO authDTO, HttpSession session) {
        logger.debug("Authenticating API user with phone/email: {}", authDTO.getPhoneNumberOrEmail());

        JwtResponse jwtResponse = loginService.validateCredentials(authDTO);
        tokenStoreService.storeToken(jwtResponse.getId(), jwtResponse);
        session.setAttribute("userid", jwtResponse.getId());

        logger.info("API authentication successful for user: {}", jwtResponse.getId());
        return new SuccessResponse<>("200", "Authentication successful", Arrays.asList(jwtResponse));
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

