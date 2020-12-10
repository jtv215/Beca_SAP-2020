*&---------------------------------------------------------------------*
*&  Include           Z2020_LISTAAEROPUERTO_01_SUB
*&---------------------------------------------------------------------*

FORM logica_principal.

*Generar el tipo de tablas, hacer consultas y pasar datos a gs_salida.
  TYPES: BEGIN OF lt_scitairp,
           country    LIKE scitairp-country,
           mastercity LIKE scitairp-mastercity,
           airport    LIKE scitairp-airport,
         END OF lt_scitairp.

  DATA: li_scitairp TYPE STANDARD TABLE OF lt_scitairp,
        ls_scitairp TYPE lt_scitairp.

  TYPES: BEGIN OF lt_sairport,
           id   LIKE sairport-id,
           name LIKE sairport-name,
         END OF lt_sairport.

  DATA: li_sairport TYPE STANDARD TABLE OF lt_sairport,
        ls_sairport TYPE lt_sairport.

* 1. Vamos a volcar la scitairp y sairport a dos tablas internas.
*-----------------------------------------------------
  SELECT country  mastercity airport
    INTO TABLE li_scitairp
    FROM scitairp
    WHERE airport IN s_pais.
  IF sy-subrc NE 0.
    REFRESH li_sairport.
  ENDIF.

  SELECT id name
      INTO TABLE li_sairport
      FROM sairport
      WHERE id IN s_pais.
  IF sy-subrc NE 0.
    REFRESH li_sairport.
  ENDIF.

* 2.Generar la tabla gi_Salida
*-----------------------------------------------------
  REFRESH gi_salida.  "Inicializo tablas.

  " Se recorre toda la tabla y se introduce en una estructura ls_scitairp
  LOOP AT li_scitairp INTO ls_scitairp.

    MOVE-CORRESPONDING ls_scitairp TO gs_salida. "asigna los campos iguales entre dos estructuras

    "Recupero el campo werks de li_Marc
    READ TABLE li_sairport INTO ls_sairport WITH KEY id = ls_scitairp-airport.
    IF sy-subrc EQ 0.
      gs_salida-name = ls_sairport.
    ENDIF.

    APPEND gs_salida TO gi_salida.
    CLEAR gs_salida.

  ENDLOOP.

  PERFORM imprimir.
ENDFORM.


FORM logica_principal_ss.
  DATA: lv_name  LIKE sairport-name. "variable local_ name de saiport
  DATA: lv_tabix LIKE sy-tabix.     "variable para guardar WERKS

* Vuelco la tabla li_ scitairp
  SELECT country mastercity airport
    INTO CORRESPONDING FIELDS OF TABLE gi_salida
    FROM scitairp
    WHERE airport IN s_pais.
  IF sy-subrc NE 0.
    REFRESH gi_salida.
  ENDIF.

  LOOP AT gi_salida INTO gs_salida.
    lv_tabix = sy-tabix.

    SELECT SINGLE name
      INTO gs_salida-name
      FROM sairport
      WHERE id = gs_salida-airport.
    IF sy-subrc NE 0.
      CLEAR gs_salida-name.
    ENDIF.

*   MODIFICAR TABLA INTERNA.
    MODIFY gi_salida FROM gs_salida INDEX lv_tabix TRANSPORTING name.
    CLEAR gs_salida.

  ENDLOOP.

PERFORM imprimir.
ENDFORM.


FORM logica_principal_join.

  SELECT scitairp~country
         scitairp~mastercity
         scitairp~airport
         sairport~name
    INTO TABLE gi_salida
    FROM scitairp LEFT OUTER JOIN sairport ON scitairp~airport = sairport~id
    WHERE scitairp~airport IN s_pais.
  IF sy-subrc NE 0.
    REFRESH gi_salida.
  ENDIF.
PERFORM imprimir.
ENDFORM.


FORM imprimir.
  "Imprimir los registros por pantallas
  WRITE: 'Pais', '' .
  WRITE: 'Población', '            ' .
  WRITE: 'Aeropuerto', ' ' .
  WRITE: 'Dirección', ' ' .
  SKIP.

  LOOP AT gi_salida INTO gs_salida.
    WRITE: gs_salida-country, ' '.
    WRITE: gs_salida-mastercity, ' '.
    WRITE: gs_salida-airport, ' '.
    WRITE: gs_salida-name, ' '.
    SKIP.
  ENDLOOP.
