
struct virtual_input
{
	WORD	result;
	WORD	curx;
	WORD	cury;
	WORD	curz;
	WORD	data;
};
typedef	struct	virtual_input	VIRTUAL_INPUT;
typedef struct virtual_input Vis;
extern Vis virtual;


/* These defines correspond to the result byte */
#define	UP		0x0000	/* button is up */
#define	JUST_DN		0x0001	/* button just went down */
#define	JUST_UP		0x0002	/* button just went up */
#define	DN		0x0003	/* button is down */
#define	CANCEL		0x0004	/* cancel button pressed */
#define	KEYPRESS	0x0008	/* key was pressed */
#define	OFFSCALE	0x0010	/* pen is off the tablet */
#define	WINDOWCLOSED	0x0020	/*close the window*/
#define	WINDOWSIZED	0x0040	/*size the window*/
#define	MENUPICKED	0x0080	/* pull down menu item selected*/
#define	WINDOWUPFRONT	0x0100	/* upfront the window*/
#ifdef UNUSED
#define	WINDOWDRAG	0x0200	/* drag the window*/
should be WINDOWDRAGGED
#endif UNUSED
#define	WINDOW_REFRESH	0x0400	/* refresh the window*/
#define GADGETSELECTED  0x0800   /* a gadget was hit*/

/* These defines correspond to the data byte */
#define	ASCII_FST	0
#define ASCII_LST	255
#define	NOTASCII	-1

#define	NO_CURSOR	0
#define	USE_CURSOR	1

/* macros for high level input routines */
#define pdn(vis)	((vis)->result & 1)
#define pjstdn(vis)	(((vis)->result & 3) == JUST_DN)
#define	cancel(vis)	((vis)->result & CANCEL)
#define	keypress(vis)	((vis)->result & KEYPRESS)
#define keydata(vis)	(((vis)->result & KEYPRESS) ? (vis)->data : NOTASCII)
#define anydn(vis)	(pdn(vis) || pjstdn(vis) || cancel(vis))
#define allup(vis)	(!pdn(vis) && !pjstdn(vis) && !cancel(vis))
#define	anyinput(vis)	(anydn(vis) || (keypress(vis) != NOTASCII))
#define windowclose(vis) ((vis)->result & WINDOWCLOSED)
#define menupicked(vis) ((vis)->result & MENUPICKED)
#define clearmenupick(vis) ((vis)->result &= ~MENUPICKED)


/* externs */
extern  VIRTUAL_INPUT	*quick_input();
extern	VIRTUAL_INPUT	*await_input();
extern	VIRTUAL_INPUT	*await_anydn();
extern	VIRTUAL_INPUT	*await_keydn();
extern	VIRTUAL_INPUT	*getinput();
extern	VIRTUAL_INPUT	*getcurvis();

