/********************************************
*		Boinkout program and acc			*
*		Samuel Streeper 90/02/26			*
*											*
*	Copyright 1990 by Antic Publishing Inc.	*
*											*
* "what to do with all that wasted			*
*	CPU time Part III"						*
********************************************/

/* edited with tabsize = 4 */

extern int _app;


/*	Compiler notes:		*/
/*	---------------		*/
/*	This code compiles with Laser C and Mark Williams C					*/
/*	version 2.0. It shouldn't be tough to get it to compile with other	*/
/*	things... 															*/
/*	There are just a few things to look out for when porting this		*/
/*	between compilers:													*/

/*	The blitter routines require a structure known as a memory form		*/
/*	descriptor block. Laser C and Alcyon C call this structure a		*/
/*	MFDB, while MWC calls this a FDB.									*/

/*	Boinkout needs to know the address of the line-a variables.			*/
/*	Megamax does not supply a function to get this address, while		*/
/*	Laser C and MWC do, but the function has a different name. Further-	*/
/*	more, the MWC supplied function returns the wrong address with		*/
/*	tos 1.4. Consequently, I use inline assembly for laser,				*/
/*	and a simple assembly function in MWC.								*/

/*	This code will work as both a desk accessory or a program if you	*/
/*	link it with the proper startup module. The default Laser startup	*/
/*	module works ok. I recommend linking to the laser or				*/
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

#include <obdefs.h>
#include <gemdefs.h>
#include <osbind.h>
#include "boinkout.h"

#if MWC
#define MFDB FDB
#define Kbshift(a) Getshift(a)
#endif

int n_redraws;
RECT region[MAX_ANI];		/* a list of redraw regions */
RECT tregion [MAX_ANI];		/* temporary clipping region */
BALL_STRUCT bs[MAX_BALLS];

int num_balls;

char null[] = "";

/* The following arrays of gem OBJECTS were dumped from a resource	*/
/* file using the resource dumper from the START magazine			*/
/* October 89 issue. By including the resource file in the code		*/
/* we don't need to load it in at run-time (which is a bad idea		*/
/* for desk accessories...)											*/

#define ABTBOINK 7
#define WINDOPEN 16
#define LOADPIC 17
#define FAST 18
#define FILEQUIT 20

OBJECT menu[] = {
-1,1,5,G_IBOX,0,0,0x0L,0,0,0x50,0x19,
5,2,2,G_BOX,0,0,0x1100L,0,0,0x50,0x201,
1,0x3,0x4,G_IBOX,0,0,0x0L,2,0,0xC,0x301,
4,-1,-1,G_TITLE,0,0," Desk ",0,0,6,0x301,
2,-1,-1,G_TITLE,0,0," File ",6,0,6,0x301,
0,6,0xF,G_IBOX,0,0,0x0L,0,0x301,0x50,0x13,
0xF,0x7,0xE,G_BOX,0,0,0xFF1100L,2,0,0x14,8,
8,-1,-1,G_STRING,0,0,"  About BoinkOut...",0,0,0x14,1,
9,-1,-1,G_STRING,0,0x8,"--------------------",0,1,0x14,1,
0xA,-1,-1,G_STRING,0,0,null,0,2,0x14,1,
0xB,-1,-1,G_STRING,0,0,null,0,3,0x14,1,
0xC,-1,-1,G_STRING,0,0,null,0,4,0x14,1,
0xD,-1,-1,G_STRING,0,0,null,0,5,0x14,1,
0xE,-1,-1,G_STRING,0,0,null,0,6,0x14,1,
0x6,-1,-1,G_STRING,0,0,null,0,7,0x14,1,
5,0x10,0x14,G_BOX,0,0,0xFF1100L,8,0,0xF,5,
0x11,-1,-1,G_STRING,0,0,"  Open Window",0,0,0xF,1,
0x12,-1,-1,G_STRING,0,0,"  Load Pic...",0,1,0xF,1,
0x13,-1,-1,G_STRING,0,0,"  High Speed",0,2,0xF,1,
0x14,-1,-1,G_STRING,0,8,"---------------",0,3,0xF,1,
0xF,-1,-1,G_STRING,0x20,0,"  Quit",0,4,0xF,1
};

TEDINFO ted0 = {
	"by Samuel Streeper",
	null,
	null,
	5, 6, 0, 0x1180, 0, 0xff, 19, 1		};

