/* This file contains all of the graphics calls for  Spectral  Sorcery */
/* In theory, this is the only file that needs to be adjusted in order */
/* to port to another machine.  Actually, some of the SORCMAIN.C file  */
/* would have to change because of the VDI and AES calls.  Oh well.    */

#include "readable.h"
#include "sorcery.h"
#include <osbind.h>


/* External Variable References */
extern PLINFO player[];
extern BDTYPE board;
extern short edgeImages[][EDGESIZE], padImages[][PADSIZE];
extern short *wizImages[][16], *wizMasks[][16], *telePads[], tpadCounter;
extern long background[];



/* Locally-define Image Buffers */
short imageBuff1[600], imageBuff2[600], maskBuff1[400], maskBuff2[400];
short teleBuff[4][600], tmaskBuff[4][400];
static char pwrBuff1[]={"00"}, pwrBuff2[] = {"00"};



/* External Function References */
/* from UTILS.C */
extern void Delay(), BinToAscii(), Wiz_Pos(), Pad_Pos(), Tele_Sound();
extern short Next_Color();

/* from TEXTIO.C */
extern void Print_Message(), Set_Font();

/* from DRAWING.S */
extern void Shift_Image(), Shift_Mask(), Make_Mask(), Draw_Image(),
	    CopyScrn_Block(), Copy_Block();

/* from TB_TEXT.S */
extern void my_fcolor(), my_ftext();




/*****************************************************************************
 *  This section contains code that handles the various tasks of animation.  *
 *****************************************************************************/

/********************************************************************
 * This routine swaps the physical screen with the logical screen.  *
 * It is assumed that the programmer has already assigned the       *
 * different buffer addresses to the Logbase and Physbase.  The     *
 * small delay section at the start of the routine waits for one    *
 * click of the 200Hz system clock before flipping screens.  This   *
 * helps clear up some flicker problems that were occuring near the *
 * top of the screen.                                               *
 ********************************************************************/
void Flip_Screens()
begin
    register ulong temp;

    temp = clock();		while (temp == clock());

    Setscreen(Physbase(), Logbase(), -1);
end /* of Flip Screens */



/*************************************************************************
 * This routine prints the player power levels at the top of the screen. *
 * It writes to both the background buffer and the Physical screen.      *
 *************************************************************************/
static void DrawPower()
begin
    long log;

    log = (long)Logbase();
    Setscreen(background, -1L, -1);
    Set_Font(2);

    BinToAscii(player[REDPLAYER].power, pwrBuff1);
    BinToAscii(player[VIOPLAYER].power, pwrBuff2);

    my_fcolor(RED,LT_RED);
    my_ftext(6, 0, pwrBuff1);    
    my_fcolor(UV, VIOLET);
    my_ftext(38, 0, pwrBuff2);    

    Set_Font(1);
    Setscreen(log, -1L, -1);
    CopyScrn_Block(1, 10, background, Physbase(),  32);
    CopyScrn_Block(1, 10, background, Physbase(), 152);
end /* of Draw Power bar */



/**********************************************************************
 * This routine prepares a shifted Wizard image from a word-aligned   *
 * LOW-RES image and a mask that is in 1/2 format.  1/2 format means  *
 * that there are only 2 vplanes per vplane block in the data rather  *
 * than the 4 it takes to fully describe a multi-color LOW-RES image. *
 * This is allowed because the masks are pixel value 15 (all planes   *
 * are identical).  So, all that is really needed is a single vplane  *
 * from each set of 4.  I used 2 because it was easier to edit.       *
 **********************************************************************/
void Prep_Wizard(who, x, frame, image, mask)
    short who, x, frame, *image, *mask;
begin
    Shift_Image(2, 35, wizImages[who][frame], image, x);
    Shift_Mask(2, 35, wizMasks[who][frame], mask, x);
end /* of Prepare Wizard image */


/* Draw a wizard.  Assume pre-prepared images and masks. */
void Draw_Wizard(x, y, image, mask)
    short x, y, *image, *mask;
begin
    Draw_Image(2, 35, ((y*160)+((x RSH 4) LSH 3)+(long)Logbase()), image,mask); 
