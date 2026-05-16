# CLAUDE.md — Inventario de Ropa

## Project overview

Desktop inventory management application for a clothing business. Built with Python + tkinter for the GUI and SQLite for persistence. Can be compiled to a standalone Windows executable via PyInstaller.

## Repository structure

```
MY-PRIMER-PROGRAMA/
├── InventarioRopa.py      # Main entry point — GUI definition and event handlers
├── producto.py            # Producto class — all CRUD operations against the DB
├── Conexion.py            # DB connection factory and schema bootstrap
├── InventarioRopa.spec    # PyInstaller build spec (produces dist/InventarioRopa.exe)
├── inventario_ropa.db     # SQLite database (committed; created automatically if missing)
├── archivos/              # User-uploaded files attached to products (e.g. images)
├── dist/                  # PyInstaller output — the .exe lives here
└── build/                 # PyInstaller intermediate build artifacts (do not edit)
```

## Architecture

Three-layer, no framework:

```
InventarioRopa.py   →   producto.py   →   Conexion.py   →   inventario_ropa.db
    (GUI)               (model/CRUD)       (DB factory)        (SQLite file)
```

- **`Conexion.py`** — `ConexionBD()` opens a new SQLite connection and ensures the `productos` table exists before returning the connection. Called once per operation.
- **`producto.py`** — `Producto` class with four `@staticmethod` methods: `agregar`, `listar`, `eliminar`, `modificar`. Each opens a connection, runs one query, commits/closes, and returns the result.
- **`InventarioRopa.py`** — Single `app()` function that builds the entire tkinter window. All widgets are positioned with absolute coordinates via `.place(x=, y=)`. Inner functions (`guardar`, `eliminar`, `limpiar`, `listar`, `seleccionar_archivo`, `abrir_o_descargar`) close over widget variables.

## Database schema

Table: `productos`

| Column     | Type    | Notes                          |
|------------|---------|--------------------------------|
| id         | INTEGER | Primary key, autoincrement     |
| nombre     | TEXT    | Product name, NOT NULL         |
| tela       | TEXT    | Fabric type                    |
| color      | TEXT    |                                |
| talla      | TEXT    | Size                           |
| precio     | REAL    | Price                          |
| cantidad   | INTEGER | Stock count                    |
| lleva_3d   | TEXT    | "Sí" or "No"                   |
| archivo    | TEXT    | Filename only (stored in archivos/) |

The DB file (`inventario_ropa.db`) is created on first run if absent. The schema is applied via `CREATE TABLE IF NOT EXISTS` in `ConexionBD()`.

## Running the application

```bash
python InventarioRopa.py
```

Requires Python 3 with tkinter (included in standard Windows Python installers). No third-party pip packages at runtime.

## Building the Windows executable

```bash
pyinstaller InventarioRopa.spec
```

Output: `dist/InventarioRopa.exe` — a single-file, no-console Windows executable. The `archivos/` folder and `inventario_ropa.db` must exist alongside the .exe at runtime since they are not embedded.

## Key conventions

- **Absolute positioning**: All widgets use `.place(x=, y=)`. When adding new UI elements, match the existing coordinate grid (form rows at y=40, 90, 140, 190, 240; table starts at y=300).
- **DB connections**: Open a fresh connection per operation via `ConexionBD()` — there is no persistent connection object or ORM. Always close after use.
- **File handling**: Only the filename (not the full path) is stored in the DB. The actual file is copied to `archivos/` on save. Use `os.path.join(carpeta_archivos, nombre_archivo)` to resolve it at runtime.
- **No input validation layer**: `precio` and `cantidad` are cast with `float()`/`int()` directly in the GUI; empty strings fall back to `0`. Add validation here if stricter rules are needed.
- **Language**: All UI strings and variable names are in Spanish.
- **`modificar` is implemented but unused**: `Producto.modificar()` exists in `producto.py` but the GUI has no edit flow yet. The next natural feature addition is an in-place edit mode triggered by selecting a row.

## Known limitations / future work

- No edit (update) UI — `Producto.modificar()` is ready but not wired up.
- `os.startfile()` in `abrir_o_descargar` is Windows-only; running on Linux/macOS will raise `AttributeError`.
- The DB path is hard-coded as a relative path (`"inventario_ropa.db"`), so the app must be launched from its own directory.
- No search or filter on the product table.
- File attachments are not embedded in the executable; distributing the app requires shipping the `archivos/` folder separately.
