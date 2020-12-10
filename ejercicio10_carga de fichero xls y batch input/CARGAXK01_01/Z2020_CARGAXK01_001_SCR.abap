*&---------------------------------------------------------------------*
*&  Include           Z2020_CARGAXK01_00_00_SCR
*&---------------------------------------------------------------------*
* PANTALLA DE SELECCION
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.

* Parametros de seleccion
PARAMETERS: p_ruta TYPE string OBLIGATORY. " Ruta para cargar la BBDD con fichero

SELECTION-SCREEN END OF BLOCK b1.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_ruta.
  PERFORM ventana_busqueda.