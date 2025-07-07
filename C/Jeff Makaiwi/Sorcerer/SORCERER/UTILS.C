/*****************************************************************************
 *  This file is a collection of general usage routines.  Steal what you can *
 *  make use of, that's why they're here in their own file.                  *
 *****************************************************************************/

#include "readable.h"
#include "sorcery.h"
#include <osbind.h>



/************************************
 *   External Function References   *
 ************************************/
/* from TB_TEXT.S */
extern void my_ftext(), my_fcolor();


/************************************
 *   External Variable references   *
 ************************************/
extern BDTYPE board;
extern char notes[][12][2];
extern short gameCtrl[], contGame, scanPad[][2];


/* Local Global Variables */
static short helpflag;		/* place to store the help flag */



/* External Function References */
/* STICKS.S */
extern short Stick();



/***********************************************
 * Check Keys for Game Abort and help request. *
 ***********************************************/
void Key_Options(contGame, help)
    short *contGame, *help;
begin
    static long mybuff[400];
    long key, phys, log;

    if (Bconstat(2)) begin
	key = Bconin(2);
	*contGame = ((short)key != ESC);
	*help = ((short)(key RSH 16) == HELPKEY);
	if (!(*contGame)) begin
	    Copy_Block((phys = ((long)Physbase() + 30400L)), mybuff, 200);

	    my_fcolor(WHITE, GRAY);
	    my_ftext(9,190, "Press     to Abort Game");
	    my_fcolor(RED,VIOLET);
	    my_ftext(15,190, "ESC");
	    Copy_Block((log = ((long)Logbase() + 30400L)), phys, 200);

	    while (!Bconstat(2));
	    *contGame = ((short)Bconin(2) != ESC);

	    Copy_Block(mybuff,phys, 200);
	    Copy_Block(mybuff,log,  200);
	end /* of verify abort */
    end /* of check for ABORT (UNDO) */
end /* of Abort Game check */



/*************************
 *   Joystick Routines   *
 *************************/

/***********************************************************************
 * This routine checks for ABORT, reads a stick and returns its value. *
 ***********************************************************************/
short Read_Stick(which)
    short which;
begin
    short stickID, result;

    stickID = gameCtrl[which];
    do begin
	result = Stick(stickID);
	Key_Options(&contGame, &helpflag);
    end while ((!result) AND (contGame));
    return(result);
end /* of Read JoyStick */


/*****************************************************************
 * This routine waits for a stick to go still or for game ABORT. *
 *****************************************************************/
void Wait_Stick(which)
    short which;
begin
    BOOLEAN flag = FALSE;
    short stickID = which;

    if ((stickID >= 0) AND (stickID <= 2)) begin
	stickID = gameCtrl[stickID];
    end else begin
	stickID = -1;
    end /* of set controller to check */

    do begin
	Key_Options(&contGame, &helpflag);
    end while ( (Stick(stickID)) AND (contGame) );
end /* of Wait for Zero Stick */



/********************************
 *   General Purpose Routines   *
 ********************************/

/********************************************************
 * This routine returns a short (16-bit) random number. *
 ********************************************************/
short My_Random(lo, hi)
    short lo, hi;
begin
    return( (((short)Random() & 0x7fff) MOD abs(hi-lo)) + lo );
end /* of My Random number generator */


/********************************************
 * This routine clears the keyboard buffer. *
 ********************************************/
void Clear_Keys()
begin
    while (Bconstat(2)) begin
	Bconin(2); /* chuck what comes up */
    end /* of kill a key */
end /* of Clear Keyboard buffer */



/**********************
 *   Sound Routines   *
 **********************/

/**********************************************************
 * This routine makes the Thudd sound for MOVE and STOMP. *
 **********************************************************/
void Thudd()
begin
    static BYTE thud[] = {CHA_F,0xff, CHA_C,0x09,  NOISE_P,0x1e, ENABLE,0xf7,
			  VOL_A,0x1f, ENVP_F,0x00, ENVP_C,0x11,  ENV_SH,0x09,
			  DTIMER,0x00};

    Dosound(thud);
end /* of Thudd */


