/* showf.c */


#include "obdefs.h"
#include "gemdefs.h"
#include "osbind.h"
#include "mydefs.h"
#include "show.h"
#include "addr.h"
#include "error.h"
#include "errno.h"
#include "stat.h"


#define MAX(X,Y)	( (X) > (Y) ? (X) : (Y) )
#define MIN(X,Y)	( (X) < (Y) ? (X) : (Y) )
#define NARGV 128


/* AES (windows and messages) related variables */
int gl_hchar;		/* height of system font (pixels) */
int gl_wchar;		/* width of system font (pixels) */
int gl_wbox;		/* width of box able to hold system font */
int gl_hbox;		/* height of box able to hold system font */

extern int gl_apid;

int phys_handle;	/* physical workstation handle */
int handle;			/* virtual workstation handle */
int wi_handle;		/* window handle */

int formw, formh, sx, sy, lx, ly;	/* dialogue box dimensions */
int xdesk, ydesk, hdesk, wdesk;		/* window X, Y, width, height */
int xwork, ywork, hwork, wwork;		/* desktop and work areas */

char *sbuf[512];
int keycode;		/* keycode returned by event-keyboard */
int mx, my;		/* mouse x and y pos. */
int butdown;		/* button state tested for, UP/DOWN */
int ret;		/* dummy return variable */
int hidden;		/* current state of cursor */
int contrl[12];
int intin[128];
int ptsin[128];
int intout[128];
int ptsout[128];	/* storage wasted for idiotic bindings */
int work_in[11];	/* Input to GSX parameter array */
int work_out[57];	/* Output from GSX parameter array */
int pxyarray[10];	/* input point array */
int msg[8];			/* message buffer */
long toptx;			/* the top line of text currently in the window */
long leftx;			/* the most left text in the window */
char *dbuff;		//* a format buffer of a file */
char *sbuff;		//* a source buffer of a file */
long *list;			/* the list of pointer of lines in a file */
long nrow;			/* total number of lines in a file */
int running;
long maxln=0;			/* the longest of text in a file */
long fsiz;			/* the size of show file */
char *tolstr = "9999";
char info[120];	/* buffer for the infomation in the window */
char showfn[24];	/* buffer of the name of show file */
int tolfile;	/* the number of files to be show */
int fno=1;		/* the index of the file list */
int prvfno=0;	/* the previous show file */
int prvfmt;		/* the previous show file format*/
int showasc=1;	/* 1: show the as ascii file */
int showlen;	/* the lenth of the show file */
int showstd;	/* the start pointer of the show file */
int openyes;	/* 1: open a new file */
DMABUFFER dma;

static char argcopy[128];
static char *argv[NARGV];

main(argc, argv)
int argc;
char *argv[];
{


	int done = FALSE;
	int skip = 0;
	int rut;

    appl_init();
    phys_handle=graf_handle(&gl_wchar, &gl_hchar, &gl_wbox, &gl_hbox);
    wind_get(0, WF_WORKXYWH, &xdesk, &ydesk, &wdesk, &hdesk);
    rut = open_vwork();

    if (!rsrc_load(RESOURCEFILE))	{
		errs("[2][|", RESOURCEFILE, "][ EXIT ]");
		goto doneit;
	}
    
    /* Get all addresses of dialogues from resource file */
    if (getalladdr() != OK) {
		errs("[2][|", RESOURCEFILE, "][ EXIT ]");
		goto doneit;
    }

    ARROW_MOUSE;
	if (!rut)	{	/* can't open the virtual workstation */
		form_alert(1, cnopen);
		goto donothing;
	}
	getargs(&argc, &argv);
	if (argc > 1)	{
		tolfile = argc-1;
	resel:
		if (select(skip) == EXIT)	{
			goto donothing;
		} else {	/* 1: first time to open the window */
			running = TRUE;
			openyes = 1;
			if ((rut=doopenwd(1, argv[fno])) == OK)	{
				skip = 1;
				goto resel;
			} else if (rut == ERROR)	{
				running = 0;
				goto donothing;
			}	/* else keep go on */
		}
		while(running)	{
			domulti();
		}
	} else {
		form_alert(1, needfile);
		goto donothing;
	}

	vst_alignment(handle, 0, 0, &done, &done); /*set text alignment*/

doneit:
	wind_delete(wi_handle);
	Mfree(dbuff);
	Mfree(sbuff);
	Mfree(list);
donothing:
    v_clsvwk(handle);
    appl_exit();
}

/* do the open window, read the files, and format them, then show them */

