#ifndef _qed_block_h_
#define _qed_block_h_

extern void	blk_mark_all	(TEXTP t_ptr);
extern void	blk_mark_word	(TEXTP t_ptr);
extern bool blk_mark_brace	(TEXTP t_ptr);
extern void get_blk_mark	(TEXTP t_ptr, long *y, int *x);
extern void	blk_mark			(TEXTP t_ptr, int marke);
extern void	blk_demark		(TEXTP t_ptr);
extern void	blk_delete		(TEXTP t_ptr);
extern void	blk_left			(TEXTP t_ptr);
extern void	blk_right		(TEXTP t_ptr);
extern void	blk_undo			(TEXTP t_ptr, int undo);
extern void	blk_cut			(TEXTP t_ptr);
extern void	blk_copy			(TEXTP t_ptr);
extern void	blk_paste		(TEXTP t_ptr, RINGP t);

extern void	block_copy		(TEXTP t_ptr, RINGP t);	/* fÅr blk_print */

extern void	line_copy		(TEXTP t_ptr);

extern void	block_info		(TEXTP t_ptr);

#define BLK_UPPER 	1
#define BLK_LOWER 	2
#define BLK_CH_UPLO 	3
#define BLK_CAPS 		4

extern void	blk_upplow		(TEXTP t_ptr, int type);

#endif
