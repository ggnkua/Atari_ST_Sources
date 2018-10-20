
void	pic_redraw(int wid, int x, int y, int w, int h);
void	pic_dith(int wid, int x, int y, int w, int h, int type);
void	new_wslidx(int sl_pos);
void	new_wslidy(int sl_pos);
void	blit_y(int old_y);
void	blit_x(int old_x);
void	new_wsize(int *pbuf);
void	new_wsize_red(int *pbuf, int redraw);
void	new_warrow(int *pbuf);
void	full_wsize(int wid);
void	area_redraw(int x, int y, int w, int h);
void	special_redraw(int type);
void	redraw_pic(void);

void	wait_click(void);