package com.tfg.api.security;

import lombok.RequiredArgsConstructor;
import org.springframework.messaging.Message;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.simp.stomp.StompCommand;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.messaging.support.ChannelInterceptor;
import org.springframework.messaging.support.MessageHeaderAccessor;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class WebSocketAuthInterceptor implements ChannelInterceptor {

    private final JwtUtils jwtUtils;
    private final UserDetailsService userDetailsService;
    private final TokenBlacklistService tokenBlacklistService;

    @Override
    public Message<?> preSend(Message<?> message, MessageChannel channel) {
        StompHeaderAccessor accessor =
                MessageHeaderAccessor.getAccessor(message, StompHeaderAccessor.class);

        if (accessor != null && StompCommand.CONNECT.equals(accessor.getCommand())) {
            String authHeader = accessor.getFirstNativeHeader("Authorization");
            if (authHeader == null || !authHeader.startsWith("Bearer ")) {
                throw new org.springframework.security.authentication.AuthenticationCredentialsNotFoundException(
                        "Se requiere autenticación para conectarse al chat");
            }
            String token = authHeader.substring(7);
            try {
                String email = jwtUtils.extractUsername(token);
                if (email == null) {
                    throw new org.springframework.security.authentication.BadCredentialsException("Token inválido");
                }
                // A07: rechazar tokens revocados por logout
                String jti = jwtUtils.extractJti(token);
                if (tokenBlacklistService.estaRevocado(jti)) {
                    throw new org.springframework.security.authentication.BadCredentialsException("Token revocado");
                }
                UserDetails userDetails = userDetailsService.loadUserByUsername(email);
                if (!jwtUtils.validateToken(token, userDetails)) {
                    throw new org.springframework.security.authentication.BadCredentialsException("Token expirado o inválido");
                }
                UsernamePasswordAuthenticationToken auth =
                        new UsernamePasswordAuthenticationToken(
                                userDetails, null, userDetails.getAuthorities());
                accessor.setUser(auth);
            } catch (AuthenticationException ex) {
                throw ex;
            } catch (Exception ex) {
                throw new org.springframework.security.authentication.BadCredentialsException("Token inválido", ex);
            }
        }
        return message;
    }
}
