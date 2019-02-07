/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/*									 */
/*			  IO.C - SOLITAIRE INPUT			 */
/*									 */
/*                             by Rob Lech                               */
/*	           (C) Copyright 1988, Antic Publishing, Inc.  		 */
/*									 */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

/*---------------------------- INCLUDED FILES ----------------------------*/

#include "gemdefs.h"		/* GEM DEFINITIONS */
#include "obdefs.h"		/* OBJECT DEFINITIONS */
#include "osbind.h"		/* OPERATING SYSTEM DEFINITIONS */
#include "portab.h"		/* PORTABILITY DEFINITIONS */

/*--------------------- GEM AES VARIABLE DECLARATIONS --------------------*/

extern long *re_gaddr;
extern int  ev_mgpbuff[16];

/*----------------------- GEM VARIABLE DECLARATIONS ----------------------*/

extern int contrl[12], intin[256], ptsin[256], intout[256], ptsout[256];
extern int handle, fd;

extern int pxyarray[16], color_index[2], set_color;
extern int drgx, drgy;
extern int gr_1, gr_2, gr_3, gr_4, ret;
extern int *ascii, r, c, n, x, y, fcol, msx, msy, msb_flag, rgb[3];
extern int ioflags, inc, inb, inr;
extern int l_intin[20], l_ptsin[20], l_out[100];

/*-------------------- VARIABLES DEFINED IN SBODY.C --------------------*/

extern	int	a, b, bx[2], by[2], draw[24], drw_ptr;
extern	int	mv_from, mv_to, mv_num, mv_card;
extern	int	stack[7][18];		/* 7 STACKS OF CARDS IN PLAY */
extern	int	stk_dn[7];		/* NUMBER CARDS IN STACK FACE DOWN */
extern	int	stk_up[7];		/* NUMBER CARDS IN STACK FACE UP */

/***************************** PROCESS INPUT *****************************/

io()
{
char instr[2];

io_loop:
	ioflags = evnt_multi(23,1,1,1,1,2,2,0,0,1,2,2,0,0,ev_mgpbuff,100,0,&msx,&msy,&inc,&inb,&instr,&inr);

/*----------------------- PROCESS KEYBOARD INPUT -----------------------*/

	ascii = instr;

	if (ioflags & 1 && *ascii == 0x2207)	/* PROCESS ^G */
	{
	    return(1);
	}

	if (ioflags & 1 && *ascii == 0x2e03)	/* PROCESS ^C */
	{
	    return(2);
	}

/*-------------------------- PROCESS MOUSE INPUT --------------------------*/

	if (~ioflags & 2)
	{
	    msb_flag = 0;			/* MOUSE BUTTON IS UP */
	    return(0);
	}

	if (msb_flag != 0) return(0);		/* MOUSE BUTTON WAS DOWN */

/*------------------ TEST FOR GAME / EXIT / FILE / HELP ------------------*/

	for (a = 0; a < 2; a++)
	{
	    if (msx>=bx[a] && msx<bx[a]+33 && msy>=by[a] && msy<by[a]+15)
	    {
		msb_flag = 1;
		return(a + 1);
	    }
	}

/*----------------------- TEST FOR DRAWING CARDS -----------------------*/

	if (msx > 3 && msx < 39 && msy > 159 && msy < 200)
	{
	    msb_flag = 1;

	    if (drw_ptr==24 || draw[drw_ptr + 1]==0)	/* END O'DECK */
	    {
		drw_ptr = -1;
		show_draw();
		return(0);
	    }

	    drw_ptr += 3;
	    if (draw[drw_ptr] == 0) drw_ptr -= 1;
	    if (draw[drw_ptr] == 0) drw_ptr -= 1;
	    if (draw[drw_ptr] == 0) drw_ptr -= 1;
	    show_draw();
	    return(0);
	}

/*-------------------- TEST FOR DRAGGING DRAWN CARD --------------------*/

    mv_from = -1;
    mv_to = -1;
    mv_num = 0;
    mv_card = 0;

    if (drw_ptr != -1 && msx > 42 && msx < 77 && msy > 159 && msy < 200)
    {
	mv_from = 12;
	mv_num = 1;
	mv_to = -1;
	mv_card = draw[drw_ptr];
	drgx = 43;
	drgy = 160;
	goto show_box;
    }

/*------------------- TEST FOR DRAGGING STACKED CARD(S) -------------------*/

    a = 0;

    while (a < 7 && mv_from == -1)
    {
	b = 0;
	while (b < stk_up[a])
	{
	    x = (44 * a) + stk_dn[a] + b;
	    y = stk_dn[a] + (b * 13);

	    if (msx >= x && msx < x + 35 && msy >= y && msy < y + 39 && msy < 155)
	    {
		mv_from = a;
		mv_num = stk_up[a] - b;
		mv_card = stack[a][stk_dn[a] + b];
		drgx = x;
		drgy = y;
	    }

	    b += 1;
	}
	a += 1;
    }

    if (mv_from == -1) return(0);

show_box:
    msb_flag = 1;
    ret = graf_dragbox(34 + mv_num,39 + (13 * (mv_num - 1)),drgx,drgy,0,0,320,200,&drgx,&drgy);

/*-------------------- DID BOX LAND ON STACKS? --------------------*/

    for (a = 0; a < 7; a++)
    {
	x = (44 * a) + stk_dn[a] + stk_up[a] - 1;
	y = stk_dn[a] + ((stk_up[a] - 1) * 13);
	if (y < 0) y = 0;

	if (drgx >= x && drgx < x + 35 && drgy >= y && drgy < y + 39 && drgy < 155)
	{
	    mv_to = a;
	    if (mv_to == mv_from) return(0);
	    goto end_mv1;
	}
    }

/*--------------------- DID BOX LAND ON ACES? ---------------------*/

    for (a = 0; a < 4; a++)
    {
	x = 165 + (39 * a);
	if (drgx >= x && drgx < x + 35 && drgy >= 160 && drgy < 199)
	{
	    mv_to = a + 8;
	    if (mv_num > 1) return(0);
	    goto end_mv1;
	}
    }

end_mv1:
    if (mv_to == -1) return(0);

    return(5);

io_out:
	return(0);

}

