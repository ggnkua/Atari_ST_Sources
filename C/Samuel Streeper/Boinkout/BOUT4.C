/********************************************
*		Bout4.c								*
*		Samuel Streeper 90/01/26			*
*											*
*											*
*	Copyright 1990 by Antic Publishing Inc.	*
*											*
*	Miscellaneous boinkout routines			*
*											*
********************************************/

/* edited with tabsize = 4 */

#include <obdefs.h>
#include <gemdefs.h>
#include <osbind.h>
#include "boinkout.h"

extern MFDB digitsource, windsource, pic_buf, ballsource, levelsource;
extern MFDB permbricksource, bricksource, twobricksource, screen_fdb;
extern int brickarray[], handle, level, lives, xwork, ywork, num_balls;
extern int ball_ani(), fuji_ani(), eye_ani(), appear[], gl_hbox;
extern int w_hand, num_bricks, wwork, hwork, ani_count, paddle_x;
extern int paddle_y, pad_y_max, pad_y_min, n_redraws, paddlearray[];
extern int max_xspeed, magic_bottom, mode, *lineaptr, fastmode;
extern int wdesk, hidden, maxy, text_ht, fuji_ht, fmask_ht, ball_ht;
extern int bh, btw, bleft, bth, btop, pad_ht, planes, pad_y_top, cheat;
extern char warray[], parray[], title_bar[];
extern char brickcount[];
extern long score, bonus_life;
extern BALL_STRUCT bs[];
extern RECT region[];		/* a list of redraw regions */
extern long get_time();

int invis;

int bonus[] = {		/* bonus sound effect */
	0x000,0x100,0x200,0x300,0x400,0x500,0x600,0x7FE,
	0x80F,0x900,0xA00,0xB00,0xC00,0xD00,
	0x8040,0x8100,0xfd31,
	0x8040,0x8100,0xfd31,
	0x8040,0x8100,0xfd31,
	0x800,0xFF00
	};

prinl(num, x, y, fill)
register long num;
{
	register int ndx = 0;
	char buf[10];

	/* make sure the number is in the acceptable range */

	if ((num < 0L) || (num > 9999999L)) num = 0L;

	/* if number is zero, be sure to show one digit */
	if (!num) buf[ndx++] = 0;

	/* build the number in reverse order */
	while (num)
	{
		buf[ndx++] = (num % 10);
		num /= 10;
	}

	if (fill)
	{	x += 8 * (7-ndx);
	}

	while (--ndx >= 0)
	{
		brickarray[0] = buf[ndx] * 8;
		brickarray[1] = 0;
		brickarray[2] = brickarray[0] + 7;
		brickarray[3] = text_ht - 1;
		brickarray[4] = x;
		brickarray[5] = y;
		brickarray[6] = x + 7;
		brickarray[7] = y + text_ht - 1;

		vro_cpyfm(handle,3,brickarray,&digitsource,&pic_buf);
		vro_cpyfm(handle,3,brickarray,&digitsource,&windsource);

		x += 8;
	}
}

show_score()
{
	prinl(score,375,2,TRUE);
	add_region(xwork+375,ywork+2,7*8,text_ht);
	if (score >= bonus_life)
	{
		Dosound(bonus);
		bonus_life += BONUS;
		lives++;
		show_lives();
	}
}

show_lives()
{
	prinl((long)lives,25,2,FALSE);
	add_region(xwork+25,ywork+2,7*8,text_ht);
}

show_level()
{
	prinl((long)level+1,170 + 6*8,2,FALSE);
	add_region(xwork+(170 + 6*8),ywork+2,7*8,text_ht);
}

clear_areas()
{
	/* put a ball in the corner */
	brickarray[0] = brickarray[1] = brickarray[4] = brickarray[5] = 0;
	brickarray[2] = brickarray[6] = 20;
	brickarray[3] = brickarray[7] = ball_ht;
	vro_cpyfm(handle,3,brickarray,&ballsource,&pic_buf);

	/* clear lives area */
	clear(21,0,4*8,text_ht + 4);

	/* clear level area */
	clear(168,0,10*8,text_ht + 4);

	/* clear score area */
	clear(375,0,7*8,text_ht + 4);

	/* put in word 'level' */
	brickarray[0] = brickarray[1] = 0;
	brickarray[2] = 8*5 - 1;
	brickarray[3] = text_ht - 1;
	brickarray[4] = 170;
	brickarray[5] = 2;
	brickarray[6] = 170 + 39;
	brickarray[7] = 170 + text_ht - 1;
	vro_cpyfm(handle,3,brickarray,&levelsource,&pic_buf);
}

