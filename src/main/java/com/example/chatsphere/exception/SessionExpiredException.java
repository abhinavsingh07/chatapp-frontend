package com.example.chatsphere.exception;

public class SessionExpiredException extends RuntimeException {
    public SessionExpiredException(String message, Throwable cause) {
        super(message, cause);
    }

    public SessionExpiredException(String message) {
        super(message);
    }
}
