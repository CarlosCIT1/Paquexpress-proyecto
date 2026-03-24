# Paquexpress App

Aplicación móvil desarrollada en Flutter para la gestión de entregas de paquetes, conectada a una API en FastAPI y una base de datos MySQL.

==================================================

## Repositorio del proyecto

El proyecto está dividido en tres partes principales:

Base de datos:
https://github.com/CarlosCIT1/Paquexpress-proyecto/tree/main/Database  

Backend (FastAPI):
https://github.com/CarlosCIT1/Paquexpress-proyecto/tree/main/backend-fastapi  

Aplicación Flutter:
https://github.com/CarlosCIT1/Paquexpress-proyecto/tree/main/app-flutter  

==================================================

## Instalación completa del proyecto

### 1. Clonar el repositorio

El proyecto ya incluye la base de datos, backend y aplicación Flutter dentro del mismo repositorio.

git clone https://github.com/CarlosCIT1/Paquexpress-proyecto.git
cd Paquexpress-proyecto

Nota:
No es necesario crear un proyecto Flutter nuevo, ya que la aplicación ya está incluida en la carpeta app-flutter.
Solo se deben instalar las dependencias y ejecutar el proyecto.

--------------------------------------------------

### Estructura del proyecto

- Database → contiene el script SQL de la base de datos  
- backend-fastapi → contiene la API desarrollada en FastAPI  
- app-flutter → contiene la aplicación móvil en Flutter  

--------------------------------------------------

### 2. Configuración de la Base de Datos (MySQL)

1. Crear la base de datos:

CREATE DATABASE paquexpress_db;

2. Acceder a la carpeta:

cd Database

3. Ejecutar el script SQL:

USE paquexpress_db;
SOURCE script.sql;

--------------------------------------------------

### 3. Configuración del Backend (FastAPI)

1. Acceder a la carpeta:

cd backend-fastapi

2. Instalar dependencias:

pip install fastapi uvicorn sqlalchemy pymysql "passlib[bcrypt]" "python-jose[cryptography]" python-multipart cryptography bcrypt==3.2.0 pydantic

3. Ejecutar el servidor:

uvicorn main:app --reload

4. Acceso:

API:
http://127.0.0.1:8000  

Swagger:
http://127.0.0.1:8000/docs  

--------------------------------------------------

### 4. Configuración de la Aplicación Flutter

1. Acceder a la carpeta:

cd app-flutter

2. Instalar dependencias:

flutter pub get

3. Ejecutar la app:

flutter run

==================================================

## Funcionalidades

- Inicio de sesión con autenticación JWT  
- Visualización de paquetes asignados  
- Captura de imagen como evidencia de entrega  
- Obtención de ubicación GPS  
- Visualización de mapa interactivo  
- Registro de entrega en base de datos  

==================================================

## Seguridad

- Contraseñas encriptadas con bcrypt  
- Autenticación mediante JWT  
- Protección de endpoints mediante token  
- Validación de usuario en el registro de entregas  

==================================================

## Evidencia de entrega

Cada entrega incluye:

- Imagen capturada desde la aplicación  
- Coordenadas GPS  
- Relación con el paquete y el usuario  

Las imágenes se almacenan en el servidor dentro de la carpeta /images.

==================================================

## Mapas

La aplicación utiliza flutter_map con OpenStreetMap para mostrar:

- Ubicación actual del usuario  
- Ubicación del destino  

También permite abrir la dirección en Google Maps externamente.

==================================================

## Notas importantes

- La API debe estar en ejecución antes de usar la app  
- La URL del backend puede modificarse en api_service.dart  
- Proyecto desarrollado con fines académicos  

==================================================

## Autor

Proyecto desarrollado para la materia  
Análisis y Diseño de Software  
