#ifndef _qed_poslist_h_
#define _qed_poslist_h_

extern void 		insert_poslist	(POSENTRY **list, char *name, int x, long y);
extern void			delete_poslist	(POSENTRY **list);	

extern void 		open_poslist	(POSENTRY *list);
extern POSENTRY	*find_poslist	(POSENTRY *list, char *name, int *x, long *y);

#endif
