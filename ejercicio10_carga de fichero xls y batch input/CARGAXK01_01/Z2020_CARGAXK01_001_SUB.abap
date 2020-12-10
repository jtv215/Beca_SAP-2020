*&---------------------------------------------------------------------*
*&  Include           Z2020_CARGAXK01_00_00_SUB
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  LOGICA_PRINCIPAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM logica_principal .

* 1. Cargar el fichero a TI.
  PERFORM cargar_fichero.

* 2. Ejecutar la carga
  PERFORM bi_proveedores.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  IMPRIMIR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM imprimir .
* mostramos el log de errores del BI
* GI_ALV.
  " Log de errores del BI
  PERFORM catalogo_campos.
  PERFORM layout.
*
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = gv_repid
*     i_callback_top_of_page        = 'TOP_OF_PAGE'
*     i_callback_user_command       = 'USER_COMMAND'
      is_layout          = gs_layout
      it_fieldcat        = gi_fieldcat
    TABLES
      t_outtab           = gi_alv.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
ENDFORM.

FORM catalogo_campos .
  DATA: ls_fieldcat LIKE LINE OF gi_fieldcat.

*  TYPES: BEGIN OF gt_alv,
*         nombre    LIKE lfa1-name1,
*         calle     LIKE lfa1-stras,
*         poblacion LIKE lfa1-ort01,
*         c_p       LIKE lfa1-pstlz,
*         telefono  LIKE lfa1-telf1,
*         mensaje   TYPE string,
*
*       END OF gt_alv.

  ls_fieldcat-fieldname             =  'NOMBRE' .
  ls_fieldcat-seltext_l             =  'Nombre'.
  APPEND ls_fieldcat TO gi_fieldcat.
  CLEAR ls_fieldcat.

  ls_fieldcat-fieldname             =  'CALLE' .
  ls_fieldcat-seltext_l             =  'Calle'.
  APPEND ls_fieldcat TO gi_fieldcat.
  CLEAR ls_fieldcat.

  ls_fieldcat-fieldname             =  'POBLACION' .
  ls_fieldcat-seltext_l             =  'Población'.
  APPEND ls_fieldcat TO gi_fieldcat.
  CLEAR ls_fieldcat.

  ls_fieldcat-fieldname             =  'C_P' .
  ls_fieldcat-seltext_l             =  'Código postal'.
  ls_fieldcat-seltext_s             =  'C.P'.
  APPEND ls_fieldcat TO gi_fieldcat.
  CLEAR ls_fieldcat.

  ls_fieldcat-fieldname             =  'TELEFONO' .
  ls_fieldcat-seltext_l             =  'Teléfono'.
  ls_fieldcat-seltext_s             =  'Tlfno.'.
  APPEND ls_fieldcat TO gi_fieldcat.
  CLEAR ls_fieldcat.

  ls_fieldcat-fieldname             =  'MENSAJE' .
  ls_fieldcat-seltext_l             =  'Mensaje'.
  ls_fieldcat-seltext_s             =  'Msj'.
  APPEND ls_fieldcat TO gi_fieldcat.
  CLEAR ls_fieldcat.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  LAYOUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM layout .
  gs_layout-zebra                 = 'X'.
  gs_layout-colwidth_optimize     = 'X'.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  VENTANA_BUSQUEDA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ventana_busqueda .

  DATA: lv_file_name LIKE  ibipparms-path.

  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      program_name  = sy-repid
      dynpro_number = sy-dynnr
      field_name    = 'PATH'
    IMPORTING
      file_name     = lv_file_name.

* La salida de la función la asigno a mi parametro ruta de la pantalla de seleccion
  p_ruta = lv_file_name.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CARGAR_FICHERO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*

FORM cargar_fichero .
  DATA: lv_filename LIKE rlgrap-filename,
        lv_end_col  TYPE i,
        lv_end_row  TYPE i,
        li_excel    TYPE STANDARD TABLE OF alsmex_tabline,
        ls_excel    LIKE LINE OF li_excel.

  DATA: lv_flag(1) TYPE c.

  lv_filename = p_ruta.

* 1. Paso el excel a la tabla excel
  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      filename                = lv_filename
      i_begin_col             = 1
      i_begin_row             = 1
      i_end_col               = 5  "lv_end_col
      i_end_row               = 50 "lv_end_row
    TABLES
      intern                  = li_excel
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2
      OTHERS                  = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
    MESSAGE ' Fallo en la funcion' TYPE 'E'.
  ENDIF.

* 2. Paso la tabla Excel a mi TI

  LOOP AT li_excel INTO ls_excel.
    IF ls_excel-row = 1. "Es la cabecera
      CONTINUE.
    ENDIF.

    AT NEW row.
      lv_flag = 'X'. "Marcador de cambio de columna
    ENDAT.

    IF lv_flag IS NOT INITIAL AND ls_excel-row > 2.
      APPEND gs_fichero TO gi_fichero.
      CLEAR gs_fichero.
    ENDIF.


