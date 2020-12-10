*&---------------------------------------------------------------------*
*& Report ZLISTACOCHES2020_00
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zlistacoches2020_00 MESSAGE-ID z2020_00_mensajes.

TABLES: z2020_00_coches.  "Indicando que tablas de BBDD utilizaré
* DECLARACIONES

CONSTANTS: gc_x(1) TYPE c VALUE 'X'.


* Tipos
TYPES: BEGIN OF gt_coches,
         matricula TYPE z2020_00_coches-matricula, "Declaracion con TYPE
         marca     LIKE z2020_00_coches-marca,     "Declaracion con LIKE
         modelo    TYPE zmarca,                    "Declaracion con Elem.Datos
         n_puertas LIKE z2020_00_coches-n_puertas,
       END OF gt_coches.

* Tablas Internas y Estructuras.
DATA: gi_coches TYPE STANDARD TABLE OF gt_coches.  "Tabla interna SIN CABECERA
DATA: gs_coches TYPE gt_coches.                    "Estructura (Work Area)

* Declaraciones para log de errores
TYPES: BEGIN OF gt_errores,
         matricula        TYPE z2020_00_coches-matricula, "Declaracion con TYPE
         descripcion(100) TYPE c,                         "Descr.Error
       END OF gt_errores.

* Tablas Internas y Estructuras.
DATA: gi_errores TYPE STANDARD TABLE OF gt_errores.  "Tabla interna SIN CABECERA
DATA: gs_errores TYPE gt_errores.                    "Estructura (Work Area)

* Declaraciones ALV
DATA: gi_fieldcat TYPE slis_t_fieldcat_alv,
      gs_layout   TYPE slis_layout_alv,
      gv_repid    LIKE sy-repid.


* PANTALLA DE SELECCION
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.

* Parametros

* Parametros de seleccion
PARAMETERS: p_ruta TYPE string. " Ruta para cargar la BBDD con fichero

SELECT-OPTIONS: s_matr FOR z2020_00_coches-matricula. "Rangos
*SELECT-OPTIONS: s_matr FOR z2020_00_coches-matricula NO INTERVALS NO-EXTENSION. "Rangos
SELECTION-SCREEN END OF BLOCK b1.


* Datos de salida / Tratamiento BBDD
SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-002.
PARAMETERS: r_opc1 RADIOBUTTON GROUP gr1, "Salida por pantalla
            r_opc2 RADIOBUTTON GROUP gr1, "Salida por fichero
            r_opc3 RADIOBUTTON GROUP gr1, "Cargar tabla
            r_opc4 RADIOBUTTON GROUP gr1, "Modificar Tabla
            r_opc5 RADIOBUTTON GROUP gr1. "Borrar tabla
SELECTION-SCREEN END OF BLOCK b2.


* Evento para comprobar la entrada de la pantalla de seleccion
AT SELECTION-SCREEN.

* Ruta obligatoria para carga y modificacion de BBDD
  IF ( r_opc3 IS NOT INITIAL OR r_opc4 IS NOT INITIAL ) AND
       p_ruta IS INITIAL. "Carga o modificacion de fichero + ruta vacía
    MESSAGE e004.
  ENDIF.

*  IF r_opc4 IS NOT INITIAL AND p_ruta IS INITIAL. "Carga de fichero + ruta vacía
*    MESSAGE e004.
*  ENDIF.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_ruta.
  PERFORM ventana_busqueda.


* LOGICA PRINCIPAL
START-OF-SELECTION.
  gv_repid = sy-repid.

  PERFORM logica_principal.


END-OF-SELECTION.
  IF r_opc1 IS NOT INITIAL OR r_opc2 IS NOT INITIAL. "Salida pantalla o fichero
    IF gi_coches[] IS INITIAL. "Si la tabla esta vacia
      MESSAGE s001.
    ELSE.
      PERFORM imprimir.
    ENDIF.
  ELSE. " Demas casos.
    " Si estoy en carga fichero
    PERFORM alv.


  ENDIF.

*
*
*
** SUBRUTINAS
**&---------------------------------------------------------------------*
**&      Form  LOGICA_PRINCIPAL
**&---------------------------------------------------------------------*
FORM logica_principal .


* Si selecciono mostrar por pantalla o fichero hago la seleccion
  IF r_opc1 IS NOT INITIAL OR r_opc2 IS NOT INITIAL.
