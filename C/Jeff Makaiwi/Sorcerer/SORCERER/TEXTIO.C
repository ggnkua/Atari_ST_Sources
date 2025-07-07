/* This file contains routines that attack the text window. */

#include "readable.h"
#include "sorcery.h"
#include <osbind.h>

extern char *colorName[], font1[], font2[];
extern BDTYPE board;


/* External Function References */
/* from UTILS.C */
extern void Ding(), Event_Timer();

/* from DRAWING.S */
extern void Copy_Block(), Clear_Block();

/* from TB_TEXT.S */
extern void my_ftext(), my_fcolor(), my_ffont(), my_fmode();



/***********************************************************
 *   This section contains some routines to interface with *
 *   the custom text output routines.                      *
 ***********************************************************/

/*****************************************************************************
  This routine set the font draw mode.
  0 = REPLACE, 1 = TRANSPARENT.
  No other modes at this time.
 *****************************************************************************/
void Set_TextMode(mode)
    short mode;
begin
    my_fmode(mode);		/* Set draw mode (0 or 1) */
end /* of Set Text Draw Mode */



/******************************************************************************
  This routine sets the font (from the 2 available) for 'my_ftext'.
  It calls the low-level 'my_ffont' in the TB_TEXT.S library.
  Actually, I have three fonts, but only two were linked to this program
 ******************************************************************************/
void Set_Font(which)
    short which;	/* Which font to use (1 or 2 right now) */
begin
    switch (which) begin
    case 1:
	my_ffont(font1);	/* use fancy text */
	break;
    default:
	my_ffont(font2);	/* use techno text */
    end /* of switch */
end /* of Set Font */



/*****************************************************************
 *   This section contains routine that work on the Text Window. *
 *****************************************************************/

/******************************************************************************
  This routine clears the text window.
 ******************************************************************************/
void Clear_Window()
begin
    Clear_Block(Logbase() + 25600L, 800); 
    Clear_Block(Physbase() + 25600L, 800);
end /* of Clear Window */


/******************************************************************************
  This routine clears a single line in the text window.
 ******************************************************************************/
void Clear_Line(line)
    short line;
begin
    register short size = 200, temp = 25600;

    temp += (line * 1600);
    if (line >= 3) size--;
    Clear_Block(Logbase()  + temp, size);    
    Clear_Block(Physbase() + temp, size);
end /* of Clear Line */



/******************************************************************************
  This routine clears and prints a text string on a line of the window.
 ******************************************************************************/
void Print_Line(line, color1, color2, msg)
    short line, color1, color2;
    char *msg;
begin
    long temp;

    line = 10 * InRange(line, 0, 3);
    temp = 25600L + (line * 160);

    my_fcolor(color1, color2);
    Clear_Block(Logbase() + temp, 200);
    my_ftext((20 - (strlen(msg) /2)), 160 + line, msg);
    Copy_Block(Logbase() + temp, Physbase() + temp, 200);
end /* of Print Line */



/******************************************************************************
  This routine print the color of a platform on line 1 of the text window.
 ******************************************************************************/
void Print_Color(row, col)
    short row, col;
begin
    short color;

    color = board.grid[row][col] & 0xff;
    Print_Line(2, color, color, colorName[color-1]);
end /* of Print Color */



/******************************************************************************
  This routine prints one of the canned messages on the screen.
 ******************************************************************************/
void Print_Message(who, line, color1, color2, octave, note, jikan, msg)
    short who, line, color1, color2, octave, note, jikan;
    char *msg;
begin
    Print_Line(line, color1, color2, msg);
    if (octave >= 0) begin
	Ding(octave, note);
    end /* Bell only if requested */
    Event_Timer(jikan, who);
end /* of Print Message */
