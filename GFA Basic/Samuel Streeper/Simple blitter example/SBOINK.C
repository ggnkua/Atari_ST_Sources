/************************************
*		Boink program and acc		*
*		Samuel Streeper 89/11/22	*
*                                   *
*     (C) Copyright 1990 by         *
*     Antic Publishing, Inc.        *
*									*
* "what to do with all that wasted	*
*     CPU time"						*
************************************/

/* edited with tabsize = 4 */

extern int _app;


/*	Compiler notes:		*/
/*	---------------		*/
/*	This code compiles with Megamax C, Laser C, and Mark Williams C		*/
/*	version 2.0. It shouldn't be tough to get it to compile with other	*/
/*	things... I used megamax because it generated the smallest fastest	*/
/*	code (all PC relative or address register relative addressing).		*/
/*	There are just a few things to look out for when porting this		*/
/*	between compilers:													*/

/*	The blitter routines require a structure known as a memory form		*/
/*	descriptor block. Laser C and Alcyon C call this structure a		*/
/*	MFDB, while Megamax C and MWC call this a FDB.						*/

/*	Boink needs to know the address of the line-a variables.			*/
/*	Megamax does not supply a function to get this address, while		*/
/*	Laser C and MWC do, but the function has a different name. Further-	*/
/*	more, the MWC supplied function returns the wrong address with		*/
/*	tos 1.4. Consequently, I use inline assembly for megamax and laser,	*/
/*	and a simple assembly function in MWC.								*/

/*	This code will work as both a desk accessory or a program if you	*/
/*	link it with the proper startup module. The default Laser startup	*/
/*	module works ok. I recommend linking to the megamax, laser, or		*/
/*	MWC startup code supplied with Start magazine October 89. This code	*/
/*	gives the smallest executable file, and will work as a program or	*/
/*	DA just by changing the file's extention from .prg to .acc			*/

/*	When run as a program, boink has a 'fast mode' option which bounces	*/
/*	the ball without going through the evnt_multi() call. To take		*/
/*	optimal advantage of fast mode, the C library blitter function		*/
/*	vro_copyfm() should be replaced by an assembly language binding		*/
/*	which goes straight to the line-a blitter call without invoking		*/
/*	the AES (via trap #2). I have supplied such a binding which works	*/
/*	with Megamax and Laser C. This binding is transparent i.e. if		*/
/*	you link in the SVRO object file you get the custom binding,		*/
/*	otherwise you get the slower AES library binding.					*/

/*	You should define one and only one of the following entries as a	*/
/*	non-zero value depending on which compiler you are using.			*/

#define MEGAMAX 1			/* 1 if megamax, 0 if other */
#define LASER 0				/* 1 if laser c, 0 if other */
#define MWC 0				/* 1 if mark williams c, 0 if other */

#define Blit(a)		xbios(0x40,a)

#include <obdefs.h>
#include <gemdefs.h>
#include <osbind.h>

#if (MEGAMAX | MWC)
#define MFDB FDB
#endif

#if MWC
#define Kbshift(a) Getshift(a)
#endif

/* The following arrays of gem OBJECTS were dumped from a resource	*/
/* file using the resource dumper from the START magazine			*/
/* October 89 issue. By including the resource file in the code		*/
/* we don't need to load it in at run-time (which is a bad idea		*/
/* for desk accessories...)											*/

#define ABTBOINK 7
#define WINDOPEN 16
#define LOADPIC 17
#define FAST 18
#define FILEQUIT 19

OBJECT menu[] = {
-1,1,0x5,G_IBOX,0,0,0x0L,0,0,0x50,0x19,
0x5,0x2,0x2,G_BOX,0,0,0x1100L,0,0,0x50,0x201,
1,0x3,0x4,G_IBOX,0,0,0x0L,0x2,0,0xC,0x301,
0x4,-1,-1,G_TITLE,0,0," Desk ",0,0,0x6,0x301,
0x2,-1,-1,G_TITLE,0,0," File ",0x6,0,0x6,0x301,
0,0x6,0xF,G_IBOX,0,0,0x0L,0,0x301,0x50,0x13,
0xF,0x7,0xE,G_BOX,0,0,0xFF1100L,0x2,0,0x14,0x8,
0x8,-1,-1,G_STRING,0,0,"  About Boink...",0,0,0x14,1,
0x9,-1,-1,G_STRING,0,0x8,"--------------------",0,1,0x14,1,
0xA,-1,-1,G_STRING,0,0,"",0,0x2,0x14,1,
0xB,-1,-1,G_STRING,0,0,"",0,0x3,0x14,1,
0xC,-1,-1,G_STRING,0,0,"",0,0x4,0x14,1,
0xD,-1,-1,G_STRING,0,0,"",0,0x5,0x14,1,
0xE,-1,-1,G_STRING,0,0,"",0,0x6,0x14,1,
0x6,-1,-1,G_STRING,0,0,"",0,0x7,0x14,1,
0x5,0x10,0x13,G_BOX,0,0,0xFF1100L,0x8,0,0xF,0x4,
0x11,-1,-1,G_STRING,0,0,"  Open Window",0,0,0xF,1,
0x12,-1,-1,G_STRING,0,0,"  Load Pic...",0,1,0xF,1,
0x13,-1,-1,G_STRING,0,0,"  High Speed",0,0x2,0xF,1,
0xF,-1,-1,G_STRING,0x20,0,"  Quit",0,0x3,0xF,1
};

