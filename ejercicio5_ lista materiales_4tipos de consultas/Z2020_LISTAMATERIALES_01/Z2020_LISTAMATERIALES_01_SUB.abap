*&---------------------------------------------------------------------*
*&  Include           Z2020_LISTAMATERIALES_01_SUB
*&---------------------------------------------------------------------*

FORM logica_principal.

  TYPES: BEGIN OF lt_mara,
           matnr LIKE mara-matnr, "Material
           ersda LIKE mara-ersda, "Fecha de creacion
         END OF lt_mara.

  DATA: li_mara TYPE STANDARD TABLE OF lt_mara.
  DATA: ls_mara TYPE lt_mara.

  TYPES: BEGIN OF lt_marc,
           matnr LIKE marc-matnr, "Material
           werks LIKE marc-werks, "Centro
         END OF lt_marc.

  DATA: li_marc TYPE STANDARD TABLE OF lt_marc,
        ls_marc TYPE lt_marc.


* 1. Vamos a volcar la mara y Marc a dos tablas internas.
*-----------------------------------------------------
  SELECT matnr ersda
    INTO TABLE li_mara
    FROM mara
    WHERE matnr IN s_matnr
    AND ersda IN s_ersda.
  IF sy-subrc NE 0.
    REFRESH li_mara.
  ENDIF.

  SELECT matnr werks
      INTO TABLE li_marc
      FROM marc
      WHERE matnr IN s_matnr.
  IF sy-subrc NE 0.
    REFRESH li_marc.
  ENDIF.


* 2.Generar la tabla GI_SALIDA
*-----------------------------------------------------
  REFRESH gi_salida.

  LOOP AT li_mara INTO ls_mara.

    MOVE-CORRESPONDING ls_mara TO gs_salida.

    "Recupero el campo werks de li_Marc
    READ TABLE li_marc INTO ls_marc WITH KEY matnr = ls_mara-matnr.
    IF sy-subrc EQ 0.
      gs_salida-werks = ls_marc.
    ENDIF.


    APPEND gs_salida TO gi_salida.
    CLEAR gs_salida.

  ENDLOOP.

*-----------------------------------------------------

ENDFORM.


FORM logica_principal_ss.
  DATA: lv_werks LIKE marc-werks. "variable para guardar WERKS
  DATA: lv_tabix LIKE sy-tabix.
* Vuelco la tabla MARA
  SELECT matnr ersda
    INTO CORRESPONDING FIELDS OF TABLE gi_salida
    FROM mara
    WHERE matnr IN s_matnr
    AND ersda IN s_ersda.
  IF sy-subrc NE 0.
    REFRESH gi_salida.
  ENDIF.

* Recorro la salida para obtener el WERKS
  LOOP AT gi_salida INTO gs_salida.
    lv_tabix = sy-tabix.

*    SELECT SINGLE werks
*            INTO lv_werks
*            FROM marc
*           WHERE matnr = gs_salida-matnr.
*    IF sy-subrc EQ 0.
*      CLEAR lv_werks.
*      else.
*        gs_salida-werks = lv_werks.
*    ENDIF.
    SELECT SINGLE werks
               INTO gs_salida-werks
               FROM marc
              WHERE matnr = gs_salida-matnr.
    IF sy-subrc NE 0.
      CLEAR gs_salida-werks.
    ENDIF.


*   MODIFICAR TABLA INTERNA.
    MODIFY gi_salida FROM gs_salida INDEX lv_tabix.
    CLEAR gs_salida.

  ENDLOOP.

ENDFORM.

FORM logica_principal_join.
  " ventajas cuando son dos tablas.
  SELECT mara~matnr
         mara~ersda
         marc~werks
    INTO TABLE gi_salida
    FROM mara LEFT OUTER JOIN marc ON mara~matnr = marc~matnr
    WHERE mara~matnr IN s_matnr
    AND ersda IN s_ersda.
  IF sy-subrc NE 0.
    REFRESH gi_salida.
  ENDIF.

ENDFORM.

FORM imprimir.

  IF r_wrt IS NOT INITIAL. "Imprime write
    PERFORM imprimir_wrt.
  ELSE.                    "Imprime ALV
    PERFORM imprimir_alv.
  ENDIF.



ENDFORM.

FORM imprimir_wrt.
  WRITE: 'NUMERO DE MATERIAL', '|', 'FECHA', '     |', 'CENTRO', '|'.
  LOOP AT gi_salida INTO gs_salida.

    WRITE: /
            gs_salida-matnr,
            '|',
            gs_salida-ersda,
            '|',
            gs_salida-werks,
            '  |'.
  ENDLOOP.

ENDFORM.

FORM imprimir_alv.

* Rellenamos el catalogo de campos.
  PERFORM catalogo_campos.
  PERFORM layout.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING                         "Parametros de entrada
      i_callback_top_of_page  = 'TOP-OF-PAGE'   "ver el perform TOP-OF-PAGE
      i_callback_program      = 'Z2020_LISTAMATERIALES_00'
      i_callback_user_command = 'USER_COMMAND'
      is_layout               = gs_layout
      it_fieldcat             = gi_fieldcat
    TABLES
      t_outtab                = gi_salida.
  IF sy-subrc <> 0.
  ENDIF.

