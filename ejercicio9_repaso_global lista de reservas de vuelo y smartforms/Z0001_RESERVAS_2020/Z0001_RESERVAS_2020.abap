*&---------------------------------------------------------------------*
*&  Include  Z0001_RESERVAS_2020
*&---------------------------------------------------------------------*
REPORT z0001_reservas_2020.

INCLUDE z0001_reservas_2020_top.
INCLUDE z0001_reservas_2020_src.
INCLUDE z0001_reservas_2020_sub.

* LOGICA PRINCIPAL
START-OF-SELECTION.

  PERFORM logica_principal.

END-OF-SELECTION.

  IF gi_salida[] IS INITIAL. " Si no hay datos
    MESSAGE s001(z2020_001_mensajes) DISPLAY LIKE 'E'.
  ENDIF.