/******************************************************************************
  This file contains the code to control the progress of the game.
  Each routine begins with a comment header describing its purpose and listing
   its parent and child routines.  The following notations have been added
   to the function names to indicate the type:
	(a) = custom assembly language routine,
	(c) = custom C routine,
	(s) = standard C library routine,
	(m) = macro.
   Furthermore, 'c' routines will be labelled with and additional character:
	(s) = static	(local to this module),
	(e) = external	(imported from another module),
	(g) = global	(local to this module but externally visible).
 ******************************************************************************/

#include "readable.h"	/* My C Macros for Readability */
#include "sorcery.h"	/* Spectral Sorcery Standard Constants */
#include <osbind.h>

/* External Variable references */
extern PLINFO player[];
extern BDTYPE board;
extern char *actions[], *spells[], *playerName[];
extern short  contGame, gameCtrl[], playerOrder[], bmode;
extern short  imageBuff1[], imageBuff2[], maskBuff1[], maskBuff2[];
extern short  teleBuff[][600], tmaskBuff[][400];
extern long mainScreen, screenBuff, background[];


/* Global Variables */
short scanPad[][2] = {0,-1, 0,1, -1,0, 1,0, -1,-1, 1,-1, 1,1, -1,1, 0,0};
short targetRow,
    targetCol,		/* Pad locs for Computer Decisions */
    contGame,		/* Game abort flag */
    savePower;		/* Flag TRUE if power can be save from turn to turn */



/* Local Global Variables */
static short helpflag;		/* place to store help flag */
static short surrender;		/* = player id if a RESIGN is selected */


/* External Function References */
/* from ACTIONS.C */
extern short Do_Move(), Do_Stomp(), Comp_Move(), Do_Cast();

/* from BRAINS.C */
extern void AI_SelectAction();

/* from ENDGAME.C */
extern void Beam_Down();

/* from GRAPHICS.C */
extern void Update_Screen(), Draw_Wizard(), Flip_Screens(), Draw_Power();
extern void Prep_Wizard();

/* from HELP.C */
extern void Action_Help(), Spell_Help();

/* from OPTIONS.C */
extern short Set_Options();

/* from SETUP.C */
extern void Init_Board(), Draw_Board(), Draw_Spectrum();

/* from TEXTIO.C */
extern void Print_Line(), Print_Message(), Clear_Window(), Clear_Line();
extern void Set_Font(), Set_TextMode();

/* from TITLE.C */
extern void Show_Credits();

/* from UTILS.C */
extern void Copy_Block(), Delay(), Clear_Keys(), Event_Timer(), Ding(),
	    Key_Options(), Set_TextMode(), Wiz_Pos(), Sound_Off();

/* from STICKS.S */
extern void Init_Sticks(), Kill_Sticks();
extern short Stick();



/***********************************************************************
 *   This section contains some routines that wouldn't function when   *
 *   they were in a different module.  Rather than waste time figuring *
 *   out why, I just plunked them in here.                             *
 ***********************************************************************/

/**********************************************************************
   This routine returns a joystick value.  It reads only the vertical
   stick movements (up and down) and the button.
   Called by:	SelectSpell(cs).
   Calls to:	Stick(a), Key_Options(ce).
 **********************************************************************/
static short VertStick(who)
    short who;		/* which player's control to interrogate */
begin
    short stickID,	/* place to store stick ID number */
	dir = 0;	/* result of joystick activity */

    stickID = gameCtrl[who];		/* save joystick id for faster ref */
    while ((!dir) AND (contGame)) begin
	dir = Stick(stickID) & 0x83;	/* get button or up/down */
        Key_Options(&contGame, &helpflag);	/* check for HELP/QUIT */
	if (helpflag) begin
	    dir |= 0x10;		/* return HELP request */
	end /* of set part b5 of 'dir' if helpflag set */
    end /* of while */
    return(dir);			/* return player action */
end /* of Vertical Stick read */


