/********************************************
*		Bout4.c								*
*											*
*		Based Upon code by					*
*		Samuel Streeper 90/01/26			*
*											*
*	Original Version						*
*	Copyright 1990 by Antic Publishing Inc.	*
*											*
*	Miscellaneous boinkout routines			*
*											*
********************************************/

/* edited with tabsize = 4 */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "boink.h"

extern MFDB digitsource, windsource, pic_buf, ballsource, levelsource;
extern int brickarray[], level, lives, num_balls;
extern void ball_ani(register BALL_STRUCT *p);
extern void fuji_ani(register BALL_STRUCT *p);
extern void eye_ani(register BALL_STRUCT *p);
extern int appear[], gl_hbox;
extern int num_bricks, ani_count, paddle_x;
extern int paddle_y, pad_y_max, pad_y_min, n_redraws, paddlearray[];
extern int max_xspeed, magic_bottom, mode, gravity;
extern int text_ht, fuji_ht, fmask_ht, ball_ht;
extern int bh, btw, bleft, bth, btop, pad_ht, planes, pad_y_top, cheat;
extern char brickcount[];
extern long score, bonus_life;
extern BALL_STRUCT bs[];
extern GRECT region[];		/* a list of redraw regions */

extern void clear(int x,int y,int w,int h);

void restore_level(void);

int invis;


void
prinl(register long num,int x,int y,int fill)
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

		vro_cpyfm(vdi_handle,S_ONLY,brickarray,&digitsource,&pic_buf);

		vro_cpyfm(vdi_handle,S_ONLY,brickarray,&digitsource,&windsource);

		x += 8;
	}
}

void
show_score(void)
{
	prinl(score,372,2,TRUE);
	add_region(work.g_x+372,work.g_y+2,7*8,text_ht);
	if (score >= bonus_life)
	{
		sound_play(S_BONUS);
		bonus_life += BONUS;
		lives++;
		show_lives();
	}
}

void
show_lives(void)
{
	prinl((long)lives,25,2,FALSE);
	add_region(work.g_x+25,work.g_y+2,7*8,text_ht);
}

void
show_level(void)
{
	prinl((long)level+1,170 + 6*8,2,FALSE);
	add_region(work.g_x+(170 + 6*8),work.g_y+2,7*8,text_ht);
}

void
clear_areas(void)
{
	/* put a ball in the corner */
	brickarray[0] = brickarray[1] = brickarray[4] = brickarray[5] = 0;
	brickarray[2] = brickarray[6] = 20;
	brickarray[3] = brickarray[7] = ball_ht - 1;

	vro_cpyfm(vdi_handle,S_ONLY,brickarray,&ballsource,&pic_buf);

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
	brickarray[7] = 2 + text_ht - 1;

	vro_cpyfm(vdi_handle,S_ONLY,brickarray,&levelsource,&pic_buf);
}

char afn[] = {BALL,EYE,BALL,FUJI,BALL,EYE,BALL,EYE	};

void
add_ball(int x,int y,int xspeed,int yspeed,int allow_fuji)
{
	register BALL_STRUCT *p;
	int ndx;

	if (num_balls >= MAX_BALLS) return;

	ndx = (int)(rand() & 7);
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

void
kill_ball(int i)
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

	vro_cpyfm(vdi_handle,mode,p->array,&pic_buf,&windsource);
	add_region(work.g_x + p->l, work.g_y + p->t,
		p->r - p->l + 1, p->b - p->t + 1);


	num_balls--;
	for (x=i;x<num_balls;x++) bs[x] = bs[x+1];
}


/********************************************/
/* magic - make something weird happen		*/
/********************************************/
char mfn[] = {0,1,0,2,0,3,0,4};

void
magic(int i)
{
	register BALL_STRUCT *p;
	register int j, ts;
	int ndx, count;

	p = &bs[i];
	gravity = 0;

	ndx = (int)(rand() & 7);
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
			count = (int)(rand() & 3);
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
			brickarray[2] = brickarray[6] = work.g_w;
			brickarray[3] = brickarray[7] = work.g_h;
			vro_cpyfm(vdi_handle,S_ONLY,brickarray,&pic_buf,&windsource);
			n_redraws = 0;
			add_region(work.g_x,work.g_y,work.g_x+work.g_w,work.g_y+work.g_h);
			break;

		case 3:		/*** background black ***/
			brickarray[0] = brickarray[1] = brickarray[4] = brickarray[5] = 0;
			brickarray[2] = brickarray[6] = work.g_w;
			brickarray[3] = brickarray[7] = work.g_h;
			vro_cpyfm(vdi_handle,ALL_BLACK,brickarray,&pic_buf,&windsource);
			mode = BLACKMODE;
			show_score();

			n_redraws = 0;
			add_region(work.g_x,work.g_y,work.g_x+work.g_w,work.g_y+work.g_h);
			break;

 		case 4:		/*** gravity ***/
 			gravity=1;
 			break;

	}
}

