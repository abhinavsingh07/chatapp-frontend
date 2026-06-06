package com.example.chatsphere.service;

import com.example.chatsphere.dto.UserDTO;
import com.example.chatsphere.dto.UserStatusDTO;
import com.example.chatsphere.util.SuccessResponse;

public interface UserService {

    SuccessResponse<UserDTO> getAllUsers();

    SuccessResponse<UserDTO> getByUserId(String userId);

    SuccessResponse<UserStatusDTO> getUserLastActiveStatus(String userId);

    SuccessResponse<UserDTO> getUserMe();
}