#define DIALOK 7
#define DIALLOAD 8

OBJECT dial[] = {
-1,1,1,G_BOX,0,0x10,0x11141L,0,0,0x1D,0x11,
0,0x2,0x8,G_BOX,0,0x20,0xFF1100L,1,1,0x1B,0xF,
3,-1,-1,G_STRING,0,0,"Boink",0xA,1,5,1,
4,-1,-1,G_STRING,0,0,"Samuel G. Streeper",4,3,0x12,1,
5,-1,-1,G_STRING,0,0,"1333 Wenatchee Ave",4,4,0x12,1,
6,-1,-1,G_STRING,0,0,"El Cajon, CA 92021 USA",2,5,0x17,1,
7,-1,-1,G_STRING,0,0,"Runs as .prg or .acc",3,7,0x14,1,
8,-1,-1,G_BUTTON,7,0,"OK",8,0xA,0xA,2,
1,-1,-1,G_BUTTON,0x65,0,"Load Pic...",4,0xD,0x12,1
};



#define TRUE 1
#define FALSE 0
#define WI_KIND	(SIZER|MOVER|FULLER|CLOSER|NAME|HSLIDE|LFARROW|RTARROW)

#if (MEGAMAX | LASER)
#define HIDE_MOUSE asm{	dc.w 0xa00a	}
#define SHOW_MOUSE asm{	dc.w 0xa009	}
#else
#define HIDE_MOUSE graf_mouse(M_OFF,0L);
#define SHOW_MOUSE graf_mouse(M_ON,0L);
#endif

#define NO_WINDOW (-1)

#define MIN_WIDTH  (gl_wbox + ball_ht)
#define MIN_HEIGHT (2*gl_hbox + ball_ht + 1)

#define SIDE_S 145
#define TOP_S 135
#define BOT_S 255

extern int	gl_apid;

int	gl_hchar;
int	gl_wchar;
int	gl_wbox;
int	gl_hbox;		/* sizes of system characters */

int	win_kind = WI_KIND;
int	menu_id;

int	phys_handle;	/* physical workstation handle */
int	handle;			/* virtual workstation handle */
int	w_hand;			/* window handle */

int	xdesk,ydesk,hdesk,wdesk;
int	xold,yold,hold,wold;
int	xwork,ywork,hwork,wwork;	/* desktop and work areas */

int	msgbuff[8];					/* event message buffer */
int	ret;

int	fulled;						/* current state of window */
int	fast_n_top;					/* = FALSE */
int	loop_ctr;
int	bltr_inst;					/* 1 if blitter installed */
int	blit_change;
int	vs_pos, hs_pos;
int	rez;
int	ball_ht = 100;
int	vert_fudge = 101;
int	first_open = 3;
int	*lineaptr;

#if MWC
extern int *a_init();
#endif

/* every now and then we check to see if some nasty program changed */
/* the logical screen base on us... */
long old_base;

long old_mem_amt;
char old_min = 99;

char *intro1;
char *intro2;
char *title_bar;

int	xpos;
int	xspeed = 5;
int	ypos;
int	oyspeed, yspeed;
int	accel = 2;
int	ball_num;
int	spin_dir = 1, rebound = 1;

int	maxx, maxy, maxw, maxh;
int	timer = 30000;

extern int int_in[], addr_in[], control[], int_out[];

int	contrl[12];
int	intin[128];
int	ptsin[128];
int	intout[128];
int	ptsout[128];

int work_in[11];
int work_out[57];
int pxyarray[10];						/* input point array */

int bpxyarray[12] =	{0,0,131,100,
					 0,0,131,100,
					 0,0,131,100};		/* ball blit array */

int spxyarray[8] =	{612,0,743,100,
					 0,0,131,100};

char *warray;
char *barray;
char *parray;

MFDB oldpic = 	 {0L,144,100,144/16,0,1,0,0,0};
MFDB ballsource = {0L,752,100,752/16,0,1,0,0,0};
MFDB windsource = {0L,640,344,640/16,0,1,0,0,0};
MFDB screen_fdb;

char path[80], name[14];


/* the sound string is the yamaha sound chip parameter for the bouncing		*/
/* ball sound. The osound array resets the modified sound chip registers	*/
/* to their old values so that key click sounds will be normal when the		*/
/* program terminates. Normally you would initialize the sound chip with	*/
/* a character array rather than a string, but the megamax compiler			*/
/* has a terrible method of initializing arrays that bloats the code.		*/
/* By using a string (or the Laser or Mark williams compiler) you can		*/
/* avoid bloating the code...												*/

char *sound =
	"\0\64\1\6\2\0\3\0\4\0\5\0\6\37\7\366\10\26\13\200\14\20\15\3\377\0";
/*	0,0x34,1,6,2,0,3,0,4,0,5,0,6,31,7,0xF6,8,0x16,11,0x80,12,16,13,3,0xFF,0 */

char *osound = "\1\0\6\0\7\376\377\0";

				/*	 0123456789012345678901234	*/
char *no_picture =	"Unable to open boink.pi3 degas picture\r\n";
char *no_image =	"Unable to open boink.im3 ball image\r\n";

				/*   0 123456 7890123456	*/
char *picture = 	"\\boink\\boink.pi3";
char *image =	 	"\\boink\\boink.im3";

