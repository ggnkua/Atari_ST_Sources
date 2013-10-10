#ifndef _qed_menu_h_
#define _qed_menu_h_

extern void		handle_menu		(int title, int item, bool ctrl);
extern void		set_menu			(int item, bool yes);
extern void		mark_menu		(int item, bool yes);
extern void		update_menu		(void);
extern void		fillup_menu		(int item, char *new_text, int free);

extern void		set_overwrite	(bool mode);

extern void		do_action		(int action);
extern bool		key_global		(int kstate, int kreturn);


/*
 * Programmende vorbereiten und durchfÅhren.
*/
extern bool 	prepare_quit	(void);
extern void 	do_quit			(void);

#endif
