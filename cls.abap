*&---------------------------------------------------------------------*
*& Include          ZCO016_I_SABIT_DEGISKEN_CLS
*&---------------------------------------------------------------------*
CLASS lcl_main_controller DEFINITION CREATE PRIVATE FINAL.
  PUBLIC SECTION.

    CLASS-DATA:
      mt_main2          TYPE TABLE OF zco016_s_sabit_degisken2,
      mt_main           TYPE TABLE OF zco016_s_sabit_degisken2,
      gt_main_alv       TYPE TABLE OF zco016_s_sabit_degisken2,
      gt_main_alv_final TYPE TABLE OF zco016_s_sabit_degisken2,
      gt_710_alv        TYPE TABLE OF zco016_s_sabit_degisken2,
      gt_710            TYPE TABLE OF zco016_s_sabit_degisken2,
      gt_720_alv        TYPE TABLE OF zco016_s_sabit_degisken2,
      gt_720            TYPE TABLE OF zco016_s_sabit_degisken2,
      gt_730            TYPE TABLE OF zco016_s_sabit_degisken2,
      gt_730_alv        TYPE TABLE OF zco016_s_sabit_degisken2,
      gt_740            TYPE TABLE OF zco016_s_sabit_degisken2,
      gt_740_alv        TYPE TABLE OF zco016_s_sabit_degisken2,
      gt_750            TYPE TABLE OF zco016_s_sabit_degisken2,
      gt_750_alv        TYPE TABLE OF zco016_s_sabit_degisken2,
      gt_760            TYPE TABLE OF zco016_s_sabit_degisken2,
      gt_760_alv        TYPE TABLE OF zco016_s_sabit_degisken2,
      gt_770            TYPE TABLE OF zco016_s_sabit_degisken2,
      gt_770_alv        TYPE TABLE OF zco016_s_sabit_degisken2,
      gt_780            TYPE TABLE OF zco016_s_sabit_degisken2,
      gt_780_alv        TYPE TABLE OF zco016_s_sabit_degisken2,
      gt_790            TYPE TABLE OF zco016_s_sabit_degisken2,
      gt_790_alv        TYPE TABLE OF zco016_s_sabit_degisken2,
      gt_skat_alv       TYPE TABLE OF zco016_s_sabit_degisken2,



      BEGIN OF ms_alv,
        BEGIN OF s0100,
          cont TYPE REF TO cl_gui_custom_container,
        END OF s0100,

        BEGIN OF s0101,
          itab TYPE STANDARD TABLE OF zpp012_s_001,
          grid TYPE REF TO cl_gui_alv_grid,
          fcat TYPE lvc_t_fcat,
          layo TYPE lvc_s_layo,
          vari TYPE disvariant,
          sort TYPE lvc_t_sort,
        END OF s0101,
      END OF ms_alv.


    CLASS-METHODS:
      end_of_selection,
      get_data,
      pbo IMPORTING VALUE(iv_scrn) TYPE sy-dynnr,
      pai IMPORTING VALUE(iv_scrn) TYPE sy-dynnr,
      ext IMPORTING VALUE(iv_scrn) TYPE sy-dynnr,

      main_alv  IMPORTING VALUE(iv_scrn_alv)  TYPE sy-dynnr
                          VALUE(iv_scrn_cont) TYPE sy-dynnr,
      build_cont IMPORTING VALUE(iv_alv_name) TYPE scrfname
                 RETURNING VALUE(ro_cont)     TYPE REF TO cl_gui_custom_container,
      fill_main_fieldcat IMPORTING VALUE(iv_scrn) TYPE char4
                         RETURNING VALUE(rt_fcat) TYPE lvc_t_fcat,
      build_grid IMPORTING VALUE(io_cont) TYPE REF TO cl_gui_custom_container
                 RETURNING VALUE(ro_grid) TYPE REF TO cl_gui_alv_grid,
      build_layo IMPORTING VALUE(iv_scrn) TYPE char4
                 RETURNING VALUE(rs_layo) TYPE lvc_s_layo,
      build_vari IMPORTING VALUE(iv_scrn) TYPE char4
                 RETURNING VALUE(rs_vari) TYPE disvariant,
      fill_main_sort IMPORTING VALUE(iv_scrn) TYPE char4
                     RETURNING VALUE(rt_sort) TYPE lvc_t_sort.


  PRIVATE SECTION.



ENDCLASS.



CLASS lcl_main_controller IMPLEMENTATION.


  METHOD get_data.

    DATA lv_710_index TYPE sy-tabix.
    DATA lv_720_index TYPE sy-tabix.
    DATA lv_730_index TYPE sy-tabix.
    DATA lv_740_index TYPE sy-tabix.
    DATA lv_750_index TYPE sy-tabix.
    DATA lv_760_index TYPE sy-tabix.
    DATA lv_770_index TYPE sy-tabix.
    DATA lv_780_index TYPE sy-tabix.
    DATA lv_790_index TYPE sy-tabix.

