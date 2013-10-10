#ifndef _qed_clipbrd_h_
#define _qed_clipbrd_h_

/* Undo Funktionen */
#define NO_UNDO			0		/*  Werte von 'undo'  */
#define COL_ANDERS		1
#define BLK_PASTE			3
#define BLK_CUT			4
#define BLK_DEL			5
#define BLK_PASTE_TRASH	6

extern void		clr_undo				(void);
extern bool		any_undo				(void);
extern bool		test_col_anders	(void);
extern void		end_undo_seq		(void);
extern void		add_undo				(int undo_op);
extern int		get_undo				(void);
extern void		undo_takes_text	(RINGP r);
extern RINGP	get_undo_text		(void);
extern void		get_undo_col		(TEXTP t_ptr);
extern void		do_undo_col			(TEXTP t_ptr, int undo);


/* Klemmbrett */
extern RING		clip_text;
extern PATH		clip_dir;

extern void		load_clip			(void);
extern void		save_clip			(void);
extern void		clip_takes_text	(RINGP r);
extern void		clip_add_text		(RINGP r);


extern void		init_clipbrd		(void);

#endif
