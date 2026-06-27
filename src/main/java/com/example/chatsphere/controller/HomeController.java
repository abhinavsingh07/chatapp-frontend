package com.example.chatsphere.controller;

import com.example.chatsphere.dto.ConversationLastMsgDTO;
import com.example.chatsphere.mappings.PageMappings;
import com.example.chatsphere.service.ChatService;
import jakarta.servlet.http.HttpServletRequest;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import java.util.List;

@Controller
public class HomeController {
    private static final Logger logger = LoggerFactory.getLogger(HomeController.class);

    private final ChatService chatService;

    public HomeController(ChatService chatService) {
        this.chatService = chatService;
    }

    // Home page route
    @GetMapping("/home")
    public String homePage(Model model, HttpServletRequest request) {
        model.addAttribute(PageMappings.VIEW_PLACEHOLDER, PageMappings.HOME_PAGE_VIEW);
        logger.info("Loading home page for user");
        String loggedInUserid = (String) request.getAttribute("userId");
        List<ConversationLastMsgDTO> chatData = chatService.getLastMessageByLoggedInUserId(loggedInUserid);
        //logger.info("/home endpoint called. Retrieved chat data for user {}: {}", loggedInUserid, chatData);
        model.addAttribute("chatData", chatData);
        //get loggedin user contacts ids
        //todo
        // List<String> loggedInUserContactIds = chatData.stream()
        //         .map(ConversationLastMsgDTO::getParticipantId)
        //         .filter(participantId -> participantId != null && !participantId.isBlank())
        //         .toList();
        // model.addAttribute("chatData", chatData);
        // request.setAttribute("loggedInUserContactIds", loggedInUserContactIds);
        return PageMappings.INDEX_PAGE;
    }

    // Settings page route
    @GetMapping("/settings")
    public String settingsPage(Model model) {
        model.addAttribute(PageMappings.VIEW_PLACEHOLDER, PageMappings.SETTINGS_VIEW);
        return PageMappings.INDEX_PAGE;
    }

}
