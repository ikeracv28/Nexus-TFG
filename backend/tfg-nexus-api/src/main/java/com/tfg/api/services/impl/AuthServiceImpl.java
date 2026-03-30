package com.tfg.api.services.impl;

import com.tfg.api.models.dto.AuthResponse;
import com.tfg.api.models.dto.LoginRequest;
import com.tfg.api.models.dto.RegisterRequest;
import com.tfg.api.models.entity.Rol;
import com.tfg.api.models.entity.Usuario;
import com.tfg.api.models.repository.RolRepository;
import com.tfg.api.models.repository.UsuarioRepository;
import com.tfg.api.security.JwtUtils;
import com.tfg.api.security.UserDetailsServiceImpl;
import com.tfg.api.services.AuthService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collections;
import java.util.stream.Collectors;

/**
 * Implementación de la lógica de autenticación real para Nexus-TFG.
 */
@Service
@RequiredArgsConstructor
public class AuthServiceImpl implements AuthService {

    private final UsuarioRepository usuarioRepository;
    private final RolRepository rolRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtils jwtUtils;
    private final AuthenticationManager authenticationManager;
    private final UserDetailsServiceImpl userDetailsService;

    /**
     * Registra al usuario y devuelve automáticamente el Token para el Login inmediato.
     */
    @Override
    @Transactional
    public AuthResponse registrar(RegisterRequest request) {

        // Validaciones (DNI y Email únicos)
        if (usuarioRepository.existsByEmail(request.email())) {
            throw new RuntimeException("El email ya está registrado");
        }
        if (usuarioRepository.existsByDni(request.dni())) {
            throw new RuntimeException("El DNI ya está registrado");
        }

        // Asignación de rol base (Alumno)
        Rol rolAlumno = rolRepository.findByNombre("ROLE_ALUMNO")
                .orElseThrow(() -> new RuntimeException("Error: Rol de Alumno no encontrado"));

        // Creación y persistencia
        Usuario usuario = Usuario.builder()
                .dni(request.dni())
                .nombre(request.nombre())
                .apellidos(request.apellidos())
                .email(request.email())
                .passwordHash(passwordEncoder.encode(request.password()))
                .roles(Collections.singleton(rolAlumno))
                .activo(true)
                .build();

        usuarioRepository.save(usuario);

        // Generamos el token de forma manual para devolverlo tras el registro
        return generarAuthResponse(usuario);
    }

    /**
     * Proceso de Login oficial:
     * 1. Usa AuthenticationManager para validar las credenciales.
     * 2. Si es válido, genera el Token JWT y lo devuelve junto con info del usuario.
     */
    @Override
    public AuthResponse login(LoginRequest request) {
        
        // El AuthenticationManager usará internamente nuestro UserDetailsService
        // y comparará contraseñas con el PasswordEncoder que configuramos.
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.email(), request.password())
        );

        // Si la autenticación falla, Spring lanzará una excepción y no llegará a este punto.
        Usuario usuario = usuarioRepository.findByEmail(request.email())
                .orElseThrow();

        return generarAuthResponse(usuario);
    }

    /**
     * Método privado de utilidad para construir la respuesta común tras login/registro.
     */
    private AuthResponse generarAuthResponse(Usuario usuario) {
        // Obtenemos el UserDetails para dárselo a JwtUtils
        UserDetails userDetails = userDetailsService.loadUserByUsername(usuario.getEmail());
        
        // Generamos el token real
        String token = jwtUtils.generateToken(userDetails);

        // Mapeamos los roles a una lista de Strings simple para el frontend
        var roles = usuario.getRoles().stream()
                .map(Rol::getNombre)
                .collect(Collectors.toSet());

        return new AuthResponse(
                token,
                usuario.getEmail(),
                usuario.getNombre(),
                roles
        );
    }
}
