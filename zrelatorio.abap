*                   
*&---------------------------------------------------------------------*
*& Report ZCOR0006
*&---------------------------------------------------------------------*
* Descrição  : Relatório Extratificação dos Elementos de custos        *
* Módulo     : CO                                                      *
* Transação  :                                                         *
*----------------------------------------------------------------------*
* Autor      : Ailson Luis                            Data: 22/12/2021 *

*                                                                      *

report zcor0006.


class lcl_app definition.
  public section.

    types:
      begin of ty_sel,
        poper type ckml_run_poper,
        gjahr type ckml_run_gjahr,
        werks type werks_d,
        matnr type matnr,
        mtart type mtart,
      end of ty_sel.

    class-data r_sel type ref to ty_sel.


    data: r_cust_unit type ref to zcl_co_product_cost,
          gt_data     type table of zcl_co_product_cost=>ty_itab,
          gt_elements type table of tckh1,
          r_alv       type ref to cl_salv_table.

    data:
      rg_poper type range of ckml_run_poper,
      rg_gjahr type range of ckmlrunperiod-gjahr,
      rg_werks type range of werks_d,
      rg_matnr type range of matnr,
      rg_mtart type range of mtart,
      pr_price type ck_peinh_1,
      p_check type flag.


    methods start.

    methods show_alv.



endclass.

