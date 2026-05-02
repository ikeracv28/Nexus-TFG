# Plan de implementación — Hito 4: Chat en tiempo real (WebSocket/STOMP)

**Proyecto**: Nexus TFG  
**Stack**: Spring Boot 3.4.1 + Flutter Web + Docker  
**Estado inicial**: `ChatPlaceholderScreen` existe en `dashboard_screen.dart` (índice 4)  
**Objetivo**: WebSocket STOMP bidireccional. Flutter conecta a `ws://localhost:8080/ws`.

---

## ÍNDICE DE PASOS

1. Backend — Dependencia WebSocket en pom.xml  
2. Backend — Migración Flyway V10  
3. Backend — Entidad `Mensaje` + DTOs  
4. Backend — Repositorio  
5. Backend — Servicio  
6. Backend — `WebSocketConfig` + interceptor JWT STOMP  
7. Backend — `MensajeController`  
8. Backend — `SecurityConfig` (permitir `/ws/**`)  
9. Nginx — Actualizar CSP (añadir `ws://localhost:8080`)  
10. Flutter — Añadir `stomp_dart_client` al pubspec  
11. Flutter — Modelo `MensajeModel`  
12. Flutter — `MensajeService`  
13. Flutter — `ChatProvider`  
14. Flutter — `ChatScreen` (sustituir placeholder)  
15. Flutter — Registrar `ChatProvider` en main  
16. Docker — Rebuild y test  
17. Auditoría — Añadir log de mensajes  

---

## PASO 1 — pom.xml: añadir WebSocket

**Archivo**: `backend/tfg-nexus-api/pom.xml`  
Añadir justo después del bloque `<!-- Web & Validation -->`:

```xml
<!-- WebSocket / STOMP -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-websocket</artifactId>
</dependency>
```

---

## PASO 2 — Flyway V10: tabla mensajes

**Archivo nuevo**: `backend/tfg-nexus-api/src/main/resources/db/migration/V10__Mensajes_Chat.sql`

```sql
CREATE TABLE mensajes (
    id           BIGSERIAL PRIMARY KEY,
    practica_id  BIGINT    NOT NULL REFERENCES practicas(id) ON DELETE CASCADE,
    remitente_id BIGINT    NOT NULL REFERENCES usuarios(id),
    contenido    TEXT      NOT NULL,
    fecha_envio  TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_mensajes_practica ON mensajes (practica_id, fecha_envio DESC);
```

---

## PASO 3 — Entidad Mensaje + DTOs

### 3a. Entidad Mensaje

**Archivo nuevo**: `backend/tfg-nexus-api/src/main/java/com/tfg/api/models/entity/Mensaje.java`

```java
package com.tfg.api.models.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "mensajes")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Mensaje {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "practica_id", nullable = false)
    private Practica practica;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "remitente_id", nullable = false)
    private Usuario remitente;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String contenido;

    @Column(name = "fecha_envio", nullable = false)
    private LocalDateTime fechaEnvio;

    @PrePersist
    protected void onCreate() {
        if (this.fechaEnvio == null) this.fechaEnvio = LocalDateTime.now();
    }
}
```

### 3b. MensajeRequest DTO

**Archivo nuevo**: `backend/tfg-nexus-api/src/main/java/com/tfg/api/models/dto/MensajeRequest.java`

```java
package com.tfg.api.models.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record MensajeRequest(
    @NotBlank(message = "El contenido no puede estar vacío")
    @Size(max = 1000, message = "El mensaje no puede superar los 1000 caracteres")
    String contenido
) {}
```

### 3c. MensajeResponse DTO

**Archivo nuevo**: `backend/tfg-nexus-api/src/main/java/com/tfg/api/models/dto/MensajeResponse.java`

```java
package com.tfg.api.models.dto;

import java.time.LocalDateTime;

public record MensajeResponse(
    Long id,
    Long practicaId,
    Long remitenteId,
    String remitenteNombre,
    String remitenteApellidos,
    String contenido,
    LocalDateTime fechaEnvio
) {}
```

---

## PASO 4 — Repositorio

**Archivo nuevo**: `backend/tfg-nexus-api/src/main/java/com/tfg/api/models/repository/MensajeRepository.java`

