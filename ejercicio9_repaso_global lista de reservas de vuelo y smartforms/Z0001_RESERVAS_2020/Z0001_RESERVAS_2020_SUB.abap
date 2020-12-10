*&---------------------------------------------------------------------*
*&  Include           Z0001_RESERVAS_2020_SUB
*&---------------------------------------------------------------------*


FORM logica_principal.

*1 PASO: Crear tablas y estructura sin cabecera.
  TYPES: BEGIN OF lt_scarr,
           carrid   LIKE scarr-carrid,
           carrname LIKE scarr-carrname,
         END OF lt_scarr.

  DATA: li_scarr TYPE STANDARD TABLE OF lt_scarr,
        ls_scarr TYPE lt_scarr.

  TYPES: BEGIN OF lt_sflight,
           carrid     LIKE sflight-carrid,
           connid     LIKE sflight-connid,
           fldate     LIKE sflight-fldate,
           seatsmax   LIKE sflight-seatsmax,
           seatsmax_b LIKE sflight-seatsmax_b,
           seatsmax_f LIKE sflight-seatsmax_f,
           seatsocc   LIKE sflight-seatsocc,
           seatsocc_b LIKE sflight-seatsocc_b,
           seatsocc_f LIKE sflight-seatsocc_f,
         END OF lt_sflight.

  DATA: li_sflight TYPE STANDARD TABLE OF lt_sflight,
        ls_sflight TYPE lt_sflight.

  TYPES: BEGIN OF lt_snvoice,
           carrid   LIKE snvoice-carrid,
           bookid   LIKE snvoice-bookid,
           customid LIKE snvoice-customid,
           instno   LIKE snvoice-instno,
           amount   LIKE snvoice-amount,
           currency LIKE snvoice-currency,
         END OF lt_snvoice.

  DATA: li_snvoice TYPE STANDARD TABLE OF lt_snvoice,
        ls_snvoice TYPE lt_snvoice.

*2 PASO: Volcar datos a la tabla interna.

  SELECT carrid carrname
    INTO TABLE li_scarr
    FROM scarr
    WHERE carrid IN so_compa.
  IF sy-subrc NE 0.
    REFRESH li_scarr.
  ENDIF.

  SELECT carrid connid fldate seatsmax seatsmax_b seatsmax_f seatsocc seatsocc_b seatsocc_f
    INTO TABLE li_sflight
    FROM sflight
    WHERE carrid IN so_compa.
  IF sy-subrc NE 0.
    REFRESH li_sflight.
  ENDIF.

  SELECT carrid bookid customid instno amount currency
    INTO TABLE li_snvoice
    FROM snvoice
    WHERE carrid IN so_compa
    AND bookid IN so_book.
  IF sy-subrc NE 0.
    REFRESH li_snvoice.
  ENDIF.

*3 PASO: Recorre la tabla interna y pasa los datos a la estrucutra.

  REFRESH gi_salida. "Inicializar tablas.
  DATA: lv_a TYPE i.
  DATA: lv_b TYPE i.

  LOOP AT li_snvoice INTO ls_snvoice.
    "*Paso los datos de snvoice a la variable salida
    MOVE-CORRESPONDING ls_snvoice TO gs_salida.

    "Selecciono los datos de la tabla sflight y los agrego a gs_salida.
    READ TABLE li_sflight INTO ls_sflight WITH KEY carrid = ls_snvoice-carrid.
    IF sy-subrc EQ 0.

      gs_salida-connid     = ls_sflight-connid.
      gs_salida-fldate     = ls_sflight-fldate.
      gs_salida-seatsmax   = ls_sflight-seatsmax.
      gs_salida-seatsmax_b = ls_sflight-seatsmax_b.
      gs_salida-seatsmax_f = ls_sflight-seatsmax_f.
      gs_salida-seatsocc   = ls_sflight-seatsocc.
      gs_salida-seatsocc_b = ls_sflight-seatsocc_b.
      gs_salida-seatsocc_f = ls_sflight-seatsocc_f.

      "Calculamos los sitios libres del avion
      lv_a = ls_sflight-seatsmax + ls_sflight-seatsmax_b + ls_sflight-seatsmax_f.
      lv_b = ls_sflight-seatsocc + ls_sflight-seatsocc_b + ls_sflight-seatsocc_f.
      gs_salida-libre = lv_a - lv_b.

      lv_a = 0.
      lv_b = 0.

      "Selecciono los datos de la tabla scarr y los agrego a gs_salida.
      READ TABLE li_scarr INTO ls_scarr WITH KEY carrid = ls_snvoice-carrid.
      IF sy-subrc EQ 0.
        gs_salida-carrname = ls_scarr-carrname.
      ENDIF.

    ENDIF.

    APPEND gs_salida TO gi_salida.
    CLEAR gs_salida.

  ENDLOOP.


  IF r_opc1 IS NOT INITIAL.

    PERFORM imprimir_alv.

  ELSE.

    PERFORM salida_formulario.

  ENDIF.


