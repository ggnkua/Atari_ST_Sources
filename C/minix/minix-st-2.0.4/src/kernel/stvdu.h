/* default screen colors - change these to your taste */
#define DEFAULT_BKGRND	RGB_WHITE
#define DEFAULT_FORGRND RGB_BLACK

/* Constants relating to the video RAM and fonts */

#if (ATARI_TYPE == TT)
#define	VIDEORAM	320*480	/* size of video ram */
#else
#define	VIDEORAM	32000	/* size of video ram */
#endif
#define VIDEOALIGNMENT	256	/* alignment of video ram */
#define NCOL		80	/* characters on a row */

#define	M_LIN_SCR	400	/* video lines on mono screen */
#define	M_BYT_LIN	80	/* bytes in mono video line */
#define	FONTM		16	/* 25 lines mono (or 8 for 50 lines) */

#define	C_LIN_SCR	200	/* video lines on color screen */
#define	C_BYT_LIN	160	/* bytes in color video line */
#define	FONTC		8	/* 25 lines color */

/* bit values for v->attr */
#define REV_PLANE0	1	/* reverse plane 0 */
#define REV_PLANE1	2	/* reverse plane 1 */
#define REVERSE		(REV_PLANE0|REV_PLANE1)
#define INHIB_PLANE0	4	/* inhibit plane 0 */
#define INHIB_PLANE1	8	/* inhibit plane 1 */
#define UL_PLANE0	16	/* underline plane 0 */
#define UL_PLANE1	32	/* underline plane 1 */
#define UNDERLINE	(UL_PLANE0|UL_PLANE1)
#define BOLD_PLANE0	64	/* underline plane 0 */
#define BOLD_PLANE1	128	/* underline plane 1 */
#define BOLD	(BOLD_PLANE0|BOLD_PLANE1)
#define DISPLAY_ATTRIBS (REVERSE|UNDERLINE|BOLD)

/* Structure to keep data about virtual consoles in. Each virtual console
 * has its own screen ram, color table, keyboard setting etc. Exchanging the
 * currently displayed virtual console just requires a reprogramming of the
 * video controller with the new data from virterm, as well as setting some
 * variables for the keyboard driver.
 */
typedef struct virterm {
	struct tty *c_tty;	/* associated tty_table entry */
	void 	*v_kbd;		/* associated kb_s entry */
		/* vdu hardware controller data */
	unsigned short vrgb[16];/* color table entry */
	unsigned char  vres;	/* screen resolution */
	char	mono;		/* 1 if mono, 0 if color */
	char	*vram;		/* base of video ram */
		/* font and cursor data */
	int	linc;		/* video lines in char */
	int	bytc;		/* bytes in video line */
	int	nrow;		/* char rows on screen */
	int	bytr;		/* bytes in row of chars */
	char	*curs;		/* cursor position in video RAM */
	int	curmode;	/* cursor mode, 1 = cursor on */
	int	cursenable;	/* cursor enabled, 0 = cursor invisible */
		/* terminal output state */
	unsigned char	attr;	/* current attribute byte */
	char	tabs[NCOL];	/* current tab stops */
	int	topscroll;	/* top line of scroll region */
	int	botscroll;	/* bottom line of scroll region */
	int	ccol;		/* current char column */
	int	crow;		/* current char row */
	int	wrap;		/* state of auto-wrap */
	int	origmode;	/* origin mode */
	unsigned char savattr;	/* saved attribute byte */
	int	savccol;	/* saved char column */
	int	savcrow;	/* saved char row */
	int	savorigmode;	/* saved origin mode */
	char	vbuf[30];	/* partial escape sequence */
	char	*next;		/* next char in vbuf[] */
		/* terminal input state */
	int	vkeypad;	/* keyboard keypad state */
	int	vapmode;	/* keyboard cursor state */
} virterm_t;