```java
package com.tfg.api.models.repository;

import com.tfg.api.models.entity.Mensaje;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface MensajeRepository extends JpaRepository<Mensaje, Long> {
    List<Mensaje> findByPracticaIdOrderByFechaEnvioAsc(Long practicaId);
}
```

---

## PASO 5 — Servicio

### 5a. Interface

**Archivo nuevo**: `backend/tfg-nexus-api/src/main/java/com/tfg/api/services/MensajeService.java`

```java
package com.tfg.api.services;

import com.tfg.api.models.dto.MensajeRequest;
import com.tfg.api.models.dto.MensajeResponse;
import java.util.List;

public interface MensajeService {
    MensajeResponse guardar(MensajeRequest request, String emailRemitente, Long practicaId);
    List<MensajeResponse> listarPorPractica(Long practicaId);
}
```

### 5b. Implementación

**Archivo nuevo**: `backend/tfg-nexus-api/src/main/java/com/tfg/api/services/impl/MensajeServiceImpl.java`

```java
package com.tfg.api.services.impl;

import com.tfg.api.exceptions.BusinessRuleException;
import com.tfg.api.exceptions.ResourceNotFoundException;
import com.tfg.api.models.dto.MensajeRequest;
import com.tfg.api.models.dto.MensajeResponse;
import com.tfg.api.models.entity.Mensaje;
import com.tfg.api.models.entity.Practica;
import com.tfg.api.models.entity.Usuario;
import com.tfg.api.models.repository.MensajeRepository;
import com.tfg.api.models.repository.PracticaRepository;
import com.tfg.api.models.repository.UsuarioRepository;
import com.tfg.api.services.AuditService;
import com.tfg.api.services.MensajeService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class MensajeServiceImpl implements MensajeService {

    private final MensajeRepository mensajeRepository;
    private final PracticaRepository practicaRepository;
    private final UsuarioRepository usuarioRepository;
    private final AuditService auditService;

    @Override
    @Transactional
    public MensajeResponse guardar(MensajeRequest request, String emailRemitente, Long practicaId) {
        Practica practica = practicaRepository.findById(practicaId)
                .orElseThrow(() -> new ResourceNotFoundException("Práctica no encontrada"));

        Usuario remitente = usuarioRepository.findByEmail(emailRemitente)
                .orElseThrow(() -> new ResourceNotFoundException("Usuario no encontrado"));

        // Solo los participantes de la práctica pueden enviar mensajes
        boolean esParticipante = emailRemitente.equals(practica.getAlumno().getEmail())
                || emailRemitente.equals(practica.getTutorCentro().getEmail())
                || emailRemitente.equals(practica.getTutorEmpresa().getEmail());
        if (!esParticipante) {
            throw new BusinessRuleException("No tienes acceso al chat de esta práctica");
        }

        Mensaje mensaje = Mensaje.builder()
                .practica(practica)
                .remitente(remitente)
                .contenido(request.contenido())
                .build();

        Mensaje guardado = mensajeRepository.save(mensaje);
        auditService.registrar("MENSAJES", "ENVIAR", guardado.getId(),
                "Practica=" + practicaId, emailRemitente);

        return toResponse(guardado);
    }

    @Override
    @Transactional(readOnly = true)
    public List<MensajeResponse> listarPorPractica(Long practicaId) {
        return mensajeRepository.findByPracticaIdOrderByFechaEnvioAsc(practicaId)
                .stream().map(this::toResponse).toList();
    }

    private MensajeResponse toResponse(Mensaje m) {
        return new MensajeResponse(
                m.getId(),
                m.getPractica().getId(),
                m.getRemitente().getId(),
                m.getRemitente().getNombre(),
                m.getRemitente().getApellidos(),
                m.getContenido(),
                m.getFechaEnvio());
    }
}
```

---

## PASO 6 — WebSocketConfig + Interceptor JWT

### 6a. WebSocketConfig

**Archivo nuevo**: `backend/tfg-nexus-api/src/main/java/com/tfg/api/config/WebSocketConfig.java`

