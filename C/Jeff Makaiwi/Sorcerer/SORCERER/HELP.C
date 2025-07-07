/* This file contains the routines to provide help for the players. */

#include "readable.h"	/* My Standard C Equates */
#include "sorcery.h"	/* Spectral Sorcery Standard Constants */
#include <osbind.h>	/* OS bindings */



/* External Variable References */
extern short gameCtrl[];	/* access the global game Control array */



/* External Function References */
/* from GRAPHICS.C */
extern void Flip_Screens();

/* from TEXTIO.C */
extern void Set_Font();

/* from UTILS.C */
extern void Wait_Stick(), Clear_Keys();

/* from DRAWING.S */
extern void Copy_Block(), Clear_Block();

/* from TB_TEXT.S */
extern void my_fcolor(), my_ftext();



/*****************************************************************************
 *   These routines are used to put masses of text on the screen for HELP.   *
 *****************************************************************************/

/*****************************************************************
 * This routine waits until a joystick button or key is pressed. *
 *****************************************************************/
void Wait_Button(who)
    short who;
begin
    Clear_Keys();
    while ((!Bconstat(2)) AND (!(Stick(gameCtrl[who]) & 0x8080)));
end /* of Wait Button */



/****************************************************************
 * This routine prints a help subject at the top of the screen. *
 ****************************************************************/
static void Print_Title(font, color1,color2, title)
    short font, color1, color2;
    char *title;
begin
    Set_Font(font);
    my_fcolor(color1, color2);
    my_ftext((20-(strlen(title)/2)), 0, title);
end /* of Print Help Title */



/**************************************************
 * This routine prints the text of a help screen. *
 **************************************************/
static void Print_Help(lines, colors, text)
    short lines, colors[][2];
    char *text[];
begin
    short i = 0, y = 5;

    while (i < lines) begin
	if (*text[i] == ' ') begin
	    my_fcolor(colors[0][0],colors[0][1]);
	end else begin
	    my_fcolor(colors[1][0],colors[1][1]);
	end /* of set correct colors */
	my_ftext(0, (y+=10), text[i++]);
    end /* of Print Text lines */
end /* of Print Help Text */



/************************************************************************
 *   This block of routines provides text description of the ACTIONS.   *
 ************************************************************************/
static void Pass_Help()
begin
    static short	colors[][2] =  {BLUE,IR, LT_VIO,RED};
    static char	*text[] = {"PURPOSE:",
			   "  Take no action for this round.",
			   "USAGE:",
			   "  Just select it and your phase of",
			   "  the current round is history.",
			   "COST:",
			   "  No cost, saves power actually.",
			   "CANCELLATION:",
			   "  You can't cancel this."};

    Print_Title(1, IR,GRAY, "PASS HELP");
    Print_Help(9, colors, text);
end /* of PASS action Help */


static void Move_Help()
begin
    static short	colors[][2] =  {WHITE,YELLOW, WHITE,UV};
    static char	*text[] = {"PURPOSE:",
			   "  To move the wizard to an adjacent",
			   "  pad and to change the pad's color.",
			   "USAGE:",
			   "  Joystick up = up and left,",
			   "           right = up and right.",
			   "  Pressing the stick button make the",
			   "  destination selection.  The pad you",
			   "  land on will then be changed one",
			   "  step closer to your color.",
			   "COST:",
			   "  1 point + 1 point if the pad color",
			   "  is changed.  If you don't have the",
			   "  extra power, then the color is not",
			   "  changed.",
			   "CANCELLATION:",
			   "  Press button while on the start pad."};

    Print_Title(1, YELLOW,WHITE, "MOVE HELP");
    Print_Help(17, colors, text);
end /* of MOVE action Help */


static void Cast_Help()
begin
    static short	colors[][2] =  {YELLOW,IR, UV,BLUE};
    static char	*text[] = {"PURPOSE:",
			   "  To allow you to select a spell.",
			   "USAGE:",
			   "  Select SPELL using joystick.",
			   "  UP and DOWN on the stick scrolls",
			   "  through the list of spells.",
			   "  Press the button to select a spell.",
			   "COST:",
			   "  Cost depends on the spell selected.",
			   "CANCELLATION:",
			   "  Select the NO SPELL item."};

    Print_Title(1, GREEN,BLUE, "CAST HELP");
    Print_Help(11, colors, text);
end /* of CAST action Help */


static void Stomp_Help()
begin
    static short colors[][2] =  {UV,GREEN, RED,YELLOW};
    static char	*text[] = {"PURPOSE:",
			   "  To change the color of the pad",
			   "  you are occupying.",
			   "USAGE:",
			   "  Your wizard will bounce on the",
			   "  pad it is on and then the color",
			   "  will change one level toward your",
			   "  end of the spectrum.  If the pad",
			   "  is already your color, then there",
			   "  will be no change.",
			   "COST:",
			   "  1 point if the pad color is changed.",
			   "CANCELLATION:",
			   "  You cannot cancel this ACTION."};

    Print_Title(1, YELLOW,GREEN, "STOMP HELP");
    Print_Help(14, colors, text);
end /* of STOMP action Help */


