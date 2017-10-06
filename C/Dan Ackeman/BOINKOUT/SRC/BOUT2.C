/********************************************
*		Bout2.c								*
*											*
*   Based upon code by						*
*		Samuel Streeper 90/01/26			*
*											*
*	Original version						*
*	Copyright 1990 by Antic Publishing Inc.	*
*											*
*	Miscellaneous boinkout routines			*
*											*
********************************************/

/* edited with tabsize = 4 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "boink.h"

extern int ballarray[], paddlearray[];
extern int paddle_x, paddle_y;
extern MFDB pic_buf, windsource, screen_fdb, ballsource, paddlesource;
extern MFDB ballmask,paddlemask;
extern long score, old_score, bonus_life, old_bonus;
extern int pad_y_min, pad_y_max, brickarray[], ani_count, num_bricks;
extern int level, n_redraws, num_balls, lives, old_lives;
extern int event_kind, cheat, pad_y_top;
extern int pady_offset, max_pad_dy, pad_ht, fuji_ht, fmask_ht;

void animate(void);
void fixx(register BALL_STRUCT *p);
void add_ani(int (*f)(),int x,int y);
void kill_ani(int n);
void erase_brick(int x,int y);
void brand(register BALL_STRUCT *p);
int bcollide(register int i);

int brick_erase(int x, int y, int frame);
int perm_flash(int x, int y, int frame);
int brick_spin(int x, int y, int frame);
int spin_erase(int x, int y, int frame);
void vro_notcpy(int *pxy, MFDB *source, MFDB *dest);

extern GRECT region[];

ANI_STRUCT ani_struct[MAX_ANI];
extern BALL_STRUCT bs[];


int magic_bottom, mode = 3, gravity = 0;
int brick_ani, randomize;
extern int max_xspeed, min_yspeed;

extern int btop, btopm, bth, bh, block_bot, bleft, btw;

extern char brickcount[];

/* Collision detection routine - returns 1 if collision */
int collide(GRECT *r1, GRECT *r2) 
{
  int x, y, w, h;

   x = max( r2->g_x, r1->g_x );
   y = max( r2->g_y, r1->g_y );
   w = min( r2->g_x + r2->g_w, r1->g_x + r1->g_w );
   h = min( r2->g_y + r2->g_h, r1->g_y + r1->g_h );

   return ( ((w > x) && (h > y) ) );
}	


