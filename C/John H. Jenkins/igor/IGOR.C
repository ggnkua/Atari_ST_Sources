/*********************************************************************/
/* Igor universal help file desk accessory  			     */
/*	   by John H. Jenkins					     */
/*								     */
/* Brought to you by START:  The ST Quarterly			     */
/*								     */
/* Copyright ½ 1988 by Antic Publishing, Inc.			     */
/*								     */
/* Based on the SAMPLE ACCESSORY SKELETON included with the Megamax  */
/*     C compiler, started 5/28/85 R.Z.  Copyright ATARI Corp. 1985  */
/*********************************************************************/

/*********************************************************************/
/* INCLUDE FILES				                     */
/*********************************************************************/

#include <obdefs.h>
#include <gemdefs.h>
#include <osbind.h>
#include <string.h>
#include <stdio.h>
#include <ctype.h>
#include "igor.h"

/*********************************************************************/
/* DEFINES											    */
/*********************************************************************/

/* The tautological definitions of TRUE and FALSE used here have the	 */
/*	advantage of forcing the compiler to use whatever non-zero number */
/*	it is most comfortable with for FALSE, rather than assuming it is */
/*	1 or -1.												 */

#define TRUE		(0 == 0)
#define FALSE		(1 == 0)
#define WI_KIND	(SIZER|INFO|MOVER|FULLER|CLOSER|NAME|UPARROW|DNARROW|VSLIDE|LFARROW|RTARROW|HSLIDE)

#define NO_WINDOW (-1)

#define DEF_SIZE	32768L

/* default size for the block of memory Igor uses for help files */

#define MIN_WIDTH  (2*gl_wbox)
#define MIN_HEIGHT (3*gl_hbox)

/* The minimum size for our window */

/* My code is a modification of the desk accessory skeleton provided by	*/
/*	   Megamax.  By #defining ACCESSORY, the code to make a desk		*/
/*	   is generated; if ACCESSORY is not #defined, then the code to		*/
/*	   make a stand-alone program is generated.	This makes debugging	*/
/*	   easier.												*/

#define ACCESSORY 

/*********************************************************************/
/* EXTERNALS											    */
/*********************************************************************/

extern int	 gl_apid; 		/* we're a desk accessory, so we'll */
							/* need this					 */

/*********************************************************************/
/* GLOBAL VARIABLES 									    */
/*********************************************************************/

int	   gl_hchar;
int	   gl_wchar;
int	   gl_wbox;
int	   gl_hbox;	    /* system sizes */

int	   menu_id ;	    /* our menu id */

int	   phys_handle;    /* physical workstation handle */
int	   handle;	    /* virtual workstation handle */
int	   wi_handle;	    /* window handle */
int	   top_window;     /* handle of topped window */

int	   xdesk,ydesk,hdesk,wdesk;
int	   xold,yold,hold,wold;
int	   xcurr,ycurr,hcurr,wcurr;
int	   xwork,ywork,hwork,wwork;		/* desktop and work areas */

int	   msgbuff[8];     /* event message buffer */
int	   keycode;	    /* keycode returned by event-keyboard */
int	   mx,my; 	    /* mouse x and y pos. */
int	   butdown;	    /* button state tested for, UP/DOWN */
int	   ret;		    /* dummy return variable */

int	   hidden;	    /* current state of cursor */

int	   fulled;	    /* current state of window */

int	   contrl[12];
int	   intin[128];
int	   ptsin[128];
int	   intout[128];
int	   ptsout[128];    /* storage wasted for idiotic bindings */

int work_in[11];	    /* Input to GSX parameter array */
int work_out[57];	    /* Output from GSX parameter array */
int pxyarray[10];	    /* input point array */

int pchar_w, pchar_h, pcell_w, pcell_h;

/****************************************************************/
/*	 Application-specific defines and variables			    */
/***************************************************************/

#define max(a,b)		((a > b) ? a : b)
#define min(a,b)		((a < b) ? a : b)
#define max4(a,b,c,d)	max(max(a,b),max(c,d))
#define min4(a,b,c,d)	min(min(a,b),min(c,d))

int can_search;		/* can we perform searches? */
					/* since we use a dialog box to get the string */
					/* to search for, this is the same as "was */
					/* the resource file loaded? */

int GDOS_inst, use_GDOS; 	/* is GDOS available and should it be used? */
int been_warned;			/* have we told the user we're running out */
						/* of memory? */

int def_point; 			/* default text size */

int up_low = TRUE;			/* do we distinguish cases in a search?  */

char search_buff [128];		/* place to hold the last search string */

#define TOPICS  0
#define LINES	 1		/* are we in TOPICS or LINES mode? */
					/* i.e., displaying the list of topics or */
					/* a single topic, respectively */

#define LINE_LENGTH     64		/* maximum length of a line */

/* what each chunk of text looks like */

typedef struct chunk_type {
		struct chunk_type	*next_chunk;
		int				efft, font, colr, size, len;
		char 			*text;
		} CHUNK_TYPE, *CHUNK_PTR;
		
/* next_chunk points to the next chunk of text in the line		*/
/* eff, fnt, clr and siz govern the various VDI text effects:	*/
/*		eff		text effects							*/
/*		fnt		font (only used if GDOS is present and used) */
/*		clr		color								*/
/*		siz		size 								*/
/* len is the length of the chunk in pixels					*/
/* *text is where the text of the chunk is saved				*/

/* each line is split up into "chunks"--a chunk is a block of	*/
/* text with the same VDI text effect information 			*/
/* This way, we need only figure out where to make these changes */
/* once.												*/

/* what each line of text within a topic looks like */

typedef struct line_type {
	   struct line_type 	  *next_l, *last_l;
	   int				  line_no, v, tot_w;
	   CHUNK_PTR			  first_chunk;
	   } LINE_TYPE, *LINE_PTR;

/* next_l and last_l point to the next and previous lines in the 	*/
/*	topic, line_no holds the number of the line within the topic,	*/
/*	and first_chunk points to the beginning of the list of chunks	*/
/*	where the text of the line is stored						*/
/*	v is the height in pixels, tot_w the total length 			*/

/* What a topic looks like */

typedef struct topic_type {
	   struct topic_type	  *next, *last;
	   int				  topic_no, top_line, top_col, no_lines,
						  v_pos, v_size, h_pos, h_size, v, max_w,
						  tot_h;
	   CHUNK_PTR			  first_chunk;
	   LINE_PTR			  first_line;
	   } 	    TOPIC_TYPE, *TOPIC_PTR;

/* next and last are the next and previous topics in the doubly- 	 */
/*	linked list of topics; topic_no is the number of the topic within */
/*	the list; top_line is the number of the line that appears at the  */
/*	top of the window; top_col is the number of the leftmost	   */
/*	column in the window; no_lines is the total number of lines in	 */
/*	the topic, and the other int's are used as variables for the	 */
/*	position and size of the two slider bars.  first_chunk is a 	 */
/*	pointer to the chunk list storing the the topic's name.		 */
/*	max_w is the maximum width (in pixels) of a line in the topic	 */
/*	tot_h is the total height of all the lines in the topic		 */
/*	first_line is a pointer to the first line in the doubly-linked	 */
/*	list of lines within the topic.							 */

#define NUM_LASTS	    4	/* number of topics maintained in a list */

TOPIC_PTR 	 first_topic, cur_top, last_topics[NUM_LASTS];

/* first_topic is the first topic in the list of topics, cur_top is
	the one we're currently looking at, and last_topics is an array
	holding the last NUM_LAST topics visited, including the current
	one, to make revisiting them easier */

int			 mode = TOPICS, ttop_line=0, ttop_col=0, no_topics=0,
			 tv_pos=1, tv_size=1000, th_pos=1, th_size=1000,
			 max_top_w, tot_top_h;

