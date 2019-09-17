/*******************************************************************************

Program: Othello
   Desc: A program to play Othello on the AtarI ST
 Author: Roy Stead
Created: 19/2/93

   File: human.c
   Desc: Human player handling routines.

  Notes: This code is written to accompany the _C'ing Straight_ C Tutorial
	 series, which started in the April 1993 issue of _Atari ST User_
	 magazine.

Updates:

Date		By	Comments

*******************************************************************************/

#include "othello.h"		/* OTHELLO program definitions.		*/

extern	void	setup_board(), bsshowtext(), pause();
extern	void	showchar(), moveleft();
extern	int	make_move();
extern	char	get_key();

extern	int	end_othello;


/*******************************************************************************
do_human()	-	Handle a single turn by a human Player.

			Given the state of the Board in the structure pointed
			to by (BOARD *)brd, this function gets commands from
			the user until a valid move or command key is entered.

			Commands are executed, and moves are checked for
			legality, and executed if legal. Illegal moves generate
			a message and a prompt for another move.
*******************************************************************************/

extern void do_human ( brd )
register BOARD *brd;		/* Pointer to Board Descriptor structure*/
{
register int flipped;		/* Number of pieces flipped by move.	*/
int move_made;			/* "User made their move?" flag.	*/
int len;			/* Length of string in (char)outstr[]	*/
char outstr[80];		/* Used to store output text.		*/
int get_move();			/* Gets a move from the Player.		*/


do	{
	/* Read in a move from the  (human)Player.
	 * The move entered is placed in the 'x' and 'y' fields of the
	 * (BOARD *)brd structure passed to the function.
	 *
	 * Note: If a command key was pressed, get_move() now returns TRUE.
	 */
	move_made = get_move ( brd );

	if ( !move_made )
		{
		flipped = make_move ( brd );

		if ( flipped > 0 )	/* Do move if legal	*/
			{
			/* Update score.
			 */
			brd->player->score += flipped + 1;
			brd->player->opponent->score -= flipped;

			/* Switch to next Player if the move given was legal.
			 */
			brd->player = brd->player->opponent;

			move_made = TRUE;	/* Signal command done	*/
			}
		else
			{
			/* Move was illegal, so try again.
			 */
			len = sprintf ( &outstr[0], "| Illegal Move" );

			pause ( &outstr[0] );	/* Show text and pause	*/


			moveleft ( 2 );
			bsshowtext ( "  " );		/* Erase move	*/
			};

		};			/* End if (!move_made)		*/
	}
	while ( !move_made );
};


/*******************************************************************************
get_move()		-	Get a move from the Player.

				Reads in two characters from the Player,
				and translates them into coordinates in the
				Othello Board. Those coordinates are then
				placed into the 'x' and 'y' fields of the
				Board descriptor pointed to by the passed-in
				(BOARD *)brd structure.

				Returns TRUE if a command was typed, FALSE
				if a move was entered.

		Exercise:	Above certain values of BRD_W or BRD_H this
				function will have some problems. Can you work
				out what those values are, and why they cause
				problems? How could you cure this? (hint: the
				values are different for BRD_W and BRD_H)
*******************************************************************************/

static int get_move ( brd )
register BOARD *brd;		/* Pointer to Othello Board descriptor	*/
{
register char c;		/* The character typed by the Player.	*/


/* We first of all obtain a single character from the Player,
 * repeating this as many times as is necessary before we get a
 * valid one.
 */
do	{
	c = get_key();

	/* Note that valid characters are a command key or a row indicator.
	 */
	}
	while ( !((c >= 'A' && c <= ('A' + BRD_H)) ||
		c == QUIT_KEY || c == RESTART_KEY || c == SKIPGO_KEY) );


brd->offset = (c - 'A') * BRD_W;

if ( c >= 'A' && c <= 'Z' )	/* Echo character to the screen		*/
	showchar ( c );


/* We only bother to obtain the second character from the user if the first
 * was a coordinate, rather than a command.
 */
if ( c >= 'A' && c <= ('A' + BRD_H) )
	{
	/* Next we repeat the operation but we're looking for a character to
	 * give us the column of the square this time.
	 */
	do	{
		c = get_key();


		/* Valid characters are a command key or a column-indicator.
		 *
		 * Note that enabling the code to be more general causes us
		 * to put in some code which is to be conditionally compiled
		 * depending on the value of BRD_W. Try to work out exactly
		 * which pieces of code will be compiled with different values
		 * of BRD_W before you experiment with the BRD_W value. If you
		 * are using Hisoft C then this is more than an academic
		 * exercise: you will have to re-write this while() conditional
		 * slightly, using the #if/#endif statements as a guide,
		 * whenever the BRD_W value is altered before your code will
		 * work with that interpreter.
		 */
		}
		while (	!(		/* Start of while() conditional	*/
#if ( BRD_W > 9 )
			( c >= '0' && c <= '9')			||
#if  ( BRD_W > 10 )
			( c >= 'A' && c <= ('A' + BRD_W - 10) )	||
#endif /* ( BRD_W > 10 ) */
#else
			( c >= '1' && c <= ('0' + BRD_W) )	||
#endif /* ( BRD_W > 9 ) */
			c == QUIT_KEY || c == QUIT_KEY || c == SKIPGO_KEY

			) );		/* End of while() conditional	*/


	if ( c != QUIT_KEY && c != RESTART_KEY && c != SKIPGO_KEY )
		{
		showchar ( c );		/* Echo character to the screen	*/

		/* Translate character pressed into an x-coordinate.
		 */
		if ( c >= '1' && c <= '9' )
			brd->offset += c - '1';
		else
			{
			if ( c == '0' )
				brd->offset += 9;
			else
				brd->offset += c - 'A' + 10;
			};
		};
	};


/* Handle commands given by the user.
 */
if ( c == QUIT_KEY )				/* Quit program		  */
	end_othello = 3;

if ( c == SKIPGO_KEY )				/* Skip a turn: switch... */
	brd->player = brd->player->opponent;	/* ...to next Player.	  */

if ( c == RESTART_KEY )				/* Restart (new game)	  */
	setup_board ( brd );


/* Return TRUE if a move has been entered by the Player, FALSE if a command.
 */
if ( c == SKIPGO_KEY || c == RESTART_KEY || c == QUIT_KEY )
	return ( TRUE );
else
	return ( FALSE );
};

/* End of File HUMAN.C */