class lcl_app implementation.


  method start.
    data wa_data type  zcl_co_product_cost=>ty_itab.

    select mara~matnr mara~meins mara~mtart  mbew~bwkey as werks makt~maktx
      from ( mara as mara inner join mbew as mbew  on mara~matnr = mbew~matnr
                          inner join makt as makt on mara~matnr = makt~matnr )
      into corresponding fields of table gt_data
      where mara~matnr in rg_matnr
        and mara~mtart in rg_mtart
        and mara~lvorm ne abap_true
        and mbew~bwkey in rg_werks
        and makt~spras eq sy-langu.


    if gt_data is initial.
      message |Dados não encontrados| type 'S' display like 'E'.
      exit.
    endif.




    if p_check = abap_true.
      data(lt_mara) = gt_data[].
      clear gt_data.
       loop at lt_mara assigning field-symbol(<fs_mara>).
          r_cust_unit = new zcl_co_product_cost( ).
          <fs_mara>-gjhar = rg_gjahr[ 1 ]-low.
          <fs_mara>-poper = rg_poper[ 1 ]-low.
          r_cust_unit->get_cost_material_t( exporting  i_gjahr = <fs_mara>-gjhar i_poper = <fs_mara>-poper  i_matnr = <fs_mara>-matnr i_werks = <fs_mara>-werks  ).
          append lines of r_cust_unit->lt_cust to gt_data.
       endloop.

    else.


    loop at gt_data assigning field-symbol(<fs_data>).
      r_cust_unit = new zcl_co_product_cost( ).
      <fs_data>-gjhar = rg_gjahr[ 1 ]-low.
      <fs_data>-poper = rg_poper[ 1 ]-low.
      r_cust_unit->get_cost_material( exporting  i_gjahr = <fs_data>-gjhar i_poper = <fs_data>-poper  i_matnr = <fs_data>-matnr i_werks = <fs_data>-werks importing e_cust = wa_data ).
      if wa_data is not initial.

        " <fs_data> = corresponding #( wa_data ).
        <fs_data>-quant =   wa_data-quant.
        <fs_data>-total =   wa_data-total.
        <fs_data>-price =  wa_data-price.
        <fs_data>-stval =  wa_data-stval .
        <fs_data>-prd =  wa_data-prd .
        <fs_data>-kdm =  wa_data-kdm.
        <fs_data>-elm001 = wa_data-elm001 .
        <fs_data>-elm002 = wa_data-elm002 .
        <fs_data>-elm003 = wa_data-elm003 .
        <fs_data>-elm004 = wa_data-elm004 .
        <fs_data>-elm005 = wa_data-elm005 .
        <fs_data>-elm006 = wa_data-elm006 .
        <fs_data>-elm007 = wa_data-elm007 .
        <fs_data>-elm008 = wa_data-elm008 .
        <fs_data>-elm009 = wa_data-elm009 .
        <fs_data>-elm010 = wa_data-elm010 .
        <fs_data>-elm011 = wa_data-elm011 .
        <fs_data>-elm012 = wa_data-elm012 .
        <fs_data>-elm013 = wa_data-elm013 .
        <fs_data>-elm014 = wa_data-elm014 .
        <fs_data>-elm015 = wa_data-elm015 .
        <fs_data>-elm016 = wa_data-elm016 .
        <fs_data>-elm017 = wa_data-elm017 .
        <fs_data>-elm018 = wa_data-elm018.

        if pr_price is not initial .
          if <fs_data>-quant = 0.
            <fs_data>-quant = 1.
          endif.

          <fs_data>-total = ( ( <fs_data>-stval + <fs_data>-prd + <fs_data>-kdm ) / <fs_data>-quant ) * pr_price.
          <fs_data>-stval = ( <fs_data>-stval / <fs_data>-quant ) * pr_price.
          <fs_data>-prd = ( <fs_data>-prd / <fs_data>-quant ) * pr_price.
          <fs_data>-kdm = ( <fs_data>-kdm / <fs_data>-quant ) * pr_price.
          <fs_data>-elm001 = <fs_data>-elm001 / <fs_data>-quant * pr_price.
          <fs_data>-elm002 = <fs_data>-elm002 / <fs_data>-quant * pr_price.
          <fs_data>-elm003 = <fs_data>-elm003 / <fs_data>-quant * pr_price.
          <fs_data>-elm004 = <fs_data>-elm004 / <fs_data>-quant * pr_price.
          <fs_data>-elm005 = <fs_data>-elm005 / <fs_data>-quant * pr_price.
          <fs_data>-elm006 = <fs_data>-elm006 / <fs_data>-quant * pr_price.
          <fs_data>-elm007 = <fs_data>-elm007 / <fs_data>-quant * pr_price.
          <fs_data>-elm008 = <fs_data>-elm008 / <fs_data>-quant * pr_price.
          <fs_data>-elm009 = <fs_data>-elm009 / <fs_data>-quant * pr_price.
          <fs_data>-elm010 = <fs_data>-elm010 / <fs_data>-quant * pr_price.
          <fs_data>-elm011 = <fs_data>-elm011 / <fs_data>-quant * pr_price.
          <fs_data>-elm012 = <fs_data>-elm012 / <fs_data>-quant * pr_price.
          <fs_data>-elm013 = <fs_data>-elm013 / <fs_data>-quant * pr_price.
          <fs_data>-elm014 = <fs_data>-elm014 / <fs_data>-quant * pr_price.
          <fs_data>-elm015 = <fs_data>-elm015 / <fs_data>-quant * pr_price.
          <fs_data>-elm016 = <fs_data>-elm016 / <fs_data>-quant * pr_price.
          <fs_data>-elm017 = <fs_data>-elm017 / <fs_data>-quant * pr_price.
          <fs_data>-elm018 = <fs_data>-elm018 / <fs_data>-quant * pr_price.

          <fs_data>-quant = pr_price.
        endif.
      endif.
      clear wa_data.
    endloop.
endif.
    gt_elements = r_cust_unit->gt_elements.

    show_alv( ).
  endmethod.


  method show_alv.
    data: r_events     type ref to cl_salv_events_table,
          r_selections type ref to cl_salv_selections,
          r_columns    type ref to cl_salv_columns_table,
          r_column     type ref to cl_salv_column.
    try.
*       Monta lista ALV de acordo com a tabela GT_CTE:
        cl_salv_table=>factory(
          exporting
            list_display   = if_salv_c_bool_sap=>false
            "r_container    =
            "container_name = 'Name'
          importing
            r_salv_table   = r_alv
          changing
            t_table        =  gt_data ).


      catch cx_salv_msg.

    endtry.

*
    data(r_functions) = r_alv->get_functions( ).
    r_functions->set_all( abap_true ).