ENDFORM.


FORM logica_principal_cuatrotabla.
*1 PASO: Crear tablas y estructura sin cabecera.
  TYPES: BEGIN OF lt_scitairp,
           city       LIKE scitairp-city,
           country    LIKE scitairp-country,
           airport    LIKE scitairp-airport,
           mastercity LIKE scitairp-mastercity,
         END OF lt_scitairp.

  DATA: li_scitairp TYPE STANDARD TABLE OF lt_scitairp,
        ls_scitairp TYPE lt_scitairp.

  TYPES: BEGIN OF lt_sairport,
           id   LIKE sairport-id,
           name LIKE sairport-name,
         END OF lt_sairport.

  DATA: li_sairport TYPE STANDARD TABLE OF lt_sairport,
        ls_sairport TYPE lt_sairport.

  TYPES: BEGIN OF lt_scounter,
           carrid   LIKE scounter-carrid,
           countnum LIKE scounter-countnum,
           airport  LIKE scounter-airport,
         END OF lt_scounter.

  DATA: li_scounter TYPE STANDARD TABLE OF lt_scounter,
        ls_scounter TYPE lt_scounter.


  TYPES: BEGIN OF lt_scarr,
           carrid   LIKE scarr-carrid,
           carrname LIKE scarr-carrname,
           currcode LIKE scarr-currcode,
         END OF lt_scarr.

  DATA: li_scarr TYPE STANDARD TABLE OF lt_scarr,
        ls_scarr TYPE lt_scarr.


*2 PASO: Volcar datos a la tabla interna.

  SELECT city country airport mastercity
    INTO TABLE li_scitairp
    FROM scitairp
    WHERE airport IN s_pais.
  IF sy-subrc NE 0.
    REFRESH li_scitairp.
  ENDIF.

  SELECT id name
    INTO TABLE li_sairport
    FROM sairport.
*    WHERE id = s_pais.
  IF sy-subrc NE 0.
    REFRESH li_sairport.
  ENDIF.


  SELECT carrid countnum airport
    INTO TABLE li_scounter
    FROM scounter.
  "WHERE id IN p_sairport.
  IF sy-subrc NE 0.
    REFRESH li_scounter.
  ENDIF.

  SELECT carrid carrname currcode
    INTO TABLE li_scarr
    FROM scarr.
  "WHERE id IN p_sairport.
  IF sy-subrc NE 0.
    REFRESH li_scarr.
  ENDIF.



*3 PASO: Recorre la tabla interna y pasa los datos a la estrucutra.
REFRESH gi_salida. "Inicializar tablas.

LOOP AT li_scitairp INTO ls_scitairp.
*Paso los datos de sairport a la variable salida
  MOVE-CORRESPONDING ls_scitairp TO gs_salida.

*Leo los atributos de la tabla sairport y los agrego a gs_salida.
  READ TABLE li_sairport INTO ls_sairport WITH KEY id = ls_scitairp-airport.
  IF sy-subrc EQ 0.
    gs_salida-name = ls_sairport-name.
    gs_salida-id = ls_sairport-id.

    READ TABLE li_scounter INTO ls_scounter WITH KEY airport = ls_sairport-id.

    IF sy-subrc EQ 0.
    gs_salida-carrid = ls_scounter-carrid.
    gs_salida-countnum = ls_scounter-countnum.

    READ TABLE li_scarr INTO ls_scarr WITH KEY carrid =  gs_salida-carrid.
    IF sy-subrc EQ 0.
      gs_salida-carrname = ls_scarr-carrname.
      gs_salida-currcode = ls_scarr-currcode.
    ENDIF.

    ENDIF.

  ENDIF.

  APPEND gs_salida TO gi_salida.
  CLEAR gs_salida.


ENDLOOP.

*PERFORM imprimir_write.
PERFORM imprimir_alv.

ENDFORM.

