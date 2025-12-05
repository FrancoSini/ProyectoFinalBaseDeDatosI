from db import crear_conexion


def leer_texto_no_vacio(campo):
    while True:
        valor = input(f"{campo}: ").strip()
        if valor == "":
            print(f" El {campo.lower()} no puede estar vacío.")
        else:
            return valor

def leer_email():
    while True:
        email = input("Email: ").strip()
        if "@" not in email or "." not in email:
            print(" Email no válido.")
        else:
            return email

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

def existe_cliente(id_cliente):
    conexion = crear_conexion()
    cursor = conexion.cursor()
    cursor.execute(
        "SELECT COUNT(*) FROM clientes WHERE id_cliente = %s AND activo = 1",
        (id_cliente,)
    )
    existe = cursor.fetchone()[0] > 0
    cursor.close()
    conexion.close()
    return existe


def agregar_cliente():
    print("=== Alta de cliente ===")
    nombre = leer_texto_no_vacio("Nombre")
    apellido = leer_texto_no_vacio("Apellido")
    email = leer_email()
    telefono = leer_texto_no_vacio("Telefono")
    direccion = leer_texto_no_vacio("Direccion")

    conexion = crear_conexion()
    cursor = conexion.cursor()

    cursor.callproc("agregar_cliente",
                    [nombre, apellido, email, telefono, direccion])
    conexion.commit()

    print(" Cliente registrado.")
    cursor.close()
    conexion.close()


def actualizar_cliente():
    print("=== Actualizar cliente ===")
    id_c = leer_entero_positivo("ID del cliente")

    if not existe_cliente(id_c):
        print(" El cliente no existe o está inactivo.")
        return

    telefono = leer_texto_no_vacio("Nuevo telefono")
    direccion = leer_texto_no_vacio("Nueva direccion")

    conexion = crear_conexion()
    cursor = conexion.cursor()

    cursor.callproc("actualizar_cliente", [id_c, telefono, direccion])
    conexion.commit()

    print("✔ Cliente actualizado.")
    cursor.close()
    conexion.close()


def ver_clientes():
    print("=== Lista de clientes activos ===")
    conexion = crear_conexion()
    cursor = conexion.cursor()
    cursor.callproc("ver_clientes")

    for result in cursor.stored_results():
        for row in result.fetchall():
            print(row)

    cursor.close()
    conexion.close()