/*******************************************************************
 * This routine make the dematerialization/materialization sounds. *
 *******************************************************************/
void Tele_Sound(which)
    short which;	/* 0 = demat., 1 = mat. */
begin
    static BYTE demat[] = {CHB_F,0x00, CHB_C,0x08,  NOISE_P,0x1a, ENABLE,0xef,
			   VOL_B,0x1f, ENVP_F,0x00, ENVP_C,0x08,  ENV_SH,0x0d,
			   LD_TEMP,0x30, DS_CNT,CHB_F,0x01,0xc0,  DTIMER,0x00},
		mater[] = {CHB_F,0x00, CHB_C,0x08,  NOISE_P,0x19, ENABLE,0xef,
			   VOL_B,0x1f, ENVP_F,0x00, ENVP_C,0x08,  ENV_SH,0x09,
			   LD_TEMP,0xc0, DS_CNT,CHB_F,0xff,0x30,  DTIMER,0x00};

    if (!which) begin
	Dosound(demat);
    end else begin
	Dosound(mater);
    end /* of do correct sound */
end /* of Teleport Sound */


/***********************************************************************
 * This routine processes the bell like sounds that the program makes. *
 ***********************************************************************/
void Ding(octave, note)
    short  octave, note;
begin
    static BYTE sounds[] = {CHA_F,0x00,  CHA_C,0x00,  ENABLE,0xfe,
			    VOL_A,0x1f,  VOL_B,0x00,  VOL_C,0x00,
			    ENVP_F,0x0c, ENVP_C,0x0a, ENV_SH,0x09,
			    DTIMER,0x00}; 

    sounds[1] = notes[octave][note][1];
    sounds[3] = notes[octave][note][0];
    Dosound(sounds);
end /* of Ding */


/**************************************************************
 * This routine halts any sound daemons that are in progress. *
 **************************************************************/
void Sound_Off()
begin
    static BYTE nosound[] = {VOL_A,0x00,  VOL_B,0x00,  VOL_C,0x00,
			     ENABLE,0xff, DTIMER,0x00};

    Dosound(nosound);
end /* of terminate all sound processes */



/**********************
 *   Timer Routines   *
 **********************/

/***********************************************************************
 * This routine waits for a specified number of vblanks, then returns. *
 ***********************************************************************/
void Delay(jikan)
    unsigned short jikan;	/* # of system clicks to wait */
begin
    register ulong vbcount;

    vbcount = SetWait((ulong) jikan);
    Wait(vbcount);
end /* of Delay */



/****************************************************************** 
 * This routine waits for either a joystick action or a time-out. *
 ******************************************************************/
void Event_Timer(jikan, who)
    short jikan, who;
begin
    register BOOLEAN flag = FALSE;	/* flag for stick checking */
    register short  stickID = who;	/* which controls to check */
    register ulong vbcount;

    if (jikan != 0) begin
	vbcount = SetWait((ulong) jikan);

	if ((stickID >= 0) AND (stickID <= 2)) begin
	    stickID = gameCtrl[who];
	end else begin
	    stickID = 2;
	end /* of select stick id */

	do begin
            flag |= Bconstat(2);	/* check for a key */
	    if (stickID <= 1) begin
		flag |= (Stick(stickID) & 0x8080);
	    end /* of check joystick */
	end while ( (!flag) AND (VBCLOCK < vbcount) );
    end /* do timer only if delay is non-zero */
end /* of Event Timer */


/************************************************************
 *   This section of the code contains the CALC routines.   *
 ************************************************************/

/*****************************************************************************
 * This routine converts a binary number (0-99) to a 2-digit ASCII sequence. *
 *****************************************************************************/
void BinToAscii(value, string)
    short value;
    char string[];
begin
    string[1] = (value MOD 10) + '0';
    value /= 10;
    string[0] = (value MOD 10) + '0';
end /* of Binary-to-ASCII conversion */



/***********************************************************************
 * This routine returns the next color in the player's color sequence. *
 ***********************************************************************/
short Next_Color(who, color, wrap)
    short  who, color, wrap;
