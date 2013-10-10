#ifndef _qed_makro_h_
#define _qed_makro_h_

#define MAKRO_ANZ		20

extern bool 	makro_play, 
					makro_rec,
					makro_shift;

extern bool		from_makro		(int *kstate, int *kreturn);
extern void		to_makro			(int kstate, int kreturn);

extern void		start_rec		(void);
extern void		end_rec			(bool one_more);

extern bool		start_play		(int key, int anz);
extern void		end_play			(void);

extern void		set_makro_str	(char *ptr);
extern bool		get_makro_str	(int nr, char *ptr);

extern void 	makro_dial		(void);

extern void		init_makro		(void);

#endif
