package com.tfg.api.security;

import com.tfg.api.models.entity.Practica;
import com.tfg.api.models.repository.PracticaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.Message;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.simp.stomp.StompCommand;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.messaging.support.ChannelInterceptor;
import org.springframework.messaging.support.MessageHeaderAccessor;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.stereotype.Component;

import java.security.Principal;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Component
@RequiredArgsConstructor
public class WebSocketAuthInterceptor implements ChannelInterceptor {

    private final JwtUtils jwtUtils;
    private final UserDetailsService userDetailsService;
    private final TokenBlacklistService tokenBlacklistService;
    private final PracticaRepository practicaRepository;

    // Captura el practicaId del destino /topic/practica/{id}
    private static final Pattern TOPIC_PRACTICA = Pattern.compile("^/topic/practica/(\\d+)$");

    @Override
    public Message<?> preSend(Message<?> message, MessageChannel channel) {
        StompHeaderAccessor accessor =
                MessageHeaderAccessor.getAccessor(message, StompHeaderAccessor.class);

        if (accessor == null) return message;

        if (StompCommand.CONNECT.equals(accessor.getCommand())) {
            autenticarConexion(accessor);
        } else if (StompCommand.SUBSCRIBE.equals(accessor.getCommand())) {
            validarSuscripcion(accessor);
        }

        return message;
    }

    // ── Autenticación en CONNECT ──────────────────────────────────────────────

    private void autenticarConexion(StompHeaderAccessor accessor) {
        String authHeader = accessor.getFirstNativeHeader("Authorization");
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            throw new org.springframework.security.authentication
                    .AuthenticationCredentialsNotFoundException(
                    "Se requiere autenticación para conectarse al chat");
        }
        String token = authHeader.substring(7);
        try {
            String email = jwtUtils.extractUsername(token);
            if (email == null) {
                throw new BadCredentialsException("Token inválido");
            }
            String jti = jwtUtils.extractJti(token);
            if (tokenBlacklistService.estaRevocado(jti)) {
                throw new BadCredentialsException("Token revocado");
            }
            UserDetails userDetails = userDetailsService.loadUserByUsername(email);
            if (!jwtUtils.validateToken(token, userDetails)) {
                throw new BadCredentialsException("Token expirado o inválido");
            }
            UsernamePasswordAuthenticationToken auth =
                    new UsernamePasswordAuthenticationToken(
                            userDetails, null, userDetails.getAuthorities());
            accessor.setUser(auth);
        } catch (AuthenticationException ex) {
            throw ex;
        } catch (Exception ex) {
            throw new BadCredentialsException("Token inválido", ex);
        }
    }

    // ── Autorización en SUBSCRIBE ─────────────────────────────────────────────

    private void validarSuscripcion(StompHeaderAccessor accessor) {
        String destination = accessor.getDestination();
        if (destination == null) return;

        Matcher m = TOPIC_PRACTICA.matcher(destination);
        if (!m.matches()) return; // destino no sensible, se permite

        long practicaId = Long.parseLong(m.group(1));

        Principal principal = accessor.getUser();
        if (principal == null) {
            throw new org.springframework.security.authentication
                    .AuthenticationCredentialsNotFoundException(
                    "No autenticado");
        }
        String email = principal.getName();

        boolean isAdmin = accessor.getUser() instanceof UsernamePasswordAuthenticationToken token
                && token.getAuthorities().stream()
                .anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN"));

        if (isAdmin) return;

        // JOIN FETCH para evitar LazyInitializationException fuera de sesión JPA
        Practica practica = practicaRepository.findByIdConParticipantes(practicaId)
                .orElseThrow(() -> new org.springframework.security.access
                        .AccessDeniedException("Práctica no encontrada"));

        boolean esParticipante = email.equals(practica.getAlumno().getEmail())
                || email.equals(practica.getTutorCentro().getEmail())
                || email.equals(practica.getTutorEmpresa().getEmail());

        if (!esParticipante) {
            throw new org.springframework.security.access
                    .AccessDeniedException(
                    "No tienes acceso al chat de la práctica " + practicaId);
        }
    }
}
