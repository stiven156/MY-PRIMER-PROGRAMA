import tkinter as tk
from tkinter import *
from tkinter import ttk, filedialog, messagebox
import os
import shutil
from producto import Producto

def app():
    base = Tk()
    base.title("Inventario de Ropa - Tu Marca")
    base.state('zoomed')  # 🟩 Abre la ventana en pantalla completa
    base.resizable(True, True)

    # Variables
    var_3d = StringVar(value="No")
    archivo_nombre = StringVar()
    archivo_ruta = ""

    # Crear carpeta donde se guardarán los archivos
    carpeta_archivos = "archivos"
    if not os.path.exists(carpeta_archivos):
        os.makedirs(carpeta_archivos)

    # --- CAMPOS DE ENTRADA ---
    Label(base, text="NOMBRE:", font=("Arial", 12, "bold")).place(x=50, y=40)
    entry_nombre = Entry(base, font=("Arial", 11))
    entry_nombre.place(x=180, y=40, width=250)

    Label(base, text="TELA:", font=("Arial", 12, "bold")).place(x=500, y=40)
    entry_tela = Entry(base, font=("Arial", 11))
    entry_tela.place(x=580, y=40, width=200)

    Label(base, text="COLOR:", font=("Arial", 12, "bold")).place(x=50, y=90)
    entry_color = Entry(base, font=("Arial", 11))
    entry_color.place(x=180, y=90, width=200)

    Label(base, text="TALLA:", font=("Arial", 12, "bold")).place(x=500, y=90)
    entry_talla = Entry(base, font=("Arial", 11))
    entry_talla.place(x=580, y=90, width=150)

    Label(base, text="PRECIO:", font=("Arial", 12, "bold")).place(x=50, y=140)
    entry_precio = Entry(base, font=("Arial", 11))
    entry_precio.place(x=180, y=140, width=120)

    Label(base, text="CANTIDAD:", font=("Arial", 12, "bold")).place(x=500, y=140)
    entry_cantidad = Entry(base, font=("Arial", 11))
    entry_cantidad.place(x=630, y=140, width=100)

    Label(base, text="LLEVA 3D:", font=("Arial", 12, "bold")).place(x=50, y=190)
    Radiobutton(base, text="Sí", variable=var_3d, value="Sí", font=("Arial", 11)).place(x=180, y=190)
    Radiobutton(base, text="No", variable=var_3d, value="No", font=("Arial", 11)).place(x=230, y=190)

    Label(base, text="ARCHIVO:", font=("Arial", 12, "bold")).place(x=500, y=190)
    entry_archivo = Entry(base, textvariable=archivo_nombre, state="readonly", font=("Arial", 11), width=40)
    entry_archivo.place(x=600, y=190)

    # --- SELECCIONAR ARCHIVO ---
    def seleccionar_archivo():
        nonlocal archivo_ruta
        ruta = filedialog.askopenfilename(title="Seleccionar archivo")
        if ruta:
            archivo_ruta = ruta
            nombre_archivo = os.path.basename(ruta)  # solo el nombre
            archivo_nombre.set(nombre_archivo)

    Button(base, text="Examinar", command=seleccionar_archivo, font=("Arial", 10, "bold"), bg="#e0e0e0").place(x=1000, y=185)

    # --- FUNCIONES ---
    def limpiar():
        entry_nombre.delete(0, END)
        entry_tela.delete(0, END)
        entry_color.delete(0, END)
        entry_talla.delete(0, END)
        entry_precio.delete(0, END)
        entry_cantidad.delete(0, END)
        archivo_nombre.set("")
        var_3d.set("No")

    def guardar():
        try:
            if archivo_nombre.get():
                destino = os.path.join(carpeta_archivos, archivo_nombre.get())
                if not os.path.exists(destino):
                    shutil.copy2(archivo_ruta, destino)
            else:
                destino = ""

            Producto.agregar(
                entry_nombre.get(),
                entry_tela.get(),
                entry_color.get(),
                entry_talla.get(),
                float(entry_precio.get() or 0),
                int(entry_cantidad.get() or 0),
                var_3d.get(),
                archivo_nombre.get()
            )
            listar()
            limpiar()
            messagebox.showinfo("Éxito", "Producto guardado correctamente.")
        except Exception as e:
            messagebox.showerror("Error", str(e))

    def eliminar():
        seleccionado = tree.selection()
        if not seleccionado:
            messagebox.showwarning("Atención", "Seleccione un producto.")
            return
        idp = tree.item(seleccionado)["values"][0]
        if messagebox.askyesno("Confirmar", "¿Desea eliminar este producto?"):
            Producto.eliminar(idp)
            listar()

    # --- ABRIR O DESCARGAR ARCHIVO ---
    def abrir_o_descargar(event):
        seleccionado = tree.selection()
        if not seleccionado:
            return
        datos = tree.item(seleccionado)["values"]
        nombre_archivo = datos[8]
        ruta_archivo = os.path.join(carpeta_archivos, nombre_archivo)

        if not nombre_archivo:
            messagebox.showwarning("Atención", "Este producto no tiene archivo asociado.")
            return

        if os.path.exists(ruta_archivo):
            opcion = messagebox.askquestion(
                "Archivo encontrado",
                f"¿Qué deseas hacer con '{nombre_archivo}'?\n\nSí = Abrir\nNo = Descargar copia"
            )
            if opcion == "yes":
                os.startfile(ruta_archivo)
            else:
                destino = filedialog.asksaveasfilename(initialfile=nombre_archivo)
                if destino:
                    shutil.copy2(ruta_archivo, destino)
                    messagebox.showinfo("Éxito", f"Archivo guardado en:\n{destino}")
        else:
            messagebox.showerror("Error", f"El archivo '{nombre_archivo}' no se encuentra en la carpeta local.")

    # --- BOTONES ---
    Button(base, text="GUARDAR", width=15, command=guardar, bg="#c8e6c9", font=("Arial", 11, "bold")).place(x=50, y=240)
    Button(base, text="ELIMINAR", width=15, command=eliminar, bg="#ffcdd2", font=("Arial", 11, "bold")).place(x=220, y=240)
    Button(base, text="LIMPIAR", width=15, command=limpiar, bg="#bbdefb", font=("Arial", 11, "bold")).place(x=390, y=240)

    # --- TABLA ---
    frame_tabla = Frame(base)
    frame_tabla.place(x=50, y=300, relwidth=0.9, relheight=0.6)

    columnas = ("ID", "Nombre", "Tela", "Color", "Talla", "Precio", "Cantidad", "3D", "Archivo")
    tree = ttk.Treeview(frame_tabla, columns=columnas, show="headings")

    estilos = ttk.Style()
    estilos.configure("Treeview.Heading", font=("Arial", 11, "bold"))
    estilos.configure("Treeview", font=("Arial", 10), rowheight=28)

    for col in columnas:
        ancho = 140 if col != "Archivo" else 200
        tree.heading(col, text=col)
        tree.column(col, width=ancho, anchor=CENTER)

    tree.pack(fill=BOTH, expand=True)
    tree.bind("<Double-1>", abrir_o_descargar)

    def listar():
        for item in tree.get_children():
            tree.delete(item)
        for fila in Producto.listar():
            tree.insert("", END, values=fila)

    listar()
    base.mainloop()

if __name__ == "__main__":
    app()
