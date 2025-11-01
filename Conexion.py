import sqlite3

def ConexionBD():
    conexion = sqlite3.connect("inventario_ropa.db")
    cursor = conexion.cursor()

    # Crear tabla si no existe
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS productos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT NOT NULL,
            tela TEXT,
            color TEXT,
            talla TEXT,
            precio REAL,
            cantidad INTEGER,
            lleva_3d TEXT,
            archivo TEXT
        )
    """)
    conexion.commit()
    return conexion
