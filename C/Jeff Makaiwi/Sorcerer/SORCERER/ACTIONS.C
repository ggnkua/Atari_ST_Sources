/* This file contains the routine to execute the spells. */

#include "readable.h"
#include "sorcery.h"
#include <osbind.h>


/* External Variable References */
extern PLINFO player[];
extern BDTYPE board;
extern short contGame, gameCtrl[], scanPad[][2], targetRow, targetCol;
extern short imageBuff1[], imageBuff2[], maskBuff1[], maskBuff2[];
extern short teleBuff[4][600], tmaskBuff[4][400];
extern long background[];

/* Global Variables that are used here mostly */
short tpadCounter, spellIgnite[8] = {0, 1, 1, 16, 9, 1, 1, 1};



/* Local Global Variables */
static BOOLEAN helpflag;	/* place to store the HELP key flag */
static short blitzQueue[50];	/* used for recursion in BLITZ */
static char *powerMsg = "You don't have enough power for that.";


/* External Function References */
/* from GRAPHICS.C */
extern BOOLEAN Tweek();
extern void Mid_Spell(), Update_Screen(), Change_Pad(), Prep_Wizard(), Hop(),
	    Draw_Wizard(), Draw_Edge(), Flip_Screens(), Exec_Teleport();

/* from TEXTIO.C */
extern void Clear_Line(), Print_Message(), Print_Line(), Print_Color();

/* from UTILS.C */
extern BOOLEAN On_Board(), Move_Pos();
extern short Is_Locked(), Color_Dist(), Next_Color(), Pad_Range(), Read_Stick();
extern void Wiz_Pos(), Pad_Pos(), Wait_Stick(), Key_Options(), Event_Timer(),
	    Ding(), Thudd();

/* from DRAWING.S */
extern void Copy_Block();

/* from STICKS.S */
extern short Stick();



/************************************************************************
 *   This section contains the routines used to implement the spells.   *
 ************************************************************************/

/******************************************************************************
  This routine raises the wizard's staff at the start of a spell.
 ******************************************************************************/
static void StartSpell(who)
    short who;
begin
    short i,j, x,y, ex,ey, front;

    front = 1 - who;
    Wiz_Pos(who, player[who].row, player[who].col, &x, &y);
    Wiz_Pos(front, player[front].row, player[front].col, &ex, &ey);
    Prep_Wizard(front, ex, 0, imageBuff2, maskBuff2);

    front = (y > ey);

    for (i = 6; i <=9; i++) begin
	Copy_Block(background, Logbase(), 3200);
	Prep_Wizard(who, x, i, imageBuff1, maskBuff1);
	if (front) begin
	    Draw_Wizard(ex, ey, imageBuff2, maskBuff2);
	    Draw_Wizard(x, y, imageBuff1, maskBuff1);
	end else begin
	    Draw_Wizard(x, y, imageBuff1, maskBuff1);
	    Draw_Wizard(ex, ey, imageBuff2, maskBuff2);
	end /* of draw images */
	Flip_Screens();
        Mid_Spell(-1);
    end /* raise staff */

    for (j = 0; j <= 5; j++) begin
	for (i = 10; i <= 11; i++) begin
	    Copy_Block(background, Logbase(), 3200);
	    Prep_Wizard(who, x, i, imageBuff1, maskBuff1);
	    if (front) begin
		Draw_Wizard(ex, ey, imageBuff2, maskBuff2);
		Draw_Wizard(x, y, imageBuff1, maskBuff1);
	    end else begin
		Draw_Wizard(x, y, imageBuff1, maskBuff1);
		Draw_Wizard(ex, ey, imageBuff2, maskBuff2);
	    end /* of Draw in precedence order */
	    Flip_Screens();
	end /* of single frame flicker */
    end /* of flicker before stabilizing */
end /* of Start Spell */



/******************************************************************************
  This routine lowers a wizard's staff after a spell is over.
 ******************************************************************************/
static void EndSpell(who)
    short who;
begin
    short i, x,y, ex,ey, front;

    front = 1 - who;
    Wiz_Pos(who, player[who].row, player[who].col, &x, &y);
    Wiz_Pos(front, player[front].row, player[front].col, &ex, &ey);
    Prep_Wizard(front, ex, 0, imageBuff2, maskBuff2);

    front = (y > ey);

    for (i = 11; i >= 6; i--) begin
	Copy_Block(background, Logbase(), 3200);
	Prep_Wizard(who, x, i, imageBuff1, maskBuff1);
	if (front) begin
	    Draw_Wizard(ex, ey, imageBuff2, maskBuff2);
	    Draw_Wizard(x, y, imageBuff1, maskBuff1);
	end else begin
	    Draw_Wizard(x, y, imageBuff1, maskBuff1);
	    Draw_Wizard(ex, ey, imageBuff2, maskBuff2);
	end /* of Draw in precedence order */
	Flip_Screens();
    end /* of lower staff loop */

    Update_Screen(0,0, -1,-1, 0);