ENDFORM.

*ALV CON CABECERA
FORM top-of-page.
  DATA: li_header TYPE slis_t_listheader, "Tabla interna
        ls_header LIKE LINE OF li_header. "Estructura / Work Area

  ls_header-typ = 'H'.
  ls_header-info = 'Lista Materiales'.
  APPEND ls_header TO li_header.


  ls_header-typ = 'S'.
  ls_header-key = 'Fecha: '.
*  ls_header-info = sy-datum.
* Formatear fecha.
  CONCATENATE sy-datum+6(2) '/' sy-datum+4(2) '/' sy-datum(4)
         INTO ls_header-info.
  APPEND ls_header TO li_header.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = li_header.
*     I_LOGO                   =
*     I_END_OF_LIST_GRID       =
*     I_ALV_FORM               =
  .

ENDFORM.

FORM catalogo_campos.
  DATA: ls_fieldcat LIKE LINE OF gi_fieldcat.
*  DATA: ls_fieldcat LIKE LINE OF slis_t_fieldat_alv.

  ls_fieldcat-fieldname = 'MATNR'.
  ls_fieldcat-seltext_l = 'Material'.
  ls_fieldcat-seltext_m = 'Material'.
  ls_fieldcat-seltext_s = 'Mat'.
  APPEND ls_fieldcat TO gi_fieldcat.
  CLEAR ls_fieldcat.

  ls_fieldcat-fieldname = 'ERSDA'.
  ls_fieldcat-seltext_l = 'Fecha Creacion'.
  ls_fieldcat-seltext_m = 'Fecha Cr.'.
  ls_fieldcat-seltext_s = 'Fe'.
  APPEND ls_fieldcat TO gi_fieldcat.
  CLEAR ls_fieldcat.

  ls_fieldcat-fieldname = 'WERKS'.
  ls_fieldcat-seltext_l = 'Centro'.
  ls_fieldcat-seltext_m = 'Centro'.
  ls_fieldcat-seltext_s = 'Cent'.
  APPEND ls_fieldcat TO gi_fieldcat.
  CLEAR ls_fieldcat.

ENDFORM.



  " se usa cuando hay desvorde de memoria
  " inconveniente nunca puede haber una tabla vacia porque
  " tardá mucho, (consumira memoria),  por eso se hace una comprobacion
* Y con el resultado hago el FOR ALL ENTRIES
FORM logica_principal_fa .

  TYPES: BEGIN OF lt_mara,
           matnr LIKE mara-matnr, "Material
           ersda LIKE mara-ersda, "Fecha de creacion
         END OF lt_mara.

  DATA: li_mara TYPE STANDARD TABLE OF lt_mara,
        ls_mara TYPE lt_mara.

  TYPES: BEGIN OF lt_marc,
           matnr LIKE marc-matnr, "Material
           werks LIKE marc-werks, "Centro
         END OF lt_marc.

  DATA: li_marc TYPE STANDARD TABLE OF lt_marc,
        ls_marc TYPE lt_marc.


* Vuelco la tabla MARA
  SELECT matnr ersda
      INTO TABLE li_mara
      FROM mara
      WHERE matnr IN s_matnr
      AND ersda IN s_ersda.
  IF sy-subrc NE 0. "IF sy-subrc NE 0.
    REFRESH li_mara."Borrar tablas
  ENDIF.



  IF li_mara[] IS NOT INITIAL. " Si viene relleno hago el forr all entries

    SELECT matnr werks
      INTO TABLE li_marc
      FROM marc
      FOR ALL ENTRIES IN li_mara
      WHERE matnr = li_mara-matnr.
    IF sy-subrc NE 0.
      REFRESH li_marc.

    ENDIF.
  ENDIF.


* Generamos la tabla de salida
  LOOP AT li_mara INTO ls_mara.

    MOVE-CORRESPONDING ls_mara TO gs_salida.

    "Recupero el campo WERKS de LI_MARC
    READ TABLE li_marc INTO ls_marc WITH KEY matnr = ls_mara-matnr.
    IF sy-subrc EQ 0.
      gs_salida-werks = ls_marc-werks.

      APPEND gs_salida TO gi_salida.
      CLEAR gs_salida.

    ENDIF.

  ENDLOOP.


ENDFORM.

FORM layout.

  gs_layout-colwidth_optimize = 'X'.
  gs_layout-zebra = 'X'.

ENDFORM.

FORM user_command USING p_ucomm     LIKE sy-ucomm
                        ps_selfield TYPE slis_selfield.

  CASE p_ucomm.
    WHEN '&IC1'."Doble click

      IF ps_selfield-fieldname EQ 'MATNR'. "Si hago DobleClick en MATNR entro

        "relleno el campo material escribiendo en la Memoria
        SET PARAMETER ID 'MAT' FIELD ps_selfield-value.

        "Llamo a la transaccion
        CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.

      ENDIF.

    WHEN OTHERS.
  ENDCASE.


ENDFORM.