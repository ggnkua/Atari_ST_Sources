/********************************************
*		Bout2.c								*
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

extern int ballarray[], handle, paddlearray[];
extern int xwork, ywork, wwork, hwork;
extern int paddle_x, paddle_y, *lineaptr;
extern MFDB pic_buf, windsource, screen_fdb, ballsource, paddlesource;
extern MFDB bricksource, permbricksource, fujisource, fmasksource;
extern MFDB eyesource, twobricksource;
extern long score, old_score, bonus_life, old_bonus;
extern int pad_y_min, pad_y_max, brickarray[], ani_count, num_bricks;
extern int level, n_redraws, num_balls, lives, old_lives;
extern int event_kind, cheat, pad_y_top;
extern int pady_offset, max_pad_dy, pad_ht, fuji_ht, fmask_ht;

extern long get_time();
int brick_erase(), perm_flash(), brick_spin(), spin_erase();

extern RECT region[];

ANI_STRUCT ani_struct[MAX_ANI];
extern BALL_STRUCT bs[];

int magic_bell[] = {
	0x0ff,0x100,0x2fe,0x300,0x400,0x500,0x600,0x7fc,
	0x810,0x910,0xa00,0xb00,0xc20,0xd09,0xff00
	};

int bricksound[] = {
	0x035,0x100,0x234,0x300,0x400,0x500,0x600,0x7fc,
	0x810,0x910,0xa00,0xb00,0xc15,0xd09,0xff00
	};

int permbricksound[] = {
	0x038,0x100,0x237,0x300,0x400,0x500,0x600,0x7fc,
	0x810,0x910,0xa00,0xb00,0xc0b,0xd09,0xff00
	};

int death[] = {
	0x0018,0x0100,0x073e,0x0810,0x0d09,0x8000,0x0b00,0x0c60,
	0x8100,0xce01,0xff00
	};

int lost_ball[] = {
	0x0000,0x0102,0x073e,0x0810,0x0d09,0x8000,0x0b00,0x0c30,
	0x8100,0x1801,0xff00
	};

int magic_bottom, mode = 3;
int brick_ani, randomize;
extern int max_xspeed, min_yspeed;

extern int btop, btopm, bth, bh, block_bot, bleft, btw;

extern char brickcount[];

int psound[] = {
	0x041,0x100,0x240,0x300,0x400,0x500,0x600,0x7fc,
	0x810,0x910,0xa00,0xb00,0xc15,0xd09,0xff00
	};

/* move the ball to its new bounce position */