/* mode is the current mode, TOPICS (showing the list of topics) or	*/
/*	LINES (showing the lines in a topic).  The other variables are	*/
/*	analogous to variables within the TOPIC_TYPE structure and have	*/
/*	to do with the display and slider bars. 					*/

/* max_top_w is the longest width (in pixels) of a topic name */
/* tot_top_h is the total height (in pixels) of the topic names */

char 		 *button_line, lines_info [192], topics_info[192],
			global_path[192];

/* button_line points to the line which is just below the info line */
/*	in the window.  There are two forms for this:  lines_info if   */
/*	mode == LINES and topics_info if mode == TOPICS.	global_path  */
/*	holds the path name for loading help files from disk.		   */

/* a few handy #define's to save typing later on			  */

#define NEW_CHUNK_PTR	((CHUNK_PTR) my_malloc((long) sizeof(CHUNK_TYPE)))
#define NEW_LINE_PTR	((LINE_PTR) my_malloc((long) sizeof(LINE_TYPE)))
#define NEW_TOPIC_PTR	((TOPIC_PTR) my_malloc((long) sizeof(TOPIC_TYPE)))

char *mem_ptr;
long mem_size, mem_pos = 0L;
char *my_malloc();

/* To avoid running into problems with applications, we are allocated all */
/* our memory by the operating system at boot time; these variables then */
/* allow us to dole it out as necessary to any given help file */

/* Since help files are all or nothing kinds of beasts, we don't have to */
/* do anything fancy in our own memory allocation routine */ 


/****************************************************************/
/*  GSX UTILITY ROUTINES.							    */
/****************************************************************/

hide_mouse()
{
	   if(! hidden){
			 graf_mouse(M_OFF,0x0L);
			 hidden=TRUE;
	   }
}

show_mouse()
{
	   if(hidden){
			 graf_mouse(M_ON,0x0L);
			 hidden=FALSE;
	   }
}

/****************************************************************/
/* open virtual workstation							    */
/****************************************************************/
open_vwork()
{
	int i;

	work_in[0] = (int) Getrez() + 2;
	for(i=1;i<10;work_in[i++]=1);
	work_in[10]=2;
	handle=phys_handle;
	v_opnvwk(work_in,&handle,work_out);
#ifdef ACCESSORY
	if (use_GDOS)
#else	   
	if (GDOS_inst) 	/* the application hasn't loaded IGOR.DAT yet */
#endif ACCESSORY
		  vst_load_fonts (handle, 0);
	   
}

/****************************************************************/
/* set clipping rectangle							    */
/****************************************************************/
set_clip(x,y,w,h)
int x,y,w,h;
{
int clip[4];
	   clip[0]=x;
	   clip[1]=y;
	   clip[2]=x+w-1;
	   clip[3]=y+h-1;
	   vs_clip(handle,1,clip);
}

/****************************************************************/
/* open window 									    */
/****************************************************************/
open_window()
{
	   wi_handle = wind_create (WI_KIND, xdesk, ydesk, wdesk, hdesk);
	   wind_set (wi_handle, WF_NAME, " Igor ", 0, 0);
	   wind_set (wi_handle, WF_INFO, " Copyright \275 1988 by Antic Publishing, Inc.", 0, 0);
	   graf_growbox(0,0,gl_wbox,gl_hbox,xcurr,ycurr,wcurr,hcurr);
	   if (mode == TOPICS) {
		   button_line = topics_info;
		   wind_set (wi_handle, WF_HSLIDE, th_pos, 0, 0, 0);
		   wind_set (wi_handle, WF_VSLIDE, tv_pos, 0, 0, 0);
		   wind_set (wi_handle, WF_HSLSIZE, th_size, 0, 0, 0);
		   wind_set (wi_handle, WF_VSLSIZE, tv_size, 0, 0, 0);
		   }
	   else {
		   button_line = lines_info;
		   wind_set (wi_handle, WF_HSLIDE, cur_top->h_pos, 0, 0, 0);
		   wind_set (wi_handle, WF_VSLIDE, cur_top->v_pos, 0, 0, 0);
		   wind_set (wi_handle, WF_HSLSIZE, cur_top->h_size, 0, 0, 0);
		   wind_set (wi_handle, WF_VSLSIZE, cur_top->v_size, 0, 0, 0);
		   }
	   
	   wind_open(wi_handle,xcurr,ycurr,wcurr,hcurr);
	   wind_get (wi_handle,WF_WORKXYWH,&xwork,&ywork,&wwork,&hwork);
}

/****************************************************************/
/* find and redraw all clipping rectangles				    */
/****************************************************************/
do_redraw(xc,yc,wc,hc)
int xc,yc,wc,hc;
{
GRECT t1,t2;

	   hide_mouse();
	   wind_update(TRUE);
	   t2.g_x=xc;
	   t2.g_y=yc;
	   t2.g_w=wc;
	   t2.g_h=hc;
	   wind_get(wi_handle,WF_FIRSTXYWH,&t1.g_x,&t1.g_y,&t1.g_w,&t1.g_h);
	   while (t1.g_w && t1.g_h) {
		if (rc_intersect(&t2,&t1)) {
		  set_clip(t1.g_x,t1.g_y,t1.g_w,t1.g_h);
		  draw_window();
		}
		wind_get(wi_handle,WF_NEXTXYWH,&t1.g_x,&t1.g_y,&t1.g_w,&t1.g_h);
	   }
	   wind_update(FALSE);
	   show_mouse();
}

/****************************************************************/
/*			 Accessory Init. Until First Event_Multi	    */
/****************************************************************/
main()
{

	int i;
	
	appl_init();
	phys_handle=graf_handle(&gl_wchar,&gl_hchar,&gl_wbox,&gl_hbox);
	if (Getrez() == 2)
		def_point = 15;
	else def_point = 9;

	GDOS_inst = FALSE;
	asm { 
		  move.w	   #-2,D0 		  ; assembly language code
		  trap	   #2			  ; to find out if GDOS is
		  cmp.w	   #-2,D0 		  ; present or not
		  beq	   no_gdos
		  move.w	   #1,GDOS_inst(A4)
		  bra	   all_done
  no_gdos:  move.w	   #0,GDOS_inst(A4)
  all_done: nop
	  }

#ifdef ACCESSORY
	   menu_id=menu_register(gl_apid,"  Igor       ");
#endif
	wind_get(0, WF_WORKXYWH, &xdesk, &ydesk, &wdesk, &hdesk);
	xcurr = xdesk;
	ycurr = ydesk;
	wcurr = 15 * (wdesk / 16);
	hcurr = 7 * (hdesk / 8);
	set_up_infos();

#ifdef ACCESSORY
	wi_handle = NO_WINDOW;
#else
	open_vwork();
	open_window();
	graf_mouse (ARROW, 0x0L);
#endif

	hidden=FALSE;
	fulled=FALSE;
	butdown=TRUE;

	for (i=0;i<NUM_LASTS;i++) 
	   last_topics[i] = NULL;
	first_topic = cur_top = NULL;

	main_load();	
	cur_top = NULL;
	strcpy (global_path, "A:\*.HLP");

	strcpy (search_buff, "\0\0\0");		/* make sure it's empty */
	if ((can_search = (rsrc_load ("\\IGOR.RSC") != 0)) == FALSE)
		  form_alert (1, "[3][  Could not load IGOR.RSC!  |  Cannot do searches!  ][  OK  ]");


	multi();
}


