package com.tfg.api.services.impl;

import com.tfg.api.models.dto.RegisterRequest;
import com.tfg.api.models.entity.Rol;
import com.tfg.api.models.entity.Usuario;
import com.tfg.api.models.repository.RolRepository;
import com.tfg.api.models.repository.UsuarioRepository;
import com.tfg.api.services.AuthService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collections;

/**
 * Implementación de la lógica de autenticación (AuthServiceImpl).
 * Aquí se definen los detalles internos de cómo se registra o loguea un usuario.
 * 
 * Uso de @RequiredArgsConstructor: 
 * Es una anotación de Lombok que genera automáticamente un constructor 
 * para los campos finales (final). Spring detecta ese constructor e 
 * inyecta las dependencias automáticamente (Inyección de dependencias).
 */
@Service
@RequiredArgsConstructor
public class AuthServiceImpl implements AuthService {

    private final UsuarioRepository usuarioRepository;
    private final RolRepository rolRepository;
    private final PasswordEncoder passwordEncoder;

    /**
     * Registra un nuevo usuario en la base de datos.
     * 
     * @Transactional: Garantiza que si algo falla durante la creación del 
     * usuario, toda la operación se deshace (rollback), evitando dejar 
     * datos corruptos o a medias en la base de datos.
     */
    @Override
    @Transactional
    public Usuario registrar(RegisterRequest request) {

        // 1. Validar que no exista un usuario con ese email
        if (usuarioRepository.existsByEmail(request.email())) {
            throw new RuntimeException("El email ya está registrado");
        }

        // 2. Validar que no exista un usuario con ese DNI
        if (usuarioRepository.existsByDni(request.dni())) {
            throw new RuntimeException("El DNI ya está registrado");
        }

        // 3. Obtener el rol de ALUMNO por defecto 
        // Nota: En una fase real, el primer script Flyway debería haber 
        // insertado los roles básicos.
        Rol rolAlumno = rolRepository.findByNombre("ROLE_ALUMNO")
                .orElseThrow(() -> new RuntimeException("Error: Rol de Alumno no encontrado en el sistema"));

        // 4. Crear el objeto Usuario y mapear los datos del DTO
        // Ciframos la contraseña antes de guardar el objeto en la BD.
        Usuario nuevoUsuario = Usuario.builder()
                .dni(request.dni())
                .nombre(request.nombre())
                .apellidos(request.apellidos())
                .email(request.email())
                .passwordHash(passwordEncoder.encode(request.password()))
                .roles(Collections.singleton(rolAlumno))
                .activo(true)
                .build();

        // 5. Persistir el usuario en la base de datos
        return usuarioRepository.save(nuevoUsuario);
    }

    @Override
    public Usuario login(String email, String password) {
        // Buscamos al usuario por su email
        Usuario usuario = usuarioRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Credenciales inválidas"));

        // Comprobamos si la contraseña en texto plano enviada por el usuario 
        // coincide con el hash guardado en la base de datos.
        if (!passwordEncoder.matches(password, usuario.getPasswordHash())) {
            throw new RuntimeException("Credenciales inválidas");
        }

        // Si todo es correcto, devolvemos el objeto usuario (a falta de JWT)
        return usuario;
    }
}