/* move the ball to its new bounce position */
void
new_ball(void)
{
	register BALL_STRUCT *p;
	register int i;
	int l2,t2,r2,b2;
	int o_padx, o_pady, pad_dx, pad_dy;
	int junk;
	GRECT paddle, ball;

	int score_loop;

	for (i=0; i<num_balls; i++)
	{
		p = &bs[i];

		p->l = p->array[0] = p->array[4];
		p->t = p->array[1] = p->array[5];
		p->r = p->array[2] = p->array[6];
		p->b = p->array[3] = p->array[7];

		/* Restore the background picture to its virgin state	*/
		/* i.e.  remove the image of the ball from it.			*/

		vro_cpyfm(vdi_handle,mode,p->array,&pic_buf,&windsource);
	}

	o_padx = l2 = paddlearray[0] = paddlearray[4];
	o_pady = t2 = paddlearray[1] = paddlearray[5];
	r2 = paddlearray[2] = paddlearray[6];
	b2 = paddlearray[3] = paddlearray[7];

	/* Restore the background picture to its virgin state	*/
	/* i.e.  remove the image of the paddle from it.			*/

	vro_cpyfm(vdi_handle,mode,paddlearray,&pic_buf,&windsource);

	/* run background animations first so things appear on top of them */
	brick_ani = FALSE;				/* not animating any bricks */
	if (ani_count) animate();


/*** Calculate paddle position  **********************************/

	graf_mkstate(&paddle_x,&paddle_y,&junk,&junk);

	paddle_x = paddle_x - work.g_x - 25;

	if (paddle_x < 0) paddle_x = 0;
	else if (paddle_x + 52 > work.g_w) paddle_x = work.g_w - 52;
/* limit paddle_x speed here, if desired */
	pad_dx = paddle_x - o_padx;

	if (paddle_x < l2) l2 = paddle_x; else r2 = paddle_x + 52;

	paddle_y = paddle_y - work.g_y - pady_offset;

	if (paddle_y < pad_y_top) paddle_y = pad_y_top;
	else if (paddle_y > pad_y_max) paddle_y = pad_y_max;

/* limit paddle_y speed here */
	pad_dy = paddle_y - o_pady;
	if (pad_dy > max_pad_dy)
	{
		paddle_y = o_pady + max_pad_dy;
		pad_dy = max_pad_dy;
	}
	else if (pad_dy < -max_pad_dy)
	{
		paddle_y = o_pady - max_pad_dy;
		pad_dy = -max_pad_dy;
	}

	if (paddle_y < t2) t2 = paddle_y; else b2 = paddle_y + pad_ht - 1;

/*********************************************/

	paddle.g_x = paddle_x;
	paddle.g_y = paddle_y;
	paddle.g_w = 52;
	paddle.g_h = pad_ht;

	for (i=0; i<num_balls; i++)
	{
		p = &bs[i];

	/* calculate new ball x position */
	p->x += p->xspeed;

	if (p->x <= 0)				/* ball hit left edge */
	{	
		p->xspeed = -p->xspeed;
		p->spin_dir = -p->spin_dir;
		sound_play(S_SIDE);
		p->x = 0;
		if (p->xspeed == 0) p->xspeed = 1;
	}
	else if (p->x >= (work.g_w - (p->ball_wid+1)))	/* ball hit right edge */
	{	sound_play(S_SIDE);
		p->xspeed = -p->xspeed;
		p->x = (work.g_w - (p->ball_wid+1));
		p->spin_dir = -p->spin_dir;
		if (p->xspeed == 0) p->xspeed = -1;
	}

	if (p->x < p->l) p->l = p->x; else p->r = p->x + p->ball_wid;

	/* calculate new ball vertical position */
 	if(gravity) gravity++;
 	if(gravity>9){
 		p->yspeed++;
 		gravity = 1;
 	}
 	if(p->yspeed == 0) p->yspeed++;

	p->y += p->yspeed;

	if (p->y <= 0)				/* ball hit top of window */
	{
		brand(p);
		sound_play(S_TOP);
		p->yspeed = -p->yspeed;
		p->y = 0;
		p->spin_dir = -p->spin_dir;
	}
	else if (p->y > (work.g_h - p->ball_ht - 1))	/* ball hit bottom of window */
	{
		if (cheat || (magic_bottom > 0))
		{
			sound_play(S_BOTTOM);
			p->yspeed = -p->yspeed;
			p->y = (work.g_h - p->ball_ht - 1);
			p->spin_dir = -p->spin_dir;
			magic_bottom--;
		}
		else
		{
			kill_ball(i);
			if (num_balls <= 0)
			{
				sound_play(S_DEATH);

				if (--lives > 0)
				{	evnt_timer(1000,0);
					cont_level();
				}
				else
				{
					show_lives();
					n_redraws = 0;
					add_region(work.g_x,work.g_y,work.g_w,work.g_h);
					do_redraw();
					event_kind = MU_KEYBD | MU_MESAG | MU_BUTTON;
					
					/* Game is Over */

					/* check highscores */
					for (score_loop = 0; score_loop < 10; score_loop++)
					{
						if (score > scores[score_loop].score)
						{
							for (junk = 9; junk > score_loop; junk--)
							{
								strcpy(scores[junk].name,scores[junk-1].name);
								scores[junk].level = scores[junk-1].level;
								scores[junk].score = scores[junk-1].score;
							}
										
							get_high_name(score_loop);
									
							break;
						}		
					}
				}
				
				goto end;
			}

			sound_play(S_LOSTBALL);

			i--;	/* a new ball takes this slot */
			goto loopend;
		}
	}


/******************************************************
	We have now calculated the projected next positions
	for the ball and paddle. Time to look for brick and
	paddle collisions!
******************************************************/

/* everything before if 0 is new */

	ball.g_x = p->x;
	ball.g_y = p->y;
	ball.g_w = p->ball_wid;
	ball.g_h = p->ball_ht;
	
	if (collide((GRECT *)&paddle,(GRECT *)&ball ))
	{
		if (ball.g_y <= paddle.g_y)
		{
			if (p->yspeed > 0)
				p->yspeed = -p->yspeed;

			p->yspeed += pad_dy;
				
			if (p->yspeed < min_yspeed) 
				p->yspeed = min_yspeed;
				
			p->y = paddle_y - p->ball_ht;
		}
		else
		{
			if ((p->xspeed * pad_dx) <= 0)
				p->xspeed = -p->xspeed;
		}
				
		p->spin_dir = -p->spin_dir;

		sound_play(S_PSOUND);

		p->xspeed += pad_dx/2;

		if (p->xspeed < -max_xspeed) p->xspeed = -max_xspeed;
		else if (p->xspeed > max_xspeed) p->xspeed = max_xspeed;

		if (p->xspeed == 0)		/* too easy! */
		{
			if (++randomize & 1) p->xspeed = -1;
			else p->xspeed = 1;
		}
	}

	if (p->y < p->t) p->t = p->y; else p->b = p->y + p->ball_ht;


/************************************************
*	Check for collisions with the bricks		*
************************************************/

	if (bcollide(i))
	{
		p->spin_dir = -p->spin_dir;

		/* logically this doesn't really go here, but			*/
		/* its more efficient than checking every iteration...	*/
		if (num_bricks <= 0)
		{
			while (ani_count && brick_ani)
			{	animate();
				do_redraw();
				evnt_timer(75,0);
			}

			level++;
			add_difficulty();

			old_lives = lives;
			old_score = score;
			old_bonus = bonus_life;
			restart_level();
			goto end;
		}
	}


/****** call the animation function for this ball now, *****/
/****** pass it a pointer to it's animation structure ******/
	(*p->ani_funct)(p);
loopend:;
	}

	paddlearray[0] = 0;
	paddlearray[1] = 0;
	paddlearray[2] = 52;
	paddlearray[3] = pad_ht - 1;
	paddlearray[4] = paddle_x;
	paddlearray[5] = paddle_y;
	paddlearray[6] = paddle_x + 52;
	paddlearray[7] = paddle_y + paddlearray[3];

	vrt_cpyfm(vdi_handle, MD_TRANS, paddlearray,&paddlemask,&windsource,junkcolors);
	vro_notcpy(paddlearray, &paddlesource, &windsource);

	/* Whew! we are now done creating the ball image in our background	*/
	/* buffer. Now we must blit the updated picture into the boink		*/
	/* window. The area we must update is the smallest rectangle that	*/
	/* will enclose both the ball's old position and its new one. This	*/
	/* technique will erase the old ball and draw in the new one		*/
	/* without any flickering of the image. Note also that the area		*/
	/* we update must be clipped to our windows rectangle list so that	*/
	/* we don't trash the contents of another window.					*/


	/* Use the rectangle list to draw the window in an orderly fashion */

	add_region(work.g_x + l2,work.g_y + t2,r2-l2+1,b2-t2+1);

	do_redraw();
end:	;
}