new_ball()
{
	register BALL_STRUCT *p;
	register int i;
	int l2,t2,r2,b2;
	int xt, yt;
	int o_padx, o_pady, pad_dx, pad_dy;
	int pcollide;

	for (i=0; i<num_balls; i++)
	{
		p = &bs[i];

		p->l = p->array[0] = p->array[4];
		p->t = p->array[1] = p->array[5];
		p->r = p->array[2] = p->array[6];
		p->b = p->array[3] = p->array[7];

		/* Restore the background picture to its virgin state	*/
		/* i.e.  remove the image of the ball from it.			*/

		vro_cpyfm(handle,mode,p->array,&pic_buf,&windsource);
	}

	o_padx = l2 = paddlearray[0] = paddlearray[4];
	o_pady = t2 = paddlearray[1] = paddlearray[5];
	r2 = paddlearray[2] = paddlearray[6];
	b2 = paddlearray[3] = paddlearray[7];

	/* Restore the background picture to its virgin state	*/
	/* i.e.  remove the image of the paddle from it.			*/

	vro_cpyfm(handle,mode,paddlearray,&pic_buf,&windsource);


	/* run background animations first so things appear on top of them */
	brick_ani = FALSE;				/* not animating any bricks */
	if (ani_count) animate();


/*** Calculate paddle position  **********************************/

	paddle_x = (*(lineaptr - 301)) - xwork - 25;
	if (paddle_x < 0) paddle_x = 0;
	else if (paddle_x + 52 > wwork) paddle_x = wwork - 52;
/* limit paddle_x speed here, if desired */
	pad_dx = paddle_x - o_padx;

	if (paddle_x < l2) l2 = paddle_x; else r2 = paddle_x + 52;

	paddle_y = (*(lineaptr - 300)) - ywork - pady_offset;
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

	for (i=0; i<num_balls; i++)
	{
		p = &bs[i];

	/* calculate new ball x position */
	p->x += p->xspeed;

	if (p->x <= 0)				/* ball hit left edge */
	{	
		p->xspeed = -p->xspeed;
		p->spin_dir = -p->spin_dir;
		bsound(SIDE_S);
		p->x = 0;
		if (p->xspeed == 0) p->xspeed = 1;
	}

	else if (p->x >= (wwork - (p->ball_wid+1)))	/* ball hit right edge */
	{	bsound(SIDE_S);
		p->xspeed = -p->xspeed;
		p->x = (wwork - (p->ball_wid+1));
		p->spin_dir = -p->spin_dir;
		if (p->xspeed == 0) p->xspeed = -1;
	}

	if (p->x < p->l) p->l = p->x; else p->r = p->x + p->ball_wid;

	/* calculate new ball vertical position */
	p->y += p->yspeed;

	if (p->y <= 0)				/* ball hit top of window */
	{
		rand(p);
		bsound(TOP_S);
		p->yspeed = -p->yspeed;
		p->y = 0;
		p->spin_dir = -p->spin_dir;
	}

	else if (p->y > (hwork - p->ball_ht - 1))	/* ball hit bottom of window */
	{
		if (cheat || (magic_bottom > 0))
		{
			bsound(BOT_S);
			p->yspeed = -p->yspeed;
			p->y = (hwork - p->ball_ht - 1);
			p->spin_dir = -p->spin_dir;
			magic_bottom--;
		}
		else
		{
			kill_ball(i);
			if (num_balls <= 0)
			{
				Dosound(death);
				if (--lives > 0)
				{	evnt_timer(1000,0);
					cont_level();
				}
				else
				{
					show_lives();
					n_redraws = 0;
					add_region(xwork,ywork,wwork,hwork);
					do_redraw();
					event_kind = MU_MESAG;
				}
				goto end;
			}

			Dosound(lost_ball);
			i--;	/* a new ball takes this slot */
			goto loopend;
		}
	}


/******************************************************
	We have now calculated the projected next positions
	for the ball and paddle. Time to look for brick and
	paddle collisions!
******************************************************/

	xt = p->x + p->half_wid; yt = p->y + p->ball_ht;
	if (yt >= paddle_y && xt >= paddle_x && (xt <= paddle_x + 52))
	{
		pcollide = FALSE;

		/* if ball passed into paddle from the top */
		if (yt <= (paddle_y + p->yspeed - pad_dy))
		{
			pcollide = TRUE;

			if (p->yspeed > 0) p->yspeed = -p->yspeed;
			p->yspeed += pad_dy;
			if (p->yspeed < min_yspeed) p->yspeed = min_yspeed;
			p->y = paddle_y - p->ball_ht;
		}

		/* else if the ball in the paddle nevertheless */
		else if (p->y <= paddle_y + pad_ht)
		{
			if ((p->xspeed * pad_dx) <= 0) p->xspeed = -p->xspeed;
			pcollide = TRUE;
		}

		if (pcollide)
		{
			p->spin_dir = -p->spin_dir;
			Dosound(psound);

			p->xspeed += pad_dx/2;
			if (p->xspeed < -max_xspeed) p->xspeed = -max_xspeed;
			else if (p->xspeed > max_xspeed) p->xspeed = max_xspeed;

			if (p->xspeed == 0)		/* too easy! */
			{
				if (++randomize & 1) p->xspeed = -1;
				else p->xspeed = 1;
			}
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

	vro_cpyfm(handle,7,paddlearray,&paddlesource,&windsource);

	/* Whew! we are now done creating the ball image in our background	*/
	/* buffer. Now we must blit the updated picture into the boink		*/
	/* window. The area we must update is the smallest rectangle that	*/
	/* will enclose both the ball's old position and its new one. This	*/
	/* technique will erase the old ball and draw in the new one		*/
	/* without any flickering of the image. Note also that the area		*/
	/* we update must be clipped to our windows rectangle list so that	*/
	/* we don't trash the contents of another window.					*/


	/* Use the rectangle list to draw the window in an orderly fashion */

	add_region(xwork + l2,ywork + t2,r2-l2+1,b2-t2+1);

	do_redraw();
end:;
}


bcollide(i)
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
			case -1:
				Dosound(permbricksound);
				add_ani(perm_flash,x,y);
				rand(p);
				break;
			case 1:
				Dosound(bricksound);
				brick_ani = TRUE;
				brickcount[ndx] = 0;
				add_ani(brick_erase,x,y);
				num_bricks--;
				score += 10;
				show_score();
				break;

			case 2:					/* magic */
				Dosound(magic_bell);
				brickcount[ndx] = 0;
				erase_brick(x,y);
				num_bricks--;
				magic(i);
				score += 13;
				show_score();
				break;

			case 3:
				Dosound(bricksound);
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
				Dosound(bricksound);
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
animate()
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
fixx(p)
register BALL_STRUCT *p;
{
	if (p->x < 0)								/* ball hit left edge */
		p->x = 0;

	else if (p->x >= (wwork - (p->ball_wid+1)))	/* ball hit right edge */
		p->x = (wwork - (p->ball_wid+1));
}

add_ani(f,x,y)
int (*f)();
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

kill_ani(n)
{
	register int i;
	ani_count--;
	for (i = n; i < ani_count; i++)
		ani_struct[i] = ani_struct[i+1];	/* structure assignment */
}

/*** animation function to erase a standard brick ***/
brick_erase(x,y,frame)
{
	brick_ani = TRUE;
	frame++;			/* we start at 1 */

	if (mode == BLACKMODE) goto nd;

	brickarray[0] = brickarray[4] = x;
	brickarray[1] = brickarray[5] = y;
	brickarray[2] = brickarray[6] = x + 43;
	brickarray[3] = brickarray[7] = y + bh - 1;

	/* erase old brick */
	vro_cpyfm(handle,3,brickarray,&pic_buf,&windsource);

	brickarray[0] = frame * btw;
	brickarray[1] = 0;
	brickarray[2] = brickarray[0] + 43;
	brickarray[3] = bh - 1;

	/* draw new brick */
	if (frame < 4)
		vro_cpyfm(handle,7,brickarray,&bricksource,&windsource);

	add_region(xwork + x, ywork + y, 44, bh);
nd:
	if (frame < 4) return FALSE;
	return TRUE;	/* all done! */
}

/*** animation function to flash a permanent brick ***/
perm_flash(x,y,frame)
{
	register int f2;

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
	vro_cpyfm(handle,3,brickarray,&permbricksource,&windsource);

	add_region(xwork + x, ywork + y, 44, bh);

	if (frame < 6) return FALSE;
	return TRUE;	/* all done! */
}


/**************************************
animate a boink ball
**************************************/
ball_ani(p)
register BALL_STRUCT *p;
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

	vro_cpyfm(handle,4,p->array,&ballsource,&windsource);

	/* blit the ball into the white hole we just cut out of the picture */
	/* with the mask */

	p->array[0] = 20 * p->ball_num;
	p->array[2] = 20 * (p->ball_num+1);

	vro_cpyfm(handle,7,p->array,&ballsource,&windsource);
	add_region(xwork + p->l, ywork + p->t,
		p->r - p->l + 1, p->b - p->t + 1);
}

char fn[] = { 0,0,0,0,1,1,1,2,3,4,5,6,5,4,3,2,1 };
/**************************************
animate a spinning fuji
**************************************/
fuji_ani(p)
register BALL_STRUCT *p;
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

	vro_cpyfm(handle,4,p->array,&fmasksource,&windsource);

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

	vro_cpyfm(handle,7,p->array,&fujisource,&windsource);

	p->array[5] = p->y;
	p->array[7] = p->y + fmask_ht - 1;

	add_region(xwork + p->l, ywork + p->t,
		p->r - p->l + 1, p->b - p->t + 1);
}

char efn[] = { 0,0,1,2,1,0,1,2,1,0,0,3,4,5,4,3 };
/**************************************
animate an eye
**************************************/
eye_ani(p)
register BALL_STRUCT *p;
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

	vro_cpyfm(handle,4,p->array,&eyesource,&windsource);

	/* blit the ball into the white hole we just cut out of the picture */
	/* with the mask */

	p->array[0] = 20 * ndx;
	p->array[2] = 20 * (ndx + 1);

	vro_cpyfm(handle,7,p->array,&eyesource,&windsource);

	add_region(xwork + p->l, ywork + p->t,
		p->r - p->l + 1, p->b - p->t + 1);
}