/****************************************************************/
/* open virtual workstation										*/
/****************************************************************/
open_vwork()
{
	register int i;

	for(i=0;i<10;work_in[i++]=1);
	work_in[10]=2;
	handle=phys_handle;
	v_opnvwk(work_in,&handle,work_out);

	init_fdb();
}

/********************************************/
/*		open window							*/
/********************************************/
int open_window()
{
	if ((w_hand=wind_create(win_kind,xdesk,ydesk,maxw,maxh)) < 0)
		return -1;

	wind_set(w_hand, WF_NAME,title_bar,0,0);
	wind_set(w_hand, WF_VSLSIZE,500,0,0,0);
	wind_set(w_hand, WF_HSLSIZE,500,0,0,0);
	wind_set(w_hand, WF_VSLIDE,vs_pos,0,0,0);
	wind_set(w_hand, WF_HSLIDE,hs_pos,0,0,0);
	if (fulled) graf_growbox(xdesk,ydesk,gl_wbox,gl_hbox,xdesk,
				 ydesk,maxw,maxh);
	  else graf_growbox(xdesk,ydesk,gl_wbox,gl_hbox,xold,yold,wold,hold);
	if (fulled) wind_open(w_hand,xdesk,ydesk,maxw,maxh);
		else wind_open(w_hand,xold,yold,wold,hold);
	wind_get(w_hand,WF_WORKXYWH,&xwork,&ywork,&wwork,&hwork);

	timer = 0;
	return 0;
}

int hidden;		/* = FALSE */
/****************************************************************/
/* find and redraw all clipping rectangles			*/
/****************************************************************/
do_redraw(xc,yc,wc,hc)
register int xc,yc,wc,hc;
{
	GRECT t1,t2;
	int pxyarray[8];
	int x_pos,y_pos;

	x_pos = *(lineaptr - 301);
	y_pos = *(lineaptr - 300);

	if ((xc < (x_pos+20)) && ((xc+wc) > (x_pos - 20)) &&
		(yc < (y_pos+20)) && ((yc+hc) > (y_pos - 20)))
	{	HIDE_MOUSE
		hidden = TRUE;
	}

	wind_update(TRUE);
	if ((xc+wc) > wdesk) wc = wdesk - xc;
	if ((yc+hc) > maxy) hc =maxy-yc; /* otherwise will blit into ramdisk! */
	t2.g_x=xc;
	t2.g_y=yc;
	t2.g_w=wc;
	t2.g_h=hc;
	wind_get(w_hand,WF_FIRSTXYWH,&t1.g_x,&t1.g_y,&t1.g_w,&t1.g_h);

	while (t1.g_w && t1.g_h)
	{
		if (rc_intersect(&t2,&t1)) 
		{
			pxyarray[0] = t1.g_x - xwork;
			pxyarray[1] = t1.g_y - ywork;
			pxyarray[2] = t1.g_x - xwork + t1.g_w - 1;
			pxyarray[3] = t1.g_y - ywork + t1.g_h - 1;
			pxyarray[4] = t1.g_x;
			pxyarray[5] = t1.g_y;
			pxyarray[6] = t1.g_x + t1.g_w - 1;
			pxyarray[7] = t1.g_y + t1.g_h - 1;

			vro_cpyfm(handle,3,pxyarray,&windsource,&screen_fdb);
		}
		wind_get(w_hand,WF_NEXTXYWH,&t1.g_x,&t1.g_y,&t1.g_w,&t1.g_h);
	}
	wind_update(FALSE);
	if (hidden)
	{	hidden = FALSE;
		SHOW_MOUSE
	}
}

