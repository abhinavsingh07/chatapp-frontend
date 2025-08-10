package com.example.chatsphere.service;

import com.example.chatsphere.dto.AuthDTO;
import com.example.chatsphere.dto.UserDTO;
import com.example.chatsphere.security.JwtResponse;

public interface LoginService {
    /**
     * Validates the user's credentials.
     *
     * @param phoneNumberOrEmail the user's phone number or email
     * @param password           the user's password
     * @return true if the credentials are valid, false otherwise
     */
     JwtResponse validateCredentials(AuthDTO dto);

    /**
     * Registers a new user with the provided details.
     *
     * @param phoneNumberOrEmail the user's phone number or email
     * @param password           the user's password
     * @return true if registration is successful, false otherwise
     */
     UserDTO registerUser(UserDTO dto);
}
