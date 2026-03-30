package com.example.EjemploLombok.WebController;

import com.example.EjemploLombok.DTO.LoginDTO;
import com.example.EjemploLombok.DTO.UsuarioSesionDTO;
import com.example.EjemploLombok.Modelo.Usuario;
import com.example.EjemploLombok.Repository.UsuarioRepository;
import com.example.EjemploLombok.Service.RolService;
import com.example.EjemploLombok.Service.UsuarioService;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

@Controller
public class LogingController {


    @Autowired
    UsuarioService usuarioService;

    @Autowired
    RolService rolService;
    @Autowired
    private UsuarioRepository usuarioRepository;
    @Autowired
    private PasswordEncoder passwordEncoder;


    @PostMapping("/login")
    @ResponseBody
    public ResponseEntity<UsuarioSesionDTO> inicioSesion(@RequestBody LoginDTO loginDTO, HttpSession session){
        Optional<Usuario> usuarioOptional = usuarioService.buscarUsuario(loginDTO.getUsername());
        if(usuarioOptional.isPresent()){
            if (passwordEncoder.matches(loginDTO.getPassword(), usuarioOptional.get().getPassword())){
                UsuarioSesionDTO infoUsuarioLogeado = new UsuarioSesionDTO(usuarioOptional.get().getIdUsuario(), usuarioOptional.get().getUsername(), usuarioOptional.get().getRoles().iterator().next().getNombre(), usuarioOptional.get().getFechaCreacion());

                session.setAttribute("usuarioLogueado", infoUsuarioLogeado);

                return ResponseEntity.ok(infoUsuarioLogeado);

            }
        }
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
    }

    @GetMapping("/killSession")
    public String matarSesion(HttpSession session){
        session.invalidate();

        return "redirect:/";
    }





}
