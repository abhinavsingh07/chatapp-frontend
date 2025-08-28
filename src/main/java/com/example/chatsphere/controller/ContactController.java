package com.example.chatsphere.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseBody;

import com.example.chatsphere.dto.ContactDTO;
import com.example.chatsphere.dto.ContactUserDTO;
import com.example.chatsphere.mappings.PageMappings;
import com.example.chatsphere.service.ContactService;
import com.example.chatsphere.util.SuccessResponse;

@Controller
public class ContactController {

    private static final Logger logger = LoggerFactory.getLogger(ContactController.class);

    private final ContactService contactService;

    public ContactController(ContactService contactService) {
        this.contactService = contactService;
    }

    @GetMapping("/contact")
    public String contactPage(Model model) {
        model.addAttribute(PageMappings.VIEW_PLACEHOLDER, PageMappings.CONTACTS_VIEW);
        return PageMappings.INDEX_PAGE;
    }

    // API endpoints
    @GetMapping("/api/contact/{userId}")
    @ResponseBody
    public SuccessResponse<ContactUserDTO> getContactsByUserId(@PathVariable(required = true) String userId) {
        logger.debug("Fetching contact list for userId={}", userId);

        SuccessResponse<ContactUserDTO> contacts = contactService.getContactsByUserId(userId);

        if (contacts.getData() == null || contacts.getData().isEmpty()) {
            logger.info("No contacts found for userId={}", userId);
        } else {
            logger.info("Found {} contact(s) for userId={}", contacts.getData().size(), userId);
        }

        return contacts;
    }

    @PostMapping("/api/contact/add")
    @ResponseBody
    public SuccessResponse<ContactUserDTO> addContact(@RequestBody ContactDTO contactDTO) {
        logger.info("Adding new contact for userId={}", contactDTO.getUserId());

        SuccessResponse<ContactUserDTO> response = contactService.addContact(contactDTO);

        if (response.getData() != null && !response.getData().isEmpty()) {
            logger.info("Contact added successfully for userId={}", contactDTO.getUserId());
        } else {
            logger.warn("Failed to add contact for userId={}", contactDTO.getUserId());
        }

        return response;
    }

    @DeleteMapping("/api/contact/{contactId}/remove")
    @ResponseBody
    public SuccessResponse<String> removeContact(@PathVariable("contactId") String contactId) {
        logger.info("Removing contact with ID={}", contactId);

        SuccessResponse<String> response = contactService.removeContact(contactId);

        if (response.getData() != null && !response.getData().isEmpty()) {
            logger.info("Contact removed successfully with ID={}", contactId);
        } else {
            logger.warn("Failed to remove contact with ID={}", contactId);
        }

        return response;
    }
}
