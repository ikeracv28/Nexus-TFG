package com.example.EjemploLombok.Service;

import com.example.EjemploLombok.Modelo.Usuario;
import com.example.EjemploLombok.Repository.UsuarioRepository;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.ArrayList;
import java.util.Optional;

@Service
public class UsuarioService {

    @Autowired
    UsuarioRepository usuarioRepository;

    @Autowired
    PasswordEncoder passwordEncoder; // Necesario para hashear la contraseña

    public Usuario crearUsuario(Usuario usuario){
        if (usuario == null) throw new IllegalArgumentException("El usuario viene vacio al service");

        if (usuarioRepository.existsByUsername(usuario.getUsername())) throw new IllegalStateException("El usuario ya existe");

        usuario.setPassword(passwordEncoder.encode(usuario.getPassword()));

        return usuarioRepository.save(usuario);

    }

    public boolean comprobarUsername(String username){
        if(!StringUtils.hasText(username))throw new IllegalArgumentException("El username no puede estar vacio");

        return usuarioRepository.existsByUsername(username);
    }

    public boolean comprobarInicioSesion(Usuario usuarioraw){
        if (usuarioraw == null) throw new IllegalArgumentException("El usuario viene vacio al service");
        Optional <Usuario> usuariobd = usuarioRepository.findUsuarioByUsername(usuarioraw.getUsername());
        if(usuariobd.isEmpty()) throw new IllegalStateException("El usuario no existe");

        //Verifica que la contraseña que mete el usuario compara una contraseña sin hashear con una hasheada.
        if(!passwordEncoder.matches(usuarioraw.getPassword(),usuariobd.get().getPassword())) throw new IllegalStateException("Las contraseñas no coinciden");
        return true;
    }

    public ArrayList<Usuario> mostrarUsuariosService(){
        return usuarioRepository.findAllBy();
    }

    public Optional<Usuario> buscarUsuario(String username){
        if (username == null) throw new IllegalArgumentException("El nombre introducido no existe");
        if (!comprobarUsername(username)) throw new IllegalStateException("El usuario no existe");
        Optional<Usuario> usuarioBuscado = usuarioRepository.findUsuarioByUsername(username);
        if(usuarioBuscado.isEmpty()) throw new IllegalStateException("El usuario es nulo");
        return usuarioBuscado;
    }

    public Optional<Usuario> buscarUsuario(int id){
        Optional<Usuario> usuarioBuscado = usuarioRepository.findUsuarioByIdUsuario(id);
        if(usuarioBuscado.isEmpty()) throw new IllegalStateException("El usuario es nulo");
        return usuarioBuscado;
    }




    @Transactional
    public Usuario updateUsuario(Optional<Usuario> usuario){
        if (usuario == null) throw new IllegalStateException("El usuario actualizado esta vacio");
        Optional <Usuario> usuariodb = usuarioRepository.findById(usuario.get().getIdUsuario());
        if (usuariodb.isEmpty()) throw new IllegalArgumentException("El usuario está vacio");
        if (!usuario.get().getPassword().equals(usuariodb.get().getPassword())){
            usuario.get().setPassword(passwordEncoder.encode(usuario.get().getPassword()));
        }

       return usuarioRepository.save(usuario.get());

    }

    @Transactional
    public Usuario updateEstado(Usuario usuario){
        if (usuario == null) throw new IllegalStateException("El usuario actualizado esta vacio");

        return usuarioRepository.save(usuario);

    }

    @Transactional
    public void deleteUsuario(Usuario usuario){
        usuarioRepository.delete(usuario);
    }

}