int
bcollide(register int i)
{
	register BALL_STRUCT *p;
	register int x1, y1, x2, y2;	/* 2 collision points */
	int x3, y3, x4, y4;				/* 2 dragging corners */
	int row, col, x, y, ndx, r2, c2, ndx2;

	p = &bs[i];

	if (p->y > block_bot) return FALSE;
	if (p->y + p->ball_ht < btopm) return FALSE;

	x2 = p->x - bleft;			/* corrected left point */
	x1 = x2 + p->half_wid;		/* corrected top point */
	y1 = p->y - btopm;			/* corrected top point */
	y2 = y1 + p->half_ht;		/* corrected left point */

	x3 = x2;					/* the dragging corners */
	x4 = x2 + p->ball_wid;

	if (x2 < 0) x2 = x3 = 0;

	if (p->xspeed > 0) x2 = x4;	/* use center point on right side */

	if ((p->xspeed * p->yspeed) < 0)
	{	y3 = y1;
		y4 = y1 + p->ball_ht;
	}
	else
	{	y3 = y1 + p->ball_ht;
		y4 = y1;
	}

	if (p->yspeed > 0)			/* going down */
	{
		y1 += p->ball_ht;
	}

/**** look for horizontal collision ****/

	if (y2 < 0) goto c1;
	row = y2 / bth;
	col = x2 / btw;
	if (col > 8) col = 8;

	ndx = 9 * row + col;
	if (brickcount[ndx] && ndx < 63)
	{
		if (p->xspeed == 0) p->yspeed = -p->yspeed;
		else
		{
			if (p->xspeed < 0) p->x = ((col + 1) * btw) + bleft + 1;
			else p->x = col * btw - 21 + bleft;
			fixx(p);
			p->xspeed = -p->xspeed;

/*			p->y -= p->yspeed / 2;*/
		}

/******* We got a horizontal collision, lets check *********/
/******* for a vertical one too and correct position *******/

		if (y1 < 0) goto collision;
		r2 = y1 / bth;
		c2 = x1 / btw;
		if (c2 > 8) c2 = 8;

		ndx2 = 9 * r2 + c2;
		if (brickcount[ndx2] && (ndx2 < 63) && (row != r2))
		{
			if (p->yspeed < 0) p->y = btopm + (r2+1) * bth;
			else p->y = btopm + r2 * bth - p->ball_ht;
/*			p->yspeed = -p->yspeed;*/
		}

		goto collision;
	}

/*** check vertical for collision ***/
c1:
	if (y1 < 0) goto c2;
	row = y1 / bth;
	col = x1 / btw;
	if (col > 8) col = 8;

	ndx = 9 * row + col;
	if (brickcount[ndx] && ndx < 63)
	{
		if (p->yspeed < 0) p->y = btopm + (row+1) * bth + 1;
		else p->y = btopm + row * bth - p->ball_ht - 1;
		p->yspeed = -p->yspeed;

		goto collision;
	}

/************ check left corner **************/
c2:
	if (y3 < 0) goto c3;
	row = y3 / bth;
	col = x3 / btw;
	if (col > 8) col = 8;

	ndx = 9 * row + col;
	if (brickcount[ndx] && ndx < 63)
	{
		if (p->xspeed < 0)
		{
			p->x = ((col + 1) * btw) + bleft + 1;
			p->xspeed = -p->xspeed;
		}
		else
		{
			if (p->yspeed < 0) p->y = btopm + (row+1) * bth + 1;
			else p->y = btopm + row * bth - p->ball_ht - 1;
			p->yspeed = -p->yspeed;
		}

		goto collision;
	}

/************ check right corner **************/
c3:
	if (y4 < 0) goto c4;
	row = y4 / bth;
	col = x4 / btw;
	if (col > 8) col = 8;

	ndx = 9 * row + col;
	if (brickcount[ndx] && ndx < 63)
	{
		if (p->xspeed <= 0)
		{
			if (p->yspeed < 0) p->y = btopm + (row+1) * bth + 1;
			else p->y = btopm + row * bth - p->ball_ht - 1;
			p->yspeed = -p->yspeed;
		}
		else
		{
			p->x = col * btw - 21 + bleft;
			fixx(p);
			p->xspeed = -p->xspeed;
		}

collision:
		x = bleft + col * btw;
		y = btop + row * bth;
		switch(brickcount[ndx])
		{
			case 9:
				sound_play(S_PERMBRICKSOUND);

				add_ani(perm_flash,x,y);
				brand(p);
				break;
			case 1:
				sound_play(S_BRICKSOUND);	
				brick_ani = TRUE;
				brickcount[ndx] = 0;
				add_ani(brick_erase,x,y);
				num_bricks--;
				score += 10;
				show_score();
				break;

			case 2:					/* magic */
				sound_play(S_MAGICBELL);
				brickcount[ndx] = 0;
				erase_brick(x,y);
				num_bricks--;
				magic(i);
				score += 13;
				show_score();
				break;

			case 3:
				sound_play(S_BRICKSOUND);
				brick_ani = TRUE;
				brickcount[ndx] = 0;
				add_ani(spin_erase,x,y);
				num_bricks--;
				score += 11;
				show_score();
				break;
			case 4:
			case 5:
			case 6:
				sound_play(S_BRICKSOUND);
				brick_ani = TRUE;
				brickcount[ndx]--;
				add_ani(brick_spin,x,y);
				score += 2;
				show_score();
				break;
		}

		return TRUE;
	}
c4:
	return FALSE;
}

