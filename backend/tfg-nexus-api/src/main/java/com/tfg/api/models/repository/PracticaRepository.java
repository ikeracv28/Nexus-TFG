package com.tfg.api.models.repository;

import com.tfg.api.models.entity.Practica;
import com.tfg.api.models.entity.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

/**
 * Repositorio para la gestión de convenios de prácticas académica (FCT).
 */
@Repository
public interface PracticaRepository extends JpaRepository<Practica, Long> {

    /**
     * Busca una práctica por su código único de expediente.
     */
    Optional<Practica> findByCodigo(String codigo);

    /**
     * Lista todas las prácticas asignadas a un alumno específico.
     */
    List<Practica> findByAlumno(Usuario alumno);

    /**
     * Lista todas las prácticas supervisadas por un tutor de centro determinado.
     */
    List<Practica> findByTutorCentro(Usuario tutorCentro);

    /**
     * Lista todas las prácticas que pertenecen a una empresa específica.
     */
    List<Practica> findByEmpresaId(Long empresaId);

    /**
     * Filtra prácticas por su estado actual (ACTIVA, FINALIZADA, etc.).
     */
    List<Practica> findByEstado(String estado);
}