TEDINFO ted1 = {
	"Runs as .prg or .acc",
	null,
	null,
	5, 6, 0, 0x1180, 0, 0xff, 21, 1		};

#define DIALOK 10
#define DIALLOAD 11

OBJECT dial[] = {
-1,1,1,G_BOX,0,0x10,0x11142L,0,0,39,20,
0,2,11,G_BOX,0,0x20,0xff1100L,1,1,37,18,
3,-1,-1,G_STRING,0,0,"BoinkOut!",13,1,9,1,
4,-1,-1,G_TEXT,0,0,&ted0,3,2,14,1,
5,-1,-1,G_TEXT,0,0,&ted1,19,2,15,1,
6,-1,-1,G_STRING,0,0,"COPYRIGHT  1990",10,4,15,1,
7,-1,-1,G_STRING,0,0,"by Antic Publishing, Inc.",6,5,25,1,
8,-1,-1,G_STRING,0,0,"Antic Publishing",9,8,16,1,
9,-1,-1,G_STRING,0,0,"544 Second Street",9,9,17,1,
10,-1,-1,G_STRING,0,0,"San Francisco, CA 94107",6,10,23,1,
11,-1,-1,G_BUTTON,0x7,0,"OK",13,13,10,2,
1,-1,-1,G_BUTTON,0x65,0,"Load Pic...",9,16,18,1,
};

#define WI_KIND	(MOVER|CLOSER|NAME)

extern int	gl_apid;

extern int monoballs[], monobricks[], mono_perm_bricks[], monopaddle[];
extern int mono_digits[], mono_fuji[], monofuji_mask[], mono_eye[];
extern int mono_leveltext[], mono_twobrick[], invis, magic_bottom;
extern int medballs[], medbricks[], med_perm_bricks[], medpaddle[];
extern int med_digits[], med_fuji[], medfuji_mask[], med_eye[];
extern int med_leveltext[], med_twobrick[];

long old_base;

int	gl_hchar, gl_wchar, gl_wbox, gl_hbox;	/* sizes of system characters */

int	win_kind = WI_KIND;
int	menu_id, paddle_x, paddle_y, pad_y_min, pad_y_max, pad_y_top;

int	phys_handle;	/* physical workstation handle */
int	handle;			/* virtual workstation handle */
int	w_hand;			/* window handle */

int	xdesk,ydesk,hdesk,wdesk;
int	xold,yold,hold,wold;
int	xwork,ywork,hwork,wwork;	/* desktop and work areas */

int	msgbuff[8];					/* event message buffer */
int	ret;

extern char brickmask[][63];
int level;

extern int mode;
int ani_count, num_bricks, cheat, fastmode;
int	fulled;						/* current state of window */
int	ball_ht = 21;
int win_ht = HEIGHT;
int max_xspeed = 8;
int min_yspeed = -8;
int planes;			/* number of bit planes */

int btop = 44;		/* actual top of block of bricks */
int btopm = 39;		/* measured top of bricks */
int bth = 26;		/* total brick height, including space */
int bh = 16;		/* brick height */
int block_bot = 221;	/* block_top = btopm + 7 * bth */
int bleft = 6;
int btw = 48;
int pady_offset = 25;
int max_pad_dy = 16;
int pad_ht = 19;
int fuji_ht = 13;
int fmask_ht = 15;
int text_ht = 12;

int	*lineaptr;
char brickcount[63];

#if MWC
extern int *a_init();
#endif

char title_bar[] = "  BoinkOut!  ";

long score, old_score, bonus_life, old_bonus;
int lives, old_lives;

int	maxx, maxy, maxw, maxh;
int	timer, ttimer, event_kind = MU_MESAG;

extern int int_in[], addr_in[], control[], int_out[];

int	contrl[12];
int	intin[128];
int	ptsin[128];
int	intout[128];
int	ptsout[128];

int work_in[11];
int work_out[57];

int ballarray[8];			/* ball blit array */
int paddlearray[8];			/* paddle blit array */
int brickarray[8];

/* These buffers are big enough for a 440 x 362 pixel image */
/* (slightly bigger than they need to be...) */
char warray[20272];
char parray[20272];