TYPES: BEGIN OF ty_acdoca_sum,
       saknr type saknr,
       hsl type FINS_VHCUR12,
       ksl type FINS_VKCUR12,
       msl type QUAN1_12,
       END OF ty_acdoca_sum,

       BEGIN OF ty_acdoca_var,
       zskanr1 type saknr,
       hsl type FINS_VHCUR12,
       ksl type FINS_VKCUR12,
       END OF ty_acdoca_var,

       BEGIN OF ty_acdoca_cons,
       zskanr2 type saknr,
       hsl type FINS_VHCUR12,
       ksl type FINS_VKCUR12,
       END OF ty_acdoca_cons.

   data lt_acdoca_sum type TABLE OF ty_acdoca_sum.
   data lt_acdoca_sum2 type TABLE OF ty_acdoca_sum.
   data lt_acdoca_var type TABLE OF ty_acdoca_var.
   data lt_acdoca_var2 type TABLE OF ty_acdoca_var.
   data lt_acdoca_cons type TABLE OF ty_acdoca_cons.
   data lt_acdoca_cons2 type TABLE OF ty_acdoca_cons.

    SELECT
       sf~setname,
       st~descript,
        sf~valsign,
        sf~valoption,
        sf~valfrom,
        sf~valto
    FROM setleaf AS sf
      INNER JOIN setheadert AS st ON st~setname = sf~setname
    WHERE st~setname LIKE @gc_setname "'MC-7%'
    INTO TABLE @DATA(lt_setleaf2).


    DATA(lr_setleaf) = CORRESPONDING rseloption( lt_setleaf2 MAPPING sign = valsign option = valoption low = valfrom high = valto ).


    "Valoption BT and EQ
    SELECT
      lt_setleaf2~setname,
      lt_setleaf2~descript,
      skat~saknr,
      skat~txt50
      FROM skat AS skat
      INNER JOIN @lt_setleaf2 AS lt_setleaf2 ON lt_setleaf2~valfrom <= skat~saknr AND lt_setleaf2~valto >= skat~saknr
      WHERE saknr IN @lr_setleaf AND ktopl = @gc_ktopl "'NUHP'
      ORDER BY saknr
      INTO TABLE @DATA(gt_skat).



    """"""""""""""""""ACDOCA Total Amounts
    DATA(lv_rrcty0) = COND #( WHEN p_plan NE abap_true THEN '0' WHEN p_actual NE abap_true THEN '1' ).
    DATA(lv_rrcty2) = COND #( WHEN p_plan NE abap_true THEN '2' WHEN p_actual NE abap_true THEN '3' ).

    SELECT
      gt_skat~saknr,
      acdoca~hsl,
      acdoca~ksl,
      acdoca~msl
      FROM acdoca AS acdoca
      INNER JOIN @gt_skat AS gt_skat ON gt_skat~saknr = acdoca~racct
    WHERE ( rrcty = @lv_rrcty0 OR rrcty = @lv_rrcty2 ) AND rldnr = @gc_rldnr AND gjahr IN @s_gjahr " '0L'
      AND rbukrs IN @s_rbukrs AND poper IN @s_poper
      ORDER BY gt_skat~saknr
    INTO TABLE @lt_acdoca_sum.
   "Because there are not enough keys, I needed to merge SAKNRs.
    IF sy-subrc IS INITIAL.
      LOOP AT lt_acdoca_sum REFERENCE INTO DATA(gr_acdoca_sum)
                GROUP BY ( saknr = gr_acdoca_sum->saknr )
                REFERENCE INTO DATA(ls_saknr_grp).

        APPEND INITIAL LINE TO lt_acdoca_sum2 ASSIGNING FIELD-SYMBOL(<fs_acdoca_sum2>).
        <fs_acdoca_sum2>-saknr = ls_saknr_grp->saknr.

        LOOP AT GROUP ls_saknr_grp INTO DATA(ls_saknr_grp_s).
          <fs_acdoca_sum2>-hsl += ls_saknr_grp_s-hsl.
          <fs_acdoca_sum2>-ksl += ls_saknr_grp_s-ksl.
        ENDLOOP.
      ENDLOOP.
    ENDIF.

    "To find Total MSL
    LOOP AT lt_acdoca_sum REFERENCE INTO DATA(gf_acdoca_sum).
      gv_msl_sum += gf_acdoca_sum->msl.
    ENDLOOP.
    gv_msl_sum_quan = gv_msl_sum.


    """""""""""""""""""""ACDOCA Variable Amounts
    SELECT
      zco016_t_varcona~zskanr1,
      acdoca~hsl,
      acdoca~ksl
      FROM acdoca AS acdoca
      INNER JOIN zco016_t_varcona AS zco016_t_varcona ON zco016_t_varcona~zskanr1 = acdoca~racct
    WHERE ( rrcty = @lv_rrcty0 OR rrcty = @lv_rrcty2 ) AND rldnr = @gc_rldnr AND gjahr IN @s_gjahr
      AND rbukrs IN @s_rbukrs AND poper IN @s_poper
      ORDER BY zco016_t_varcona~zskanr1
    INTO TABLE @lt_acdoca_var.
    "Because there are not enough keys, I needed to merge zskanr1s.
    IF sy-subrc IS INITIAL.
      LOOP AT lt_acdoca_var REFERENCE INTO DATA(gr_acdoca_var)
                GROUP BY ( zskanr1 = gr_acdoca_var->zskanr1 )
                REFERENCE INTO DATA(ls_saknrvar_grp).

        APPEND INITIAL LINE TO lt_acdoca_var2 ASSIGNING FIELD-SYMBOL(<fs_acdoca_var2>).
        <fs_acdoca_var2>-zskanr1 = ls_saknrvar_grp->zskanr1.

        LOOP AT GROUP ls_saknrvar_grp INTO DATA(ls_saknrvar_grp_s).
          <fs_acdoca_var2>-hsl += ls_saknrvar_grp_s-hsl.
          <fs_acdoca_var2>-ksl += ls_saknrvar_grp_s-ksl.
        ENDLOOP.
      ENDLOOP.
    ENDIF.


    """""""""""""""""""""ACDOCA Constant Amounts
    SELECT
      zco016_t_varcona~zskanr2,
      acdoca~hsl,
      acdoca~ksl
      FROM acdoca AS acdoca
      INNER JOIN zco016_t_varcona AS zco016_t_varcona ON zco016_t_varcona~zskanr2 = acdoca~racct
    WHERE ( rrcty = @lv_rrcty0 OR rrcty = @lv_rrcty2 ) AND rldnr = @gc_rldnr AND gjahr IN @s_gjahr
      AND rbukrs IN @s_rbukrs AND poper IN @s_poper
      ORDER BY zco016_t_varcona~zskanr2
    INTO TABLE @lt_acdoca_cons.
    "Because there are not enough keys, I needed to merge zskanr2s.
    IF sy-subrc IS INITIAL.
      LOOP AT lt_acdoca_cons REFERENCE INTO DATA(gr_acdoca_cons)
                GROUP BY ( zskanr2 = gr_acdoca_cons->zskanr2 )
                REFERENCE INTO DATA(ls_saknrcons_grp).

        APPEND INITIAL LINE TO lt_acdoca_cons2 ASSIGNING FIELD-SYMBOL(<fs_acdoca_cons2>).
        <fs_acdoca_cons2>-zskanr2 = ls_saknrcons_grp->zskanr2.

        LOOP AT GROUP ls_saknrcons_grp INTO DATA(ls_saknrcons_grp_s).
          <fs_acdoca_cons2>-hsl += ls_saknrcons_grp_s-hsl.
          <fs_acdoca_cons2>-ksl += ls_saknrcons_grp_s-ksl.
        ENDLOOP.
      ENDLOOP.
    ENDIF.

    "MAIN CALCULATION
    LOOP AT gt_skat REFERENCE INTO data(lr_skat).
      DATA(lv_tabix) = sy-tabix.

      "SETNAME SUB-TOTAL
      IF lv_tabix = 1.
        DATA(lv_setname1) = lr_skat->setname.
      ENDIF.
      IF lv_setname1 <> lr_skat->setname.
        APPEND INITIAL LINE TO mt_main REFERENCE INTO DATA(lr_main).
        gv_n += 1.
        lr_main->zrowdex = gv_n.
        "coloring-Begins
        APPEND INITIAL LINE TO lr_main->scol ASSIGNING FIELD-SYMBOL(<fs_color1>).
        <fs_color1>-color-col = 5.
        "coloring-Ends

        LOOP AT mt_main REFERENCE INTO DATA(lr_main2) WHERE setname = lv_setname1.
          IF lt_acdoca_sum IS NOT INITIAL.
            lr_main->zhsl_sum += lr_main2->zhsl_sum.
            lr_main->zksl_sum += lr_main2->zksl_sum.
          ENDIF.
          IF lt_acdoca_var IS NOT INITIAL.
            lr_main->zhsl_var += lr_main2->zhsl_var.
            lr_main->zksl_var += lr_main2->zksl_var.
          ENDIF.
          IF lt_acdoca_cons IS NOT INITIAL.
            lr_main->zhsl_cons += lr_main2->zhsl_cons.
            lr_main->zksl_cons += lr_main2->zksl_cons.
          ENDIF.
        ENDLOOP.

        lr_main->txt50 = TEXT-003. "'Ara Toplam:'
        lr_main->descript = lv_setname1.
        lv_setname1 = lr_skat->setname.
      ENDIF.

      "SAKNR MERGE
      APPEND INITIAL LINE TO mt_main REFERENCE INTO lr_main.
      lr_main->setname = lr_skat->setname.
      lr_main->descript = lr_skat->descript.
      lr_main->saknr = lr_skat->saknr.
      lr_main->txt50 = lr_skat->txt50.

      IF lt_acdoca_sum IS NOT INITIAL.
        READ TABLE lt_acdoca_sum2 INTO DATA(ls_acdoca_sum2) WITH KEY saknr = lr_main->saknr BINARY SEARCH.
        IF p_total = abap_true OR p_acc_to = abap_true.
          lr_main->zhsl_sum = ls_acdoca_sum2-hsl.
          lr_main->zKsl_sum = ls_acdoca_sum2-ksl.
        ELSEIF p_unit = abap_true OR p_acc_un = abap_true.
          lr_main->zhsl_sum = ( ls_acdoca_sum2-hsl / gv_msl_sum ).
          lr_main->zKsl_sum = ( ls_acdoca_sum2-ksl / gv_msl_sum ).
        ENDIF.
      ENDIF.

      IF lt_acdoca_var IS NOT INITIAL.
        READ TABLE lt_acdoca_var2 INTO DATA(ls_acdoca_var2) WITH KEY zskanr1 = lr_main->saknr BINARY SEARCH.
        IF p_total = abap_true OR p_acc_to = abap_true.
          lr_main->zhsl_var = ls_acdoca_var2-hsl.
          lr_main->zKsl_var = ls_acdoca_var2-ksl.
        ELSEIF p_unit = abap_true OR p_acc_un = abap_true.
          lr_main->zhsl_var = ( ls_acdoca_var2-hsl / gv_msl_sum ).
          lr_main->zKsl_var = ( ls_acdoca_var2-ksl / gv_msl_sum ).
        ENDIF.
      ENDIF.

      IF lt_acdoca_cons IS NOT INITIAL.
        READ TABLE lt_acdoca_cons2 INTO DATA(ls_acdoca_cons2) WITH KEY zskanr2 = lr_main->saknr BINARY SEARCH.
        IF p_total = abap_true OR p_acc_to = abap_true.
          lr_main->zhsl_cons = ls_acdoca_cons2-hsl.
          lr_main->zksl_cons = ls_acdoca_cons2-ksl.
        ELSEIF p_unit = abap_true OR p_acc_un = abap_true.
          lr_main->zhsl_cons = ( ls_acdoca_cons2-hsl / gv_msl_sum ).
          lr_main->zksl_cons = ( ls_acdoca_cons2-ksl / gv_msl_sum ).
        ENDIF.
      ENDIF.


    ENDLOOP.

    "For the last SETNAME sumarization.
    APPEND INITIAL LINE TO mt_main REFERENCE INTO lr_main.
    gv_n += 1.
    lr_main->zrowdex = gv_n.
    "coloring-Begins
    APPEND INITIAL LINE TO lr_main->scol ASSIGNING <fs_color1>.
    <fs_color1>-color-col = 5.
    "coloring-Ends

    LOOP AT mt_main REFERENCE INTO lr_main2 WHERE setname = lv_setname1.
      IF lt_acdoca_sum IS NOT INITIAL.
        lr_main->zhsl_sum += lr_main2->zhsl_sum.
        lr_main->zksl_sum += lr_main2->zksl_sum.
      ENDIF.
      IF lt_acdoca_var IS NOT INITIAL.
        lr_main->zhsl_var += lr_main2->zhsl_var.
        lr_main->zksl_var += lr_main2->zksl_var.
      ENDIF.
      IF lt_acdoca_cons IS NOT INITIAL.
        lr_main->zhsl_cons += lr_main2->zhsl_cons.
        lr_main->zksl_cons += lr_main2->zksl_cons.
      ENDIF.
    ENDLOOP.

    lr_main->txt50 = TEXT-003. "'Ara Toplam:'
    lr_main->descript = lv_setname1.




    """""""""""""""""""""""""""""""""""MAIN ACOUNT TOTAL CALCULATION - BEGIN"""""""""""""""""""""""""""


    LOOP AT mt_main REFERENCE INTO lr_main
              GROUP BY ( setname = lr_main->setname )
              REFERENCE INTO DATA(ls_setname_main_grp).

      APPEND INITIAL LINE TO gt_main_alv ASSIGNING FIELD-SYMBOL(<fs_main_alv>).

      <fs_main_alv>-descript = ls_setname_main_grp->setname.


      LOOP AT GROUP ls_setname_main_grp INTO DATA(ls_setname_main_grp_s).
        <fs_main_alv>-zhsl_sum += ls_setname_main_grp_s-zhsl_sum.
        <fs_main_alv>-zhsl_var += ls_setname_main_grp_s-zhsl_var.
        <fs_main_alv>-zhsl_cons += ls_setname_main_grp_s-zhsl_cons.
        <fs_main_alv>-zksl_sum += ls_setname_main_grp_s-zksl_sum.
        <fs_main_alv>-zksl_var += ls_setname_main_grp_s-zksl_var.
        <fs_main_alv>-zksl_cons += ls_setname_main_grp_s-zksl_cons.
        <fs_main_alv>-zrowdex = ls_setname_main_grp_s-zrowdex.
        <fs_main_alv>-txt50 = COND #( WHEN p_total EQ abap_true OR p_unit EQ abap_true THEN TEXT-003 ). "'Ara Toplam:'
      ENDLOOP.
    ENDLOOP.


    """""SUM OF EVERTHING - LAST ROW"""""""""

    DELETE gt_main_alv WHERE zrowdex <> 0.

    LOOP AT gt_main_alv REFERENCE INTO DATA(gr_main_alv)
              GROUP BY ( setname = gr_main_alv->setname )
              REFERENCE INTO DATA(ls_setname_main_grp_final).

      APPEND INITIAL LINE TO gt_main_alv_final ASSIGNING FIELD-SYMBOL(<fs_main_alv_final>).

      <fs_main_alv_final>-setname = ls_setname_main_grp_final->setname.

      LOOP AT GROUP ls_setname_main_grp_final INTO DATA(ls_setname_main_grp_final_s).
        <fs_main_alv_final>-zhsl_sum += ls_setname_main_grp_final_s-zhsl_sum.
        <fs_main_alv_final>-zhsl_var += ls_setname_main_grp_final_s-zhsl_var.
        <fs_main_alv_final>-zhsl_cons += ls_setname_main_grp_final_s-zhsl_cons.
        <fs_main_alv_final>-zksl_sum += ls_setname_main_grp_final_s-zksl_sum.
        <fs_main_alv_final>-zksl_var += ls_setname_main_grp_final_s-zksl_var.
        <fs_main_alv_final>-zksl_cons += ls_setname_main_grp_final_s-zksl_cons.
        <fs_main_alv_final>-descript = TEXT-016. "'GENEL TOPLAM:'
        CLEAR: <fs_main_alv_final>-txt50, <fs_main_alv_final>-setname.
      ENDLOOP.
    ENDLOOP.

    LOOP AT gt_main_alv_final ASSIGNING <fs_main_alv_final>.
      APPEND INITIAL LINE TO <fs_main_alv_final>-scol ASSIGNING FIELD-SYMBOL(<fs_color_final>).
      CASE <fs_main_alv_final>-zrowdex.
        WHEN  <fs_main_alv_final>-zrowdex.
          <fs_color_final>-color-col = 6.
      ENDCASE.
    ENDLOOP.