/********************************/
/*		MAIN() 					*/
/********************************/
main()
{
	register int temp, dw, dh;
	int fd, wx,wy,ww,wh;

/* We need to allocate space for the ball images, the background picture	*/
/* and the save area for the part of the picture we trash when we draw		*/
/* the ball. The best way to do this would be to declare three character	*/
/* arrays, but Megamax compiler will only let me have 32K of global			*/
/* variables. (yuck!) The things I put up with for PC relative code			*/
/* generation...															*/

/* Memo: if desk accessories MUST Malloc(), they should only do one,	*/
/* and do it before any AES calls.										*/
/* Also, you should check for the success of the Malloc, which is not	*/
/* done in this example. If the Malloc() fails, the program probably	*/
/* should terminate, and the desk accessory should go into some null	*/
/* event loop...														*/

	barray = (char *)Malloc((long)(9494L + 27520L + 1838L));
	warray = barray + 9494L;
	parray = warray + 27520L;

#if MEGAMAX
	asm{	dc.w 0xa000
			move.l D0,lineaptr(A4)
	   }
#else
#if LASER
	asm{	dc.w 0xa000
			move.l D0,lineaptr
	   }
#else
#if MWC
	lineaptr = a_init();
#endif						/* mwc */
#endif						/* laser */
#endif						/* megamax */

	appl_init();

	if (!_app) menu_id=menu_register(gl_apid,"  Boink ");

	phys_handle=graf_handle(&gl_wchar,&gl_hchar,&gl_wbox,&gl_hbox);

	vs_pos = ((Blit(-1) & 1) ? 0 : 1000);
	intro1 = " SGS Software presents v 2.1 ";
	intro2 = " START Boink! ";
	title_bar = "\011 00:00   0000000 free   \010blitter ";

	bltr_inst = ((Blit(-1) & 2) == 0) ? 0 : 1;
	if ((!bltr_inst) || vs_pos) title_bar[23] = '\0';
	if (bltr_inst) win_kind |= (VSLIDE|UPARROW|DNARROW);

	wind_get(0, WF_WORKXYWH, &xdesk, &ydesk, &wdesk, &hdesk);
	wind_calc(1,win_kind,xdesk,ydesk,wdesk,hdesk,&wx,&wy,&ww,&wh);
	dw = wdesk - ww;
	dh = hdesk - wh;
	maxw = (wdesk < (temp=(windsource.fd_w + dw))) ? wdesk : temp;
	maxh = (hdesk < (temp=(windsource.fd_h + dh))) ? hdesk : temp;
	xold = xdesk;
	yold = ydesk;
	wold = maxw;
	hold = maxh;

	maxx = xdesk + wdesk;
	maxy = ydesk + hdesk;

	path[0] = Dgetdrv() + 'A';
	path[1] = ':';
	Dgetpath(path+2,Dgetdrv() + 1);
	strcat(path,"\\*.PI?");
	strcpy(name,"");

	rez = Getrez();
	if (rez == 1)		/* color monitor */
	{	accel = 1;
		bpxyarray[3]=bpxyarray[7]=bpxyarray[11]=
		spxyarray[3]=spxyarray[7]= 46;
		oldpic.fd_nplanes = 2;
		ballsource.fd_nplanes = 2;
		windsource.fd_nplanes = 2;
		ball_ht = 46;
		vert_fudge = 47;
		temp = '2';
		no_picture[23] = temp;
		no_image[23] = temp;
		picture[15] = temp;
		image[15] = temp;
	}

	w_hand=NO_WINDOW;
	fulled=FALSE;


/*	Find the image of the rotating balls and load it in	*/

	fd = Fopen(image+7,0);
	if (fd <= 0)
		fd = Fopen(image,0);

	if (fd > 0)
	{	Fread(fd,(long)9494L,(char *)barray);
		Fclose(fd);
	}
	else
	{	Cconws(no_image);
		wait();
	}


/*	Find the degas picture and load it in	*/

	fd = Fopen(picture + 7,0);

	if (fd <= 0)
		fd = Fopen(picture,0);

	if (fd > 0)
	{	Fseek(34L,fd,0);
		Fread(fd,27520L,warray);
		Fclose(fd);
	}
	else
	{	Cconws(no_picture);
		wait();
	}

	ballsource.fd_addr = (long)&barray[0];
	windsource.fd_addr = (long)&warray[0];
	oldpic.fd_addr = (long)&parray[0];

	open_vwork();


/*	Before we begin, we need to fill the save area with the part	*/
/*	of the picture that will be destroyed when we blit in the ball.	*/

	vro_cpyfm(handle,3,bpxyarray,&windsource,&oldpic);

	if (_app)
	{
		dial[DIALLOAD].ob_flags = (LASTOB | HIDETREE);
		dial[DIALOK].ob_height = 3;

		graf_mouse( ARROW, 0L);

		convert_resource(menu);

		menu_bar(menu, 1);	/* display the menu */
	}
	else
	{	v_clsvwk(handle);
	}

	convert_resource(dial);

	multi();			/* accessory will not return, program will */

	menu_bar(menu, 0);	/* erase the menu bar */

	v_clsvwk(handle);	/* close the window */

	appl_exit();
}


