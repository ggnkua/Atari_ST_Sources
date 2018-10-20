/* Preview Functions */
void	show_preview(void);
void	dial_preview(int ob);

void	preview_closed(WINDOW *win);
void	preview_sized(WINDOW *win, int *pbuf);
void	preview_fulled(WINDOW *win);
void	init_preview(void);
void	make_vbig(void);
void	make_nbig(void);
void	make_vdetail(void);
void	make_ndetail(void);
void	ob_clear(uchar *dest, int uw, int uh, long doff);
void	init_detail(void);
void	fix_detail(void);
void	init_big_start(void);
void	fix_big_start(void);
int		init_preview_by_size(void);
void	free_preview(void);

int		new_ob_size(int w, int h);
void	set_objects(int w, int h);

void	used_size(int *nw, int *nh);

void	move_detail(void);
void	detail_moved(int x, int y);
void	move_frame(void);
void	frame_moved(int x, int y);

/* Ganzer Preview-Bereich neu */
void	new_preview_sel(void);
/* Nur Ergebnis neu */
void	update_preview(void);
void	update_prev_if_in(int x, int y, int w, int h);

/* Preview Globvars */

extern OBJECT *opreview;
extern WINDOW	wpreview;
extern DINFO	dpreview;
extern int BIG_X, BIG_Y, BIG_W, BIG_H, DETAIL_X, DETAIL_Y;

extern int cdecl(*prev_func)(uchar *c, uchar *m, uchar *y, int w, int h, GRECT *area, int prv);