/********************************************************
*	animate runs and updates all the animation threads	*
********************************************************/
void
animate(void)
{
	register int i;
	register ANI_STRUCT *p;

	for (i = 0; i < ani_count; i++)
	{
		p = &ani_struct[i];
		if ((*p->ani_funct)(p->x,p->y,p->frame))
		{
			kill_ani(i--);
		}
		else (p->frame)++;
	}
}

/************************************************
fix ball x position to keep it within window
after x corrections. The blit routines bomb
if passed a coordinate less than zero, too.
************************************************/
void
fixx(register BALL_STRUCT *p)
{
	if (p->x < 0)								/* ball hit left edge */
		p->x = 0;

	else if (p->x >= (work.g_w - (p->ball_wid+1)))	/* ball hit right edge */
		p->x = (work.g_w - (p->ball_wid+1));
}

void
add_ani(int (*f)(),int x,int y)
{
	register ANI_STRUCT *p;
	register int i;

	/* kill any other animations of this brick */
	for (i=0; i<ani_count; i++)
	{
		p = &ani_struct[i];
		if (x == p->x && y == p->y)
		{
			kill_ani(i);
			break;
		}
	}

	if (ani_count >= MAX_ANI) return;	/* would overflow list */

	p = &ani_struct[ani_count];
	p->ani_funct = f;
	p->x = x;
	p->y = y;
	p->frame = 0;
	ani_count++;
}