doopenwd(first, path)
int first;
char *path;
{

	int done = FALSE;
	long slidsiz, dsize;
	int hsldsiz;
	int i, tmpy, tmpx, fp;
	char *tem;
	long *tmp;
	char *s1 =" bytes used in 1 item.     NOTE: Hit 'Help' key for selection.";
	int showbin=0;
	long findrow(), ckupper(), gdbufsiz();
	/*
	int minADE, maxADE, maxwidth;
	int distances[5], effects[3];
	*/
	int attrib[10];


	BEE_MOUSE;
	if (fno == prvfno) {
		if ((prvfmt) && (!showasc))	{/* prevous and now showing binary fmt */
			goto skpconv;
		} else if ((!prvfmt) && (showasc))	{/* prv & now showing ascii fmt */
			goto skpconv;
		} else {
			Mfree(dbuff);
			Mfree(list);
			fsiz = dma.d_fsize;
			goto skprd;
		} 
	} 
	if (!first)	{
		Mfree(dbuff);
		Mfree(sbuff);
		Mfree(list);
	}
	Fsetdta(&dma);
	if (Fsfirst(path, 0x3F) != 0)	{
		ARROW_MOUSE;
		if (form_alert(2, cnfdf) == 1)	{
			return OK;		/* skip */
		} else {			/* cancel */
    		erasemsg();		/* erase the select dialog box */
			return ERROR;
		}
	}
	info[0] = 0x20;
	fsiz = dma.d_fsize;
	itoa(dma.d_fsize, &info[1]);
	strcat(&info[0], s1);

	/* read the file into buffer */

	if ((sbuff = Malloc(dma.d_fsize + 150)) == NULL)	{
		ARROW_MOUSE;
		if (form_alert(2, outmem) == 1)	{
			return OK;		/* skip */
		} else {			/* cancel */
    		erasemsg();		/* erase the select dialog box */
			return ERROR;
		}
	}
	if ((fp = Fopen(path, 0)) < 0)	{
		ARROW_MOUSE;
		Mfree(sbuff);
		if (form_alert(2, cnopf) == 1)	{
			return OK;		/* skip */
		} else {			/* cancel */
    		erasemsg();		/* erase the select dialog box */
			return ERROR;
		}
	}
	if (Fread(fp, dma.d_fsize, sbuff) < 0)	{
		ARROW_MOUSE;
		Mfree(sbuff);
		Fclose(fp);			/* close the previous file */
		if (form_alert(2, cnrdf) == 1)	{
			return OK;		/* skip */
		} else {			/* cancel */
    		erasemsg();		/* erase the select dialog box */
			return ERROR;
		}
	}
	Fclose(fp);			/* close the previous file */

skprd:
	if ((showbin=binary(sbuff)) || (!showasc))	{
		/*it is a binary file or show as binary*/
		if ((showbin) && (showasc))	{
			ARROW_MOUSE;
			form_alert(1, binonly);
			BEE_MOUSE;
		} else {
			showbin = 1;
		}
		/* every 16 bytes of sbuf needs 67 bytes of dbuf */
		dsize = (dma.d_fsize/16+2)*67; 		
	} else {
		dsize = gdbufsiz(sbuff, dma.d_fsize) + 1000;
	}
	if ((dbuff = Malloc(dsize)) == NULL)	{
		ARROW_MOUSE;
		Mfree(sbuff);
		if (form_alert(2, outmem) == 1)	{
			return OK;		/* skip */
		} else {			/* cancel */
    		erasemsg();		/* erase the select dialog box */
			return ERROR;
		}
	}
	/* find out it is a binary file or not */
	if (showbin)	{		/*it is a binary file or show as binary*/
		nrow = dma.d_fsize/16;
		if (dma.d_fsize%16)	{
			nrow += 1;
		}
		if ((list = Malloc(nrow*4)) == NULL)	{
			if (nrow)	{
				Mfree(sbuff);
				Mfree(dbuff);
				ARROW_MOUSE;
				if (form_alert(2, outmem) == 1)	{
					return OK;		/* skip */
				} else {			/* cancel */
    				erasemsg();		/* erase the select dialog box */
					return ERROR;
				}
			}
		}
		bin2str(list, sbuff, dbuff);
	} else 	{ 			/* it is a asci file */
		nrow = findrow(sbuff, dma.d_fsize);
		if ((list = Malloc(nrow*4)) == NULL)	{
			if (nrow)	{
				ARROW_MOUSE;
				Mfree(dbuff);
				Mfree(sbuff);
				if (form_alert(2, outmem) == 1)	{
					return OK;		/* skip */
				} else {			/* cancel */
    				erasemsg();		/* erase the select dialog box */
					return ERROR;
				}
			}
		}
		asci2str(list, sbuff, dbuff, dma.d_fsize);

	}
    /*
     * Draw shrinking box and cleanup the screen;
     * return thing that caused our exit.
     */

skpconv:
    erasemsg();		/* erase the select dialog box */

	if (first)	{	/* it is the first time to open the window */
    	wi_handle=wind_create(0x0FFF, xdesk, ydesk, wdesk, hdesk);
	}
	wind_set(wi_handle, WF_INFO, &info[0], 0, 0);
	wind_set(wi_handle, WF_NAME, ckupper(path), 0, 0);
	if (first)	{
		wind_open(wi_handle, xdesk+30, ydesk+40, gl_wchar*70, gl_hchar*13);
		vst_alignment(handle, 0, 5, &done, &done); 
	}
	/*
	vqt_fontinfo(phys_handle, &minADE, &maxADE, distances, &maxwidth, effects);
	*/
	vqt_attributes(phys_handle, attrib);
	vst_height(handle, attrib[7], &done, &done, &done, &done);
   	wind_get(wi_handle, WF_WORKXYWH, &xwork, &ywork, &wwork, &hwork);

	toptx = 0;		/* start top line of text */
	leftx = 0; 		/* left side of the text */

	/* find slider size and set it */
	if (!nrow)	{
		slidsiz = 1000;
	} else {
		slidsiz = (1000*hwork/gl_hchar) / nrow; 
	}
	if (!maxln)	{
		hsldsiz = 1000;
	} else {
		hsldsiz = (1000*wwork/gl_wchar) / maxln;
	}
	wind_set(wi_handle, WF_VSLSIZE, (int)slidsiz, 0, 0, 0);
	wind_set(wi_handle, WF_HSLSIZE, hsldsiz, 0, 0, 0);
	mvslide(wi_handle, 3, 1);
	mvslide(wi_handle, 4, 1);
	ARROW_MOUSE;
	redwmsg(wi_handle); 
	prvfno = fno;
	prvfmt = showbin;
	return YES;
}



/* send don't redraw message to the window */

redwmsg(wh)

int wh;

{
	int msg[8];

	msg[0] = WM_REDRAW;
	msg[1] = gl_apid;
	msg[2] = 0;
	msg[3] = wh;
	msg[4] = 0;
	msg[5] = 0;
	msg[6] = 0;
	msg[7] = 0;
	appl_write(gl_apid, 16, &msg);
}


/* check the path name is a directory or not, if is, return 1 */

isdir(path)

char *path;

{

	char *ptr;
	int dir=0;

	ptr = path;
	while(*ptr)	{
		ptr++;
	}
	if (*(ptr-1) == 0x5C)	{	/* if it is a backslash, it is a directory */
		dir = 1;
	} 
	return(dir);
}


long ckupper(ptr)
char *ptr;
{
	char *stmp, *dtmp;

	stmp = ptr;
	dtmp = ptr;
	while (*stmp)	{
		*dtmp++ = (char)toupper((int)*stmp++);
	}
	return ptr;
}

itoa(n, s)
long n;
char s[];

{
	int i;
	long sign;

	if ((sign = n) < 0) /* record sign */
		n = -n;			/* make n positive */
	i = 0;
	do 	{
		s[i++] = n % 10 + '0';
	} while ((n /= 10) > 0);
	if (sign < 0)
		s[i++] = '-';
	s[i] = '\0';
	reverse(s);
}

reverse(s)
char s[];
{
	int c, i, j;

	for (i = 0, j=strlen(s)-1; i < j; i++, j--) 	{
		c = s[i];
		s[i] = s[j];
		s[j] = c;
	}
}

/* this function do the WM_FULLED message */

toggle(wh)		
int wh;
{

	GRECT prv, cur, full;

	/* get the previous, current, and the full size of windows */
	wind_get(wh, WF_PREVXYWH, &prv.g_x, &prv.g_y, &prv.g_w, &prv.g_h);
	wind_get(wh, WF_CURRXYWH, &cur.g_x, &cur.g_y, &cur.g_w, &cur.g_h);
	wind_get(wh, WF_FULLXYWH, &full.g_x, &full.g_y, &full.g_w, &full.g_h);

	/* if it is full size, change it to previous unless that was full also */

	if (((cur.g_x == full.g_x) &&
		 (cur.g_y == full.g_y) &&
		 (cur.g_w == full.g_w) &&
		 (cur.g_h == full.g_h)) &&
		 	((prv.g_x != full.g_x) ||
		 	 (prv.g_y != full.g_y) ||
		 	 (prv.g_w != full.g_w) ||
		 	 (prv.g_h != full.g_h))) 	{
		wind_set(wh, WF_CURRXYWH, prv.g_x, prv.g_y, prv.g_w, prv.g_h);
    	wind_get(wh, WF_WORKXYWH, &xwork, &ywork, &wwork, &hwork);
		prv.g_x = xwork;
		prv.g_y = ywork;
		prv.g_h = hwork;
		prv.g_w = wwork;
	} else {
		wind_set(wh, WF_CURRXYWH, full.g_x, full.g_y, full.g_w, full.g_h);
    	wind_get(wh, WF_WORKXYWH, &xwork, &ywork, &wwork, &hwork);
		if (maxln <= wwork/gl_wchar)	{
			leftx = 0;
		}
		if (nrow <= hwork/gl_hchar)	{
			toptx = 0;
		}
	}
	mvslide(wh, 4, 1);
	mvslide(wh, 3, 1);
}


