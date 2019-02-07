/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/*									 */
/*			       SOLITAIRE BODY				 */
/*									 */
/*                               by Rob Lech                             */
/*	            (C) Copyright 1988, Antic Publishing		 */
/*									 */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

/*---------------------------- INCLUDED FILES ----------------------------*/

#include "gemdefs.h"		/* GEM DEFINITIONS */
#include "obdefs.h"		/* OBJECT DEFINITIONS */
#include "osbind.h"		/* OPERATING SYSTEM DEFINITIONS */
#include "portab.h"		/* PORTABILITY DEFINITIONS */

/*--------------------- GEM AES VARIABLE DECLARATIONS --------------------*/

long	*re_gaddr;
int	ev_mgpbuff[16];

/*----------------------- GEM VARIABLE DECLARATIONS ----------------------*/

int	contrl[12], intin[256], ptsin[256], intout[256], ptsout[256];
int	handle, fd;

int	pxyarray[16], color_index[2], set_color;
int	drgx, drgy;
int	gr_1, gr_2, gr_3, gr_4, ret;
int	*ascii, r, n, fcol, msx, msy, msb_flag;
int	ioflags, inc, inb, inr;
int	l_intin[20], l_ptsin[20], l_out[100];
int	ap_id, me_rmenuid;

int	x, y, w, h, win_han;
long	scr, *scrloc;

/*-------------------- SOLITAIRE VARIABLE DECLARATIONS --------------------*/

int	old_pal[16];		/* PALLETE BEFORE RUNNING SOLITAIRE */
int	set_flag, rgb[3];	/* VARS FOR SETTING OLD PAL */
int	first_deal;		/* FLAG FOR FIRST DEAL */
int	count1;			/* TEMPORARY COUNTER */
int	count2;			/* TEMPORARY COUNTER */
int	aces[4];		/* LAST OF EACH SUIT OUT OF PLAY */
int	stack[7][18];		/* 7 STACKS OF CARDS IN PLAY */
int	stk_dn[7];		/* NUMBER OF CARDS IN STACK FACE DOWN */
int	stk_up[7];		/* NUMBER OF CARDS IN STACK FACE UP */
int	draw[24];		/* 24 CARDS TO DRAW FROM */
int	deck[52];		/* 52 CARDS IN DECK */
int	drw_ptr;		/* POINTER TO LAST CARD DRAWN */
int	mv_from, mv_to;		/* MOVEMENT VARIABLES */
int	mv_num, mv_card;
int	c_suit;			/* SUIT OF CARD */
int	c_value;		/* VALUE OF CARD */
int	t_suit;			/* TEST SUIT OF CARD */
int	t_value;		/* TEST VALUE OF CARD */
int	winner;			/* FLAG FOR WIN BELLS & WHISTLES */
int	a,b,d,e,f,g;		/* TEMPORARY COUNTERS */

extern	char	menu_desc[10];		/* DESKTOP ACCESSORY DESCRIPTION */
extern	int	gem_pix[16];		/* GEM PIXEL TRANSLATION ARRAY */
extern	int	sol_pal[16];		/* SOLITAIRE PALETTE */
extern	int	c_color[4];		/* COLOR OF THE FOUR SUITS */
extern	int	pattern[10][17];	/* PATTERN OF SUITS ON CARDS */
extern	int	sx[17], sy[17];		/* (X,Y) OF SUITS IN PATTERN */
extern	int	bx[2], by[2];		/* (X,Y) OF BUTTONS */
extern	long	SCREEN;			/* SCREEN MEMORY FORM DEFINITION */
extern	long	tmfdb;			/* TEMP MEMORY FORM DEFINITION */
extern	long	bmfdb;			/* TEMP MEMORY FORM DEFINITION */
extern	long	cmfdb;			/* TEMP MEMORY FORM DEFINITION */
extern	long	button[2];		/* BUTTON GRAPHICS POINTERS */
extern	long	backs[4];		/* PICTURE GRAPHICS POINTERS */
extern	long	ltl_usuit[4];		/* POINTERS TO SMALL SUIT GRAPHICS */
extern	long	ltl_dsuit[4];		/* POINTERS TO SMALL SUIT GRAPHICS */
extern	long	big_usuit[4];		/* POINTERS TO LARGE SUIT GRAPHICS */
extern	long	big_dsuit[4];		/* POINTERS TO LARGE SUIT GRAPHICS */
extern	long	uval[13];		/* POINTERS TO GRAPHIC VALUES */
extern	long	dval[13];		/* POINTERS TO GRAPHIC VALUES */

