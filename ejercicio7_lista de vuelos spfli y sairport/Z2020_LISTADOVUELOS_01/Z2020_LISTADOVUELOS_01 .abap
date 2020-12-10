*&---------------------------------------------------------------------*
*& Report Z2020_LISTADOVUELOS_01
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z2020_listadovuelos_01.

INCLUDE z2020_listadovuelos_01_top.
INCLUDE z2020_listadovuelos_01_src.
INCLUDE z2020_listadovuelos_01_sub.

* LOGICA PRINCIPAL
START-OF-SELECTION.

  PERFORM logica_principal.

  IF r_opc1 IS NOT INITIAL.
    PERFORM imprimir_write.
  ELSE.
    PERFORM imprimir_alv.
  ENDIF.

END-OF-SELECTION.

  IF gi_salida[] IS INITIAL. " Si no hay datos
    MESSAGE s001(z2020_001_mensajes) DISPLAY LIKE 'E'.
  ENDI