Redraw(msg, dbox)	

int msg;		/* window handle from msg[3] */
GRECT *dbox;	/* pointer to the redraw rectangle */

{  

	GRECT wdrct;	/* the current window rectangle in rect list */ 
	int done;
	int temp[4];

	hide_mouse();		/* turn off mouse */
	wind_update(BEG_UPDATE);	/* lock screen */
	vsf_interior(handle, 1);	
	vsf_color(handle, 0);
	wind_get
		(msg, WF_FIRSTXYWH, &wdrct.g_x, &wdrct.g_y, &wdrct.g_w, &wdrct.g_h);
	while (wdrct.g_w && wdrct.g_h)	{	/* while it is not the last one */
		if (rc_intersect(dbox, &wdrct))	{ /*check see if this one is damaged*/ 
			setclip(&wdrct);
			temp[0] = wdrct.g_x;
			temp[1] = wdrct.g_y;
			temp[2] = wdrct.g_x + wdrct.g_w - 1;
			temp[3] = wdrct.g_y + wdrct.g_h - 1;
			v_bar(handle, temp);
			writewd(msg);				/* redraw the window */
		}
		wind_get
		  (msg, WF_NEXTXYWH, &wdrct.g_x, &wdrct.g_y, &wdrct.g_w, &wdrct.g_h);
	}
	wind_update(END_UPDATE);	/* unlock screen */
	show_mouse();		/* turn on mouse */

}


/* draw and display the window */

writewd(msg)

int msg;
{
	int i, j, k;
	int x, y, w, h;

	j = nrow - toptx;	/* number of line left */
	wind_get(msg, WF_WORKXYWH, &x, &y, &w, &h);
	k = ((h-1)%gl_hchar)?((h-1)/gl_hchar+1):((h-1)/gl_hchar);
	for (i=0; i < k; i++)	{
		if (toptx+i < nrow)	{
			v_gtext(handle, x-(int)leftx*gl_wchar, 
							gl_hchar*i + y, *(list+toptx+i));
		} else	{
			break;
		}
	}
}


blit2lf(msg, dbox)	

int msg;		/* window handle from msg[3] */
GRECT *dbox;	/* pointer to the redraw rectangle */

{  

	GRECT wdrct;	/* the current window rectangle in rect list */ 
	int done;

	/*
	hide_mouse();		
	*/
	wind_update(BEG_UPDATE);	/* lock screen */
	vsf_interior(handle, 1);	
	vsf_color(handle, 0);
	wind_get
		(msg, WF_FIRSTXYWH, &wdrct.g_x, &wdrct.g_y, &wdrct.g_w, &wdrct.g_h);
	while (wdrct.g_w && wdrct.g_h)	{	/* while it is not the last one */
		if (rc_intersect(dbox, &wdrct))	{ /*check see if this one is damaged*/ 
			setclip(&wdrct);
			blitlf(msg, &wdrct);
		}
		wind_get
		  (msg, WF_NEXTXYWH, &wdrct.g_x, &wdrct.g_y, &wdrct.g_w, &wdrct.g_h);
	}
	wind_update(END_UPDATE);	/* unlock screen */
	/*
	show_mouse();
	*/

}


/* redraw the window */

blitlf(wh, box)
int wh;
GRECT *box;

{
	int i, j, k, l, m, done;
	GRECT rect;
	int pxyarray[8];
	int x[2]; 
	char *pt;
	char y[3];

	x[0] = 0;
	x[1] = 0;
	y[1] = 0;
	y[2] = 0;

	graf_mouse(M_OFF, 0L);
	pxyarray[0] = box->g_x;
	pxyarray[1] = box->g_y;
	pxyarray[2] = box->g_x+box->g_w-gl_wchar;
	pxyarray[3] = box->g_y+box->g_h;
	pxyarray[4] = box->g_x+gl_wchar;
	pxyarray[5] = box->g_y;
	pxyarray[6] = box->g_x+box->g_w;
	pxyarray[7] = box->g_y+box->g_h;
	vro_cpyfm(handle, 3, pxyarray, &x[0], &x[0]);
	rect.g_x = box->g_x;
	rect.g_y = box->g_y;
	rect.g_w = gl_wchar;
	rect.g_h = box->g_h;
	clrbox(&rect);			/* clear this line */
	j = nrow - toptx;	/* number of line left */
	i = box->g_y-ywork+box->g_h-1;
	k = (i%gl_hchar)?(i/gl_hchar+1):(i/gl_hchar);
	i = (box->g_y-ywork)/gl_hchar;
	for (; i < k; i++)	{
		if (j > i)	{
			pt = *(list+toptx+i);
			if (box->g_x == xwork)	{
				l = lenth(pt);
				if ((*pt == 0x20) && (l < 2))	{
					;				/* do nothing */
				} else if (l > leftx)	{
					pt = pt + leftx;
					y[0] = *pt;
					v_gtext(handle, xwork, gl_hchar*i+ ywork, &y[0]);
				}
			} else {
				l = lenth(pt);
				m = (box->g_x-xwork)/gl_wchar;
				if ((l-leftx) >= m)	{
					pt = pt + leftx + m;
					y[0] = *pt;
					if (((box->g_x-xwork)%gl_wchar))	{
						y[1] = *(pt+1);
					}
					v_gtext(handle,  xwork+m*gl_wchar, 
											gl_hchar*i+ywork, &y[0]);
				}
			}
		} else	{
			break;
		}
	}
	graf_mouse(M_ON, 0L);
}

blit2rt(msg, dbox)	

int msg;		/* window handle from msg[3] */
GRECT *dbox;	/* pointer to the redraw rectangle */

{  

	GRECT wdrct;	/* the current window rectangle in rect list */ 
	int done;

	/*
	hide_mouse();	
	*/
	wind_update(BEG_UPDATE);	/* lock screen */
	vsf_interior(handle, 1);	
	vsf_color(handle, 0);
	wind_get
		(msg, WF_FIRSTXYWH, &wdrct.g_x, &wdrct.g_y, &wdrct.g_w, &wdrct.g_h);
	while (wdrct.g_w && wdrct.g_h)	{	/* while it is not the last one */
		if (rc_intersect(dbox, &wdrct))	{ /*check see if this one is damaged*/ 
			setclip(&wdrct);
			blitrt(msg, &wdrct);
		}
		wind_get
		  (msg, WF_NEXTXYWH, &wdrct.g_x, &wdrct.g_y, &wdrct.g_w, &wdrct.g_h);
	}
	wind_update(END_UPDATE);	/* unlock screen */
	/*
	show_mouse();
	*/
}


blitrt(wh, box)
int wh;
GRECT *box;