* Obtener registros de la tabla BBDD.
    SELECT matricula marca modelo n_puertas     " Que campos quiero seleccionar
      FROM z2020_00_coches                      " De que tabla
      INTO TABLE gi_coches                      " Donde lo voy a guardar
      WHERE matricula IN s_matr.   " Filtro
    IF sy-subrc <> 0. " IF sy-subrc NE 0.
      REFRESH gi_coches.
    ENDIF.
    WRITE: / gs_coches-matricula, gs_coches-marca, gs_coches-modelo, gs_coches-n_puertas.
  ENDIF.

  IF r_opc3 IS NOT INITIAL.

    PERFORM cargar_tabla.

  ELSEIF r_opc4 IS NOT INITIAL.

    PERFORM modificar_tabla.

  ELSEIF r_opc5 IS NOT INITIAL.

    PERFORM borrar_tabla.

  ENDIF.



ENDFORM.
*
*&---------------------------------------------------------------------*
*&      Form  IMPRIMIR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM imprimir .

*  IF r_opc1 IS NOT INITIAL. "Salida por pantalla

  IF r_opc1 = gc_x. "Salida por pantalla

* Imprimir los registros por pantalla.
    LOOP AT gi_coches INTO gs_coches.
      WRITE: / gs_coches-matricula, gs_coches-marca, gs_coches-modelo, gs_coches-n_puertas.
    ENDLOOP.

  ELSE. "Salida por fichero
    PERFORM salida_fichero.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SALIDA_FICHERO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM salida_fichero .
  DATA: lv_filename TYPE string,
        lv_path     TYPE string,
        lv_fullpath TYPE string.


  CALL METHOD cl_gui_frontend_services=>file_save_dialog
    EXPORTING
      window_title              = 'Ruta fichero'
*     default_extension         =
      initial_directory         = 'C:\'
    CHANGING
      filename                  = lv_filename "Nombre del fichero
      path                      = lv_path     " Ruta
      fullpath                  = lv_fullpath "Ruta + Nombre del fichero
    EXCEPTIONS
      cntl_error                = 1
      error_no_gui              = 2
      not_supported_by_gui      = 3
      invalid_default_file_name = 4
      OTHERS                    = 5.
  IF sy-subrc <> 0.
* Implement suitable error handling here
    MESSAGE e002.
  ENDIF.


* Funcion que pasa de Tabla interna a Fichero
  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
*     BIN_FILESIZE            =
      filename                = lv_fullpath "Ruta del fichero
*     FILETYPE                = 'ASC'
    TABLES
      data_tab                = gi_coches
*     FIELDNAMES              =
    EXCEPTIONS
      file_write_error        = 1
      no_batch                = 2
      gui_refuse_filetransfer = 3
      invalid_type            = 4
      no_authority            = 5
      unknown_error           = 6
      header_not_allowed      = 7
      separator_not_allowed   = 8
      filesize_not_allowed    = 9
      header_too_long         = 10
      dp_error_create         = 11
      dp_error_send           = 12
      dp_error_write          = 13
      unknown_dp_error        = 14
      access_denied           = 15
      dp_out_of_memory        = 16
      disk_full               = 17
      dp_timeout              = 18
      file_not_found          = 19
      dataprovider_exception  = 20
      control_flush_error     = 21
      OTHERS                  = 22.
  IF sy-subrc <> 0.
* Implement suitable error handling here
    MESSAGE e003.
  ENDIF.



ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CARGAR_TABLA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM cargar_tabla .

* 1. Cargar tabla interna con FICHERO
  PERFORM leer_fichero.

* 2. Cargar la tabla interna con fichero

* INSERT MASIVO CON TABLA INTERNA
*  INSERT z2020_00_coches FROM TABLE gi_coches.

  LOOP AT gi_coches INTO gs_coches.

*   Compruebo si existe la matricula
    SELECT SINGLE matricula
           INTO gs_coches-matricula "Solo quiero saber si existe o no
           FROM z2020_00_coches
           WHERE matricula = gs_coches-matricula.
    IF sy-subrc NE  0. "No existe la matricula en la tabla
*  Rellenando la cabecera de la BBDD
      z2020_00_coches-mandt = sy-mandt.
      z2020_00_coches-matricula = gs_coches-matricula.
      z2020_00_coches-marca = gs_coches-marca.
      z2020_00_coches-modelo = gs_coches-modelo.
      z2020_00_coches-n_puertas = gs_coches-n_puertas.
      INSERT z2020_00_coches.

      gs_errores-matricula = gs_coches-matricula.
      gs_errores-descripcion = 'Matricula cargada correctamente'.
      APPEND gs_errores TO gi_errores.
      CLEAR gs_errores.

    ELSE. " Si existe la matricula la añade en el log de errores
      gs_errores-matricula = gs_coches-matricula.
      gs_errores-descripcion = 'Matricula ya existente'.

      APPEND gs_errores TO gi_errores.
      CLEAR gs_errores.
    ENDIF.

  ENDLOOP.

  COMMIT WORK AND WAIT.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MODIFICAR_TABLA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM modificar_tabla .
