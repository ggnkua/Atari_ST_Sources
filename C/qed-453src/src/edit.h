#ifndef _qed_edit_h_
#define _qed_edit_h_

extern int		edit_type;


extern void		absatz_edit		(void);
extern void		font_edit		(void);
extern void		pos_korr			(WINDOWP window, TEXTP t_ptr);
extern void		blink_edit		(void);
extern void		offblink_edit	(void);
extern void		onblink_edit	(void);
extern int		new_edit			(void);
extern int		load_edit		(char *filename, bool bin);
extern void		close_edit		(char *filename, int flag);

extern bool		info_edit		(int icon);

extern void		make_chg			(int link, int change, long ypos);
extern void		restore_edit	(void);

extern void		cursor_on		(int wHandle);
extern void		cursor_off		(int wHandle);

/* Infozeile an- bzw. abschalten */
extern void		set_info			(TEXTP t_ptr, char *str);
extern void		clear_info		(TEXTP t_ptr);

extern void		color_change	(void);

extern void		init_edit		(void);

#endif
