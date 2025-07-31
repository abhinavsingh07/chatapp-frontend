package com.example.chatsphere.config;

import com.apiservice.client.ApiDispatcherService;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.web.servlet.view.InternalResourceViewResolver;

import java.util.Map;

@Configuration
public class ApplicationConfig {

    @Bean
    public InternalResourceViewResolver jspViewResolver() {
        InternalResourceViewResolver resolver = new InternalResourceViewResolver();
        resolver.setPrefix("/WEB-INF/views/");   // Folder where JSPs are placed
        resolver.setSuffix(".jsp");              // JSP file extension
        resolver.setViewNames("*.jsp", "*");     // Allow view name matching
        resolver.setOrder(1);                    // In case of multiple view resolvers
        return resolver;
    }

    @Bean
    public ApiDispatcherService apiDispatcherService() {
        ApiDispatcherService service = new ApiDispatcherService();
        service.setBaseUrl("http://localhost:8080/synk"); // Set your base URL here
        return service;
    }
}