{
	int i, j, k, l, done;
	GRECT rect;
	int pxyarray[8];
	int x[2]; 
	char y[3];
	char *pt;

	x[0] = 0;
	x[1] = 0;
	y[1] = 0;
	y[2] = 0;

	graf_mouse(M_OFF, 0L);
	pxyarray[0] = box->g_x+gl_wchar;
	pxyarray[1] = box->g_y;
	k = ((box->g_x-xwork+box->g_w-1)/gl_wchar)*gl_wchar;
	pxyarray[2] = xwork+k;
	pxyarray[3] = box->g_y+box->g_h;
	pxyarray[4] = box->g_x;
	pxyarray[5] = box->g_y;
	pxyarray[6] = pxyarray[2]-gl_wchar;
	pxyarray[7] = box->g_y+box->g_h;
	vro_cpyfm(handle, 3, pxyarray, &x[0], &x[0]);
	rect.g_x = xwork+ k - gl_wchar;
	rect.g_y = box->g_y;
	rect.g_w = ((box->g_x-xwork+box->g_w-1)%gl_wchar)?
				(box->g_x-xwork+box->g_w-k+gl_wchar) : (gl_wchar+1);
	rect.g_h = box->g_h;
	clrbox(&rect);			 
	j = nrow - toptx;	/* number of line left */
	i = box->g_y-ywork+box->g_h-1;
	l = (i%gl_hchar)?(i/gl_hchar+1):(i/gl_hchar);
	i = (box->g_y-ywork)/gl_hchar;
	for (; i < l; i++)	{
		if (j > i)	{
			pt = *(list+toptx+i);
			if (((lenth(pt)-leftx+1)*gl_wchar) >= box->g_x-xwork+box->g_w) 	{
				pt = pt + k/gl_wchar+leftx-1;
				y[0] = *pt;
				if (*pt) {
					y[1] = *(pt+1);
				}
				v_gtext(handle, xwork+k-gl_wchar, gl_hchar*i+ywork, &y[0]);
			}
		} else	{
			break;
		}
	}
	graf_mouse(M_ON, 0L);
}


lenth(pt)
char *pt;
{
	int i=0;

	while (*pt++)	{
		i++;
	}
	return i;
}

blitup(wh, box)
int wh;
GRECT *box;

{
	int i, j, done;
	GRECT rect;
	int pxyarray[8];
	int x[2];

	x[0] = 0;
	x[1] = 0;

	i = ((box->g_y-ywork+hwork-1)/gl_hchar)*gl_hchar;

	graf_mouse(M_OFF, 0L);
	pxyarray[0] = box->g_x;
	pxyarray[1] = box->g_y;
	pxyarray[2] = box->g_x+box->g_w;
	pxyarray[3] = ywork+i;
	pxyarray[4] = box->g_x;
	pxyarray[5] = box->g_y+gl_hchar;
	pxyarray[6] = box->g_x+box->g_w;
	pxyarray[7] = pxyarray[3]+gl_hchar;
	vro_cpyfm(handle, 3, pxyarray, &x[0], &x[0]);
	rect.g_x = box->g_x;
	rect.g_y = box->g_y;
	rect.g_w = box->g_w;
	rect.g_h = gl_hchar;
	clrbox(&rect);			/* clear this line */
	i = (box->g_y-ywork)/gl_hchar;
	j = (box->g_y-ywork)%gl_hchar;
	if (toptx+i < nrow)	{
		v_gtext(handle, xwork-(int)leftx*gl_wchar, i*gl_hchar+ywork, 
							*(list+toptx+i));
	}
	if ((j)&&(toptx+i+1 < nrow))	{
		v_gtext(handle, xwork-(int)leftx*gl_wchar, (i+1)*gl_hchar+ywork, 
							*(list+toptx+i+1));
	}
	graf_mouse(M_ON, 0L);
}

blit2up(msg, dbox)	

int msg;		/* window handle from msg[3] */
GRECT *dbox;	/* pointer to the redraw rectangle */

{  

	GRECT wdrct;	/* the current window rectangle in rect list */ 
	int done;
	/*
	hide_mouse();	
	*/
	wind_update(BEG_UPDATE);	/* lock screen */
	vsf_interior(handle, 1);	
	vsf_color(handle, 0);
	wind_get
		(msg, WF_FIRSTXYWH, &wdrct.g_x, &wdrct.g_y, &wdrct.g_w, &wdrct.g_h);
	while (wdrct.g_w && wdrct.g_h)	{	/* while it is not the last one */
		if (rc_intersect(dbox, &wdrct))	{ /*check see if this one is damaged*/ 
			setclip(&wdrct);
			blitup(msg, &wdrct);
		}
		wind_get
		  (msg, WF_NEXTXYWH, &wdrct.g_x, &wdrct.g_y, &wdrct.g_w, &wdrct.g_h);
	}
	wind_update(END_UPDATE);	/* unlock screen */
	/*
	show_mouse();
	*/

}


blit2dn(msg, dbox)	

int msg;		/* window handle from msg[3] */
GRECT *dbox;	/* pointer to the redraw rectangle */

{  

	GRECT wdrct;	/* the current window rectangle in rect list */ 
	int done;
	/*
	hide_mouse();
	*/
	wind_update(BEG_UPDATE);	/* lock screen */
	vsf_interior(handle, 1);	
	vsf_color(handle, 0);
	wind_get
		(msg, WF_FIRSTXYWH, &wdrct.g_x, &wdrct.g_y, &wdrct.g_w, &wdrct.g_h);
	while (wdrct.g_w && wdrct.g_h)	{	/* while it is not the last one */
		if (rc_intersect(dbox, &wdrct))	{ /*check see if this one is damaged*/ 
			setclip(&wdrct);
			blitdn(msg, &wdrct);
		}
		wind_get
		  (msg, WF_NEXTXYWH, &wdrct.g_x, &wdrct.g_y, &wdrct.g_w, &wdrct.g_h);
	}
	wind_update(END_UPDATE);	/* unlock screen */
	/*
	show_mouse();
	*/

}


/* redraw the window */
blitdn(wh, box)
int wh;
GRECT *box;

{
	int i, j, done;
	GRECT rect;
	int pxyarray[8];
	int x[2];


	x[0] = 0;
	x[1] = 0;
	graf_mouse(M_OFF, 0L);
	i = ((box->g_y-ywork+box->g_h-1)/gl_hchar)*gl_hchar;
	pxyarray[0] = box->g_x;
	pxyarray[1] = box->g_y+gl_hchar;
	pxyarray[2] = box->g_x+box->g_w;
	pxyarray[3] = ywork+i;
	pxyarray[4] = box->g_x;
	pxyarray[5] = box->g_y;
	pxyarray[6] = box->g_x+box->g_w;
	pxyarray[7] = pxyarray[3]-gl_hchar;
	vro_cpyfm(handle, 3, pxyarray, &x[0], &x[0]);
	j = (box->g_y-ywork+box->g_h-1)%gl_hchar;
	rect.g_x = box->g_x;
	rect.g_y = ywork+i-gl_hchar;
	rect.g_w = box->g_w;
	rect.g_h = (j)?(gl_hchar+box->g_y-ywork+box->g_h-i):(gl_hchar+1);
	clrbox(&rect);			/* clear this line */
	i = (box->g_y-ywork+box->g_h-1)/gl_hchar-1;
	if (toptx+i < nrow)	{
		v_gtext(handle,xwork-(int)leftx*gl_wchar,
						i*gl_hchar+ywork, *(list+toptx+i));
	}
	if ((j)&&(toptx+i+1 < nrow))	{
		v_gtext(handle, xwork-(int)leftx*gl_wchar, 
						(i+1)*gl_hchar+ywork, *(list+toptx+i+1));
	}
	graf_mouse(M_ON, 0L);
}