/****************************************************************/
/* dispatches all accessory tasks				*/
/****************************************************************/
multi()
{
	int event, newx, newy;
	int sized = FALSE, done = FALSE;

/*	If run as a program in medium or high res, 	*/
/*	open window when first run.					*/

	if (_app && rez)
	{
		if (open_window() < 0)
		{	return;
		}
		redraw_time();
		new_speed();
	}


/*	The accessory will loop forever, the program loops until	*/
/*	the done variable is set to TRUE.							*/

	while ((!_app) || !done)
	{


/* Instead of using the C library function for event_multi()			*/
/* I wrote my own megamax binding in assembly. This is not				*/
/* portable to other compilers and only yields a very small increase in	*/
/* speed, but every little bit counts... Normally you would be best to	*/
/* stick to the normal C library bindings.								*/


#if (MEGAMAX == 0)

		event = evnt_multi(MU_MESAG | MU_TIMER,
			1,0,0,
			0,0,0,0,0,
			0,0,0,0,0,
			msgbuff,timer,0,&ret,&ret,&ret,&ret,&ret,&ret);

#else

		asm{
			lea int_in(A4),A0
			move.l #0x300001,(A0)+		;flags,clicks
			clr.l (A0)+
			clr.l (A0)+
			clr.l (A0)+
			clr.l (A0)+
			clr.l (A0)+
			clr.l (A0)+
			move timer(A4),(A0)+
			clr (A0)+
			lea msgbuff(A4),A0
			move.l A0,addr_in(A4)

			lea control(A4),A0
			move.l #0x190010,(A0)+		;event_multi
			move.l #0x70001,(A0)+
			clr (A0)

			lea gl_apid(A4),A0
			addq.l #2,A0				;a0 = &1ad_c, a dirty trick!
			move.l (A0),D1

			move #0xc8,D0
			trap #2						;call evnt_multi
			move int_out(A4),event(A6)	;get return value
		   }

#endif

		if (event & MU_MESAG) switch (msgbuff[0])
		{

		case MN_SELECTED:

		/* menu functions, program only */

			switch(msgbuff[4])
			{

			case ABTBOINK:	boink_dial();
					break;

			case WINDOPEN:
				if (!rez) break;
				if (w_hand != NO_WINDOW)
					wind_set(w_hand,WF_TOP,0,0,0,0);
				else if (open_window() >= 0)
				{	redraw_time();
					new_speed();
				}
				break;

			case LOADPIC:
				load_pic();
				break;

			case FAST:
				fast_mode();
				break;

			case FILEQUIT:
				if (w_hand != NO_WINDOW)
				{	wind_close(w_hand);
					wind_delete(w_hand);
				}
				done = TRUE;
				break;
			}

			menu_tnormal(menu, msgbuff[3], TRUE ); /* deselect menubar */
			break;

		case WM_REDRAW:
	    	if (msgbuff[3] == w_hand)
			do_redraw(msgbuff[4],msgbuff[5],msgbuff[6],msgbuff[7]);
	    	break;

		case WM_ARROWED:
	    	if (msgbuff[3] == w_hand) switch(msgbuff[4])
			{case 0:	/* up */
			case 2:
				vs_pos = 0;
				Blit(1);
				blit_change = 1;
				title_bar[23] = ' ';
				wind_set(w_hand, WF_VSLIDE,1,0,0,0);
				redraw_time();
				break;

			case 1:	/* down */
			case 3:
				vs_pos = 1000;
				Blit(0);
				blit_change = 1;
				title_bar[23] = '\0';
				wind_set(w_hand, WF_VSLIDE,1000,0,0,0);
				redraw_time();
				break;

			case 4:	/* left */
			case 6:
				if (hs_pos == 1000)
				{	wind_set(w_hand, WF_HSLIDE,1,0,0,0);
					invid();
					hs_pos = 0;
				}
				break;

			case 5:	/* right */
			case 7:
				if (hs_pos == 0)
				{	wind_set(w_hand, WF_HSLIDE,1000,0,0,0);
					invid();
					hs_pos = 1000;
				}
				break;
			}
			break;

		case WM_VSLID:
			if (msgbuff[3] == w_hand && msgbuff[4] != vs_pos)
			{	if (vs_pos  == 0)
				{	vs_pos = 1000;
					Blit(0);
					blit_change = 1;
					title_bar[23] = '\0';
					redraw_time();
				}
				else
				{	vs_pos = 0;
					Blit(1);
					blit_change = 1;
					title_bar[23] = ' ';
					redraw_time();
				}
				wind_set(w_hand, WF_VSLIDE,vs_pos,0,0,0);
			}
			break;

		case WM_HSLID:
	    	if ((msgbuff[3] == w_hand) && (msgbuff[4] != hs_pos))
			{	hs_pos = (hs_pos  == 0)?1000:0;
				invid();
				wind_set(w_hand, WF_HSLIDE,hs_pos,0,0,0);
			}
	    	break;

		case WM_NEWTOP:
		case WM_TOPPED:
			if (msgbuff[3] == w_hand)
			{	wind_set(w_hand,WF_TOP,0,0,0,0);
				timer = 0;
			}
	    	break;

		case AC_CLOSE:
			if((msgbuff[3] == menu_id) && (w_hand != NO_WINDOW))
			{
				wind_update(TRUE);

				v_clsvwk(handle);

				w_hand = NO_WINDOW;
				Dosound(osound);
				timer = 30000;
				wind_update(FALSE);
			}
			break;

		case WM_CLOSED:
			if(msgbuff[3] == w_hand)
			{	wind_close(w_hand);
				graf_shrinkbox(xdesk,ydesk,gl_wbox,gl_hbox,
					xold,yold,wold,hold);
				wind_delete(w_hand);

				if (!_app) v_clsvwk(handle);

				w_hand = NO_WINDOW;
				Dosound(osound);
				timer = 30000;
			}
			break;

		case WM_SIZED:
			sized = TRUE;	/* now fall through */
		case WM_MOVED:
			if(msgbuff[3] != w_hand) break;
			if(msgbuff[6] < MIN_WIDTH) msgbuff[6] = MIN_WIDTH;
			if(msgbuff[7] < MIN_HEIGHT) msgbuff[7] = MIN_HEIGHT;
			if(msgbuff[6] > maxw) msgbuff[6] = maxw;
			if(msgbuff[7] > maxh) msgbuff[7] = maxh;

			xold = msgbuff[4];
			yold = msgbuff[5];
			wold = msgbuff[6];
			hold = msgbuff[7];

			wind_set(w_hand,WF_CURRXYWH,msgbuff[4],
				msgbuff[5],msgbuff[6],msgbuff[7]);
			wind_get(w_hand,WF_WORKXYWH,&xwork,&ywork,&wwork,&hwork);
			if (sized)
			{	new_speed();
				sized = FALSE;
			}
			if (msgbuff[4] != xdesk || msgbuff[5] != ydesk ||
				msgbuff[6] !=maxw || msgbuff[7]!=maxh) fulled = FALSE;
			else fulled = TRUE;

		    break;

		case AC_OPEN:
		    if (msgbuff[4] == menu_id)
			{
				if (Kbshift(-1) & 2)
				{	boink_dial();
					break;
				}
				if (!rez) break;

				if (w_hand == NO_WINDOW)
				{	open_vwork();

					if (open_window() < 0)
					{
						v_clsvwk(handle);
						break;
					}
					new_speed();
				}
				else wind_set(w_hand,WF_TOP,0,0,0,0);

				timer = 0;
				redraw_time();
			}
			break;

		case WM_FULLED:
			if(fulled)
			{
				wind_calc(WC_WORK,WI_KIND,xold,yold,wold,hold,
						&xwork,&ywork,&wwork,&hwork);
				wind_set(w_hand,WF_CURRXYWH,xold,yold,wold,hold);
			}
			else
			{
				wind_calc(WC_BORDER,WI_KIND,xwork,ywork,wwork,hwork,
						&xold,&yold,&wold,&hold);
				newx = ((xold+maxw) < maxx) ? xold : (maxx - maxw);
				newy = ((yold+maxh) < maxy) ? yold : (maxy - maxh);
				wind_calc(WC_WORK,WI_KIND,newx,newy,maxw,maxh,
						&xwork,&ywork,&wwork,&hwork);
				wind_set(w_hand,WF_CURRXYWH,newx,newy,maxw,maxh);
			}
			fulled ^= TRUE;
			new_speed();
			break;

		} /* switch (msgbuff[0]) */

		if (event & MU_TIMER)
		{	if (w_hand != NO_WINDOW)
			{
				new_ball();
				if (timer == 0)	new_ball();
			}
			if (++loop_ctr > 25)
			{	loop_ctr = 0;
				redraw_time();
			}
		}

	} /* while (!_app || !done) */

}


