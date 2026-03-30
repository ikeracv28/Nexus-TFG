package com.tfg.api.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

/**
 * Clase de configuración para la seguridad del backend.
 * Aquí definiremos los beans necesarios para el cifrado y la autorización.
 */
@Configuration
public class SecurityConfig {

    /**
     * Define el bean para el cifrado de contraseñas.
     * 
     * BCrypt es un algoritmo de hashing fuerte que incluye un 'salt' aleatorio 
     * automáticamente. Esto significa que si dos usuarios tienen la misma 
     * contraseña, sus hashes en la base de datos serán diferentes, lo que 
     * protege contra ataques de tablas arcoíris (rainbow tables).
     * 
     * @return Una instancia de BCryptPasswordEncoder.
     */
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
