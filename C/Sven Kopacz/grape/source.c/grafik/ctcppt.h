/* Cut, Copy, Paste */

void	del(void);
void	del_frame(void);
void	cut(void);
void	cut_frame(void);
void	copy(void);
int		copy_frame(void);
void	copy_vis(void);
int		copy_frame_vis(void);
void	object_frame(int wid);
void	paste(void);
void	paste_frame(void);
void	clip_size(void);
void	clip_size_frame(void);
void	select_all(void);
void	select_all_frame(void);

int		write_clipboard(char *name);
int		read_clipboard(char *name, char *path);

int		get_vis_frame(unsigned char **c_buf, unsigned char **m_buf, unsigned char **y_buf, long *h, long *w, long *uw);
void	vis_to_buf(unsigned char *c_buf, unsigned char *m_buf, unsigned char *y_buf, long x, long y, long w, long h);

void	frame(int wid);
void	draw_frame_clip(GRECT *todo);
void	draw_frame(void);
void	draw_win_frame(void);

void	paste_mode(void);
void	dial_pmode(int ob);

/* CutCopyPaste Globvars */

extern OBJECT *opmode;
extern WINDOW	wpmode;
extern DINFO	dpmode;