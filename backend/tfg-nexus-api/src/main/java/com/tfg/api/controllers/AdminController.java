package com.tfg.api.controllers;

import com.tfg.api.models.dto.CreateUsuarioRequest;
import com.tfg.api.models.dto.UsuarioResponse;
import com.tfg.api.services.AdminService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/admin")
@RequiredArgsConstructor
public class AdminController {

    private final AdminService adminService;

    @GetMapping("/usuarios")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<UsuarioResponse>> listarUsuarios() {
        return ResponseEntity.ok(adminService.listarUsuarios());
    }

    @PostMapping("/usuarios")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<UsuarioResponse> crearUsuario(@Valid @RequestBody CreateUsuarioRequest request) {
        return new ResponseEntity<>(adminService.crearUsuario(request), HttpStatus.CREATED);
    }

    @PatchMapping("/usuarios/{id}/toggle-activo")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<UsuarioResponse> toggleActivo(@PathVariable Long id) {
        return ResponseEntity.ok(adminService.toggleActivo(id));
    }
}
