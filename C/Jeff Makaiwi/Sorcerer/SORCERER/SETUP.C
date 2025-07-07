/* This file contains various setup routines, all eventually.  We'll see */

#include "readable.h"
#include "sorcery.h"
#include <osbind.h>


extern PLINFO player[];
extern BDTYPE board;
extern short imageBuff1[], imageBuff2[], maskBuff1[], maskBuff2[];
extern short padPattern[], edgePattern[], edgeTemplate[][4], padTemplate[][4];
extern short padImages[][PADSIZE], edgeImages[][EDGESIZE];
extern long mainScreen, screenBuff, background[];


/* Global game environment variables */
short bmode;		/* Board setup mode, standard or random */



/* External Function References */
/* from GRAPHICS.C */
extern void Draw_Platform();

/* from UTILS.C */
extern void Clear_Block(), Copy_Block(), Delay(), Pad_Pos();
extern short My_Random(), Next_Color();

/* from DRAWING.S */
extern void Shift_Image(), Make_Mask();



/***********************************************
 *   The game initialization routine follow.   *
 ***********************************************/

/**************************************************************
 * This routine sets the board to its starting configuration. *
 **************************************************************/
static void InitBoard()
begin
    short row,col,src,targ,color;

    color = RED;
    for (row = MINROW; row <= MAXROW; row++) begin
	for (col = MINCOL; col <= MAXCOL; col++) begin
	    board.grid[row][col] = color;
	    color = Next_Color(REDPLAYER, color, TRUE);
	end /* of make row */
	color += 2;
	while (color > VIOLET) begin
	    color -= VIOLET;
	end /* of fix overflow */
    end /* of make board */

 /* This Scrambles the board */
    if (bmode) begin
	for (src = 1; src < 24; src++) begin
	    targ = My_Random(1, 23);
	    color = board.linear[src];
	    board.linear[src] = board.linear[targ];
	    board.linear[targ] = color;
	end /* shuffle board loop */
    end /* of make Random Configurations */
end /* Initialize Board */



/******************************************************
 * This routine draws the entire board on the screen. *
 ******************************************************/
static void DrawBoard()
begin
    short row,col,x,y;

    for (row = MINROW; row <= MAXROW; row++) begin
	for (col = MINCOL; col <= MAXCOL; col++) begin
	    Pad_Pos(row, col, &x, &y);
	    Draw_Platform(x, y, board.grid[row][col]);
	end /* of draw cols */
    end /* of draw rows */
end /* of Draw Board */


/*********************************************************************
 * This routine draws a row of platforms at the bottom of the screen *
 * that shows the color sequence of the spectrum.                    *
 *********************************************************************/
static void DrawSpectrum()
begin
    short x,color;

    x = XOFFSET + 16;
    for (color = RED; color <= VIOLET; color++, x+=56) begin
	Draw_Platform(x, SPECLINE, color);
    end /* of draw the platforms */
end /* of Draw Spectum */



/****************************************************************
 * This routine beams the wizards up from their spectral homes. *
 ****************************************************************/
static void Beamup()
begin
    short xr,yr, xv,yv, xd,yd;
    ulong vbcount;

    xr = XOFFSET + 16;
    xv = XOFFSET + 262;
    yr = yv = SPECLINE - 23;

    Prep_Wizard(0, xr, 0, imageBuff1, maskBuff1);
    Prep_Wizard(1, xv, 0, imageBuff2, maskBuff2);
    Draw_Wizard(xr, yr, imageBuff1, maskBuff1);
    Draw_Wizard(xv, yv, imageBuff2, maskBuff2);
    Flip_Screens();

    Wiz_Pos(REDPLAYER, MINROW,MINCOL, &xd, &yd);
    Delay(12);
    Exec_Teleport(REDPLAYER, xv,yv, xr,yr, xd,yd);

    vbcount = SetWait(12L);
    xr = xd;	yr = yd;
    Wiz_Pos(VIOPLAYER, MAXROW,MAXCOL, &xd, &yd);
    Wait(vbcount);

    Exec_Teleport(VIOPLAYER, xr,yr, xv,yv, xd,yd);
    Delay(12);
end /* of Beamup */



/************************************************************
 * This routine sets up the display at the start of a game. *
 ************************************************************/
void Init_Game()
begin
    Clear_Block(mainScreen, 4000);
    Setscreen(background, mainScreen, -1);
    Clear_Block(screenBuff, 4000);
    Clear_Block(background, 4000);

    InitBoard();
    DrawBoard();
    DrawSpectrum();

 /* Print the POWER headers */
    Set_Font(2);
    my_fcolor(RED,LT_RED);
    my_ftext(0,0, "POWER:");
    my_fcolor(UV,LT_VIO);
    my_ftext(32,0,"POWER:");
    Set_Font(1);

    Copy_Block(background, mainScreen, 3200);
    Copy_Block(background, screenBuff, 3200);

    Setscreen(screenBuff, mainScreen, -1);

 /* Initialize Player Information */
    player[REDPLAYER].row = 0;
    player[REDPLAYER].col = 0;
    player[REDPLAYER].power = 21;

    player[VIOPLAYER].row = 4;
    player[VIOPLAYER].col = 4;
    player[VIOPLAYER].power = 21;

    Beamup();			/* Beam-up the Wizards */

end /* of Initialize Game */



/**********************************************************
 * Make a Pad image from a template and a vplane pattern. *
 **********************************************************/
static void MakeImage(size,pattern,template,destBuff)
    short size,pattern[],template[],destBuff[];
begin
    short patcnt,destcnt,plane;

    for (patcnt=0,destcnt=0; patcnt < size; patcnt++) begin
	for (plane=0; plane < VPLANE_CNT;) begin
	    destBuff[destcnt++] = template[plane++] & pattern[patcnt];
	end /* of do all Vplanes */
    end /* of pattern */ 
end /* of Make Image */



/******************************************************
 * Generate all Pads from the templates and patterns. *
 ******************************************************/
void Create_Platforms()
begin
    short i;

 /* Create the Pad Images */
    for (i = 0; i < VIOLET; i++) begin
	MakeImage(PADSIZE/VPLANE_CNT, padPattern, padTemplate[i], padImages[i]);
    end /* of Make Pad Loop */

    for (i = 0; i < 3; i++) begin
       MakeImage(EDGESIZE/VPLANE_CNT,edgePattern,edgeTemplate[i],edgeImages[i]);
    end /* of Make Edge Loop */
end /* of Create Platforms */
