/* title.c  Tue 24 May 1988 */
/* This is the Title Screen Routine for Spectral Sorcery. */

#include "readable.h"
#include "sorcery.h"
#include <osbind.h>

#define XTITLEMIN 0
#define XTITLEMAX 304
#define YTITLEMIN 0
#define YTITLEMAX 180
#define XVECMAX	  16
#define YVECMAX   16


#include "xtitlfnt.c"		/* Data for the big "SPECTRAL SORCERY" */

/* External Variable References */
extern short colorSet[], imageBuff1[], maskBuff1[];
extern long mainScreen, screenBuff, background[];



/* Global Local Variables */
static short glow[] = {0x310,0x420,0x530,0x640,0x750},
	     cindex = 0, lindex = RED;
static long letters[2][8] = {{sorc1,sorc2,sorc3,sorc4,sorc5,sorc6,sorc7,0L},
			     {spec1,spec2,spec3,spec4,spec5,spec6,spec7,spec8}};



/* External Function References */
/* from GRAPHICS.C */
extern void Flip_Screens();

/* from TEXTIO.C */
extern void Set_Font(), Set_TextMode();

/* from UTILS.C */
extern short My_Random();
extern void Clear_Keys(), Delay(), Clear_Block();

/* from DRAWING.S */
extern void Shift_Image(), Make_Mask(), Draw_Image();

/* from TB_TEXT.S */
extern void my_fcolor(), my_ftext();




/************************************
 *   THE CODE SECTION STARTS HERE   *
 ************************************/

/*********************************************
 * This routine sets the new motion vectors. *
 *********************************************/
static void SetVectors(xdir,ydir, xpos,ypos, xplace,yplace)
    short *xdir,*ydir, xpos,ypos, xplace,yplace;
begin
    if ((xpos != xplace) OR (ypos != yplace)) begin

	*xdir += (Sign(xplace - xpos) * 3);
	if (abs(*xdir) > XVECMAX) begin
	    *xdir = XVECMAX * Sign(*xdir);
	end /* of add new offset */

	*ydir += (Sign(yplace - ypos) * 3);
	if (abs(*ydir) > YVECMAX) begin
	    *ydir = YVECMAX * Sign(*ydir);
	end /* of add new offset */

    end else begin
	*xdir = *ydir = 0;
    end /* zero vector if on target */

end /* of Set Vector */



/***********************************************
 * This routine sets the new letter positions. *
 ***********************************************/
static short SetPosition(x, y, xvec, yvec, xplace, yplace)
    short *x, *y, *xvec, *yvec, xplace, yplace;
begin
    *x += *xvec;	*y += *yvec;
    if (*x < xplace) begin
	(*x)++;
    end else if (*x > xplace) begin
	(*x)--;
    end /* of move toward target */

    if (*y < yplace) begin
	(*y)++;
    end else if (*y > yplace) begin
	(*y)--;
    end /* of move toward target */

    *x += Sign(xplace - *x);
    *y += Sign(yplace - *y);

    if (*x < XTITLEMIN) begin
	*x = XTITLEMIN;		*xvec = -(abs(*xvec) - 1);
    end else if (*x > XTITLEMAX) begin
	*x = XTITLEMAX;		*xvec = -(abs(*xvec) - 1);
    end /* of keep it on screen */

    if (*y < YTITLEMIN) begin
	*y = YTITLEMIN;		*yvec = -(abs(*yvec) - 1);
    end else if (*y > YTITLEMAX) begin
	*y = YTITLEMAX;		*yvec = -(abs(*yvec) - 1);
    end /* of keep it on screen */

    if ((*x == xplace) AND (*y == yplace)) begin
	return(1);
    end else begin
	return(0);
    end /* return destination reached result */
end /* of Set Position */



/*****************************************************************
 * This routine makes the title characters fly around the screen *
 * until they finally settle into their correct positions.       *
 *****************************************************************/
