*&---------------------------------------------------------------------*
*&  Include           Z2020_LISTAEQUIPOS_01_SCR
*&---------------------------------------------------------------------*

* PANTALLA DE SELECCION
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.

PARAMETERS:     p_ruta TYPE string. " Ruta para cargar la BBDD con fichero
SELECT-OPTIONS: s_matr FOR z2020_equipos_01-equipo. "Rangos

SELECTION-SCREEN END OF BLOCK b1.

* Datos de salida / Tratamiento BBDD
SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-002.
PARAMETERS: r_opc1 RADIOBUTTON GROUP gr1, "Salida por pantalla
            r_opc2 RADIOBUTTON GROUP gr1, "Salida por fichero
            r_opc3 RADIOBUTTON GROUP gr1, "Cargar tabla
            r_opc4 RADIOBUTTON GROUP gr1, "Modificar Tabla
            r_opc5 RADIOBUTTON GROUP gr1. "Borrar tabla
SELECTION-SCREEN END OF BLOCK b2.