end /* of End Spell */



/******************************************************************************
  This routine executes the CONVERT spell.
 ******************************************************************************/
static short Do_Convert(who)
    short who;
begin
    short row, col, *power, *color, mycolor;

    StartSpell(who);
    row = player[who].row;		col = player[who].col;
    power = &player[who].power;		color = &board.grid[row][col];
    mycolor = RED + (who * 4);

    if (*color == mycolor) begin
	Tweek(who, row, col, FALSE, TRUE, TRUE);
	Mid_Spell(who);		Mid_Spell(who);
    end else begin
	while ((*power > 0) AND (Tweek(who, row, col, FALSE,TRUE,FALSE))) begin
	    Mid_Spell(who);	Mid_Spell(who);
	end /* of Tweek until power gone or pad is not same color */
    end /* of Wrap Tweek or Tweek in a series of steps. */

    EndSpell(who);
    return(1);
end /* of Do Convert spell */



/******************************************************************************
  This routine executes a Computer controlled TELEPORT.
 ******************************************************************************/
static short Comp_Teleport(who)
    short who;
begin
    short x,y, newx,newy, ex,ey;
	
    Wiz_Pos(who, player[who].row,player[who].col, &x,&y);
    Wiz_Pos(who, targetRow,targetCol, &newx,&newy);
    Wiz_Pos(1-who, player[1-who].row,player[1-who].col, &ex,&ey);

    Exec_Teleport(who, ex,ey, x,y, newx,newy);

    player[who].row = targetRow;
    player[who].col = targetCol;
    player[who].power -= (Color_Dist(board.grid[targetRow][targetCol],
				     ((who*4)+RED)) + 1);

    Ding(3,2);	    Update_Screen(0,0, -1,-1, 40);
    return(1);
end /* of Computer Teleport */



/******************************************************************************
  This routine handles a human controlled TELEPORT.
 ******************************************************************************/
static short Do_Teleport(who)
    short who;
begin
    static char	*msg2 = "Select another target pad.";
    static dir,oldDir,sflag,wflag,selected,stickID,cost;
    short i, row,col, tRow,tCol, x,y, newX,newY, ex,ey, *power, result = 0;

    tpadCounter = 0;
    tRow = row = player[who].row;
    tCol = col = player[who].col;
    power = &player[who].power;
    stickID = gameCtrl[who];
    Update_Screen(0,0, row,col, 0);

    do begin
	selected = FALSE;	oldDir = 0;
	do begin
	    Key_Options(&contGame, &helpflag);
	    dir = Stick(stickID);
	    if (dir != oldDir) begin
		oldDir = dir;
		if (dir & 0x80) begin
		    break;	/* exit loop with button event */
		end else if ((dir & 0x0f)) begin
		    x = tRow;	y = tCol;
		    Move_Pos(dir, &tRow, &tCol);
		    if ((tRow != x) OR (tCol != y)) begin
			Ding(3, (board.grid[tRow][tCol] & 0xff));
			if ((tRow != row) OR (tCol != col)) begin
			    Print_Color(tRow, tCol);
			end else begin
			    Print_Line(2, WHITE,GRAY, "CANCEL");
			end /* of Print 'Cancel' message */
		    end /* of ON or OFF board */
		end /* of stick or button event */
	    end /* of ignore non-changing stick */
	    Update_Screen(0,0, tRow,tCol, 0);
	end while (contGame); /* target selection loop */

	if ((contGame) AND ((tRow != row) OR (tCol != col))) begin
	    cost = Color_Dist((who*4)+RED, board.grid[tRow][tCol]) + 1;
	    if (*power >= cost) begin
		result = 1;	/* good target selected */
		break;		/* exit Teleport Loop */
	    end else begin

		Print_Message(who, 2, WHITE,YELLOW, 4,1, 0, powerMsg);
		i = 80;		oldDir = 0;
		sflag = FALSE;	wflag = TRUE;
		do begin
		    Update_Screen(0,0, tRow,tCol, 0);
		    Key_Options(&contGame, &helpflag);
		    dir = Stick(stickID);
		    if (wflag) begin
			wflag = (dir != 0);
		    end else begin
			sflag = ((dir != oldDir) AND (oldDir));
			oldDir = dir;
		    end /* of set escape flag */
		end while ((i-- >= 0) AND (contGame) AND (!sflag));

		Print_Message(who, 2, YELLOW,WHITE, 4,2, 0, msg2);
		i = 80;		oldDir = 0;
		sflag = FALSE;	wflag = TRUE;
		do begin
		    Update_Screen(0,0, tRow,tCol, 0);
		    Key_Options(&contGame, &helpflag);
		    dir = Stick(stickID);
		    if (wflag) begin
			wflag = (dir != 0);
		    end else begin
			sflag = ((dir != oldDir) AND (oldDir));
			oldDir = dir;
		    end /* of set escape flag */
		end while ((i-- >= 0) AND (contGame) AND (!sflag));

		Clear_Line(2);		cost = 0;

	    end /* check for sufficient TELEPORT energy */
	end else begin
	    cost = 0;		/* not enough power or game ABORT */
	    break;		/* exit Teleport Loop */
	end /* of check for CANCELLATION */
    end while (contGame); /* Teleport Loop */

    if ((contGame) AND (result)) begin
	Wiz_Pos(who, row,col, &x,&y);
	Wiz_Pos(who, tRow,tCol, &newX,&newY);
	Wiz_Pos(1-who, player[1-who].row, player[1-who].col, &ex,&ey);

	Exec_Teleport(who, ex,ey, x,y, newX,newY);

	player[who].row = tRow;		player[who].col = tCol;
	*power -= cost;
    end /* of Teleport if result positive */
    Ding(3,2);		Update_Screen(0,0, -1,-1, 0);
    Wait_Stick(who);
    return(result);