*   Seleção das linhas:
    r_selections = r_alv->get_selections( ).
    r_selections->set_selection_mode( if_salv_c_selection_mode=>row_column ).

*   Seta eventos
    " r_events = r_alv->get_event( ).
    " set handler on_user_command for r_events.

    r_columns = r_alv->get_columns( ).
    r_columns->set_optimize( 'X' ).
    try.



        r_column = r_columns->get_column( 'ELM001' ).
        r_column->set_long_text( |{ gt_elements[ elemt = 100 ]-txele }|  ).
        r_column->set_short_text( |{ gt_elements[ elemt = 100 ]-txele }|  ).
        r_column->set_medium_text( |{ gt_elements[ elemt = 100 ]-txele }| ).

        r_column = r_columns->get_column( 'ELM002' ).
        r_column->set_long_text( |{ gt_elements[ elemt = 110 ]-txele }|  ).
        r_column->set_short_text( |{ gt_elements[ elemt = 110 ]-txele }| ).
        r_column->set_medium_text( |{ gt_elements[ elemt = 110 ]-txele }| ).

        r_column = r_columns->get_column( 'ELM003' ).
        r_column->set_long_text( |{ gt_elements[ elemt = 120 ]-txele }|  ).
        r_column->set_short_text( |{ gt_elements[ elemt = 120 ]-txele }| ).
        r_column->set_medium_text( |{ gt_elements[ elemt = 120 ]-txele }| ).

        r_column = r_columns->get_column( 'ELM004' ).
        r_column->set_long_text( |{ gt_elements[ elemt = 130 ]-txele }|  ).
        r_column->set_short_text( |{ gt_elements[ elemt = 130 ]-txele }| ).
        r_column->set_medium_text( |{ gt_elements[ elemt = 130 ]-txele }| ).

        r_column = r_columns->get_column( 'ELM005' ).
        r_column->set_long_text( |{ gt_elements[ elemt = 140 ]-txele }|  ).
        r_column->set_short_text( |{ gt_elements[ elemt = 140 ]-txele }| ).
        r_column->set_medium_text( |{ gt_elements[ elemt = 140 ]-txele }| ).

        r_column = r_columns->get_column( 'ELM006' ).
        r_column->set_long_text( |{ gt_elements[ elemt = 150 ]-txele }|  ).
        r_column->set_short_text( |{ gt_elements[ elemt = 150 ]-txele }| ).
        r_column->set_medium_text( |{ gt_elements[ elemt = 150 ]-txele }| ).

        r_column = r_columns->get_column( 'ELM007' ).
        r_column->set_long_text( |{ gt_elements[ elemt = 160 ]-txele }|  ).
        r_column->set_short_text( |{ gt_elements[ elemt = 160 ]-txele }| ).
        r_column->set_medium_text( |{ gt_elements[ elemt = 160 ]-txele }| ).

        r_column = r_columns->get_column( 'ELM008' ).
        r_column->set_long_text( |{ gt_elements[ elemt = 170 ]-txele }|  ).
        r_column->set_short_text( |{ gt_elements[ elemt = 170 ]-txele }| ).
        r_column->set_medium_text( |{ gt_elements[ elemt = 170 ]-txele }| ).

        r_column = r_columns->get_column( 'ELM009' ).
        r_column->set_long_text( |{ gt_elements[ elemt = 180 ]-txele }|  ).
        r_column->set_short_text( |{ gt_elements[ elemt = 180 ]-txele }| ).
        r_column->set_medium_text( |{ gt_elements[ elemt = 180 ]-txele }| ).

        r_column = r_columns->get_column( 'ELM010' ).
        r_column->set_long_text( |{ gt_elements[ elemt = 200 ]-txele }|  ).
        r_column->set_short_text( |{ gt_elements[ elemt = 200 ]-txele }| ).
        r_column->set_medium_text( |{ gt_elements[ elemt = 200 ]-txele }| ).

        r_column = r_columns->get_column( 'ELM011' ).
        r_column->set_long_text( |{ gt_elements[ elemt = 210 ]-txele }|  ).
        r_column->set_short_text( |{ gt_elements[ elemt = 210 ]-txele }| ).
        r_column->set_medium_text( |{ gt_elements[ elemt = 210 ]-txele }| ).

        r_column = r_columns->get_column( 'ELM012' ).
        r_column->set_long_text( |{ gt_elements[ elemt = 220 ]-txele }|  ).
        r_column->set_short_text( |{ gt_elements[ elemt = 220 ]-txele }| ).
        r_column->set_medium_text( |{ gt_elements[ elemt = 220 ]-txele }| ).

        r_column = r_columns->get_column( 'ELM013' ).
        r_column->set_long_text( |{ gt_elements[ elemt = 230 ]-txele }|  ).
        r_column->set_short_text( |{ gt_elements[ elemt = 230 ]-txele }| ).
        r_column->set_medium_text( |{ gt_elements[ elemt = 230 ]-txele }| ).

        r_column = r_columns->get_column( 'ELM014' ).
        r_column->set_long_text( |{ gt_elements[ elemt = 240 ]-txele }|  ).
        r_column->set_short_text( |{ gt_elements[ elemt = 240 ]-txele }| ).
        r_column->set_medium_text( |{ gt_elements[ elemt = 240 ]-txele }| ).

        r_column = r_columns->get_column( 'ELM015' ).
        r_column->set_long_text( |{ gt_elements[ elemt = 250 ]-txele }|  ).
        r_column->set_short_text( |{ gt_elements[ elemt = 250 ]-txele }| ).
        r_column->set_medium_text( |{ gt_elements[ elemt = 250 ]-txele }| ).

        r_column = r_columns->get_column( 'ELM016' ).
        r_column->set_long_text( |{ gt_elements[ elemt = 260 ]-txele }|  ).
        r_column->set_short_text( |{ gt_elements[ elemt = 260 ]-txele }| ).
        r_column->set_medium_text( |{ gt_elements[ elemt = 260 ]-txele }| ).

        r_column = r_columns->get_column( 'ELM017' ).
        r_column->set_long_text( |{ gt_elements[ elemt = 270 ]-txele }|  ).
        r_column->set_short_text( |{ gt_elements[ elemt = 270 ]-txele }| ).
        r_column->set_medium_text( |{ gt_elements[ elemt = 270 ]-txele }| ).

        r_column = r_columns->get_column( 'ELM018' ).
        r_column->set_long_text( |{ gt_elements[ elemt = 280 ]-txele }|  ).
        r_column->set_short_text( |{ gt_elements[ elemt = 280 ]-txele }| ).
        r_column->set_medium_text( |{ gt_elements[ elemt = 280 ]-txele }| ).





      catch cx_salv_not_found .
        " error handling
    endtry.

