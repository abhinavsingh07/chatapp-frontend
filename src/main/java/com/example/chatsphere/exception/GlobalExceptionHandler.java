package com.example.chatsphere.exception;

import com.apiservice.client.ApiException;
import com.example.chatsphere.mappings.ErrorMessageMappings;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import com.example.chatsphere.mappings.PageMappings;
import org.springframework.web.servlet.ModelAndView;

import java.io.IOException;
import java.util.Map;

// This class handles exceptions globally for the application.
@ControllerAdvice
public class GlobalExceptionHandler {

    private static final Logger logger = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    //handle ApiException comes from ApiDispatcherService.And also handling redirection to views accordingly.
    @ExceptionHandler(ApiException.class)
    public ModelAndView handleApiException(ApiException ex, HttpServletRequest request) {
        String requestURI = request.getRequestURI();
        ModelAndView modelAndView = new ModelAndView();

        if (requestURI.contains("/authenticate")) {
            // Show login page with error
            modelAndView.setViewName(PageMappings.INDEX_PAGE);
            modelAndView.addObject("errorMessage", ErrorMessageMappings.toFriendlyMessage(ex.getErrorMessage()));
            modelAndView.addObject(PageMappings.VIEW_PLACEHOLDER, PageMappings.LOGIN_VIEW);
        } else {
            // Generic fallback
            modelAndView.setViewName(PageMappings.INDEX_PAGE);
            modelAndView.addObject("errorMessage", ex.getErrorMessage());
            modelAndView.addObject(PageMappings.VIEW_PLACEHOLDER, PageMappings.ERROR_VIEW);
        }

        return modelAndView;
    }

    @ExceptionHandler(SessionExpiredException.class)
    public Object handleSessionExpired(HttpServletRequest request, HttpServletResponse response) {
        String requestedWith = request.getHeader("X-Requested-With");

        if ("XMLHttpRequest".equalsIgnoreCase(requestedWith)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("message", "Session expired"));
        }

        return new ModelAndView("redirect:/login");
    }

    // Optional: handle other exceptions
    @ExceptionHandler(Exception.class)
    public ModelAndView handleGenericException(Exception ex, HttpServletRequest request) {
        logger.error("An unexpected error occurred: {}", ex.getMessage(), ex);
        ModelAndView modelAndView = new ModelAndView();
        modelAndView.setViewName(PageMappings.ERROR_VIEW);
        modelAndView.addObject("errorMessage", "An unexpected error occurred. Please try again later.");
        return modelAndView;
    }
}