FORM imprimir_write.

  LOOP AT gi_salida INTO gs_salida.
    WRITE: /
           '|', gs_salida-city,' ',
           '|', gs_salida-country,
           '|', gs_salida-mastercity,' ',
           '|', gs_salida-id,' ',
           '|', gs_salida-name,' ',
           '|', gs_salida-carrid,' ',
           '|', gs_salida-countnum,' ',
           '|', gs_salida-carrname,' ',
           '|', gs_salida-currcode,' '.

  ENDLOOP.
ENDFORM.


FORM imprimir_alv.

  PERFORM catalogo_campos.
  PERFORM layout.


*Llamada a la funcion ALV
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program      = 'Z2020_LISTAAEROPUERTO_01' "g_repid
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
  ls_fieldcat-fieldname = 'CITY'.
  ls_fieldcat-seltext_m = 'Ciudad'.
  ls_fieldcat-seltext_l = 'Ciudad'.
  ls_fieldcat-seltext_s = 'Ciudad'.
  APPEND ls_fieldcat TO gi_fieldcat.
  CLEAR ls_fieldcat.

  ls_fieldcat-fieldname = 'COUNTRY'.
  ls_fieldcat-seltext_l = 'Pais'.
  ls_fieldcat-seltext_m = 'Pais'.
  ls_fieldcat-seltext_s = 'Pais'.
  APPEND ls_fieldcat TO gi_fieldcat.
  CLEAR ls_fieldcat.

  ls_fieldcat-fieldname = 'Airport'.
  ls_fieldcat-seltext_l = 'Aeropuerto'.
  ls_fieldcat-seltext_m = 'Aeropuerto'.
  ls_fieldcat-seltext_s = 'Aeropuerto'.
  APPEND ls_fieldcat TO gi_fieldcat.
  CLEAR ls_fieldcat.

  ls_fieldcat-fieldname = 'MASTERCITY'.
  ls_fieldcat-seltext_l = 'Población'.
  ls_fieldcat-seltext_m = 'Población'.
  ls_fieldcat-seltext_s = 'Población'.
  APPEND ls_fieldcat TO gi_fieldcat.
  CLEAR ls_fieldcat.

  ls_fieldcat-fieldname = 'ID'.
  ls_fieldcat-seltext_l = 'ID'.
  ls_fieldcat-seltext_m = 'ID'.
  ls_fieldcat-seltext_s = 'ID'.
  APPEND ls_fieldcat TO gi_fieldcat.
  CLEAR ls_fieldcat.

  ls_fieldcat-fieldname = 'NAME'.
  ls_fieldcat-seltext_l = 'Nombre'.
  ls_fieldcat-seltext_m = 'Nombre'.
  ls_fieldcat-seltext_s = 'Nombre'.
  APPEND ls_fieldcat TO gi_fieldcat.
  CLEAR ls_fieldcat.

  ls_fieldcat-fieldname = 'CARRID'.
  ls_fieldcat-seltext_l = 'Compañia Aerea'.
  ls_fieldcat-seltext_m = 'Compañia Aerea'.
  ls_fieldcat-seltext_s = 'Compañia Aerea'.
  APPEND ls_fieldcat TO gi_fieldcat.
  CLEAR ls_fieldcat.

  ls_fieldcat-fieldname = 'COUNTNUM'.
  ls_fieldcat-seltext_l = 'Número Terminal'.
  ls_fieldcat-seltext_m = 'Nº Terminal'.
  ls_fieldcat-seltext_s = 'Nº Terminal'.
  APPEND ls_fieldcat TO gi_fieldcat.
  CLEAR ls_fieldcat.

  ls_fieldcat-fieldname = 'CARRNAME'.
  ls_fieldcat-seltext_l = 'Nombre Compañia Aerea'.
  ls_fieldcat-seltext_m = 'Nombre Compañia Aerea'.
  ls_fieldcat-seltext_s = 'Nombre Compañia Aerea'.
  APPEND ls_fieldcat TO gi_fieldcat.
  CLEAR ls_fieldcat.

  ls_fieldcat-fieldname = 'CURRCODE'.
  ls_fieldcat-seltext_l = 'Moneda Local'.
  ls_fieldcat-seltext_m = 'Moneda Local'.
  ls_fieldcat-seltext_s = 'Moneda Local'.
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
  ls_header-info  = 'Listado de Aeropuerto'.
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