char afn[] = {BALL,EYE,BALL,FUJI,BALL,EYE,BALL,EYE	};
add_ball(x,y,xspeed,yspeed,allow_fuji)
{
	register BALL_STRUCT *p;
	int ndx;

	if (num_balls >= MAX_BALLS) return;

	ndx = Random() & 7;
	p = &bs[num_balls];

	switch(afn[ndx])
	{
		case BALL:				/* ball */
b1:			p->id = BALL;
			p->ani_funct = ball_ani;
			p->ball_ht = ball_ht;
			p->ball_wid = 20;
			p->half_ht = ball_ht / 2;
			p->half_wid = 10;
			break;

		case FUJI:
			if (!allow_fuji) goto b1;
			p->id = FUJI;
			p->ani_funct = fuji_ani;
			p->ball_ht = fmask_ht;
			p->ball_wid = 16;
			p->half_ht = fmask_ht / 2;
			p->half_wid = 8;
			break;

		case EYE:
			p->id = EYE;
			p->ani_funct = eye_ani;
			p->ball_ht = ball_ht;
			p->ball_wid = 20;
			p->half_ht = ball_ht / 2;
			p->half_wid = 10;
			break;
	}

	p->y = y;
	p->x = p->array[4] = x;
	p->array[5] = p->y;
	p->array[6] = x + p->ball_wid;
	p->array[7] = y + p->ball_ht - 1;
	p->xspeed = xspeed;
	p->yspeed = yspeed;
	p->spin_dir = 1;

	num_balls++;
}

kill_ball(i)
{
	register BALL_STRUCT *p;
	register int x;

	p = &bs[i];

	p->l = p->array[0] = p->array[4];
	p->t = p->array[1] = p->array[5];
	p->r = p->array[2] = p->array[6];
	p->b = p->array[3] = p->array[7];

	/* Restore the background picture to its virgin state	*/
	/* i.e.  remove the image of the ball from it.			*/

	vro_cpyfm(handle,mode,p->array,&pic_buf,&windsource);
	add_region(xwork + p->l, ywork + p->t,
		p->r - p->l + 1, p->b - p->t + 1);


	num_balls--;
	for (x=i;x<num_balls;x++) bs[x] = bs[x+1];
}


/********************************************/
/* magic - make something weird happen		*/
/********************************************/
char mfn[] = {0,1,0,2,0,3,0,0};
magic(i)
{
	register BALL_STRUCT *p;
	register int j, ts;
	int ndx, count;

	p = &bs[i];

	ndx = Random() & 7;
	if (mode == BLACKMODE || invis)
	{
		if ((num_balls >= MAX_BALLS))
		{
			if (mode == BLACKMODE && cheat) restore_level();
			return;
		}

		restore_level();
		ndx = 0;
	}

	switch(mfn[ndx])
	{
		case 0:		/*** multiple balls ***/
			ts = p->xspeed;
			if (ts <= -max_xspeed) ts = -max_xspeed + 1;
			else if (ts >= max_xspeed) ts = max_xspeed - 1;

			/* get random # of balls */
			count = (Supexec(get_time) & 3);
			if (!count) count = 1;
			if (num_balls >= 3) count = 1;

			for (j=0; j<count; j++)
			{
				add_ball(p->x,p->y+1-j,ts+1-j,p->yspeed,TRUE);
			}
			break;

		case 1:		/*** magic bottom ***/
			magic_bottom += 2;
			break;

		case 2:		/*** bricks invisible ***/
			invis = TRUE;
			brickarray[0] = brickarray[1] = brickarray[4] = brickarray[5] = 0;
			brickarray[2] = brickarray[6] = wwork;
			brickarray[3] = brickarray[7] = hwork;
			vro_cpyfm(handle,3,brickarray,&pic_buf,&windsource);
			n_redraws = 0;
			add_region(xwork,ywork,xwork+wwork,ywork+hwork);
			break;

		case 3:		/*** background black ***/
			brickarray[0] = brickarray[1] = brickarray[4] = brickarray[5] = 0;
			brickarray[2] = brickarray[6] = wwork;
			brickarray[3] = brickarray[7] = hwork;
			vro_cpyfm(handle,15,brickarray,&pic_buf,&windsource);
			mode = BLACKMODE;
			show_score();

			n_redraws = 0;
			add_region(xwork,ywork,xwork+wwork,ywork+hwork);
			break;
	}
}