* 1. Cargar tabla interna con FICHERO
  PERFORM leer_fichero.

* 2. Modificar Tabla de BBDD
  LOOP AT gi_coches INTO gs_coches.
*   Compruebo si existe la matricula
    SELECT SINGLE matricula
           INTO gs_coches-matricula "Solo quiero saber si existe o no
           FROM z2020_00_coches
           WHERE matricula = gs_coches-matricula.
    IF sy-subrc EQ  0. "No existe la matricula en la tabla

      z2020_00_coches-mandt = sy-mandt.
      z2020_00_coches-matricula = gs_coches-matricula.
      z2020_00_coches-marca = gs_coches-marca.
      z2020_00_coches-modelo = gs_coches-modelo.
      z2020_00_coches-n_puertas = gs_coches-n_puertas.

      UPDATE z2020_00_coches.
      gs_errores-matricula = gs_coches-matricula.
      gs_errores-descripcion = 'Matricula modificada correctamente'.

      APPEND gs_errores TO gi_errores.
      CLEAR gs_errores.
    ELSE.
      gs_errores-matricula = gs_coches-matricula.
      gs_errores-descripcion = 'Matricula no existente'.

      APPEND gs_errores TO gi_errores.
      CLEAR gs_errores.
    ENDIF.
*    MODIFY z2020_00_coches.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  BORRAR_TABLA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM borrar_tabla .
  DATA: lv_answer(1) TYPE c.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar       = 'Borrado de BBDD'
      text_question  = '¿Esta seguro de que desea borrar la BBDD?'
      text_button_1  = 'SI'
      icon_button_1  = 'ICON_GREEN_LIGHT'
      text_button_2  = 'No'
      icon_button_2  = 'ICON_RED_LIGHT'
    IMPORTING
      answer         = lv_answer
    EXCEPTIONS
      text_not_found = 1
      OTHERS         = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  IF lv_answer = '1'.
    DELETE FROM z2020_00_coches
     WHERE matricula IN s_matr.

    MESSAGE s006.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  LEER_FICHERO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM leer_fichero .

  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename                = p_ruta
*     FILETYPE                = 'ASC'
*     HAS_FIELD_SEPARATOR     = ' '
    TABLES
      data_tab                = gi_coches
    EXCEPTIONS
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      OTHERS                  = 17.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  VENTANA_BUSQUEDA
*&---------------------------------------------------------------------*
*       text
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
*&      Form  ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM alv .

* Rellenamos el catalogo de campos.
  PERFORM catalogo_campos.
  PERFORM layout.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING                                 "Parametros de entrada
      i_callback_program = gv_repid
*     i_callback_top_of_page  = 'TOP-OF-PAGE' "Ver el perform TOP-OF-PAG
*     i_callback_user_command = 'USER_COMMAND'
      is_layout          = gs_layout
      it_fieldcat        = gi_fieldcat
    TABLES
      t_outtab           = gi_errores.
  IF sy-subrc <> 0.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CATALOGO_CAMPOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM catalogo_campos .
  DATA: ls_fieldcat LIKE LINE OF gi_fieldcat.
* Campo Matricula
  ls_fieldcat-fieldname = 'MATRICULA'.
  ls_fieldcat-seltext_l = 'Matricula'.
  ls_fieldcat-seltext_m = 'Matricula'.
  ls_fieldcat-seltext_s = 'Mat'.
  APPEND ls_fieldcat TO gi_fieldcat.
  CLEAR ls_fieldcat.

* Campo descripción
  ls_fieldcat-fieldname = 'DESCRIPCION'.
  ls_fieldcat-seltext_l = 'Descripcion'.
  ls_fieldcat-seltext_m = 'Descrip.'.
  ls_fieldcat-seltext_s = 'Descr'.
  APPEND ls_fieldcat TO gi_fieldcat.
  CLEAR ls_fieldcat.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  LAYOUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM layout .

  gs_layout-colwidth_optimize = 'X'.
  gs_layout-zebra = 'X'.

ENDFORM.