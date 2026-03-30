package com.tfg.api.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Component;

import java.security.Key;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.function.Function;

/**
 * Clase de utilidad para la gestión de tokens JWT.
 * Se encarga de generar, validar y extraer información de los tokens.
 */
@Component
public class JwtUtils {

    /**
     * Clave secreta para firmar los tokens. 
     * En producción, este valor DEBE venir de una variable de entorno segura.
     */
    @Value("${jwt.secret:clave_secreta_muy_larga_y_segura_para_el_proyecto_nexus_tfg_2026}")
    private String secret;

    /**
     * Tiempo de validez del token (ej: 24 horas).
     */
    @Value("${jwt.expiration:86400000}")
    private Long expiration;

    /**
     * Genera un token JWT para un usuario específico.
     * 
     * @param userDetails Detalles del usuario autenticado por Spring Security.
     * @return String con el JWT generado.
     */
    public String generateToken(UserDetails userDetails) {
        Map<String, Object> claims = new HashMap<>();
        // Aquí podríamos añadir más información al payload (Claims adicionales)
        return createToken(claims, userDetails.getUsername());
    }

    /**
     * Crea la estructura del token JWT.
     * 
     * Jwts.builder(): Inicia la construcción del token.
     * setSubject: El "dueño" del token (normalmente el email).
     * setIssuedAt: Fecha de creación.
     * setExpiration: Fecha de caducidad.
     * signWith: Firma el token usando nuestra clave y el algoritmo HS256.
     */
    private String createToken(Map<String, Object> claims, String subject) {
        return Jwts.builder()
                .setClaims(claims)
                .setSubject(subject)
                .setIssuedAt(new Date(System.currentTimeMillis()))
                .setExpiration(new Date(System.currentTimeMillis() + expiration))
                .signWith(getSigningKey(), SignatureAlgorithm.HS256)
                .compact();
    }

    /**
     * Valida si un token es correcto para un usuario determinado.
     * Comprueba que el nombre de usuario coincida y que el token no haya expirado.
     */
    public Boolean validateToken(String token, UserDetails userDetails) {
        final String username = extractUsername(token);
        return (username.equals(userDetails.getUsername()) && !isTokenExpired(token));
    }

    /**
     * Extrae el nombre de usuario (email) del token.
     */
    public String extractUsername(String token) {
        return extractClaim(token, Claims::getSubject);
    }

    /**
     * Extrae la fecha de expiración del token.
     */
    public Date extractExpiration(String token) {
        return extractClaim(token, Claims::getExpiration);
    }

    /**
     * Método genérico para extraer cualquier dato (Claim) del token.
     */
    public <T> T extractClaim(String token, Function<Claims, T> claimsResolver) {
        final Claims claims = extractAllClaims(token);
        return claimsResolver.apply(claims);
    }

    /**
     * Lee todos los datos del token usando nuestra clave secreta.
     * Si el token ha sido manipulado, este método lanzará una excepción.
     */
    private Claims extractAllClaims(String token) {
        return Jwts.parserBuilder()
                .setSigningKey(getSigningKey())
                .build()
                .parseClaimsJws(token)
                .getBody();
    }

    /**
     * Verifica si el token ya no es válido por tiempo.
     */
    private Boolean isTokenExpired(String token) {
        return extractExpiration(token).before(new Date());
    }

    /**
     * Obtiene la clave de firma a partir del String secreto definido.
     */
    private Key getSigningKey() {
        byte[] keyBytes = secret.getBytes();
        return Keys.hmacShaKeyFor(keyBytes);
    }
}
