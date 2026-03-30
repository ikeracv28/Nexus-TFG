package com.example.EjemploLombok.Repository;

import com.example.EjemploLombok.Modelo.Usuario;
import jakarta.transaction.Transactional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.lang.reflect.Array;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public interface UsuarioRepository extends JpaRepository<Usuario, Integer> {
    boolean existsByUsername(String username);

    ArrayList<Usuario> findAllBy();

    Optional<Usuario> findUsuarioByUsername(String username);


    Optional<Usuario> findUsuarioByIdUsuario(int idUsuario);

}