end /* of Do Teleport */



/******************************************************************************
  This routine checks all pads that are edge-on with the specified pad
  to see if they will be affected by the BLITZ.  If the pad is eligible
  to be BLITZed, then its location is placed at the end of a blitzqueue.
 ******************************************************************************/
static void Find_Adjacent(bqp, color, row, col)
    short *bqp, color, row, col;
begin
    short nRow, nCol, dir;
    BOOLEAN found = FALSE;

    for (dir = 0; dir < 4; dir ++) begin
	nRow = row + scanPad[dir][0];
	nCol = col + scanPad[dir][1];
	if ((nRow >= MINROW) AND (nRow <= MAXROW) AND
	    (nCol >= MINCOL) AND (nCol <= MAXCOL)) begin
	    if (board.grid[nRow][nCol] == color) begin
		board.grid[nRow][nCol] |= 0x8000;	/* mark as used */
		blitzQueue[(*bqp)++] = nRow;
		blitzQueue[(*bqp)++] = nCol;
	    end /* of check for a good Pad */
	end /* of find Pad on the board */
    end /* of search loop */
end /* of Find Adjacent BLITZ Pad */


/******************************************************************************
  This routine applies the recursive BLITZ spell in an iterative manner.
 ******************************************************************************/
static short Do_Blitz(who)
    short who;
begin
    short i, row,col, ccolor,tcolor, bqp, *power;

    StartSpell(who);
    contGame = TRUE;	power = &player[who].power;
    do begin
	bqp = 0;	row = player[who].row;	col = player[who].col;
	ccolor = board.grid[row][col] & 0xff;
	tcolor = Next_Color(who, ccolor, FALSE);
	Key_Options(&contGame, &helpflag);

	while ((tcolor != ccolor) AND (contGame)) begin
	    if ((board.grid[row][col] & 0xff) != tcolor) begin
		Change_Pad(row, col, tcolor);	(*power)--;
	        Ding(2, tcolor);
		Mid_Spell(who);		Mid_Spell(who);
	    end /* of change Pad color */

	    Find_Adjacent(&bqp, ccolor, row,col);
	    if ((*power <= 0) OR (bqp == 0)) begin
		break;
	    end else begin
		row = blitzQueue[0];	col = blitzQueue[1];
		if ((bqp -= 2) > 0) begin
		    for (i = 0; i < bqp; i++) begin
			blitzQueue[i] = blitzQueue[i+2];
		    end /* of update queue */
		end /* of update only if needed */
	    end /* of select next target pad */

	    Key_Options(&contGame, &helpflag);;

	end /* of 1 pass of Blitz */

    end while ((ccolor != tcolor) AND (*power > 0) AND (contGame));

    for (i = 0; i <= 24;) begin
	board.linear[i++] &= 0x7fff;
    end /* of fix all board pads */
    EndSpell(who);
    return(1);
