#ifndef __DH_SUJI_VDI_H_
#define __DH_SUJI_VDI_H_

int init_vwork(void);void exit_vwork(void);void set_new_font(int id,int size);void icons_anpassen(void);int test_max_breite(FILE_INFO *fi);void init_max_breite(void);void set_mouse(int type);void reform_3d(void);
extern int vdi_h;extern int zahl_der_fonts;extern int screen_font;extern int screen_font_height;extern int screen_font_color;
extern int line_height;extern int top_height;#endif