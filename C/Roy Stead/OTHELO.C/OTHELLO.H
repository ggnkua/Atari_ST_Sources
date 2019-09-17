/*******************************************************************************

Program: Othello
   Desc: A program to play Othello on the AtarI ST
 Author: Roy Stead
Created: 19/2/93

   File: othello.h
   Desc: Header file for the Othello package

  Notes: This code is written to accompany the _C'ing Straight_ C Tutorial
	 series, which started in the April 1993 issue of _Atari ST User_
	 magazine.

 Notes2: A separate version of this header file, OTHELLO.HS, is provided for
	 use with the Hisoft C Interpreter. That file should be renamed to
	 OTHELLO.H and placed in the same folder as your Hisoft C program.

Updates:

Date		By	Comments

 19/2/93	RS	Changed BOARD struct definition to use a single offset
				into block pointed to by (char *)board field
				instead of separate x and y fields

*******************************************************************************/

#ifndef OTHELLO_H
#define OTHELLO_H

#include <stdio.h>		/* STandarD Input and Output Header	*/


/*******************************************************************************
Portability Macros - this code fascilitates the transfer of code between
different compilers, possibly even on different machines.
*******************************************************************************/

#ifdef SOZOBON
/* Sozobon C compiler-specific redefinitions.
 */
#define const			/* Sozobon doesn't understand const	*/

#define malloc		lalloc	/* Sozobon's malloc uses int as arg...	*/
				/* ...Substitute lalloc (uses a long)	*/
#endif /* SOZOBON */


/*******************************************************************************
			Constant Definitions
*******************************************************************************/

#define ESC		0x1B	/* ESCape code				*/
#define SPC		0x20	/* ASCII code for a space character	*/


/*******************************************************************************
	The Defaults: Default values of major parameters of this program
*******************************************************************************/

/* The default names used for the two Players.
 */
#define PLAY0_NAME	"Human"
#define PLAY1_NAME	"Mini Max"

/* The default skill levels for the Players.
 * A value of (-1) indicates a human Player;
 * zero, or positive values, indicate computer Players of increasing skill.
 *
 * Notice, by the way, the brackets around the (-1). Always used brackets in
 * these circumstances, to avoid ambiguity when the macro is expanded.
 */
#define PLAY0_LEVEL	(-1)
#define PLAY1_LEVEL	3

/* The characters used for the individual pieces and blanks squares.
 */
#define PLAY0_PIECE	'O'		/* Player zero's piece		*/
#define PLAY1_PIECE	'X'		/* Player one's piece		*/
#define EMPTY		'.'		/* Empty square			*/


/* The command keys used in this program.
 */
#define QUIT_KEY	'Q'	/* 'q' or 'Q' key Quits the program	*/
#define RESTART_KEY	'R'	/* 'r' or 'R' key Restarts program	*/
#define SKIPGO_KEY	ESC	/* ESC key is used to skip a turn	*/


#define BRD_W		8	/* Width of Othello Board  (1 <= BRD_W <= 36 */
#define BRD_H		8	/* Height of Othello Board (1 <= BRD_H <= 15)*/

/* BRD_SIZ holds the number of squares in our Othello Board.
 * Since we define this in terms of BRD_W and BRD_H, we could modify either
 * or both of those values and not have to change the definition of BRD_SIZ 
 */
#define BRD_SIZ		(BRD_W * BRD_H)


/*******************************************************************************
			typedef'initions of struct'ures
*******************************************************************************/

/* Define a structure to hold information about the Players, PLAYER.
 */
typedef struct plyr	{
			char	piece;		/* Player's piece.	    */
			char	*name;		/* Player's name.	    */
			int	score;		/* Player's score.	    */
			int	level;		/* Skill level (-1 is human)*/
			struct plyr *opponent;	/* Pointer to opponent.	    */
			} PLAYER;


/* Define the Othello Board descriptor structure, BOARD.
 *
 * A move is specified by loading field (int)offset of a structure of
 * this type with an offset into the (char *)board field which specifies the
 * square to move to, with the (struct plyr *)player field holding the
 * description of the Player who is making the move (held in a PLAYER block,
 * as defined above) and the (char *)board field pointing to a 64-byte memory
 * block in which is stored a description of the Othello Board on which the
 * move is to be made.
 *
 * The (BOARD *)nxtbrd field is provided for linked list construction.
 */
typedef struct oth_brd	{
			char *board;		/* The Othello Board.	    */
			struct plyr *player;	/* The current Player.	    */
			int offset;		/* Offset to current square.*/
			int minimax;		/* Minimax value of Board.  */
			struct oth_brd *nxtbrd;	/* Pointer to next Board.   */
			}
			BOARD;


/*******************************************************************************
		Macros: Macros used by the Othello program
*******************************************************************************/

/* The At_???? macros each take a Board Descriptor as their argument.
 * Their value is TRUE or FALSE, depending on whether the square described by
 * the (BOARD *)brd descriptor is in the topmost row, bottommost row,
 * leftmost column or rightmost column of the Board respectively.
 */
#define At_top( brd )		( (brd)->offset < BRD_W )
#define At_bottom( brd )	( ((brd)->offset + BRD_W) >= BRD_SIZ )
#define At_left( brd )		( ((brd)->offset % BRD_W) == 0 )
#define At_right( brd )		( ((brd)->offset % BRD_W) == (BRD_W - 1) )


#endif /* OTHELLO_H */

/* End file OTHELLO.H	*/
