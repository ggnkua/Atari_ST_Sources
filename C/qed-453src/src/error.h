#ifndef _qed_error_h_
#define _qed_error_h_

#define FEHLERANZ	6

extern char		error[FEHLERANZ][40];
extern TEXTP	last_errtext;

extern void		set_errorline	(char *zeile);
extern void		handle_error	(TEXTP t_ptr);
extern void		fehler_box		(void);

#endif