/* move the slider to match top text */

mvslide(wh, msg, resiz)
int wh;
int msg;		/* 4: do the horizontal slide; < 3, for vertical slide */
int resiz;		/* if resize the window, set for 1 */
{
	int cslide, nslide, flag1, flag2;
	long tmp1, tmp2;

	if (msg > 3)	{	/* do the horizontal move */
		flag1 = WF_HSLIDE;
		flag2 = WF_HSLSIZE;
		if (maxln <= wwork/gl_wchar)	{
			tmp1 = 1000;
			tmp2 = 1000;
		} else {
			tmp1 = 1000*leftx/(maxln-wwork/gl_wchar);
			tmp2 = 1000*(wwork/gl_wchar)/maxln;
		}
	} else {			/* do the vertical move */
		flag1 = WF_VSLIDE;
		flag2 = WF_VSLSIZE;
		if (nrow <= hwork/gl_hchar)	{
			tmp1 = 1000;
			tmp2 = 1000;
		} else {
			tmp1 = 1000*toptx/(nrow-hwork/gl_hchar);
			tmp2 = 1000*(hwork/gl_hchar)/nrow;
		}
	}
	wind_get(wh, flag1, &cslide, &nslide, &nslide, &nslide);
	if ((nslide=tmp1) != cslide)	{
		wind_set(wh, flag1, nslide, 0, 0, 0);
	}
	if (resiz)	{
		wind_get(wh, flag2, &cslide, &nslide, &nslide, &nslide);
		if ((nslide=tmp2) != cslide)	{
			wind_set(wh, flag2, nslide, 0, 0, 0);
		}
	}
}


/* set clip to specified rectangle */
setclip(p)	
GRECT *p;

{
	int ptr[4];

	grect_conv(p, ptr);
	vs_clip(handle, 1, ptr);
}

clrbox(r)
GRECT *r;

{
	int p[4];

    hide_mouse();
	grect_conv(r, &p);
    vsf_interior(handle, 1);
    vsf_color(handle, 0);
    v_bar(handle, &p);
    show_mouse();
}

grect_conv(r, ar)
GRECT *r;
int *ar;
{
	*ar++ = r->g_x;
	*ar++ = r->g_y;
	*ar++ = r->g_x + r->g_w - 1;
	*ar   = r->g_y + r->g_h - 1;
}


binary(buf)
char *buf;
{
	int i;
	if (!fsiz)	return 0;	/* if file size is 0, return 0 */
	for (i=0; i < 150; i++)	{
		if (*buf++ == 0x0D)	{	/* it is a carriage return */
			if (*buf++ == 0x0A)	{ /* it is line feed */
				return 0;/* it is not a binary file for have carriage return */
			}
		}
	} 
	return 1;			/* it is a binary file */
}


long findrow(buf, size)
char *buf;
long size;
{
	long n=0;

	while (size > 0)	{
		while (*buf != 0x0D)	{
			buf++;
			size--;
			if (!size)	{
				n++;
				return (n);
			}
		}
		n++;
		buf += 2;
		size -= 2;
	}
	return (n);
}

bin2str(list, sbuf, dbuf)
long *list;
char *sbuf;
char *dbuf;
{

	long *tmp;
	char *sptr, *dptr, *ptr;
	int i;
	long count;
	char bit, hbit, lbit;


	if (!fsiz) 	/* if the file size is 0, return 0 */
		return count;
	sptr = sbuf;
	dptr = dbuf;
	count = fsiz;
	maxln = 67;
	tmp = list;
	*tmp++ = dbuf;
	while (fsiz > 0L)	{
		ptr = sptr;
		*dptr++ = 0x20;
		for (i=0; i < 8; i++)	{
			/* conver it to hex */
			bit = *sptr++;
			if (fsiz-- < 1L)	{
				bit = 0x00;
			}
			lbit = bit & 0x000F;
			hbit = (bit>>4) & 0x000F;
			*dptr++ = myitoa(hbit);
			*dptr++ = myitoa(lbit);
			bit = *sptr++;
			if (fsiz-- < 1L)	{
				bit = 0x00;
			}
			lbit = bit & 0x000F;
			hbit = (bit>>4) & 0x000F;
			*dptr++ = myitoa(hbit);
			*dptr++ = myitoa(lbit);
			if (i == 3)	{
				*dptr++ = 0x20;
			}
			*dptr++ = 0x20;
		}
		/* conver it to the printable in the right side */
		*dptr++ = 0x20;		/* space */
		*dptr++ = 0x20;	
		*dptr++ = 0x20;	
		*dptr++ = 0x20;	
		*dptr++ = 0x7C;		/* vertical bar */
		*dptr++ = 0x20;	
		for (i=0; i < 16; i++)	{
			bit = *ptr++;
			if (count-- < 1)	{
				bit = 0x00;
			}
			if ((bit >= 0x00) && (bit < 0x20))	{
				/* for non printable character, print it as a period */
				*dptr++ = 0x2E;		
			} else {
				*dptr++ = bit; /* print whatever they are */
			}
		}
		*dptr++ = 0x20;
		*dptr++ = 0x7C;
		*dptr++ = 0x00;
		*tmp++ = dptr;
	}
	return OK;
}

myitoa(bit)
char bit;

{

	char i;

	switch(bit)	{
		case 0x00:
			i = 0x30;
			break;
		case 0x01:
			i = 0x31;
			break;
		case 0x02:
			i = 0x32;
			break;
		case 0x03:
			i = 0x33;
			break;
		case 0x04:
			i = 0x34;
			break;
		case 0x05:
			i = 0x35;
			break;
		case 0x06:
			i = 0x36;
			break;
		case 0x07:
			i = 0x37;
			break;
		case 0x08:
			i = 0x38;
			break;
		case 0x09:
			i = 0x39;
			break;
		case 0x0A:
			i = 0x41;
			break;
		case 0x0B:
			i = 0x42;
			break;
		case 0x0C:
			i = 0x43;
			break;
		case 0x0D:
			i = 0x44;
			break;
		case 0x0E:
			i = 0x45;
			break;
		case 0x0F:
			i = 0x46;
			break;

		defual:
			break;
	}
	return i;
}