/****************************************************************/
/* dispatches all accessory tasks						    */
/****************************************************************/
multi()
{
int event;

#ifdef ACCESSORY
	 while (TRUE) {
#else
	   do {
#endif
			 event = evnt_multi (MU_MESAG | MU_BUTTON | MU_KEYBD,
				    1,1,butdown,
				    0,0,0,0,0,
				    0,0,0,0,0,
				    msgbuff,0,0,&mx,&my,&ret,&ret,&keycode,&ret);

			 wind_update(TRUE);
			 wind_get(wi_handle,WF_TOP,&top_window,&ret,&ret,&ret);

			 if (event & MU_MESAG)
			  switch (msgbuff[0]) {

			   case WM_REDRAW:
				if (msgbuff[3] == wi_handle)
				    do_redraw(msgbuff[4],msgbuff[5],msgbuff[6],msgbuff[7]);
			 break;

			 case WM_NEWTOP:
			 case WM_TOPPED:
			 if (msgbuff[3] == wi_handle){
				    wind_set(wi_handle,WF_TOP,0,0,0,0);}
			 break;

#ifdef ACCESSORY
			 case AC_CLOSE:
			 if((msgbuff[3] == menu_id)&&(wi_handle != NO_WINDOW)){
				    if (use_GDOS)
					    vst_unload_fonts (handle, 0);
				    v_clsvwk (handle);
				    wi_handle = NO_WINDOW;
				    }
			 break;

			 case WM_CLOSED:
			 if (msgbuff[3] == wi_handle) {
				    wind_close (wi_handle);
				    graf_shrinkbox (0,0,gl_wbox,gl_hbox,xwork,ywork,wwork,hwork);
				    wind_delete (wi_handle);
				    v_clsvwk (handle);
				    wi_handle = NO_WINDOW;
				    }
			 break;
#endif

			 case WM_SIZED:
			 case WM_MOVED:
			 if (msgbuff[3] == wi_handle) {
						  if (msgbuff[6]<MIN_WIDTH)
								msgbuff[6]=MIN_WIDTH;
						  if (msgbuff[7]<MIN_HEIGHT)
								msgbuff[7]=MIN_HEIGHT;
						  wind_set(wi_handle,WF_CURRXYWH,msgbuff[4],msgbuff[5],msgbuff[6],msgbuff[7]);
						  wind_get(wi_handle,WF_WORKXYWH,&xwork,&ywork,&wwork,&hwork);
						  wind_get(wi_handle,WF_CURRXYWH,&xcurr,&ycurr,&wcurr,&hcurr);
						  settle_slides();
				    }
			 break;

#ifdef ACCESSORY
			 case AC_OPEN:
				    if (wi_handle == NO_WINDOW) {
						  open_vwork();
						  open_window();
						  }
				    else	  /* if already opened, for user convenience */
						  wind_set(wi_handle,WF_TOP,0,0,0,0);
			 break;
#endif

			 case WM_FULLED:
			 if (fulled) {
						  wind_calc(WC_WORK,WI_KIND,xold,yold,wold,hold,
								&xwork,&ywork,&wwork,&hwork);
						  wind_set(wi_handle,WF_CURRXYWH,xold,yold,wold,hold);
						  settle_slides();
						  }
			 else {
						  wind_calc(WC_BORDER,WI_KIND,xwork,ywork,wwork,hwork,
								&xold,&yold,&wold,&hold);
						  wind_calc(WC_WORK,WI_KIND,xdesk,ydesk,wdesk,hdesk,
								&xwork,&ywork,&wwork,&hwork);
						  wind_set(wi_handle,WF_CURRXYWH,xdesk,ydesk,wdesk,hdesk);
						  settle_slides();
				    }
			 wind_get(wi_handle,WF_WORKXYWH,&xwork,&ywork,&wwork,&hwork);
			 wind_get(wi_handle,WF_CURRXYWH,&xcurr,&ycurr,&wcurr,&hcurr);
			 fulled ^= TRUE;
			 break;
			 
			case WM_ARROWED:	do_arrowed (msgbuff[3], msgbuff[4]);
							break;
			case WM_HSLID: 	do_hslide (msgbuff[3], msgbuff[4]);
							break;
			case WM_VSLID: 	do_vslide (msgbuff[3], msgbuff[4]);
							break;

		} /* switch (msgbuff[0]) */

	   if ((event & MU_BUTTON)&&(wi_handle == top_window))
		handle_mouse (mx, my);

	   if (event & MU_KEYBD) {
		switch (keycode) {
			case 0x4800   : do_arrowed (wi_handle, 2);	/* up arrow */
						 break;
			case 0x4838   : do_arrowed (wi_handle, 0);	/* shift up arrow */
						 break;
			case 0x5000   : do_arrowed (wi_handle, 3);	/* down arrow */
						 break;
			case 0x5032   : do_arrowed (wi_handle, 1);	/* shift down arrow */
						 break;
			case 0x4B00   : do_arrowed (wi_handle, 6);	/* left arrow */
						 break;
			case 0x4B34   : do_arrowed (wi_handle, 4);	/* shift left arrow */
						 break;
			case 0x4D00   : do_arrowed (wi_handle, 7);	/* right arrow */
						 break;
			case 0x4D36   : do_arrowed (wi_handle, 5);	/* shift right arrow */
						 break;
			case 0x4700   : do_vslide (wi_handle, 0);	/* home */
						 break;
			case 0x1400   : if (mode != TOPICS)		/* T */
							change_from_topic();
						 break;
			case 0x2600   : do_reload();				/* L */
						 break;
			case 0x1F00   : if (mode == TOPICS)		/* S */
							search_names();
						 else search_topic();
						 break;
			}
		}
	   
	   wind_update(FALSE);

#ifdef ACCESSORY
	 } /* while (TRUE) */
#else
			 } while (!((event & MU_MESAG) && (msgbuff[0] == WM_CLOSED)));

	   wind_close (wi_handle);
	   graf_shrinkbox (0,0,gl_wbox,gl_hbox,
				    xcurr, ycurr, wcurr, hcurr);
	   wind_delete (wi_handle);
	   if (use_GDOS)
		   vst_unload_fonts (handle, 0);
	   v_clsvwk (handle);
	   Mfree ((long) mem_ptr);		/* free up memory */
	   appl_exit();
#endif

}

/****************************************************************/
/* Draw the text									    */
/****************************************************************/
draw_window()
{
	int temp[8], x, y, wx, wy, ww, wh, lines_vis, i, j, vert, horz;
	CHUNK_TYPE *s, *get_text();

	wind_get (wi_handle, WF_WORKXYWH, &wx, &wy, &ww, &wh);

	vsf_interior(handle,2);
	vsf_style(handle,8);
	vsf_color(handle,0);
	temp[0]=wx;
	temp[1]=wy;
	temp[2]=wx+ww-1;
	temp[3]=wy+wh-1;
	v_bar(handle,temp); 		  /* blank the interior */
	
	vst_effects (handle, 0);
	vst_color (handle, 1);
	vst_point (handle, def_point, &pchar_w, &pchar_h, &pcell_w, &pcell_h);
	if (use_GDOS)
	   vst_font (handle, 1);
	
	v_gtext (handle, wx, wy+gl_hchar-1, button_line);
	
	temp[0] = wx;
	temp[1] = wy + gl_hchar + 1;
	temp[2] = wx+ww;
	temp[3] = wy + gl_hchar + 1;
	vsl_width (handle, 1);
	vsl_color (handle, 1);
	v_pline (handle, 2, temp);
		   
	x = gl_wchar / 2;
	i = 0;
	for (y = gl_hchar+2; y < wh; i++) {
		s = get_text (i, &vert, &horz);
		if (s != NULL) {
			y += vert;
			x = gl_wchar / 2 - horz * gl_wchar + wx;

			while (s != NULL) {
				if (x > wx || x + s->len > wx) {
					if (use_GDOS)
						vst_font (handle, s->font);
					vst_effects (handle, s->efft);
					vst_color (handle, s->colr);
					vst_point (handle, s->size, &pchar_w, &pchar_h, &pcell_w, &pcell_h);
					v_gtext (handle, x, y+wy, s->text);
					x += s->len;
					}
				s = s->next_chunk;
				}
			}

		else y += gl_hchar;
		}
	
}



