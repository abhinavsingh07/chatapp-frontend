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
    // @ResponseBody is used to return JSON response
    private static final Logger logger = LoggerFactory.getLogger(ContactController.class);

    @Autowired
    private ContactService contactService;

    @GetMapping("/contact")
    public String contactPage(Model model) {
        logger.info("Rendering contact page");
        model.addAttribute(PageMappings.VIEW_PLACEHOLDER, PageMappings.CONTACTS_VIEW);
        return PageMappings.INDEX_PAGE;
    }

    @GetMapping("/api/contact/{userId}")
    @ResponseBody
    public SuccessResponse<ContactUserDTO> getContactsByUserId(@PathVariable String userId) {
        logger.info("Fetching contact list for userId: {}", userId);

        SuccessResponse<ContactUserDTO> contacts = contactService.getContactsByUserId(userId);
        logger.info("Found {} contact(s) for userId: {}", contacts.getData().size(), userId);

        String message = contacts.getData().isEmpty()
                ? "No contact found"
                : "Contact(s) fetched successfully";
        contacts.setMessage(message);

        return contacts;
    }

    @PostMapping("/api/contact/add")
    @ResponseBody
    public SuccessResponse<ContactUserDTO> addContact(@RequestBody ContactDTO contactDTO) {
        logger.info("Attempting to add new contact for user: {}", contactDTO.getUserId());
        SuccessResponse<ContactUserDTO> response = contactService.addContact(contactDTO);
        return response;
    }

    @DeleteMapping("/api/contact/{contactId}/remove")
    @ResponseBody
    public SuccessResponse<String> removeContact(@PathVariable("contactId") String contactId) {
        logger.info("Attempting to remove contact with ID: {}", contactId);
        SuccessResponse<String> response = contactService.removeContact(contactId);
        return response;
    }

}