long gdbufsiz(sbuf, size)
char *sbuf;
long size;
{

	long count=0;
	char *sptr;
	int i=0, j=0;


	sptr = sbuf;
	if (*sptr == 0x0D)	{ /* the first line is the blank line */
		count++;
		count++;
		sptr += 2;
		size -= 2;
	} 
	while (size > 0)	{
		count++; 	/* a space for the beginning of the line */
		while ((*sptr != 0x09) && (*sptr != 0x0D))	{
			i++;
			sptr++;
			size--;
			count++;
			if (!size)	{	/* end of file */
				return count;
			}
		}
		switch(*sptr)	{
			case 0x09:		/* it is a tab char */
				sptr++;
				size--;
				j = 4 - i%4;	/* calculate how many space should be */
				i += j;
				switch(j)	{
					case 4:			/* four spaces for the tab */
						count += 4;
						break;
					case 3:			/* three spaces for the tab */

						count += 3;
						break;
					case 2:
						count += 2;
						break;
					case 1:
						count++;
						break;
					default:
						break;
				}
				break;
			case 0x0D:		/* it is a carriage return char */
				sptr++;
				size--;
				count++;
				sptr++;
				size--;
				break;
			default:
				break;
		}
		i = 0;
	}
	return count;
}


asci2str(list, sbuf, dbuf, size)
long *list;
char *sbuf;
char *dbuf;
long size;
{

	long *tmp;
	char *sptr, *dptr;
	int i=0, j=0;
	int width=0;


	maxln = 0;
	if (!fsiz) return OK;
	tmp = list;
	*tmp++ = dbuf;
	sptr = sbuf;
	dptr = dbuf;
	if (*sptr == 0x0D)	{ /* the first line is the blank line */
		*dptr++ = 0x20;
		*dptr++ = 0x00;
		sptr += 2;
		*tmp++ = dptr;
		size -= 2;
	} 
	while (size > 0)	{
		*dptr++ = 0x20;			/* a space for the beginning of the line */
		i++;
		while ((*sptr != 0x09) && ((*dptr++ = *sptr) != 0x0D))	{
			i++;
			sptr++;
			size--;
			if (!size)	{	/* end of file */
				*dptr = 0x00;
				*tmp++ = dptr;
				return OK;
			}
		}
		switch(*sptr)	{
			case 0x09:		/* it is a tab char */
				sptr++;
				size--;
				j = 4 - i%4;	/* calculate how many space should be */
				i += j;
				switch(j)	{
					case 4:			/* four spaces for the tab */
						*dptr++ = 0x20;
						*dptr++ = 0x20;
						*dptr++ = 0x20;
						*dptr++ = 0x20;
						break;
					case 3:			/* three spaces for the tab */
						*dptr++ = 0x20;
						*dptr++ = 0x20;
						*dptr++ = 0x20;
						break;
					case 2:
						*dptr++ = 0x20;
						*dptr++ = 0x20;
						break;
					case 1:
						*dptr++ = 0x20;
						break;
					default:
						break;
				}
				width += i;	/* the width the line */
				break;
			case 0x0D:		/* it is a carriage return char */
				sptr++;
				size--;
				if (*(sptr-2) == 0x0A) {/* it is a blank line */
					*(dptr-1) = 0x20;
					*dptr++ = 0x00;
				} else {
					*(dptr-1) = 0x00;
				}
				*tmp++ = dptr;
				sptr++;
				size--;
				width += i;
				maxln = MAX(maxln, width);
				width = 0;
				break;
			default:
				break;
		}
		i = 0;
	}
	maxln += 1;		/* for the space of each begining line */
}

/*
 * Get a single event, process it, and return.
 *
 */
domulti(){

    int event, rut;
	int skip = 0;
	long tmp;
	GRECT box;
	int prvw, prvh;

	box.g_x = xwork;
	box.g_y = ywork;
	box.g_h = hwork;
	box.g_w = wwork;
    
    event = evnt_multi(MU_MESAG|MU_KEYBD, 1,1,butdown, 0,0,0,0,0, 0,0,0,0,0,
						msg,0,0,&mx,&my,&ret,&ret,&keycode,&ret);

	if (event & MU_KEYBD)	{	/* keyboard was hit */
		switch(keycode)		{
			case 0x6200:	{	/* help key */
					/* 0: show the new file in the old window */
				selagn:
					if (select(skip) == EXIT)	{
						running = 0;
					} else {
						/*
						Mfree(dbuff);
						Mfree(list);
						*/
						openyes = 1;
						if ((rut=doopenwd(0, argv[fno])) == OK)	{
							skip = 1;
							goto selagn;
						} else if (rut == ERROR)	{			/* get out */
							running = 0;
						} /* keep go on */
					}
				}
				break;

			case 0x4D00: msg[4] = 7;
						 goto tort;		/* right-arrow key */

			case 0x4B00: msg[4] = 6;
						 goto tolf;		/* left-arrow key */

			case 0x4800: msg[4] = 2;
						 goto toup;		/* up-arrow key */

			case 0x5000: msg[4] = 3;
						 goto todn;		/* down-arrow key */

			defualt: break;
		} 
	} else  if (event & MU_MESAG) {
    	wind_update(TRUE);
	switch (msg[0]) {
		case  WM_REDRAW:		/* do the redraw by call redraw routine */
			if (!openyes)	{
				box.g_x = msg[4];
				box.g_y = msg[5];
				box.g_w = msg[6];
				box.g_h = msg[7];
			} else {
				openyes = 0;
			}
			/*
			printf("%d %d %d %d\n", box.g_x, box.g_y, box.g_w, box.g_h);
			*/
			Redraw(msg[3], &box);
			break;

		case  WM_TOPPED:		/* if topped, send to top */
			wind_set(msg[3], WF_TOP, 0, 0, 0, 0);
    		wind_get(msg[3], WF_WORKXYWH, &xwork, &ywork, &wwork, &hwork);
			break;

		case  WM_SIZED:			/* if sized, check for min size, then resize */
			msg[6] = MAX(msg[6], gl_wchar*8);
			msg[7] = MAX(msg[7], gl_hchar*4);
			wind_set(msg[3], WF_CURRXYWH, msg[4], msg[5], msg[6], msg[7]);
    		wind_get(msg[3], WF_WORKXYWH, &xwork, &ywork, &wwork, &hwork);
			if (maxln <= wwork/gl_wchar)	{
				leftx = 0;
			}
			if (nrow <= hwork/gl_hchar)	{
				toptx = 0;
			}
			mvslide(msg[3], 3, 1);	
			mvslide(msg[3], 4, 1);
			break;

		case  WM_MOVED:			/* if moved, make sure the window stays on the
								   desktop */
			wind_set(msg[3], WF_CURRXYWH, msg[4], msg[5], msg[6], msg[7]);
    		wind_get(msg[3], WF_WORKXYWH, &xwork, &ywork, &wwork, &hwork);
			break;

		case  WM_FULLED:		/* if fulled, do toggle routine */
			toggle(msg[3]);
			break;

		case  WM_CLOSED:		/* if closed, set flag */
			wind_close(msg[3]);
			running = 0;
			break;

		case  WM_VSLID:			/* slide bar was dragged */
			if (nrow < hwork/gl_hchar)	{
				break;
			}
			tmp = msg[4] * (nrow-hwork/gl_hchar) / 1000;	/* calc toptx */
			if (toptx == tmp)	{	/* don't move */
				break;
			}
			toptx = tmp;
			Redraw(msg[3], &box);	
			mvslide(msg[3], 0, 0);
			break;

		case  WM_HSLID:			/* slide bar was dragged */
			if (wwork <= maxln*gl_wchar)		{
				tmp = msg[4] * (maxln-wwork/gl_wchar) / 1000; 
				if (leftx == tmp)	{ /* don't move */
					break;
				}
				leftx = tmp;
				Redraw(msg[3], &box);
				mvslide(msg[3], 4, 0);
			}
			break;

		case  WM_ARROWED:
			switch (msg[4])	{
				case 0:	/* page up */
					if (toptx)	{
						tmp = MAX(0, toptx-hwork/gl_hchar);
						if (toptx == tmp)	{ /* don't move */
							break;
						}
						toptx = tmp;
						Redraw(msg[3], &box);	 
						mvslide(msg[3], msg[4], 0);
					}
					break;

				case 1:	/* page down */
 					tmp = MIN(nrow-hwork/gl_hchar, 
											toptx+hwork/gl_hchar);
					if (toptx == tmp)	{
						break;
					} else if (nrow < hwork/gl_hchar)	{
						;
					} else if (tmp < nrow)	{
						toptx = tmp;
						Redraw(msg[3], &box);
						mvslide(msg[3], msg[4], 0);
					} 
					break;

				case 2:	/* row up */
				toup:
					if (toptx)	{
						toptx = MAX(0, toptx-1);
						blit2up(msg[3], &box);
						mvslide(msg[3], msg[4], 0);
					}
					break;

				case 3:	/* row down */
				todn:
					if ((nrow-toptx) > hwork/gl_hchar)	{
						toptx = MIN(nrow-hwork/gl_hchar, toptx+1);
						blit2dn(msg[3], &box);
						mvslide(msg[3], msg[4], 0);
					}
					break;

				case 4:	/* page left */
					if (wwork <= maxln*gl_wchar)		{
						tmp = MAX(0, leftx-wwork/gl_wchar);
						if (leftx == tmp)	{	/* don't move */
							break;
						}
						leftx = tmp;
						Redraw(msg[3], &box);
						mvslide(msg[3], msg[4], 0);
					}
					break;

				case 5:	/* page right */
					if (wwork <= maxln*gl_wchar)		{
 						tmp = MIN(maxln-wwork/gl_wchar, 
											leftx+wwork/gl_wchar);
						if (leftx == tmp)	{	/* don't move */
							break;
						}
						leftx = tmp;
						Redraw(msg[3], &box);	 
						mvslide(msg[3], msg[4], 0);
					}
					break;

				case 6:	/* column left */
				tolf:
					if (leftx)	{
						leftx = MAX(0, leftx-1);
						blit2lf(msg[3], &box);
						mvslide(msg[3], msg[4], 0);
					}
					break;

				case 7:	/* column right */
				tort:
					if ((maxln-leftx)*gl_wchar > wwork)		{
						leftx = MIN(gl_wchar+maxln-wwork/gl_wchar, leftx+1);
						blit2rt(msg[3], &box);
						mvslide(msg[3], msg[4], 0);
					}
					break;

				default:
					break;
			}
			break;

	    case WM_NEWTOP:
			wind_set(wi_handle, WF_TOP, 0, 0, 0, 0);
			break;


	    default:
		break;
	}
	wind_update(FALSE);
    }
}