* Dependiendo de la columna asignamos el valor al campo de la TI
    CASE ls_excel-col.
      WHEN 1.
        gs_fichero-nombre       = ls_excel-value.
      WHEN 2.
        gs_fichero-calle        = ls_excel-value.
      WHEN 3.
        gs_fichero-poblacion    = ls_excel-value.
      WHEN 4.
        gs_fichero-c_p          = ls_excel-value.
      WHEN 5.
        gs_fichero-telefono     = ls_excel-value.
      WHEN OTHERS.
    ENDCASE.

    CLEAR lv_flag.
  ENDLOOP.

* Hago el ultimo append si la tabla esta rellena.
  IF gs_fichero-nombre IS NOT INITIAL.
    APPEND gs_fichero TO gi_fichero.
    CLEAR gs_fichero.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  BI_PROVEEDORES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM bi_proveedores .
  DATA: lv_mode(1) TYPE c VALUE 'N'.



* Llamo a la pantalla, relleno campos y ejecuto accion
  LOOP AT gi_fichero INTO gs_fichero.

    PERFORM bdc_dynpro USING 'SAPMF02K' '0100'.
    PERFORM bdc_field USING 'RF02K-REF_LIFNR' '4000000021'.
    PERFORM bdc_field USING 'BDC_OKCODE' '/00'.

* relleno campos
    PERFORM bdc_dynpro USING 'SAPMF02K' '0110'.
    PERFORM bdc_field USING 'LFA1-NAME1' gs_fichero-nombre.
    PERFORM bdc_field USING 'LFA1-STRAS' gs_fichero-calle.
    PERFORM bdc_field USING 'LFA1-ORT01' gs_fichero-poblacion.
    PERFORM bdc_field USING 'LFA1-PSTLZ' gs_fichero-c_p.
    PERFORM bdc_field USING 'LFA1-TELF'  gs_fichero-telefono.
    PERFORM bdc_field USING 'BDC_OKCODE' '/00'.

* Pulso grabar
    PERFORM bdc_dynpro USING 'SAPMF02K' '0120'.
    PERFORM bdc_field USING 'BDC_OKCODE' '=UPDA'.

    CALL TRANSACTION 'XK01' USING gi_bdcdata
                            MODE lv_mode  "A-visible E-Solo errores N-Invible
                            MESSAGES INTO gi_tabla_msg.


    READ TABLE gi_tabla_msg INTO gs_tabla_msg WITH KEY msgtyp = 'E'.
    IF sy-subrc = 0.
      gs_alv-nombre = gs_fichero-nombre.
      gs_alv-calle = gs_fichero-calle.
      gs_alv-poblacion = gs_fichero-poblacion.
      gs_alv-c_p = gs_fichero-c_p.
      gs_alv-telefono = gs_fichero-telefono.

      gs_alv-mensaje = 'El proveedor no se ha creado correctamente.'.
    ELSE.
      gs_alv-nombre = gs_fichero-nombre.
      gs_alv-calle = gs_fichero-calle.
      gs_alv-poblacion = gs_fichero-poblacion.
      gs_alv-c_p = gs_fichero-c_p.
      gs_alv-telefono = gs_fichero-telefono.

      gs_alv-mensaje = 'El proveedor se ha creado correctamente.'.
    ENDIF.
    APPEND gs_alv TO gi_alv.

*    LOOP AT gi_tabla_msg INTO gs_tabla_msg.
*
*      gs_alv-nombre = gs_fichero-nombre.
*      gs_alv-calle = gs_fichero-calle.
*      gs_alv-poblacion = gs_fichero-poblacion.
*      gs_alv-c_p = gs_fichero-c_p.
*      gs_alv-telefono = gs_fichero-telefono.
*
*      CALL FUNCTION 'MESSAGE_TEXT_BUILD'
*        EXPORTING
*          msgid               = gs_tabla_msg-msgid
*          msgnr               = gs_tabla_msg-msgnr
*          msgv1               = gs_tabla_msg-msgv1
*          msgv2               = gs_tabla_msg-msgv2
*          msgv3               = gs_tabla_msg-msgv3
*          msgv4               = gs_tabla_msg-msgv4
*        IMPORTING
*          message_text_output = gs_alv-mensaje.
*
*      APPEND gs_alv TO gi_alv.
*      CLEAR gs_alv.
** borramos elementos para siguiente iteracion.
*      REFRESH gi_bdcdata.
*      REFRESH gi_tabla_msg.
*    ENDLOOP.
  ENDLOOP.




ENDFORM.

*----------------------------------------------------------------------*
*        Start new screen                                              *
*----------------------------------------------------------------------*
FORM bdc_dynpro USING program dynpro.

  CLEAR gs_bdcdata.
  gs_bdcdata-program  = program.
  gs_bdcdata-dynpro   = dynpro.
  gs_bdcdata-dynbegin = 'X'.
  APPEND gs_bdcdata TO gi_bdcdata.

ENDFORM.
*----------------------------------------------------------------------*
*        Insert field                                                  *
*----------------------------------------------------------------------*
FORM bdc_field USING fnam fval.

  IF fval IS NOT INITIAL.
    CLEAR gs_bdcdata.
    gs_bdcdata-fnam = fnam.
    gs_bdcdata-fval = fval.
    APPEND gs_bdcdata TO gi_bdcdata.
  ENDIF.

ENDFORM.