/***********************************************************************/
/*	Basically all the code above this point is part of the desk 	 */
/*	accessory skeleton. 									 */
/***********************************************************************/




CHUNK_PTR get_text (n, vert, horz)
int n, *vert, *horz;
/*	Returns a pointer to the nth line of the current display */
/*	and returns the height of that line and its leftmost "column" */
{

	CHUNK_TYPE *get_topic_text(), *get_line_text();
	
	if (mode == TOPICS)
		return (get_topic_text(n, vert, horz));
	else return (get_line_text(n, vert, horz));
	
}




CHUNK_PTR get_topic_text (n, vert, horz)
int n, *vert, *horz;
/* Returns a pointer to the nth line of topic names currently */
/*	in the window, its height and left-most "column"		  */
{

	TOPIC_PTR p;

	n += ttop_line;				/* look for the n+ttop_line-th topic's name */
	p = first_topic;				/* scan through the list until we find it or */
	while (n-- > 0 && p != NULL)		/*		there are no more topics */
		p = p->next;
	if (p != NULL) {				/* if there's something */
		*vert = p->v;
		*horz = ttop_col;
		return (p->first_chunk);
		}
	else {
		*vert = gl_hchar;
		*horz = 0;
		return (NULL);
		}
	
}




CHUNK_PTR get_line_text (n, vert, horz)
int n, *vert, *horz;
/* Returns the text of the nth line of the current display of a single topic */
{

	LINE_PTR p;
	char t[255], *u;

	if (cur_top == NULL) {		/* if we're not displaying any topic, return NULL */
		*vert = gl_hchar;
		*horz = 0;
		return (NULL);
		}
	else { n += cur_top->top_line;	/* otherwise we work as before */
		  p = cur_top->first_line;
		  while (n-- > 0 && p != NULL)
			  p = p->next_l;
		  if (p != NULL) {
			  *vert = p->v;
			  *horz = cur_top->top_col;
			  return (p->first_chunk);
			  }
		  else { 
			  *vert = gl_hchar;
			  *horz = 0;
			  return (NULL);
			  }
		}
	
}





		



/***********************************************************************/
/*	   Set up information lines								 */
/***********************************************************************/

set_up_infos()
/* sets up the two possible button lines (the name is a holdover from */
/*	earlier attempts)										*/
{

	char t[512], u[256], v[256];
	CHUNK_PTR p;
	int i=-1;

	strcpy (topics_info, "  LOAD  |  SEARCH  |");	 /* set up the basic lines */
	strcpy (lines_info, "  TOPICS  |  SEARCH  |");
	strcpy (t, "\0");					/* add all the stuff we've visited */
	while (++i < NUM_LASTS && last_topics[i] != NULL && strlen (t) < 128) {
		de_chunk (last_topics[i]->first_chunk, v);
		sprintf (u, "  %s  |", v);
		strcat (t, u);
		}
	strcat (topics_info, t);
	strcat (lines_info, t);

}


/***********************************************************************/
/*			Load files									 */
/***********************************************************************/

do_reload()
/*	load a new file */
{

	char name[256], full_name[256];
	int	i;
	strcpy(name, "");

	if (fsel_input(global_path, name, &i) > 0 && i == 1) {
		strcpy (full_name, global_path);			/* set up name of file */
		for (i=strlen(full_name);full_name[i-1]!='\\';i--);
		full_name[i] = '\0';
		strcat (full_name, name);
		if (mode != TOPICS) 			/* automatically switch us back */
			change_from_topic();		/*	to list of topics */
		mem_pos = 0L;					/* reset memory */
		for (i=0;i<NUM_LASTS;i++) 
			last_topics[i] = NULL;
		first_topic = cur_top = NULL;    /* reset pointers */
		tot_top_h = gl_hchar;
		max_top_w = LINE_LENGTH * gl_wchar;
		been_warned = FALSE;
		load_file (full_name);			/* load new file */
		set_up_infos();				/* set up button lines */
		settle_slides(); 
		}
		
}



main_load()
/* load the default file; executed when we start up */
/* this also allocates the memory we need		  */
/* (remember, Malloc (-1L) == free memory		  */
/* when compiled as a desk accessory, we have to create */
/* a virtual workstation in order to tell how large strings are */
/* in the help file */
{

	FILE *fp;
	char name[256], biff[128];
	int loaded = FALSE;
	long i;

#ifdef ACCESSORY
	use_GDOS = GDOS_inst;
	open_vwork();		/* make sure we have a virtual workstation */
#endif
	mem_pos = 0L;
	tot_top_h = gl_hchar;
	been_warned = FALSE;
	max_top_w = LINE_LENGTH * gl_wchar;
	if ((fp = fopen("\IGOR.DAT", "r")) != NULL) {
		if (fgets (name, 128, fp) != NULL) {
			if (fgets (biff, 128, fp) != NULL) 	/* get size of buffer (in Kb) */
				mem_size = 1024L * atol (biff);
			else mem_size = DEF_SIZE;	 
			if (mem_size < 0L)
				mem_size = DEF_SIZE;
			if (mem_size > Malloc (-1L))			/* do we want more than there is? */
				mem_size = Malloc (-1L) / 2L;
			mem_ptr = (char *) Malloc (mem_size);
			if (mem_ptr == NULL)
				mem_size = 0L;
			load_file (name);
			loaded = TRUE;
			use_GDOS = (GDOS_inst && fgets (name, 128, fp) != NULL && (name[0] == 'Y' || name [0] == 'y'));
			}
		fclose (fp);
		}
	if (loaded == FALSE) {			/* either the data file wasn't there, or */
								/* it didn't contain the name of a help file */
		mem_size = DEF_SIZE;    
		if (mem_size > Malloc (-1L))	/* do we want more than there is? */
			mem_size = Malloc (-1L) / 2L;
		mem_ptr = (char *) Malloc (mem_size);
		}
		
	if (mem_ptr == NULL) {			/* did something go wrong? */
		form_alert (1, "[3][  No memory available!  ][  OK  ]"); 
		mem_size = 0L;
		}
		
#ifdef ACCESSORY
	if (GDOS_inst)
		vst_unload_fonts (handle, 0);
	v_clsvwk (handle);				/* close down our workstation */
#else
	if (use_GDOS == FALSE)
		vst_unload_fonts (handle, 0);
#endif	 

}




load_file (name)
char *name;
/* load a file with the name *name */
{

	FILE 	*fp;
	char 	t[256], *s;
	int		i;
	TOPIC_PTR p;

	for (i=0;i<strlen(name);i++) 
		if (name[i] == '\n')
			name[i] = '\0';
	if ((fp = fopen(name, "r")) != NULL) {
		while ((s = fgets (t, 256, fp)) != NULL)
			process_line (t);
		fclose (fp);
		}
	for (i = 1, p = first_topic; p != NULL; p = p->next, i++)
		p->topic_no = i;

}




int topic_in(t)
char *t;
/* is this the first line of a new topic? */
{

	char s[256];

	if (strlen(t) < 7)
		return (FALSE);
	else {	strcpy (s, t);
			s [6] = '\0';
			return ((strcmp(s, "TOPIC ") == 0));
		}
		
}