end /* of Blitz Spell */



/******************************************************************************
  This routine executes the TRANSMUTE spell.
 ******************************************************************************/
static short Do_Transmute(who)
    short who;
begin
    short i, row,col, trow,tcol;

    StartSpell(who);
    row = player[who].row;	col = player[who].col;
    for (i = 0; i < 9; i++) begin
	trow = row + scanPad[i][0];
	tcol = col + scanPad[i][1];
	if (On_Board(trow, tcol)) begin
	    if (Tweek(who, trow, tcol, FALSE, TRUE, FALSE)) begin
		Mid_Spell(who);
		Mid_Spell(who);
	    end /* of do a Tweek */
	end /* of do it if on the board */
    end /* of scan TRANSMUTE zone */
    EndSpell(who);
    return(1);
end /* of Do Transmute */



/******************************************************************************
  This routine locks the pad that the specified wizard is on.
 ******************************************************************************/
static short Do_Lock(who)
    short who;
begin
    static char *msg1 = "The Pad is Now LOCKed.";
    short row,col, cost, x,y;

    row = player[who].row;		col = player[who].col;
    cost = ((Color_Dist(board.grid[row][col], (who*4)+RED)) / 2) + 1;
    if (cost <= player[who].power) begin
	StartSpell(who);
	board.grid[row][col] |= ((who + 1) LSH 8);
	player[who].power -= cost;
	Pad_Pos(row,col, &x,&y);	Draw_Edge(x,y, who+1);
	Ding(3,4);			Mid_Spell(who);
	EndSpell(who);
	Print_Message(who, 2, IR+who,(board.grid[row][col] & 0xff),
		      -1,-1, 120, msg1);
	Clear_Line(2);
	return(1);
    end else begin
	Print_Message(who, 2, WHITE,GRAY, 4,1, 120, powerMsg);
	Clear_Line(2);
	return(0);
    end /* of Power Check */
end /* of Do Lock */



/******************************************************************************
  This routine UNLOCKs the pad the wizard is on.
 ******************************************************************************/
static short Do_Unlock(who)
    short who;
begin
    static char *msg1 = "This Pad is not LOCKed!",
		*msg2 = "The Pad is now UNLOCKed.";
    short row,col, cost, lockStatus, x,y;

    row = player[who].row;		col = player[who].col;
    lockStatus = Is_Locked(who, row, col);
    cost = ((Color_Dist(board.grid[row][col], (who*4)+RED)) / 2) + 1;
    cost += (player[who].advantage / 5);
    if (lockStatus < 0) begin
	cost = 0;		/* self-lock removal cost */
    end /* of set cost */

    if (lockStatus == 0) begin

	Print_Message(who, 2, WHITE,RED+(who*7), 3,5, 120, msg1);

    end else if (cost <= player[who].power) begin

	StartSpell(who);
	player[who].power -= cost;	/* deduct power cost */
	lockStatus = 0;
	board.grid[row][col] &= 0xff;
	Pad_Pos(row,col, &x,&y);
	Draw_Edge(x,y, 0);		Mid_Spell(who);
	Ding(3,9);			EndSpell(who);
	Print_Message(who, 2, WHITE,IR+who, -1,-1, 120, msg2);

    end else begin
	Print_Message(who, 2, WHITE,GRAY, 4,1, 120, powerMsg);
    end /* of check for sufficient power */
    Clear_Line(2);
    return(0);
end /* of Do Unlock */



/******************************************************************************
  This routine RELEASEs all of the specified player's pads.
 ******************************************************************************/
static short Do_Release(who)
    short who;
begin
    static char	*msg1 = "All of Your LOCKs are Gone.",
		*msg2 = "You Don't Have Any Locks!";
    short row,col, x,y, mask, count=0;

    StartSpell(who);
    mask = (who + 1) LSH 8;
    for (row = MINROW; row <= MAXROW; row++) begin
	for (col = MINCOL; col <= MAXCOL; col++) begin
	    if (board.grid[row][col] & mask) begin
		board.grid[row][col] &= 0xff;
		Pad_Pos(row,col, &x,&y);
		Draw_Edge(x,y, 0);	Ding(3, 10);
		Mid_Spell(who);		Mid_Spell(who);
		count++;
	    end /* of draw only if an LOCK was yanked */
	end /* of do a row */
    end /* of remove all masks */

    if (count > 0) begin
	player[who].power--;	EndSpell(who);
	Print_Message(who, 2, WHITE,RED+(who*7), 3,11, 120, msg1);
	Clear_Line(2);
	return(1);
    end else begin
	EndSpell(who);
	Print_Message(who, 2, WHITE,GRAY, 3,11, 120, msg2);
	Clear_Line(2);
	return(0);
    end /* of what happened */
