/*****************************************************************************
 *  This file has all of the game option setting routines.                   *
 *****************************************************************************/

#include "readable.h"	/* My C Macros for Readability */
#include "sorcery.h"	/* Game Specific Constants */
#include <osbind.h>


/* Here are some external variable references */ 
extern PLINFO player[];
extern BOOLEAN savePower;
extern short bmode, playerOrder[], gameCtrl[];
extern long mainScreen, screenBuff;


/* External functions */
/* from HELP.C */
extern void Wait_Button();

/* from TEXTIO.C */
extern void Set_Font();

/* from UTILS.C */
extern void Clear_Keys();

/* from DRAWING.S */
extern void Clear_Block();

/* from TB_TEXT.S */
extern void my_fcolor(), my_ftext();



/********************************************************
 *   This section prints the instructions on request.   *
 ********************************************************/

/************************************************************
 * This routine prints a single page of text for the rules. *
 ************************************************************/
static void PrintScreen(lines, text, pause)
    short lines;
    char *text[];
    BOOLEAN pause;
begin
    short i, y;

    for (i = y = 0; i < lines; i++, y+=11) begin
	my_ftext(0, y, text[i]);
    end /* of print text */

    Set_Font(1);	my_fcolor(WHITE,GRAY);
    if (pause) begin
        my_ftext(4,190, "Press Button or Key for More...");
    end else begin
	my_ftext(4, 190, "Press Button or Key to Exit...");
    end /* of print MORE at bottom of screen */
    Wait_Button(2);
end /* of Print a Screen of text */



/**********************************************************************
 * This routine prints the instructions on the screen in MORE format. *
 **********************************************************************/
static void ShowRules()
begin
    static char *rules1[] = {"  In SPECTRAL SORCERY the object is",
			     "to convert a board of 25 squares to",
			     "a single color (your own).  Since each",
			     "square (or pad) can be any one of five",
			     "colors at a given time, the task of",
			     "conversion can be quite difficult.",
			     "Especially when you have to contend",
			     "with an opponent who is trying to",
			     "convert the pads to his/her/its color.",
			     "  The board always starts with 5 pads",
			     "of each color.  From there you must",
			     "use the various spells and actions to",
			     "convert the pads on the board to your",
			     "color.  Detailed information on the",
			     "various activities is available during",
			     "game play if you press the HELP button."};

    Clear_Block(screenBuff, 4000);
    Setscreen(screenBuff, screenBuff, -1);

    Set_Font(2);
    my_fcolor(RED,LT_RED);
    PrintScreen(16, rules1, FALSE);
    
    Setscreen(mainScreen, mainScreen, -1);
    Clear_Block(screenBuff, 4000);
    Clear_Keys();
end /* of Show Rules */



/*************************************************************************
 *   This section contain routines that allow game options to be set .   *
 *************************************************************************/

/*************************************************
 * This routine prints the game control options. *
 *************************************************/
static void WriteControl(who)
    short who;
begin
    static short smcolors[] = {IR, LT_VIO, LT_RED, UV};
    static char *stickMsg[] = {"Joystick 0", "Joystick 1"};

    Set_Font(2);
    my_fcolor(smcolors[who], smcolors[who + 2]);
    my_ftext(5 + (who*20), 35, stickMsg[gameCtrl[who]]);
end /* of Write Stick Control Mode */


/* Some routines to print some things for Setopts() */
static void WriteMode(mode)
    short mode;
begin
    static short mcolors[] = {YELLOW, RED,    UV,     GREEN,
			      GREEN,  DK_RED, VIOLET, BLUE};
    static char *modeMsg[] = {"Two-Player Mode", " Computer  Red ",
			      "Computer Violet", "   Demo Mode   "};

    Set_Font(2);
    my_fcolor(mcolors[mode], mcolors[mode+4]);
    my_ftext(13, 60, modeMsg[mode]);
end /* of Write Mode PROC */


static void WriteOrder(first)
    short first;
begin
    static short ocolors[] = {RED, UV, DK_RED, VIOLET};
    static char *orderMsg[] = {" Red  Player ",	"Violet Player"};

    Set_Font(2);
    my_fcolor(ocolors[first], ocolors[first + 2]);
    my_ftext(14, 85, orderMsg[first]);
end /* of Write Order PROC */


static void WriteBmode(bmode)
    short bmode;
begin
    static short bmcolors[] = {RED, YELLOW, GREEN, IR};
    static char *boardMsg[] = {"Standard", " Random "};

    Set_Font(2);
    my_fcolor(bmcolors[bmode], bmcolors[bmode+2]);
    my_ftext(16, 110, boardMsg[bmode]);
end /* of Write Board Setup Mode PROC */


