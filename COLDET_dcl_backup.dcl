/* COLDET.dcl - Settings Dialog */

coldet_start : dialog {
  label = "COLDET";
  : spacer { height = 0.3; }
  : row {
    spacer;
    : button { key = "start_settings"; label = "הגדרות"; width = 14; fixed_width = true; }
    : button { key = "start_run";      label = "בחר עמוד"; width = 14; fixed_width = true; is_default = true; }
    : button { key = "start_cancel";   label = "ביטול";      width = 14; fixed_width = true; is_cancel = true; }
    spacer;
  }
  : spacer { height = 0.3; }
}

bar_data : dialog {
  label = "נתוני ברזל";
  : popup_list { key = "bar_type"; label = "Type:";          width = 22; }
  : popup_list { key = "bar_diam"; label = "Diameter (mm):"; width = 22; }
  : edit_box   { key = "bar_len";  label = "Length (mm):";   edit_width = 10; }
  : spacer { height = 0.5; }
  : row {
    spacer;
    : button { key = "bd_ok";     label = "OK";     is_default = true;  width = 12; fixed_width = true; }
    : button { key = "bd_cancel"; label = "Cancel"; is_cancel  = true;  width = 12; fixed_width = true; }
  }
}


coldet_settings : dialog {
  label = "הגדרות עמוד בטון";

  : row {

    : column {

      : boxed_column {
        label = "1. גיאומטריה חיצונית";
        : button { key = "btn_ext"; label = "Pick Line"; fixed_width = false; }
        : row {
          : popup_list { key = "ext_layer"; label = "Layer:"; width = 18; }
          : edit_box { key = "ext_color"; label = ""; edit_width = 4; fixed_width = true; }
          : button { key = "btn_ext_col"; label = "Color"; width = 10; fixed_width = true; }
        }
      }

      : boxed_column {
        label = "2. גיאומטריה פנימית";
        : button { key = "btn_int"; label = "Pick Line"; fixed_width = false; }
        : row {
          : popup_list { key = "int_layer"; label = "Layer:"; width = 18; }
          : edit_box { key = "int_color"; label = ""; edit_width = 4; fixed_width = true; }
          : button { key = "btn_int_col"; label = "Color"; width = 10; fixed_width = true; }
        }
        : edit_box { key = "int_offset"; label = "כיסוי מינ:"; edit_width = 10; }
      }

      : boxed_column {
        label = "3. ברזל ראשי";
        : boxed_column {
          label = "דונאט";
          : button { key = "btn_dlay"; label = "Pick Donut"; fixed_width = false; }
          : row {
            : edit_box { key = "donut_size"; label = "Diameter:"; edit_width = 6; }
            : edit_box { key = "bar_len";    label = "אורך:";    edit_width = 6; }
          }
          : row {
            : popup_list { key = "donut_layer"; label = "Layer:"; width = 18; }
            : edit_box { key = "donut_color"; label = ""; edit_width = 4; fixed_width = true; }
            : button { key = "btn_donut_col"; label = "Color"; width = 10; fixed_width = true; }
          }
        }
        : boxed_column {
          label = "טקסט";
          : button { key = "btn_dtxt"; label = "Pick"; fixed_width = false; }
          : row {
            : popup_list { key = "donut_txt_style"; label = "Style:"; width = 18; }
            : edit_box { key = "donut_txt_col"; label = ""; edit_width = 4; fixed_width = true; }
            : button { key = "btn_dtxt_col"; label = "Color"; width = 10; fixed_width = true; }
          }
          : edit_box { key = "donut_txt_height"; label = "Height:"; edit_width = 8; }
        }
        : boxed_column {
          label = "עוגן";
          : button { key = "btn_leader"; label = "Pick"; fixed_width = false; }
          : row {
            : popup_list { key = "leader_layer"; label = "Layer:"; width = 18; }
            : edit_box { key = "leader_color"; label = ""; edit_width = 4; fixed_width = true; }
            : button { key = "btn_ldr_col"; label = "Color"; width = 10; fixed_width = true; }
          }
        }
      }

    }

    : column {

      : boxed_column {
        label = "4. מידות";
        : button { key = "btn_dim"; label = "Pick dim"; fixed_width = false; }
        : popup_list { key = "dim_layer"; label = "Layer:"; width = 28; }
        : row {
          : popup_list { key = "dim_style"; label = "Style:"; width = 18; }
          : edit_box { key = "dim_scale"; label = "DIMSCALE:"; edit_width = 6; fixed_width = true; }
        }
      }

      : boxed_column {
        label = "5. כותרות";
        : boxed_column {
          label = "ראשית";
          : button { key = "btn_tlay1"; label = "Pick"; fixed_width = false; }
          : row {
            : popup_list { key = "title_layer1"; label = "Layer:"; width = 16; }
            : edit_box { key = "title_color1"; label = ""; edit_width = 4; fixed_width = true; }
            : button { key = "btn_tc1_col"; label = "Color"; width = 10; fixed_width = true; }
          }
          : popup_list { key = "title_style1"; label = "Style:"; width = 28; }
          : edit_box { key = "title_height1"; label = "Height:"; edit_width = 8; }
          : edit_box { key = "title_txt1"; label = "Title text:"; edit_width = 22; }
          : popup_list { key = "title_style_num"; label = "Num Style:"; width = 28; }
          : edit_box { key = "title_height_num"; label = "Num Height:"; edit_width = 8; }
          : row {
            : edit_box { key = "title_color_num"; label = "Num Color:"; edit_width = 4; fixed_width = true; }
            : button { key = "btn_tcn_col"; label = "Color"; width = 10; fixed_width = true; }
          }
          : toggle { key = "title_flip1"; label = "הפוך כיוון טקסט"; }
        }
        : boxed_column {
          label = "משנית";
          : button { key = "btn_tlay2"; label = "Pick"; fixed_width = false; }
          : row {
            : popup_list { key = "title_layer2"; label = "Layer:"; width = 16; }
            : edit_box { key = "title_color2"; label = ""; edit_width = 4; fixed_width = true; }
            : button { key = "btn_tc2_col"; label = "Color"; width = 10; fixed_width = true; }
          }
          : popup_list { key = "title_style2"; label = "Style:"; width = 28; }
          : edit_box { key = "title_height2"; label = "Height:"; edit_width = 8; }
          : toggle { key = "title_flip2"; label = "הפוך כיוון טקסט"; }
        }
      }

      : boxed_column {
        label = "6. חישוקים";
        : boxed_column {
          label = "חישוק";
          : button { key = "btn_stir"; label = "Pick"; fixed_width = false; }
          : row {
            : popup_list { key = "stirrup_layer"; label = "Layer:"; width = 18; }
            : edit_box { key = "stirrup_color"; label = ""; edit_width = 4; fixed_width = true; }
            : button { key = "btn_stc_col"; label = "Color"; width = 10; fixed_width = true; }
          }
        }
        : boxed_column {
          label = "טקסט";
          : button { key = "btn_ststy"; label = "Pick"; fixed_width = false; }
          : row {
            : popup_list { key = "stir_style"; label = "Style:"; width = 18; }
            : edit_box { key = "stir_txt_col"; label = ""; edit_width = 4; fixed_width = true; }
            : button { key = "btn_stxt_col"; label = "Color"; width = 10; fixed_width = true; }
          }
          : edit_box { key = "stir_height"; label = "Height:"; edit_width = 8; }
        }
      }

    }
  }

  : spacer { height = 0.5; }

  : row {
    spacer;
    : button { key = "dlg_ok"; label = "OK"; is_default = true; width = 12; fixed_width = true; }
    : button { key = "dlg_cancel"; label = "Cancel"; is_cancel = true; width = 12; fixed_width = true; }
  }
}
