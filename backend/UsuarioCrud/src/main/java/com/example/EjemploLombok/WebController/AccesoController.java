package com.example.EjemploLombok.WebController;


import com.example.EjemploLombok.DTO.UsuarioSesionDTO;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/control")
public class AccesoController {

    @Autowired
    LogingController logingController;

    @GetMapping()
    public String kroos(HttpSession session) {
        UsuarioSesionDTO usuarioSesionDTO = (UsuarioSesionDTO) session.getAttribute("usuarioLogueado");

        if (usuarioSesionDTO != null) {
            if (usuarioSesionDTO.getNombreRol().equalsIgnoreCase("admin")) {
                return "Admin/AdminController";
            } else if (usuarioSesionDTO.getNombreRol().equalsIgnoreCase("user")) {
                return "User/UserController";
            } else {
                return "redirect:/index.html";

            }
        }
        return "redirect:/killSession";
    }



}