/* move the ball to its new bounce position */

new_ball()
{	register int left,right,top,bottom;
	long new_base;

	left = bpxyarray[4];
	top = bpxyarray[5];
	right = bpxyarray[6];
	bottom = bpxyarray[7];

	bpxyarray[0] = 0;
	bpxyarray[1] = 0;
	bpxyarray[2] = 131;
	bpxyarray[3] = ball_ht;

	/* Restore the background picture to its virgin state	*/
	/* i.e.  remove the image of the ball from it.			*/

	vro_cpyfm(handle,3,bpxyarray,&oldpic,&windsource);

	/* calculate new ball x position */
	xpos += xspeed;

	if (xpos < 0)				/* ball hit left edge */
	{	bsound(SIDE_S);
		xspeed = -xspeed;
		spin_dir = -spin_dir;
		xpos = 0;


		/* check to see if anyone has changed the logical screen base */
		/* if so, redraw the entire window */

		new_base = (long)Logbase();
		screen_fdb.fd_addr = new_base;
		if (old_base != new_base)
		{	left = 0; top = 0;
			right = wwork; bottom = hwork;
		}
		old_base = new_base;
	}
	else if (xpos > (wwork - 101))		/* ball hit right edge */
	{	bsound(SIDE_S);
		xspeed = -xspeed;
		xpos = (wwork - 101);
	}


	/* change vertical ball speed to simulate gravity */
	yspeed += accel;

	/* calculate new ball vertical position */
	ypos += yspeed;

	if (ypos < 0)				/* ball hit top of window */
	{	if (hwork > (ball_ht + 1)) bsound(TOP_S);
		yspeed = -yspeed;
		ypos = 0;
		rebound = 1;
	}
	else if (ypos > (hwork - vert_fudge))	/* ball hit bottom of window */
	{	if (hwork > (ball_ht + 1)) bsound(BOT_S);
		oyspeed += rebound;
		if (oyspeed >= 0)
		{	oyspeed = 0;
			rebound = -4;
		}
		yspeed = oyspeed;
		ypos = (hwork - vert_fudge);
	}


	/* rotate the ball by selecting a new ball image to blit */
	/* we have an image of the ball in 6 different stages of rotation */

	ball_num += spin_dir;
	if (ball_num >= 6) ball_num = 0;
	else if (ball_num < 0) ball_num = 5;

	bpxyarray[0] = 102 * ball_num;
	bpxyarray[2] = 102 * (ball_num+1);
	bpxyarray[4] = xpos;
	bpxyarray[5] = ypos;
	bpxyarray[6] = xpos+131;
	bpxyarray[7] = ypos+ball_ht;

	spxyarray[4] = xpos;
	spxyarray[5] = ypos;
	spxyarray[6] = xpos+131;
	spxyarray[7] = ypos+ball_ht;

	if (xpos < left) left = xpos;
	if (ypos < top) top = ypos;
	if (bpxyarray[6] > right) right = bpxyarray[6];
	if (bpxyarray[7] > bottom) bottom = bpxyarray[7];

	/* save the area of the background picture we will trash when	*/
	/* we blit the ball image into it */

	vro_cpyfm(handle,3,&bpxyarray[4],&windsource,&oldpic);

	/* blit the ball mask into the background picture which cuts a 	*/
	/* black hole in the picture and creates the ball shadow effect */

	vro_cpyfm(handle,7,spxyarray,&ballsource,&windsource);
	bpxyarray[6] = xpos+100;

	/* blit the ball into the black hole we just cut out of the picture */
	/* with the mask */

	vro_cpyfm(handle,4,bpxyarray,&ballsource,&windsource);

	bpxyarray[6] = xpos+131;


	/* Whew! we are now done creating the ball image in our background	*/
	/* buffer. Now we must blit the updated picture into the boink		*/
	/* window. The area we must update is the smallest rectangle that	*/
	/* will enclose both the ball's old position and its new one. This	*/
	/* technique will erase the old ball and draw in the new one		*/
	/* without any flickering of the image. Note also that the area		*/
	/* we update must be clipped to our windows rectangle list so that	*/
	/* we don't trash the contents of another window.					*/

	if (fast_n_top)
		/* Draw the window without going through the AES for speed! */
		fast_redraw(left+xwork,top+ywork,right - left + 1,bottom - top + 1);
	else
		/* Use the rectangle list to draw the window in an orderly fashion */
		do_redraw(left+xwork,top+ywork,right - left + 1,bottom - top + 1);
}