static void Help_Help()
begin
    static short colors[][2] =  {UV,VIOLET, RED,DK_RED};
    static char	*text[] = {"PURPOSE:",
			   "  To ask the computer to make your",
			   "  next move for you.",
			   "USAGE:",
			   "  Select this whenever you want the",
			   "  computer to figure out the next",
			   "  action you should take.  Then, just",
			   "  sit back and watch as while your",
			   "  wizard is moved by the computer.",
			   "  Control returns to you after 1 move.",
			   "COST:",
			   "  Depends on what the computer selects.",
			   "CANCELLATION:",
			   "  You cannot cancel this ACTION."};

    Print_Title(2, IR,RED, "HELP-ME HELP");
    Print_Help(14, colors, text);
end /* of HELP-ME Help */


static void Resign_Help()
begin
    static short colors[][2] =  {UV,BLUE, RED,BLUE};
    static char *text[] = {"PURPOSE:",
			   "  To resign the game to your",
			   "  opponent allowing a graceful",
			   "  end to a game that is hopeless.",
			   "CANCELLATION:",
			   "  You can't!"};

    Print_Title(1, RED,VIOLET, "RESIGN HELP");
    Print_Help(6, colors, text);
end /* of RESIGN Help */



/*********************************************************
 * This routine provides help for the specified ACTION . *
 *********************************************************/
void Action_Help(who, act)
    short who, act;
begin
    long log;

    log = (long)Logbase();
    Copy_Block(Physbase(), Logbase(), 4000);
    Clear_Block(Physbase(), 4000);
    Setscreen(Physbase(), -1L, -1);

    switch (act) begin
    case PASS:
	Pass_Help();	break;
    case MOVE:
	Move_Help();	break;
    case CAST:
	Cast_Help();	break;
    case STOMP:
	Stomp_Help();	break;
    case HELPACT:
	Help_Help();	break;
    case RESIGN:
	Resign_Help();
    end /* of action switch */

    Set_Font(1);
    my_fcolor(WHITE,GRAY);
    my_ftext(4,189, "Press Button or Key to Exit...");
    Flip_Screens();

    Wait_Stick(who);			/* Wait for null stick */
    Wait_Button(who);			/* Wait for the button press */
    
    Setscreen(log, -1L, -1);
    Flip_Screens();
    Copy_Block((long)Physbase()+25600, (long)Logbase()+25600, 800);
    Clear_Keys();
end /* of Action Help */



/***********************************************************************
 *   This block of routines provides text description of the SPELLS.   *
 ***********************************************************************/

static void NoSpell_Help()
begin
    static short colors[][2] = {RED,WHITE, RED,DK_RED};
    static char	*text[] = {"PURPOSE:",
			   "  To Abort Spell Selection.",
			   "EFFECT:",
			   "  Exits Spell Selector and returns to",
			   "  Action Selector."};

    Print_Title(3, UV,VIOLET, "NO SPELL");
    Print_Help(5, colors, text);
end /* of NO SPELL spell Help */


static void Convert_Help()
begin
    static short colors[][2] = {WHITE,BLUE, YELLOW,GRAY};
    static char	*text[] = {"PURPOSE:",
			   "  To Convert a Pad to your color.",
			   "EFFECT:",
			   "  Converts the Pad occupied by the",
			   "  Wizard to the wizard's color.  If",
			   "  the wizard does not have enough power",
			   "  then the Pad will be converted to a",
			   "  color as close to the proper end of",
			   "  the spectrum as possible.",
			   "IGNITION POWER:",
			   "  1 point.",
			   "COST:",
			   "  1 point per level of color change.",
			   "CANCELLATION:",
			   "  This spell cannot be cancelled."};

    Print_Title(1, UV,BLUE, "CONVERT SPELL");
    Print_Help(15, colors, text);
end /* of CONVERT spell Help */


static void Teleport_Help()
begin
    static short colors[][2] = {RED,BLUE, RED,RED};
    static char	*text[] = {"PURPOSE:",
			   "  To Teleport the wizard elsewhere.",
			   "EFFECT:",
			   "  Transports the wizard to the pad",
			   "  marked by the target pad.  The target",
			   "  pad is the multi-colored pad that you",
			   "  can move with the joystick.",
			   "IGNITION POWER:",
			   "  1 point.",
			   "COST:",
			   "  1 point minimum + 1 point for",
			   "  each color level of difference",
			   "  between your color and the target.",
			   "CANCELLATION:",
			   "  Teleport to the pad you are on."};


    Print_Title(2, RED,DK_RED, "TELEPORT SPELL");
    Print_Help(15, colors, text);
end /* of TELEPORT spell Help */


static void Blitz_Help()
begin
    static short colors[][2] = {UV,LT_VIO, YELLOW,GRAY};
    static char	*text[] = {"PURPOSE:",
			   "  To change all contacting pads of the",
			   "  same color to your own color.",
			   "EFFECT:",
			   "  Changes the pad you are on and all",
			   "  laterally contacting pads of the",
			   "  same color one level closer to your",
			   "  end of the spectrum.  Spell repeats",
			   "  until all eligible pads are converted",
			   "  to your color or your power is gone.",
			   "IGNITION POWER:",
			   "  16 points.",
			   "COST:",
			   "  1 point per color change per Pad.",
			   "CANCELLATION:",
			   "  This spell cannot be cancelled."};

    Print_Title(3, WHITE,UV, "BLITZ SPELL");
    Print_Help(16, colors, text);
