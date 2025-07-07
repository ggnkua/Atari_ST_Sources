/* This file contains the routines that animate the end game sequence. */

#include "readable.h"	/* My Readability Macros */
#include "sorcery.h"	/* Spectral Sorcery Standard Constants */
#include <osbind.h>



/* External Variable References */
extern PLINFO player[];
extern short imageBuff1[], imageBuff2[], maskBuff1[], maskBuff2[];
extern long background[];



/* External Function References */
/* from GRAPHICS.C */
extern void Prep_Wizard(), Draw_Wizard(), Flip_Screens();

/* from UTILS.C */
extern void Delay(), Wiz_Pos(), Tele_Sound();

/* from DRAWING.S */
extern void Copy_Block();



/*************************************************************************
 *   This section contains routines that animate the start and end game. *
 *************************************************************************/

/***********************************************************************
 * This routine allows for simultaneous animation of the both wizards. *
 ***********************************************************************/
static void Animate(rframe, vframe, xr,yr, xv,yv, frames, radd, vadd, jikan)
    short rframe, vframe, xr,yr, xv,yv, frames, radd, vadd;
    ushort jikan;
begin
    short i;
    ulong vbcount;

    for (i = frames; i > 0;i--, rframe+=radd, vframe+=vadd) begin
	vbcount = SetWait(4L);
	Prep_Wizard(REDPLAYER, xr, rframe, imageBuff1, maskBuff1);
	Prep_Wizard(VIOPLAYER, xv, vframe, imageBuff2, maskBuff2);
	Copy_Block(background, Logbase(), 3200);
	Draw_Wizard(xr,yr, imageBuff1, maskBuff1);
	Draw_Wizard(xv,yv, imageBuff2, maskBuff2);
	Wait(vbcount);	Flip_Screens();
    end /* of raise staff loop */

    if (jikan > 0) begin
	Delay(jikan);
    end /* of delay */
end /* of Animate motion (simultaneous possible) */



/*************************************************************************
 * This routine beams the wizards down to the GREEN spectrum pad and     *
 * then makes the loser salute the winner.  If the game was a draw, then *
 * both players salute one another.                                      *
 *************************************************************************/
void Beam_Down(winner)
    short winner;
begin
    short xr,yr, xv,yv, xd,yd;

    Copy_Block(Physbase()+25600, Logbase()+25600, 799);
    Wiz_Pos(REDPLAYER, player[REDPLAYER].row, player[REDPLAYER].col, &xr,&yr);
    Wiz_Pos(VIOPLAYER, player[VIOPLAYER].row, player[VIOPLAYER].col, &xv,&yv);
    xd = XOFFSET + 128;		yd = SPECLINE - 23;

    Animate(2,2, xr,yr, xv,yv,   4, 1,1, 20);	/* both nod */
    Tele_Sound(0);
    Animate(12,12, xr,yr, xv,yv, 4, 1,1,  0);   /* demat */
    yr = yv = yd;
    xr = xd;	xv = xd + 22;
    Tele_Sound(1);
    Animate(15,15, xr,yr, xv,yv, 4, -1,-1, 0);  /* materialize */
    Animate(5,5, xr,yr, xv,yv,   4, -1,-1, 0);	/* raise heads */
    Animate(0,0, xr,yr, xv,yv,   1, 0,0,  20);  /* rest position */

    switch (winner) begin
    case REDPLAYER:
	Animate(0,6, xr,yr, xv,yv, 2, 0,1,  20);	/* vio raise staff */
	Animate(2,7, xr,yr, xv,yv, 4, 1,0,  15);	/* red nod */
	Animate(5,7, xr,yr, xv,yv, 4,-1,0,   0);	/* red raise head */
	Animate(0,7, xr,yr, xv,yv, 1, 0,0,  20);	/* red rest pose */
	Animate(0,7, xr,yr, xv,yv, 2, 0,-1,  0);	/* vio lower staff */
	Animate(0,0, xr,yr, xv,yv, 1, 0,0,  20);	/* vio rest pose */
	break;
    case VIOPLAYER:
	Animate(6,0, xr,yr, xv,yv, 2, 1,0,  20);	/* red raise staff */
	Animate(7,2, xr,yr, xv,yv, 4, 0,1,  15);	/* vio nod */
	Animate(7,5, xr,yr, xv,yv, 4, 0,-1,  0);	/* vio head up */
	Animate(7,0, xr,yr, xv,yv, 1, 0,0,  20);	/* vio rest pose */
	Animate(7,0, xr,yr, xv,yv, 2, -1,0,  0);	/* red lower staff */
	Animate(0,0, xr,yr, xv,yv, 1, 0,0,  20);	/* red rest pose */
	break;
    default:
	Animate(6,6, xr,yr, xv,yv, 2, 1,1,  20);	/* both raise staves */
	Animate(7,7, xr,yr, xv,yv, 2, -1,-1, 0);	/* now lower them */
	Animate(0,0, xr,yr, xv,yv, 1, 0,0,  20);	/* back to rest pose */
    end /* of Salute type switch */

    Animate(2,2, xr,yr, xv,yv,   4, 1,1, 20);	/* both nod */
    Tele_Sound(0);
    Animate(12,12, xr,yr, xv,yv, 4, 1,1,  0);   /* demat */
    xr = XOFFSET + 16;		xv = XOFFSET + 262;
    Tele_Sound(1);
    Animate(15,15, xr,yr, xv,yv, 4, -1,-1, 0);  /* materialize */
    Animate(5,5, xr,yr, xv,yv,   4, -1,-1, 0);	/* raise hed */
    Animate(0,0, xr,yr, xv,yv,   1, 0,0,  20);  /* rest position */
end /* of Beam Down */