MFDB ballsource = {0L,144,20,144/16,0,1,0,0,0};
MFDB paddlesource = {0L,64,19,64/16,0,1,0,0,0};
MFDB bricksource = {0L,192,16,192/16,0,1,0,0,0};
MFDB twobricksource = {0L,192,16,192/16,0,1,0,0,0};
MFDB permbricksource = {0L,192,16,192/16,0,1,0,0,0};
MFDB windsource = {0L,448,344,448/16,0,1,0,0,0};
MFDB pic_buf = {0L,448,344,448/16,0,1,0,0,0};
MFDB digitsource = {0L,5*16,12,5,0,1,0,0,0};
MFDB fujisource = {0L,7*16,13,7,0,1,0,0,0};
MFDB fmasksource = {0L,7*16,15,7,0,1,0,0,0};
MFDB eyesource = {0L,144,20,144/16,0,1,0,0,0};
MFDB levelsource = {0L,3*16,12,3,0,1,0,0,0};
MFDB screen_fdb;

char path[80], name[14];


/* the sound string is the yamaha sound chip parameter for the bouncing		*/
/* ball sound. The osound array resets the modified sound chip registers	*/
/* to their old values so that key click sounds will be normal when the		*/
/* program terminates.														*/

char sound[] =	{
	0,0xf0,1,0x0f, 2,0xff, 3,0x0f, 4,0x00, 5,0, 6,0x1f, 7,0xdc,
	8,0x10,9,0x10,10,0x10,11,0x00,12,25,13,0,0xff,0
	};

int appear[] = {
	0x040,0x102,0x242,0x302,0x400,0x500,0x61f,0x7dc,
	0x810,0x910,0xA10,0xB00,0xC15,0xD0f,0xFF00
	};

/* osound restores registers 9 and 10 for normal key click */
char osound[] = { 9, 0, 10, 0, 0xff, 0	};

				/*	 012345678901234567890123456	*/
char *no_picture =	"Unable to open BOINKOUT.PI3 Degas picture\r\n";

			/*   0 123456 789012345678	*/
char *pic1 =	"\\boink\\boinkout.pi3";
char *pic2 =	"\\boink\\boink.pi3";

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

	if (Kbshift(-1) & 1) cheat = TRUE;
	else cheat = FALSE;

	wind_set(w_hand, WF_NAME,title_bar,0,0);
	graf_growbox(xdesk,ydesk,gl_wbox,gl_hbox,xold,yold,wold,hold);
	wind_open(w_hand,xold,yold,wold,hold);
	wind_get(w_hand,WF_WORKXYWH,&xwork,&ywork,&wwork,&hwork);

	if (lives <= 0) new_game();
	restart_level();

	event_kind = MU_MESAG | MU_TIMER;
	ttimer = timer = 0;
	screen_fdb.fd_addr = (long)Logbase();

	return 0;
}

int hidden;		/* = FALSE */
/****************************************************************/
/* find and redraw all clipping rectangles			*/
/****************************************************************/
do_redraw()
{
	register RECT *p;
	RECT t;
	register int i;
	int array[8];
	int x_pos,y_pos, mxmin, mxmax, mymin, mymax;

	if (fastmode)
	{
		fast_redraw();
		return;
	}

	x_pos = *(lineaptr - 301);
	y_pos = *(lineaptr - 300);
	if (*(lineaptr - 298)) ttimer = 200;
	else ttimer = timer;

	mxmin = x_pos - 20;
	mxmax = x_pos + 20;
	mymin = y_pos - 20;
	mymax = y_pos + 20;

	wind_update(TRUE);

	/* check all redraw regions for mouse interference */
	for (i=0; i<n_redraws; i++)
	{
		p = &region[i];
		if ((p->x < mxmax) && ((p->x + p->w) > mxmin) &&
			(p->y < mymax) && ((p->y + p->h) > mymin))
		{	HIDE_MOUSE;
			hidden = TRUE;
			break;
		}
	}

	/* clip all regions to screen size */
	for (i=0; i<n_redraws; i++)
	{
		p = &region[i];
		if ((p->x+p->w) > wdesk) p->w = wdesk - p->x;
		if ((p->y+p->h) > maxy) p->h =maxy-p->y;
	}

	wind_get(w_hand,WF_FIRSTXYWH,&t.x,&t.y,&t.w,&t.h);

	while (t.w && t.h)
	{
		for (i=0; i<n_redraws; i++)
		{
			p = &tregion[i];
			*p = t;				/* copy this window rect */

			if (rc_intersect(&region[i],p))
			/* tregion[i] clipped to my redraw region */
			{
				array[0] = p->x - xwork;
				array[1] = p->y - ywork;
				array[2] = p->x - xwork + p->w - 1;
				array[3] = p->y - ywork + p->h - 1;
				array[4] = p->x;
				array[5] = p->y;
				array[6] = p->x + p->w - 1;
				array[7] = p->y + p->h - 1;

				vro_cpyfm(handle,3,array,&windsource,&screen_fdb);
			}
		}
		wind_get(w_hand,WF_NEXTXYWH,&t.x,&t.y,&t.w,&t.h);
	}

	if (hidden)
	{	hidden = FALSE;
		SHOW_MOUSE;
	}

	wind_update(FALSE);
	n_redraws = 0;
}