/*------------------------------ MAIN LOGIC ------------------------------*/

main()
{

/*--------------------------- SET UP GEM STUFF ---------------------------*/

start:
    setup();			/* SET UP GEM STUFF */

/*--------------------------- SAVE OLD PALETTE ---------------------------*/

    for (count1 = 0; count1 < 16; count1++)
    {
	set_flag = 1;
	vq_color(handle, count1, set_flag, rgb);

	rgb[0] = (rgb[0] + 1) * 7 / 1000;
	rgb[1] = (rgb[1] + 1) * 7 / 1000;
	rgb[2] = (rgb[2] + 1) * 7 / 1000;
	old_pal[gem_pix[count1]] = rgb[0] * 256 + rgb[1] * 16 + rgb[2];
    }

    if (l_out[13] < 5)		/* EXIT IF NOT LOW RESOLUTION */
    {
	goto lowout;
    }

    Setpallete(&sol_pal);	/* SET PALLETE */
    SCREEN = Physbase();	/* GET SCREEN POINTER */
    show_butn();		/* SHOW PLAYING SURFACE */

loop:
    deal();			/* SHUFFLE & DEAL NEW GAME */
    show_game();		/* DISPLAY THE GAME */

loop2:
    ret = io();

    if (ret == 1)			/* NEW GAME */
    {
	winner = 1;			/* ASSUME A WINNER */

	if (draw[1]) winner = 0;	/* NO WIN IF CARDS LEFT TO DRAW */

	for (a = 0; a < 7; a++)
	{
	    if (stk_dn[a]) winner = 0;	/* NO WIN IF CARDS STILL HIDDEN */
	}

	for (a = 0; a < 4; a++)
	{
	    if (aces[a] == 0) winner = 0;	/* NO WIN IF NONE DISCARDED */
	}

	goto loop;
    }
    if (ret == 2) goto getout;	/* EXIT PROGRAM */
    if (ret == 5) move();	/* RE-ARRANGE STACKS */
    if (ioflags & 2) msb_flag = 1;

/*-------------------- HAS PLAYER WON THE GAME? --------------------*/

    if (aces[0] == 13 && aces[1] == 26 && aces[2] == 39 && aces[3] == 52)
    {
	winner = 1;
	goto loop;
    }

    goto loop2;

/*------------------------- Close the Workstation -------------------------*/

getout:

    ret = form_alert(2,"[3][   | Are you certain that   | you wish to exit   | Klondike?][Exit|Oops]");

    if (ret == 2)
    {
	ret = graf_mouse(3,0,0);	/* CHANGE MOUSE FORM TO HAND */
	goto loop2;
    }

    v_hide_v(handle);
    v_clrwk(handle);			/* CLEAR THE SCREEN */
    ret = wind_close(win_han);		/* CLOSE WINDOW */
    ret = wind_delete(win_han);		/* DELETE WINDOW */
    v_show_c(handle,0);
    Setpallete(&old_pal);		/* RESET PALLETE */

lowout:
    v_clsvwk(handle);			/* CLOSE THIS WORKSTATION */
    appl_exit();			/* EXIT THE APPLICATION */
}

/******************* SET UP WORKSTATION FOR USE WITH GEM *******************/

