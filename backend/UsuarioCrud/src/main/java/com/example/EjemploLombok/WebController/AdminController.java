package com.example.EjemploLombok.WebController;


import com.example.EjemploLombok.DTO.UsuarioSesionDTO;
import com.example.EjemploLombok.Modelo.Rol;
import com.example.EjemploLombok.Modelo.Usuario;
import com.example.EjemploLombok.Service.RolService;
import com.example.EjemploLombok.Service.UsuarioService;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Controller
@RequestMapping("/admin")
public class AdminController {

    @Autowired
    UsuarioService usuarioService;

    @Autowired
    RolService rolService;




    @ResponseBody
    @GetMapping("/datosAdmin")
    public ResponseEntity<UsuarioSesionDTO> mostrarDatosAdmin(HttpSession session) {

        UsuarioSesionDTO usuarioSesionDTO = (UsuarioSesionDTO) session.getAttribute("usuarioLogueado");
        if (usuarioSesionDTO == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        try {
            Optional<Usuario> usuarioOptional = usuarioService.buscarUsuario(usuarioSesionDTO.getUsername());
            UsuarioSesionDTO usuarioAmostrar = new UsuarioSesionDTO(usuarioOptional.get().getIdUsuario(), usuarioOptional.get().getUsername(), usuarioOptional.get().getRoles().iterator().next().getNombre(), usuarioOptional.get().getFechaCreacion());

            return ResponseEntity.ok(usuarioAmostrar);

        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }


    @GetMapping()
    public String vaidarAdmin(HttpSession session)
    {
        UsuarioSesionDTO usarioLogeado = (UsuarioSesionDTO) session.getAttribute("usuarioLogueado");
        if (usarioLogeado == null){
            return "redirect:killSession";
        }
        if(!usarioLogeado.getNombreRol().equalsIgnoreCase("admin")){
            return "redirect:killSession";
        }
        return "Admin/ListaUsuariosAdmin";
    }

    @ResponseBody
    @GetMapping("/verUsuarios")
    public ArrayList<UsuarioSesionDTO> mostrarUsuarios() {
        ArrayList<Usuario> lista = new ArrayList<>();
        ArrayList<UsuarioSesionDTO> listaDTO = new ArrayList<>();

        try {
            lista = usuarioService.mostrarUsuariosService();
            for (Usuario usuario : lista) {

                listaDTO.add(new UsuarioSesionDTO(usuario.getIdUsuario(), usuario.getUsername(), usuario.getRoles().iterator().next().getNombre(), usuario.getFechaCreacion(), usuario.isActivo()));

            }

            if (lista.isEmpty()) throw new IllegalStateException("No hay usuarios disponibles");
            return listaDTO;

        } catch (Exception e) {
            System.out.println(e.getMessage());
            return listaDTO;
        }
    }

    @ResponseBody
    @PostMapping("/actualizarUsuario")
    public ResponseEntity<?> actualizarUsuarios(@RequestBody UsuarioSesionDTO usuarioSessionDTO, HttpSession session ) {
        UsuarioSesionDTO usuarioSession = (UsuarioSesionDTO) session.getAttribute("usuarioLogueado");

        if (usuarioSession == null || !"admin".equalsIgnoreCase(usuarioSession.getNombreRol())) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        try {
            Optional<Usuario> usuario = usuarioService.buscarUsuario(usuarioSessionDTO.getIdUsuario());

            usuario.get().setUsername(usuarioSessionDTO.getUsername());
            usuario.get().setActivo(usuarioSessionDTO.isEstado());


            String nombreRol = usuarioSessionDTO.getNombreRol();

            if (StringUtils.hasText(nombreRol)) {
                Optional<Rol> rol = rolService.obtenerPorNombre(nombreRol);

                if (rol.isPresent()) {
                    usuario.get().getRoles().clear();

                    usuario.get().getRoles().add(rol.get());
                } else
                    System.out.println("No se ha encontrado ningun rol");

            }

            Usuario usuarioActualizado = usuarioService.updateUsuario(usuario);

            return ResponseEntity.ok(usuarioActualizado);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }

    }

    @ResponseBody
    @DeleteMapping("/eliminarUsuario/{id}")
    public ResponseEntity<?> eliminarUsuario(@PathVariable int id, HttpSession session) {
        UsuarioSesionDTO usuarioSessionDTO = (UsuarioSesionDTO) session.getAttribute("usuarioLogueado");

        if (usuarioSessionDTO == null || !"admin".equalsIgnoreCase(usuarioSessionDTO.getNombreRol())) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }

        try {
            Optional<Usuario> usuario = usuarioService.buscarUsuario(id);

            if (usuario.isPresent()) {
                usuarioService.deleteUsuario(usuario.get());
                // Devolvemos 200 OK para que el frontend sepa que terminó bien
                return ResponseEntity.ok().build();
            } else {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Usuario no encontrado");
            }
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

}