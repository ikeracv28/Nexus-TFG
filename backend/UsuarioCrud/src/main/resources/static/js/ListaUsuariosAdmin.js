// --- Selectores de navegación y elementos ---
const saludoUsuario = document.getElementById("saludoUsuario");
const datosMostrar = document.getElementById("datosMostrar");
const btnSalir = document.getElementById("btnSalir");
const btnVerUsuarios = document.getElementById("btnVerUsuarios");
const volver = document.getElementById("volver");

// --- VARIABLE PARA EL MODAL NATIVO ---
const editDialog = document.getElementById('editDialog');
const editForm = document.getElementById('editForm');

// --- EVENTOS DE NAVEGACIÓN ---
if (btnSalir) {
    btnSalir.addEventListener("click", () => window.location.href = 'killSession');
}
if (btnVerUsuarios) {
    btnVerUsuarios.addEventListener("click", () => window.location.href = '/admin');
}
if (volver) {
    volver.addEventListener("click", () => window.location.href = '/control');
}

// --- CARGA INICIAL ---
document.addEventListener('DOMContentLoaded', () => {
    // Escuchar el envío del formulario del dialog
    if (editForm) {
        editForm.addEventListener('submit', enviarActualizacion);
    }

    // Cargamos los roles reales de la base de datos
    cargarRolesEnSelect();

    // Inicializar encabezados
    actualizarEncabezado("PANEL ADMINISTRATIVO", "Panel de Administración > Lista de Usuarios Registrados");

    // Decidir qué cargar según el contenedor presente
    if (document.getElementById("datosMostrar")) {
        // Si estamos en la vista de lista completa
        if (window.location.pathname.includes('/admin')) {
            cargarUsuarios();
        } else {
            // Si estamos en el perfil individual
            cargarDatosPerfil();
        }
    }
});

// --- LÓGICA DE PERFIL (MANTENIDA) ---
function cargarDatosPerfil() {
    fetch('/admin/datosAdmin')
        .then(response => {
            if (response.ok) return response.json();
            throw new Error(`Error ${response.status}`);
        })
        .then(data => {
            saludoUsuario.style.opacity = "0";
            saludoUsuario.innerHTML = `Bienvenido de nuevo, <span class="text-primary">${data.username}</span>`;

            setTimeout(() => {
                saludoUsuario.style.transition = "opacity 0.8s ease-in-out";
                saludoUsuario.style.opacity = "1";
            }, 100);

            const fecha = data.fechaCreacion ? new Date(data.fechaCreacion).toLocaleDateString() : '-';
            datosMostrar.innerHTML = `
                <div class="table-container">
                    <table class="table table-hover align-middle mb-0">
                        <thead>
                            <tr>
                                <th class="ps-3">ID</th>
                                <th>Username</th>
                                <th>Rol</th>
                                <th>Fecha Creación</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td class="ps-3 fw-bold text-muted">${data.idUsuario}</td>
                                <td class="fw-bold">${data.username}</td>
                                <td><span class="badge bg-dark px-3 py-2 text-uppercase">${data.nombreRol}</span></td>
                                <td class="text-muted">${fecha}</td>
                            </tr>
                        </tbody>
                    </table>
                </div>`;
        })
        .catch(err => {
            console.error(err);
            datosMostrar.innerHTML = `<div class="alert alert-danger">Error al cargar perfil.</div>`;
        });
}

