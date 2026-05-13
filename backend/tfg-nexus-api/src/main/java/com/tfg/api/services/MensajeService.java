package com.tfg.api.services;

import com.tfg.api.models.dto.MensajeRequest;
import com.tfg.api.models.dto.MensajeResponse;
import java.util.List;

public interface MensajeService {
    MensajeResponse guardar(MensajeRequest request, String emailRemitente, Long practicaId, String canal);
    List<MensajeResponse> listarPorPractica(Long practicaId, String canal);
}
