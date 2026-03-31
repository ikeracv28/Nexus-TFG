package com.tfg.api.models.repository;

import com.tfg.api.models.entity.Seguimiento;
import com.tfg.api.models.entity.Practica;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

/**
 * Repositorio para la gestión de los diarios de seguimiento de los alumnos.
 */
@Repository
public interface SeguimientoRepository extends JpaRepository<Seguimiento, Long> {

    /**
     * Recupera todos los registros de seguimiento (diarios) asociados a una práctica concreta.
     * @param practica Entidad de la práctica.
     * @return Lista de seguimientos ordenada cronológicamente por defecto.
     */
    List<Seguimiento> findByPracticaOrderByFechaRegistroDesc(Practica practica);

    /**
     * Filtra los seguimientos de una práctica por su estado (PENDIENTE, VALIDADO).
     */
    List<Seguimiento> findByPracticaAndEstado(Practica practica, String estado);

    /**
     * Lista todos los seguimientos que están pendientes de validar en todo el sistema.
     * Útil para notificaciones de tutores.
     */
    List<Seguimiento> findByEstado(String estado);
}
