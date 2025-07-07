/* This file contains the routines that allow the computer to play. */

#include "readable.h"	/* My C Macros for Readability */
#include "sorcery.h"	/* Spectral Sorcery Standard Constants */
#include <osbind.h>



/* External Variable References */
extern PLINFO player[];
extern BDTYPE board;
extern char *actions[], *spells[], *playerName[];
extern long mainScreen, screenBuff, background[];
extern short contGame, gameCtrl[], playerOrder[], spellIgnite[],
	     scanPad[][2], targetRow, targetCol, savePower;



/* Local Global Variables */
static short mycolor, cdist, targPad[8];



/* External Function References */
/* from TEXTIO.C */
extern void Print_Line();

/* from UTILS.C */
extern BOOLEAN On_Board();
extern short Color_Dist(), Is_Locked(), My_Random();
extern void Event_Timer(), Key_Options();



/**************************************************************************
 *   This section contains some routines that rank the actions to take.   *
 **************************************************************************/

/******************************************************************************
  This routine calculates the value of a pad assuming that the one closest
  to the largest number of pads that are "far" from your color will be
  ranked higher than one that is close to pads of your color.
 ******************************************************************************/
static short PadValue(color, row, col)
    short color, row, col;
begin
    short i, trow,tcol, score = 0;

 /* The center pad is has double weight in its color value. */
    for (i = 0; i < 9; i++) begin
	trow = row + scanPad[i][0];
	tcol = col + scanPad[i][1];
	if (On_Board(trow, tcol)) begin
	    score += Color_Dist(color, board.grid[trow][tcol]);
	end /* of only add in things from the board */
    end /* of scan value region */
    return(score);
end /* of Pad Value */


/******************************************************************************
  Check to see if an UNLOCK is necessary and possible.
 ******************************************************************************/
static short CheckUnlock(who, row, col)
    short who, row, col;
begin
    short temp, cost;

    temp = Is_Locked(who, row, col);
    if ((board.grid[row][col] & 0xf) != mycolor) begin
	if (temp > 0) begin
	    cost = (Color_Dist(board.grid[row][col], mycolor) / 2) + 1;
	    cost += (player[who].advantage / 5);
	    if (cost <= player[who].power) begin
		return(1);	/* remove the lock */
	    end else begin
		return(2);	/* there is a lock, but can't remove it */
	    end /* report enemy lock vs. own power */
	end else if (temp < 0) begin
	    return(1);		/* remove own lock */
	end else begin
	    return(0);		/* no lock to remove */
	end /* of only if there is a lock */

    end else begin
	return(0);		/* own color or no lock */
    end /* return verdict */

end /* of Check Unlock */


/******************************************************************************
  Count the number of adjacent pads that would be affected by a BLITZ.
 ******************************************************************************/
static short CheckBlitz(row, col)
    short row, col;
begin
    short i, trow,tcol, count, color;

    for (i = count = 0; i < 4; i++) begin
	trow = row + scanPad[i][0];
	tcol = col + scanPad[i][1];
	if (On_Board(trow, tcol)) begin
	    color = board.grid[trow][tcol] & 0xff;
	    if ((cdist >= Color_Dist(color, mycolor)) AND
		(color != mycolor)) begin
		count++;
	    end /* good if adjacent is no farther from own color */
	end /* of check for pad on board */
    end /* of scan adjacent BLITZ range */
    return(count);
end /* of Check for blitz desirability */


/******************************************************************************
  This routine counts the number of pads that a TRANSMUTE would affect.
 ******************************************************************************/
static short CheckTransmute(row, col)
    short row, col;
begin
    short i, count, trow, tcol;

    for (i = count = 0; i < 9; i++) begin
	trow = row + scanPad[i][0];
	tcol = col + scanPad[i][1];
	if (On_Board(trow, tcol)) begin
	    if (board.grid[trow][tcol] != mycolor) begin
		count++;
	    end /* of check for affectability of pads */
	end /* of check for on board */
    end /* of scan TRANSMUTE zone */
    return(count);