// --- LÓGICA DE LISTA COMPLETA (ADMIN) ---
function cargarUsuarios() {
    fetch('/admin/verUsuarios')
        .then(res => res.json())
        .then(data => {
            let tablaHTML = `
            <div class="table-container">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-dark">
                        <tr>
                            <th class="ps-3">ID</th>
                            <th>Username</th>
                            <th>Rol</th>
                            <th>Fecha</th>
                            <th>Estado</th>
                            <th class="text-center">Acciones</th>
                        </tr>
                    </thead>
                    <tbody class="bg-white">`;

            data.forEach(usuario => {
                const fecha = usuario.fechaCreacion ? new Date(usuario.fechaCreacion).toLocaleDateString() : '-';
                const estadoBadge = usuario.estado ?
                    '<span class="badge bg-success">Activo</span>' :
                    '<span class="badge bg-danger">Inactivo</span>';

                tablaHTML += `
                    <tr>
                        <td class="ps-3 fw-bold text-muted">${usuario.idUsuario}</td>
                        <td class="fw-bold">${usuario.username}</td>
                        <td><span class="badge bg-info text-dark">${usuario.nombreRol}</span></td>                       
                        <td>${fecha}</td>
                        <td>${estadoBadge}</td>
                        <td class="text-center">
                            <div class="btn-group">
                                <button class="btn btn-sm btn-warning fw-bold px-3" 
                                    onclick="prepararEdicion('${usuario.idUsuario}', '${usuario.username}', '${usuario.nombreRol}', ${usuario.estado})">
                                    Editar
                                </button>
                                <button class="btn btn-sm btn-danger fw-bold px-3" 
                                    onclick="eliminarUsuario('${usuario.idUsuario}')">
                                    Eliminar
                                </button>
                            </div>
                        </td>
                    </tr>`;
            });
            tablaHTML += `</tbody></table></div>`;
            datosMostrar.innerHTML = tablaHTML;
        });
}

// --- FUNCIONES DEL MODAL <DIALOG> ---
async function prepararEdicion(id, username, rol, estado) {
    // 1. Cargamos los roles primero y esperamos a que termine
    await cargarRolesEnSelect();

    // 2. Llenamos los campos
    document.getElementById('editId').value = id;
    document.getElementById('editUsername').value = username;

    // 3. Asignamos el rol (ahora que sabemos que las opciones existen)
    const selectRol = document.getElementById('editRol');
    selectRol.value = rol;

    document.getElementById('editEstado').value = estado.toString();

    // 4. Abrimos el modal
    if (editDialog) {
        editDialog.showModal();
    }
}

// Convertimos cargarRolesEnSelect en una función que devuelve una Promesa
async function cargarRolesEnSelect() {
    const selectRol = document.getElementById('editRol');
    if (!selectRol) return;

    try {
        const res = await fetch('/admin/verRoles');

        // Si el servidor responde 404 o error, lanzamos error para ir al catch
        if (!res.ok) throw new Error("Ruta no encontrada");

        const roles = await res.json();

        selectRol.innerHTML = "";
        roles.forEach(rol => {
            let option = document.createElement('option');
            option.value = rol.nombre;
            option.text = rol.nombre.toUpperCase();
            selectRol.appendChild(option);
        });
    } catch (err) {
        console.warn("Usando roles por defecto debido a error 404 en el servidor");
        // --- SOLUCIÓN MANUAL SI FALLA EL FETCH ---
        selectRol.innerHTML = `
            <option value="ADMIN">ADMIN</option>
            <option value="USER">USER</option>
        `;
    }
}

function enviarActualizacion(e) {
    e.preventDefault();
    const updatedUser = {
        idUsuario: document.getElementById('editId').value,
        username: document.getElementById('editUsername').value,
        nombreRol: document.getElementById('editRol').value,
        estado: document.getElementById('editEstado').value === 'true'
    };

    fetch('/admin/actualizarUsuario', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(updatedUser)
    })
        .then(res => {
            if(res.ok) {
                editDialog.close();
                location.reload();
            } else {
                alert("Error al actualizar");
            }
        });
}

// --- FUNCIONES DE APOYO (MANTENIDAS) ---
/*
function cargarRolesEnSelect() {
    fetch('/admin/verRoles')
        .then(res => res.json())
        .then(roles => {
            const selectRol = document.getElementById('editRol');
            if (!selectRol) return;
            selectRol.innerHTML = "";
            roles.forEach(rol => {
                let option = document.createElement('option');
                option.value = rol.nombre;
                option.text = rol.nombre.toUpperCase();
                selectRol.appendChild(option);
            });
        });
}
*/
function eliminarUsuario(id) {
    if(confirm('¿Estás seguro de eliminar este usuario?')) {
        fetch(`/admin/eliminarUsuario/${id}`, { method: 'DELETE' })
            .then(res => res.ok ? location.reload() : alert("Error al eliminar"));
    }
}

function actualizarEncabezado(titulo, subtitulo) {
    const hTitulo = document.getElementById("headerTitulo");
    const hSubtitulo = document.getElementById("headerSubtitulo");
    if(hTitulo) hTitulo.innerText = titulo;
    if(hSubtitulo) hSubtitulo.innerText = subtitulo;
}