end /* of Draw Wizard */



/**********************************************
 * Draws the surface of a platform (the pad). *
 **********************************************/
void Draw_Pad(x, y, color)
    short x, y, color;
begin
    long screenAddr;

    screenAddr = (y * 160) + ((x / 16) * 8);
    if (color >= 0) begin
	Shift_Image(4, 17, padImages[color - 1], imageBuff1, x);
	screenAddr += (long)background;
    end else begin
	Shift_Image(4, 17, telePads[tpadCounter++], imageBuff1, x);
	tpadCounter MOD= 5;
	screenAddr += (long)Logbase();
    end /* of shift correct image */

    Make_Mask(4, 17, imageBuff1, maskBuff1);
    Draw_Image(4, 17, screenAddr, imageBuff1, maskBuff1); 
end /* of Draw Pad */



/******************************************************************************
 * This routine draws the edge of a pad.  The color indicates the lock state. *
 ******************************************************************************/
void Draw_Edge(x, y, locks)
    short x, y, locks;
begin
    long screenAddr;

    screenAddr = (long)background + 1440 + (y * 160) + ((x / 16) * 8);
    Shift_Image(4, 10, edgeImages[locks], imageBuff1, x);
    Make_Mask(4, 10, imageBuff1, maskBuff1);
    Draw_Image(4, 10, screenAddr, imageBuff1, maskBuff1); 
end /* of Draw Edge */



/**********************************************************************
 * This routine draws a full platform, both the surface and the edge. *
 **********************************************************************/
void Draw_Platform(x, y, color)
    short x, y, color;
begin
    Draw_Pad(x, y, color & 0xff);
    Draw_Edge(x, y, (color RSH 8) & 0xff);
end /* of Draw Platform routine */



/************************************************************************
 * This routine changes the color of a pad in memory and on the screen. *
 * It also has the side effect of removing any locks from the platform. *
 ************************************************************************/
void Change_Pad(row, col, color)
    short row, col, color;
begin
    short x, y;

    board.grid[row][col] = color;
    Pad_Pos(row, col, &x, &y);
    Draw_Pad(x, y, color);
end /* of Change Pad color */


/********************************************************************
 * This routine changes a pad to the next color in a player's color *
 * sequence.  It also decucts one power point from the player's     *
 * reserves and rings a bell (if enabled).  If the pad is locked,   *
 * no change will occur and a message will be displayed, if that    *
 * function is enabled.                                             *
 ********************************************************************/
BOOLEAN Tweek(who, row, col, maskShow, noise, wrap)
    short who, row, col, maskShow, noise, wrap;
begin
    static char *msg1 = "The Pad is LOCKed.  No color change!";
    short ccolor,				/* Current color */
 	  tcolor,				/* Target color */
	  *pad,					/* ptr to PAD */
	  result = FALSE;			/* assume it failed */

    pad = &board.grid[row][col];		/* set ptr to PAD content */
    ccolor = *pad & 0xff;
    if ( !(*pad & 0xff00) ) begin
	tcolor = Next_Color(who, ccolor, wrap);
	if (ccolor != tcolor) begin
	    player[who].power--;		/* costs 1 power point */
	    Change_Pad(row, col, tcolor);	/* change to new color */
	    if (noise) begin
		Ding(2, tcolor+5);		/* Ring bell */
	    end /* of make noise if specified */
	    result = TRUE;			/* Tweek worked */
	end /* of try to change color */

    end else if (maskShow) begin
	Print_Message(2, 3, ccolor,GRAY, 3,6, 90, msg1);
    end /* What to do */

    return(result);
end /* of Tweek pad color */


/***************************************************************
 * This routine updates the screen from the background buffer. *
 * It then redraws the wizards and flips the screens.          *
 ***************************************************************/
void Update_Screen(rframe, vframe, xtarg, ytarg, jikan)
    short rframe, vframe, xtarg, ytarg;
    ushort jikan;
