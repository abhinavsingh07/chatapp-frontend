package com.example.chatsphere.service;

import com.example.chatsphere.dto.ContactDTO;
import com.example.chatsphere.dto.ContactUserDTO;
import com.example.chatsphere.util.SuccessResponse;

public interface ContactService {

    /**
     * Adds a new contact for a user.
     *
     * @param contactDTO the contact details to be added
     * @return the saved ContactDTO object containing the persisted contact details
     */
    SuccessResponse<ContactUserDTO> addContact(ContactDTO contactDTO);

    /**
     * Retrieves all contacts associated with a given user ID.
     *
     * @param userId the unique identifier of the user
     * @return a list of ContactDTO objects for the specified user
     */
   SuccessResponse<ContactUserDTO>  getContactsByUserId(String userId);

    /**
     * Removes a contact by its ID.
     *
     * @param contactId the unique identifier of the contact to be removed
     * @return a SuccessResponse indicating the outcome of the operation
     */
    SuccessResponse<String> removeContact(String contactId);
}

