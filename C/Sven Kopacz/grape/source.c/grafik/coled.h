void	dial_coled(int ob);
void	dial_colpal(int ob);

void	sl_grey(int c);
void	sl_cec(int c);
void	sl_cem(int c);
void	sl_cey(int c);

void set_color(int ob);
void set_colpal_slide(void);
void colpal_redraw(void);
void colpal_save(int fh);
void colpal_load(int fh);
void colpal_load_save(void);
void read_col_key(void);
void get_key_color(int c1, int c2);
void got_frame(int c1, int c2);
void write_col_pal(CMY_COLOR *pal);
void read_col_pal(CMY_COLOR *pal);

void	set_grey(CMY_COLOR *col);
void	set_col_ed(CMY_COLOR *c);

/* Farbpalette */

void	colpal_arrowed(WINDOW *win, int *pbuf);
void	colpal_vslid(WINDOW *win, int *pbuf);
void	colpal_sized(WINDOW *win, int *pbuf);
void	key_col_sel(void);
void	fill_colpal_ob(int ob, int re, int ye, int bl);
void	set_color(int ob);

/* Coled Globvars */
extern OBJECT *ocoled, *ocolpal;
extern WINDOW	wcoled, wcolpal;
extern DINFO  dcoled, dcolpal;