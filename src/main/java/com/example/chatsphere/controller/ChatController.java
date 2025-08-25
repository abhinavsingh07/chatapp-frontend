package com.example.chatsphere.controller;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import com.example.chatsphere.dto.MessageDTO;
import com.example.chatsphere.dto.UserDTO;
import com.example.chatsphere.service.ChatService;
import com.example.chatsphere.service.UserService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.ResponseBody;

import com.example.chatsphere.mappings.PageMappings;
import com.example.chatsphere.util.SuccessResponse;

@Controller
public class ChatController {
    private static final Logger logger = LoggerFactory.getLogger(ChatController.class);

    @Autowired
    private ChatService chatService;

    @Autowired
    private UserService userService;

   @GetMapping("/chat-room/{conversationId}/{toUserId}")
    public String openChatRoom(@PathVariable(required=true) String conversationId,@PathVariable(required=true) String toUserId, Model model) {
    logger.info("Opening chat room for conversationId: {}", conversationId);

    if (conversationId == null || conversationId.isBlank()) {
        logger.error("Conversation ID is missing in request");
        model.addAttribute("error", "Invalid conversation");
        model.addAttribute("conversationId", null);
        model.addAttribute("messages", Collections.emptyList());
    } else {
        // Fetch messages for the conversation
        List<MessageDTO> messages = chatService.getMessagesByConversationId(conversationId);
        model.addAttribute("conversationId", conversationId);
        model.addAttribute("toUserId",toUserId);
        model.addAttribute("messages", messages);
        //fetch user details from touserid
         SuccessResponse<UserDTO> userResponse = userService.getByUserId(toUserId);
         if(userResponse.getData() != null && !userResponse.getData().isEmpty()) {
             model.addAttribute("toUserDetails", userResponse.getData().get(0));
         } else {
             model.addAttribute("toUserDetails", null);
         }
        logger.info("Loaded {} messages for conversationId {}", messages.size(), conversationId);
    }

    // always set the placeholder for layout
    model.addAttribute(PageMappings.VIEW_PLACEHOLDER, PageMappings.CHAT_PAGE_VIEW);

    return PageMappings.INDEX_PAGE;
}



    @GetMapping("/api/conversation/get-or-create/{fromUserId}/{toUserId}")
    @ResponseBody
    public SuccessResponse<String> getOrCreateConversationId(@PathVariable(required=true) String fromUserId, @PathVariable(required=true) String toUserId) {

        logger.info("Request to get or create conversation between {} and {}", fromUserId, toUserId);

        String conversationId = chatService.getOrCreateConversationId(fromUserId, toUserId);

        return new SuccessResponse<>("200", "Conversation fetched/created successfully", Arrays.asList(conversationId));
    }

    @GetMapping("/api/messages/conversation/{conversationId}")
    @ResponseBody
    public SuccessResponse<MessageDTO> getMessagesByConversationId(@PathVariable(required=true) String conversationId) {

        logger.info("Request to fetch messages for conversationId: {}", conversationId);

        List<MessageDTO> messages = chatService.getMessagesByConversationId(conversationId);

        String message = messages.isEmpty() ? "No messages found for this conversation" : "Messages fetched successfully";

        return new SuccessResponse<>("200", message, messages);
    }
}