package com.example.chatsphere.security;

import com.example.chatsphere.service.TokenStoreService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Autowired
    private TokenStoreService tokenStoreService;

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration authConfig) throws Exception {
        return authConfig.getAuthenticationManager();
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        // Disable CSRF protection for simplicity, but consider enabling it in production
        return http
                .csrf(csrf -> csrf.disable()) // disable CSRF for testing (enable in prod)
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers("/", "/login", "/authenticate","/register","/error","/api/authenticate","/api/register").permitAll()
                        .requestMatchers("/WEB-INF/**").permitAll() // allow access to JSPs
                        .requestMatchers("/css/**", "/js/**", "/images/**","/icons/**").permitAll() //allow static resources
                        .anyRequest().authenticated()
                )
                .sessionManagement(sess -> sess.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .formLogin(form -> form.disable()) // using custom login flow
                .logout(logout -> logout
                        .logoutUrl("/logout")
                        .logoutSuccessUrl("/login")
                        .invalidateHttpSession(true)
                        .deleteCookies("JSESSIONID")
                )
                //even if we add this addfilterbefore filter always runs
                .addFilterBefore(new CustomSessionJwtFilter(tokenStoreService), UsernamePasswordAuthenticationFilter.class)
                .build();
    }

}