begin
    register short nextColor;

    nextColor = color + (who LSH 1) - 1;
    if (nextColor > VIOLET) begin
	if (wrap) begin
	    nextColor = RED;
	end else begin
	    nextColor = VIOLET;
	end /* of wrap or truncate OVERFLOW */
    end else if (nextColor < RED) begin
	if (wrap) begin
	    nextColor = VIOLET;
	end else begin
	    nextColor = RED;
	end /* of wrap or truncate UNDERFLOW */
    end /* of fix overflows */
    return(nextColor);
end /* of Next Color */



/******************************************************
 * This routine calculates the pixel coords of a Pad. *
 ******************************************************/
void Pad_Pos(row, col, x, y)
    short  row, col, *x, *y;
begin
    *x = ((row + col) * 32) + XOFFSET;
    *y = (((4 - row) + col) * 11) + YOFFSET;
end /* of Pad Position */



/*********************************************************
 * This routine calculates the pixel coords of a Wizard. *
 *********************************************************/
void Wiz_Pos(who, row, col, x, y)
    short who, row, col, *x, *y;
begin
    *x = ((row + col) * 32) + XOFFSET + (who * 22);
    *y = (((4 - row) + col) * 11) + YOFFSET - 23;
end /* of Calc and return Wizard Pixel Coords */



/************************************************************************
 * This routine calculates the distance between to colors wrt spectrum. *
 ************************************************************************/
short Color_Dist(color1, color2)
    short color1, color2;
begin
    color1 &= 0xf;	color2 &= 0xf;
    if (color1 < color2) begin
	return(color2 - color1);
    end else begin
	return(color1 - color2);
    end /* of set color distance */
end /* of Color Distance */



/****************************************************************************
 * This routine checks a row and col position to see if it is on the board. *
 ****************************************************************************/
BOOLEAN On_Board(row, col)
    short row, col;
begin
    if ((row < MINROW) OR (row > MAXROW) OR
	(col < MINCOL) OR (col > MAXCOL)) begin
	return(FALSE);		/* not on the board */
    end else begin
	return(TRUE);		/* is on the board */
    end /* of return results */
end /* of check for On Board */



/**********************************************************
 * This routine calcs the MOVE distance between two pads. *
 **********************************************************/
short Pad_Range(oRow, oCol, row, col)
    short oRow, oCol, row, col;
begin
    register short r, c;

    r = oRow - row;    if (r < 0) r = -r;
    c = oCol - col;    if (c < 0) c = -c;
    return( Max(r,c) );
end /* of Pad Range */



/**************************************************************************
 * This routine calcs a new board position relative based on a stick dir. *
 **************************************************************************/
BOOLEAN Move_Pos(joy, row, col)
    short joy, *row, *col;
begin
    register short tRow = *row,		/* new row */
		 tCol = *col,		/* new column */
		 flag = FALSE;		/* legal move flag */

    if (joy & 1) begin

	if (--tCol < MINCOL) begin
	    tCol = MINCOL;	flag = TRUE;
	end /* of fix underflow */

    end else if (joy & 2) begin

	if (++tCol > MAXCOL) begin
	    tCol = MAXCOL;	flag = TRUE;
	end /* of fix overflow */

    end else if (joy & 4) begin

	if ((--tRow) < MINROW) begin
	    tRow = MINROW;	flag = TRUE;
	end /* of fix underflow */

    end else if (joy & 8) begin

	if ((++tRow) > MAXROW) begin
	    tRow = MAXROW;	flag = TRUE;
	end /* of fix overflow */

    end /* of which direction */

    *row = tRow;	*col = tCol;	
    return(flag);
end /* of calc new Move Position */



/************************************************************
 * This routine returns the status of a pad's locks.        *
 * 0 = UNLOCKed, 1 = opponent LOCKed, and -1 = self LOCKed. *
 ************************************************************/
short Is_Locked(who, row, col)
    short who, row, col;
begin
    register short locks;

    locks = (board.grid[row][col] RSH 8) & 0xff;
    if (!locks) begin
	return(0);	/* not LOCKed */
    end else if (locks == (who + 1)) begin
	return(-1);	/* self LOCKed */
    end else begin
	return(1);	/* opponent LOCKed */
    end /* of return lock status */
end /* of Is (pad) Locked */