/* output a bouncing ball sound with a pitch specified by val */

bsound(val)
int val;
{	int test;
	wind_get(w_hand,WF_TOP,&test,&ret,&ret,&ret);
	if (test == w_hand)
	{	*(sound + 1) = val;
		Dosound(sound);
		timer = 0;
	}
	else timer = 1;
}


/* calculate a vertical launch speed which will get the ball almost to	*/
/* the top of the window before gravity pulls it back down. Little bit	*/
/* of physics lesson here...											*/

new_speed()
{	oyspeed = yspeed = (-1 * root(2 * accel * (hwork - ball_ht)));
	xpos = 1;
	ypos = hwork - vert_fudge;
	if (xspeed < 0) xspeed = -xspeed;
}


/* Yuck! I iterate through a loop to find the integer square root */
/* of a number. */

int root(num)
int num;
{	register int high = 60;
	register int low = 1;
	register int mid;
	mid = 30;

	do
	{	if ((mid * mid) > num) high = mid;
		else if ((mid * mid) == num) return mid;
		else low = mid;
		mid = (high + low) >> 1;
	} while ((high - low) > 1);
	return mid;
}


/* redraw the time, free memory, and blitter status if any have changed */

redraw_time()
{int no_change = TRUE;
 if (w_hand == NO_WINDOW) return;
 if (first_open <= 0)
 {	if (fetch_time() == 0) no_change = FALSE;
	if (fetch_mem() == 0) no_change = FALSE;
	if ((blit_change == 1) || ((!(Blit(-1) & 1)) != (vs_pos != 0)))
	{	if (bltr_inst || blit_change) no_change = FALSE;
		if ((!blit_change) && bltr_inst)
		{	if (vs_pos == 0)
			{	vs_pos = 1000;
				title_bar[23] = '\0';
			}
			else
			{	vs_pos = 0;
				title_bar[23] = ' ';
			}
			wind_set(w_hand, WF_VSLIDE,vs_pos,0,0,0);
		}
		blit_change = FALSE;
	}
	if (no_change) return;
	HIDE_MOUSE;
	wind_set(w_hand,WF_NAME,title_bar,0,0);
	SHOW_MOUSE;
 }
 else
 {	if (first_open > 2)
	{	HIDE_MOUSE;
		wind_set(w_hand,WF_NAME,intro1,0,0);
		SHOW_MOUSE;
	}
 	else
	if (first_open == 1)
	{	HIDE_MOUSE;
		wind_set(w_hand,WF_NAME,intro2,0,0);
		SHOW_MOUSE;
	}
	first_open --;
 }
}

fetch_time()
{unsigned int time;
 char min,hour;

	time = Tgettime();
	min = (time >> 5) & 0x3F;
	if (min == old_min) return -1;
		else old_min = min;
	hour = (time >> 11) & 0x1F;
	if (hour > 12) hour -= 12;
	if (hour > 9) title_bar[2] = '1';
		else title_bar[2] = ' ';
	title_bar[3] = (char)(hour % 10) + '0';
	title_bar[5] = (char)(min / 10) + '0';
	title_bar[6] = (char)(min % 10) + '0';
	return 0;
}

fetch_mem()
{long f_mem;
 if ((f_mem = Malloc(-1L)) == old_mem_amt) return -1;
 old_mem_amt = f_mem;
 prinl(f_mem);
 return 0;
}


/* I write my own long integer output. You could do the same thing	*/
/* with sprintf(), but the code would be much larger.				*/

prinl(num)
register long num;
{
	register int ndx = 16;

	/* make sure the number is in the acceptable range */

	if (num < 0L) num = 0L;
	else if (num > 9999999L) num = 9999999L;

	/* if number is zero, be sure to show one digit */
	if (!num) title_bar[ndx--] = '0';

	/* build the number in reverse order */
	while (num)
	{
		title_bar[ndx--] = (num % 10) + '0';
		num /= 10;
	}

	/* fill with leading spaces */
	while (ndx > 9) title_bar[ndx--] = ' ';
}


/* invert screen colors on medium or high res monitor */

invid()
{	register int temp;

	switch(rez)
	{
		case 1:
			temp = (int)Setcolor(0,-1);
			Setcolor(0,(int)Setcolor(3,-1));
			Setcolor(3,temp);
			break;
		case 2:
			Setcolor(0,((Setcolor(0,-1) & 0x777) == 0) ? 0x777 : 0);
			break;
	}
}

wait()
{	long i;
	for (i = 0; i < 320000L; i++);
}


/* put up dialog box */

boink_dial()
{
	int xchoice,dial_x,dial_y,dial_w,dial_h;

	form_center(dial,&dial_x,&dial_y,&dial_w,&dial_h);
	wind_update(TRUE);
	objc_draw(dial,0,3,dial_x,dial_y,dial_w,dial_h);
	xchoice = (form_do(dial, 0) & 0x7fff);
	wind_update(FALSE);
	dial[xchoice].ob_state &= ~SELECTED;

	/* accessory only */
	if (xchoice == DIALLOAD) load_pic();

	form_dial(FMD_FINISH,0,0,10,10,dial_x,dial_y,dial_w,dial_h);
}


