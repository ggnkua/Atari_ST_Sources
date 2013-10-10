#ifndef _qed_text_h_
#define _qed_text_h_

extern TEXTP	new_text				(int link);
extern void		destruct_text		(TEXTP t_ptr);
extern void		clear_text			(TEXTP t_ptr);
extern TEXTP	get_text				(int link);
extern void		do_all_text			(TEXT_DOFUNC func);

extern void		set_text_name		(TEXTP t_ptr, char *filename, bool namenlos);
extern void		update_loc_opt		(void);
extern bool 	strip_endings		(TEXTP t_ptr);
extern int		get_longestline	(TEXTP t_ptr);

extern int 		text_still_loaded	(char *name);

#endif