/*****************************************************************************
  This routine polls the specified user's joystick and makes adjustments
  to the SPELL selection menu as appropriate.  The joystick button signals
  a selection (and exits the routine).  The HELP button triggers a help
  screen call.
  Called by:	SelectAction(cs).
  Calls to:	Print_Line(ce), Wait_Stick(ce), VertStick(cs), Spell_Help(ce),
		Ding(ce).
 *****************************************************************************/
static short SelectSpell(who)
    short who;		/* which player is selecting the spell */
begin
    short spell=1,	  /* which spell was selected */
	  select = FALSE, /* flag TRUE if selection made (= button pressed) */
	  dir;		  /* joystick or HELP key activity */

    Print_Line(1, IR+who, 1+RED, spells[1]);	/* CONVERT spell is default */
    Wait_Stick(who);			/* wait for null stick */
    do begin
        dir = VertStick(who);		/* get/wait-for player commands */
	if (contGame) begin
	    if (dir & 0x10) begin	/* HELP selected */
		Spell_Help(who, spell);	/* provide help for selected SPELL */
		helpflag = FALSE;	/* clear helpflag */

	    end else if (dir & 1) begin
		spell++;	spell MOD= MAXSPELL;	/* next spell in list */

	    end else if (dir & 2) begin
		if ((--spell) < 0) begin
		    spell = MAXSPELL - 1;	/* previous spell in list */
		end /* of fix underflow */

	    end else begin
		select = TRUE;			/* button pressed */
	    end /* of take correct action */

	    Print_Line(1, IR+who, RED+spell, spells[spell]);	/* new spell */
	    Ding(3, spell);					/* bell */
	    Wait_Stick(who);	/* wait for null stick to avoid fast scroll */
	end /* of select only if no abort */

    end while ((!select) AND (contGame));  /* until SELECT or GAME ABORT */
    return(spell);		/* return spell selected */
end /* of Select Spell */



/******************************************************************************
  This routine allows the player to use a joystick to select an action.
  It polls the appropriate stick and makes changes in the ACTION menu.  If
  the button is pressed, then the current ACTION is selected.  If the HELP
  button is pressed, an appropriate Help screen is displayed.
  Called by:	DoTurn(cs).
  Calls to:	Print_Line(ce), Wait_Stick(ce), VertStick(cs), Action_Help(ce),
		Ding(ce), SelectSpell(cs), Clear_Line(ce), AI_SelectAction(ce).
 ******************************************************************************/
static void SelectAction(who, action, spell, helpme)
    short who,		/* who is making the selection */
	  *action,	/* return ACTION selected through this */
	  *spell;	/* return SPELL selected through this */
    BOOLEAN *helpme;	/* help flag for the HELP ME action */
begin
    short act=1,	  /* which ACTION was selected, default to MOVE */
	  spl,		  /* which SPELL was selected */
	  dir;		  /* player controller activity */
    BOOLEAN select=FALSE; /* flag TRUE when a selection is made */

    *helpme = helpflag = FALSE;	/* clear help request flags */
    Print_Line(1, WHITE, 1+GRAY, actions[1]);	/* print default action, MOVE */
    Wait_Stick(who);		/* wait for null stick to avoid bouncing */
    do begin
        dir = VertStick(who);	/* get the player's command */
	if (contGame) begin
	    if (dir & 0x10) begin	/* a INFO-HELP request was made */
		Action_Help(who, act);	/* provide help on ACTION */
		helpflag = FALSE;	/* clear help flag */

	    end else if (dir & 1) begin
		act++;		act MOD= MAXACTION;  /* next ACTION in list */

	    end else if (dir & 2) begin
		if ((--act) < 0) begin
		    act = MAXACTION - 1;	/* previous ACTION in list */
		end /* fix underflow */

	    end else begin
		select = TRUE;			/* select the current ACTION */
	    end /* of switch */

	    Ding(4, act);			/* bell */
	    Print_Line(1, WHITE, act+GRAY, actions[act]); /* print new ACTION */
	    Wait_Stick(who);	/* wait for null stick to avoid fast scroll */
	end /* of select only if no abort */

	if (select) begin
	    if (act == CAST) begin	/* CAST was selected */
		spl = SelectSpell(who);	/* so go to SPELL selection routine */
		if ((!spl) AND (contGame)) begin
		    Clear_Line(2);    act = 1;	/* back to ACTION selector */
		    Ding(4, act);
		    Print_Line(1, WHITE, act+GRAY, actions[act]);
		    select = 0;		/* no spell selection */
		end /* of NO SPELL */
	    end else if (act == HELPACT) begin	/* HELP-ME was selected */
		AI_SelectAction(who, action, spell);	/* automated select */
		act = *action;		spl = *spell;
		*helpme = TRUE;
	    end /* of non-terminal action selection */
	end /* of Selected Something */

    end while ((!select) AND (contGame));  /* until button or abort */
    *action = act;	*spell = spl;	   /* return selected ACTION/SPELL */