/********************************/
/*		MAIN() 					*/
/********************************/
main()
{
	register BALL_STRUCT *p;
	register int temp, dw, dh;
	int fd, wx,wy,ww,wh, i;


#if LASER
	asm{	dc.w 0xa000
			move.l D0,lineaptr
	   }
#else
#if MWC
	lineaptr = a_init();
#endif						/* mwc */
#endif						/* laser */

	planes = *lineaptr;

	if (planes == 2)		/* color monitor */
	{
		ballsource.fd_nplanes = 2;
		paddlesource.fd_nplanes = 2;
		bricksource.fd_nplanes = 2;
		twobricksource.fd_nplanes = 2;
		permbricksource.fd_nplanes = 2;
		windsource.fd_nplanes = 2;
		pic_buf.fd_nplanes = 2;
		digitsource.fd_nplanes = 2;
		fujisource.fd_nplanes = 2;
		fmasksource.fd_nplanes = 2;
		eyesource.fd_nplanes = 2;
		levelsource.fd_nplanes = 2;

		windsource.fd_h = 172;
		ball_ht = 10;
		win_ht = HEIGHT/2;
		temp = '2';
		no_picture[26] = temp;
		pic1[18] = temp;
		pic2[15] = temp;
		min_yspeed = -4;
		btop = 22;
		btopm = 20;
		bth = 13;
		bh = 8;
		block_bot = 111;
		pady_offset = 12;
		max_pad_dy = 8;
		pad_ht = 10;
		fuji_ht = 6;
		fmask_ht = 8;
		text_ht = 6;

		pad_y_min = 122;
		pad_y_max = 159;

		ballsource.fd_addr = (long)medballs;
		paddlesource.fd_addr = (long)medpaddle;
		bricksource.fd_addr = (long)medbricks;
		twobricksource.fd_addr = (long)med_twobrick;
		permbricksource.fd_addr = (long)med_perm_bricks;
		digitsource.fd_addr = (long)med_digits;
		fujisource.fd_addr = (long)med_fuji;
		fmasksource.fd_addr = (long)medfuji_mask;
		eyesource.fd_addr = (long)med_eye;
		levelsource.fd_addr = (long)med_leveltext;
	}
	else			/* mono monitor */
	{
		ballsource.fd_addr = (long)monoballs;
		paddlesource.fd_addr = (long)monopaddle;
		bricksource.fd_addr = (long)monobricks;
		twobricksource.fd_addr = (long)mono_twobrick;
		permbricksource.fd_addr = (long)mono_perm_bricks;
		digitsource.fd_addr = (long)mono_digits;
		fujisource.fd_addr = (long)mono_fuji;
		fmasksource.fd_addr = (long)monofuji_mask;
		eyesource.fd_addr = (long)mono_eye;
		levelsource.fd_addr = (long)mono_leveltext;

		pad_y_min = 247;
		pad_y_max = 323;
	}

	windsource.fd_addr = (long)warray;
	pic_buf.fd_addr = (long)parray;

/*	Find the degas picture and load it in	*/

	fd = Fopen(pic1 + 7,0);
	if (fd <= 0) fd = Fopen(pic1,0);
	if (fd <= 0) fd = Fopen(pic2 + 7,0);
	if (fd <= 0) fd = Fopen(pic2,0);

	if (fd > 0) do_load(fd);
	else
	{	Cconws(no_picture);
		wait(2);
	}


	appl_init();

	if (!_app) menu_id=menu_register(gl_apid,"  BoinkOut! ");

	phys_handle=graf_handle(&gl_wchar,&gl_hchar,&gl_wbox,&gl_hbox);

	wind_get(0, WF_WORKXYWH, &xdesk, &ydesk, &wdesk, &hdesk);
	wind_calc(1,win_kind,xdesk,ydesk,wdesk,hdesk,&wx,&wy,&ww,&wh);
	dw = wdesk - ww;
	dh = hdesk - wh;

	xold = xdesk + (wdesk - WIDTH) / 2;
	yold = ydesk + (hdesk - win_ht) / 3;
	wold = WIDTH;
	hold = win_ht;

	maxx = xdesk + wdesk;
	maxy = ydesk + hdesk;

	path[0] = Dgetdrv() + 'A';
	path[1] = ':';
	Dgetpath(path+2,Dgetdrv() + 1);
	strcat(path,"\\*.PI?");
	strcpy(name,null);

	w_hand=NO_WINDOW;


	if (_app)
	{
		open_vwork();
		dial[DIALLOAD].ob_flags = (LASTOB | HIDETREE);
		dial[DIALOK].ob_height = 3;

		graf_mouse( ARROW, 0L);

		convert_resource(menu);

		menu_bar(menu, 1);	/* display the menu */
	}

	convert_resource(dial);

	multi();			/* accessory will not return, program will */

	Dosound(osound);	/* fix key click sound */

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

	if (_app && (planes == 1 || planes == 2))
	{
		if (open_window() < 0) return;
	}


/*	The accessory will loop forever, the program loops until	*/
/*	the done variable is set to TRUE.							*/

	while ((!_app) || !done)
	{

		event = evnt_multi(event_kind,
			1,0,0,
			0,0,0,0,0,
			0,0,0,0,0,
			msgbuff,ttimer,0,&ret,&ret,&ret,&ret,&ret,&ret);


		if (event & MU_MESAG) switch (msgbuff[0])
		{

		case MN_SELECTED:

		/* menu functions, program only */

			switch(msgbuff[4])
			{

			case ABTBOINK:	boink_dial();
					break;

			case WINDOPEN:
				if (planes != 1 && planes != 2) break;
				if (w_hand != NO_WINDOW)
				{	wind_set(w_hand,WF_TOP,0,0,0,0);
					if (lives <= 0)
					{
						new_game();
						restart_level();
						event_kind = MU_MESAG | MU_TIMER;
					}
				}
				else open_window();
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
			add_region(msgbuff[4],msgbuff[5],msgbuff[6],msgbuff[7]);
			do_redraw();
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
				event_kind = MU_MESAG;
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
				event_kind = MU_MESAG;
			}
			break;

		case WM_MOVED:
			if(msgbuff[3] != w_hand) break;

			xold = msgbuff[4];
			yold = msgbuff[5];

			wind_set(w_hand,WF_CURRXYWH,msgbuff[4],
				msgbuff[5],wold,hold);
			wind_get(w_hand,WF_WORKXYWH,&xwork,&ywork,&wwork,&hwork);

		    break;

		case AC_OPEN:
		    if (msgbuff[4] == menu_id)
			{
				if (Kbshift(-1) & 2)
				{	boink_dial();
					break;
				}
				if (planes != 1 && planes != 2) break;

				if (w_hand == NO_WINDOW)
				{	open_vwork();

					if (open_window() < 0)
					{
						v_clsvwk(handle);
						break;
					}
				}
				else
				{	wind_set(w_hand,WF_TOP,0,0,0,0);
					if (lives <= 0)
					{
						new_game();
						restart_level();
						event_kind = MU_MESAG | MU_TIMER;
					}
				}
			}
			break;

		} /* switch (msgbuff[0]) */

		if (event & MU_TIMER)
		{	if (w_hand != NO_WINDOW)
			{
				new_ball();
			}
		}

	} /* while (!_app || !done) */

}