ENDFORM.


FORM imprimir_alv.

  PERFORM catalogo_campos.
  PERFORM layout.

*Llamada a la funcion ALV
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program      = 'Z0001_RESERVAS_2020' "g_repid
      i_callback_top_of_page  = 'TOP-OF-PAGE'
      i_callback_user_command = 'USER_COMMAND'
      is_layout               = gs_layout
      it_fieldcat             = gi_fieldcat
    TABLES
      t_outtab                = gi_salida.
  IF sy-subrc <> 0.
  ENDIF.
ENDFORM.


FORM catalogo_campos.
*Creo una varible local de fieldcat para configurar los campos.
  DATA: ls_fieldcat LIKE LINE OF gi_fieldcat.

*Configuracion de campos:
  ls_fieldcat-fieldname = 'CARRID'.
  ls_fieldcat-seltext_m = 'Id Compañia'.
  ls_fieldcat-seltext_l = 'Id Compañia'.
  ls_fieldcat-seltext_s = 'Id Compañia'.
  APPEND ls_fieldcat TO gi_fieldcat.
  CLEAR ls_fieldcat.

  ls_fieldcat-fieldname = 'CARRNAME'.
  ls_fieldcat-seltext_l = 'Nombre de la compañia'.
  ls_fieldcat-seltext_m = 'Nombre de la compañia'.
  ls_fieldcat-seltext_s = 'N. Compañia'.
  APPEND ls_fieldcat TO gi_fieldcat.
  CLEAR ls_fieldcat.

  ls_fieldcat-fieldname = 'CONNID'.
  ls_fieldcat-seltext_l = 'Número de vuelo'.
  ls_fieldcat-seltext_m = 'Número de vuelo'.
  ls_fieldcat-seltext_s = 'N. Vuelo'.
  APPEND ls_fieldcat TO gi_fieldcat.
  CLEAR ls_fieldcat.

  ls_fieldcat-fieldname = 'fldate'.
  ls_fieldcat-seltext_l = 'Fecha de vuelo'.
  ls_fieldcat-seltext_m = 'Fecha de vuelo'.
  ls_fieldcat-seltext_s = 'F. Vuelo'.
  APPEND ls_fieldcat TO gi_fieldcat.
  CLEAR ls_fieldcat.

  ls_fieldcat-fieldname = 'LIBRE'.
  ls_fieldcat-seltext_l = 'Plaza libres Totales'.
  ls_fieldcat-seltext_m = 'Plaza Libres Totales'.
  ls_fieldcat-seltext_s = 'P. Libres T.'.
  APPEND ls_fieldcat TO gi_fieldcat.
  CLEAR ls_fieldcat.

  ls_fieldcat-fieldname = 'BOOKID'.
  ls_fieldcat-seltext_l = 'Número de reserva'.
  ls_fieldcat-seltext_m = 'Número de reserva'.
  ls_fieldcat-seltext_s = 'N. Reserva'.
  APPEND ls_fieldcat TO gi_fieldcat.
  CLEAR ls_fieldcat.

  ls_fieldcat-fieldname = 'CUSTOMID'.
  ls_fieldcat-seltext_l = 'Número de pasajero'.
  ls_fieldcat-seltext_m = 'Número de pasajero'.
  ls_fieldcat-seltext_s = 'N. Pasajero'.
  APPEND ls_fieldcat TO gi_fieldcat.
  CLEAR ls_fieldcat.

  ls_fieldcat-fieldname = 'INSTNO'.
  ls_fieldcat-seltext_l = 'Número de factura'.
  ls_fieldcat-seltext_m = 'Número de factura'.
  ls_fieldcat-seltext_s = 'N. Factura'.
  APPEND ls_fieldcat TO gi_fieldcat.
  CLEAR ls_fieldcat.

  ls_fieldcat-fieldname = 'AMOUNT'.
  ls_fieldcat-seltext_l = 'Precio'.
  ls_fieldcat-seltext_m = 'Precio'.
  ls_fieldcat-seltext_s = 'Precio'.
  APPEND ls_fieldcat TO gi_fieldcat.
  CLEAR ls_fieldcat.

  ls_fieldcat-fieldname = 'CURRENCY'.
  ls_fieldcat-seltext_l = 'Moneda'.
  ls_fieldcat-seltext_m = 'Moneda'.
  ls_fieldcat-seltext_s = 'Moneda'.
  APPEND ls_fieldcat TO gi_fieldcat.
  CLEAR ls_fieldcat.

ENDFORM.

FORM layout.
*Configuracicion del Layout
  gs_layout-zebra             = 'X'.
  gs_layout-colwidth_optimize = 'X'.
ENDFORM.