*    IF gt_main_alv IS NOT INITIAL.
    IF gt_main_alv IS NOT INITIAL.
      APPEND gt_main_alv_final[ 1 ] TO mt_main.
      APPEND gt_main_alv_final[ 1 ] TO gt_main_alv. "In case of other p_acc_to or p_acc_un are abap_true.
    ENDIF.

    """""""""""""""""""""""""""""""""""MAIN ACOUNT TOTAL CALCULATION - END"""""""""""""""""""""""""""



    """""""""""""""""""""""""""""""""""""""""SUB-TOTAL ACCOUNT_BEGIN"""""""""""""""""""""""""""""""""""""""""""""""""""
    "Account Sub-Totals
    "710
    SELECT
      mt_main~saknr,
      mt_main~txt50,
      mt_main~zhsl_sum,
      mt_main~zhsl_var,
      mt_main~zhsl_cons,
      mt_main~zksl_sum,
      mt_main~zksl_var,
      mt_main~zksl_cons
      FROM @mt_main AS mt_main
      WHERE saknr LIKE '710%'
      INTO CORRESPONDING FIELDS OF TABLE @gt_710.
    IF sy-subrc IS INITIAL.
      LOOP AT gt_710 REFERENCE INTO DATA(ls_710_tmp)
            GROUP BY ( setname = ls_710_tmp->setname )
            REFERENCE INTO DATA(ls_setname710_grp).

        APPEND INITIAL LINE TO gt_710_alv ASSIGNING FIELD-SYMBOL(<fs_710_alv>).

        <fs_710_alv>-setname = ls_setname710_grp->setname.

        LOOP AT GROUP ls_setname710_grp INTO DATA(ls_setname710_grp_s).
          <fs_710_alv>-zhsl_sum += ls_setname710_grp_s-zhsl_sum.
          <fs_710_alv>-zhsl_var += ls_setname710_grp_s-zhsl_var.
          <fs_710_alv>-zhsl_cons += ls_setname710_grp_s-zhsl_cons.
          <fs_710_alv>-zksl_sum += ls_setname710_grp_s-zksl_sum.
          <fs_710_alv>-zksl_var += ls_setname710_grp_s-zksl_var.
          <fs_710_alv>-zksl_cons += ls_setname710_grp_s-zksl_cons.
          <fs_710_alv>-saknr = TEXT-004. "'Grup Adı:'
          <fs_710_alv>-txt50 = TEXT-005. "'710'
          lv_710_index = sy-tabix.
        ENDLOOP.
      ENDLOOP.
      "Coloring
      LOOP AT gt_710_alv ASSIGNING <fs_710_alv>.
        APPEND INITIAL LINE TO <fs_710_alv>-scol ASSIGNING FIELD-SYMBOL(<fs_710color>).
        CASE <fs_710_alv>-zrowdex.
          WHEN  <fs_710_alv>-zrowdex.
            <fs_710color>-color-col = 7.
        ENDCASE.
      ENDLOOP.
      lv_710_index += 1.
      INSERT <fs_710_alv> INTO mt_main INDEX ( lv_710_index ).
      lv_710_index += 1.
    ENDIF.


    "720
    SELECT
    mt_main~saknr,
    mt_main~txt50,
    mt_main~zhsl_sum,
    mt_main~zhsl_var,
    mt_main~zhsl_cons,
    mt_main~zksl_sum,
    mt_main~zksl_var,
    mt_main~zksl_cons
    FROM @mt_main AS mt_main
    WHERE saknr LIKE '720%'
    INTO CORRESPONDING FIELDS OF TABLE @gt_720.
    IF sy-subrc IS INITIAL.
      LOOP AT gt_720 REFERENCE INTO DATA(ls_720_tmp)
            GROUP BY ( setname = ls_720_tmp->setname )
            REFERENCE INTO DATA(ls_setname720_grp).

        APPEND INITIAL LINE TO gt_720_alv ASSIGNING FIELD-SYMBOL(<fs_720_alv>).

        <fs_720_alv>-setname = ls_setname720_grp->setname.

        LOOP AT GROUP ls_setname720_grp INTO DATA(ls_setname720_grp_s).
          <fs_720_alv>-zhsl_sum += ls_setname720_grp_s-zhsl_sum.
          <fs_720_alv>-zhsl_var += ls_setname720_grp_s-zhsl_var.
          <fs_720_alv>-zhsl_cons += ls_setname720_grp_s-zhsl_cons.
          <fs_720_alv>-zksl_sum += ls_setname720_grp_s-zksl_sum.
          <fs_720_alv>-zksl_var += ls_setname720_grp_s-zksl_var.
          <fs_720_alv>-zksl_cons += ls_setname720_grp_s-zksl_cons.
          <fs_720_alv>-saknr = TEXT-004. "'Grup Adı:'
          <fs_720_alv>-txt50 = TEXT-006. "'720'
          lv_720_index = sy-tabix + lv_710_index.
        ENDLOOP.
      ENDLOOP.
      "Coloring
      LOOP AT gt_720_alv ASSIGNING <fs_720_alv>.
        APPEND INITIAL LINE TO <fs_720_alv>-scol ASSIGNING FIELD-SYMBOL(<fs_720color>).
        CASE <fs_720_alv>-zrowdex.
          WHEN  <fs_720_alv>-zrowdex.
            <fs_720color>-color-col = 7.
        ENDCASE.
      ENDLOOP.
      lv_720_index += 1.
      INSERT <fs_720_alv> INTO mt_main INDEX ( lv_720_index ).
      lv_720_index += 1.
    ENDIF.


    "730
    SELECT
    mt_main~saknr,
    mt_main~txt50,
    mt_main~zhsl_sum,
    mt_main~zhsl_var,
    mt_main~zhsl_cons,
    mt_main~zksl_sum,
    mt_main~zksl_var,
    mt_main~zksl_cons
    FROM @mt_main AS mt_main
    WHERE saknr LIKE '730%'
    INTO CORRESPONDING FIELDS OF TABLE @gt_730.
    IF sy-subrc IS INITIAL.
      LOOP AT gt_730 REFERENCE INTO DATA(ls_730_tmp)
            GROUP BY ( setname = ls_730_tmp->setname )
            REFERENCE INTO DATA(ls_setname730_grp).

        APPEND INITIAL LINE TO gt_730_alv ASSIGNING FIELD-SYMBOL(<fs_730_alv>).

        <fs_730_alv>-setname = ls_setname730_grp->setname.

        LOOP AT GROUP ls_setname730_grp INTO DATA(ls_setname730_grp_s).
          <fs_730_alv>-zhsl_sum += ls_setname730_grp_s-zhsl_sum.
          <fs_730_alv>-zhsl_var += ls_setname730_grp_s-zhsl_var.
          <fs_730_alv>-zhsl_cons += ls_setname730_grp_s-zhsl_cons.
          <fs_730_alv>-zksl_sum += ls_setname730_grp_s-zksl_sum.
          <fs_730_alv>-zksl_var += ls_setname730_grp_s-zksl_var.
          <fs_730_alv>-zksl_cons += ls_setname730_grp_s-zksl_cons.
          <fs_730_alv>-saknr = TEXT-004. "'Grup Adı:'
          <fs_730_alv>-txt50 = TEXT-007.  "'730'
          lv_730_index = sy-tabix + lv_720_index.
        ENDLOOP.
      ENDLOOP.
      "Coloring
      LOOP AT gt_730_alv ASSIGNING <fs_730_alv>.
        APPEND INITIAL LINE TO <fs_730_alv>-scol ASSIGNING FIELD-SYMBOL(<fs_730color>).
        CASE <fs_730_alv>-zrowdex.
          WHEN  <fs_730_alv>-zrowdex.
            <fs_730color>-color-col = 7.
        ENDCASE.
      ENDLOOP.
      lv_730_index += 1.
      INSERT <fs_730_alv> INTO mt_main INDEX ( lv_730_index ).
      lv_730_index += 1.
    ENDIF.

    "740
    SELECT
    mt_main~saknr,
    mt_main~txt50,
    mt_main~zhsl_sum,
    mt_main~zhsl_var,
    mt_main~zhsl_cons,
    mt_main~zksl_sum,
    mt_main~zksl_var,
    mt_main~zksl_cons
    FROM @mt_main AS mt_main
    WHERE saknr LIKE '740%'
    INTO CORRESPONDING FIELDS OF TABLE @gt_740.
    IF sy-subrc IS INITIAL.
      LOOP AT gt_740 REFERENCE INTO DATA(ls_740_tmp)
            GROUP BY ( setname = ls_740_tmp->setname )
            REFERENCE INTO DATA(ls_setname740_grp).

        APPEND INITIAL LINE TO gt_740_alv ASSIGNING FIELD-SYMBOL(<fs_740_alv>).

        <fs_740_alv>-setname = ls_setname740_grp->setname.

        LOOP AT GROUP ls_setname740_grp INTO DATA(ls_setname740_grp_s).
          <fs_740_alv>-zhsl_sum += ls_setname740_grp_s-zhsl_sum.
          <fs_740_alv>-zhsl_var += ls_setname740_grp_s-zhsl_var.
          <fs_740_alv>-zhsl_cons += ls_setname740_grp_s-zhsl_cons.
          <fs_740_alv>-zksl_sum += ls_setname740_grp_s-zksl_sum.
          <fs_740_alv>-zksl_var += ls_setname740_grp_s-zksl_var.
          <fs_740_alv>-zksl_cons += ls_setname740_grp_s-zksl_cons.
          <fs_740_alv>-saknr = TEXT-004. "'Grup Adı:'
          <fs_740_alv>-txt50 = TEXT-008. "'740'
          lv_740_index = sy-tabix + lv_720_index.
        ENDLOOP.
      ENDLOOP.

      "Coloring
      LOOP AT gt_740_alv ASSIGNING <fs_740_alv>.
        APPEND INITIAL LINE TO <fs_740_alv>-scol ASSIGNING FIELD-SYMBOL(<fs_740color>).
        CASE <fs_740_alv>-zrowdex.
          WHEN  <fs_740_alv>-zrowdex.
            <fs_740color>-color-col = 7.
        ENDCASE.
      ENDLOOP.
      lv_740_index += 1.
      INSERT <fs_740_alv> INTO mt_main INDEX ( lv_740_index ).
      lv_740_index += 1.
    ENDIF.


    "750
    SELECT
    mt_main~saknr,
    mt_main~txt50,
    mt_main~zhsl_sum,
    mt_main~zhsl_var,
    mt_main~zhsl_cons,
    mt_main~zksl_sum,
    mt_main~zksl_var,
    mt_main~zksl_cons
    FROM @mt_main AS mt_main
    WHERE saknr LIKE '750%'
    INTO CORRESPONDING FIELDS OF TABLE @gt_750.
    IF sy-subrc IS INITIAL.
      LOOP AT gt_750 REFERENCE INTO DATA(ls_750_tmp)
            GROUP BY ( setname = ls_750_tmp->setname )
            REFERENCE INTO DATA(ls_setname750_grp).

        APPEND INITIAL LINE TO gt_750_alv ASSIGNING FIELD-SYMBOL(<fs_750_alv>).

        <fs_750_alv>-setname = ls_setname750_grp->setname.

        LOOP AT GROUP ls_setname750_grp INTO DATA(ls_setname750_grp_s).
          <fs_750_alv>-zhsl_sum += ls_setname750_grp_s-zhsl_sum.
          <fs_750_alv>-zhsl_var += ls_setname750_grp_s-zhsl_var.
          <fs_750_alv>-zhsl_cons += ls_setname750_grp_s-zhsl_cons.
          <fs_750_alv>-zksl_sum += ls_setname750_grp_s-zksl_sum.
          <fs_750_alv>-zksl_var += ls_setname750_grp_s-zksl_var.
          <fs_750_alv>-zksl_cons += ls_setname750_grp_s-zksl_cons.
          <fs_750_alv>-saknr = TEXT-004. "'Grup Adı:'
          <fs_750_alv>-txt50 = TEXT-009. "'750'
          lv_750_index = sy-tabix + lv_740_index.
        ENDLOOP.
      ENDLOOP.
      "Coloring
      LOOP AT gt_750_alv ASSIGNING <fs_750_alv>.
        APPEND INITIAL LINE TO <fs_750_alv>-scol ASSIGNING FIELD-SYMBOL(<fs_750color>).
        CASE <fs_750_alv>-zrowdex.
          WHEN  <fs_750_alv>-zrowdex.
            <fs_750color>-color-col = 7.
        ENDCASE.
      ENDLOOP.
      lv_750_index += 1.
      INSERT <fs_750_alv> INTO mt_main INDEX ( lv_750_index ).
      lv_750_index += 1.
    ENDIF.


    "760
    SELECT
    mt_main~saknr,
    mt_main~txt50,
    mt_main~zhsl_sum,
    mt_main~zhsl_var,
    mt_main~zhsl_cons,
    mt_main~zksl_sum,
    mt_main~zksl_var,
    mt_main~zksl_cons
    FROM @mt_main AS mt_main
    WHERE saknr LIKE '760%'
    INTO CORRESPONDING FIELDS OF TABLE @gt_760.
    IF sy-subrc IS INITIAL.
      LOOP AT gt_760 REFERENCE INTO DATA(ls_760_tmp)
            GROUP BY ( setname = ls_760_tmp->setname )
            REFERENCE INTO DATA(ls_setname760_grp).

        APPEND INITIAL LINE TO gt_760_alv ASSIGNING FIELD-SYMBOL(<fs_760_alv>).

        <fs_760_alv>-setname = ls_setname760_grp->setname.

        LOOP AT GROUP ls_setname760_grp INTO DATA(ls_setname760_grp_s).
          <fs_760_alv>-zhsl_sum += ls_setname760_grp_s-zhsl_sum.
          <fs_760_alv>-zhsl_var += ls_setname760_grp_s-zhsl_var.
          <fs_760_alv>-zhsl_cons += ls_setname760_grp_s-zhsl_cons.
          <fs_760_alv>-zksl_sum += ls_setname760_grp_s-zksl_sum.
          <fs_760_alv>-zksl_var += ls_setname760_grp_s-zksl_var.
          <fs_760_alv>-zksl_cons += ls_setname760_grp_s-zksl_cons.
          <fs_760_alv>-saknr = TEXT-004. "'Grup Adı:'
          <fs_760_alv>-txt50 = TEXT-010. "'760'
          lv_760_index = sy-tabix + lv_750_index.
        ENDLOOP.
      ENDLOOP.
      "Coloring
      LOOP AT gt_760_alv ASSIGNING <fs_760_alv>.
        APPEND INITIAL LINE TO <fs_760_alv>-scol ASSIGNING FIELD-SYMBOL(<fs_760color>).
        CASE <fs_760_alv>-zrowdex.
          WHEN  <fs_760_alv>-zrowdex.
            <fs_760color>-color-col = 7.
        ENDCASE.
      ENDLOOP.
      lv_760_index += 1.
      INSERT <fs_760_alv> INTO mt_main INDEX ( lv_760_index ).
      lv_760_index += 1.
    ENDIF.


    "770
    SELECT
    mt_main~saknr,
    mt_main~txt50,
    mt_main~zhsl_sum,
    mt_main~zhsl_var,
    mt_main~zhsl_cons,
    mt_main~zksl_sum,
    mt_main~zksl_var,
    mt_main~zksl_cons
    FROM @mt_main AS mt_main
    WHERE saknr LIKE '770%'
    INTO CORRESPONDING FIELDS OF TABLE @gt_770.
    IF sy-subrc IS INITIAL.
      LOOP AT gt_770 REFERENCE INTO DATA(ls_770_tmp)
            GROUP BY ( setname = ls_770_tmp->setname )
            REFERENCE INTO DATA(ls_setname770_grp).

        APPEND INITIAL LINE TO gt_770_alv ASSIGNING FIELD-SYMBOL(<fs_770_alv>).

        <fs_770_alv>-setname = ls_setname770_grp->setname.

        LOOP AT GROUP ls_setname770_grp INTO DATA(ls_setname770_grp_s).
          <fs_770_alv>-zhsl_sum += ls_setname770_grp_s-zhsl_sum.
          <fs_770_alv>-zhsl_var += ls_setname770_grp_s-zhsl_var.
          <fs_770_alv>-zhsl_cons += ls_setname770_grp_s-zhsl_cons.
          <fs_770_alv>-zksl_sum += ls_setname770_grp_s-zksl_sum.
          <fs_770_alv>-zksl_var += ls_setname770_grp_s-zksl_var.
          <fs_770_alv>-zksl_cons += ls_setname770_grp_s-zksl_cons.
          <fs_770_alv>-saknr = TEXT-004. "'Grup Adı:'
          <fs_770_alv>-txt50 = TEXT-011. "'770'
          lv_770_index = sy-tabix + lv_760_index.
        ENDLOOP.
      ENDLOOP.
      "Coloring
      LOOP AT gt_770_alv ASSIGNING <fs_770_alv>.
        APPEND INITIAL LINE TO <fs_770_alv>-scol ASSIGNING FIELD-SYMBOL(<fs_770color>).
        CASE <fs_770_alv>-zrowdex.
          WHEN  <fs_770_alv>-zrowdex.
            <fs_770color>-color-col = 7.
        ENDCASE.
      ENDLOOP.
      lv_770_index += 1.
      INSERT <fs_770_alv> INTO mt_main INDEX ( lv_770_index ).
      lv_770_index += 1.
    ENDIF.


    "780
    SELECT
    mt_main~saknr,
    mt_main~txt50,
    mt_main~zhsl_sum,
    mt_main~zhsl_var,
    mt_main~zhsl_cons,
    mt_main~zksl_sum,
    mt_main~zksl_var,
    mt_main~zksl_cons
    FROM @mt_main AS mt_main
    WHERE saknr LIKE '780%'
    INTO CORRESPONDING FIELDS OF TABLE @gt_780.
    IF sy-subrc IS INITIAL.
      LOOP AT gt_780 REFERENCE INTO DATA(ls_780_tmp)
            GROUP BY ( setname = ls_780_tmp->setname )
            REFERENCE INTO DATA(ls_setname780_grp).

        APPEND INITIAL LINE TO gt_780_alv ASSIGNING FIELD-SYMBOL(<fs_780_alv>).

        <fs_780_alv>-setname = ls_setname780_grp->setname.

        LOOP AT GROUP ls_setname780_grp INTO DATA(ls_setname780_grp_s).
          <fs_780_alv>-zhsl_sum += ls_setname780_grp_s-zhsl_sum.
          <fs_780_alv>-zhsl_var += ls_setname780_grp_s-zhsl_var.
          <fs_780_alv>-zhsl_cons += ls_setname780_grp_s-zhsl_cons.
          <fs_780_alv>-zksl_sum += ls_setname780_grp_s-zksl_sum.
          <fs_780_alv>-zksl_var += ls_setname780_grp_s-zksl_var.
          <fs_780_alv>-zksl_cons += ls_setname780_grp_s-zksl_cons.
          <fs_780_alv>-saknr = TEXT-004. "'Grup Adı:'
          <fs_780_alv>-txt50 = TEXT-012. "'780'
          lv_780_index = sy-tabix + lv_770_index.
        ENDLOOP.
      ENDLOOP.
      "Coloring
      LOOP AT gt_780_alv ASSIGNING <fs_780_alv>.
        APPEND INITIAL LINE TO <fs_780_alv>-scol ASSIGNING FIELD-SYMBOL(<fs_780color>).
        CASE <fs_780_alv>-zrowdex.
          WHEN  <fs_780_alv>-zrowdex.
            <fs_780color>-color-col = 7.
        ENDCASE.
      ENDLOOP.
      lv_780_index += 1.
      INSERT <fs_780_alv> INTO mt_main INDEX ( lv_780_index ).
      lv_780_index += 1.
    ENDIF.

    "790
    SELECT
    mt_main~saknr,
    mt_main~txt50,
    mt_main~zhsl_sum,
    mt_main~zhsl_var,
    mt_main~zhsl_cons,
    mt_main~zksl_sum,
    mt_main~zksl_var,
    mt_main~zksl_cons
    FROM @mt_main AS mt_main
    WHERE saknr LIKE '790%'
    INTO CORRESPONDING FIELDS OF TABLE @gt_790.
    IF sy-subrc IS INITIAL.
      LOOP AT gt_790 REFERENCE INTO DATA(ls_790_tmp)
            GROUP BY ( setname = ls_790_tmp->setname )
            REFERENCE INTO DATA(ls_setname790_grp).

        APPEND INITIAL LINE TO gt_790_alv ASSIGNING FIELD-SYMBOL(<fs_790_alv>).

        <fs_790_alv>-setname = ls_setname790_grp->setname.

        LOOP AT GROUP ls_setname790_grp INTO DATA(ls_setname790_grp_s).
          <fs_790_alv>-zhsl_sum += ls_setname790_grp_s-zhsl_sum.
          <fs_790_alv>-zhsl_var += ls_setname790_grp_s-zhsl_var.
          <fs_790_alv>-zhsl_cons += ls_setname790_grp_s-zhsl_cons.
          <fs_790_alv>-zksl_sum += ls_setname790_grp_s-zksl_sum.
          <fs_790_alv>-zksl_var += ls_setname790_grp_s-zksl_var.
          <fs_790_alv>-zksl_cons += ls_setname790_grp_s-zksl_cons.
          <fs_790_alv>-saknr = TEXT-004. "'Grup Adı:'
          <fs_790_alv>-txt50 = TEXT-013. "'790'
          lv_790_index = sy-tabix + lv_780_index.
        ENDLOOP.
      ENDLOOP.
      "Coloring
      LOOP AT gt_790_alv ASSIGNING <fs_790_alv>.
        APPEND INITIAL LINE TO <fs_790_alv>-scol ASSIGNING FIELD-SYMBOL(<fs_790color>).
        CASE <fs_790_alv>-zrowdex.
          WHEN  <fs_790_alv>-zrowdex.
            <fs_790color>-color-col = 7.
        ENDCASE.
      ENDLOOP.
      lv_790_index += 1.
      INSERT <fs_790_alv> INTO mt_main INDEX ( lv_790_index ).
      lv_790_index += 1.
    ENDIF.
    """""""""""""""""""""""""""""""""""""""""SUB-TOTAL ACCOUNT_END"""""""""""""""""""""""""""""""""""""""""""""""""""




  ENDMETHOD.



  METHOD end_of_selection.
    CALL SCREEN 0100.
  ENDMETHOD.



  METHOD main_alv.


    DATA lt_exclude TYPE ui_functions.
    FIELD-SYMBOLS : <lo_grid> TYPE REF TO cl_gui_alv_grid,
                    <lo_prnt> TYPE REF TO cl_gui_container,
                    <lo_cont> TYPE REF TO cl_gui_custom_container.

    DATA(lv_str_alv) = 'S' && iv_scrn_alv.
    ASSIGN COMPONENT lv_str_alv OF STRUCTURE ms_alv TO FIELD-SYMBOL(<ls_alv>).
    IF <ls_alv> IS ASSIGNED.
      ASSIGN COMPONENT ms_alv_components-grid OF STRUCTURE <ls_alv> TO <lo_grid>.
      IF <lo_grid> IS ASSIGNED.


        "GRID INITIAL CONTROL if it is bound then flush( ).
        IF <lo_grid> IS NOT BOUND.
          "GRID
          DATA(lv_str_gui) = 'S' && iv_scrn_cont.
          ASSIGN COMPONENT lv_str_gui OF STRUCTURE ms_alv TO FIELD-SYMBOL(<ls_gui>).
          IF <ls_gui> IS ASSIGNED.
            ASSIGN COMPONENT ms_alv_components-cont OF STRUCTURE <ls_gui> TO <lo_cont>.
            IF <lo_cont> IS ASSIGNED.
              <lo_grid> = build_grid( io_cont = <lo_cont> ).
            ENDIF.
          ENDIF.


          "FCAT
          ASSIGN COMPONENT ms_alv_components-fcat OF STRUCTURE <ls_alv> TO FIELD-SYMBOL(<lt_fcat>).
          IF <lt_fcat> IS ASSIGNED.
            CLEAR : <lt_fcat>.
            <lt_fcat> = fill_main_fieldcat( iv_scrn = iv_scrn_alv ).
          ENDIF.

          "LAYOUT
          ASSIGN COMPONENT ms_alv_components-layo OF STRUCTURE <ls_alv> TO FIELD-SYMBOL(<ls_layo>).
          IF <ls_layo> IS ASSIGNED.
            CLEAR : <ls_layo>.
            <ls_layo> = build_layo( iv_scrn = iv_scrn_alv ).
          ENDIF.

          "VARIANT
          ASSIGN COMPONENT ms_alv_components-vari OF STRUCTURE <ls_alv> TO FIELD-SYMBOL(<ls_vari>).
          IF <ls_vari> IS ASSIGNED.
            CLEAR : <ls_vari>.
            <ls_vari> = build_vari( iv_scrn = iv_scrn_alv ).
          ENDIF.

          "SORT
          ASSIGN COMPONENT ms_alv_components-sort OF STRUCTURE <ls_alv> TO FIELD-SYMBOL(<lt_sort>).
          IF <lt_sort> IS ASSIGNED.
            CLEAR : <lt_sort>.
            <lt_sort> = fill_main_sort( iv_scrn = iv_scrn_alv ).
          ENDIF.


          CHECK sy-subrc IS INITIAL.

          "ALV
          ASSIGN COMPONENT ms_alv_components-itab OF STRUCTURE <ls_alv> TO FIELD-SYMBOL(<lt_itab>).
          IF <lt_itab> IS ASSIGNED.



            mt_main = COND #( WHEN p_acc_to EQ abap_true OR p_acc_un EQ abap_true THEN gt_main_alv ELSE mt_main ).
            ASSIGN mt_main TO <lt_itab>.


            CALL METHOD <lo_grid>->set_table_for_first_display
              EXPORTING
                i_buffer_active               = abap_true
                is_layout                     = <ls_layo>
                i_save                        = 'A'
                it_toolbar_excluding          = lt_exclude
              CHANGING
                it_outtab                     = <lt_itab>
                it_fieldcatalog               = <lt_fcat>
                it_sort                       = <lt_sort>
              EXCEPTIONS
                invalid_parameter_combination = 1
                program_error                 = 2
                too_many_lines                = 3
                OTHERS                        = 4.

            IF sy-subrc <> 0.
              MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            ENDIF.
          ENDIF.
        ELSE.
          cl_gui_cfw=>flush( ).
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.



  METHOD build_grid.

    CREATE OBJECT ro_grid
      EXPORTING
        i_parent = io_cont.

  ENDMETHOD.

  METHOD build_layo.
    rs_layo-grid_title = |{ Text-014 } { gv_msl_sum_quan } { Text-015 }|.
    rs_layo-zebra = abap_true.
    rs_layo-sel_mode   = 'A'.
    rs_layo-col_opt = abap_true.
    rs_layo-cwidth_opt = abap_true.
    rs_layo-ctab_fname = 'SCOL'.

    CASE iv_scrn.
      WHEN ms_scr-s0101.
        rs_layo-no_rowmark = abap_true.
    ENDCASE.


  ENDMETHOD.

  METHOD build_vari.

    CASE iv_scrn.
      WHEN ms_scr-s0101.
        rs_vari = VALUE #( report = sy-repid username = sy-uname handle = iv_scrn ).
    ENDCASE.

  ENDMETHOD.





  METHOD fill_main_fieldcat.
    DATA: lv_fname     TYPE lvc_fname,
          lv_offset    TYPE i,
          lv_structure TYPE dd02l-tabname.


    lv_structure = gt_structure1.


    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        i_structure_name       = lv_structure
        i_bypassing_buffer     = abap_true
      CHANGING
        ct_fieldcat            = rt_fcat
      EXCEPTIONS
        inconsistent_interface = 1
        program_error          = 2
        OTHERS                 = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

  ENDMETHOD.


  METHOD fill_main_sort.
  ENDMETHOD.


  METHOD build_cont.

    CREATE OBJECT ro_cont
      EXPORTING
        container_name = iv_alv_name.

  ENDMETHOD.


  METHOD pai.
  ENDMETHOD.


  METHOD pbo.

    DATA(lv_status) = |{ ms_gui-status }{ iv_scrn }|.
    SET PF-STATUS lv_status.

    DATA(lv_title) = |{ ms_gui-title }{ iv_scrn }|.
    SET TITLEBAR lv_title.

    CASE iv_scrn.
      WHEN ms_scr-s0100.
        IF ms_alv-s0100-cont IS NOT BOUND.

          " Build Container
          ms_alv-s0100-cont = build_cont( iv_alv_name = |{ 'F_' }{ iv_scrn }| ).
          main_alv( iv_scrn_cont = iv_scrn  iv_scrn_alv = ms_scr-s0101 ).
        ENDIF.
    ENDCASE.

  ENDMETHOD.

  METHOD ext.

    CASE sy-ucomm.
      WHEN ms_ucomm-back.
        LEAVE TO SCREEN 0.
      WHEN ms_ucomm-leave.
        LEAVE TO SCREEN 0.
      WHEN ms_ucomm-exit.
        LEAVE TO SCREEN 0.
    ENDCASE.


  ENDMETHOD.


ENDCLASS.