setup()
{

/*------------------------- Open the workstation -------------------------*/

    ap_id = appl_init();
    me_rmenuid = menu_register(ap_id,"  Klondike");

/*await_open:
    ret = appl_read(ap_id,16,ev_mgpbuff);
    if (ev_mgpbuff[0] == 30) goto acc_open;
    goto await_open;
*/

acc_open:
    handle = graf_handle(&gr_1,&gr_2,&gr_3,&gr_4);

    l_intin[0] = 1;		/* DEVICE ID NUMBER (1=SCREEN) */
    l_intin[1] = 1;		/* LINETYPE
    l_intin[2] = 1;		/* POLYLINE COLOR INDEX */
    l_intin[3] = 1;		/* MARKER TYPE */
    l_intin[4] = 1;		/* POLYMARKER COLOR INDEX */
    l_intin[5] = 1;		/* TEXT FACE */
    l_intin[6] = 1;		/* TEXT COLOR INDEX */
    l_intin[7] = 1;		/* FILL INTERIOR STYLE */
    l_intin[8] = 1;		/* FILL STYLE INDEX */
    l_intin[9] = 1;		/* FILL COLOR INDEX */
    l_intin[10] = 2;		/* USE RASTER (640 X 400) COORDINATES */

    v_opnvwk(l_intin, &handle, l_out);

/*----------------- Check if screen is in low resolution -----------------*/

    if (l_out[13] < 5)
    {
	form_alert(1,"[3][You must set the screen|resolution to LOW before|playing Klondike.][Sorry]");
	return;
    }

    evnt_dclick(4,1);		/* SET DOUBLE CLICK LENGTH */
    ret = graf_mouse(3,0,0);	/* CHANGE MOUSE FORM TO HAND */
    ret = vswr_mode(handle,2);	/* WRITE MODE = TRANSPARENT */

    v_hide_c(handle);
    wind_calc(0,0x000b,-2,-2,326,206,&x,&y,&w,&h);
    win_han = wind_create(0x000b,x,y,w,h);
    wind_set(win_han,2,'\0',a,b);
    wind_open(win_han,x,y,w,h);
    v_show_c(handle,0);

set_ret:

    return;
}

/****************************** DEAL NEW GAME *****************************/

deal()
{

/*------------------------- CLEAR ALL VARIABLES -------------------------*/

    drw_ptr = -1;
    aces[0] = 0;
    aces[1] = 0;
    aces[2] = 0;
    aces[3] = 0;

/*------------------------ CLEAR DECK & DRAW PILE ------------------------*/

    for(count1 = 0; count1 < 52; count1++)
    {
	deck[count1] = 0;
	if (count1 < 24) draw[count1] = 0;
    }

/*------------------------- CLEAR STACK VARIABLES -------------------------*/

    for (count1 = 0; count1 < 7; count1++)
    {
	for (count2 = 0; count2 < 18; count2++)
	{
	    stack[count1][count2] = 0;
	}
    }

    if (first_deal == 0) goto deal_ret;

/*-------------------- RANDOMLY CHOOSE ORDER OF CARDS --------------------*/

    for (x = 0; x < 24; x++)
    {
again1:
	draw[x] = Random();			/* GET 16-BIT RANDOM NUMBER */
	draw[x] = draw[x] & 0x7fff;		/* MAKE IT POSITIVE */
	draw[x] = draw[x] % 52;			/* GET NUMBER 0 - 51 */

	if (deck[draw[x]] == 1) goto again1;

	deck[draw[x]] = 1;			/* MARK CARD AS CHOSEN */
	draw[x] += 1;
    }

/*----------------------- DEFINE STACKS OF CARDS -----------------------*/

    for (x = 0; x < 7; x++)
    {
	for (y = 0; y < x + 1; y++)
	{
again2:
	stack[x][y] = Random();			/* GET 16-BIT RANDOM NUMBER */
	stack[x][y] = stack[x][y] & 0x7fff;
	stack[x][y] = stack[x][y] % 52;

	if (deck[stack[x][y]] == 1) goto again2;

	deck[stack[x][y]] = 1;			/* MARK CARD AS CHOSEN */
	stack[x][y] += 1;			/* PLACE CARD IN STACK */
	}

	stk_dn[x] = x;		/* DEFINE NUMBER OF CARDS FACE DOWN */
	stk_up[x] = 1;		/* DEFINE NUMBER OF CARDS FACE UP */
    }

deal_ret:
    return;
}

/************************** CLEAR ENTIRE SCREEN **************************/

cls()
{
    v_hide_c(handle);				/* ERASE CURSOR */

    pxyarray[0] = 0;
    pxyarray[1] = 0;
    pxyarray[2] = 319;
    pxyarray[3] = 199;
    set_color = vsf_color(handle,0);		/* SET BACKGROUND COLOR */
    vr_recfl(handle,pxyarray);			/* CLEAR SCREEN */

    v_show_c(handle,0);
    return;
}

