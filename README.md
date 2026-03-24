# Paquexpress App

Aplicación móvil desarrollada en Flutter para la gestión de entregas de paquetes, conectada a una API en FastAPI y una base de datos MySQL.

==================================================

## Instalación completa del proyecto

==================================================

## 1. Base de Datos (MySQL)

1. Abrir MySQL Workbench o consola de MySQL.

2. Crear la base de datos:

CREATE DATABASE paquexpress_db;

3. Seleccionar la base de datos:

USE paquexpress_db;

4. Ir al repositorio y abrir el archivo:

Database/DBscript.sql

5. Copiar TODO el contenido del archivo y pegarlo en MySQL.

6. Ejecutar el script para crear las tablas.

--------------------------------------------------

## 2. Backend (FastAPI)

1. Ir a la carpeta del backend:

backend-fastapi

2. Instalar dependencias:

pip install fastapi uvicorn sqlalchemy pymysql "passlib[bcrypt]" "python-jose[cryptography]" python-multipart cryptography bcrypt==3.2.0 pydantic

3. Verificar configuración de la base de datos en el archivo apiPaquexpress.py:

DATABASE_URL = "mysql+pymysql://root:TU_PASSWORD@localhost/paquexpress_db"

Cambiar TU_PASSWORD por la contraseña de MySQL.

4. Ejecutar el servidor:

uvicorn apiPaquexpress:app --reload

5. Verificar funcionamiento:

API:
http://127.0.0.1:8000  

Swagger:
http://127.0.0.1:8000/docs  

--------------------------------------------------

## 3. Aplicación Flutter

1. Ir a la carpeta del proyecto:

cd app-flutter

2. Instalar dependencias:

flutter pub get

Dependencias utilizadas:
- http
- image_picker
- geolocator
- shared_preferences
- flutter_map
- latlong2
- url_launcher
- flutter_map_cancellable_tile_provider

3. Ejecutar la aplicación:

flutter run

--------------------------------------------------

## Importante

- El backend debe estar corriendo antes de iniciar la app.
- La URL de la API se encuentra en api_service.dart:

const baseUrl = "http://127.0.0.1:8000";

Si se usa dispositivo físico, cambiar por la IP del equipo.

==================================================

## Funcionalidades

- Inicio de sesión con JWT
- Consulta de paquetes asignados
- Captura de imagen como evidencia
- Obtención de ubicación GPS
- Visualización de mapa
- Registro de entrega en base de datos

==================================================

## Seguridad

- Encriptación de contraseñas con bcrypt
- Autenticación con JWT
- Validación de usuario en endpoints protegidos

==================================================