process_line (t)
char *t;
/* if a line is the first line of a new topic, process a new topic, */
/*	else process a new line within the current topic			   */
{
	int i;
	
	for (i=0;i<strlen(t);i++)				/* clear '\n' at the end of the line */
		if (t[i] == '\n')	 t[i] = '\0';
		
	if (strlen(t) > 6 && topic_in (t))
		new_topic (t);
	else new_line (t);

}




new_topic (t)
char *t;
/* creates a new topic with the name *t and height vert */
{

	char 	*s;
	TOPIC_PTR p;
	int		len, hght, eff, fnt, clr, siz;

	s = (char *)((long) t + 6);			/* point beyond "TOPIC " at the beginning */
	if ((p = NEW_TOPIC_PTR) != NULL) { 	/* can we allocate memory? */
		p->next = p->last = NULL;		/* initialize everybody */
		clr = fnt = 1;
		eff = 0;
		siz = def_point;
		len = 0;
		hght = gl_hchar; 
		p->topic_no = no_topics++;
		p->top_line = 0;
		p->top_col = 0;
		p->no_lines = 0;
		p->v_pos = 1;
		p->h_pos = 1;
		p->v_size = 1000;
		p->h_size = 1000;
		while (tilde_len(s) > LINE_LENGTH) 	 /* make sure the title isn't too long */
			s[strlen(s)-1] = '\0';
		split_line (s, &hght, &len, &eff, &fnt, &clr, &siz, &(p->first_chunk));
		p->v = hght;
		p->max_w = LINE_LENGTH * gl_wchar;
		p->tot_h = gl_hchar;
		tot_top_h += hght;
		max_top_w = max(max_top_w, len);
		p->first_line = NULL;
		cur_top = p;
		add_topic (p); 				/* add it to the list */
		}
	else {
		cur_top = NULL;		   /* if we failed, make sure this is NULL */
		}

}


int is_before (s1, t1)
CHUNK_TYPE *s1, *t1;
/* is s1 before t1 lexically--ignoring control blocks, that is */
{

	char s[256], t[256];
	
	de_chunk (s1, s);
	de_chunk (t1, t);
	return (strcmp (s, t));
	
}




add_topic (p)
TOPIC_PTR p;
/* adds topic *p to the list in alphabetical order */
{

	TOPIC_PTR q;

	if (first_topic == NULL) 	/* nothing in list? */
		first_topic = p;
	else { 
			/* before first_topic alphabetically? */
		if (is_before (p->first_chunk, first_topic->first_chunk) < 0) {
			first_topic->last = p;
			p->next = first_topic;
			first_topic = p;
			}
		else {
			/* scan until we get to the end or past the point where */
			/* this name should be inserted					 */
			q = first_topic;
			while (q->next != NULL && is_before (p->first_chunk, q->first_chunk) > 0)
				 q = q->next;
			if (is_before (p->first_chunk, q->first_chunk) > 0) {
				q->next = p;
				p->last = q;
				}
			else {
				q->last->next = p;
				p->last = q->last;
				p->next = q;
				q->last = p;
				}
			}
		}

}




new_line (t)
char *t;
/* create a new line with the text *t and add it to the list (if possible) */
{

	LINE_PTR p;
	int fnt, clr, siz, eff, wid, hig;
	
	/* If cur_top is not NULL and we can allocate memory, then add */
	/*	the line to the current topic */
	
	if (cur_top != NULL && (p = NEW_LINE_PTR) != NULL) {
		p->next_l = p->last_l = NULL; 		/* initialize stuff */
		p->line_no = (cur_top->no_lines)++;
		while (tilde_len(t) > LINE_LENGTH) 		 /* make sure the text isn't too long */
			t[strlen(t)-1] = '\0';
		fnt = clr = 1;
		siz = def_point;
		eff = 0; 
		wid = 0;
		hig = gl_hchar;
		split_line (t, &hig, &wid, &eff, &fnt, &clr, &siz, &(p->first_chunk));
		p->v = hig;
		cur_top->max_w = max (cur_top->max_w, wid);
		cur_top->tot_h += hig;
		add_line(p);						/* add it to the list */
		}
}




add_line (p)
LINE_PTR p;
/* add a line to the current topic, if possible */
{

	LINE_PTR q;
	
	if (cur_top != NULL) {
		if (cur_top->first_line == NULL)
			cur_top->first_line = p;
		else {	q = cur_top->first_line;
				while (q->next_l != NULL)
					q = q->next_l;
				q->next_l = p;
				p->last_l = q;
			}
		}
	
}




/**********************************************************************/
/*	    Memory allocation related routine						*/
/**********************************************************************/


char *my_malloc (size)
long size;
/* allocates memory from the block given us by the operating system */
/* returns NULL if there isn't enough room left in the block */
{

	char t[256];
	
	if (size & 1L != 0L)	/* make sure we use an EVEN number of bytes */
		size++;			/* (avoid address errors on the 68000) */
	if (size + mem_pos >= mem_size) {	/* is there memory left in our block? */
		if (!(been_warned)) {
			been_warned = TRUE;
			form_alert (1, "[3][  Igor is out of memory.  |  Using this file may make |  the system crash.  ][  OK  ]"); 
			form_alert (1, "[3][  Increase default memory  |  and reboot.  ][  OK  ]");
			}
		return (NULL); 		   /* return NULL */
		}
	else {
		   mem_pos += size; 	   /* yes, increment pointer */
		   return ((char *) ((long) mem_ptr + mem_pos - size));
		}					   /* return where the pointer USED to be */

}



/************************************************************************/
/*		What to do with a mouse click 						  */
/************************************************************************/


handle_mouse(mx, my)
int mx, my;
{

	int wx, wy, ww, wh, x, y, temp [8], i;
	int vert, horz, chars;
	char t[256], s1[256];
	CHUNK_PTR s, p, q;
	
	wind_get (wi_handle, WF_WORKXYWH, &wx, &wy, &ww, &wh);
	mx -= wx; 			/* adjust to coordinates within our window */
	my -= wy;
	
	if (my <= gl_hchar) 	/* convert my to line number */
		my = 0;
	else {
		i = 1;
		y = 2 * gl_hchar + 2;
		while (y < wh && y < my) {
			s = get_text (i, &vert, &horz);
			y += vert;
			i++;
			}
		my = i;
		}
	
	if (my != 0) {     
		de_chunk (s, s1);
		x = mx + gl_wchar * horz;
		chars = 0;
		for (p = s, q = NULL; x > 0 && p != NULL; p = p->next_chunk) {
			x -= p->len;
			chars += strlen(p->text);
			q = p;
			}
		if (x <= 0 && q != NULL) {
			chars -= ((-x * strlen(q->text)) / q->len);
			mx = chars;
			}
		else mx = chars + 1;	/* make sure mx is beyond end of string */
		}
	else mx /= gl_wchar;
	
	if (mode == TOPICS) {	
		if (my > 0) {				 /* are we not in the button line? */
			change_to_topic (my-1);	 /* switch to the appropriate topic */
			}
		else {
			if (mx < 8)				 /* In the LOAD button? */
				  do_reload(); 		 /* yes, get a new file */
			else if (mx < 19)			 /* in the SEARCH button? */
				  search_names();		 /* yes, do the search */
			else string_topic (button_line, mx);		/* no, check to see if we're in a topic name */
			}
		}
	else {						/* we're looking at a topic */
		if (my == 0) { 			/* in the button line? */
			if (mx < 11)			/* in the TOPIC button? */
				change_from_topic();
			else if (mx < 22)
				search_topic();
			else string_topic (button_line, mx);
			}
		else if ((s = get_line_text(my-1, &vert, &horz)) != NULL) {     /* get the text of the line we're in */
				de_chunk (s, s1);
				string_topic (s1, mx);
				}
		}
		
}	/* handle_mouse() */




/*************************************************************************/
/*		 Topic-changing routines 							   */
/*************************************************************************/




