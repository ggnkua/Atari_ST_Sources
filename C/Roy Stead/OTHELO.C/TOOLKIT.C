/*******************************************************************************

Program: Othello
   Desc: A program to play Othello on the AtarI ST
 Author: Roy Stead
Created: 19/2/93

   File: toolkit.c
   Desc: General purpose bread-and-butter functions

  Notes: This code is written to accompany the _C'ing Straight_ C Tutorial
	 series, which started in the April 1993 issue of _Atari ST User_
	 magazine.

Updates:

Date		By	Comments

*******************************************************************************/

#include <osbind.h>		/* Operating System BINDings		*/
#include "othello.h"		/* OTHELLO program definitions.		*/


extern	void	pause();
extern	BOARD	*brdcreat();

extern	int	end_othello;


/*******************************************************************************
get_key()	-	Waits for a key press from the user, and returns the
			ASCII code of the key pressed.

			If the key was an alphabetic character, then the
			_upper case_ character is returned.
*******************************************************************************/

extern char get_key()
{
register char c;		/* Character pressed by the user.	*/


/* Bconin() waits for a keypress and returns a long integer containing
 * the keyboard scan code for that key. Bconin() is a gemdos function,
 * and is declared in the header file <osbind.h>.
 *
 * The ampersand (&) performs a bitwise AND operation.
 * We use it here because we are only interested in the lower word of
 * the value returned from Bconin(), as that word contains the ASCII
 * code of the character typed. Explanations in future articles, okay?
 */
c = (char)(Bconin ( 2 ) & 0x00FF);

if ( c >= 'a' && c <= 'z' )		/* Convert upper to lower case	*/
	c -= 'a' - 'A';

return ( c );
};


/*******************************************************************************
game_over()		-	Checks for a Game Over situation.

				If Game Over is detected, produces an
				appropriate Win/Lose/Draw message and returns
				TRUE, otherwise just returns FALSE.
*******************************************************************************/

extern int game_over ( brd, stalemate )
register BOARD *brd;		/* Pointer to current Board Descriptor	*/
register int stalemate;		/* TRUE if no legal moves for anyone.	*/
{
int len;			/* Length of string in (char)outstr[]	*/
char outstr[80];		/* Used to store output text.		*/


/* Check to see if the game is over.
 *
 * This happens if all of the squares are filled or if either Player has no
 * pieces remaining on the Board. A Game Over is also forced when neither
 * Player has any legal moves available (a stalemate).
 */
if ( (brd->player->score + brd->player->opponent->score) == BRD_SIZ	||
		brd->player->score == 0					||
		brd->player->opponent->score == 0			||
		stalemate )
	{
	/* sprintf() behaves exactly like printf(), but takes an extra
	 * argument before the formatting string, which is a pointer to a
	 * string to which all output will be sent _instead of_ being sent
	 * to the screen. Like printf(), sprintf() returns the number of
	 * characters output.
	 */
	len = sprintf ( &outstr[0], "Game Over: " );


	/* Signal to the user that a stalemate has been found.
	 * Only signal if the stalemate is the _sole_ reason for Game Over.
	 */
	if (((brd->player->score + brd->player->opponent->score) != BRD_SIZ) &&
			 stalemate					&&
			brd->player->score != 0				&&
			brd->player->opponent->score != 0 )
		{
		len += sprintf ( &outstr[len], "Stalemate: " );
		};


	/* Handle outright win or draw messages.
	 */
	if ( brd->player->score == brd->player->opponent->score )
		len += sprintf ( &outstr[len], "It was a draw." );
	else
		{
		/* Show message indicating which Player has won.
		 *
		 * Note the use of the ternary conditional operator within
		 * this sprintf() statement.
		 */
		len += sprintf ( &outstr[len], "Player %s (%c) has won.",
			((brd->player->score > brd->player->opponent->score) ?
					brd->player->name		:
					brd->player->opponent->name ),
			((brd->player->score > brd->player->opponent->score) ?
					brd->player->piece		:
					brd->player->opponent->piece )
			);
		};

	pause ( &outstr[0] );		/* Show text and wait for key	*/

	return ( TRUE );		/* Signal Game Over		*/
	}
else
	return ( FALSE );		/* Signal Game not over		*/
};


/*******************************************************************************
kill_list()		-	Given a pointer to the first element in a
				linked list, this function will delete the
				entire list.
*******************************************************************************/

extern void kill_list ( first )
register BOARD *first;		/* Pointer to 1st item in list to kill.	*/
{
register BOARD *currbrd;	/* Pointer to items in list.		*/


/* Note that first always points to the first item in the linked list on
 * every iteration of the loop (the previous first item having been erased).
 */
do	{
	currbrd = first;		/* Pointer to 1st item in list.	*/

	first = currbrd->nxtbrd;	/* This will be 1st next time.	*/


	free ( currbrd->board );	/* Kill block used by 1st item.	*/
	free ( currbrd );		/* Kill the first item in list.	*/

	/*	NB/	We don't delete player fields as these are...	*/
	/*		shared globally by all Board Descriptors.	*/

	}
	while ( first != NULL );	/* Carry on until end detected.	*/
};


/*******************************************************************************
brddup()	-	Given a pointer to an Othello Board descriptor
			structures (BOARD *srcbrd), this function creates a
			duplicate of (BOARD *)srcbrd and returns a pointer to
			the new structure.

			Note that the new structure's (char *)board field
			points to a different memory block from that pointed
			to by the (char *)board field of the passed-in
			descriptor, though the contents of the latter are
			copied across to the new structure. The (PLAYER *)player
			field of the new both structures do, however, point
			at the same memory block.

			Since this function is used mainly in the creation of
			linked lists, the (BOARD *)nxtbrd field of the new
			structure is not duplicated, but is set to NULL.
*******************************************************************************/

extern BOARD *brddup ( srcbrd )
register BOARD *srcbrd;		/* Board descriptor to duplicate.	*/
{
register BOARD *newbrd;		/* Pointer to duplicate Board.		*/
register int x;			/* Looping variable.			*/


/* Create a new Othello Board descriptor.
 */
if ( (newbrd = brdcreat()) != NULL )
	{
	/* Copy contents of srcbrd to newbrd
	 */
	for ( x = 0; x < BRD_SIZ; x++ )		/* Copy Board info	*/
		*(newbrd->board + x) = *(srcbrd->board + x);

	newbrd->offset	= srcbrd->offset;	/* Copy square info	*/
	newbrd->player	= srcbrd->player;	/* Copy Player info	*/
	newbrd->minimax	= srcbrd->minimax;	/* Copy minimax value	*/

	/* (BOARD *)nxtbrd field was set to NULL by brdcreat()		*/
	};

return ( newbrd );		/* Return a pointer to newbrd, or NULL	*/
};

/* End of File TOOLKIT.C */
