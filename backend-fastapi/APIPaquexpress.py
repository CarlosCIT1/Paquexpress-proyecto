from fastapi import FastAPI, UploadFile, File, Form, Depends
from sqlalchemy import create_engine, Column, Integer, String, ForeignKey, DECIMAL, Enum
from sqlalchemy.orm import sessionmaker, declarative_base, Session
from passlib.context import CryptContext
from jose import jwt
from fastapi.middleware.cors import CORSMiddleware
from datetime import datetime, timedelta
import shutil
import os
import time

# CONFIGURACION
# =========================
DATABASE_URL = "mysql+pymysql://root:password@localhost/paquexpress_db"

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

# carpeta de imágenes
if not os.path.exists("images"):
    os.makedirs("images")

# MODELOS
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
    descripcion = Column(String(255))
    estado = Column(Enum('pendiente', 'entregado'))
    usuario_id = Column(Integer, ForeignKey("usuarios.id"))


class Entrega(Base):
    __tablename__ = "entregas"

    id = Column(Integer, primary_key=True, index=True)
    paquete_id = Column(Integer, ForeignKey("paquetes.id"))
    foto_ruta = Column(String(255))
    latitud = Column(DECIMAL(10,8))
    longitud = Column(DECIMAL(11,8))


Base.metadata.create_all(bind=engine)

# SEGURIDAD
# =========================
pwd_context = CryptContext(schemes=["bcrypt"])

SECRET_KEY = "secret123"
ALGORITHM = "HS256"

def hash_password(password: str):
    return pwd_context.hash(password)

def verify_password(plain, hashed):
    return pwd_context.verify(plain, hashed)

def create_token(data: dict):
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(hours=2)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

# DEPENDENCIA DB
# =========================
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# =========================
# ENDPOINTS
# =========================

# REGISTRO (para pruebas)
@app.post("/register")
def register(username: str, password: str, db: Session = Depends(get_db)):
    hashed = hash_password(password)

    nuevo = Usuario(username=username, password=hashed)
    db.add(nuevo)
    db.commit()

    return {"msg": "Usuario creado"}

# LOGIN
@app.post("/login")
def login(username: str, password: str, db: Session = Depends(get_db)):
    user = db.query(Usuario).filter(Usuario.username == username).first()

    if not user:
        return {"error": "Usuario no encontrado"}

    if not verify_password(password, user.password):
        return {"error": "Contraseña incorrecta"}

    token = create_token({"sub": user.username})

    return {"access_token": token}

# OBTENER PAQUETES
@app.get("/paquetes")
def get_paquetes(db: Session = Depends(get_db)):
    return db.query(Paquete).all()

# GUARDAR ENTREGA
@app.post("/entrega")
def crear_entrega(
    paquete_id: int = Form(...),
    latitud: float = Form(...),
    longitud: float = Form(...),
    foto: UploadFile = File(...),
    db: Session = Depends(get_db)
):
    paquete = db.query(Paquete).get(paquete_id)

    if not paquete:
        return {"error": "Paquete no existe"}

    file_path = f"images/{int(time.time())}_{foto.filename}"

    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(foto.file, buffer)

    nueva = Entrega(
        paquete_id=paquete_id,
        foto_ruta=file_path,
        latitud=latitud,
        longitud=longitud
    )

    db.add(nueva)

    paquete.estado = "entregado"

    db.commit()

    return {"msg": "Entrega guardada correctamente"}