string_topic (t, n)
char *t;
int n;
{

	/* if the character t[n] is a part of the name of some topic, */
	/*	then change to that topic						  */

	int j, temp;
	TOPIC_PTR p;
	char u[256];
	
	for (j = 0, p = first_topic; p->next != NULL; p = p->next, j++);
	temp = TRUE;
	while (p != NULL && temp) {
		de_chunk (p->first_chunk, u);
		temp = not_in_string (u, t, n);
		if (temp) {
			p = p->last;
			j--;
			}
		}
	if (p != NULL)
		change_to_topic (j-ttop_line);
		
}




not_in_string (t1, s1, n)
char *t1, *s1;
int n;
/*	returns FALSE if s[n] is within any occurence of string *t in string *s */
/*	This function calls itself.  If *t occurs within *s more than once, we first */
/*		check to see if s[n] is part of the first occurence.  If not, we create */
/*		a new (char *) pointing beyond this first orrurence of *t, and check to */
/*		see if it s[n] occurs within an instance of *t in the remainder */
{

	int	i;
	char *u, t[256], s[256];


	/* first check to see if n is beyond the end of the string, or */
	/*	if *t never occurs at all in the string *s, or if it does */
	/*	if it occurs after s[n]							   */
   
	strcpy (t, t1);		/* make sure we use command-block-less strings */
	de_tilde (t);
	strcpy (s, s1);
	de_tilde (s);
	while (strlen(t) > 0 && t[strlen(t)-1] == ' ')	/* strip trailing blanks */
		t[strlen(t)-1] = '\0';
	while (strlen(s) > 0 && s[strlen(s)-1] == ' ')
		s[strlen(s)-1] = '\0';

	if (n > strlen(s) || (i = pos (s, t, TRUE, FALSE)) == -1 || i > n) 
		return (TRUE);
	else {
		if (n < i + strlen(t))			/* is s[n] within the first occurence of *t */
			return (FALSE);
		else {						/* no--is it in subsequent occurences? */
			u = (char *)((long) s + i + strlen(t)); 		/* point beyond the first occurence of *t */
			return (not_in_string (t, u, n-i-strlen(t)));	/* call not_in_string() recursively	  */
			}
		}
			
}


change_to_topic(n)
int n;
/* change the display to topic on line n in the display */
{

	TOPIC_PTR p;
	
	n += ttop_line;
	p = first_topic;			/* find a pointer to the topic */
	while (n-- > 0 && p != NULL)
		p = p->next;
	if (p != NULL) {			/* if there is such a beast, then change */
		mode = LINES;
		cur_top = p;
		add_to_topic_list (p);
		set_up_infos();
		button_line = lines_info;
		settle_slides();
		}
	
}






change_from_topic()
/* change the display to the list of topics */
{

	add_to_topic_list (cur_top);	   /* add the current topic to the list of recently visited stuff */
	cur_top = NULL;
	mode = TOPICS;
	set_up_infos();
	button_line = topics_info;
	settle_slides();
		
}




add_to_topic_list(p)
TOPIC_PTR p;
/* adds *p to the list of recently visited topics */
/* if *p is already in the list, then we just do some */
/*	reshuffling */
{

	int i, j;
	
	if (p != NULL) {
		j = NUM_LASTS-1;
		for (i=0;i<NUM_LASTS;i++)		/* is *p already in the list */
			if (last_topics[i] == p)
				j = i;
		for (i=j;i>0;i--)
			last_topics[i] = last_topics[i-1];
		last_topics[0] = p;
		}
		   
}


int tilde_len (t)
char *t;
/*  returns the length of a line less the tilde command blocks */
{

	char s[256];
	
	strcpy (s, t);
	de_tilde (s);
	return (strlen (s));
	
}



de_tilde (t)
char *t;
/* remove all one/two/four-character chunks beginning with '~' in the string */
{

	int i, j;
	
	for (i=strlen(t)-1;i>=0;i--)
		if (t[i] == '~') {
			if (t[i+1] == '~') 
				for (j=i;t[j]!='\0';j++)
				    t[j] = t[j+1];
			else if (t[i+1] == 'n' || t[i+1] == 'N')
				for (j=i;t[j+1]!='\0';j++)
					t[j] = t[j+2];
			else for (j=i;t[j+3]!='\0';j++)
					t[j] = t[j+4];
			}
				
}




de_chunk (p, t)
CHUNK_PTR p;
char *t;
/* copies into t the text of all the chunks beginning with p */
/* that it, it produces the total text in any given line, without */
/* text effects */
{

	strcpy (t, "\0");
	while (p != NULL) {
		strcat (t, p->text);
		p = p->next_chunk;
		}
		
}




pos (s1, t1, low_up, wild_card)
char *s1, *t1;
int low_up;
/*	Looks for the position of string *t1 in string *s1 */
/*	Returns -1 if it isn't found				  */
/*	if (low_up) distinguishes between upper and lower cases */
/*	if (wild_card), then "?" acts as a wild-card character */
{

	register int i, j, k, not_found = TRUE;
	char s[256], t[256];

	strcpy (s, s1);
	de_tilde (s);
	strcpy (t, t1);
	de_tilde (t);
	if (strlen(t) > strlen(s))
		return (-1);
	else {
		for (i=0;i<=strlen(s)-strlen(t) && not_found; i++) {
			for (j=0;t[j] != '\0' && (wild_card && t[j] == '?' || t[j]==s[j+i] ||
						low_up == FALSE && toupper(t[j]) == toupper(s[i+j]))
						; j++);
			not_found = (t[j] != '\0');
			}
		if (not_found)
			return (-1);
		else return (i);
		}
		
}

/*************************************************************************/
/*			 Search routines								   */
/*************************************************************************/


int do_search_dialog()
{

	OBJECT *dialog;
	int cx, cy, cw, ch;
	int wx, wy, ww, wh;
	int exit_obj;
	char temp_buff [128];

	wind_get (0, WF_WORKXYWH, &wx, &wy, &ww, &wh);
	rsrc_gaddr (0, SEARCHD, &dialog);

	strcpy (temp_buff, search_buff);

	((TEDINFO *)dialog[SEARCHS].ob_spec)->te_ptext = temp_buff;
	((TEDINFO *)dialog[SEARCHS].ob_spec)->te_txtlen = 33;

	dialog [FIRSTB].ob_state  = NORMAL;
	dialog [NEXTB].ob_state	 = NORMAL;
	dialog [FINALB].ob_state  = NORMAL;
	dialog [PREVB].ob_state	 = NORMAL;
	dialog [CANCELB].ob_state = NORMAL;

	if (up_low) { 
		dialog [YESB].ob_state = SELECTED;
		dialog [NOB].ob_state  = NORMAL;
		}
	else {
		dialog [YESB].ob_state = NORMAL;
		dialog [NOB].ob_state  = SELECTED;
		}

	form_center (dialog, &cx, &cy, &cw, &ch);
	form_dial (FMD_START, cx, cy, cw, ch, 0, 0, 0, 0);
	form_dial (FMD_GROW, ww / 2 - 4, wh / 2 - 4, 8, 8, cx, cy, cw, ch);
	objc_draw (dialog, 0, 10, cx, cy, cw, ch);

	if ((exit_obj = form_do (dialog, SEARCHS)) != CANCELB) {
		strcpy (search_buff, temp_buff);
		up_low = (dialog [YESB].ob_state & SELECTED != 0);
		}

	form_dial (FMD_SHRINK, ww / 2 - 4, wh / 2 - 4, 8, 8, cx, cy, cw, ch);
	form_dial (FMD_FINISH, cx, cy, cw, ch, cx, cy, cw, ch);

	return (exit_obj);

}