end /* of Select Action */


/******************************************************************************
  This routine administrates the interactions of a single turn.  It handles
  asking for user commands and calling the routines that make decisions for
  the computer.
  Called by:	Game_Loop(cg).
  Calls to:	Update_Screen(ce), Key_Options(ce), Clear_Window(ce),
		Print_Line(ce), AI_SelectAction(ce), SelectAction(cs), 
		Comp_Move(ce), Do_Move(ce), Do_Cast(ce), Do_Stomp(ce),
		Delay(ce), Clear_Line(ce), Event_Timer(ce), Print_Message(ce).
 ******************************************************************************/
static short DoTurn()
begin
    static char *msg1 = "You Have No More Power!";
    static char *msg2 = "The Turn is Over";
    short who;		/* The player who is currently active (RED or VIOLET) */
    short phase;	/* Which player (0 or 1) is active at the moment */
    short action;	/* Which ACTION to execute */
    short spell;	/* Which SPELL to cast */
    short passflag;	/* Flag to indicate that both players have PASSed */
    short actStat;	/* Flag, 0=give the current player another ACTION,
			   1=go to next player */
    BOOLEAN helpme;	/* set if use picked HELP ME action */

    Update_Screen(0,0, -1,-1, 0);	/* Make sure everything is okay */

    do begin
	phase = passflag = 0;
	Key_Options(&contGame, &helpflag);
	do begin
	    Clear_Window();
	    who = playerOrder[phase];
	    Print_Line(0, (who*4)+RED, LT_RED-(who*2) , playerName[who]);
	    Ding(3, who);	actStat = 1;

	    if ((contGame) AND (player[who].power > 0)) begin
		if (player[who].comp) begin
		    AI_SelectAction(who, &action, &spell);
		end else begin
		    SelectAction(who, &action, &spell, &helpme);
		end /* of action determination */

		if (contGame) begin
		    switch (action) begin
			case PASS:
			    passflag++;	/* two of these in a round */
			    break;	/* will end the turn */
			case MOVE:
			    if ((player[who].comp) OR (helpme)) begin
				actStat = Comp_Move(who, targetRow, targetCol);
			    end else begin
				actStat = Do_Move(who);
			    end /* of Human or Computer MOVE */
			    break;
			case CAST:
			    actStat = Do_Cast(who, spell, helpme);
			    break;
			case STOMP:
			    actStat = Do_Stomp(who);
			    break;
			case RESIGN:
			    return((who*4)+RED);  /* return RESIGN status */
		    end /* of Execute Actions phase */

		end /* of Execute Action, if no game abort */
		Delay(3);

	    end else if (contGame) begin
		passflag++;
		Clear_Line(2);
		Print_Line(1, IR+who, DK_VIO-(who*2), msg1);
		Event_Timer(120, who);
	    end /* of power check */

	    phase += actStat;	/* Next player, or not */
 
	end while ((contGame) AND (phase < 2) AND (passflag < 2));

    end while ((contGame) AND (passflag < 2) AND 
		((player[REDPLAYER].power + player[VIOPLAYER].power) > 0));

    Clear_Window();
    if (contGame) begin
	Print_Message(-1, 1, IR,UV, 1,10, 120, msg2);
    end /* of End of the Game */
    return(-1);
