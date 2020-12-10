*&---------------------------------------------------------------------*
*&  Include           Z2020_LISTAEQUIPOS_01_TOP
*&---------------------------------------------------------------------*

TABLES: z2020_equipos_01.  "Indicando que tablas de BBDD utilizaré

* DECLARACIONES
CONSTANTS: gc_x(1) TYPE c VALUE 'X'.

* Tipos
TYPES: BEGIN OF gt_equipos,
         equipo        TYPE z2020_equipos_01-equipo,
         clasificacion LIKE z2020_equipos_01-clasificacion,
         color         TYPE z2020_equipos_01-color,
       END OF gt_equipos.


DATA: gi_equipos TYPE STANDARD TABLE OF gt_equipos,
      gs_equipos TYPE gt_equipos.

* Declaraciones para log de errores
TYPES: BEGIN OF gt_errores,
         equipo           TYPE z2020_equipos_01-equipo,
         descripcion(100) TYPE c,
       END OF gt_errores.


DATA: gi_errores TYPE STANDARD TABLE OF gt_errores,
      gs_errores TYPE gt_errores.

* Declaraciones ALV
DATA: gi_fieldcat TYPE slis_t_fieldcat_alv,
      gs_layout   TYPE slis_layout_alv,
      gv_repid    LIKE sy-repid.