#ifndef _qed_tasten_h_
#define _qed_tasten_h_

extern bool		edit_key		(TEXTP t_ptr, WINDOWP window, int kstate, int kreturn);
extern void		char_bs		(TEXTP t_ptr);
extern void		char_cr		(TEXTP t_ptr);
extern void		char_insert	(TEXTP t_ptr, char c);
extern void		char_left	(TEXTP t_ptr);
extern void 	char_swap	(TEXTP t_ptr);

#endif