```java
package com.tfg.api.config;

import com.tfg.api.security.WebSocketAuthInterceptor;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.simp.config.ChannelRegistration;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.web.socket.config.annotation.EnableWebSocketMessageBroker;
import org.springframework.web.socket.config.annotation.StompEndpointRegistry;
import org.springframework.web.socket.config.annotation.WebSocketMessageBrokerConfigurer;

@Configuration
@EnableWebSocketMessageBroker
@RequiredArgsConstructor
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {

    private final WebSocketAuthInterceptor webSocketAuthInterceptor;

    @Override
    public void configureMessageBroker(MessageBrokerRegistry config) {
        // /topic — canal de broadcast (el broker simple lo gestiona en memoria)
        config.enableSimpleBroker("/topic");
        // /app — prefijo para @MessageMapping en los controllers
        config.setApplicationDestinationPrefixes("/app");
    }

    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        // Endpoint de conexión WebSocket — SIN SockJS (Flutter usa WS nativo)
        registry.addEndpoint("/ws")
                .setAllowedOriginPatterns("*");
    }

    @Override
    public void configureClientInboundChannel(ChannelRegistration registration) {
        // Intercepta el frame STOMP CONNECT para validar el JWT
        registration.interceptors(webSocketAuthInterceptor);
    }
}
```

### 6b. WebSocketAuthInterceptor

**Archivo nuevo**: `backend/tfg-nexus-api/src/main/java/com/tfg/api/security/WebSocketAuthInterceptor.java`

```java
package com.tfg.api.security;

import lombok.RequiredArgsConstructor;
import org.springframework.messaging.Message;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.simp.stomp.StompCommand;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.messaging.support.ChannelInterceptor;
import org.springframework.messaging.support.MessageHeaderAccessor;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class WebSocketAuthInterceptor implements ChannelInterceptor {

    private final JwtUtils jwtUtils;
    private final UserDetailsService userDetailsService;

    @Override
    public Message<?> preSend(Message<?> message, MessageChannel channel) {
        StompHeaderAccessor accessor =
                MessageHeaderAccessor.getAccessor(message, StompHeaderAccessor.class);

        if (accessor != null && StompCommand.CONNECT.equals(accessor.getCommand())) {
            String authHeader = accessor.getFirstNativeHeader("Authorization");
            if (authHeader != null && authHeader.startsWith("Bearer ")) {
                String token = authHeader.substring(7);
                try {
                    String email = jwtUtils.extractUsername(token);
                    if (email != null) {
                        UserDetails userDetails = userDetailsService.loadUserByUsername(email);
                        if (jwtUtils.validateToken(token, userDetails)) {
                            UsernamePasswordAuthenticationToken auth =
                                    new UsernamePasswordAuthenticationToken(
                                            userDetails, null, userDetails.getAuthorities());
                            accessor.setUser(auth);
                        }
                    }
                } catch (Exception ignored) {
                    // Token inválido — la conexión STOMP quedará sin autenticar
                    // y los endpoints con @PreAuthorize denegarán el acceso
                }
            }
        }
        return message;
    }
}
```

---

## PASO 7 — MensajeController

**Archivo nuevo**: `backend/tfg-nexus-api/src/main/java/com/tfg/api/controllers/MensajeController.java`

```java
package com.tfg.api.controllers;

import com.tfg.api.models.dto.MensajeRequest;
import com.tfg.api.models.dto.MensajeResponse;
import com.tfg.api.services.MensajeService;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;

import java.security.Principal;
import java.util.List;

@RestController
@RequestMapping("/api/v1/mensajes")
@RequiredArgsConstructor
public class MensajeController {

    private final MensajeService mensajeService;
    private final SimpMessagingTemplate messagingTemplate;

    /**
     * REST: historial de mensajes de una práctica (carga inicial al abrir el chat).
     * Acceso: todos los participantes de la práctica (ADMIN, tutores, alumno).
     */
    @GetMapping("/practica/{practicaId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'TUTOR_CENTRO', 'TUTOR_EMPRESA', 'ALUMNO')")
    public ResponseEntity<List<MensajeResponse>> historial(@PathVariable Long practicaId) {
        return ResponseEntity.ok(mensajeService.listarPorPractica(practicaId));
    }

    /**
     * STOMP: recibe un mensaje y lo publica en el topic de la práctica.
     * Flutter envía a:   /app/chat/{practicaId}
     * Flutter suscribe:  /topic/practica/{practicaId}
     */
    @MessageMapping("/chat/{practicaId}")
    public void enviarMensaje(
            @DestinationVariable Long practicaId,
            @Payload MensajeRequest request,
            Principal principal) {
        if (principal == null) return; // no autenticado — ignorar
        MensajeResponse resp = mensajeService.guardar(request, principal.getName(), practicaId);
        messagingTemplate.convertAndSend("/topic/practica/" + practicaId, resp);
    }
}
```