/********************************************/
/* restart a level without restoring		*/
/* brick counts								*/
/********************************************/
void
cont_level(void)
{
	register int x, y, image, ndx;

	if (win[GAME_WIN].handle == NO_WINDOW) return;

	clear_areas();

	num_bricks = 0;
	
	brickarray[0] = brickarray[1] = brickarray[4] = brickarray[5] = 0;
	brickarray[2] = brickarray[6] = pic_buf.fd_w - 1;
	brickarray[3] = brickarray[7] = pic_buf.fd_h - 1;
	vro_cpyfm(vdi_handle,S_ONLY,brickarray,&pic_buf,&windsource); 

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
				case 9:		/* permanent */
					vrt_cpyfm(vdi_handle, MD_TRANS, brickarray,&permbrickmask,&windsource,junkcolors);
					vro_notcpy(brickarray, &permbricksource, &windsource);
					break;

				case 1:			/* normal */
					num_bricks++;
					break;

				case 2:			/* magic */
					vrt_cpyfm(vdi_handle, MD_TRANS, brickarray,&twobrickmask,&windsource,junkcolors);
					vro_notcpy(brickarray, &magicbricksource, &windsource);

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
	add_region(work.g_x,work.g_y,work.g_w,work.g_h);
	do_redraw();

	evnt_timer(150,0);

	sound_play(S_APPEAR);

	evnt_timer(150,0);

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
						vrt_cpyfm(vdi_handle, MD_TRANS, brickarray,&nbrickmask,&windsource,junkcolors);
						vro_notcpy(brickarray, &bricksource, &windsource);
						break;
					case 3:
					case 4:
					case 5:
					case 6:
						if (image > 0)
						{
							vrt_cpyfm(vdi_handle, MD_TRANS, brickarray,&twobrickmask,&windsource,junkcolors);
							vro_notcpy(brickarray, &twobricksource, &windsource);
						}
						break;
				}
			}
		}
		add_region(work.g_x,work.g_y,work.g_w,work.g_h);
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
 	gravity = 0;
}


/********************************************/
/* restore a level in progress to normal	*/
/* and keep playing							*/
/********************************************/
void
restore_level(void)
{
	register int x, y, ndx;

	mode = BNORMAL;
	invis = FALSE;

	clear_areas();

	brickarray[0] = brickarray[1] = brickarray[4] = brickarray[5] = 0;
	brickarray[2] = brickarray[6] = pic_buf.fd_w - 1;
	brickarray[3] = brickarray[7] = pic_buf.fd_h - 1;
	vro_cpyfm(vdi_handle,S_ONLY,brickarray,&pic_buf,&windsource); /* windsource */
	
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
				case 9:		/* permanent */
					brickarray[0] = 0;
					brickarray[2] = 43;
					vrt_cpyfm(vdi_handle, MD_TRANS, brickarray,&permbrickmask,&windsource,junkcolors);
					vro_notcpy(brickarray, &permbricksource, &windsource);
					break;

				case 1:			/* normal */
					brickarray[0] = 0;
					brickarray[2] = 43;

					vrt_cpyfm(vdi_handle, MD_TRANS, brickarray,&nbrickmask,&windsource,junkcolors);
					vro_notcpy(brickarray, &bricksource, &windsource);
					break;

				case 2:			/* magic */
					brickarray[0] = 0;
					brickarray[2] = 43;
					vrt_cpyfm(vdi_handle, MD_TRANS, brickarray,&twobrickmask,&windsource,junkcolors);
					vro_notcpy(brickarray, &magicbricksource, &windsource);
					break;

				case 3:
				case 4:
				case 5:
				case 6:
					brickarray[0] = btw;
					brickarray[2] = btw + 43;
					
					vrt_cpyfm(vdi_handle, MD_TRANS, brickarray,&twobrickmask,&windsource,junkcolors);
					vro_notcpy(brickarray, &twobricksource, &windsource);
					break;
			}
			ndx++;
		}
	}

	n_redraws = 0;
	add_region(work.g_x,work.g_y,work.g_w,work.g_h);
	do_redraw();
}


void
add_difficulty(void)
{
	if (level <= 17)
	{
		/* restrict upper paddle limit */
		pad_y_top++;

		if (desk.g_h > 300) pad_y_top++;

	}
}
