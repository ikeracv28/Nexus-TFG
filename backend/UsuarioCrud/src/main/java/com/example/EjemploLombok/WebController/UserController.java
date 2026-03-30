package com.example.EjemploLombok.WebController;


import com.example.EjemploLombok.DTO.LoginDTO;
import com.example.EjemploLombok.DTO.UsuarioSesionDTO;
import com.example.EjemploLombok.Modelo.Usuario;
import com.example.EjemploLombok.Service.UsuarioService;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.Optional;

@Controller
@RequestMapping("/user")
public class UserController {

    @Autowired
    UsuarioService usuarioService;




    @ResponseBody
    @GetMapping("/datos")
    public ResponseEntity<UsuarioSesionDTO> mostrarDatos(HttpSession session){

        UsuarioSesionDTO usuarioSesionDTO = (UsuarioSesionDTO) session.getAttribute("usuarioLogueado");
        if (usuarioSesionDTO == null){
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
            }
        try{
            Optional<Usuario> usuarioOptional = usuarioService.buscarUsuario(usuarioSesionDTO.getUsername());
            UsuarioSesionDTO usuarioAmostrar = new UsuarioSesionDTO(usuarioOptional.get().getIdUsuario(), usuarioOptional.get().getUsername(), usuarioOptional.get().getRoles().iterator().next().getNombre(), usuarioOptional.get().getFechaCreacion());

            return ResponseEntity.ok(usuarioAmostrar);

        }catch (Exception e){
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }


}