---

## PASO 8 — SecurityConfig: permitir /ws/**

**Archivo modificar**: `backend/tfg-nexus-api/src/main/java/com/tfg/api/config/SecurityConfig.java`

Busca la sección `.authorizeHttpRequests` y añade la línea de `/ws/**`:

```java
.authorizeHttpRequests(auth -> auth
    .requestMatchers("/api/v1/auth/**").permitAll()
    .requestMatchers("/ws/**").permitAll()   // <-- AÑADIR ESTA LÍNEA
    .anyRequest().authenticated()
)
```

---

## PASO 9 — Nginx: actualizar CSP

**Archivo modificar**: `frontend/nginx.conf`

Busca la cabecera `Content-Security-Policy` y añade `ws://localhost:8080` al `connect-src`:

```nginx
# ANTES:
add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; img-src 'self' data:; connect-src 'self' http://localhost:8080;" always;

# DESPUÉS:
add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; img-src 'self' data:; connect-src 'self' http://localhost:8080 ws://localhost:8080;" always;
```

---

## PASO 10 — pubspec.yaml: añadir stomp_dart_client

**Archivo modificar**: `frontend/pubspec.yaml`

Añadir en la sección `dependencies` (al lado de dio, provider, etc.):

```yaml
# Chat WebSocket STOMP
stomp_dart_client: ^2.0.0
```

Después de editar el pubspec, dentro del contenedor de Flutter se ejecutará `flutter pub get` automáticamente en el rebuild. NO hace falta ejecutarlo manualmente ahora.

---

## PASO 11 — Flutter: MensajeModel

**Archivo nuevo**: `frontend/lib/data/models/mensaje_model.dart`

```dart
class MensajeModel {
  final int id;
  final int practicaId;
  final int remitenteId;
  final String remitenteNombre;
  final String remitenteApellidos;
  final String contenido;
  final DateTime fechaEnvio;

  MensajeModel({
    required this.id,
    required this.practicaId,
    required this.remitenteId,
    required this.remitenteNombre,
    required this.remitenteApellidos,
    required this.contenido,
    required this.fechaEnvio,
  });

  String get nombreCompleto => '$remitenteNombre $remitenteApellidos';

  factory MensajeModel.fromJson(Map<String, dynamic> json) {
    return MensajeModel(
      id: json['id'] as int,
      practicaId: json['practicaId'] as int,
      remitenteId: json['remitenteId'] as int,
      remitenteNombre: json['remitenteNombre'] as String,
      remitenteApellidos: json['remitenteApellidos'] as String,
      contenido: json['contenido'] as String,
      fechaEnvio: DateTime.parse(json['fechaEnvio'] as String),
    );
  }
}
```

---

## PASO 12 — Flutter: MensajeService

**Archivo nuevo**: `frontend/lib/data/services/mensaje_service.dart`