search_names()
{

	int the_topic, the_button, the_dir, not_found;
	TOPIC_PTR p;
	char t[256];

	if (can_search && (the_button = do_search_dialog()) != CANCELB && strlen(search_buff) > 0) {
		if (the_button == FIRSTB) {
			the_dir = 1;
			the_topic = 0;
			}
		else if (the_button == NEXTB) {
			the_topic = ttop_line + 1;
			the_dir = 1;
			}
		else if (the_button == FINALB) {
			for (p = first_topic; p->next != NULL; p = p->next);
			the_topic = p->topic_no;
			the_dir = -1;
			}
		else {
			the_topic = ttop_line - 1;
			the_dir = -1;
			}

		for (p = first_topic; p != NULL && p->topic_no != the_topic; p = p->next);
				/* start from the correct line */

		not_found = TRUE;
		while (p != NULL && not_found) {
			de_chunk (p->first_chunk, t);
			if (not_found = (pos (t, search_buff, up_low, TRUE) == -1)) {
				if (the_dir == 1)
					p = p->next;
				else p = p->last;
				}
			}

		if (p == NULL)
			form_alert (1, "[1][  Could not find string!  ][  OK  ]");
		else {
			ttop_line = p->topic_no;
			settle_slides();
			}
		}

}



search_topic()
{

	int the_line, the_button, the_dir, not_found;
	LINE_PTR p;
	char t[256];

	if (can_search && cur_top != NULL && (the_button = do_search_dialog()) != CANCELB && strlen(search_buff) > 0) {
		if (the_button == FIRSTB) {
			the_dir = 1;
			the_line = 0;
			}
		else if (the_button == NEXTB) {
			the_line = cur_top->top_line + 1;
			the_dir = 1;
			}
		else if (the_button == FINALB) {
			for (p = cur_top->first_line; p->next_l != NULL; p = p->next_l);
			the_line = p->line_no;
			the_dir = -1;
			}
		else {
			the_line = cur_top->top_line - 1;
			the_dir = -1;
			}

		for (p = cur_top->first_line; p != NULL && 
								  p->line_no != the_line; p = p->next_l);
				/* start from the correct line */

		not_found = TRUE;
		while (p != NULL && not_found) {
			de_chunk (p->first_chunk, t);
			if (not_found = (pos (t, search_buff, up_low, TRUE) == -1)) { 
				if (the_dir == 1)
					p = p->next_l;
				else p = p->last_l;
				}
			}
	
		if (p == NULL)
			form_alert (1, "[1][  Could not find string!  ][  OK  ]");
		else {
			cur_top->top_line = p->line_no;
			settle_slides();
			}
		}

}



/*************************************************************************/
/*	    slide-settling routines								   */
/*************************************************************************/


settle_slides()
/* adjusts the size and position of the slider bars */
{

	if (mode == TOPICS)
		settle_topic_slides();
	else settle_line_slides();
	do_redraw (xwork, ywork, wwork, hwork);
	
}




settle_topic_slides()
{

	int page_h, page_w, start_h, start_w;
	TOPIC_PTR p;
 
    if (first_topic == NULL) {
		th_size = tv_size = 1000;
		th_pos  = tv_pos  = 0;
		ttop_line = ttop_col = 0;
		}
	else {
	
		/* scan forward through list of topics until we find a */
		/* topic where displaying everything from that point	*/
		/* on fills the window */
		
		for (p = first_topic, start_h = tot_top_h, page_h = 0;
			p->next != NULL && start_h > hwork;
			page_h += p->v, start_h -= p->v, p = p->next);
		page_h += p->v;
			
		/* find rightmost allowable leftmost pixel */
		
		page_w  = max_top_w + gl_wchar;		 
		start_w = max(page_w - wwork,0);
		
		/* put ttop_line and ttop_col in range */
		
		ttop_line   = max(0,min(p->topic_no,ttop_line));
		ttop_col	  = (max(0,min(start_w,gl_wchar*ttop_col)))/gl_wchar;
		
		if (hwork >= tot_top_h) {	    /* everything is displayed */
			tv_size = 1000;
			tv_pos  =    0;
			ttop_line  = 0;
			}
		else {
			for (start_h=0, p = first_topic; p->topic_no < ttop_line;
				start_h += p->v, p = p->next);
			tv_size = (int) (((long) hwork * 1000L) / tot_top_h);
			if (tv_size <= 0)	tv_size = -1;
			if (p->v != page_h)
				tv_pos = (int) (((long) start_h * 1000L) / (page_h - p->v));
			else tv_pos = 0;
			}
		
		if (wwork > max_top_w) {
			th_size =  1000;
			th_pos  =     0;
			ttop_col = 0;
			}
		else {
			th_size = (int) (((long) wwork * 1000L) / page_w);
			if (th_size <= 0)	th_size = -1;
			th_pos = (int) (((long) ttop_col * gl_wchar * 1000L) / start_w);
			}
			
		}

	wind_set (wi_handle, WF_VSLSIZE, tv_size, 0, 0, 0);
	wind_set (wi_handle, WF_VSLIDE, tv_pos, 0, 0, 0);
	wind_set (wi_handle, WF_HSLSIZE, th_size, 0, 0, 0);
	wind_set (wi_handle, WF_HSLIDE, th_pos, 0, 0, 0);
	

}




settle_line_slides()
{

	int page_h, page_w, start_h, start_w;
	LINE_PTR p;

	if (cur_top != NULL) {
		if (cur_top->first_line == NULL) {
			cur_top->top_line = cur_top->top_col = 0;
			cur_top->v_pos = cur_top->h_pos = 0;
			cur_top->v_size = cur_top->h_size = 1000;
			}
		else {
		
			for (p = cur_top->first_line, start_h = cur_top->tot_h, page_h = 0;
				p->next_l != NULL && start_h > hwork;
				page_h += p->v, start_h -= p->v, p = p->next_l);
			page_h += p->v;

			page_w  = cur_top->max_w + gl_wchar;
			start_w = max(0,page_w - wwork);

			cur_top->top_line = max(0,min(p->line_no,cur_top->top_line));
			cur_top->top_col  = (max(0,min(start_w,gl_wchar*cur_top->top_col)))/gl_wchar;

			if (hwork >= cur_top->tot_h) {
				cur_top->v_size = 1000;
				cur_top->v_pos  =	 0;
				cur_top->top_line =  0;
				}
			else {
				for (start_h = 0, p = cur_top->first_line; p->line_no < cur_top->top_line;
					start_h += p->v, p = p->next_l);
				cur_top->v_size = (int) (((long) hwork * 1000L) / cur_top->tot_h);
				if (cur_top->v_size <= 0)   cur_top->v_size = -1;
				if (page_h != p->v)
					cur_top->v_pos = (int) (((long) start_h * 1000L) / (page_h - p->v));
				else cur_top->v_pos = 0;
				}

		    if (wwork >= cur_top->max_w) {
				cur_top->h_size = 1000;
				cur_top->h_pos  =	 0;
				cur_top->top_col =	 0;
				}
		    else {
				cur_top->h_size = (int) (((long) wwork * 1000L) / cur_top->max_w);
				if (cur_top->h_size <= 0)   cur_top->h_size = -1;
				cur_top->h_pos = (int) (((long) cur_top->top_col * gl_wchar * 1000L) / start_w);
			    }
		    }

		wind_set (wi_handle, WF_VSLSIZE, cur_top->v_size, 0, 0, 0);
		wind_set (wi_handle, WF_VSLIDE, cur_top->v_pos, 0, 0, 0);
		wind_set (wi_handle, WF_HSLSIZE, cur_top->h_size, 0, 0, 0);
		wind_set (wi_handle, WF_HSLIDE, cur_top->h_pos, 0, 0, 0);
		}

}