begin
    short xr, yr, xv, yv;

    DrawPower();
    Copy_Block(background, Logbase(), 3200);
    if ((xtarg >= 0) OR (ytarg >= 0)) begin
	Pad_Pos(xtarg, ytarg, &xr, &yr);
	Draw_Pad(xr, yr, -1);
    end /* of put target pad on screen */

    Wiz_Pos(0, player[REDPLAYER].row, player[REDPLAYER].col, &xr, &yr);
    Wiz_Pos(1, player[VIOPLAYER].row, player[VIOPLAYER].col, &xv, &yv);
    Prep_Wizard(0, xr, rframe, imageBuff1, maskBuff1);
    Prep_Wizard(1, xv, vframe, imageBuff2, maskBuff2);

    if (yr < yv) begin
	Draw_Wizard(xr, yr, imageBuff1, maskBuff1);
	Draw_Wizard(xv, yv, imageBuff2, maskBuff2);
    end else begin
	Draw_Wizard(xv, yv, imageBuff2, maskBuff2);
	Draw_Wizard(xr, yr, imageBuff1, maskBuff1);
    end /* of draw the dudes */
    Flip_Screens();

    if (jikan > 0) begin
	Delay(jikan);
    end /* of delay if requested */
end /* of Update Screen */


/****************************************************************
 * This routine updates the screen in the middle of a spell.    *
 * It is just a short way to call Update_Screen from the middle *
 * of a spell.  Nothing fancy, but it does flicker the staff.   *
 ****************************************************************/
void Mid_Spell(who)
    short who;
begin
    static short frames[] = {10,11}, stage = 0;
    register short temp;

    if (who < 0) begin
	stage = 0;
    end else begin
	temp = frames[stage];
	stage XOR= 1;

	if (who == REDPLAYER) begin
	    Update_Screen(temp,0, -1,-1, 0);
	end else begin
	    Update_Screen(0,temp, -1,-1, 0);
	end /* update correct player */
    end /* of update images or stage counter */

end /* of Mid Spell screen update */



/***************************************************
 * This routine does the animation for a TELEPORT. *
 ***************************************************/
void Exec_Teleport(who, ex,ey, x,y, tx,ty)
    short who, ex,ey, x,y, tx,ty;
begin
    short i;
    ulong vbcount;

    Prep_Wizard(1-who, ex, 0, imageBuff2, maskBuff2);
    for (i = 2; i <= 5; i++) begin
	vbcount = SetWait(4L);
        Copy_Block(background, Logbase(), 3200);
	Prep_Wizard(who, x, i, imageBuff1, maskBuff1);
	if (ey < y) begin
	    Draw_Wizard(ex, ey, imageBuff2, maskBuff2);
	    Draw_Wizard(x, y, imageBuff1, maskBuff1);
	end else begin
	    Draw_Wizard(x, y, imageBuff1, maskBuff1);
	    Draw_Wizard(ex, ey, imageBuff2, maskBuff2);
	end /* fix overlap */
	Wait(vbcount);	Flip_Screens();
    end /* of animate nod on source pad */

 /* This section is where the meat of the animation is done. */
    for (i = 0; i < 4; i++) begin
	Prep_Wizard(who, x, 12+i, &teleBuff[i][0], &tmaskBuff[i][0]);
    end /* of prepare teleport images */

    Tele_Sound(0);
    for (i = 0; i < 4; i++) begin
	vbcount = SetWait(4L);
	Copy_Block(background, Logbase(), 3200);
	if (ey < y) begin
	    Draw_Wizard(ex, ey, imageBuff2, maskBuff2);
	    Draw_Wizard(x, y, &teleBuff[i][0], &tmaskBuff[i][0]);
	end else begin
	    Draw_Wizard(x, y, &teleBuff[i][0], &tmaskBuff[i][0]);
	    Draw_Wizard(ex, ey, imageBuff2, maskBuff2);
	end /* of draw disintegration frames */
	Wait(vbcount);	Flip_Screens();
    end /* update all of the frames */

    vbcount = SetWait(4L);
    Copy_Block(background, Logbase(), 3200);
    Draw_Wizard(ex, ey, imageBuff2, maskBuff2);
    Wait(vbcount);	Flip_Screens();	
    Delay(5);

    if ((tx & 0xf) != (x & 0xf)) begin
	for (i = 0; i < 4; i++) begin
	    Prep_Wizard(who, tx, 12+i, &teleBuff[i][0], &tmaskBuff[i][0]);
	end /* of make new images as necessary */
    end /* of prepare destination teleport images */

    Tele_Sound(1);
    for (i = 0; i < 4; i++) begin
	vbcount = SetWait(4L);
	Copy_Block(background, Logbase(), 3200);
	if (ey < ty) begin
	    Draw_Wizard(ex, ey, imageBuff2, maskBuff2);
	    Draw_Wizard(tx, ty, &teleBuff[i][0], &tmaskBuff[i][0]);
	end else begin
	    Draw_Wizard(tx, ty, &teleBuff[i][0], &tmaskBuff[i][0]);
	    Draw_Wizard(ex, ey, imageBuff2, maskBuff2);
	end /* of draw disintegration frames */
	Wait(vbcount);	Flip_Screens();
    end /* update all of the frames */

    for (i = 5; i >= 0; i--) begin
	if (i == 1) continue;
	vbcount = SetWait(4L);
	Copy_Block(background, Logbase(), 3200);
	Prep_Wizard(who, tx, i, imageBuff1, maskBuff1);
	if (ey < ty) begin
	    Draw_Wizard(ex, ey, imageBuff2, maskBuff2);
	    Draw_Wizard(tx, ty, imageBuff1, maskBuff1);
	end else begin
	    Draw_Wizard(tx, ty, imageBuff1, maskBuff1);
	    Draw_Wizard(ex, ey, imageBuff2, maskBuff2);
	end /* fix overlap */
	Wait(vbcount);	Flip_Screens();
    end /* of animate anti-nod on dest pad */

    Prep_Wizard(who, tx, 0, imageBuff1, maskBuff1);
    vbcount = SetWait(4L);
    Copy_Block(background, Logbase(), 3200);
    Draw_Wizard(ex, ey, imageBuff2, maskBuff2);
    Draw_Wizard(tx, ty, imageBuff1, maskBuff1);
    Wait(vbcount);	Flip_Screens();
