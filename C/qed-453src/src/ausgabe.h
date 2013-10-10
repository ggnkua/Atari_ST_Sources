#ifndef _qed_ausgabe_h_
#define _qed_ausgabe_h_

/* Liefert die interne Position */
extern int		inter_pos		(int x, ZEILEP a, bool tab, int tab_size);

/* Liefert die L„nge auf dem Bild */
extern int		bild_len			(ZEILEP a, bool tab, int tab_size);

/* Liefert die Position auf dem Bild */
extern int		bild_pos			(int x, ZEILEP a, bool tab, int tab_size);

extern void		fill_area		(int x, int y, int w, int h, int color);
extern int		out_s				(int x, int y, int w, char *str);
extern int		out_sb			(int x, int y, int w, char *str);

extern void		head_out			(WINDOWP window, TEXTP t_ptr);
extern void		line_out			(WINDOWP window, TEXTP t_ptr, int wy);
extern void		bild_out			(WINDOWP window, TEXTP t_ptr);
extern void		bild_blkout		(WINDOWP window, TEXTP t_ptr, long z1, long z2);
extern int		cursor_xpos		(TEXTP t_ptr, int pos);
extern void		cursor			(WINDOWP window, TEXTP t_ptr);

extern void 	set_drawmode	(void);

#endif
