from db import crear_conexion

def leer_texto_no_vacio(campo):
    while True:
        valor = input(f"{campo}: ").strip()
        if valor == "":
            print(f" El {campo.lower()} no puede estar vacío.")
        else:
            return valor

def leer_entero_positivo(campo):
    while True:
        valor = input(f"{campo}: ").strip()
        try:
            n = int(valor)
            if n <= 0:
                print(" Debe ser un número entero mayor a 0.")
            else:
                return n
        except ValueError:
            print(" Debe ingresar un número entero válido.")

def leer_entero_no_negativo(campo):
    while True:
        valor = input(f"{campo}: ").strip()
        try:
            n = int(valor)
            if n < 0:
                print("No puede ser negativo.")
            else:
                return n
        except ValueError:
            print(" Debe ingresar un número entero válido.")

def leer_float_positivo(campo):
    while True:
        valor = input(f"{campo}: ").strip()
        try:
            n = float(valor)
            if n <= 0:
                print(" El valor debe ser mayor a 0.")
            else:
                return n
        except ValueError:
            print(" Debe ingresar un número numérico válido.")

def existe_producto(id_producto):
    conexion = crear_conexion()
    cursor = conexion.cursor()
    cursor.execute(
        "SELECT COUNT(*) FROM productos WHERE id_producto = %s AND activo = 1",
        (id_producto,)
    )
    existe = cursor.fetchone()[0] > 0
    cursor.close()
    conexion.close()
    return existe

def agregar_producto():
    print("=== Alta de producto ===")
    nombre = leer_texto_no_vacio("Nombre")
    categoria = leer_texto_no_vacio("Categoria")
    precio = leer_float_positivo("Precio")
    stock = leer_entero_no_negativo("Stock")

    conexion = crear_conexion()
    cursor = conexion.cursor()

    cursor.callproc("agregar_producto", [nombre, categoria, precio, stock])
    conexion.commit()

    print("✔ Producto agregado.")
    cursor.close()
    conexion.close()


def actualizar_producto():
    print("=== Actualizar producto ===")
    id_p = leer_entero_positivo("ID del producto")

    if not existe_producto(id_p):
        print("El producto no existe o está inactivo.")
        return

    precio = leer_float_positivo("Nuevo precio")
    stock = leer_entero_no_negativo("Nuevo stock")

    conexion = crear_conexion()
    cursor = conexion.cursor()

    cursor.callproc("actualizar_producto", [id_p, precio, stock])
    conexion.commit()

    print("✔ Producto actualizado.")
    cursor.close()
    conexion.close()


def ver_productos():
    print("=== Lista de productos activos ===")
    conexion = crear_conexion()
    cursor = conexion.cursor()
    cursor.callproc("ver_productos")

    for result in cursor.stored_results():
        for row in result.fetchall():
            print(row)

    cursor.close()
    conexion.close()


def eliminar_producto():
    print("=== Eliminar producto (baja lógica) ===")
    id_p = leer_entero_positivo("ID del producto")

    if not existe_producto(id_p):
        print(" El producto no existe o ya está inactivo.")
        return

    conexion = crear_conexion()
    cursor = conexion.cursor()
    cursor.callproc("eliminar_producto", [id_p])
    conexion.commit()

    print("✔ Producto marcado como inactivo.")
    cursor.close()
    conexion.close()