end /* of Do Turn */


/******************************************************************************
  This routine counts the number of pads of each color.  If the board is
  made up of nothing but one color of pads, then the game is over.  A RED
  board results in a REDPLAYER victory.  A VIOLET board means the VIOPLAYER
  has won.  Any other color board is a Draw.  If the board is not homogeneous
  and a user abort (via UNDO) was not triggered, power is allocated to each
  player based on the number of pads on the board.  Each pad produces 1/2 a
  power point.  In addition, players receive 16 power points as a base
  allotment.  As an option, 1/2 of a players power from the previous turn may
  be saved for use in the next turn.  The maximum amount of power is 99 points.
  Called by:	DoTurn(cs).
  Calls to:	Update_Screen(ce).
 ******************************************************************************/
static short CheckWinner()
begin
    short	*redPower, *vioPower;
    register short i,		/* fast loop counter */
		   temp;	/* fast temporary register */
    static short cnts[6],	/* # of pads of each color */
		 locks[2];	/* # of locks for each player */

    redPower = &player[REDPLAYER].power;
    vioPower = &player[VIOPLAYER].power;

    player[REDPLAYER].advantage = player[VIOPLAYER].advantage = 0;

    if (!contGame) begin
	return(-1);		/* a draw, because of an UNDO keypress */
    end else begin
	locks[0] = locks[1] = 0;  /* assume there are no LOCKs */
	for (i = 0; i < 6; cnts[i++] = 0);
	for (i = 0; i < 25; i++) begin
	    temp = board.linear[i];	/* get pad color and LOCK status */
	    cnts[(temp & 0xff)]++;	/* increment base only on color */
	    if (temp & 0x0100) begin
		locks[REDPLAYER]++;	/* found a RED LOCK */
	    end else if (temp & 0x0200) begin
		locks[VIOPLAYER]++;	/* found a VIOLET LOCK */
	    end /* of count locks */
	end /* of scan board */

	if (cnts[RED] == 25) begin
	    return(RED);		/* RED Won */
	end else if (cnts[VIOLET] == 25) begin
	    return(VIOLET);		/* VIOLET Won */
	end else if ((cnts[YELLOW] == 25) OR 
		     (cnts[GREEN] == 25)  OR
		     (cnts[BLUE] == 25)) begin
	    return(-1);			/* The game is a draw */
	end else begin
	 /* Not done yet, so reset power levels */
	    if (!savePower) begin
		*redPower = *vioPower = 0;
	    end /* of set start power level for this turn */

	    *redPower += (16 + cnts[RED] - locks[REDPLAYER]);
	    *vioPower += (16 + cnts[VIOLET] - locks[VIOPLAYER]);

	    if (*redPower < 1) begin
		*redPower = 1;
	    end else if (*redPower > 99) begin
		*redPower = 99;
	    end /* of make sure RED power is in [1,99] */

	    if (*vioPower < 1) begin
		*vioPower = 1;
	    end else if (*vioPower > 99) begin
		*vioPower = 99;
	    end /* of make sure VIOLET power is in [1,99] */
	
            if (cnts[RED] > cnts[VIOLET]) begin
		player[REDPLAYER].advantage = cnts[RED] - cnts[VIOLET];
	    end else if (cnts[RED] < cnts[VIOLET]) begin
		player[VIOPLAYER].advantage = cnts[VIOLET] - cnts[RED];
	    end /* of set ADVANTAGE */

	    Update_Screen(0, 0, -1, -1, 4);
	    return(0);
	end /* of do counting */
    end /* of always a draw if the game was aborted */
end /* of Check board for Winner */



/******************************************************************************
  This routine announces winner and does the endgame animation.  Both wizards
  beam down to the green pad in the spectrum row.  Then, the loser raise its
  staff in salute.  The winner nods.  In a draw, both wizards raise their
  staves in salute.  Then they both teleport to their respective pads at
  either end of the spectrum row.  The actual animation is handled by
  the Beam_Down function located in the 'endgame.c' module.
  Called by:	DoTurn(cs).
  Calls to:	Clear_Window(ce), Clear_Keys(ce), Print_Line(ce), Delay(ce),
		Beam_Down(ce), Event_Timer(ce).
 ******************************************************************************/
