*&---------------------------------------------------------------------*
*& Report Z2020_LISTAEQUIPOS_01
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z2020_listaequipos_01 MESSAGE-ID z2020_01_mensajes.

INCLUDE z2020_listaequipos_01_top.
INCLUDE z2020_listaequipos_01_scr.
INCLUDE z2020_listaequipos_01_sub.

AT SELECTION-SCREEN.

* Ruta obligatoria para carga y modificacion de BBDD
  IF ( r_opc3 IS NOT INITIAL OR r_opc4 IS NOT INITIAL ) AND
       p_ruta IS INITIAL. "Carga o modificacion de fichero + ruta vacía
    MESSAGE s004 DISPLAY LIKE 'E'.
  ENDIF.

  IF r_opc4 IS NOT INITIAL AND p_ruta IS INITIAL. "Carga de fichero + ruta vacía
    MESSAGE s004 DISPLAY LIKE 'E'.
  ENDIF.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_ruta.

  PERFORM ventana_busqueda.

* LOGICA PRINCIPAL
START-OF-SELECTION.

  PERFORM logica_principal.

END-OF-SELECTION.

  IF r_opc1 IS NOT INITIAL OR r_opc2 IS NOT INITIAL. "Salida pantalla o fichero
    IF gi_equipos[] IS INITIAL. "Si la tabla esta vacia
      MESSAGE s001.
    ELSE.
      PERFORM imprimir.
    ENDIF.
  ELSE. " Demas casos.
    " Si estoy en carga fichero
    PERFORM alv.
  ENDIF.