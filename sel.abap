*&---------------------------------------------------------------------*
*& Include          ZCO016_I_SABIT_DEGISKEN_SEL
*&---------------------------------------------------------------------*
TABLES: ACDOCA, ZCO016_T_VARCONA.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS:
  s_gjahr FOR acdoca-gjahr,    "Fiscal Year
  s_rbukrs FOR acdoca-rbukrs,  "Company Code
  s_prctr FOR acdoca-PRCTR,    "Profit Center
  s_poper FOR acdoca-poper,    "Period
  s_racct FOR acdoca-racct.    "cost element

  PARAMETERS: p_actual TYPE char1 RADIOBUTTON GROUP gr1 USER-COMMAND o DEFAULT 'X',
              p_plan TYPE char1 RADIOBUTTON GROUP gr1.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-002.
  PARAMETERS:
  p_total TYPE char1 RADIOBUTTON GROUP gr2,
  p_unit TYPE char1 RADIOBUTTON GROUP gr2,
  p_acc_to TYPE char1 RADIOBUTTON GROUP gr2,
  p_acc_un TYPE char1 RADIOBUTTON GROUP gr2.
SELECTION-SCREEN END OF BLOCK b2.
