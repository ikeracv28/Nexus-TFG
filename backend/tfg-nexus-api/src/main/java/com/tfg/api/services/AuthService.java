package com.tfg.api.services;

import com.tfg.api.models.dto.RegisterRequest;
import com.tfg.api.models.entity.Usuario;

/**
 * Interfaz de servicio para la gestión de autenticación en Nexus-TFG.
 * Aquí definimos el "qué" hace el sistema de autenticación.
 */
public interface AuthService {

    /**
     * Registra un nuevo usuario en la plataforma.
     * 
     * @param request Datos del nuevo usuario (DTO).
     * @return El usuario recién creado ya persistido en la base de datos.
     */
    Usuario registrar(RegisterRequest request);

    /**
     * Realiza el proceso de login. 
     * Nota: En el futuro esto devolverá un token JWT.
     * 
     * @param email Email del usuario.
     * @param password Contraseña en texto plano para verificar.
     * @return Usuario autenticado si las credenciales son válidas.
     */
    Usuario login(String email, String password);
}
