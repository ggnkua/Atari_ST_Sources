

/* these define the largest character screen possible, just bigger than my Moniterm */
#define MAXX	160
/* this should be power of 2 */
#define	MAXY	64

struct ws {
	struct ws *next,*prev;
	word x,y,w,h;
	word xpos,ypos;
	uword wword;
	ulong wlong;		/* <--------keep with */
	byte number;		/* <--------this one  */
	bool written;		/* NE if written to */
	bool remember,open;
	byte type,zoomed;
	word ox,oy,ow,oh;
	char *title;
	void *magic;						/* depends on type */
	long *lockreg;						/* ptr to lock reg, or 0 */
	long lastlock;						/* last value of lock reg */
	schar contents[MAXX][MAXY];			/* should be ptr */
	};

#define	isborder(x)	( (x>=BD_FIRST) && (x<=BD_LAST) )

#define MAXTITLE	70					/* longest text; '1 '+null extra */
#define	MAXWINDOW	11					/* no of windows; max is less 1. Last one is special */
#define	NOWINDOW	-1

#define	update_contents(a)	update_rectangle( (word)(a->x+1),(word)(a->y+1),(word)(a->w-2),(word)(a->h-2) )

extern struct ws *wlist[MAXWINDOW],*frontwindow;
extern word frontnum;

void wprint_line(struct ws*,char *,bool);
void border_out(word,word,schar,bool);
void char_out(word,word,schar);
void start_command(struct ws *, char *);
void window_cls(struct ws *);
word open_window(word num,word x,word y,word w,word h, char *t,byte wtype);