long get_time()
{
	return *((long *)0x4ba);
}

/* output a bouncing ball sound */
bsound(pitch)
{	int test;

	*(sound + 13) = pitch;
	Dosound(sound);

	wind_get(w_hand,WF_TOP,&test,&ret,&ret,&ret);

	if (test == w_hand) timer = 0;
	else timer = 1;
}


wait(sec)
{	long alarm;

	alarm = Supexec(get_time) + (200 * sec);
	while (Supexec(get_time) < alarm);
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
	fdbp->fd_w		= work_out[0] + 1;
	fdbp->fd_h		= work_out[1] + 1;
	fdbp->fd_wdwidth= fdbp->fd_w/16;
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

	do_load(fd);

	if (w_hand != NO_WINDOW)
	{
		if (lives <= 0) new_game();
		restart_level();
		event_kind = MU_MESAG | MU_TIMER;
	}

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

bncpy(a,b,n)
register char *a, *b;
register int n;
{	while (n--) *a++ = *b++;
}

restart_level()
{
	register BALL_STRUCT *p;
	register int x, y, image, ndx;
	int i, ltemp = level % LEVELS;

	if (w_hand == NO_WINDOW) return;

	magic_bottom = 0;
	score = old_score;
	lives = old_lives;
	bonus_life = old_bonus;
	invis = FALSE;

	clear_areas();

	num_bricks = 0;
	bncpy(warray,parray,20272);

	show_lives();
	show_level();
	show_score();

	brickarray[1] = 0;
	brickarray[3] = bh-1;

	ndx = 0;
	for (y=0; y<7; y++)
	{
		for (x=0; x < 9; x++)
		{
			brickarray[0] = 0;
			brickarray[2] = 43;
			brickarray[4] = bleft + x * btw;
			brickarray[5] = btop + y * bth;
			brickarray[6] = brickarray[4] + 43;
			brickarray[7] = brickarray[5] + bh - 1;

			switch(brickmask[ltemp][ndx])
			{
				case -1:		/* permanent */
					vro_cpyfm(handle,3,brickarray,&permbricksource,&windsource);
					break;

				case 1:			/* normal */
					num_bricks++;
					break;

				case 2:			/* magic */
					vro_cpyfm(handle,4,brickarray,&bricksource,&windsource);
					vro_cpyfm(handle,7,brickarray,&twobricksource,&windsource);
					num_bricks++;
					break;

				case 3:
				case 4:
				case 5:
				case 6:
					num_bricks++;
					break;
			}
			ndx++;
		}
	}

	n_redraws = 0;
	add_region(xwork,ywork,wwork,hwork);
	do_redraw();

	evnt_timer(150,0);
	Dosound(appear);
	evnt_timer(250,0);

	for (image = 3; image >= 0; image--)
	{
		ndx = 0;
		brickarray[0] = image * btw;
		brickarray[2] = brickarray[0] + btw - 1;

		for (y=0; y<7; y++)
		{
			for (x=0; x < 9; x++)
			{
				brickarray[4] = bleft + x * btw;
				brickarray[5] = btop + y * bth;
				brickarray[6] = brickarray[4] + btw - 1;
				brickarray[7] = brickarray[5] + bh - 1;

				switch(brickmask[ltemp][ndx++])
				{
					case 1:
						vro_cpyfm(handle,7,brickarray,&bricksource,&windsource);
						break;
				case 3:
				case 4:
				case 5:
				case 6:
					if (image > 0) vro_cpyfm(handle,7,
						brickarray,&twobricksource,&windsource);
					break;
				}
			}
		}
		add_region(xwork,ywork,wwork,hwork);
		do_redraw();
	}
	evnt_timer(500,0);

	ani_count = 0;
	paddle_x = 0;
	paddle_y = pad_y_max;
	paddlearray[4] = 0;
	paddlearray[5] = pad_y_max;
	paddlearray[6] = 52;
	paddlearray[7] = paddlearray[5] + pad_ht - 1;

	num_balls = 0;

	if (cheat)
	{
		for (x=0; x<3; x++)
			add_ball(0,pad_y_min - ball_ht,max_xspeed-x,-min_yspeed, TRUE);
	}
	else add_ball(0,pad_y_min - ball_ht,2,2, FALSE);

	mode = BNORMAL;

	for (x=0; x < 63; x++) brickcount[x] = brickmask[ltemp][x];
}

add_region(x,y,w,h)
{
	register RECT *p;

	/* this should never happen... */
	if (n_redraws >= MAX_ANI) return;

	p = &region[n_redraws];
	p->x = x;
	p->y = y;
	p->w = w;
	p->h = h;
	n_redraws++;
}

new_game()
{
	lives = old_lives = 3;
	score = old_score = 0;
	bonus_life = old_bonus = BONUS;
	pad_y_top = pad_y_min;
	level = 0;
}

clear(x,y,w,h)
{
	int arr[8];

	arr[0] = arr[1] = 0;
	arr[2] = w;
	arr[3] = h;
	arr[4] = x;
	arr[5] = y;
	arr[6] = x + w - 1;
	arr[7] = y + h - 1;

	vro_cpyfm(handle,0,arr,&pic_buf,&pic_buf);
}