static BOOLEAN FlyingTitle()
begin
    static short xplace[][8] = {{104,120,136,152,168,184,200,  0},
				{ 96,112,128,144,160,176,192,208}};
    static short yplace[] = {101,79};
    static short xpos[2][8],ypos[2][8], xdir[2][8],ydir[2][8];

    short i, j, lcount;
    ulong log, scrnAddr, vbcount;
    BOOLEAN movedone, notSpaced = TRUE;

    Setscreen(screenBuff, mainScreen, -1);
    for (i = 0; i < 2; i++) begin
	lcount = i + 7;
	for (j = 0; j < lcount; j++) begin
	    xpos[i][j] = My_Random(0,304);
	    ypos[i][j] = My_Random(0,180);
	    xdir[i][j] = My_Random(0, XVECMAX * 2) - XVECMAX;
	    ydir[i][j] = My_Random(0, YVECMAX * 2) - YVECMAX;
	end /* of individual positions */
    end /* of set initial positions */

    do begin
	log = (ulong)Logbase();
	Copy_Block(background, log, 4000);
	movedone = 0;
	vbcount = SetWait(6L);

	for (i = 0; i < 2; i++) begin
	    lcount = i + 7;
	    for (j = 0; j < lcount; j++) begin
		scrnAddr = log + (ypos[i][j] * 160) + 
				 ((xpos[i][j] & 0xfff0) RSH 1);
		Shift_Image(1, 20, letters[i][j], imageBuff1, xpos[i][j]);
		Make_Mask(1, 20, imageBuff1, maskBuff1);
		Draw_Image(1, 20, scrnAddr, imageBuff1, maskBuff1);
		movedone += SetPosition(&xpos[i][j],  &ypos[i][j],
					&xdir[i][j],  &ydir[i][j],
					 xplace[i][j], yplace[i]);

		SetVectors(&xdir[i][j],&ydir[i][j], xpos[i][j],ypos[i][j],
			    xplace[i][j],yplace[i]);

	    end /* of draw title letters */
	end /* of draw each word */
	Wait(vbcount);

	Setcolor(LT_RED, glow[cindex++]);
	Setcolor(RED, colorSet[lindex++]);
	if (cindex > 4)	cindex = 0;	
	if (lindex > VIOLET) lindex = RED;
	Flip_Screens();

	if (Bconstat(2)) begin
	    notSpaced = ((short)Bconin(2) != ' ');
	end /* of check for SPACE Key */

    end while ((movedone < 15) AND (notSpaced));

    log = (long)Logbase();
    Copy_Block(background, log, 4000);
    vbcount = SetWait(6L);

    for (i = 0; i < 2; i++) begin
	lcount = i + 7;
	for (j = 0; j < lcount; j++) begin
	    scrnAddr = log + (yplace[i] * 160) + ((xplace[i][j]&0xfff0) RSH 1);
	    Shift_Image(1, 20, letters[i][j], imageBuff1, xplace[i][j]);
	    Make_Mask(1, 20, imageBuff1, maskBuff1);
	    Draw_Image(1, 20, scrnAddr, imageBuff1, maskBuff1);
	end /* of draw title letters */
    end /* of draw each word */
    Wait(vbcount);

    Flip_Screens();
    Copy_Block(Physbase(), Logbase(), 4000);
    Setscreen((long)Physbase(), -1L, -1);
    return(notSpaced);
end /* of Flying Title */



/****************************************
 * THE TITLE, CREDITS, PLOT, AND SO ON. *
 ****************************************/
void Roll_Credits()
begin
    ulong vbcount;
    short jikan;
    BOOLEAN flag;

    Clear_Keys();
    Clear_Block(background, 4000);
    Clear_Block(mainScreen, 4000);
    Clear_Block(screenBuff, 4000);
    Setscreen(background, -1L, -1);
    Setcolor(YELLOW, 0x310);
    Setcolor(LT_RED, 0x650);
    Setcolor(DK_RED, 0x430);

    Set_TextMode(0);	/* replace mode */
    Set_Font(2);
    my_fcolor(DK_RED,LT_RED);
    my_ftext( 9, 40, "The Paranoid Programmer");
    my_fcolor(IR,LT_RED);
    my_ftext(14, 51, "Jeff Makaiwi");
    my_fcolor(LT_VIO,VIOLET);
    my_ftext(16, 62, "Presents");

    my_fcolor(GREEN,DK_GRAY);
    my_ftext( 4, 130, "Copyright (c) 1897 by Jeff Makaiwi");
    my_fcolor(GRAY,BLUE);
    my_ftext( 3, 142, "Compiled with Mark Williams C v3.0.6");

    Set_Font(1);
    my_fcolor(WHITE,GRAY);
    my_ftext(9, 189, "Press SPACE to begin...");
    Setscreen(mainScreen, -1L, -1);

    flag = FlyingTitle();

    Clear_Keys();	jikan = 600;
    do begin
	vbcount = SetWait(10L);
	Setcolor(LT_RED, glow[cindex++]);
	Setcolor(RED, colorSet[lindex++]);
	if (cindex > 4)	cindex = 0;	
	if (lindex > VIOLET) lindex = RED;
	if (Bconstat(2)) begin
	    flag = (((short)Bconin(2) & 0xff) != ' ');
	end /* of check for space bar */
	Wait(vbcount);
    end while ((flag) AND ((--jikan) > 0));

    Setcolor(RED,    colorSet[RED]);
    Setcolor(YELLOW, colorSet[YELLOW]);
    Setcolor(LT_RED, colorSet[LT_RED]);
    Setcolor(DK_RED, colorSet[DK_RED]);
    Setscreen(mainScreen, mainScreen, -1);
end /* of Roll_Credits */
