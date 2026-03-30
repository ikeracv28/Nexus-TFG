package com.example.EjemploLombok.Service;

import com.example.EjemploLombok.Modelo.Rol;
import com.example.EjemploLombok.Repository.RolRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
public class RolService {

    @Autowired
    RolRepository rolRepository;

    public List<Rol> obtenerRoles(){
        return rolRepository.findAll();
    }

    public Optional<Rol> obtenerPorNombre(String nombreRol){
        return rolRepository.findByNombre(nombreRol);

    }

}