```dart
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../models/mensaje_model.dart';
import '../../core/config/api_client.dart';

class MensajeService {
  final ApiClient _apiClient = ApiClient();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  StompClient? _stompClient;

  // ---- REST: historial ----

  Future<List<MensajeModel>> getHistorial(int practicaId) async {
    final response =
        await _apiClient.dio.get('/mensajes/practica/$practicaId');
    return (response.data as List)
        .map((j) => MensajeModel.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  // ---- STOMP: conexión en tiempo real ----

  Future<void> conectar({
    required int practicaId,
    required void Function(MensajeModel) onMensaje,
    void Function()? onConectado,
    void Function()? onDesconectado,
  }) async {
    // Recuperar el token almacenado de forma segura
    final token = await _storage.read(key: 'jwt_token') ?? '';

    _stompClient = StompClient(
      config: StompConfig(
        // La URL WebSocket apunta directamente al backend (puerto 8080,
        // igual que el ApiClient usa http://localhost:8080/api/v1)
        url: 'ws://localhost:8080/ws',
        // Cabeceras del frame STOMP CONNECT — aquí va el JWT
        stompConnectHeaders: {'Authorization': 'Bearer $token'},
        onConnect: (frame) {
          onConectado?.call();
          // Suscribirse al topic de esta práctica
          _stompClient!.subscribe(
            destination: '/topic/practica/$practicaId',
            callback: (frame) {
              if (frame.body == null) return;
              try {
                final json = jsonDecode(frame.body!) as Map<String, dynamic>;
                onMensaje(MensajeModel.fromJson(json));
              } catch (_) {}
            },
          );
        },
        onDisconnect: (_) => onDesconectado?.call(),
        onStompError: (frame) => onDesconectado?.call(),
        onWebSocketError: (_) => onDesconectado?.call(),
        reconnectDelay: const Duration(seconds: 5),
      ),
    );

    _stompClient!.activate();
  }

  void enviarMensaje({
    required int practicaId,
    required String contenido,
  }) {
    if (_stompClient == null || !_stompClient!.connected) return;
    _stompClient!.send(
      destination: '/app/chat/$practicaId',
      body: jsonEncode({'contenido': contenido}),
    );
  }

  void desconectar() {
    _stompClient?.deactivate();
    _stompClient = null;
  }
}
```

---

## PASO 13 — Flutter: ChatProvider

**Archivo nuevo**: `frontend/lib/presentation/providers/chat_provider.dart`

```dart
import 'package:flutter/material.dart';
import '../../data/models/mensaje_model.dart';
import '../../data/services/mensaje_service.dart';

class ChatProvider extends ChangeNotifier {
  final MensajeService _service = MensajeService();

  List<MensajeModel> _mensajes = [];
  bool _cargando = false;
  bool _conectado = false;
  int? _practicaId;

  List<MensajeModel> get mensajes => _mensajes;
  bool get cargando => _cargando;
  bool get conectado => _conectado;

  Future<void> iniciar(int practicaId) async {
    if (_practicaId == practicaId && _conectado) return;
    _practicaId = practicaId;
    _cargando = true;
    notifyListeners();

    try {
      _mensajes = await _service.getHistorial(practicaId);
    } catch (_) {
      _mensajes = [];
    }

    await _service.conectar(
      practicaId: practicaId,
      onMensaje: (mensaje) {
        // Evitar duplicados por si el historial ya lo incluye
        if (_mensajes.any((m) => m.id == mensaje.id)) return;
        _mensajes.add(mensaje);
        notifyListeners();
      },
      onConectado: () {
        _conectado = true;
        notifyListeners();
      },
      onDesconectado: () {
        _conectado = false;
        notifyListeners();
      },
    );

    _cargando = false;
    notifyListeners();
  }

  void enviar(String contenido) {
    if (_practicaId == null || contenido.trim().isEmpty) return;
    _service.enviarMensaje(
      practicaId: _practicaId!,
      contenido: contenido.trim(),
    );
  }

  void limpiar() {
    _service.desconectar();
    _mensajes = [];
    _conectado = false;
    _practicaId = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _service.desconectar();
    super.dispose();
  }
}
```

---

## PASO 14 — Flutter: ChatScreen

**Archivo reemplazar**: `frontend/lib/presentation/screens/chat_placeholder_screen.dart`  
(Renombrar o reemplazar su contenido completo por el siguiente)

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/mensaje_model.dart';
import '../providers/auth_provider.dart';
import '../providers/practica_provider.dart';
import '../providers/chat_provider.dart';

class ChatPlaceholderScreen extends StatefulWidget {
  const ChatPlaceholderScreen({super.key});

