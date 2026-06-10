/* COLDET.dcl - Settings Dialog */

coldet_settings : dialog {
  label = "COLDET - Settings";

  : row {

    : column {

      : boxed_column {
        label = "1. External Geometry";
        : row {
          : edit_box {
            key = "ext_layer"; label = "Layer:";
            edit_width = 16; width = 22;
          }
          : button { key = "btn_ext"; label = "Pick"; width = 8; fixed_width = true; }
        }
      }

      : boxed_column {
        label = "2. Internal Geometry";
        : row {
          : edit_box {
            key = "int_layer"; label = "Layer:";
            edit_width = 16; width = 22;
          }
          : button { key = "btn_int"; label = "Pick"; width = 8; fixed_width = true; }
        }
        : edit_box {
          key = "int_offset"; label = "Offset:";
          edit_width = 10; width = 22;
        }
      }

      : boxed_column {
        label = "3. Donuts";
        : row {
          : edit_box {
            key = "donut_layer"; label = "Layer:";
            edit_width = 16; width = 22;
          }
          : button { key = "btn_dlay"; label = "Pick"; width = 8; fixed_width = true; }
        }
        : row {
          : edit_box {
            key = "donut_size"; label = "Size (diam):";
            edit_width = 10; width = 22;
          }
          : button { key = "btn_dsz"; label = "Pick"; width = 8; fixed_width = true; }
        }
        : row {
          : edit_box {
            key = "leader_text"; label = "Leader text:";
            edit_width = 16; width = 22;
          }
          : button { key = "btn_ltxt"; label = "Pick"; width = 8; fixed_width = true; }
        }
      }

    }

    : column {

      : boxed_column {
        label = "4. Dimensions";
        : row {
          : edit_box {
            key = "dim_layer"; label = "Layer:";
            edit_width = 16; width = 22;
          }
          : button { key = "btn_dim"; label = "Pick dim"; width = 10; fixed_width = true; }
        }
        : edit_box {
          key = "dim_style"; label = "Style:";
          edit_width = 16; width = 22;
        }
        : edit_box {
          key = "dim_scale"; label = "Scale (e.g. 50):";
          edit_width = 10; width = 22;
        }
      }

      : boxed_column {
        label = "5. Title";
        : row {
          : edit_box {
            key = "title_layer"; label = "Layer:";
            edit_width = 16; width = 22;
          }
          : button { key = "btn_tlay"; label = "Pick"; width = 8; fixed_width = true; }
        }
        : row {
          : edit_box {
            key = "title_style1"; label = "Style row 1:";
            edit_width = 12; width = 22;
          }
          : button { key = "btn_tt1"; label = "Pick"; width = 8; fixed_width = true; }
        }
        : edit_box {
          key = "title_height1"; label = "Height row 1:";
          edit_width = 8; width = 22;
        }
        : row {
          : edit_box {
            key = "title_style2"; label = "Style row 2:";
            edit_width = 12; width = 22;
          }
          : button { key = "btn_tt2"; label = "Pick"; width = 8; fixed_width = true; }
        }
        : edit_box {
          key = "title_height2"; label = "Height row 2:";
          edit_width = 8; width = 22;
        }
        : row {
          : edit_box {
            key = "title_lweight"; label = "Sep. line wt:";
            edit_width = 8; width = 22;
          }
          : button { key = "btn_tlw"; label = "Pick"; width = 8; fixed_width = true; }
        }
      }

      : boxed_column {
        label = "6. Stirrup";
        : row {
          : edit_box {
            key = "stirrup_layer"; label = "Layer:";
            edit_width = 16; width = 22;
          }
          : button { key = "btn_stir"; label = "Pick"; width = 8; fixed_width = true; }
        }
      }

    }
  }

  : spacer { height = 0.5; }
  ok_cancel;
}