/* change an object array from character coordinates to pixel coordinates */

convert_resource(p)
register OBJECT *p;
{	register OBJECT *p2 = p;
	register int ndx = 0;

	for (;;)
	{	rsrc_obfix(p,ndx);
		if (p2->ob_flags & 0x20) break;
		ndx++;
		p2++;
	}
}


/* redraw the ball as fast as possible without going through the AES	*/
/* If you use either the evnt_multi of vro_copyfm calls the AES is		*/
/* invoked and other GEM tasks (like desk accessories) will be run.		*/
/* This is good for a nice Gem program, but it slows you down...		*/

fast_mode()
{
	register int count;
	int test;

	if (w_hand == NO_WINDOW) return;
	wind_get(w_hand,WF_TOP,&test,&ret,&ret,&ret);
	if (test == w_hand)
	{	wind_update(TRUE);
		fast_n_top = TRUE;
	}

	wind_set(w_hand,WF_NAME," Both mouse keys to resume ",0,0);
	while (((*(lineaptr-174)) & 0x300) != 0x300)
	{
		count = 0;
		while (++count < 5) new_ball();
	}
	if (fast_n_top) wind_update(FALSE);
	fast_n_top = FALSE;
	HIDE_MOUSE;
	wind_set(w_hand,WF_NAME,title_bar,0,0);
	SHOW_MOUSE;
	redraw_time();
}

fast_redraw(xc,yc,wc,hc)
register int xc,yc,wc,hc;
{
int pxyarray[8];
int x_pos, y_pos, overrun;

	x_pos = *(lineaptr - 301);
	y_pos = *(lineaptr - 300);
	if ((xc < (x_pos+20)) && ((xc+wc) > (x_pos - 20)) &&
	   (yc < (y_pos+20)) && ((yc+hc) > (y_pos - 20)))
	{	HIDE_MOUSE
		hidden = TRUE;
	}
	if ((xc+wc) > wdesk) wc = wdesk - xc;
	if ((overrun = ((xwork + wwork) - (xc+wc))) < 0)
		wc += overrun;
	if ((yc+hc) > maxy) hc =maxy-yc;
	if (wc <=0 || hc <=0) return;

	pxyarray[0] = xc - xwork;
	pxyarray[1] = yc - ywork;
	pxyarray[2] = xc - xwork + wc - 1;
	pxyarray[3] = yc - ywork + hc - 1;
	pxyarray[4] = xc;
	pxyarray[5] = yc;
	pxyarray[6] = xc + wc - 1;
	pxyarray[7] = yc + hc - 1;

	vro_cpyfm(handle,3,pxyarray,&windsource,&screen_fdb);

	if (hidden)
	{	hidden = FALSE;
		SHOW_MOUSE
	}
}

/*********************************************
INIT_FDB() - init screen memory form definition block.
In order to blit from one rectangle (our background picture)
to another (the screen) we need to to give gem a memory form
definition block for each rectangle. This structure describes the
location of the rectangle, its width, height, and number of bit
planes. For the background picture, the parameters are hard wired
to the size of a Degas picture. We must ask gem to tell us the screen
parameters so that the program will work on any monitor including
large screen monitors.
*********************************************/
init_fdb()
{
	register MFDB *fdbp = &screen_fdb;
	register int temp;

	fdbp->fd_addr	= Logbase();
	fdbp->fd_w	= work_out[0] + 1;
	fdbp->fd_h	= work_out[1] + 1;
	fdbp->fd_wdwidth	= fdbp->fd_w/16;
	fdbp->fd_stand	= 0;

	switch(work_out[13])
	{
		case 16: temp = 4; break;
		case 08: temp = 3; break;
		case 04: temp = 2; break;
		default: temp = 1; break;
	}
	fdbp->fd_nplanes = temp;
}


/* Allow the user access to a Gem file selector to pick a new */
/* background picture */

load_pic()
{	register int i, fd;
	int button;
	char complete[80];
	int revblit[8];

	wind_update(TRUE);
	fsel_input(path,name,&button);
	if (!button) goto end;

	i = strlen(path) - 1;
	while (i > 0 && (path[i] != '\\') && (path[i] != ':'))
		i--;
	strcpy(complete,path);
	strcpy(&complete[i+1],name);

	fd = Fopen(complete,0);
	if (fd <= 0) goto end;

	Fseek(34L,fd,0);
	Fread(fd,27520L,warray);
	Fclose(fd);

	/* blit from buffer to ball save buffer */
	for (i=0; i<4; i++)	revblit[i] = bpxyarray[i+4];
	revblit[4] = 0;
	revblit[5] = 0;
	revblit[6] = 131;
	revblit[7] = ball_ht;

	/* normally blit would req open workstation... */
	vro_cpyfm(handle,3,revblit,&windsource,&oldpic);

	if (w_hand != NO_WINDOW) do_redraw(xwork,ywork,wwork,hwork);
end:
	wind_update(FALSE);
}


/* Handy C string functions */

strlen(a)
register char *a;
{	register int n = 0;
	while (*a++) n++;
	return n;
}

strcpy(a,b)
register char *a, *b;
{	while (*a++ = *b++);
}

strcat(a,b)
register char *a, *b;
{	while (*a) a++;
	while (*a++ = *b++);
}
