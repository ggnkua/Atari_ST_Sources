/* dialog box handler for Mon, also pop-up menus */

#include "mon.h"
#include "window.h"
#include "time.h"

struct ws *dlog;
static struct ws *oldfront;
char *line_buffer;
char dlog_line[256];


void window_title2(struct ws *wptr, char *t, bool draw);
void recalcw();
void recalc_frontback();
void remove_wlist(struct ws *);
void add_wlist(struct ws *);


/* a dialog is not really a true window, as the active window
	remains unchanged by it. A dialog is a trick of the light */

#define	DLOGX	2

/* a ypos of 0 means inside it */
void print_dialog(word ypos, char *mes)
{
	dlog->xpos=DLOGX;
	dlog->ypos=++ypos;
	wprint_str(mes);
}

/* height is specified as internal height */
/* if prompt is zero then we are really a menu */
word open_dialog(char *title, word width, word height, char *prompt)
{

word num;

	if ( (num=spare_window(TRUE))==-1)
		return ERRM_NOSPARE;

	dlog=wlist[num];

	/* centered on screen */
	dlog->x=(maxw-width-2)/2;
	dlog->y=(maxh-height-2)/2;
	dlog->w=width+2;
	dlog->h=height+2;

	dlog->open=TRUE;
	dlog->number=num;
	dlog->type=WTYPE_DIALOG;
	dlog->magic=NULL;
	add_wlist(dlog);

	/* mark us on the screen, carefully as we are not in the wlist */
	window_cls(dlog);
	window_title2(dlog,title,FALSE);
	recalcw(dlog);
	update_rectangle(dlog->x,dlog->y,dlog->w,dlog->h);

	line_buffer=dlog_line;			/* where it will be remembered */

	if (prompt)
		{
		winit_command(dlog);
		if (dlog->type==WTYPE_NONE)
			{
			close_dialog();
			return ERRM_NOMEMORY;
			}

		print_dialog(1,prompt);			/* print prompt */
		dlog->xpos=DLOGX;
		dlog->ypos++;
		start_command(dlog,"");
		}

	return 0;
	
}


word wait_dialog()
{
word key,mx,my,ev;

	for(;;)
		{
		xor_command();
		ev=get_event(&key,&mx,&my);
		xor_command();
		if (ev&EV_KEY)
			{
			if (key==KEY_ESC)
				return ERRM_INTERRUPTED;
			key_command(key);
			if ( (key==KEY_RETURN) || (key==KEY_ENTER) )
				return 0;
			}
		}

	return ev;
}

void close_dialog()
{

	wdeinit_command(dlog);

	dlog->open=FALSE;

	remove_wlist(dlog);

	/* restore correct view of world */
	recalc_frontback();
	/* and redraw this new place */
	update_rectangle(dlog->x, dlog->y, (word)(dlog->x+dlog->w),
			(word)(dlog->y+dlog->h) );
	
}

void light_line(word y, word x, word width)
{
	y++; x++;					/* allow for window border */
	while (width--)
		{
		cursor_out( (word)(frontwindow->x+x),
			(word)(frontwindow->y+y) );
		x++;
		}
}

#define	MAXMENUWIDTH	29




/* a menu is a dialog which you cannot really type into */
/* it is passed a pointer to an array of chars */
/* and an (optional) reload function */
/* cannot use dlog var else cannot be invoked over them */