/* Write the Save/Waste Unused Power Option */
static void WritePower(savePower)
    short savePower;
begin
    static short spcolors[] = {IR,RED, UV,VIOLET};
    static char *spmode[] = {"F6 IGNORE UNUSED POWER",
			     " F6 SAVE UNUSED POWER "};

    Set_Font(1);
    my_fcolor(spcolors[savePower], spcolors[savePower+2]);
    my_ftext(10,130, spmode[savePower]);
end /* of Write Power Save Mode */



/* This routine lets the player(s) set the game options. */
BOOLEAN Set_Options()
begin
    static short mode, first, nokey;
    static long key;
    ulong vbcount;
    BOOLEAN quit, done;
    short hikey;

    Clear_Keys();
    Clear_Block(mainScreen, 4000);
    Setscreen(mainScreen, mainScreen, -1);

    mode = player[REDPLAYER].comp | player[VIOPLAYER].comp;
    first = playerOrder[REDPLAYER];

    my_fcolor(UV, BLUE);
    my_ftext(5, 0, "SPECTRAL SORCERY GAME OPTIONS");

    Set_Font(1);
    my_fcolor(WHITE,GRAY);
    my_ftext( 4, 25,"F1 PLAYER ONE");
    my_ftext(24, 25,"F2 PLAYER TWO");
    my_ftext(11, 50,"F3 COMPUTER CONTROL");
    my_ftext(13, 75,"F4 PLAYER ORDER");
    my_ftext( 9,100,"F5 BOARD CONFIGURATION");
    WritePower(savePower);

    Set_Font(1);
    my_fcolor(WHITE, GRAY);
    my_ftext(11, 160, "Press     to Quit");
    Set_Font(2);
    my_fcolor(UV, VIOLET);
    my_ftext(17, 160, "ESC");

    Set_Font(1);
    my_fcolor(WHITE, GRAY);
    my_ftext(10, 170, "Press       to Start");
    Set_Font(2);
    my_fcolor(IR, LT_RED);
    my_ftext(16, 170, "SPACE");

    Set_Font(1);
    my_fcolor(WHITE, GRAY);
    my_ftext(7, 180, "Press      for Instructions");
    Set_Font(2);
    my_fcolor(BLUE,GRAY);
    my_ftext(13, 180, "HELP");

    WriteControl(REDPLAYER);
    WriteControl(VIOPLAYER);
    WriteMode(mode);
    WriteOrder(first);
    WriteBmode(bmode);

    done = quit = FALSE;
    do begin
        vbcount = SetWait(3600L);
	nokey = TRUE;
	while ((nokey) AND (VBCLOCK < vbcount)) begin
	    if (Bconstat(2)) begin
		key = Bconin(2);
		hikey = (key RSH 16) & 0xff;
		key &= 0xff;
		nokey = FALSE;
	    end /* of process a key */
	end /* of process a key */

	if (nokey) begin
	    mode = 3;	/* set DEMO mode */
	    break;	/* exit to setting parameters */
	end /* of go to DEMO mode if timeout occurs */

	if (key == ' ') begin
	    quit = FALSE;	done = TRUE;

        end else if (key == ESC) begin
	    quit = done = TRUE;		/* Exit Game */

	end else begin
	    switch (hikey) begin
	    case HELPKEY:
		ShowRules();
		break;
	    case FUNC1:
		gameCtrl[REDPLAYER] XOR= 1;	/* Red Controller */
		WriteControl(REDPLAYER);
		break;
	    case FUNC1+1:
		gameCtrl[VIOPLAYER] XOR= 1;	/* Violet Controller */
		WriteControl(VIOPLAYER);
		break;
	    case FUNC1+2:
		mode = (++mode) MOD 4;	/* Computer Control */
		WriteMode(mode);
		break;
	    case FUNC1+3:
		first XOR= 1;		/* Who goes first */
		WriteOrder(first);
		break;
	    case FUNC1+4:
		bmode XOR= 1;		/* Board Configuration */
		WriteBmode(bmode);
		break;
	    case FUNC1+5:
		savePower XOR= 1;	/* Save power from turn to turn */
		WritePower(savePower);
	    end /* of button switch */
	end /* of check key */
    end while (!done);

    playerOrder[0] = first;	
    playerOrder[1] = 1 - first;
    player[REDPLAYER].comp = mode & 1;
    player[VIOPLAYER].comp = mode & 2;

    if (gameCtrl[REDPLAYER] == gameCtrl[VIOPLAYER]) begin
	gameCtrl[2] = gameCtrl[REDPLAYER];
    end else begin
	gameCtrl[2] = -1;
    end /* of set 'both players stick id' */

    Set_Font(1);
    return(quit);
end /* of Set Options */
