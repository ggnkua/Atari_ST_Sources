#ifndef _qed_icon_h_
#define _qed_icon_h_

#define MAX_ICON_ANZ 30

#define CLIP_ICON		0
#define SUB_ICON		1024

#define ALL_TYPES		-1


extern int		all_icons		(int *c_obj_nr);

extern int		decl_icon_type	(bool (*test)(int,int),
			 							 int	(*edit)(int,int),
										 void	(*exist)(int,SET),
										 bool	(*drag)(int,int));
extern bool		add_icon			(int type_id, int icon);
extern void		del_icon			(int icon);
extern int		icon_anz			(int type_id);

/* <0 : Fehler bei der AusfÅhrung	*/
/*	=0 : Nicht mîglich					*/
/* >0 : Erfolgreich ausgefÅhrt		*/
extern int		do_icon			(int icon, int action);
extern void		do_all_icon		(int type_id, int action);
extern bool		icon_test		(int icon, int action);
extern int		icon_edit		(int icon, int action);
extern void		icon_exist		(int icon, SET exist);

extern bool		icon_drag		(int dest_icon, int src_icon);

extern void		init_icon		(void);

#endif
