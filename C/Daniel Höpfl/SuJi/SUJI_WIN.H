#ifndef __DH_SUJI_WIN_H_
#define __DH_SUJI_WIN_H_

#define WIND_KIND		NAME|INFO|CLOSER|MOVER|SIZER|UPARROW|DNARROW|VSLIDE|LFARROW|RTARROW|HSLIDE|SMALLER|FULLERint open_list_window( GRECT *xywh );void close_list_window( GRECT *xywh );void redraw_window(GRECT *r);
void move_up_down(long diff);void move_left_right(int diff);int calc_slider(void);void set_info_line(void);extern int window_handle;extern int shaded_or_iconified;extern unsigned long first_shown;extern unsigned long lines_to_show;extern GRECT full;extern int scrolled_left;
#endif
