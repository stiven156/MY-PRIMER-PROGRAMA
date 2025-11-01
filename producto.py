from Conexion import ConexionBD

class Producto:
    @staticmethod
    def agregar(nombre, tela, color, talla, precio, cantidad, lleva_3d, archivo):
        conexion = ConexionBD()
        cursor = conexion.cursor()
        cursor.execute("""
            INSERT INTO productos (nombre, tela, color, talla, precio, cantidad, lleva_3d, archivo)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """, (nombre, tela, color, talla, precio, cantidad, lleva_3d, archivo))
        conexion.commit()
        filas = cursor.rowcount
        conexion.close()
        return filas

    @staticmethod
    def listar():
        conexion = ConexionBD()
        cursor = conexion.cursor()
        cursor.execute("SELECT * FROM productos")
        filas = cursor.fetchall()
        conexion.close()
        return filas

    @staticmethod
    def eliminar(idp):
        conexion = ConexionBD()
        cursor = conexion.cursor()
        cursor.execute("DELETE FROM productos WHERE id=?", (idp,))
        conexion.commit()
        filas = cursor.rowcount
        conexion.close()
        return filas

    @staticmethod
    def modificar(idp, nombre, tela, color, talla, precio, cantidad, lleva_3d, archivo):
        conexion = ConexionBD()
        cursor = conexion.cursor()
        cursor.execute("""
            UPDATE productos
            SET nombre=?, tela=?, color=?, talla=?, precio=?, cantidad=?, lleva_3d=?, archivo=?
            WHERE id=?
        """, (nombre, tela, color, talla, precio, cantidad, lleva_3d, archivo, idp))
        conexion.commit()
        filas = cursor.rowcount
        conexion.close()
        return filas