/*
 * Open virtual workstation.
 *
 */
open_vwork()
{
    int i;

    for (i = 0; i < 10;)	{
		work_in[i++] = 1;
	}
    work_in[10] = 2;
	handle = phys_handle;
    v_opnvwk(work_in, &handle, work_out);
	return(handle);
}



/*
 * Hide the mouse.
 *
 */
hide_mouse()
{
    if (!hidden) {
	graf_mouse(M_OFF, 0L);
	hidden = TRUE;
    }
}


/*
 * Show the mouse.
 *
 */
show_mouse() 
{
    if (hidden) {
	graf_mouse(M_ON, 0L);
	hidden = FALSE;
    }
}


/*
 *  Display a dialogue box on the screen.
 *	Input:
 *		tree - object tree for dialogue box to be displayed.
 *	Output:
 *		formw, formh, sx, sy, lx, ly - dimensions of box.
 */
dsplymsg(tree)
OBJECT *tree;
{
    form_center(tree,&lx, &ly, &formw, &formh);

    form_dial(1, 0, 0, 0, 0, lx, ly, formw, formh);
    objc_draw(tree, 0, 3, lx, ly, formw, formh);
}


/*
 *  Erase a dialogue box from the screen.
 *	Input:
 *		formw, formh, sx, sy, lx, ly - dimensions of box.
 */
erasemsg()
{
    form_dial(3, 0, 0, 0, 0, lx, ly, formw, formh);
}



/*
 * getargs: interpret either MWC args or command-line args (if no MWC).
 *
 * USAGE:
 *	main(argc,argv)
 *	int argc;
 *	char *argv[];
 *	{
 *		getargs(&argc,&argv);
 *		... now process the args and run the program ...
 *	}
 *
 * Allows a max of NARGV arguments: normally 128 is sufficient.
 *
 * Call with *(&argc) != 0 if somebody has already parsed the command-
 * line arguments for you; in that case, if there aren't any
 * args in the environment, this procedure just returns
 * because the previous parser has already done its best. 
 *
 * Requires getenv().
 *
 * Clobbers the environment so children started from here will not
 * see ARGV= in their env (unless it's put there later).  This also
 * means you can't call getargs twice...
 *
 * Interprets the environment string like MWC does.
 *
 * Does not validate the ARGV string.  This is a bug.  The convention
 * which has developed means that all programs which launch children
 * must use the ARGV convention, or none may, because if one which does
 * use it launches one which doesn't, which launches one which does,
 * then the last one will see the middle one's ARGV.
 */


getargs(p_argc,p_argv)
int *p_argc;
char ***p_argv;
{
    extern char *_base;
    char *getenv();
    register char *eptr;
    register int count = 0;
    char hold;

    if (eptr = getenv("ARGV")) {
	eptr += strlen(eptr) + 1;
	while (count < NARGV-1 && *eptr) {
	    argv[count++] = eptr;
	    eptr += strlen(eptr) + 1;
	}

	/* clobber "ARGV=" so environment ends there,	*/
	/* so children won't see these args in the env.	*/

	eptr = getenv("ARGV");
	while (*(--eptr) != 'A') ;
	*eptr = 0;
    }
    else {
	/* if we've already got args, don't do anything! */
    	if (*p_argc != 0) return *p_argc;
	count = *(_base+0x80);
	*(_base+0x81+count) = 0;
	strcpy(argcopy,_base+0x81);
	eptr = argcopy;
	argv[0] = "runtime";
	count = 1;
	while (1) {
	    while (*eptr == ' ') eptr++;	/* skip leading spaces */
	    if (!*eptr) break;			/* if end, quit */
	    argv[count++] = eptr;		/* not end: next arg */
	    while (*eptr && *eptr != ' ') eptr++;   /* skip nonwhite */
	    hold = *eptr;			/* save old value */
	    *eptr = 0;				/* null terminate */
	    if (!hold) break;			/* if old was null, end */
	    else eptr++;			/* else increment & loop */
	}
    }
    argv[count] = eptr;
    *p_argv = &argv[0];
    *p_argc = count;
    return count;
}