/************************ DISPLAY PLAYING SURFACE ************************/

show_butn()
{
    v_hide_c(handle);

    v_clrwk(handle);		/* CLEAR THE SCREEN */

    pxyarray[0] = 0;
    pxyarray[1] = 155;
    pxyarray[2] = 319;
    pxyarray[3] = 155;
    set_color = vsf_color(handle,3);		/* SET COLOR TO BLACK */
    vr_recfl(handle,pxyarray);			/* DRAW HORIZ LINE */

/* DRAW BOX (82,155) - (160,199)

/*----------------------- LOOP THROUGH BUTTONS -----------------------*/

    for (a = 0; a < 2; a++)
    {
	bmfdb = button[a];
	pxyarray[0] = 0;
	pxyarray[1] = 0;
	pxyarray[2] = 32;
	pxyarray[3] = 14;
	pxyarray[4] = bx[a];
	pxyarray[5] = by[a];
	pxyarray[6] = bx[a] + 32;
	pxyarray[7] = by[a] + 14;
	vro_cpyfm(handle,7,pxyarray,&bmfdb,&SCREEN);
    }

/* display menu */

    ret = vst_color(handle,4);
    v_gtext(handle,92,98,"Copyright 1988 By");
    ret = vst_effects(handle,0);
    v_gtext(handle,74,108,"ANTIC Publishing Inc.");
    v_gtext(handle,88,118,"The Atari Resource");

    ret = vst_color(handle,3);
    ret = vst_effects(handle,4);
    v_gtext(handle,115,128,"Written by");
    v_gtext(handle,70,138,"The Rugby Circle, Inc.");

    ret = vst_effects(handle,1);
    ret = vst_color(handle,2);
    v_gtext(handle,87,50,"K L O N D I K E ");

    v_show_c(handle,0);

    return;
}

/*************************** DISPLAY DRAW PILES ****************************/

show_draw()
{
    v_hide_c(handle);				/* ERASE CURSOR */
    card_out(4,160,54);				/* SHOW OUTLINE */
    if (drw_ptr < 24 && draw[drw_ptr + 1] != 0) card_out(4,160,53);

    card_out(43,160,54);			/* SHOW OUTLINE */
    if (drw_ptr != -1) card_out(43,160,draw[drw_ptr]);

    v_show_c(handle,1);				/* SHOW CURSOR (IF NEEDED) */
    return;
}

/***************************** DRAW GAME SETUP *****************************/

