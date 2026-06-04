package com.example.chatsphere.service;

import com.example.chatsphere.dto.AuthDTO;
import com.example.chatsphere.dto.UserDTO;
import com.example.chatsphere.util.JwtResponse;
import com.example.chatsphere.util.RefreshTokenRequest;

public interface AuthService {
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

    /**
     * Refreshes the JWT token using the refresh token.
     *
     * @param refreshTokenRequest the request containing the refresh token
     * @return JwtResponse containing the new access token and refresh token
     */
     JwtResponse refreshToken(RefreshTokenRequest refreshTokenRequest);
}