end /* of Execute Teleport */



/*********************************************************************
 * This routine actually moves a wizard from pad one pad to another. *
 *********************************************************************/
void Hop(who, lastRow, lastCol, row, col)
    short who, lastRow, lastCol, row, col;
begin
    ulong vbcount;
    short x,y, newX,newY, ex,ey, ypos, frame, i, lat, vert, front;
    static short jumpPos[2][8] = {{5, 11, 15, 19, 20, 19, 15, 11},
				  {4,  8,  9,  8,  4,  0, -6,-11}};
    
    i = 1 - who;
    Wiz_Pos(i, player[i].row, player[i].col, &ex, &ey);
    Prep_Wizard(i, ex, 0, imageBuff2, maskBuff2);
    Wiz_Pos(who, lastRow, lastCol, &x, &y);
    Wiz_Pos(who, row, col, &newX, &newY);

    lat = (newX - x) / 8;
    if (lat < 0) begin
	frame = 1 - who;
    end else begin
	frame = who;
    end /* of set frame number */

    if (newY < y) begin
	vert = 0;
    end else begin
	vert = 1;
    end /* of select vertical vector table */

    front = ((y >= ey) AND ((y - jumpPos[vert][7]) >= ey));

    for (i = 0; i < 8; i++) begin
	vbcount = SetWait(2L);
	x += lat;	ypos = y - jumpPos[vert][i];
	Copy_Block(background, Logbase(), 3200);	/* restore backgrnd */
	Prep_Wizard(who, x, frame, imageBuff1, maskBuff1);
	if (front) begin
	    Draw_Wizard(ex, ey, imageBuff2, maskBuff2);
	    Draw_Wizard(x, ypos, imageBuff1, maskBuff1);
	end else begin
	    Draw_Wizard(x, ypos, imageBuff1, maskBuff1);
	    Draw_Wizard(ex, ey, imageBuff2, maskBuff2);
	end /* of Draw Precedence */
	Wait(vbcount);	Flip_Screens();
    end /* of do hop loop */
    Thudd();	Delay(4);
end /* of Hop */
