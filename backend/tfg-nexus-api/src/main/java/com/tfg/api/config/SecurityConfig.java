package com.tfg.api.config;

import com.tfg.api.security.JwtAuthenticationFilter;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

/**
 * Configuración maestra de seguridad para Nexus-TFG.
 * Aquí se coordinan el cifrado, la gestión de usuarios y el filtro JWT.
 */
@Configuration
@EnableWebSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final JwtAuthenticationFilter jwtAuthFilter;
    private final UserDetailsService userDetailsService;

    /**
     * Definición de la cadena de filtros de seguridad.
     * Es el corazón de la protección de la API.
     */
    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            // 1. Deshabilitamos CSRF (Cross-Site Request Forgery). 
            // Como usamos JWT y no sesiones de navegador (cookies), no es necesario.
            .csrf(AbstractHttpConfigurer::disable)
            
            // 2. Configuración de rutas (Endpoints)
            .authorizeHttpRequests(auth -> auth
                // Rutas públicas: Registro y Login deben ser accesibles para todos.
                .requestMatchers("/api/v1/auth/**").permitAll()
                // El resto de rutas requieren estar autenticado.
                .anyRequest().authenticated()
            )
            
            // 3. Gestión de sesiones: Indicamos que la API es STATELESS (Sin estado).
            // No se crearán sesiones en el servidor.
            .sessionManagement(session -> session
                .sessionCreationPolicy(SessionCreationPolicy.STATELESS)
            )
            
            // 4. Registramos nuestro proveedor de autenticación personalizado.
            .authenticationProvider(authenticationProvider())
            
            // 5. Añadimos el filtro JWT antes del filtro de usuario/contraseña estándar.
            .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    /**
     * Proveedor de autenticación que conecta el servicio de usuarios con el codificador de contraseñas.
     */
    @Bean
    public AuthenticationProvider authenticationProvider() {
        DaoAuthenticationProvider authProvider = new DaoAuthenticationProvider();
        authProvider.setUserDetailsService(userDetailsService);
        authProvider.setPasswordEncoder(passwordEncoder());
        return authProvider;
    }

    /**
     * Gestor de autenticación: Necesario para que el controlador de login 
     * pueda validar las credenciales de forma oficial.
     */
    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration config) throws Exception {
        return config.getAuthenticationManager();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
