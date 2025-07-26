package com.example.chatsphere.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.view.InternalResourceViewResolver;

@Configuration
public class AppConfig {

    @Bean
    public InternalResourceViewResolver jspViewResolver() {
        InternalResourceViewResolver resolver = new InternalResourceViewResolver();
        resolver.setPrefix("/WEB-INF/views/");   // Folder where JSPs are placed
        resolver.setSuffix(".jsp");              // JSP file extension
        resolver.setViewNames("*.jsp", "*");     // Allow view name matching
        resolver.setOrder(1);                    // In case of multiple view resolvers
        return resolver;
    }
}
