package com.tfg.api.models.mapper;

import com.tfg.api.models.dto.AuthResponse;
import com.tfg.api.models.dto.RegisterRequest;
import com.tfg.api.models.entity.Rol;
import com.tfg.api.models.entity.Usuario;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.Named;

import java.util.Set;
import java.util.stream.Collectors;

/**
 * Mapper para la conversión entre Usuario (Entidad JPA) y DTOs (Records).
 * Utiliza MapStruct para generar el código de mapeo de forma eficiente 
 * durante la compilación.
 * 
 * componentModel = "spring": Permite que Spring inyecte el Mapper 
 * como un Bean estándar (@Autowired).
 */
@Mapper(componentModel = "spring")
public interface UsuarioMapper {

    /**
     * Convierte los datos de registro en una Entidad de base de datos.
     * Ignoramos el ID (autogenerado) y la fechaCreación.
     */
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "passwordHash", source = "password") // Mapeamos password de DTO a passwordHash de Entity
    @Mapping(target = "centro", ignore = true) // El centro se asignará en el Service
    @Mapping(target = "roles", ignore = true)  // Los roles se asignarán en el Service
    @Mapping(target = "activo", constant = "true")
    @Mapping(target = "fechaCreacion", ignore = true)
    Usuario registerToEntity(RegisterRequest request);

    /**
     * Convierte un usuario de la BD en una respuesta de autenticación con el Token.
     * 
     * @param usuario Entidad JPA.
     * @param token JWT generado previamente.
     * @return DTO AuthResponse listo para el cliente Flutter.
     */
    @Mapping(target = "token", source = "token")
    @Mapping(target = "nombre", expression = "java(usuario.getNombre() + \" \" + usuario.getApellidos())")
    @Mapping(target = "roles", source = "usuario.roles", qualifiedByName = "mapRoles")
    AuthResponse toAuthResponse(Usuario usuario, String token);

    /**
     * Método auxiliar para extraer solo los nombres de los roles 
     * y devolver un Set<String> más ligero para el JSON.
     */
    @Named("mapRoles")
    default Set<String> mapRoles(Set<Rol> roles) {
        if (roles == null) return Set.of();
        return roles.stream()
                .map(Rol::getNombre)
                .collect(Collectors.toSet());
    }
}