*   Exibe:
    r_alv->display( ).
  endmethod.

endclass.


selection-screen begin of block b1 with frame title text-t01.

select-options:
               s_poper for lcl_app=>r_sel->poper no intervals no-extension obligatory,
               s_gjahr for lcl_app=>r_sel->gjahr no intervals no-extension obligatory,
               s_werks for lcl_app=>r_sel->werks no intervals no-extension obligatory,
               s_mtart for lcl_app=>r_sel->mtart ,
               s_matnr for lcl_app=>r_sel->matnr.



selection-screen end of block b1.

selection-screen begin of block b2 with frame title text-t02.
parameters: p_price type ck_peinh_1.
selection-screen end of block b2.

selection-screen begin of block b3 with frame title text-t03.
PARAMETERS p_chkbox AS CHECKBOX DEFAULT ''.
selection-screen end of block b3.


start-of-selection.

  data r_app type ref to lcl_app.


  r_app = new lcl_app( ).
  r_app->rg_poper = s_poper[].
  r_app->rg_gjahr = s_gjahr[].
  r_app->rg_werks = s_werks[].
  r_app->rg_matnr = s_matnr[].
  r_app->rg_mtart = s_mtart[].
  r_app->pr_price = p_price.
  r_app->P_CHECK = P_CHKBOX.
  r_app->start( ).