  @override
  State<ChatPlaceholderScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatPlaceholderScreen> {
  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final practica = context.read<PracticaProvider>().practica;
      if (practica != null) {
        context.read<ChatProvider>().iniciar(practica.id);
      }
    });
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    // NO llamar limpiar() aquí para no cortar el WebSocket al salir de tab
    super.dispose();
  }

  void _scrollAlFinal() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _enviar() {
    final texto = _inputCtrl.text.trim();
    if (texto.isEmpty) return;
    context.read<ChatProvider>().enviar(texto);
    _inputCtrl.clear();
    _scrollAlFinal();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final chat = context.watch<ChatProvider>();
    final practica = context.watch<PracticaProvider>().practica;

    if (practica == null) {
      return const Center(
        child: Text('No tienes ninguna práctica activa.',
            style: TextStyle(color: NexusColors.inkSecondary)),
      );
    }

    // Hacer scroll al fondo cuando llegan mensajes nuevos
    if (chat.mensajes.isNotEmpty) _scrollAlFinal();

    return Column(
      children: [
        // ---- Header ----
        Container(
          color: NexusColors.surface,
          padding: const EdgeInsets.symmetric(
              horizontal: NexusSizes.spaceLG, vertical: NexusSizes.spaceMD),
          child: Row(
            children: [
              const Icon(Icons.chat_bubble_outline,
                  size: 18, color: NexusColors.primary),
              const SizedBox(width: NexusSizes.spaceSM),
              Expanded(
                child: Text('Chat — ${practica.codigo}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: NexusColors.ink)),
              ),
              // Indicador de conexión WebSocket
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: chat.conectado ? NexusColors.success : NexusColors.neutral,
                ),
              ),
              const SizedBox(width: NexusSizes.spaceXS),
              Text(
                chat.conectado ? 'Conectado' : 'Conectando…',
                style: TextStyle(
                    fontSize: 11,
                    color: chat.conectado
                        ? NexusColors.success
                        : NexusColors.inkTertiary),
              ),
            ],
          ),
        ),
        const Divider(height: 0.5, thickness: 0.5, color: NexusColors.border),

        // ---- Lista de mensajes ----
        Expanded(
          child: chat.cargando
              ? const Center(child: CircularProgressIndicator())
              : chat.mensajes.isEmpty
                  ? const Center(
                      child: Text('Sé el primero en escribir.',
                          style: TextStyle(color: NexusColors.inkTertiary,
                              fontSize: 13)),
                    )
                  : ListView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.symmetric(
                          horizontal: NexusSizes.spaceLG,
                          vertical: NexusSizes.spaceMD),
                      itemCount: chat.mensajes.length,
                      itemBuilder: (_, i) {
                        final msg = chat.mensajes[i];
                        final esMio =
                            msg.remitenteId == auth.user?.id;
                        return _MensajeBurbuja(
                            mensaje: msg, esMio: esMio);
                      },
                    ),
        ),

        const Divider(height: 0.5, thickness: 0.5, color: NexusColors.border),

        // ---- Input de texto ----
        Container(
          color: NexusColors.surface,
          padding: const EdgeInsets.symmetric(
              horizontal: NexusSizes.spaceMD, vertical: NexusSizes.spaceSM),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _inputCtrl,
                  maxLength: 1000,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _enviar(),
                  decoration: InputDecoration(
                    hintText: 'Escribe un mensaje…',
                    hintStyle: const TextStyle(
                        color: NexusColors.inkTertiary, fontSize: 13),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(NexusSizes.radiusFull),
                      borderSide: const BorderSide(color: NexusColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(NexusSizes.radiusFull),
                      borderSide: const BorderSide(color: NexusColors.border),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: NexusSizes.spaceLG,
                        vertical: NexusSizes.spaceSM),
                    isDense: true,
                    counterText: '',
                  ),
                ),
              ),
              const SizedBox(width: NexusSizes.spaceSM),
              FilledButton(
                onPressed: chat.conectado ? _enviar : null,
                style: FilledButton.styleFrom(
                  backgroundColor: NexusColors.primary,
                  minimumSize: const Size(44, 44),
                  padding: EdgeInsets.zero,
                  shape: const CircleBorder(),
                ),
                child: const Icon(Icons.send_rounded, size: 18,
                    color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MensajeBurbuja extends StatelessWidget {
  final MensajeModel mensaje;
  final bool esMio;

  const _MensajeBurbuja({required this.mensaje, required this.esMio});

  @override
  Widget build(BuildContext context) {
    final hora =
        '${mensaje.fechaEnvio.hour.toString().padLeft(2, '0')}:${mensaje.fechaEnvio.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: NexusSizes.spaceSM),
      child: Row(
        mainAxisAlignment:
            esMio ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!esMio) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: NexusColors.primaryLight,
              child: Text(
                mensaje.remitenteNombre.isNotEmpty
                    ? mensaje.remitenteNombre[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: NexusColors.primaryText),
              ),
            ),
            const SizedBox(width: NexusSizes.spaceXS),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: esMio
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (!esMio)
                  Padding(
                    padding: const EdgeInsets.only(
                        left: NexusSizes.spaceXS, bottom: 2),
                    child: Text(
                      mensaje.nombreCompleto,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: NexusColors.inkSecondary),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: NexusSizes.spaceMD,
                      vertical: NexusSizes.spaceSM),
                  decoration: BoxDecoration(
                    color: esMio
                        ? NexusColors.primary
                        : NexusColors.surface,
                    border: esMio
                        ? null
                        : Border.all(color: NexusColors.border),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(NexusSizes.radiusMD),
                      topRight: const Radius.circular(NexusSizes.radiusMD),
                      bottomLeft: Radius.circular(
                          esMio ? NexusSizes.radiusMD : 4),
                      bottomRight: Radius.circular(
                          esMio ? 4 : NexusSizes.radiusMD),
                    ),
                  ),
                  child: Text(
                    mensaje.contenido,
                    style: TextStyle(
                        fontSize: 13,
                        color: esMio ? Colors.white : NexusColors.ink),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 2, left: NexusSizes.spaceXS,
                      right: NexusSizes.spaceXS),
                  child: Text(hora,
                      style: const TextStyle(
                          fontSize: 10,
                          color: NexusColors.inkTertiary)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## PASO 15 — Flutter: Registrar ChatProvider en main.dart

**Archivo modificar**: `frontend/lib/main.dart`

Busca donde se registran los providers (probablemente un `MultiProvider` con `ChangeNotifierProvider`).  
Añadir:

```dart
// Añadir este import al principio del archivo:
import 'presentation/providers/chat_provider.dart';

// Añadir dentro del MultiProvider (lista de providers):
ChangeNotifierProvider(create: (_) => ChatProvider()),
```

**Verificar también** en `dashboard_screen.dart` que el import del chat apunta al mismo archivo:  
```dart
import 'chat_placeholder_screen.dart'; // este import ya existe y es correcto
```
El widget usado en el `IndexedStack` también se llama `ChatPlaceholderScreen` — el nombre no cambia, solo el contenido del archivo.

---

## PASO 16 — Añadir `id` al UsuarioModel (si no existe)

El `ChatProvider` usa `auth.user?.id` para saber si el mensaje es mío.  
Verificar que `AuthProvider` expone `user` con el campo `id`.  

Buscar en `frontend/lib/data/models/usuario_model.dart` si tiene `id`. Si no, añadirlo:
```dart
// Ya existe en este proyecto: final int id;
// Verificado en UsuarioModel — campo id presente. No hay nada que añadir.
```

---

## PASO 17 — Docker: rebuild y test

```bash
# Solo backend y frontend (la BD no cambia en el rebuild, pero Flyway aplicará V10)
docker-compose build --no-cache backend frontend

# Reemplazar contenedores
docker rm -f nexus-api nexus-web
docker-compose up -d

# Verificar que V10 se aplicó
docker logs nexus-api 2>&1 | grep "V10"
# Debe salir: Successfully applied 1 migration to schema "public", now at version v10

# Verificar que no hay errores
docker logs nexus-api 2>&1 | grep "ERROR"
```

Después: **Ctrl+Shift+R** en Chrome (limpiar caché Flutter web).

---

## PASO 18 — Test manual del chat

1. Abre Chrome en `http://localhost`
2. Login como `alumno@nexus.edu` / `Alumno@Nexus2026`
3. Ve a la pestaña Chat (icono chat en la barra inferior)
4. Debería aparecer el indicador "Conectado" en verde
5. Abre otra ventana de Chrome en modo incógnito
6. Login como `tutor@nexus.edu` / `Tutor@Nexus2026`
7. Ve a la pestaña Chat (en el panel tutor, pestaña de su práctica)
8. Escribe un mensaje desde el alumno → debe aparecer en tiempo real en el tutor

---

## PROBLEMAS COMUNES Y SOLUCIONES

### Error: "WebSocket connection failed" en la consola del browser
- Verificar que el contenedor `nexus-api` está corriendo: `docker ps`
- Verificar que el puerto 8080 está expuesto: `docker-compose ps`
- Verificar que la CSP de Nginx incluye `ws://localhost:8080`

### Error: "403 Forbidden" al conectar STOMP
- El `WebSocketAuthInterceptor` rechazó el JWT
- Verificar que `stompConnectHeaders: {'Authorization': 'Bearer $token'}` se pasa en el `StompConfig`
- Verificar que la ruta `/ws/**` está en `permitAll()` en `SecurityConfig`

### Los mensajes no llegan en tiempo real (pero el historial REST sí funciona)
- Verificar que Flutter suscribe a `/topic/practica/{id}` (con el ID correcto)
- Verificar que el backend publica en `/topic/practica/{id}` (mismo path)
- Ver logs del backend: `docker logs nexus-api -f`

### `stomp_dart_client` no compila en Flutter web
- Verificar que se añadió al `pubspec.yaml` y se hizo `flutter pub get`
- En Flutter web, `stomp_dart_client` usa `dart:html` WebSocket internamente — es compatible

### Principal es null en `@MessageMapping`
- El interceptor JWT no autenticó al usuario
- Verificar que el `WebSocketAuthInterceptor` está registrado en `configureClientInboundChannel`
- Añadir un log temporal en el interceptor: `System.out.println("STOMP CONNECT token: " + authHeader)`

---

## DÓNDE AÑADIR EL CHAT EN EL PANEL TUTOR (opcional)

El panel del tutor de centro (`panel_tutor_centro_screen.dart`) muestra detalles del alumno.
Para añadir chat allí también:

1. Añadir un botón "Abrir chat" en `_DetailPanel` que navegue a una pantalla de chat con ese `practicaId`
2. Reutilizar `ChatPlaceholderScreen` pasándole el `practicaId` como parámetro

Para esto, modificar `ChatPlaceholderScreen` para aceptar un `practicaId` opcional:
```dart
class ChatPlaceholderScreen extends StatefulWidget {
  final int? practicaIdOverride; // null = usar el de PracticaProvider
  const ChatPlaceholderScreen({super.key, this.practicaIdOverride});
  ...
}
// En initState:
final id = widget.practicaIdOverride ?? context.read<PracticaProvider>().practica?.id;
```

---

## RESUMEN DE ARCHIVOS MODIFICADOS/CREADOS

| Archivo | Acción |
|---------|--------|
| `backend/.../pom.xml` | Modificar: añadir spring-boot-starter-websocket |
| `backend/.../db/migration/V10__Mensajes_Chat.sql` | Crear |
| `backend/.../entity/Mensaje.java` | Crear |
| `backend/.../dto/MensajeRequest.java` | Crear |
| `backend/.../dto/MensajeResponse.java` | Crear |
| `backend/.../repository/MensajeRepository.java` | Crear |
| `backend/.../services/MensajeService.java` | Crear |
| `backend/.../services/impl/MensajeServiceImpl.java` | Crear |
| `backend/.../config/WebSocketConfig.java` | Crear |
| `backend/.../security/WebSocketAuthInterceptor.java` | Crear |
| `backend/.../controllers/MensajeController.java` | Crear |
| `backend/.../config/SecurityConfig.java` | Modificar: añadir `/ws/**` permitAll |
| `frontend/nginx.conf` | Modificar: añadir ws:// al CSP |
| `frontend/pubspec.yaml` | Modificar: añadir stomp_dart_client |
| `frontend/lib/data/models/mensaje_model.dart` | Crear |
| `frontend/lib/data/services/mensaje_service.dart` | Crear |
| `frontend/lib/presentation/providers/chat_provider.dart` | Crear |
| `frontend/lib/presentation/screens/chat_placeholder_screen.dart` | Reemplazar |
| `frontend/lib/main.dart` | Modificar: registrar ChatProvider |