show_game()
{
    v_hide_c(handle);				/* ERASE CURSOR */

    if (first_deal == 0) goto skip_clear;

    pxyarray[0] = 0;
    pxyarray[1] = 0;
    pxyarray[2] = 319;
    pxyarray[3] = 154;
    set_color = vsf_color(handle,0);		/* SET BACKGROUND COLOR */
    vr_recfl(handle,pxyarray);			/* CLEAR SCREEN */

skip_clear:
    first_deal = 1;
    show_draw();				/* SHOW DRAW PILES */

/*------------------------ LOOP THROUGH ACES ------------------------*/

    for (a = 0; a < 4; a++)
    {
	x = 165 + (39 * a);
	y = 160;
	card_out(x,y,54);				/* SHOW OUTLINE */

	tmfdb = big_usuit[a];
	color_index[0] = c_color[a];
	pxyarray[0] = 0;
	pxyarray[1] = 0;
	pxyarray[2] = 6;
	pxyarray[3] = 6;
	pxyarray[4] = x + 14;
	pxyarray[5] = y + 16;
	pxyarray[6] = pxyarray[4] + 6;
	pxyarray[7] = pxyarray[5] + 6;
	vrt_cpyfm(handle, 2, pxyarray, &tmfdb, &SCREEN, color_index);
    }

/*--------------- DO CARD TRICKS IF PLAYER WON LAST GAME ---------------*/

    if (winner == 0) goto no_win;

    ret=vst_effects(handle,0);
    ret=vst_color(handle,2);
    ret=vst_height(handle,25,&gr_1,&gr_2,&gr_3,&gr_4);
    v_gtext(handle,40,85,"CONGRATULATIONS!");

    y = 0;
    for (x = 282; x > 0; x -= 10)
    {
	card_out(x,y,53);		/* SHOW BACKS OF CARDS */
	ret = evnt_timer(25,0);
    }

    for (x = 2; x < 283; x += 10)
    {
	card_out(x,y,1 + x/10);		/* SHOW FACES OF CARDS */
	ret = evnt_timer(25,0);
    }

    for (x = -33; x < 248; x += 10)
    {
	card_out(x,y,0);		/* ERASE CARDS */
	ret = evnt_timer(40,0);
    }

    card_out(282,0,0);			/* ERASE LAST CARD */

    ret=vst_color(handle,0);
    ret=vst_height(handle,25,&gr_1,&gr_2,&gr_3,&gr_4);
    v_gtext(handle,40,85,"CONGRATULATIONS!");

    ret = graf_mouse(3,0,0);		/* CHANGE MOUSE FORM TO HAND */
    winner = 0;

/*----------------------- LOOP THROUGH STACKS -----------------------*/

no_win:

    for (a = 0; a < 7; a++)
    {
	x = (44 * a);
	y = 0;
	b = 0;

	card_out(x,y,54);		/* SHOW OUTLINE OF A CARD */

/*-------------------- LOOP THROUGH HIDDEN CARDS --------------------*/

	while (stk_dn[a] > b)
	{
	    card_out(x, y, 53);		/* SHOW BACK OF CARD */
	    x += 1;
	    y += 1;
	    b += 1;
	}

/*-------------------- LOOP THROUGH SHOWN CARDS --------------------*/

	while (stk_dn[a] + stk_up[a] > b)
	{
	    card_out(x,y,stack[a][b]);
	    x += 1;
	    y += 13;
	    b += 1;
	}
    }

    v_show_c(handle,0);			/* RE-DISPLAY CURSOR */

    return;
}

/*********************** RE-ARRANGE STACKED / DRAWN ***********************/

move()
{

/*-------------------- MOVE CARD TO DISCARD PILE --------------------*/

    if (mv_to > 7)
    {
	if (aces[mv_to - 8] == 0 && mv_card != (mv_to - 8) * 13 + 1) goto end_move;
	if (aces[mv_to - 8] != 0 && (aces[mv_to - 8] != mv_card - 1 || mv_card > (mv_to - 7) * 13)) goto end_move;

	aces[mv_to - 8] = mv_card;
	card_out(165 + (39 * (mv_to - 8)),160,aces[mv_to - 8]);
    }

/*-------------------------- MOVE CARD TO STACK --------------------------*/

    if (mv_to < 8)
    {
	c_suit = crd_suit(mv_card);
	c_value = crd_val(mv_card);

	b = stk_up[mv_to] + stk_dn[mv_to];

	if (b == 0 && c_value == 13) goto mv_kng;
	if (b == 0 && c_value != 13) goto end_move;
	if (c_value == 1) goto end_move;

	t_suit = crd_suit(stack[mv_to][b - 1]);
	t_value = crd_val(stack[mv_to][b - 1]);

	if (c_color[c_suit] == c_color[t_suit]) goto end_move;
	if (c_value != t_value - 1) goto end_move;

mv_kng:
	for (a = 0; a < mv_num; a++)
	{
	    stk_up[mv_to] += 1;
	    stack[mv_to][b + a] = mv_card;

	    if (a > 0)
	    {
		d = stk_dn[mv_from] + stk_up[mv_from] - mv_num + a;
		stack[mv_to][b + a] = stack[mv_from][d];
	    }

	    x = (44 * mv_to) + stk_dn[mv_to] + stk_up[mv_to] - 1;
	    y = stk_dn[mv_to] + ((stk_up[mv_to] - 1) * 13);
	    card_out(x,y,stack[mv_to][b + a]);
	}
    }

/*----------------------- MOVE CARD FROM DRAW PILE -----------------------*/

    if (mv_from == 12)
    {
	for (a = drw_ptr; a < 23; a++)
	{
	    draw[a] = draw[a + 1];
	}

	draw[23] = 0;
	drw_ptr -= 1;

	show_draw();
    }

/*------------------------- MOVE CARD FROM STACK -------------------------*/

    if (mv_from < 8)
    {
	for (a = 1; a <= mv_num; a++)
	{
	    stack[mv_from][stk_dn[mv_from] + stk_up[mv_from] - 1] = 0;
	    x = (44 * mv_from) + stk_dn[mv_from] + stk_up[mv_from] - 1;
	    y = stk_dn[mv_from] + ((stk_up[mv_from] - 1) * 13);
	    card_out(x,y,0);
	    stk_up[mv_from] -= 1;
	}

	if (stk_up[mv_from] == 0 && stk_dn[mv_from] != 0)
	{
	    stk_dn[mv_from] -= 1;
	    stk_up[mv_from] = 1;
	}

	if (stk_up[mv_from] != 0)
	{
	    x = (44 * mv_from) + stk_dn[mv_from] + stk_up[mv_from] - 1;
	    y = stk_dn[mv_from] + ((stk_up[mv_from] - 1) * 13);
	    card_out(x,y,stack[mv_from][stk_dn[mv_from] + stk_up[mv_from]-1]);
	}

	if (stk_up[mv_from] == 0 && stk_dn[mv_from] == 0)
	{
	    x = (44 * mv_from);
	    card_out(x,0,54);
	}
    }

end_move:
    return;
}