end /* of Do Release */



/******************************************************************************
  This routine calls the correct spells as requested by a human or brains.
 ******************************************************************************/
short Do_Cast(who, spell, helpme)
    short who, spell;
    BOOLEAN helpme;
begin
    short result = 0;
    static char *msg1 = "The Pad is LOCKed!",
		*msg2 = "Your Spell has Failed!",
		*msg3 = "Not Enough Power to Ignite Spell.",
		*msg4 = "Choose Another Action.";

    if (player[who].power >= spellIgnite[spell]) begin

	if ((spell == CONVERT) OR (spell == BLITZ) OR
	    (spell == LOCK)) begin
	    result = Is_Locked(who, player[who].row, player[who].col);
	end /* of these worry about LOCKS */
    
	if (!result) begin
	    switch (spell) begin
		case CONVERT:
		    result = Do_Convert(who);
		    break;
		case TELEPORT:
		    if ((player[who].comp) OR (helpme)) begin
			result = Comp_Teleport(who);
		    end else begin
			result = Do_Teleport(who);
		    end /* of Human or Computer Teleport */
		    break;
		case BLITZ:
		    result = Do_Blitz(who);
		    break;
		case TRANSMUTE:
		    result = Do_Transmute(who);
		    break;
		case LOCK:
		    result = Do_Lock(who);
		    break;
		case UNLOCK:
		    result = Do_Unlock(who);
		    break;
		case RELEASE:
		    result = Do_Release(who);
	    end /* of switch */

	    if ((result == 0) AND (contGame)) begin
		Print_Message(who, 2, YELLOW,RED, 3,7, 120, msg4);
	    end /* of indicate cancellation */

	end else begin
	    result = 1;
	    Update_Screen(0,0, -1,-1, 0);
	    Print_Message(who, 2, RED,UV, 3,3, 120, msg1);
	    Wait_Stick(who);
	    Print_Message(who, 2, RED+(who*6),DK_RED+(who*2), 3,2, 120, msg2);
	end /* of LOCKed or not LOCKed */

    end else begin
	result = 0;
	Print_Message(who, 2, WHITE,GRAY, 3,8, 120, msg3);
	Wait_Stick(who);
	Print_Message(who, 2, YELLOW,RED, 3,7, 120, msg4);
    end /* of check for ignition power */
    Clear_Line(2);
    return(result);
end /* of Do Cast */


/*********************************************************
 *   This section contains the "pure" ACTION routines.   *
 *********************************************************/

/******************************************************************************
  This routine handles a computer controlled MOVE. 
 ******************************************************************************/
short Comp_Move(who, trow, tcol)
    short who, trow, tcol;
begin
    register short *power;
    short row, col;

    row = player[who].row;	col = player[who].col;
    power = &player[who].power;
    Print_Color(row, col);

    if (row != trow) begin
	Hop(who, row, col, trow, col);
	row = trow;
	Print_Color(row, col);
	Event_Timer(12, 1-who);
    end /* of hop to a pad */

    if (col != tcol) begin
	Hop(who, row, col, row, tcol);
	col = tcol;
	Print_Color(row, col);		Event_Timer(12, 1-who);
    end /* and again if necessary */

    player[who].row = trow;	player[who].col = tcol;
    if ((--player[who].power) > 0) begin
	Tweek(who, row, col, TRUE, TRUE, FALSE);
    end /* of Enough power to change pad color */
    Update_Screen(0,0, -1,-1, 0);
    Event_Timer(30, 1-who);
    return(1);
end /* of Computer Move */



/******************************************************************************
  This routine reads the appropriate joystick and moves the Wizard indicated
  by 'who'.  It updates the position and checks for cancellation.
 ******************************************************************************/
short Do_Move(who)
    short who;