end /* of Check for Transmute desirability */


/******************************************************************************
  This routine checks to see if a LOCK should be placed.
 ******************************************************************************/
static BOOLEAN CheckLock(who, row, col)
    short who, row, col;
begin
    short i, cost, trow, tcol, count, temp1;

    if (mycolor == board.grid[row][col]) begin
	cost = (Color_Dist(board.grid[row][col], mycolor) / 2) + 1;

	if (cost <= player[who].power) begin
	    for (i = count = temp1 = 0; i < 8; i++) begin
		trow = row + scanPad[i][0];
		tcol = col + scanPad[i][1];
		if (On_Board(trow, tcol)) begin
		    if (board.grid[trow][tcol] == mycolor) begin
			if (i < 4) begin
			    count++;	/* count BLITZable pads */
			end else begin
			    temp1++;	/* count secondary BLITZ pads */
			end /* of which counter to increment */
		    end /* count number of pads */
		end /* of check for pipeline position */
	    end /* of check for strategic position */

	    if ((count > 1) AND (temp1 == 0)) begin
		return(TRUE);
	    end /* of if in correct position, then place a lock */

	    if ((player[1-who].row == row) AND
		(player[1-who].col == col)) begin

		temp1 = mycolor;
		mycolor = RED + ((1-who) * 4);
		count = CheckBlitz(row, col);
		mycolor = temp1;
		if (count >= 1) begin
		    return(TRUE);
		end /* try to stop enemy blitz */

	    end /* try to stop an impending BLITZ of own color */

	end /* of no LOCK without the power */

    end /* of don't LOCK any color but your own */

    return(FALSE);	/* if not out yet, then no LOCK will be placed */

end /* of Check for Lock placement advisability */


/******************************************************************************
  This routine checks to see if a MOVE is desirable/possible.
 ******************************************************************************/
static BOOLEAN CheckMove(row, col)
    short row, col;
begin
    static short goodPads[8];
    short i,count, x,y, best = 0;

    for (i = 0; i < 8; i++) begin
	x = row + scanPad[i][0];
	y = col + scanPad[i][1];
	if (On_Board(x, y)) begin
	    targPad[i] = Color_Dist(board.grid[x][y], mycolor);
	    if (targPad[i] > best) best = targPad[i];
	end else begin
	    targPad[i] = -1;
	end /* of set value of target pad */	
    end /* of scan MOVE zone */

    if (best) begin
	for (i = count = 0; i < 8; i++) begin
	    if (targPad[i] >= best) begin
		goodPads[count++] = i;
	    end /* of compose list of best buys */
	end /* of find best targets */

	i = My_Random(0, count-1);

	targetRow = row + scanPad[goodPads[i]][0];
	targetCol = col + scanPad[goodPads[i]][1];

	return(TRUE);	/* found a spot to MOVE to */

    end else begin

	return(FALSE);	/* NO good spots for a MOVE */

    end /* are there any good locations */
end /* of Check Move */



/******************************************************************************
  This routine checks to see if a TELEPORT is possible and picks target.
 ******************************************************************************/
static BOOLEAN CheckTeleport(who, row, col)
    short row, col;
begin
    static BDTYPE score, best;
    short i, count, power, tcdist, crow,ccol, highest = 0;

    power = player[who].power;
    for (crow = MINROW; crow <= MAXROW; crow++) begin
	for (ccol = MINCOL; ccol <= MAXCOL; ccol++) begin
	    tcdist = Color_Dist(mycolor, board.grid[crow][ccol]);
	    if (((crow != row) OR (ccol != col)) AND (tcdist < power)) begin
		score.grid[crow][ccol] = PadValue(mycolor, crow, ccol);
		if (score.grid[crow][ccol] > highest) begin
		    highest = score.grid[crow][ccol];
		end /* of note highest score */
	    end else begin
		score.grid[crow][ccol] = 0;	/* bad pads get zero */
	    end /* don't check the origin platform */
	end /* of scan columns */
    end /* of scan rows */

    if (highest > 0) begin
	for (i = count = 0; i < 25; i++) begin
	    if (score.linear[i] >= highest) begin
		best.linear[count++] = i;
	    end /* of save only the good ones */
	end /* scan for the all pads of 'highest' TeleValue */

	i = My_Random(0, count - 1);
	targetCol = best.linear[i] MOD 5;
	targetRow = best.linear[i] / 5;
	return(TRUE);	/* Return a good Teleport Target */

    end else begin
	return(FALSE);	/* No Target found */
    end /* of was a place found? */
