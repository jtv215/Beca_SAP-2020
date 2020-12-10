*&---------------------------------------------------------------------*
*&  Include           Z2020_LISTADOVUELOS_01_SUB
*&---------------------------------------------------------------------*

FORM logica_principal.

*Generar el tipo de tablas, hacer consultas y pasar datos a gs_salida.
*1 PASO: Crear tablas y estructura sin cabecera.
  TYPES: BEGIN OF lt_sairport,
           id   LIKE sairport-id,
           name LIKE sairport-name,
         END OF lt_sairport.

  DATA: li_sairport TYPE STANDARD TABLE OF lt_sairport,
        ls_sairport TYPE lt_sairport. "sin cabecera, se aloja los datos en cada registro

  TYPES: BEGIN OF lt_spfli,
           countryto LIKE spfli-countryto,
           carrid    LIKE spfli-carrid,
           connid    LIKE spfli-connid,
           airpto    LIKE spfli-airpfrom,
           airpfrom  LIKE spfli-airpfrom,
           countryfr LIKE spfli-countryfr,
         END OF lt_spfli.

  DATA: li_spfli TYPE STANDARD TABLE OF lt_spfli,
        ls_spfli TYPE lt_spfli.

*2 PASO: Volcar datos a la tabla interna.
  SELECT id name
    INTO TABLE li_sairport
    FROM sairport
  WHERE id IN p_airpto.

  IF sy-subrc NE 0.
    REFRESH li_sairport.
  ENDIF.

  SELECT countryto carrid connid  airpto airpfrom countryfr
    INTO TABLE li_spfli
    FROM spfli
  WHERE airpto IN p_airpto.

  IF sy-subrc NE 0.
    REFRESH li_spfli.
  ENDIF.

*3 PASO: Recorre la tabla interna y pasa los datos a la estrucutra.
  REFRESH gi_salida. "Inicializar tablas.

  LOOP AT li_spfli INTO ls_spfli.
*Paso los datos de sairport a la variable salida
    MOVE-CORRESPONDING ls_spfli TO gs_salida.

*Leo los atributos de la tabla sairport y los agrego a gs_salida.
    READ TABLE li_sairport INTO ls_sairport WITH KEY id = ls_spfli-airpfrom.
    IF sy-subrc EQ 0.
      gs_salida-name = ls_sairport-name.
      gs_salida-id = ls_sairport-id.
    ENDIF.

    "junto cada item de salida a la tabla interna de salida
    APPEND gs_salida TO gi_salida.
    CLEAR gs_salida.

  ENDLOOP.

ENDFORM.

FORM imprimir_write.
  WRITE: '|Aeropuerto Origen', '|', 'Nombre Aeropuerto       ', ' |', 'Pais Origen', '|' ,'Compania Aerea', '|' ,'N. Vuelo' , '|' ,'Aeropuerto Destino', '|' ,'Pais Destino','|'.
  LOOP AT gi_salida INTO gs_salida.
    WRITE: /
           '|', gs_salida-airpfrom,'            ',
           '|', gs_salida-name,
           '|', gs_salida-countryfr,'       ',
           '|', gs_salida-carrid,'          ',
           '|', gs_salida-connid,'   ',
           '|', gs_salida-airpto,'              ',
           '|', gs_salida-countryto,'        ','|'.
  ENDLOOP.
ENDFORM.

FORM imprimir_alv.
*Creo la tabla interna llamada gi_alv.
  TYPES: BEGIN OF lt_alv,
           airpfrom  LIKE spfli-airpfrom,
           name      LIKE sairport-name,
           countryfr LIKE spfli-countryfr,
           carrid    LIKE spfli-carrid,
           connid    LIKE spfli-connid,
           airpto    LIKE spfli-airpto,
           countryto LIKE spfli-countryto,
         END OF lt_alv.
  DATA: gi_alv TYPE STANDARD TABLE OF lt_alv.

  PERFORM catalogo_campos.
  PERFORM layout.


*Llamada a la funcion ALV
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program      = 'Z2020_LISTADOVUELOS_01' "g_repid
      i_callback_top_of_page  = 'TOP-OF-PAGE'
      i_callback_user_command = 'USER_COMMAND'
      is_layout               = gs_layout
      it_fieldcat             = gi_fieldcat
    TABLES
      t_outtab                = gi_salida.
  IF sy-subrc <> 0.
  ENDIF.