/*
 * getenv: get the value of an environment string parameter
 */

char *getenv(s)
char *s;
{
    extern long *_base;	    /* set by gemstart */
    char *p;
    char *start;
    int temp;

    p = _base[11];
    while (*p) {
	for (start=p ; *p && *p != '='; p++);
	if (*p) {
	    *p = '\0';
	    temp = strcmp(start,s);
	    *p = '=';
	    if (temp == 0) {
		return ++p;
	    }
	    while (*p) p++;	/* no match; skip to next */
	}
	p++;
    }
    return 0L;
}


/*
 * Select the file that will be show.
 */

select(skip)
int skip;

{


	wind_update(BEG_UPDATE);	 /* lock screen */
    for (;;)
    {
	switch (doscrbar(skip))
		{
			case OKDO:  wind_update(END_UPDATE);	/* unlock screen */
						return OK;
			case EXIT:  erasemsg();		/* erase the select dialog box */
						wind_update(END_UPDATE);	/* unlock screen */
						return EXIT;
			default:	break;
		}
    }
}


doscrbar(skip)
int skip;

{

    int but;
    int xrun = 1;
	long mystrcp();

	showasc = 1;	/* default for showing the binary file */

	scrpnl[OKDO].ob_state = NORMAL;
	
	if (!skip)	{
		showstd = 0;
		/* set form for first display */
   		totalpart(tolfile, tolstr);
		scrpnl[TOLFILE].ob_spec = tolstr;
		scrpnl[TOLFILE].ob_state = NORMAL;

		scrpnl[FILESTR].ob_spec = mystrcp(ckupper(argv[fno]));
		scrpnl[FILESTR].ob_state = NORMAL;

		scrpnl[SCRUP].ob_state = NORMAL;
		scrpnl[SCRDN].ob_state = NORMAL;
		scrpnl[SCRLF].ob_state = NORMAL;
		scrpnl[SCRRT].ob_state = NORMAL;

		if (showlen <= 21)  {/* the show box only show 21 char */
			scrpnl[SCRLF].ob_state = DISABLED;
			scrpnl[SCRRT].ob_state = DISABLED;
		}
		scrpnl[EXIT].ob_state = NORMAL;

    	ARROW_MOUSE;
    	dsplymsg(scrpnl);
	} else {
    	objc_draw(scrpnl, OKDO, 3, lx, ly, formw, formh);
	}

    /*
     * Edit the thing;
     * canonical event-driven switch().
     */
    while (xrun) 	{
		switch ((but = form_do(scrpnl, -1)))
    		{
				case EXIT:	xrun = 0;			/* return */
							break;
				case OKDO:  if (isdir(argv[fno]))	{  /* it is a dir */
								/* can't show the directory */
								form_alert(1, cnsdir);
								scrpnl[OKDO].ob_state = NORMAL;
    							objc_draw(scrpnl, OKDO, 3, lx,ly, formw,formh);
							} else {
								xrun = 0;
							}
							break;
				case SCRUP:	sepadj(-1, scrpnl);	break;
				case SCRDN:	sepadj(1, scrpnl);	break;
				case SCRLF:	sepsft(-1, scrpnl);	break;
				case SCRRT:	sepsft(1, scrpnl);	break;
				default:	break;
  			}
  	}
	if (scrpnl[BINARYB].ob_state & SELECTED)	{
		showasc = 0;
	}
    return but;
}


long mystrcp(str)
char *str;
{

	int i;

	if ((showlen=strlen(str)) <= 21)	{
		i=showlen-showstd;
		strcpy(&showfn[1], str);
	} else {
		if ((i=showlen-showstd) >= 21)	{
			strncpy(&showfn[1], str+showstd, 21);
		} else {
			strcpy(&showfn[1], str+showstd);
		}
	}
	if (showstd)	{
		showfn[0] = 0xAE;
	} else 	{
		showfn[0] = 0x20;
	} 
	if (i > 21)	{
		showfn[22] = 0xAF;
	} else {
		showfn[22] = 0x20;
		if (showlen < 21)	{
			showfn[showlen+1] = 0x20;
			showfn[showlen+2] = 0;
		}
	}
	showfn[23] = 0;
	return(&showfn[0]);
}




sepsft(sftdir, pnl)
int sftdir;
OBJECT *pnl;
{
	long mystrcp();

	if (sftdir > 0)	{
		if (showlen-showstd > 21)	{
			showstd++;
			pnl[FILESTR].ob_spec = mystrcp(argv[fno]);
			pnl[FILESTR].ob_state = NORMAL;
    		objc_draw(pnl, FILESTR, 3, lx, ly, formw, formh);
		}
	} else {
		if (showstd)	{
			showstd--;
			pnl[FILESTR].ob_spec = mystrcp(argv[fno]);
			pnl[FILESTR].ob_state = NORMAL;
    		objc_draw(pnl, FILESTR, 3, lx, ly, formw, formh);
		}
	}
}

/*
 * Adjust partition `pno' size by `amt';
 * if `pno' is -1, just recompute and update disk space left indicator.
 *
 * A partition of size zero is disabled.
 */



sepadj(amt, pnl)
int amt;
OBJECT *pnl;

{
		long mystrcp();

		if (amt > 0)	{
			if (fno+1 > tolfile)	{
				return OK;
			} else	{
				fno++;
				showstd = 0;
			}
		} else {
			if (fno-1 < 1)	{
				return OK;
			} else {
				fno--;
				showstd = 0;
			}
		}

		pnl[FILESTR].ob_spec = mystrcp(ckupper(argv[fno]));
		pnl[FILESTR].ob_state = NORMAL;
		if (showlen <= 21)  {/* the show box only show 21 char */
			pnl[SCRLF].ob_state = DISABLED;
			pnl[SCRRT].ob_state = DISABLED;
		} else {
			pnl[SCRLF].ob_state = NORMAL;
			pnl[SCRRT].ob_state = NORMAL;
		}
    	objc_draw(pnl, SCRLF, 3, lx, ly, formw, formh);
    	objc_draw(pnl, SCRRT, 3, lx, ly, formw, formh);
    	objc_draw(pnl, FILESTR, 3, lx, ly, formw, formh);

		return OK;
}

/*
 * find out the total partitions
 */

totalpart(num, str)

int num;
char *str;

{
	int  i=0, j=0;
	char tem[10];

	/* conver the integer to ASCII */
	do	{	/* generate digits in reverse order */
		tem[i++] = num % 10 + '0';	/* get next digits */
	} while ((num /= 10) > 0);		/* delete it */

	for (; i > 0; )	{ /* reverse string 'str' in place */
		*str++ = tem[--i];
		j++;
	}
	for (; j < 5; j++)	
		*str++ = ' ';
   	*str = '\0';
}

