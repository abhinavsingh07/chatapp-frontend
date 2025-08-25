package com.example.chatsphere.service;

import java.util.List;
import com.example.chatsphere.dto.MessageDTO;

public interface ChatService {

    String getOrCreateConversationId(String fromUserId, String toUserId);

    List<MessageDTO> getMessagesByConversationId(String conversationId);

}
