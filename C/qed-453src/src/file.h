#ifndef _qed_file_h_
#define _qed_file_h_

extern void 	open_error		(char *filename, int error);

extern int 		load_from_fd	(int fd, char *name, RINGP t, bool verbose, bool *null_byte, long size);
extern int 		load_datei		(char *name, RINGP t, bool verbose, bool *null_byte);
extern int		load				(TEXTP t_ptr, bool verbose);
extern int		infoload			(char *name, long *bytes, long *lines);

extern int 		save_to_fd		(int fd, char *name, RINGP t, bool verbose);
extern int		save_datei		(char *name, RINGP t, bool verbose);
extern int		save				(TEXTP t_ptr);
extern int		save_as			(TEXTP t_ptr, char *name);
extern bool		save_new			(char *name, char *mask, char *title);

extern bool		select_single 	(char *filename, char *mask, char *title);
extern bool		select_path 	(char *pathname, char *title);
extern void 	select_multi	(bool binary);

extern void 	store_path		(char *path);

extern void		init_file		(void);
extern void		term_file		(void);

#endif