FORM top-of-page.
*Configuracicion de la cabecera
  DATA: li_header TYPE slis_t_listheader,
        ls_header TYPE slis_listheader.

  DATA: lv_lineas type i.

  ls_header-typ   = 'H'.
  ls_header-info  = 'Listado de Reservas'.
  APPEND ls_header TO li_header.
  CLEAR ls_header.

  ls_header-typ   = 'S'.
  ls_header-key   = 'Fecha: '.
  CONCATENATE sy-datum+6(2) '/' sy-datum+4(2) '/' sy-datum(4)
  INTO ls_header-info.
  APPEND ls_header TO li_header.

  ls_header-typ   = 'S'.
  ls_header-key   = 'Autor: '.
  CONCATENATE 'Jefferson Max Tomala' ' '
  INTO ls_header-info.
  APPEND ls_header TO li_header.

  "añadimos a la cabecera el nº de registros.
  Describe TABLE gi_salida Lines lv_lineas.
  ls_header-typ   = 'S'.
  ls_header-key   = 'Nº de registro: '.
  ls_header-info  = lv_lineas.
  APPEND ls_header TO li_header.

  ls_header-typ  = 'A'. "Action Cursiva
  ls_header-info = 'En esta lista se usan 3 tablas: SCARR, SFLIGHT, SNVOICE.'.
  APPEND ls_header TO li_header.


  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = li_header.

ENDFORM.


FORM user_command USING p_ucomm     LIKE sy-ucomm
                        ps_selfield TYPE slis_selfield.

  CASE p_ucomm.
    WHEN '&IC1'."Doble click

      IF ps_selfield-fieldname EQ 'CARRID'. "Si hago DobleClick entra en la transacción
*        CALL TRANSACTION 'DRAIRPORT' AND SKIP FIRST SCREEN.

        PERFORM salida_Formulario2.

      ELSEIF ps_selfield-fieldname EQ 'CARRNAME'. "Compañia aerea
*        SET PARAMETER ID 'CAR' FIELD ps_selfield-value. "Rellena el campo
        PERFORM salida_Formulario2.
*        CALL TRANSACTION 'DRFLIGHT' AND SKIP FIRST SCREEN.

      ELSEIF ps_selfield-fieldname EQ 'CONNID'. "Nº de vuelo
*        SET PARAMETER ID 'CAR' FIELD ps_selfield-value.
        PERFORM salida_Formulario2.


      ENDIF.

    WHEN OTHERS.
  ENDCASE.

ENDFORM.



FORM salida_formulario .
  DATA: lv_function_name TYPE  rs38l_fnam.
  DATA: lv_control_parameters TYPE ssfctrlop.
  DATA: lv_output_options     TYPE ssfcompop.

*1. Detectar que funcion lanza nuestro formulario
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = 'Z2020_AVIONES_01'
    IMPORTING
      fm_name            = lv_function_name
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid
    TYPE sy-msgty
    NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


* Parametros de impresion
  lv_control_parameters-no_dialog = 'X'.
  lv_control_parameters-preview = space.

  lv_output_options-tddest = 'LP01'. "Impresora
*  lv_output_options-tdnewid = space. "Nueva orden de spool
*  lv_output_options-tdimmed = 'X'. "Inmediata
*  lv_output_options-tdcopies = 1.

*  TRY .

* Lanzar el formulario
  CALL FUNCTION lv_function_name
    EXPORTING
     control_parameters  = lv_control_parameters
     output_options      = lv_output_options
     iv_carrid           = so_compa-low
    tables
      gi_salida        = gi_salida
    EXCEPTIONS
      formatting_error = 1
      internal_error   = 2
      send_error       = 3
      user_canceled    = 4
      OTHERS           = 5.

      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid
        TYPE sy-msgty
        NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.


*    CATCH cx_root.
*      MESSAGE 'Error al llamar al formulario' TYPE 'E'.
*  ENDTRY.


ENDFORM.

FORM salida_formulario2 .
  DATA: lv_function_name TYPE  rs38l_fnam.
  DATA: lv_control_parameters TYPE ssfctrlop.
  DATA: lv_output_options     TYPE ssfcompop.

*1. Detectar que funcion lanza nuestro formulario
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = 'Z2020_AVIONESINFO_01'
    IMPORTING
      fm_name            = lv_function_name
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid
    TYPE sy-msgty
    NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


* Parametros de impresion
  lv_control_parameters-no_dialog = 'X'.
  lv_control_parameters-preview = space.

  lv_output_options-tddest = 'LP01'. "Impresora
*  lv_output_options-tdnewid = space. "Nueva orden de spool
*  lv_output_options-tdimmed = 'X'. "Inmediata
*  lv_output_options-tdcopies = 1.

*  TRY .

* Lanzar el formulario
  CALL FUNCTION lv_function_name
    EXPORTING
     control_parameters  = lv_control_parameters
     output_options      = lv_output_options
     iv_carrid           = so_compa-low
    tables
      gi_salida        = gi_salida
    EXCEPTIONS
      formatting_error = 1
      internal_error   = 2
      send_error       = 3
      user_canceled    = 4
      OTHERS           = 5.

      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid
        TYPE sy-msgty
        NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.


*    CATCH cx_root.
*      MESSAGE 'Error al llamar al formulario' TYPE 'E'.
*  ENDTRY.


ENDFORM.