brick_spin(x,y,frame)
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
	vro_cpyfm(handle,3,brickarray,&pic_buf,&windsource);

	brickarray[0] = f2 * 48;
	brickarray[1] = 0;
	brickarray[2] = brickarray[0] + 43;
	brickarray[3] = bh - 1;

	/* draw new brick */
	vro_cpyfm(handle,7,brickarray,&twobricksource,&windsource);

	add_region(xwork+x,ywork+y, 44, bh);
nd:
	if (frame < 5) return FALSE;
	return TRUE;	/* all done! */
}

spin_erase(x,y,frame)
{
	brick_ani = TRUE;
	frame+=2;			/* we start at 2 */

	if (mode == BLACKMODE) goto nd;

	brickarray[0] = brickarray[4] = x;
	brickarray[1] = brickarray[5] = y;
	brickarray[2] = brickarray[6] = x + 43;
	brickarray[3] = brickarray[7] = y + bh - 1;

	/* erase old brick */
	vro_cpyfm(handle,mode,brickarray,&pic_buf,&windsource);

	brickarray[0] = frame * 48;
	brickarray[1] = 0;
	brickarray[2] = brickarray[0] + 43;
	brickarray[3] = bh - 1;

	/* draw new brick */
	if (frame < 4)
		vro_cpyfm(handle,7,brickarray,&twobricksource,&windsource);

	add_region(xwork+x, ywork+y, 44, bh);
nd:
	if (frame < 4) return FALSE;
	return TRUE;	/* all done! */
}

/* used to erase a magic brick */
erase_brick(x,y)
{
	brickarray[0] = brickarray[4] = x;
	brickarray[1] = brickarray[5] = y;
	brickarray[2] = brickarray[6] = x + 43;
	brickarray[3] = brickarray[7] = y + bh - 1;

	vro_cpyfm(handle,mode,brickarray,&pic_buf,&windsource);
	add_region(xwork+x,ywork+y,44,bh);
}

rand(p)
register BALL_STRUCT *p;
{
	register int val;

	if (++randomize > 40)
	{
		val = (Supexec(get_time) & 3);
		if (val > 2) val = 2;

		randomize = 0;
		p->xspeed += val;
		while (p->xspeed > max_xspeed)
			p->xspeed -= (Supexec(get_time) & 3);
	}
}
