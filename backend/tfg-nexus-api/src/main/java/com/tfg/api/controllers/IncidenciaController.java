package com.tfg.api.controllers;

import com.tfg.api.exceptions.ResourceNotFoundException;
import com.tfg.api.models.dto.IncidenciaResponse;
import com.tfg.api.models.repository.IncidenciaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Controlador REST para la consulta de incidencias.
 * En el Hito 3 se ampliará con creación, actualización y flujo de resolución.
 */
@RestController
@RequestMapping("/api/v1/incidencias")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class IncidenciaController {

    private final IncidenciaRepository incidenciaRepository;

    /**
     * Lista las incidencias de una práctica, ordenadas de más reciente a más antigua.
     * Acceso: Todos los roles participantes en la práctica.
     */
    @GetMapping("/practica/{practicaId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'TUTOR_CENTRO', 'TUTOR_EMPRESA', 'ALUMNO')")
    public ResponseEntity<List<IncidenciaResponse>> listarPorPractica(@PathVariable Long practicaId) {
        var incidencias = incidenciaRepository
                .findByPracticaIdOrderByFechaCreacionDesc(practicaId)
                .stream()
                .map(i -> new IncidenciaResponse(
                        i.getId(),
                        i.getPractica().getId(),
                        i.getCreadaPor().getId(),
                        i.getCreadaPor().getNombre() + " " + i.getCreadaPor().getApellidos(),
                        i.getTipo(),
                        i.getDescripcion(),
                        i.getEstado(),
                        i.getFechaCreacion()
                ))
                .toList();

        return ResponseEntity.ok(incidencias);
    }

    /**
     * Obtiene el detalle de una incidencia concreta.
     * Acceso: Cualquier usuario autenticado con acceso a la práctica.
     */
    @GetMapping("/{id}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<IncidenciaResponse> obtenerPorId(@PathVariable Long id) {
        var i = incidenciaRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Incidencia no encontrada"));

        return ResponseEntity.ok(new IncidenciaResponse(
                i.getId(),
                i.getPractica().getId(),
                i.getCreadaPor().getId(),
                i.getCreadaPor().getNombre() + " " + i.getCreadaPor().getApellidos(),
                i.getTipo(),
                i.getDescripcion(),
                i.getEstado(),
                i.getFechaCreacion()
        ));
    }
}
