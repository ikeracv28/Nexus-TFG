package com.tfg.api.services.impl;

import com.tfg.api.models.dto.AuthResponse;
import com.tfg.api.models.dto.LoginRequest;
import com.tfg.api.models.dto.RegisterRequest;
import com.tfg.api.models.entity.Rol;
import com.tfg.api.models.entity.Usuario;
import com.tfg.api.models.mapper.UsuarioMapper;
import com.tfg.api.models.repository.RolRepository;
import com.tfg.api.models.repository.UsuarioRepository;
import com.tfg.api.security.JwtUtils;
import com.tfg.api.services.AuthService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collections;

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
    private final UsuarioMapper usuarioMapper;

    /**
     * Registra al usuario y devuelve automáticamente el Token para el Login inmediato.
     */
    @Override
    @Transactional
    public AuthResponse registrar(RegisterRequest request) {

        // Validaciones de integridad (DNI y Email únicos)
        validarUnicidad(request);

        // Uso del Mapper para convertir DTO a Entidad (Mapeo automático de campos simples)
        Usuario usuario = usuarioMapper.registerToEntity(request);
        
        // Encriptación de contraseña (Lógica de seguridad)
        usuario.setPasswordHash(passwordEncoder.encode(request.password()));

        // Asignación de rol base (Alumno por defecto en registro abierto)
        Rol rolAlumno = rolRepository.findByNombre("ROLE_ALUMNO")
                .orElseThrow(() -> new RuntimeException("Error: El rol de Alumno no está configurado en la base de datos"));
        
        usuario.setRoles(Collections.singleton(rolAlumno));
        usuario.setActivo(true);

        // Persistencia en PostgreSQL
        Usuario usuarioGuardado = usuarioRepository.save(usuario);

        // Generamos el token JWT y mapeamos a la respuesta final
        String token = jwtUtils.generateToken(usuarioGuardado);
        return usuarioMapper.toAuthResponse(usuarioGuardado, token);
    }

    /**
     * Proceso de Login oficial:
     * 1. Usa AuthenticationManager para validar las credenciales contra la BD.
     * 2. Si es válido, genera el Token JWT y lo devuelve al cliente.
     */
    @Override
    public AuthResponse login(LoginRequest request) {
        
        // Validación de credenciales delegada en Spring Security
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.email(), request.password())
        );

        // Si llegamos aquí, el usuario es válido
        Usuario usuario = usuarioRepository.findByEmail(request.email())
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado tras autenticación exitosa"));

        // Generamos el token JWT para esta sesión
        String token = jwtUtils.generateToken(usuario);
        
        // Convertimos a DTO de respuesta usando el Mapper centralizado
        return usuarioMapper.toAuthResponse(usuario, token);
    }

    /**
     * Verifica que no existan duplicados de identificación en el sistema.
     */
    private void validarUnicidad(RegisterRequest request) {
        if (usuarioRepository.existsByEmail(request.email())) {
            throw new RuntimeException("El correo electrónico ya se encuentra registrado");
        }
        if (usuarioRepository.existsByDni(request.dni())) {
            throw new RuntimeException("El DNI introducido ya existe en el sistema");
        }
    }
}