begin
    static char *msg1 = "You Cannot Move That Far!";
    static char *msg2 = "You Cannot Leave The Board!";
    static char *msg3 = "Your MOVE is Cancelled.";
    short dir, row, col, lastRow, lastCol, oRow, oCol, *power, mycolor;
    BOOLEAN done=FALSE;

    mycolor = RED + (who * 4);
    power = &player[who].power;
    oRow = row = player[who].row;
    oCol = col = player[who].col;
    Print_Color(row, col);

    do begin
	dir = Read_Stick(who);		/* Read Correct Joystick */
	if ((!(dir & 0x80)) AND (contGame)) begin

	    lastRow = row;	lastCol = col;
	    if (!Move_Pos(dir, &row, &col)) begin

		if (Pad_Range(oRow, oCol, row, col) <= 1) begin
		    Hop(who, lastRow, lastCol, row, col);
		    lastRow = row;	lastCol = col;
		    if ((row != player[who].row) OR
			(col != player[who].col)) begin
			Print_Color(row, col);
		    end else begin
			Print_Line(2, WHITE,GRAY, "CANCEL");
		    end /* of Print color or Cancel */

		end else begin
		    /* Can't Move so Far */
		    row = lastRow;	col = lastCol;
		    Print_Message(who, 3, WHITE,GRAY, 4,9, 60, msg1);
		    Clear_Line(3);
		end /* of Check for Moving too Far */

	    end else begin
		/* Can't Leave Board */
		Print_Message(who, 3, WHITE,GRAY, 4,7, 60, msg2);
		Clear_Line(3);
	    end /* of Check for Leaving Board */

	end else begin
	    done = TRUE;	/* Button pressed */
	end /* of button pressed or not */

	Wait_Stick(who);

    end while ((!done) AND (contGame));

    if (contGame) begin
	if ((row == player[who].row) AND (col == player[who].col)) begin
	    Print_Message(who, 2, WHITE,RED+(who LSH 2), 3,who+1, 60, msg3);
	    done = 0;
	end else begin
	    player[who].row = row;	player[who].col = col;
	    if ((--player[who].power) > 0) begin
		done = Tweek(who, row, col, TRUE, TRUE, FALSE);
	    end /* of Enough power to change pad color */
	    done = 1;	
        end /* of Check for Cancel */
    end /* of do this if the game is still on */
    Update_Screen(0,0, -1,-1, 30);;
    return(done);
end /* of Do Move */



/******************************************************************************
  This routine executes the STOMP action.
 ******************************************************************************/
short Do_Stomp(who)
    short who;
begin
    static short stompPos[] = {0, 3, 7, 10, 12, 10, 7, 3, 0};
    short i, other, lat, front, x, y, ex, ey, newY;
    ulong vbcount;

    other = 1 - who;
    Wiz_Pos(other, player[other].row, player[other].col, &ex, &ey);
    Wiz_Pos(who, player[who].row, player[who].col, &x, &y);
    Prep_Wizard(other, ex, 0, imageBuff2, maskBuff2);

    if (who == REDPLAYER) begin
	lat = 3;
    end else begin
	lat = -3;
    end /* of set lateral vector */

    front = (y >= ey);

    for (i = 1; i <= 8; i++) begin
        vbcount = SetWait(3L);
	x += lat;	newY = y - stompPos[i];
	Copy_Block(background, Logbase(), 3200);
	Prep_Wizard(who, x, 0, imageBuff1, maskBuff1);
	if (front) begin
	    Draw_Wizard(ex, ey, imageBuff2, maskBuff2);
	    Draw_Wizard(x, newY, imageBuff1, maskBuff1);
	end else begin
	    Draw_Wizard(x, newY, imageBuff1, maskBuff1);
	    Draw_Wizard(ex, ey, imageBuff2, maskBuff2);
	end /* draw in precedence order */
	Wait(vbcount);	Flip_Screens();
    end		/* of do animation */

    Thudd();	Delay(15);

    for (i = 7; i >= 0; i--) begin
	vbcount = SetWait(3L);
	x -= lat;	newY = y - stompPos[i];
	Copy_Block(background, Logbase(), 3200);
	Prep_Wizard(who, x, 0, imageBuff1, maskBuff1);
	if (front) begin
	    Draw_Wizard(ex, ey, imageBuff2, maskBuff2);
	    Draw_Wizard(x, newY, imageBuff1, maskBuff1);
	end else begin
	    Draw_Wizard(x, newY, imageBuff1, maskBuff1);
	    Draw_Wizard(ex, ey, imageBuff2, maskBuff2);
	end /* draw in precedence order */
	Wait(vbcount);	Flip_Screens();
    end		/* of do animation */

    Thudd();
    Tweek(who, player[who].row, player[who].col, TRUE,FALSE,FALSE);
    Update_Screen(0,0, -1,-1, 30);
    return(1);
end /* of Do Stomp */
