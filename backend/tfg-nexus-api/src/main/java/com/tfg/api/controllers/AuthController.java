package com.tfg.api.controllers;

import com.tfg.api.models.dto.RegisterRequest;
import com.tfg.api.models.entity.Usuario;
import com.tfg.api.services.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * Controlador para la gestión de autenticación y registro.
 * Expone los endpoints bajo la ruta base /api/v1/auth.
 * 
 * @RestController: Combina @Controller y @ResponseBody. Indica que los 
 * métodos devuelven datos (JSON) en lugar de vistas HTML.
 * @RequestMapping: Define el prefijo de la URL para todos los métodos.
 * @CrossOrigin: Permite peticiones desde otros dominios (necesario para Flutter Web).
 */
@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
@CrossOrigin(origins = "*") 
public class AuthController {

    private final AuthService authService;

    /**
     * Endpoint para el registro de nuevos usuarios.
     * 
     * @PostMapping: Indica que este método responde a peticiones HTTP POST.
     * @Valid: Activa las validaciones que pusimos en el Record RegisterRequest 
     * (como @Email o @NotBlank). Si fallan, Spring devolverá un error 400.
     * @RequestBody: Indica que el JSON del cuerpo de la petición debe mapearse al DTO.
     * 
     * @return ResponseEntity con el usuario creado y código 201 (CREATED).
     */
    @PostMapping("/register")
    public ResponseEntity<Usuario> registrar(@Valid @RequestBody RegisterRequest request) {
        // Llamamos al servicio para ejecutar la lógica de negocio.
        Usuario usuarioCreado = authService.registrar(request);
        
        // Devolvemos el objeto creado con el código de estado HTTP 201.
        return new ResponseEntity<>(usuarioCreado, HttpStatus.CREATED);
    }

    /**
     * Endpoint temporal para probar el login sin JWT.
     * 
     * @param email Correo del usuario.
     * @param password Contraseña en texto plano.
     * @return Usuario si las credenciales son válidas, o error si fallan.
     */
    @PostMapping("/login-test")
    public ResponseEntity<?> loginTest(@RequestParam String email, @RequestParam String password) {
        try {
            Usuario usuario = authService.login(email, password);
            return ResponseEntity.ok(usuario);
        } catch (RuntimeException e) {
            // Si el servicio lanza una excepción (ej: credenciales inválidas), 
            // devolvemos un código 401 (UNAUTHORIZED) con el mensaje de error.
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(e.getMessage());
        }
    }
}