word do_menu(char *title, word width, word height, char *list[],
	word *result, bool(*reload)(char*, word*), char *preload )
{
word i;
word ev,key,mx,my;
word currenty,currentx;
word visible;
word num;
struct ws *menuw;
char menu_so_far[MAXMENUWIDTH+1];		/* can, in theory, recurse */
word numlist;

	if (preload==NULL)
		menu_so_far[0]=0;
	else
		{
		stccpy(menu_so_far,preload,MAXMENUWIDTH);
		strupr(menu_so_far);
		}
	currentx=strlen(menu_so_far);
	(reload)(menu_so_far,&numlist);		/* initial value */
	if (numlist==0)
		{
		*result=-1;
		return 0;
		}
	if ( (num=spare_window(TRUE))==-1)
		return ERRM_NOSPARE;

	if (width>MAXMENUWIDTH)
		width=MAXMENUWIDTH;
		
	menuw=wlist[num];

	/* centered on screen */
	menuw->x=(maxw-width-2)/2;
	menuw->y=(maxh-height-2)/2;
	menuw->w=width+2;
	menuw->h=height+2;

	menuw->open=TRUE;
	menuw->number=num;
	menuw->type=WTYPE_DIALOG;
	menuw->magic=NULL;

	add_wlist(menuw);


	/* mark us on the screen, carefully as we are not in the wlist */
	window_cls(menuw);
	window_title2(menuw,title,FALSE);
	recalcw(menuw);
	update_rectangle(menuw->x,menuw->y,menuw->w,menuw->h);

	for (;;)
		{
p:		visible=min(height,numlist);
		currenty=0;
		/* print the entries */
		for (i=0; i<visible; i++)
			{
			menuw->xpos=DLOGX;
			menuw->ypos=i+1;
			wprint_str(list[i]);
			}
k:		if (visible)
			light_line(currenty,(word)(currentx+1),(word)(width-currentx-1));
		else
			light_line(currenty,1,(word)(width-1));

		ev=get_event(&key,&mx,&my);

		if (visible)
			light_line(currenty,(word)(currentx+1),(word)(width-currentx-1));
		else
			light_line(currenty,1,(word)(width-1));

		if (ev&EV_CLICK)
			{
			word w; ubyte edge;
			if (visible)
				{
				w=which_window(&mx,&my,&edge);
				if ( (w==num) && (edge==0) && (my<=visible) )
					{
					if (key)
						{ /* a double-click */
						key=KEY_RETURN;
						break;
						}
					currenty=--my;
					goto k;
					}
				}
			}
		if (ev&EV_KEY)
			{
			if ( (key==KEY_UP) && (currenty) && visible )
				{ currenty--; goto k; }
			if ( (key==KEY_DOWN) && visible && (currenty<(visible-1)) )
				{ currenty++; goto k; }
			if ( (key==KEY_RETURN) || (key==KEY_ENTER) || (key==KEY_ESC) )
				break;
			if (reload)
				{
				if (key==KEY_BACKSPACE)
					{
					if (currentx)
						menu_so_far[--currentx]=0;
					}
				else if (key==KEY_CLEAR)
					{
					menu_so_far[currentx=0]=0;
					}
				else if (key&0xFF)
					{
					if (currentx<MAXMENUWIDTH)
						menu_so_far[currentx++]=upper((char)key);
						menu_so_far[currentx]=0;
					}
				else
					goto k;
				if ( (reload)(menu_so_far,&numlist) )
					{
					window_cls(menuw);
					update_contents(menuw);
					goto p;
					}
				else
					goto k;
				}
			}
		goto k;
		}
	/* like close_dialog */
	remove_wlist(menuw);
	menuw->open=FALSE;

	/* restore correct view of world */
	recalc_frontback();
	/* and redraw this new place */
	update_rectangle(menuw->x, menuw->y, (word)(menuw->x+menuw->w),
			(word)(menuw->y+menuw->h) );

	*result=( (key==KEY_ESC) || (visible==0) )
					 ? -2 : currenty;
	return 0;
}

/* 2nd line is optional */
word general_alert(char *title, char *line1, char *line2, const char *keylist, word *res)
{
word width,height;
word num;
struct ws *alertw;
word key,mx,my,ev;
word err;

	width=strlen(line1);
	height=5;
	if (line2)
		{
		width=max(width,strlen(line2));
		height+=2;
		}
	width+=4;
	width=min(maxw,width);

	if ( (num=spare_window(TRUE))==-1)
		return ERRM_NOSPARE;

	alertw=wlist[num];

	/* centered on screen */
	alertw->x=(maxw-width)/2;
	alertw->y=(maxh-height)/2;
	alertw->w=width;
	alertw->h=height;

	alertw->open=TRUE;
	alertw->number=num;
	alertw->type=WTYPE_DIALOG;
	alertw->magic=NULL;

	add_wlist(alertw);

	/* mark us on the screen, carefully as we are not in the wlist */
	window_cls(alertw);
	window_title2(alertw,title ? title : "",FALSE);
	recalcw(alertw);
	update_rectangle(alertw->x,alertw->y,alertw->w,alertw->h);

	alertw->xpos=2;
	alertw->ypos=2;
	wprint_str(line1);
	if (line2)
		{
		alertw->xpos=2;
		alertw->ypos+=2;
		wprint_str(line2);
		}

	for (;;)
		{
		err=0;
		ev=get_event(&key,&mx,&my);
		if (keylist)
			{
			if (ev&EV_KEY)
				{
				char *match;
				if (key==KEY_ESC)
					{
					err=ERRM_INTERRUPTED;
					break;
					}
				key=toupper(key&0xFF);
				if (match=strchr(keylist,key))
					{
					*res=(word)(match-keylist);
					break;						/* returns 0 */
					}
				}
			}
		else if (ev&(EV_KEY|EV_CLICK))
			break;			/* any key exits or a click */
		}

	remove_wlist(alertw);
	alertw->open=FALSE;

	/* restore correct view of world */
	recalc_frontback();
	/* and redraw this new place */
	update_rectangle(alertw->x, alertw->y, (word)(alertw->x+alertw->w),
			(word)(alertw->y+alertw->h) );

	return err;
}

