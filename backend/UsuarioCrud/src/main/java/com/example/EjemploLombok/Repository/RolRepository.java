package com.example.EjemploLombok.Repository;

import com.example.EjemploLombok.Modelo.Rol;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface RolRepository extends JpaRepository<Rol, Integer> {

    Optional<Rol> findByNombre(String nombreRol);
}
