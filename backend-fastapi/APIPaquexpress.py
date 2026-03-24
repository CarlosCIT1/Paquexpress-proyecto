from fastapi import FastAPI, UploadFile, File, Form, Depends, HTTPException
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from fastapi.staticfiles import StaticFiles
from sqlalchemy import create_engine, Column, Integer, String, ForeignKey, DECIMAL, Enum, Text
from sqlalchemy.orm import sessionmaker, declarative_base, Session
from passlib.context import CryptContext
from jose import jwt
from fastapi.middleware.cors import CORSMiddleware
from datetime import datetime, timedelta
from pydantic import BaseModel
import shutil
import os
import time

# =========================
# CONFIGURACION
# =========================
DATABASE_URL = "mysql+pymysql://root:tele2006s@localhost/paquexpress_db"

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(bind=engine)
Base = declarative_base()

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Carpeta de imágenes
if not os.path.exists("images"):
    os.makedirs("images")

app.mount("/images", StaticFiles(directory="images"), name="images")

# =========================
# MODELOS SQLAlchemy
# =========================
class Usuario(Base):
    __tablename__ = "usuarios"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String(50), unique=True)
    password = Column(String(255))

class Paquete(Base):
    __tablename__ = "paquetes"

    id = Column(Integer, primary_key=True, index=True)
    direccion = Column(String(255))
    descripcion = Column(Text)
    estado = Column(Enum('pendiente', 'entregado'))
    usuario_id = Column(Integer, ForeignKey("usuarios.id"))

class Entrega(Base):
    __tablename__ = "entregas"

    id = Column(Integer, primary_key=True, index=True)
    paquete_id = Column(Integer, ForeignKey("paquetes.id"))
    usuario_id = Column(Integer, ForeignKey("usuarios.id"))
    foto_ruta = Column(String(255))
    latitud = Column(DECIMAL(10,8))
    longitud = Column(DECIMAL(11,8))

Base.metadata.create_all(bind=engine)

# =========================
# SEGURIDAD
# =========================
pwd_context = CryptContext(schemes=["bcrypt"])
SECRET_KEY = "secret123"
ALGORITHM = "HS256"
security = HTTPBearer()

def hash_password(password: str):
    return pwd_context.hash(password)

def verify_password(plain, hashed):
    return pwd_context.verify(plain, hashed)

def create_token(data: dict):
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(hours=2)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

def verify_token(credentials: HTTPAuthorizationCredentials = Depends(security)):
    token = credentials.credentials
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return payload
    except:
        raise HTTPException(status_code=401, detail="Token inválido")

# =========================
# DEPENDENCIA DB
# =========================
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# =========================
# MODELOS Pydantic
# =========================
class LoginRequest(BaseModel):
    username: str
    password: str

class RegisterRequest(BaseModel):
    username: str
    password: str

# =========================
# ENDPOINTS
# =========================
@app.post("/register")
def register(data: RegisterRequest, db: Session = Depends(get_db)):
    hashed = hash_password(data.password)
    nuevo = Usuario(username=data.username, password=hashed)
    db.add(nuevo)
    db.commit()
    return {"msg": "Usuario creado"}

@app.post("/login")
def login(data: LoginRequest, db: Session = Depends(get_db)):
    user = db.query(Usuario).filter(Usuario.username == data.username).first()

    if not user:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")

    if not verify_password(data.password, user.password):
        raise HTTPException(status_code=401, detail="Contraseña incorrecta")

    token = create_token({"sub": user.username})
    return {
        "access_token": token,
        "user_id": user.id
    }

@app.get("/paquetes")
def get_paquetes(
    user=Depends(verify_token),
    db: Session = Depends(get_db)
):
    username = user["sub"]
    usuario = db.query(Usuario).filter(Usuario.username == username).first()

    resultados = db.query(Paquete, Usuario.username)\
        .join(Usuario, Paquete.usuario_id == Usuario.id)\
        .filter(Paquete.usuario_id == usuario.id)\
        .all()

    respuesta = []

    for paquete, nombre_usuario in resultados:
        entrega = db.query(Entrega).filter(
            Entrega.paquete_id == paquete.id
        ).first()

        imagen = None
        if entrega:
            imagen = f"http://127.0.0.1:8000/{entrega.foto_ruta}"

        respuesta.append({
            "id": paquete.id,
            "direccion": paquete.direccion,
            "descripcion": paquete.descripcion,
            "estado": paquete.estado,
            "usuario_id": paquete.usuario_id,
            "agente": nombre_usuario,
            "imagen": imagen
        })

    return respuesta

@app.post("/entrega")
def crear_entrega(
    user=Depends(verify_token),
    paquete_id: int = Form(...),
    usuario_id: int = Form(...),
    latitud: float = Form(...),
    longitud: float = Form(...),
    foto: UploadFile = File(...),
    db: Session = Depends(get_db)
):
    username = user["sub"]
    usuario = db.query(Usuario).filter(Usuario.username == username).first()

    #  Validar que el usuario del token sea el mismo que envía
    if usuario.id != usuario_id:
        raise HTTPException(status_code=403, detail="Acceso no permitido")

    paquete = db.query(Paquete).get(paquete_id)
    if not paquete:
        raise HTTPException(status_code=404, detail="Paquete no existe")

    file_path = f"images/{int(time.time())}_{foto.filename}"
    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(foto.file, buffer)

    nueva = Entrega(
        paquete_id=paquete_id,
        usuario_id=usuario_id,
        foto_ruta=file_path,
        latitud=latitud,
        longitud=longitud
    )

    db.add(nueva)
    paquete.estado = "entregado"
    db.commit()

    return {"msg": "Entrega guardada correctamente"}
