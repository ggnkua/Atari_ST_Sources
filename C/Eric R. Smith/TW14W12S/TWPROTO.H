/*
 * Copyright 1992 Eric R. Smith. All rights reserved.
 * Redistribution is permitted only if the distribution
 * is not for profit, and only if all documentation
 * (including, in particular, the file "copying")
 * is included in the distribution in unmodified form.
 * THIS PROGRAM COMES WITH ABSOLUTELY NO WARRANTY, NOT
 * EVEN THE IMPLIED WARRANTIES OF MERCHANTIBILITY OR
 * FITNESS FOR A PARTICULAR PURPOSE. USE AT YOUR OWN
 * RISK.
 */
#if defined(__STDC__) || defined(__cplusplus)
# define P_(s) s
#else
# define P_(s) ()
#endif


/* config.c */
char *nextword P_((char **ptr));
int hexval P_((char *s));
char *valhex P_((int i));
int decval P_((char *s));
char *valdec P_((int i));
char *valdec2 P_((int d));
void set_default_font P_((char *s));
void set_scrap_coord P_((char *s));
void load_config P_((char *name));
void save_config P_((char *file));
void load_menu_key P_((char *s));
void config_menu P_((void));
void sendhex P_((char *s));
MENU *loadmenu P_((char *fname));
void unloadmenu P_((MENU *men));

/* environ.c */
char *envstr P_((char *progname, char *progargs, char *progdir, int cols, int rows));
void setenvoptions P_((void));
void output_termcap P_((TEXTWIN *t));

/* font.c */
void init_fontdesc P_((void));
void set_fontbox P_((int off, int maxfntoff, int draw));
void set_sizebox P_((FONTDESC *f, int off, int draw));
int slide P_((OBJECT *tree, int box, int slider, int maxoff));
int page P_((OBJECT *tree, int box, int slider, int off, int maxoff));
int get_font P_((int *font, int *size));
int find_font_named P_((char *name));

/* gadgets.c */
void g_move P_((void));
void g_full P_((void));
void g_scroll P_((long));
void g_close P_((void));

/* iconify.c */
void iconify_topwin P_((void));
void iconify_win P_((WINDOW *));
void iconify_message P_((int *msgbuff));

/* scrap.c */
void write_scrap P_((char *file, char *data, int len));
char *read_scrap P_((char *name));
int  scrap_exists P_((char *name));

/* toswin.c */
void dead_kid P_((void));
void send_sig P_((long sig));
void ignore P_((void));
void newstdwin P_((void));
void newaltwin P_((void));
void get_winsize P_((int *col, int *row, int *scroll));
void set_linea P_((int ncol, int nrow));
void set_altsiz P_((void));
void set_stdsiz P_((void));
void set_winsiz P_((void));
void shutdown P_((void));
void quit P_((void));
void about_alert P_((void));
void do_cut P_((void));
void do_paste P_((void));
void set_wfont P_((void));
void set_dfont P_((void));
void get_gadgets P_((int *, int));
void toggle P_((int *var));
void bury P_((void));
char *Strng P_((int));
#define AlertStrng Strng
int main P_((void));
void ac_open P_((void));
void ac_close();
void force_ac_close P_((void));

/* util.c */
void setcutoptions P_((void));
void unselect P_((TEXTWIN *t));
void cut P_((WINDOW *w));
void paste P_((WINDOW *w));
void redraw_screen P_((int x, int y, int w, int h));
void cut_from_desk P_((int x, int y));
void paste_to_desk P_((int x, int y));
void hot_dragbox P_((int *lines, int numpoints, int *lastx, int *lasty));
void togglemenu P_((void));
int win_click P_((WINDOW *w, int clicks, int x, int y, int kshift, int buttons));
void desk_mouse P_((int clicks, int x, int y, int kshift, int buttons));

/* winops.c */
int getfilename P_((char *title, char *name, char *path, char *default_name));
int getprogname P_((char *name));
int getargs P_((char *, char *));
int typeit P_((WINDOW *w, int code, int shift));
TEXTWIN * newproc P_((char *progname, char *progargs, char *progdir, int x,
		      int y, int cols, int rows, int scroll, int kind, int font, int point));
void exec_tos P_((char *buf));
void fd_input P_((void));
void acc_input P_((void));
void send_char P_((void));

#ifdef WWA_GEM_RUN
void desk_menu_show P_((int));
#endif

#undef P_