end /* of Check Teleport */



/******************************************************************************
  This routine selects the Computer Player's ACTION or SPELLS.
  I am using my more primitive (but quick) system here.
  'who' refers to the computer controlled player.
 ******************************************************************************/
static void SetStrategy(who, action, spell)
    short who, *action, *spell;
begin
    short *power, row,col, color, locked;

    power = &player[who].power;
    row = player[who].row;	col = player[who].col;
    color = board.grid[row][col];
    mycolor = (who * 4) + RED;
    cdist = Color_Dist(color, mycolor);

    *action = PASS;	*spell = NO_SPELL;

    do begin
     /* DO an UNLOCK? */
	if ((locked = CheckUnlock(who, row, col)) == 1) begin
	    *action = CAST;		*spell = UNLOCK;
	    break;
	end /* of consider UNLOCKing, if needed */

     /* DO a BLITZ? */
	if ((*power >= spellIgnite[BLITZ]) AND (color != mycolor) AND
	    ((short)Random() & 0xf) AND (!locked)) begin
	    if (CheckBlitz(row, col) >= 1) begin
		*action = CAST;		*spell = BLITZ;
		break;
	    end /* of do the BLITZ */
	end /* of pick BLITZ? */

     /* DO a TRANSMUTE? */
	if ((*power >= spellIgnite[TRANSMUTE]) AND ((short)Random() & 0x88)) begin
	    if (CheckTransmute(row, col) >= My_Random(3,5)) begin
		*action = CAST;		*spell = TRANSMUTE;
		break;
	    end /* of do the TRANSMUTE */
	end /* of pick TRANSMUTE? */

     /* DO a STOMP or a CONVERT? */
	if ((cdist) AND (!locked) AND ((short)Random() & 0xf)) begin
	    if ((cdist == 1) OR (*power == 1)) begin
		*action = STOMP;	/* STOMP if it is near own color */
	    end else begin
		*action = CAST;
		*spell = CONVERT;	/* else CONVERT to own color */
	    end /* of pick STOMP or CONVERT */
	    break;
	end /* of pick CONVERT? */

     /* LOCK the PAD? */
	if (CheckLock(who, row, col)) begin
	    *action = CAST;	*spell = LOCK;
	    break;
	end /* of set LOCK? */

     /* DO a MOVE? */
	if (CheckMove(row, col)) begin
	    *action = MOVE;
	    break;
	end /* of pick MOVE? */

     /* DO a TELEPORT? */
	if (CheckTeleport(who, row, col) AND ((!savePower) OR
	    ((savePower) AND ((short)Random() & 0x3)) )) begin
	    if ((targetRow != row) OR (targetCol != col)) begin
		*action = CAST;	    *spell = TELEPORT;
		break;
	    end /* of make sure it goes somewhere */
	end /* of pick TELEPORT? */
    end while (FALSE != FALSE);
end /* of Set Strategy */



/******************************************************************************
  This routine administrates the computer decision making process.
 ******************************************************************************/
void AI_SelectAction(who, action, spell)
    short who, *action, *spell;
begin
    static short dummy;

    SetStrategy(who, action, spell);

    Print_Line(1, WHITE, *action + GRAY, actions[*action]);
    Event_Timer(45, 1-who);
    Key_Options(&contGame, &dummy);

    if (*action == CAST) begin
	Print_Line(1, IR+who, RED+*spell, spells[*spell]);
    end /* of print action or spell selected */
    Key_Options(&contGame, &dummy);
end /* of AI Select Action */
