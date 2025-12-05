import os
import productos
import clientes
import ordenes
import reportes


# --------------------------------------------------------
#   FUNCIONES ÚTILES
# --------------------------------------------------------

def limpiar_pantalla():
    os.system("cls" if os.name == "nt" else "clear")


def pausar():
    input("\nPresiona ENTER para continuar...")


# --------------------------------------------------------
#   REALIZAR COMPRA
# --------------------------------------------------------

def realizar_compra():
    limpiar_pantalla()
    print("=== Nueva Compra ===")

    id_cliente_txt = input("ID del cliente: ").strip()
    if not id_cliente_txt.isdigit() or int(id_cliente_txt) <= 0:
        print(" ID inválido.")
        pausar()
        return

    id_cliente = int(id_cliente_txt)

    # Crear la orden
    id_orden = ordenes.crear_orden(id_cliente)

    if id_orden is None:
        print("\n El cliente no existe. No se pudo crear la orden.")
        pausar()
        return

    print(f"\n✔ Orden creada con ID: {id_orden}")

    while True:
        print("\n--- Agregar productos a la orden ---")
        print("1. Agregar producto")
        print("2. Finalizar compra")
        print("0. Cancelar")

        op = input("Opción: ")

        if op == "1":
            id_prod_txt = input("ID del producto: ").strip()
            if not id_prod_txt.isdigit() or int(id_prod_txt) <= 0:
                print(" ID de producto inválido.")
                continue

            cant_txt = input("Cantidad: ").strip()
            if not cant_txt.isdigit() or int(cant_txt) <= 0:
                print(" La cantidad debe ser un número entero mayor a 0.")
                continue

            id_prod = int(id_prod_txt)
            cant = int(cant_txt)

            try:
                ordenes.agregar_item(id_orden, id_prod, cant)
                print("✔ Producto agregado.")
            except Exception as e:
                print(" Error:", e)

        elif op == "2":
            ordenes.confirmar_orden(id_orden)
            print("\n Compra finalizada y marcada como PAGADA.")
            pausar()
            break

        elif op == "0":
            print("Compra cancelada.")
            pausar()
            break

        else:
            print(" Opción inválida.")
            pausar()


# --------------------------------------------------------
#   VER ÓRDENES POR CLIENTE
# --------------------------------------------------------

def op_ordenes_cliente():
    limpiar_pantalla()
    id_txt = input("ID del cliente: ").strip()
    if not id_txt.isdigit() or int(id_txt) <= 0:
        print(" ID inválido.")
        pausar()
        return

    idc = int(id_txt)
    datos = ordenes.ver_ordenes_cliente(idc)

    print("\n--- Órdenes del cliente ---")
    if not datos:
        print("No hay órdenes para este cliente.")
    else:
        for row in datos:
            print(row)

    pausar()


# --------------------------------------------------------
#   MENÚ PRINCIPAL
# --------------------------------------------------------

def menu():
    while True:
        limpiar_pantalla()
        print("===== PLATAFORMA DE VENTAS =====")
        print("1. Gestión de Productos")
        print("2. Gestión de Clientes")
        print("3. Realizar Compra")
        print("4. Órdenes por cliente")
        print("5. Búsquedas avanzadas")
        print("6. Producto más vendido")
        print("0. Salir")

        op = input("\nOpción: ")

        if op == "1":
            menu_productos()
        elif op == "2":
            menu_clientes()
        elif op == "3":
            realizar_compra()
        elif op == "4":
            op_ordenes_cliente()
        elif op == "5":
            menu_busquedas()
        elif op == "6":
            limpiar_pantalla()
            reportes.producto_mas_vendido()
            pausar()
        elif op == "0":
            limpiar_pantalla()
            print("Gracias por usar el sistema. ¡Hasta luego!")
            break
        else:
            print("Opción inválida.")
            pausar()


# --------------------------------------------------------
#   SUBMENÚS
# --------------------------------------------------------

def menu_productos():
    while True:
        limpiar_pantalla()
        print("--- Gestión de Productos ---")
        print("1. Agregar producto")
        print("2. Actualizar producto")
        print("3. Ver productos")
        print("4. Eliminar producto")
        print("0. Volver al menú principal")

        op = input("\nOpción: ")

        if op == "1":
            limpiar_pantalla()
            productos.agregar_producto()
            pausar()
        elif op == "2":
            limpiar_pantalla()
            productos.actualizar_producto()
            pausar()
        elif op == "3":
            limpiar_pantalla()
            productos.ver_productos()
            pausar()
        elif op == "4":
            limpiar_pantalla()
            productos.eliminar_producto()
            pausar()
        elif op == "0":
            break
        else:
            print(" Opción inválida.")
            pausar()


def menu_clientes():
    while True:
        limpiar_pantalla()
        print("--- Gestión de Clientes ---")
        print("1. Registrar cliente")
        print("2. Actualizar cliente")
        print("3. Ver clientes")
        print("0. Volver al menú principal")

        op = input("\nOpción: ")

        if op == "1":
            limpiar_pantalla()
            clientes.agregar_cliente()
            pausar()
        elif op == "2":
            limpiar_pantalla()
            clientes.actualizar_cliente()
            pausar()
        elif op == "3":
            limpiar_pantalla()
            clientes.ver_clientes()
            pausar()
        elif op == "0":
            break
        else:
            print(" Opción inválida.")
            pausar()


def menu_busquedas():
    while True:
        limpiar_pantalla()
        print("--- Búsquedas Avanzadas ---")
        print("1. Buscar producto")
        print("2. Buscar cliente")
        print("0. Volver al menú principal")

        op = input("\nOpción: ")

        if op == "1":
            limpiar_pantalla()
            reportes.buscar_producto()
            pausar()
        elif op == "2":
            limpiar_pantalla()
            reportes.buscar_cliente()
            pausar()
        elif op == "0":
            break
        else:
            print(" Opción inválida.")
            pausar()


# --------------------------------------------------------
#   EJECUCIÓN DEL PROGRAMA
# --------------------------------------------------------

if __name__ == "__main__":
    menu()