/********************************************/
/* restart a level without restoring		*/
/* brick counts								*/
/********************************************/
cont_level()
{
	register BALL_STRUCT *p;
	register int x, y, image, ndx;
	int i;

	if (w_hand == NO_WINDOW) return;

	clear_areas();

	num_bricks = 0;
	bncpy(warray,parray,20272);

	show_lives();
	show_level();
	show_score();

	brickarray[1] = 0;
	brickarray[3] = bh - 1;

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

			switch(brickcount[ndx])
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
		brickarray[2] = brickarray[0] + 43;

		for (y=0; y<7; y++)
		{
			for (x=0; x < 9; x++)
			{
				brickarray[4] = bleft + x * btw;
				brickarray[5] = btop + y * bth;
				brickarray[6] = brickarray[4] + 43;
				brickarray[7] = brickarray[5] + bh - 1;

				switch(brickcount[ndx++])
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
	paddlearray[7] = pad_y_max + pad_ht;

	num_balls = 0;
	add_ball(0, pad_y_min - ball_ht, 2, 2, FALSE);
	mode = BNORMAL;
	invis = FALSE;
}


/********************************************/
/* restore a level in progress to normal	*/
/* and keep playing							*/
/********************************************/
restore_level()
{
	register BALL_STRUCT *p;
	register int x, y, image, ndx;
	int i;

	mode = BNORMAL;
	invis = FALSE;

	clear_areas();

	bncpy(warray,parray,20272);

	show_lives();
	show_level();
	show_score();

	brickarray[1] = 0;
	brickarray[3] = bh - 1;

	ndx = 0;
	for (y=0; y<7; y++)
	{
		for (x=0; x < 9; x++)
		{
			brickarray[4] = bleft + x * btw;
			brickarray[5] = btop + y * bth;
			brickarray[6] = brickarray[4] + 43;
			brickarray[7] = brickarray[5] + bh - 1;

			switch(brickcount[ndx])
			{
				case -1:		/* permanent */
					brickarray[0] = 0;
					brickarray[2] = 43;
					vro_cpyfm(handle,3,brickarray,&permbricksource,&windsource);
					break;

				case 1:			/* normal */
					brickarray[0] = 0;
					brickarray[2] = 43;
					vro_cpyfm(handle,7,brickarray,&bricksource,&windsource);
					break;

				case 2:			/* magic */
					brickarray[0] = 0;
					brickarray[2] = 43;
					vro_cpyfm(handle,4,brickarray,&bricksource,&windsource);
					vro_cpyfm(handle,7,brickarray,&twobricksource,&windsource);
					break;

				case 3:
				case 4:
				case 5:
				case 6:
					brickarray[0] = btw;
					brickarray[2] = btw + 43;
					vro_cpyfm(handle,7,brickarray,&twobricksource,&windsource);
					break;
			}
			ndx++;
		}
	}

	n_redraws = 0;
	add_region(xwork,ywork,wwork,hwork);
	do_redraw();
}

fast_mode()
{
	int test, ret;

	wind_get(w_hand,WF_TOP,&test,&ret,&ret,&ret);
	if (test != w_hand) return;

	wind_update(TRUE);

	wind_set(w_hand, WF_NAME," Both Mouse Keys to Resume ",0,0);
	fastmode = TRUE;

	while ((((*(lineaptr - 298)) & 3) != 3) && lives > 0)
	{
		new_ball();
	}

	fastmode = FALSE;
	wind_set(w_hand, WF_NAME,title_bar,0,0);

	wind_update(FALSE);
}

fast_redraw()
{
	register RECT *p;
	RECT t;
	register int i;
	int array[8];
	int x_pos,y_pos, mxmin, mxmax, mymin, mymax;

	x_pos = *(lineaptr - 301);
	y_pos = *(lineaptr - 300);

	mxmin = x_pos - 20;
	mxmax = x_pos + 20;
	mymin = y_pos - 20;
	mymax = y_pos + 20;

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

	for (i=0; i<n_redraws; i++)
	{
		p = &region[i];
		/* clip all regions to screen size */
		if ((p->x+p->w) > wdesk) p->w = wdesk - p->x;
		if ((p->y+p->h) > maxy) p->h =maxy - p->y;
		if ((p->x+p->w) > (xwork+wwork)) p->w = (xwork+wwork) - p->x;
		if ((p->y+p->h) > (ywork+hwork)) p->h = (ywork+hwork) - p->y;
		if (p->w <=0 || p->h <= 0) continue;

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

	if (hidden)
	{	hidden = FALSE;
		SHOW_MOUSE;
	}

	n_redraws = 0;
}

/*******************************************************
do_load() mallocs a buffer, reads in a degas pic, and
	copies the contents to the picture buffer. This means
	I only do 1 disk access, and I dont waste the space of
	keeping a full width picture, which saves about 15K of
	space. Note that if memory cannot be allocated nothing
	bad happens, but no picture is loaded and no error
	message is returned... This routine also closes the
	file after the read.
*********************************************************/
do_load(fd)
{
	register char *tptr, *buffer;
	register int x,y;
	char *tptr2;

	tptr = (char *)Malloc(27520L);
	if ((long)tptr <= 0L) goto end;

	tptr2 = tptr;
	buffer = parray;

	Fseek(34L,fd,0);
	Fread(fd,27520L,tptr);


	if (planes == 2)
	{
		for (y = 0; y < 181; y++)
		{
			for (x = 0; x < 112; x++)
				*buffer++ = *tptr++;
			tptr += 48;				/* to end of degas line */
		}
	}
	else
	{
		for (y = 0; y < 362; y++)
		{
			for (x = 0; x < 56; x++)
				*buffer++ = *tptr++;
			tptr += 24;				/* to end of degas line */
		}
	}

	Mfree(tptr2);
end:
	Fclose(fd);
}

add_difficulty()
{
	if (level <= 17)
	{
		/* restrict upper paddle limit */
		pad_y_top++;
		if (planes == 1) pad_y_top++;
	}
}
