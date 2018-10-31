#ifndef _WIN_H_
#define _WIN_H_

typedef struct
{
	int handle;	/* AES Window handle for this window */
	char *title;	/* Title for title bar of window */
	OBJECT *window_obj; /* RSC object for window */
	int type; 		/* 0 - Closer (w_type), 1 - No closer (w_type2) */
	int status;		 /* 0 = Normal, 1 = Rolled up, 3 = Iconified */
	GRECT current;   	/* Used for forcing redraws */

	MFDB	image;	/* Back drop for window */
	RGB1000 colortab[256]; /* used to save colors */
	
	int cur_item;
	int edit_pos;
	
	int   total_items;
	int   edit; 	/* 0 = NO, 1 = Set it */
	OBJECT *icon_obj; 	/* The windows iconified icon */
	GRECT icon;	 /* icon_ are the redraw points for the iconified window */
	
}win_info ;

#define W_TYPE (NAME | MOVER | CLOSER | SMALLER)
#define W_T2 (NAME | MOVER | FULLER | SMALLER)
#define W_T3 (NAME | MOVER)

#ifndef WM_SHADED
#define WM_SHADED	0x5758
#define WM_UNSHADED	0x5759
#define	WF_SHADE	0x575D
#endif

extern int get_topwindow(int window);
extern int close_all_windows(void);
#ifndef _GEMLIB_H_
	extern int rc_intersect( GRECT *r1, GRECT *r2 );
#endif
extern void handle_win(int wind, void *handler);
extern int get_wininfo_from_handle(int w_hand);
extern int new_window(OBJECT *tree, const char *title, int type);
extern int redraw(int wh, GRECT *area);
extern int do_wind_redraw(int wh, GRECT *p);
extern int custom_redraw(int wh, GRECT *p);

#endif