void
kill_ani(int n)
{
	register int i;
	ani_count--;
	for (i = n; i < ani_count; i++)
		ani_struct[i] = ani_struct[i+1];	/* structure assignment */
}

/*** animation function to erase a standard brick ***/
int
brick_erase(int x,int y,int frame)
{
	brick_ani = TRUE;
	frame++;			/* we start at 1 */

	if (mode == BLACKMODE) goto nd;

	brickarray[0] = brickarray[4] = x;
	brickarray[1] = brickarray[5] = y;
	brickarray[2] = brickarray[6] = x + 43;
	brickarray[3] = brickarray[7] = y + bh - 1;

	/* erase old brick */
	vro_cpyfm(vdi_handle,S_ONLY,brickarray,&pic_buf,&windsource);

	brickarray[0] = frame * btw;
	brickarray[1] = 0;
	brickarray[2] = brickarray[0] + 43;
	brickarray[3] = bh - 1;

	/* draw new brick */
	if (frame < 4)
	{
		vrt_cpyfm(vdi_handle, MD_TRANS, brickarray,&nbrickmask,&windsource,junkcolors);	
		vro_notcpy(brickarray, &bricksource, &windsource);	/* Fix for inverted mono in Truecolor */
	}
		
	add_region(work.g_x + x, work.g_y + y, 44, bh);
nd:
	if (frame < 4) return FALSE;
	return TRUE;	/* all done! */
}

/*** animation function to flash a permanent brick ***/
int
perm_flash(int x,int y,int frame)
{
	register int f2;
	int temparray[8];

	frame++;			/* we start at 1 */

	if (frame < 4) f2 = frame;
	else f2 = 6 - frame;

	brickarray[0] = f2 * btw;
	brickarray[1] = 0;
	brickarray[2] = brickarray[0] + 43;
	brickarray[3] = bh - 1;
	brickarray[4] = x;
	brickarray[5] = y;
	brickarray[6] = x + 43;
	brickarray[7] = y + brickarray[3];

	/* draw new brick */

	temparray[0] = temparray[4] = x;
	temparray[1] = temparray[5] = y;
	temparray[2] = temparray[6] = x + 43;
	temparray[3] = temparray[7] = y + bh - 1;

	vro_cpyfm(vdi_handle,mode,temparray,&pic_buf,&windsource);
	
/*	if (planes > 8)
		vro_cpyfm(vdi_handle,S_OR_D,brickarray,&permbricksource,&windsource);
	else*/
		vrt_cpyfm(vdi_handle, MD_TRANS, brickarray,&permbrickmask,&windsource,junkcolors);	
		
	vro_notcpy(brickarray, &permbricksource, &windsource);	/* Fix for inverted mono in Truecolor */

	add_region(work.g_x + x, work.g_y + y, 44, bh);

	if (frame < 6) return FALSE;
	return TRUE;	/* all done! */
}


