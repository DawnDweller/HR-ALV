*&---------------------------------------------------------------------*
*& Include          ZHR015_I_VERGI_BILGILERI_TOP
*&---------------------------------------------------------------------*
CONSTANTS:
           gt_structure1 type string value 'ZHR060_S_TOPLU_URETIM',
           gv_YG type ZHR060_E_YG_CONS value 'YG',
           gv_FL type ZHR060_E_FL_CONS value 'FL',
           gv_subty type ANZHL value '3695',
           gv_H type ZHR060_E_H_CONS value 'H',
           BEGIN OF ms_gui,
              status TYPE char7 VALUE 'STATUS_',
              title  TYPE char6 VALUE 'TITLE_',
           END OF ms_gui,
           BEGIN OF ms_scr,
              s0100 TYPE sy-dynnr VALUE '0100',
              s0101 TYPE sy-dynnr VALUE '0101',
           END OF ms_scr,
           BEGIN OF ms_ucomm,
              back   TYPE sy-ucomm VALUE 'EX001',
              leave  TYPE sy-ucomm VALUE 'EX002',
              exit   TYPE sy-ucomm VALUE 'EX003',
           END OF ms_ucomm,

           BEGIN OF ms_alv_components,
              fcat TYPE char10 VALUE 'FCAT',
              grid TYPE char10 VALUE 'GRID',
              cont TYPE char10 VALUE 'CONT',
              layo TYPE char10 VALUE 'LAYO',
              vari TYPE char10 VALUE 'VARI',
              sort TYPE char10 VALUE 'SORT',
              itab TYPE char10 VALUE 'ITAB',
           END OF ms_alv_components.


DATA: lv_titleInfo   TYPE lvc_title.
data gv_hire_date like P0000-BEGDA.
data gv_pernr LIKE  PERNR-PERNR.
TABLES :
  pernr. "p0001_af, p0002_af.

INFOTYPES: 0770,
           0002,
           0105,
           0009,
           0000,
           0014.
