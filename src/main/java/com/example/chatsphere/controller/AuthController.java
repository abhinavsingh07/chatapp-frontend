package com.example.chatsphere.controller;

import com.apiservice.client.ApiException;
import com.example.chatsphere.dto.AuthDTO;
import com.example.chatsphere.dto.UserDTO;
import com.example.chatsphere.mappings.ErrorMessageMappings;
import com.example.chatsphere.mappings.PageMappings;
import com.example.chatsphere.service.AuthService;
import com.example.chatsphere.service.CookieService;
import com.example.chatsphere.util.JwtResponse;
import com.example.chatsphere.util.RefreshTokenRequest;
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
public class AuthController {
    private static final Logger logger = LoggerFactory.getLogger(AuthController.class);

    private final AuthService authService;

    private final CookieService tokenCookieService;

    public AuthController(AuthService authService, CookieService tokenCookieService) {
        this.authService = authService;
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

    // Forgot password page route
    @GetMapping("/forgot-password")
    public String forgotPasswordPage(Model model) {
        model.addAttribute(PageMappings.VIEW_PLACEHOLDER, PageMappings.FORGOT_PASSWORD_VIEW);
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

  
    @PostMapping("/authenticate")
    public String doLogin(@ModelAttribute AuthDTO authDTO, Model model, HttpSession session,
            HttpServletResponse response) {
        logger.debug("Authenticating user with phone/email: {}", authDTO.getPhoneNumberOrEmail());

        try {
            JwtResponse jwtResponse = authService.validateCredentials(authDTO);
            // dont need session as all details is in token.
            //create cookies for access and refresh token and add to response.
            tokenCookieService.writeTokenCookies(response, jwtResponse);
            logger.info("User {} authenticated successfully", jwtResponse.getId());
            return PageMappings.REDIRECT_HOME;
        } catch (ApiException ex) {
            logger.warn("Login failed for phone/email: {}", authDTO.getPhoneNumberOrEmail());
            model.addAttribute("errorMessage", ErrorMessageMappings.toFriendlyMessage(ex.getErrorMessage()));
            model.addAttribute("auth", authDTO);
            model.addAttribute(PageMappings.VIEW_PLACEHOLDER, PageMappings.LOGIN_VIEW);
            return PageMappings.INDEX_PAGE;
        } catch (Exception ex) {
            logger.error("Unexpected login failure for phone/email: {}", authDTO.getPhoneNumberOrEmail(), ex);
            model.addAttribute("errorMessage", "Unable to sign in. Please check your credentials and try again.");
            model.addAttribute("auth", authDTO);
            model.addAttribute(PageMappings.VIEW_PLACEHOLDER, PageMappings.LOGIN_VIEW);
            return PageMappings.INDEX_PAGE;
        }
    }

    @PostMapping("/register")
    public String doRegister(@ModelAttribute UserDTO userDTO, Model model) {
        logger.debug("Registering user with email: {}", userDTO.getEmail());

        authService.registerUser(userDTO);

        model.addAttribute("successMessage", "Registration successful! Please log in.");
        model.addAttribute(PageMappings.VIEW_PLACEHOLDER, PageMappings.REGISTER_VIEW);

        logger.info("User registered successfully with email: {}", userDTO.getEmail());
        return PageMappings.INDEX_PAGE;
    }

    @PostMapping("/forgot-password")
    public String doForgotPassword(@ModelAttribute AuthDTO authDTO, Model model) {
        logger.debug("Processing forgot password request for phone/email: {}", authDTO.getPhoneNumberOrEmail());

        try {
            SuccessResponse<String> response = authService.forgotPassword(authDTO);
            String message = response != null && response.getMessage() != null
                    ? response.getMessage()
                    : "Password reset successful. Please sign in with your new password.";
            model.addAttribute("successMessage", message);
            model.addAttribute(PageMappings.VIEW_PLACEHOLDER, PageMappings.LOGIN_VIEW);
            logger.info("Forgot password request successful for phone/email: {}", authDTO.getPhoneNumberOrEmail());
            return PageMappings.INDEX_PAGE;
        } catch (ApiException ex) {
            logger.warn("Forgot password request failed for phone/email: {}", authDTO.getPhoneNumberOrEmail());
            model.addAttribute("errorMessage", ErrorMessageMappings.toFriendlyMessage(ex.getErrorMessage()));
            model.addAttribute("auth", authDTO);
            model.addAttribute(PageMappings.VIEW_PLACEHOLDER, PageMappings.FORGOT_PASSWORD_VIEW);
            return PageMappings.INDEX_PAGE;
        } catch (Exception ex) {
            logger.error("Unexpected forgot password failure for phone/email: {}",
                    authDTO.getPhoneNumberOrEmail(), ex);
            model.addAttribute("errorMessage", "Unable to reset password. Please check your details and try again.");
            model.addAttribute("auth", authDTO);
            model.addAttribute(PageMappings.VIEW_PLACEHOLDER, PageMappings.FORGOT_PASSWORD_VIEW);
            return PageMappings.INDEX_PAGE;
        }
    }

    // APIs Route
    @PostMapping("/api/authenticate")
    @ResponseBody
    public SuccessResponse<JwtResponse> authenticate(@RequestBody AuthDTO authDTO) {
        logger.debug("Authenticating API user with phone/email: {}", authDTO.getPhoneNumberOrEmail());

        JwtResponse jwtResponse = authService.validateCredentials(authDTO);

        logger.info("API authentication successful for user: {}", jwtResponse.getId());
        return new SuccessResponse<>("200", "Authentication successful", java.util.Arrays.asList(jwtResponse));
    }

    @PostMapping("/api/register")
    @ResponseBody
    public SuccessResponse<UserDTO> register(@RequestBody UserDTO userDTO) {
        logger.debug("Registering API user with email: {}", userDTO.getEmail());

        UserDTO userResponse = authService.registerUser(userDTO);

        logger.info("API registration successful for user: {}", userResponse.getEmail());
        return new SuccessResponse<>("200", "Registration successful! Please log in.", Arrays.asList(userResponse));
    }

    @PostMapping("/api/forgot-password")
    @ResponseBody
    public SuccessResponse<String> forgotPassword(@RequestBody AuthDTO authDTO) {
        logger.debug("Processing API forgot password request for phone/email: {}", authDTO.getPhoneNumberOrEmail());

        SuccessResponse<String> response = authService.forgotPassword(authDTO);

        logger.info("API forgot password request successful for phone/email: {}", authDTO.getPhoneNumberOrEmail());
        return response;
    }

    @PostMapping("/api/tokenrefresh")
    @ResponseBody
    public SuccessResponse<JwtResponse> refreshAccessToken(@RequestBody RefreshTokenRequest refreshTokenRequest, HttpServletResponse response) {
        logger.debug("Refreshing access token");

        JwtResponse jwtResponse = authService.refreshToken(refreshTokenRequest);
        tokenCookieService.writeTokenCookies(response, jwtResponse);

        logger.info("Access token refreshed successfully for user: {}", jwtResponse.getId());
        return new SuccessResponse<>("200", "Token refreshed successfully", java.util.Arrays.asList(jwtResponse));
    }
}