/**************************************
animate a boink ball
**************************************/
void ball_ani(register BALL_STRUCT *p)
{
	/* rotate the ball by selecting a new ball image to blit */
	/* we have an image of the ball in 6 different stages of rotation */

	p->ball_num += p->spin_dir;
	if (p->ball_num >= 6) p->ball_num = 0;
	else if (p->ball_num < 0) p->ball_num = 5;

	p->array[0] = 120;
	p->array[1] = 0;
	p->array[2] = 140;
	p->array[3] = p->ball_ht-1;
	p->array[4] = p->x;
	p->array[5] = p->y;
	p->array[6] = p->x + 20;
	p->array[7] = p->y + p->ball_ht-1;

	/* blit the ball mask into the background picture which cuts a 	*/
	/* white hole in the picture */

	/* fix for inverted mono in truecolor */
/*	if (planes > 8)
		vro_cpyfm(vdi_handle,S_OR_D,p->array,&ballsource,&windsource);
	else*/

		vrt_cpyfm(vdi_handle, MD_TRANS, p->array,&ballmask,&windsource,junkcolors);	

/*		vro_cpyfm(vdi_handle,NOTS_AND_D,p->array,&ballsource,&windsource);*/

	/* blit the ball into the white hole we just cut out of the picture */
	/* with the mask */

	p->array[0] = 20 * p->ball_num;
	p->array[2] = 20 * (p->ball_num+1);

	vro_notcpy(p->array, &ballsource, &windsource);

	add_region(work.g_x + p->l, work.g_y + p->t,
		p->r - p->l + 1, p->b - p->t + 1);
}

char fn[] = { 0,0,0,0,1,1,1,2,3,4,5,6,5,4,3,2,1 };
/**************************************
animate a spinning fuji
**************************************/
void fuji_ani(register BALL_STRUCT *p)
{
	register int offset;
	/* rotate the ball by selecting a new ball image to blit */
	/* we have an image of the ball in 6 different stages of rotation */

	p->ball_num++;
	if (p->ball_num > 16) p->ball_num = 0;

	offset = 16 * fn[p->ball_num];

	p->array[0] = offset;
	p->array[1] = 0;
	p->array[2] = offset + 15;
	p->array[3] = fmask_ht - 1;
	p->array[4] = p->x;
	p->array[5] = p->y;
	p->array[6] = p->x + 15;
	p->array[7] = p->y + fmask_ht - 1;

	/* blit the ball mask into the background picture which cuts a 	*/
	/* white hole in the picture */

	/* fix for inverted mono in truecolor */
/*	if (planes > 8)
		vro_cpyfm(vdi_handle,S_OR_D,p->array,&fmasksource,&windsource);
	else
		vro_cpyfm(vdi_handle,NOTS_AND_D,p->array,&fmasksource,&windsource);
*/
	vrt_cpyfm(vdi_handle, MD_TRANS, p->array,&fmasksource,&windsource,junkcolors);	

	/* blit the ball into the white hole we just cut out of the picture */
	/* with the mask */

	p->array[0] = offset;
	p->array[1] = 0;
	p->array[2] = offset + 15;
	p->array[3] = fuji_ht - 1;
	p->array[4] = p->x;
	p->array[5] = p->y + 1;
	p->array[6] = p->x + 15;
	p->array[7] = p->y + fuji_ht - 1;

	vro_notcpy(p->array, &fujisource, &windsource);

	p->array[5] = p->y;
	p->array[7] = p->y + fmask_ht - 1;

	add_region(work.g_x + p->l, work.g_y + p->t,
		p->r - p->l + 1, p->b - p->t + 1);
}

char efn[] = { 0,0,1,2,1,0,1,2,1,0,0,3,4,5,4,3 };
/**************************************
animate an eye
**************************************/
void eye_ani(register BALL_STRUCT *p)
{
	register int ndx;
	/* rotate the ball by selecting a new ball image to blit */
	/* we have an image of the ball in 6 different stages of rotation */

	p->ball_num++;
	if (p->ball_num > 31) p->ball_num = 0;

	ndx = efn[p->ball_num/2];

	p->array[0] = 120;
	p->array[1] = 0;
	p->array[2] = 140;
	p->array[3] = p->ball_ht - 1;
	p->array[4] = p->x;
	p->array[5] = p->y;
	p->array[6] = p->x + 20;
	p->array[7] = p->y + p->ball_ht - 1;

	/* blit the ball mask into the background picture which cuts a 	*/
	/* white hole in the picture */

	/* fix for inverted mono in truecolor */
/*	if (planes > 8)
		vro_cpyfm(vdi_handle,S_OR_D,p->array,&eyesource,&windsource);
	else*/
		vrt_cpyfm(vdi_handle, MD_TRANS, p->array,&eyemask,&windsource,junkcolors);	

/*		vro_cpyfm(vdi_handle,NOTS_AND_D,p->array,&eyesource,&windsource);
*/

	/* blit the ball into the white hole we just cut out of the picture */
	/* with the mask */

	p->array[0] = 20 * ndx;
	p->array[2] = 20 * (ndx + 1);

	vro_notcpy(p->array, &eyesource, &windsource);

/*	vro_cpyfm(vdi_handle,S_OR_D,p->array,&eyesource,&windsource);*/

	add_region(work.g_x + p->l, work.g_y + p->t,
		p->r - p->l + 1, p->b - p->t + 1);
}

