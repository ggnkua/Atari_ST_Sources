#if  !defined( __MASK__ )
#define __MASK__
#include "layer.h"

typedef struct _MASK_LIST
{
	struct	_MASK_LIST	*prev;
	MASK		this;
	struct 	_MASK_LIST	*next;
}MASK_LIST;

typedef struct
{
	int mask_on;
	int	mask_ed;
	int	mask_vis;
	int mask_id;
}MASK_STORE;


/* Mask Functions */
void	fill_act_plane(CMY_COLOR *col);


MASK_LIST *find_mask_list(int num);
MASK_LIST *find_mask_list_id(int id);
MASK	*find_mask(int num);
MASK	*find_mask_id(int id);
int		count_masks(void);
void	insert_mask_win(void);
void	insert_mask(void);
void	dial_newmask(int ob);
void	modify_mask_win(void);
void	modify_mask(void);
void	delete_mask(void);
void	clear_mask(void);
void	copy_mask_init(void);
void	copy_mask(int sid, int did, int how);
void	copy_mask_lay(int sid, int did, int how);
void	copy_lay_mask(int src, int dst, int how);
int		mask_popup(OBJECT *tree, int ob, int disable_id);


/* Mask Globvars */

extern int mask_id;
extern MASK	*mod_mask;
extern MASK_STORE mask_store[11];
extern MASK_LIST	*first_mask, *act_mask, *painted_mask;

extern OBJECT *onewmask;
extern WINDOW wnewmask;
extern DINFO	dnewmask;

extern unsigned char mask_col_tab[8];

#endif