end /* of BLITZ spell Help */


static void Transmute_Help()
begin
    static short colors[][2] = {WHITE,YELLOW, YELLOW,GRAY};
    static char	*text[] = {"PURPOSE:",
			   "  To change the nine pads adjacent to",
			   "  and including the pad you are on",
			   "  one color level closer to your color.",
			   "EFFECT:",
			   "  Change each pad in the target zone",
			   "  one level closer to your own.  Pads",
			   "  of your color are not affected.",
			   "IGNITION POWER:",
			   "  9 points.",
			   "COST:",
			   "  1 point per pad that is changed.",
			   "CANCELLATION:",
			   "  This spell cannot be cancelled."};

    Print_Title(1, YELLOW,GREEN, "TRANSMUTE SPELL");
    Print_Help(14, colors, text);
end /* of TRANSMUTE spell Help */


static void Lock_Help()
begin
    static short colors[][2] = {RED,UV, RED,LT_RED};
    static char	*text[] = {"PURPOSE:",
			   "  To LOCK a pad so that its color can't",
			   "  be changed by anyone until UNLOCKed.",
			   "EFFECT:",
			   "  Changes edge color of pads to your",
			   "  power color and prevents any changes",
			   "  in the pad's color.  Some spells will",
			   "  fail if cast on a LOCKed pad.",
			   "IGNITION POWER:",
			   "  1 point.",
			   "COST:",
			   "  1 to 5 points, depending on the color",
			   "  of the pad.  The cost is lower for",
			   "  colors close to your color.",
			   "CANCELLATION:",
			   "  This spell cannot be cancelled."};

    Print_Title(2, UV,DK_VIO, "LOCK SPELL");
    Print_Help(16, colors, text);
end /* of LOCK spell Help */


static void Unlock_Help()
begin
    static short colors[][2] = {YELLOW,DK_GRAY, GRAY,DK_GRAY};
    static char	*text[] = {"PURPOSE:",
			   "  To remove a LOCK from a pad.",
			   "EFFECT:",
			   "  Removes a lock from the pad you are",
			   "  on and allows you to take another",
			   "  Action or Cast another spell.",
			   "IGNITION POWER:",
			   "  1 point.",
			   "COST:",
			   "  1 to 8 points, depending on the",
			   "  color of the pad and the number",
			   "  of your pads on the board.  Colors",
			   "  closer to your own cost less.",
			   "CANCELLATION:",
			   "  This spell cannot be cancelled."};

    Print_Title(3, WHITE,YELLOW, "UNLOCK SPELL");
    Print_Help(15, colors, text);
end /* of UNLOCK spell Help */


static void Release_Help()
begin
    static short colors[][2] = {WHITE,WHITE, UV,IR};
    static char	*text[] = {"PURPOSE:",
			   "  To remove all of your LOCKs at once.",
			   "  This spell is here in case you find",
			   "  that your LOCKs are draining too much",
			   "  of your power.",
			   "EFFECT:",
			   "  Removes all of your LOCKs from any",
			   "  and all pads on the board.  No effect",
			   "  on your opponent's LOCKs.",
			   "IGNITION POWER:",
			   "  1 point.",
			   "COST:",
			   "  1 point.",
			   "CANCELLATION:",
			   "  This spell cannot be cancelled."};

    Print_Title(1, WHITE,UV, "RELEASE SPELL");
    Print_Help(15, colors, text);
end /* of RELEASE spell Help */



/*******************************************************
 * This routine provides help for the specified SPELL. *
 *******************************************************/
void Spell_Help(who, spell)
    short who, spell;
begin
    long log;

    log = (long)Logbase();
    Copy_Block(Physbase(), log, 4000);
    Setscreen(Physbase(), -1L, -1);
    Clear_Block(Physbase(), 4000);

    switch (spell) begin
    case NO_SPELL:
	NoSpell_Help();		break;
    case CONVERT:
	Convert_Help();		break;
    case TELEPORT:
	Teleport_Help();	break;
    case BLITZ:
	Blitz_Help();		break;
    case TRANSMUTE:
	Transmute_Help();	break;
    case LOCK:
	Lock_Help();		break;
    case UNLOCK:
	Unlock_Help();		break;
    case RELEASE:
	Release_Help();
    end /* of spell switch */

    Set_Font(1);
    my_fcolor(WHITE,GRAY);
    my_ftext(4,189, "Press Button or Key to Exit...");
    Flip_Screens();

    Wait_Stick(who);			/* Wait for null stick */
    Wait_Button(who);			/* wait for a button press */
    
    Setscreen(log, -1L, -1);
    Flip_Screens();
    Copy_Block((long)Physbase()+25600, (long)Logbase()+25600, 800);
    Clear_Keys();
end /* of Action Help */
