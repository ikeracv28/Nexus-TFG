const saludoUsuario = document.getElementById("saludoUsuario");
const datosMostrar = document.getElementById("datosMostrar");
const btnSalir = document.getElementById("btnSalir");
const btnVerUsuarios = document.getElementById("btnVerUsuarios");


// Cerrar Sesión
btnSalir.addEventListener("click", () => {
    window.location.href = '/killSession';
});




// Obtener datos del usuario logueado
fetch('/user/datos', {})
    .then((response) => {
        if (response.ok) return response.json();
        throw new Error("Error al obtener datos");
    })
    .then((data) => {
        // --- EFECTO DE BIENVENIDA ---
        saludoUsuario.style.opacity = "0";
        saludoUsuario.innerHTML = `Bienvenido de nuevo, <span class="text-primary">${data.username}</span>`;

        setTimeout(() => {
            saludoUsuario.style.transition = "opacity 0.8s ease-in-out";
            saludoUsuario.style.opacity = "1";
        }, 100);

        // --- GENERACIÓN DE TABLA ---
        const fecha = data.fechaCreacion ? new Date(data.fechaCreacion).toLocaleDateString() : '-';

        datosMostrar.innerHTML = `
        <div class="table-container">
            <table class="table table-hover align-middle">
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
                        <td><span class="badge bg-primary">${data.nombreRol}</span></td>
                        <td class="text-muted">${fecha}</td>
                    </tr>
                </tbody>
            </table>
        </div>
    `;
    })
    .catch((error) => {
        console.error("Fallo al cargar datos:", error);
        datosMostrar.innerHTML = `<div class="alert alert-danger">Error al cargar la información del perfil.</div>`;
    });