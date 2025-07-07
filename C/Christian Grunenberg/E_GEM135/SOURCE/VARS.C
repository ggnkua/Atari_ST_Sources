
#include "e_gem.h"

int ap_id, aes_version, winx, magx, grhandle, x_handle;
int gr_cw, gr_ch, gr_bw, gr_bh, gr_sw, gr_sh;
int max_w, max_h, colors, planes, redraw;
int small_font,small_font_id,ibm_font,ibm_font_id,fonts_loaded;

GRECT desk;
VRECT clip;
MFDB scr_mfdb;
OBJECT *menu,*iconified;
MFDB *screen = &scr_mfdb;
int menu_id = -1;
