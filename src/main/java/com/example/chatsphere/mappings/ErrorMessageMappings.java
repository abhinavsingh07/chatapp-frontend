package com.example.chatsphere.mappings;

public class ErrorMessageMappings {

    public static String toFriendlyMessage(String backendCode) {
        return switch (backendCode) {
            case "INVALID_CREDENTIALS" -> "Incorrect username or password.";
            case "GENERIC_ERROR" -> "Backend is temporarily unavailable.";
            default -> "Internal server error. Please try again later.";
        };
    }
}