int
brick_spin(int x, int y, int frame)
{
	register int f2;

	brick_ani = TRUE;
	frame+=2;			/* we start at 2 */

	if (mode == BLACKMODE) goto nd;

	if (frame < 4) f2 = frame;
	else f2 = 6-frame;

	brickarray[0] = brickarray[4] = x;
	brickarray[1] = brickarray[5] = y;
	brickarray[2] = brickarray[6] = x + 43;
	brickarray[3] = brickarray[7] = y + bh - 1;

	/* erase old brick */
	vro_cpyfm(vdi_handle,S_ONLY,brickarray,&pic_buf,&windsource);

	brickarray[0] = f2 * 48;
	brickarray[1] = 0;
	brickarray[2] = brickarray[0] + 43;
	brickarray[3] = bh - 1;

	/* draw new brick */

	vrt_cpyfm(vdi_handle, MD_TRANS, brickarray,&twobrickmask,&windsource,junkcolors);

	vro_notcpy(brickarray, &twobricksource, &windsource);

	add_region(work.g_x+x,work.g_y+y, 44, bh);
nd:
	if (frame < 5) return FALSE;
	return TRUE;	/* all done! */
}

int
spin_erase(int x, int y, int frame)
{
	brick_ani = TRUE;
	frame+=2;			/* we start at 2 */

	if (mode == BLACKMODE) goto nd;

	brickarray[0] = brickarray[4] = x;
	brickarray[1] = brickarray[5] = y;
	brickarray[2] = brickarray[6] = x + 43;
	brickarray[3] = brickarray[7] = y + bh - 1;

	/* erase old brick */
	vro_cpyfm(vdi_handle,mode,brickarray,&pic_buf,&windsource);

	brickarray[0] = frame * 48;
	brickarray[1] = 0;
	brickarray[2] = brickarray[0] + 43;
	brickarray[3] = bh - 1;

	/* draw new brick */
	if (frame < 4)
	{
		vrt_cpyfm(vdi_handle, MD_TRANS, brickarray,&twobrickmask,&windsource,junkcolors);
		vro_notcpy(brickarray, &twobricksource, &windsource);
	}
	
	add_region(work.g_x+x, work.g_y+y, 44, bh);
nd:
	if (frame < 4) return FALSE;
	return TRUE;	/* all done! */
}

/* used to erase a magic brick */
void
erase_brick(int x,int y)
{
	brickarray[0] = brickarray[4] = x;
	brickarray[1] = brickarray[5] = y;
	brickarray[2] = brickarray[6] = x + 43;
	brickarray[3] = brickarray[7] = y + bh - 1;

	vro_cpyfm(vdi_handle,mode,brickarray,&pic_buf,&windsource);
	add_region(work.g_x+x,work.g_y+y,44,bh);
}

void
brand(register BALL_STRUCT *p)
{
	register int val;

	if (++randomize > 40)
	{
		val = (rand() & 3);
		if (val > 2) val = 2;

		randomize = 0;
		p->xspeed += val;
		while (p->xspeed > max_xspeed)
			p->xspeed -= (rand() & 3);
	}
}

/* does a test on number of screen planes
 * if > 8 does NOTS_AND_D
 * else S_OR_D.  Just a common test for truecolor resolutions
 */
void
vro_notcpy(int *pxy, MFDB *source, MFDB *dest)
{
	if (planes > 8)
	{
/*		vro_cpyfm(vdi_handle,NOTS_AND_D,pxy,source,dest);*/
		vro_cpyfm(vdi_handle,S_AND_D,pxy,source,dest);
	}
	else
		vro_cpyfm(vdi_handle,S_OR_D,pxy,source,dest);
}