/************************* CALCULATE CARD SUIT *************************/

crd_suit(c)
int c;
{
    c = (c - 1) / 13;
    return(c);				/* CALCULATE SUIT */
}

/************************* CALCULATE CARD VALUE *************************/

crd_val(c)
int c;
{
int suit;
    suit = crd_suit(c);
    c = c - (suit * 13);
    return(c);			/* CALCULATE VALUE OF CARD */
}

/************************* DISPLAY CARD ON SCREEN *************************/

/* CARD TYPES : */
/* 0 = ERASE CARD */
/* 1 - 52 = CARDS */
/* 53 = BACK OF CARD */
/* 54 = OUTLINE OF CARD */

card_out(x,y,c)
int x,y,c;
{
    v_hide_c(handle);

    if (y < 155)			/* SET CLIPPING FOR TOP OF SCREEN */
    {
	pxyarray[0] = 0;
	pxyarray[1] = 0;
	pxyarray[2] = 319;
	pxyarray[3] = 154;
	vs_clip(handle, 1, pxyarray);
    }

    c_suit = crd_suit(c);
    c_value = crd_val(c);

    pxyarray[0] = x;				/* SET COORDS OF CARD */
    pxyarray[1] = y;
    pxyarray[2] = x + 34;
    pxyarray[3] = y + 38;
    set_color = vsf_color(handle,2);		/* SET CARD COLOR TO WHITE */
    if (c == 0) set_color = vsf_color(handle, 0);	/* GREEN */
    if (c == 53) set_color = vsf_color(handle, 9);	/* GRAY */
    if (c == 54) set_color = vsf_color(handle, 3);	/* BLACK */
    vr_recfl(handle,pxyarray);			/* DRAW FILLED RECTANGLE */

    if (c == 0) goto card_ret;			/* FINISHED ERASING CARD */

    if (c == 53 || c_value > 10)
    {
	if (c_value > 10) cmfdb = backs[c_value - 11];
	if (c == 53) cmfdb = backs[3];
	pxyarray[0] = 0;
	pxyarray[1] = 0;
	pxyarray[2] = 26;
	pxyarray[3] = 30;
	pxyarray[4] = x + 4;
	pxyarray[5] = y + 4;
	pxyarray[6] = x + 30;
	pxyarray[7] = y + 34;
	vro_cpyfm(handle,3,pxyarray,&cmfdb,&SCREEN);
    }

    if (c == 53) goto card_ret;

    if (c == 54)
    {
	set_color = vsf_color(handle, 0);	/* SET COLOR TO GREEN */
	pxyarray[0] += 1;
	pxyarray[1] += 1;
	pxyarray[2] -= 1;
	pxyarray[3] -= 1;
	vr_recfl(handle,pxyarray);		/* DRAW FILLED RECTANGLE */

	goto card_ret;				/* FINISHED OUTLINING CARD */
    }

/* DISPLAY SUIT OF CARD IN TWO PLACES */

    color_index[0] = c_color[c_suit];
    tmfdb = ltl_usuit[c_suit];

    pxyarray[0] = 0;
    pxyarray[1] = 0;
    pxyarray[2] = 4;
    pxyarray[3] = 4;
    pxyarray[4] = x + 1;
    pxyarray[5] = y + 9;
    pxyarray[6] = x + 5;
    pxyarray[7] = y + 13;

    if (y < 155 && pxyarray[7] > 154)
    {
	pxyarray[7] = 154;
	pxyarray[3] = pxyarray[7] - pxyarray[5];
    }

    if (y > 155 || pxyarray[5] < 155) vrt_cpyfm(handle, 2, pxyarray, &tmfdb, &SCREEN, color_index);

    tmfdb = ltl_dsuit[c_suit];
    pxyarray[2] = 4;
    pxyarray[3] = 4;
    pxyarray[4] = x + 29;
    pxyarray[5] = y + 25;
    pxyarray[6] = x + 33;
    pxyarray[7] = y + 29;

    if (y < 155 && pxyarray[7] > 154)
    {
	pxyarray[7] = 154;
	pxyarray[3] = pxyarray[7] - pxyarray[5];
    }

    if (y > 155 || pxyarray[5] < 155) vrt_cpyfm(handle, 2, pxyarray, &tmfdb, &SCREEN, color_index);

/* DISPLAY VALUE OF CARD IN 2 PLACES */

    tmfdb = uval[c_value - 1];

    pxyarray[2] = 4;
    pxyarray[3] = 6;
    pxyarray[4] = x + 1;
    pxyarray[5] = y + 1;
    pxyarray[6] = x + 5;
    pxyarray[7] = y + 7;

    if (y < 155 && pxyarray[7] > 154)
    {
	pxyarray[7] = 154;
	pxyarray[3] = pxyarray[7] - pxyarray[5];
    }

    if (y > 155 || pxyarray[5] < 155) vrt_cpyfm(handle, 2, pxyarray, &tmfdb, &SCREEN, color_index);

    tmfdb = dval[c_value - 1];
    pxyarray[2] = 4;
    pxyarray[3] = 6;
    pxyarray[4] = x + 29;
    pxyarray[5] = y + 31;
    pxyarray[6] = x + 33;
    pxyarray[7] = y + 37;

    if (y < 155 && pxyarray[7] > 154)
    {
	pxyarray[7] = 154;
	pxyarray[3] = pxyarray[7] - pxyarray[5];
    }

    if (y > 155 || pxyarray[5] < 155) vrt_cpyfm(handle, 2, pxyarray, &tmfdb, &SCREEN, color_index);

/*------------------------ DISPLAY CENTER OF CARD ------------------------*/

    if (c_value > 10) goto card_ret;

    pxyarray[2] = 6;				/* EXPAND WIDTH TO 7 */

    for (count1 = 0; count1 < 17; count1++)
    {
	if (pattern[c_value - 1][count1] == 1) tmfdb = big_usuit[c_suit];
	if (pattern[c_value - 1][count1] == 2) tmfdb = big_dsuit[c_suit];

	if (pattern[c_value - 1][count1] != 0)
	{
	    pxyarray[2] = 6;
	    pxyarray[3] = 6;
	    pxyarray[4] = x + sx[count1];
	    pxyarray[5] = y + sy[count1];
	    pxyarray[6] = pxyarray[4] + 6;
	    pxyarray[7] = pxyarray[5] + 6;

	    if (y < 155 && pxyarray[7] > 154)
	    {
		pxyarray[7] = 154;
		pxyarray[3] = pxyarray[7] - pxyarray[5];
	    }

	    if (y > 155 || pxyarray[5] < 155) vrt_cpyfm(handle, 2, pxyarray, &tmfdb, &SCREEN, color_index);
	}
    }

card_ret:
    if (y < 155)
    {
	pxyarray[0] = 0;
	pxyarray[1] = 0;
	pxyarray[2] = 319;
	pxyarray[3] = 154;
	vs_clip(handle, 0, pxyarray);
    }

    v_show_c(handle,1);

    return;
}