/********************************************************************************/
/*	Arrow or slider bar events (these routines are pretty straightforward 	*/
/********************************************************************************/


do_arrowed (wind, slide_type)
int wind, slide_type;
/* handles arrow events */
{

	TOPIC_PTR    p;
	LINE_PTR	   q;
	register int i;

	if (wind == wi_handle) {
		if (mode == TOPICS) {
			switch (slide_type) {
				case 0 : if (first_topic != NULL) {
							for (p = first_topic; p->topic_no < ttop_line; p = p->next);
							for (i = hwork - p->v; p->last != NULL && i > p->last->v; p = p->last, i -= p->v);
							ttop_line = p->topic_no;
							}
						break;
				case 1 : if (first_topic != NULL) {
							for (p = first_topic; p->topic_no < ttop_line; p = p->next);
							for (i = hwork - p->v; p->next != NULL && i > 0; p = p->next, i -= p->v);
							ttop_line = p->topic_no;
							}
						break;
				case 2 : ttop_line--;						break;
				case 3 : ttop_line++;						break;
				case 4 : ttop_col -= (wwork / gl_wchar) - 1; 	break;
				case 5 : ttop_col += (wwork / gl_wchar) - 1; 	break;
				case 6 : ttop_col--;						break;
				case 7 : ttop_col++;						break;
				}
			settle_slides();
			}
		else if (cur_top != NULL) {
			switch (slide_type) {
				case 0 : if (cur_top->first_line != NULL) {
							for (q = cur_top->first_line; 
								q->line_no < cur_top->top_line; 
								q = q->next_l);
							for (i = hwork - q->v; q->last_l != NULL && i > q->last_l->v; q = q->last_l, i -= q->v);
							cur_top->top_line = q->line_no;
							}
						break;
				case 1 : if (cur_top->first_line != NULL) {
							for (q = cur_top->first_line; 
								q->line_no < cur_top->top_line; 
								q = q->next_l);
							for (i = hwork - q->v; q->next_l != NULL && i > 0; q = q->next_l, i -= q->v);
							cur_top->top_line = q->line_no-1;
							}
						break;
				case 2 : cur_top->top_line--; 					break;
				case 3 : cur_top->top_line++; 					break;
				case 4 : cur_top->top_col -= (wwork / gl_wchar) - 1;	break;
				case 5 : cur_top->top_col += (wwork / gl_wchar) - 1;	break;
				case 6 : cur_top->top_col--;						break;
				case 7 : cur_top->top_col++;						break;
				}
			settle_slides();
			}
		}
		
}




do_vslide(wind, pos)
int wind, pos;
/* handles vertical slider bar events */
{

	TOPIC_PTR    p;
	LINE_PTR	   q;
	register int i, ideal;

	if (wind == wi_handle) {
		if (mode == TOPICS) {
			if (first_topic != NULL) {
				ideal = (int) (((long) pos * (long) (max(0,tot_top_h - hwork))) / 1000);
				for (p = first_topic, i = 0; p->next != NULL && i <= ideal;
					i += p->v, p = p->next);
				ttop_line = p->topic_no;
				settle_slides();
				}
			}
		else if (cur_top != NULL && cur_top->first_line != NULL) {
			ideal = (int) (((long) pos * (long) (max(0,cur_top->tot_h - hwork))) / 1000);
			for (q = cur_top->first_line, i = 0; q->next_l != NULL && i < ideal;
				i += q->v, q = q->next_l);
			cur_top->top_line = q->line_no;
			settle_slides();
			}
		}
		
}




do_hslide(wind, pos)
int wind, pos;
/* handles horizontal slider bar events */
{

	if (wind == wi_handle) {
		if (mode == TOPICS) {
			ttop_col = (int) (((long) pos * (long) max(max_top_w-wwork,0)) / (gl_wchar * 1000)) - 1;
			settle_slides();
			}
		else if (cur_top != NULL) {
			cur_top->top_col = (int) (((long) pos * (long) max(cur_top->max_w-wwork,0)) / (gl_wchar * 1000)) - 1; 
			settle_slides();
			}
		}
		
}





/***********************************************************************/
/*	  Routines to divide text lines into chunks					 */
/***********************************************************************/


is_comm (c)
char c;
/* returns TRUE if c is a character for a tilde command */
{

	register char d;

	return ((d = toupper(c)) == 'N' || d == 'E' || d == 'C' || d == 'F' ||
			d == 'S');
			
}



split_line (s, max_h, tot_w, eff, fnt, clr, siz, p)
char *s;
int *max_h, *tot_w, *eff, *fnt, *clr, *siz;
CHUNK_PTR *p;
/* splits the line up into chunks, updating effect and size in- */
/* formation as needed, and storing the result in the CHUNK_PTR */
/* pointed to by p */
{

	int pchw, pchh, pclw, pclh;
	register char c, d;
	char t[256], *u, v[256];
	int i, j, num, do_more;
	
	/* Step 1:  process all tilde commands at the beginning of the */
	/*	line 										   */

	u = s;
	while (u[0] == '~' && is_comm(u[1])) {
		if (toupper(u[1]) == 'N') {
			*eff = 0;
			*fnt = 1;
			*siz = def_point;
			*clr = 1;
			i = 2;			    /* how long is the command? */
			}
		else {
			i = 4;
			num = 10 * ((int) u[2] - (int) '0') + (int) u[3] - (int) '0';
			switch (toupper(u[1])) {
			    case 'E' : *eff = num;	    break;
			    case 'S' : *siz = num;	    break;
			    case 'F' : *fnt = num;	    break;
			    case 'C' : *clr = num;	    break;
			    }
			}
		u = (char *)((long) u + i);
		}
		
	/* Step 2:  Find the end of the line or the next tilde command */
	/*	Turn any double tildes into single tildes along the way   */
	
	strcpy (t, u);
	for (i=0; (c = t[i]) != '\0' && !(c == '~' && is_comm(t[i+1])); i++)
		if (c == '~' && t[i+1] == '~') 
			for (j=i;t[j]!='\0';j++)
				t[j] = t[j+1];
				
	/* Step 3:  Split up the line if necessary and process the rest of it */
	
	if (t[i] == '~') {			/* we found a new tilde command */
		strcpy (v, (char *)((long) t + i));	/* split it up */
		t[i] = '\0';
		do_more = TRUE;					/* we're not done yet */
		}
	else do_more = FALSE;
	
	if (i == 0)		/* there is nothing in the string */
		*p = NULL;
	else {
		*p = NEW_CHUNK_PTR;
		if (*p != NULL) {
			vst_effects (handle, *eff);
			vst_point (handle, *siz, &pchw, &pchh, &pclw, &pclh);
			if (use_GDOS)
				vst_font (handle, *fnt);
			(*p)->efft = *eff;
			(*p)->size = *siz;
			(*p)->colr = *clr;
			(*p)->font = *fnt;
			*tot_w += ((*p)->len = p_length(t));
			*max_h = max(*max_h, pclh);
			(*p)->next_chunk = NULL;
			(*p)->text = my_malloc ((long) strlen(t));
			if ((*p)->text != NULL)
				strcpy ((*p)->text, t);
			}
		}
			
	if (*p != NULL && do_more) {
		split_line (v, max_h, tot_w, eff, fnt, clr, siz, &((*p)->next_chunk));
		}
		
}





int p_length (s)
char *s;
/* returns the length of the string *s, given current text attributes */
/* (font, size, effects, and so on) */
{

	int extent[8];
	
	vqt_extent (handle, s, extent);
	return (max4(extent[0],extent[2],extent[4],extent[6]) - min4(extent[0],extent[2],extent[4],extent[6]));
	
}






