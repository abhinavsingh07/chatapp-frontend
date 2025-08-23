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
    @Autowired
    private TokenStoreService tokenStoreService;

    @Autowired
    private LoginService loginService;

    //Login page route
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
            // Remove from concurrent hashmap
            tokenStoreService.removeToken(session.getAttribute("userid").toString());
            // Invalidate session
            session.invalidate();
        }
        // Clear authentication context
        SecurityContextHolder.clearContext();
        return PageMappings.REDIRECT_LOGIN;
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


    /**
     * APIs Route
     **/
    @PostMapping("/authenticate")
    public String doLogin(@ModelAttribute AuthDTO authDTO, Model model, HttpSession session, HttpServletResponse response) {
        logger.info("Attempting to authenticate user with phone/email: {}", authDTO.getPhoneNumberOrEmail());

        // Validate credentials → service will throw ApiException if invalid
        JwtResponse jwtResponse = loginService.validateCredentials(authDTO);

        //  put JWT in HttpOnly cookie
        Cookie jwtCookie = new Cookie("jwt", jwtResponse.getJwtToken());
        jwtCookie.setHttpOnly(true);      // prevent JS access
        //jwtCookie.setSecure(true);        // send only over HTTPS for now commenting for dev
        jwtCookie.setPath("/");           // valid across your app
        //jwtCookie.setMaxAge(15 * 60);     // 15 min expiration to do using refesh tokens
        jwtCookie.setAttribute("SameSite", "Strict"); // prevent CSRF
        response.addCookie(jwtCookie);//add cookie in resposne

        // Still keep non-sensitive user details in session if you want
        session.setAttribute("username", jwtResponse.getName());
        session.setAttribute("userid", jwtResponse.getId());

        return PageMappings.REDIRECT_HOME; // redirect user to home page
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


    @PostMapping("/api/authenticate")
    @ResponseBody
    public SuccessResponse<JwtResponse> authenticate(@RequestBody AuthDTO authDTO, HttpSession session) {
        logger.info("Attempting to authenticate user with phone number or email: {}", authDTO.getPhoneNumberOrEmail());
        JwtResponse jwtResponse = loginService.validateCredentials(authDTO);
        // Storing userid plus jwtResponse in concurrent hashmap for centralized token and user details
        tokenStoreService.storeToken(jwtResponse.getId(), jwtResponse);
        session.setAttribute("userid", jwtResponse.getId());
        return new SuccessResponse<>("200", "Authentication successful", Arrays.asList(jwtResponse));
    }

    @PostMapping("/api/register")
    @ResponseBody
    public SuccessResponse<UserDTO> register(@RequestBody UserDTO userDTO) {
        logger.info("Attempting to register user with phone number or email: {}", userDTO.getEmail());
        // Call the service to register the user
        UserDTO userResponse = loginService.registerUser(userDTO);
        return new SuccessResponse<>("200", "Registration successful! Please log in.", Arrays.asList(userResponse));
    }
}