word simple_alert(char *title, char *line1, char *line2)
{
	return general_alert(title,line1,line2,NULL,NULL);
}

txt(TX_YN);

/* returns TRUE if Y or FALSE if N (or error) */
bool yn_alert(char *line1, char *line2)
{
word err; word res;
	err=general_alert("",line1,line2,TX_YN,&res);
	if ( (err==0) && (res==0) )
		return TRUE;
	else
		return FALSE;
}

txt(TX_ALERTERROR);

/* always returns same error code, doesnt do anything if interrupted */
word error_alert(word errnum, char *extra)
{
	if (errnum && (errnum!=ERRM_INTERRUPTED))
		simple_alert(TX_ALERTERROR,error_message(errnum),extra);
	return errnum;
}

#if DEMO

// print a message in a nice way
// returns next page of text, or NULL if there is no more

static char *demo_message(struct ws *alertw, char *message, int longest)
{
char *prompt = "---ESC to Start, Space for More---";

	window_cls(alertw);
	update_rectangle(alertw->x,alertw->y,alertw->w,alertw->h);
	
	alertw->ypos=2;

	for (;;)
		{
		char *start, *space;
		int w;
		char c;
		
		// calculate how much we can fit on a line
		space = start = message;
		w = longest;

		while (w--)
			{
			c = *message++;
			if ( (c=='\n') || (c=='@') || (c=='\r') )
				{
				space = message - 1;
				break;					// hard CRs are respected
				}
			if (c==0)
				{
				message = NULL;
				break;
				}
			if (c==' ')
				space = message - 1;
			}
			
		// got a line - print it
		if (c)
			*space = 0;					// null term it
		alertw->xpos=2;
		wprint_str( start );			// and print it
		alertw->ypos++;
		if (c=='\n')
			alertw->ypos++;				// CRs count double
		if (c && (c!='@') )
			{
			*space = c;
			message = ++space;
			}
		else
			break;						// stop when run out of messages
		}
	alertw->xpos = (alertw->w - strlen(prompt)) / 2;
	alertw->ypos = alertw->h - 2;
	wprint_str(prompt);

	return message;
}

// demo alert box, based on general_alert
// given a long string, word wrap it to fit

word demo_alert(char *message)
{
word width,height;
word num;
struct ws *alertw;
word key,mx,my,ev;
word err;

	width=maxw-4;
	height=maxh-2;

	if ( (num=spare_window(TRUE))==-1)
		return ERRM_NOSPARE;

	alertw=wlist[num];

	/* centered on screen */
	alertw->x=(maxw-width)/2;
	alertw->y=(maxh-height)/2;
	alertw->w=width;
	alertw->h=height;

	alertw->open=TRUE;
	alertw->number=num;
	alertw->type=WTYPE_DIALOG;
	alertw->magic=NULL;

	add_wlist(alertw);

	/* mark us on the screen, carefully as we are not in the wlist */
	window_cls(alertw);
	window_title2(alertw,"X-Debug Demonstration",FALSE);
	recalcw(alertw);
	update_rectangle(alertw->x,alertw->y,alertw->w,alertw->h);

	width -= 4;								// used as max text width
	
	message = demo_message(alertw, message, width);

	for (;;)
		{
		err=0;
		ev=get_event(&key,&mx,&my);
			{
			if (ev&EV_KEY)
				{
				if (key==KEY_ESC)
					{
					err=ERRM_INTERRUPTED;
					break;
					}
				else
					{
					key &= 0xff;
					if ( (key==13) || (key==' ') )
						{
						if (!message)
							break;						// if no more
						// user wants more!
						message = demo_message(alertw, message, width);
						}
					}
				}
			}
		}

	remove_wlist(alertw);
	alertw->open=FALSE;

	/* restore correct view of world */
	recalc_frontback();
	/* and redraw this new place */
	update_rectangle(alertw->x, alertw->y, (word)(alertw->x+alertw->w),
			(word)(alertw->y+alertw->h) );

	return err;
}

#endif
	