//package com.example.EjemploLombok.Controller;
//
//import com.example.EjemploLombok.Modelo.Usuario;
//import com.example.EjemploLombok.Repository.UsuarioRepository;
//import com.example.EjemploLombok.Service.UsuarioService;
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.boot.CommandLineRunner;
//import org.springframework.stereotype.Component;
//
//import javax.swing.text.html.Option;
//import java.util.ArrayList;
//import java.util.Optional;
//import java.util.Scanner;
//@Component
//public class UsuarioController implements CommandLineRunner {
//    public static Scanner scanner = new Scanner(System.in);
//
//    @Autowired
//    UsuarioService usuarioService;
//
//    @Autowired
//    UsuarioRepository usuarioRepository;
//
//    @Override
//    public void run(String... args) throws Exception {
//        if (iniciarSesion()) {
//            System.out.println("Sesion Iniciada");
//
//            while (true) {
//
//                System.out.println("\n--- MENU USUARIO ---");
//                System.out.println("1. Test de conexión");
//                System.out.println("2. Crear usuario");
//                System.out.println("3. Listar usuarios ");
//                System.out.println("4. Buscar por username");
//                System.out.println("5. Actualizar Usuario");
//                System.out.println("6. Desactivar usuario (borrado lógico)");
//                System.out.println("7. Eliminar usuario (borrado físico)");
//                System.out.println("0. Salir");
//                System.out.print("Elige una opción: ");
//
//                String opcion = scanner.nextLine();
//
//                switch (opcion) {
//                    case "1":
//                        System.out.println("La conexion está funcionando perfectamente");
//                        break;
//                    case "2":
//                        darDeAltaUsuario();
//                        break;
//                    case "3":
//                        mostrarUsuarios();
//                        break;
//                    case "4":
//                        mostrarUsuarioPorUser();
//                        break;
//                    case "5":
//                        actualizarUsuario();
//                        break;
//                    case "6":
//                        desactivarEstadoUsuario();
//                        break;
//                    case "7":
//                        eliminarUsuario();
//                        break;
//                    case "0":
//                        System.out.println("Se ha cerrado la aplicacion.");
//                        System.exit(0);
//                    default:
//                        System.out.println("Opción no válida.");
//                }
//            }
//        }
//    }
//
//    public boolean iniciarSesion() {
//        boolean logeado = false;
//        while (!logeado) {
//            System.out.println("Dime un username");
//            String username = scanner.nextLine();
//            try {
//                if (!usuarioService.comprobarUsername(username)) throw new IllegalStateException("El usuario no existe");
//                System.out.println("Dime la contraseña");
//                String password = scanner.nextLine();
//                if(usuarioService.comprobarInicioSesion(new Usuario(username,password))){
//                    logeado = true;
//                }
//            } catch (IllegalArgumentException | IllegalStateException e) {
//                System.out.println(e.getMessage());
//
//            }
//        }
//        return logeado;
//    }
//
//
//        public void darDeAltaUsuario() {
//            try {
//
//                System.out.println("Dime el username");
//                String username = scanner.nextLine();
//                if (usuarioService.comprobarUsername(username)) throw new IllegalStateException("El usuario ya existe");
//
//                System.out.println("Dime tu contraseña");
//                String password = scanner.nextLine();
//
//                Usuario usuario = new Usuario(username, password);
//                Usuario usuariocreado = usuarioService.crearUsuario(usuario);
//
//                if (usuariocreado == null) throw new IllegalStateException("El usuario no se ha creado correctamente");
//                System.out.println("El usuario se ha creado correctamente con el id " + usuariocreado.getIdUsuario());
//
//            } catch (IllegalStateException | IllegalArgumentException e) {
//                System.out.println(e.getMessage());
//            }
//        }
//
//        public void mostrarUsuarios(){
//
//        try{
//            ArrayList<Usuario> lista = usuarioService.mostrarUsuariosService();
//            if(lista.isEmpty()) throw new IllegalStateException("No hay usuarios disponibles");
//            System.out.println("--- Lista de Usuarios ---");
//            for(Usuario u : lista){
//                System.out.println("ID: " + u.getIdUsuario() + " USERNAME: " + u.getUsername() + " ACTIVO?: " + (u.isActivo()?"ACTIVO" : "INACTIVO"));
//            }
//
//        }catch (IllegalArgumentException | IllegalStateException e){
//            System.out.println(e.getMessage());
//        }
//        }
//
//        public void mostrarUsuarioPorUser(){
//        try{
//            System.out.println("Introduce el username a buscar: ");
//            String username = scanner.nextLine();
//
//            Optional<Usuario> buscarusuario = usuarioService.buscarUsuario(username);
//
//            System.out.println("ID: " + buscarusuario.get().getIdUsuario() + " USERNAME: " + buscarusuario.get().getUsername() + " ACTIVO?: " + (buscarusuario.get().isActivo()?"ACTIVO" : "INACTIVO"));
//
//        }catch (IllegalArgumentException | IllegalStateException e){
//            System.out.println(e.getMessage());
//        }
//        }
//
//        public void actualizarUsuario(){
//        try{
//
//            System.out.println("Introduce el username de quien quieres actualizar");
//            String julian = scanner.nextLine();
//
//            Optional <Usuario> usuario = usuarioService.buscarUsuario(julian);
//            //Usuario usuario1 = usuario.get(); // Aqui pasariamos un Optional a un usuario normal
//
//            System.out.println("--- Datos encontrados ---");
//            System.out.println("ID: " + usuario.get().getIdUsuario() + " USERNAME: " + usuario.get().getUsername() + " ACTIVO?: " + (usuario.get().isActivo()?"ACTIVO" : "INACTIVO"));
//            System.out.println("¿Que quieres actualizar? username / contraseña");
//            String opcion = scanner.nextLine().toLowerCase().trim();
//            switch (opcion){
//                case "username":
//                    System.out.println("Introduce el nuevo username");
//                    String nuevoUsername = scanner.nextLine();
//                    usuario.get().setUsername(nuevoUsername);
//                    break;
//                case "contraseña":
//                    System.out.println("Introduce la nueva contraseña");
//                    String nuevaContraseña = scanner.nextLine();
//                    usuario.get().setPassword(nuevaContraseña);
//                    break;
//                default:
//                    System.out.println("Seleccione una opcion valida");
//            }
//            Usuario usuarioActualizado = usuarioService.updateUsuario(usuario.get());
//
//            System.out.println("El usuario se ha actualizado correctamente");
//            System.out.println("ID: " + usuarioActualizado.getIdUsuario() + " USERNAME: " + usuarioActualizado.getUsername() + " ACTIVO?: " + (usuarioActualizado.isActivo()?"ACTIVO" : "INACTIVO"));
//
//
//        }catch (IllegalArgumentException | IllegalStateException e){
//            System.out.println(e.getMessage());
//        }
//        }
//
//    public void desactivarEstadoUsuario(){
//
//        System.out.println("Introduce el username de quien quieres actualizar");
//        String julian = scanner.nextLine();
//
//        Optional <Usuario> usuario = usuarioService.buscarUsuario(julian);
//        System.out.println("--- Datos encontrados ---");
//        System.out.println("ID: " + usuario.get().getIdUsuario() + " USERNAME: " + usuario.get().getUsername() + " ACTIVO?: " + (usuario.get().isActivo()?"ACTIVO" : "INACTIVO"));
//        System.out.println("Introduce el nuevo estado True (ACTIVO) / False (INACTIVO)");
//        boolean nuevoEstado = scanner.nextBoolean();
//        scanner.nextLine();
//        usuario.get().setActivo(nuevoEstado);
//
//        Usuario estadoActualizado = usuarioService.updateEstado(usuario.get());
//        System.out.println("El usuario se ha actualizado correctamente");
//        System.out.println("ID: " + estadoActualizado.getIdUsuario() + " USERNAME: " + estadoActualizado.getUsername() + " ACTIVO?: " + (estadoActualizado.isActivo()?"ACTIVO" : "INACTIVO"));
//    }
//
//    public void eliminarUsuario(){
//
//        System.out.println("Introduce el username de quien quieres eliminar");
//        String julian = scanner.nextLine();
//
//        Optional <Usuario> usuario = usuarioService.buscarUsuario(julian);
//        System.out.println("--- Datos encontrados ---");
//        System.out.println("ID: " + usuario.get().getIdUsuario() + " USERNAME: " + usuario.get().getUsername() + " ACTIVO?: " + (usuario.get().isActivo()?"ACTIVO" : "INACTIVO"));
//
//        System.out.println("Estas seguro que quieres eliminarlo? Si / No");
//        String opcion = scanner.nextLine().toLowerCase().trim();
//        switch (opcion){
//            case "si":
//                usuarioService.deleteUsuario(usuario.get());
//                if (!usuarioService.comprobarUsername(usuario.get().getUsername())){
//                    System.out.println("El usuario se ha eliminado");
//                }else {
//                    System.out.println("El usuario no se ha borrado");
//                }
//                break;
//            case "no":
//                System.out.println("No se borrará el usuario");
//                break;
//            default:
//                System.out.println("Seleccione una opcion valida");
//
//        }
//    }
//
//}
