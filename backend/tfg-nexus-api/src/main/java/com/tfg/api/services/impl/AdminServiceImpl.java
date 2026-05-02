package com.tfg.api.services.impl;

import com.tfg.api.exceptions.BusinessRuleException;
import com.tfg.api.exceptions.ResourceNotFoundException;
import com.tfg.api.models.dto.CreateUsuarioRequest;
import com.tfg.api.models.dto.UpdateUsuarioRequest;
import com.tfg.api.models.dto.UsuarioResponse;
import com.tfg.api.models.entity.Rol;
import com.tfg.api.models.entity.Usuario;
import com.tfg.api.models.mapper.UsuarioMapper;
import com.tfg.api.models.repository.RolRepository;
import com.tfg.api.models.repository.UsuarioRepository;
import com.tfg.api.services.AdminService;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AdminServiceImpl implements AdminService {

    private static final Logger log = LoggerFactory.getLogger(AdminServiceImpl.class);

    private static final Set<String> ROLES_PERMITIDOS = Set.of(
            "ROLE_ALUMNO", "ROLE_TUTOR_CENTRO", "ROLE_TUTOR_EMPRESA", "ROLE_ADMIN"
    );

    private final UsuarioRepository usuarioRepository;
    private final RolRepository rolRepository;
    private final PasswordEncoder passwordEncoder;
    private final UsuarioMapper usuarioMapper;

    @Override
    @Transactional
    public UsuarioResponse crearUsuario(CreateUsuarioRequest request) {
        if (!ROLES_PERMITIDOS.contains(request.rolNombre())) {
            throw new BusinessRuleException(
                    "Rol no válido. Los roles permitidos son: " + String.join(", ", ROLES_PERMITIDOS));
        }
        if (usuarioRepository.existsByEmail(request.email()) || usuarioRepository.existsByDni(request.dni())) {
            throw new BusinessRuleException("El email o DNI ya están registrados en el sistema.");
        }

        Rol rol = rolRepository.findByNombre(request.rolNombre())
                .orElseThrow(() -> new BusinessRuleException("Rol no encontrado en el sistema: " + request.rolNombre()));

        Usuario usuario = Usuario.builder()
                .dni(request.dni())
                .nombre(request.nombre())
                .apellidos(request.apellidos())
                .email(request.email())
                .passwordHash(passwordEncoder.encode(request.password()))
                .roles(Set.of(rol))
                .activo(true)
                .build();

        Usuario guardado = usuarioRepository.save(usuario);
        log.info("ADMIN_CREAR_USUARIO id={} rol={}", guardado.getId(), request.rolNombre());
        return usuarioMapper.toResponse(guardado);
    }

    @Override
    @Transactional(readOnly = true)
    public List<UsuarioResponse> listarUsuarios() {
        return usuarioRepository.findAllByOrderByFechaCreacionDesc()
                .stream()
                .map(usuarioMapper::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public UsuarioResponse toggleActivo(Long id) {
        Usuario usuario = usuarioRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Usuario no encontrado"));
        usuario.setActivo(!usuario.getActivo());
        log.info("ADMIN_TOGGLE_ACTIVO id={} activo={}", id, usuario.getActivo());
        return usuarioMapper.toResponse(usuarioRepository.save(usuario));
    }

    @Override
    @Transactional
    public UsuarioResponse editarUsuario(Long id, UpdateUsuarioRequest request) {
        if (!ROLES_PERMITIDOS.contains(request.rolNombre())) {
            throw new BusinessRuleException(
                    "Rol no válido. Los roles permitidos son: " + String.join(", ", ROLES_PERMITIDOS));
        }
        Usuario usuario = usuarioRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Usuario no encontrado"));

        if (!usuario.getEmail().equals(request.email()) && usuarioRepository.existsByEmail(request.email())) {
            throw new BusinessRuleException("El email ya está en uso por otro usuario.");
        }
        if (!usuario.getDni().equals(request.dni()) && usuarioRepository.existsByDni(request.dni())) {
            throw new BusinessRuleException("El DNI ya está en uso por otro usuario.");
        }

        Rol nuevoRol = rolRepository.findByNombre(request.rolNombre())
                .orElseThrow(() -> new BusinessRuleException("Rol no encontrado en el sistema: " + request.rolNombre()));

        usuario.setDni(request.dni());
        usuario.setNombre(request.nombre());
        usuario.setApellidos(request.apellidos());
        usuario.setEmail(request.email());
        usuario.setRoles(Set.of(nuevoRol));

        log.info("ADMIN_EDITAR_USUARIO id={} rol={}", id, request.rolNombre());
        return usuarioMapper.toResponse(usuarioRepository.save(usuario));
    }
}