ENDFORM.

FORM catalogo_campos..
*Creo una varible local de fieldcat para configurar los campos.
  DATA: ls_fieldcat LIKE LINE OF gi_fieldcat.

*Configuracion de campos:
  ls_fieldcat-fieldname = 'AIRPFROM'.
  ls_fieldcat-seltext_m = 'Aeropuerto Origen'.
  ls_fieldcat-seltext_l = 'Aeropuerto Origen'.
  ls_fieldcat-seltext_s = 'Aeropuerto Origen'.
  APPEND ls_fieldcat TO gi_fieldcat.
  CLEAR ls_fieldcat.

  ls_fieldcat-fieldname = 'NAME'.
  ls_fieldcat-seltext_l = 'Nombre del Aeropuerto'.
  ls_fieldcat-seltext_m = 'Nombre del Aeropuerto'.
  ls_fieldcat-seltext_s = 'Nombre del Aeropuerto'.
  APPEND ls_fieldcat TO gi_fieldcat.
  CLEAR ls_fieldcat.

  ls_fieldcat-fieldname = 'COUNTRYFR'.
  ls_fieldcat-seltext_l = 'Pais Origen'.
  ls_fieldcat-seltext_m = 'Pais Origen'.
  ls_fieldcat-seltext_s = 'Pais Origen'.
  APPEND ls_fieldcat TO gi_fieldcat.
  CLEAR ls_fieldcat.

  ls_fieldcat-fieldname = 'CARRID'.
  ls_fieldcat-seltext_l = 'Compañia Aerea'.
  ls_fieldcat-seltext_m = 'Compañia Aerea'.
  ls_fieldcat-seltext_s = 'Compañia Aerea'.
  APPEND ls_fieldcat TO gi_fieldcat.
  CLEAR ls_fieldcat.

  ls_fieldcat-fieldname = 'CONNID'.
  ls_fieldcat-seltext_l = 'Numero de Vuelo'.
  ls_fieldcat-seltext_m = 'Numero de Vuelo'.
  ls_fieldcat-seltext_s = 'Numero de Vuelo'.
  APPEND ls_fieldcat TO gi_fieldcat.
  CLEAR ls_fieldcat.

  ls_fieldcat-fieldname = 'AIRPTO'.
  ls_fieldcat-seltext_l = 'Aeropuerto Destino'.
  ls_fieldcat-seltext_m = 'Aeropuerto Destino'.
  ls_fieldcat-seltext_s = 'Aeropuerto Destino'.
  APPEND ls_fieldcat TO gi_fieldcat.
  CLEAR ls_fieldcat.

  ls_fieldcat-fieldname = 'COUNTRYTO'.
  ls_fieldcat-seltext_l = 'Pais Destino'.
  ls_fieldcat-seltext_m = 'Pais Destino'.
  ls_fieldcat-seltext_s = 'Pais Destino'.
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

  ls_header-typ   = 'H'.
  ls_header-info  = 'Listado de vuelos'.
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

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = li_header.

ENDFORM.

FORM user_command USING p_ucomm     LIKE sy-ucomm
                        ps_selfield TYPE slis_selfield.

  CASE p_ucomm.
    WHEN '&IC1'."Doble click

      IF ps_selfield-fieldname EQ 'AIRPFROM'. "Si hago DobleClick entra en la transacción
        CALL TRANSACTION 'DRAIRPORT' AND SKIP FIRST SCREEN.

      ELSEIF ps_selfield-fieldname EQ 'CARRID'. "Compañia aerea
        SET PARAMETER ID 'CAR' FIELD ps_selfield-value. "Rellena el campo
        CALL TRANSACTION 'DRFLIGHT' AND SKIP FIRST SCREEN.

      ELSEIF ps_selfield-fieldname EQ 'CONNID'. "Nº de vuelo
        SET PARAMETER ID 'CAR' FIELD ps_selfield-value.
        CALL TRANSACTION 'DRCARR' AND SKIP FIRST SCREEN.

      ELSEIF ps_selfield-fieldname EQ 'AIRPTO'. "Aeropuerto Destino
        CALL TRANSACTION 'DRAIRPORT' AND SKIP FIRST SCREEN.

      ENDIF.

    WHEN OTHERS.
  ENDCASE.

ENDFORM.