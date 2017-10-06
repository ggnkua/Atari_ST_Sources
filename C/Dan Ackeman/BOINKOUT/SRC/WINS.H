/********************************************/
/*											*/
/*					WINS.H					*/
/*				 jan 18 1996				*/
/*				 Dan Ackerman				*/
/*											*/
/*		My window struct includes			*/
/*											*/
/********************************************/

struct win_info
{
	int handle;
	OBJECT *window_obj; /* RSC object for window */
	int status; /* 1 = Normal, 2 = Rolled up, 3 = Iconified */
	char *title;
	GRECT curr;
	int page;
	int cur_item;
	int edit_pos;
	char *text_block;
	long  buf_size;
	int   total_items;
	int	  edit; /* 0 = NO, 1 = Set it */
	OBJECT *icon_obj; /* The windows iconified icon */
	GRECT icon; /* icon_ are the redraw points for the iconified window */
	int type; /* 0 - Closer (w_type), 1 - No closer (w_type2) */
};

extern struct win_info win[MAX_WINDOWS];

#ifndef SMALLER
#define SMALLER 0x4000
#endif

/*#define W_TYPE (NAME | MOVER | CLOSER | FULLER | SMALLER) disabled FULLER */
#define W_TYPE (NAME | MOVER | CLOSER | SMALLER)
#define W_T2 (NAME | MOVER | FULLER | SMALLER)
#define W_T3 (NAME | MOVER)