static void EndGame(winner)
    short winner;
begin
    static char *adraw = "The Game is a Draw!";
    static char *redwin = "Red is Victorious!";
    static char *violetwin = "Violet is the Winner!";
    static char *redResign = "Red has Resigned!";
    static char *vioResign = "Violet has Resigned!";

    Clear_Window();
    Clear_Keys();
    switch (winner) begin
	case (RED|0x80):
	    Print_Line(1, IR,RED, redResign);		Delay(3);
	    Beam_Down(-1);
	    break;
	case (VIOLET|0x80):
	    Print_Line(1, UV,VIOLET, vioResign);
	    Beam_Down(-1);				Delay(3);
	    break;
	case RED:
	    Print_Line(1, RED, IR, redwin);		Delay(3);
	    Beam_Down(REDPLAYER);
	    break;
	case VIOLET:
	    Print_Line(1, VIOLET, UV, violetwin);	Delay(3);
	    Beam_Down(VIOPLAYER);
	    break;
	default:
	    Print_Line(1, GRAY, DK_GRAY, adraw);	Delay(3);
	    Beam_Down(-1);
    end /* of announce result of game switch */
    Event_Timer(180, 2);
end /* of End Game */



/**************************************************************************
  This routine is the main game control loop.  Calls all sorts of things
  that make the game what it is.  It turns of the keyboard repeat feature,
  activates the joysticks (shutting the mouse off in the process), shows
  my title/credit screen, sets the game options, and runs the game.
  Called by:	main(ce).
  Calls to:	Kbrate(m), Init_Sticks(a), Roll_Credits(ce), Set_Font(ce),
		Set_TextMode(ce), Set_Options(ce), Init_Game(ce),
		DoTurn(cs), CheckWinner(cs), Endgame(cs), Clear_Block(a),
		Kill_Sticks(a).
 **************************************************************************/
void Game_Loop()
begin
    static short old_rate,
	         old_delay;	/* old keyboard repeat rates */
    short winner;		/* winner code */
    BOOLEAN quit;		/* UNDO game abort from Set_Options */

    old_rate = Kbrate(0,0);	/* Don't want any keyboard repeats */
    old_delay = (old_rate RSH 8) & 0xff;
    old_rate &= 0xff;		/* so shut them off */

    Init_Sticks();		/* activate joysticks and kill mouse */

    gameCtrl[REDPLAYER] = 0;	/* Set default play options */
    gameCtrl[VIOPLAYER] = 1;
    gameCtrl[2] = -1;
    bmode = STNDRD_CONFIG;	/* Standard Board Config */
    playerOrder[0] = REDPLAYER;	/* Red first */
    playerOrder[1] = VIOPLAYER;	/* Violet second */
    savePower = FALSE;		/* Don't save unused power */

    do begin
	Roll_Credits();		/* tell people who wrote this */
	Set_Font(1);		/* default FONT style */
	Set_TextMode(0);	/* my_ftext in REPLACE mode */
	contGame = TRUE;
	quit = Set_Options();	/* ask user to set the game options */

	if (!quit) begin
	    Init_Game();	/* setup for a new game */
	    do begin
		/* Do one turn */
		if ((winner = DoTurn()) < 0) begin
		    winner = CheckWinner();	/* did someone win? */
		end else begin
		    winner |= 0x80;
		end /* set winner to lose-thru-resignation */
	    end while ((contGame) AND (!winner));

	    EndGame(winner);	/* game over, so do the animation for it */

	end /* of not quit */

    end while (!quit);

    Sound_Off();
    Clear_Block(mainScreen, 4000); /* clear the screen */
    Kill_Sticks();		/* Terminate sticks and give CPR to mouse */
    Kbrate(old_rate, old_delay);/* keyboard repeat restored */
end /* of Game Loop */
