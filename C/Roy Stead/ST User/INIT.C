/*******************************************************************************

Program: Othello
   Desc: A program to play Othello on the AtarI ST
 Author: Roy Stead
Created: 19/2/93

   File: init.c
   Desc: Initialisation routines.

  Notes: This code is written to accompany the _C'ing Straight_ C Tutorial
	 series, which started in the April 1993 issue of _Atari ST User_
	 magazine.

Updates:

Date		By	Comments

*******************************************************************************/

/* If using the Hisoft C Interpreter, delete the #include lines between the
 * #ifndef IC/#endif lines or that package will produce a weird error message
 * about finding an error in the header file. Don't ask me why, but it does...
 */
#ifndef IC
#include <string.h>		/* STRING definitions.			*/
#include <malloc.h>		/* Memory ALLOCation Header file	*/
#endif /* IC */

#include "othello.h"		/* OTHELLO program definitions.		*/


extern	int	end_othello;


/*******************************************************************************
setup_board()		-	Setups a blank Board ready for a new game.

				The Board to set up is given in the Board
				descriptor pointed to by (BOARD *)brd .
*******************************************************************************/

extern void setup_board ( brd )
register BOARD *brd;		/* Pointer to Board to initialise.	*/
{
register int x;			/* Looping variable.			*/


for ( x = 0; x < BRD_SIZ; x++ )
	*(brd->board + x) = EMPTY;	/* Set Board to empty squares	*/


/* Player zero goes first.
 */
if ( brd->player->piece != PLAY0_PIECE )
	brd->player = brd->player->opponent;


/* Othello starts off with the central four pieces already on the Board.
 */
brd->offset = (BRD_W >> 1) + ((BRD_H * BRD_W) >> 1);	/* <4,4> in 8x8 */

*(brd->board + brd->offset)		= brd->player->piece;		/* 44 */
*(brd->board + brd->offset - 1)		= brd->player->opponent->piece; /* 34 */
*(brd->board + brd->offset - BRD_W - 1)	= brd->player->piece;		/* 33 */
*(brd->board + brd->offset - BRD_W)	= brd->player->opponent->piece; /* 34 */


/* Reset scores for the two Players.
 */
brd->player->score = brd->player->opponent->score = 2;
brd->minimax = 0;
};


/*******************************************************************************
brdcreat()	-	Creates an Othello Board descriptor.

			Returns a pointer to the new Othello Board, or NULL.
*******************************************************************************/

extern BOARD *brdcreat()
{
register BOARD *brd;			/* Pointer to Othello Board.	*/


/* Obtain a memory block for our Othello Board Descriptor.
 * Note the use of sizeof(), which calculates - at compile time - the correct
 * number of bytes required to store a BOARD structure. sizeof() can, of
 * course, be used with any C variable type and "returns" an int .
 *
 * Exercise: Try combining these two malloc() calls into a single call to
 *		allocate sufficent memory for both required memory blocks.
 *		Hint: You'll need to use cast-to-type statements, and
 *		to think about the way pointer addition is handled in C.
 */
if ( (brd = (BOARD *)malloc ( (long)sizeof(BOARD) )) == NULL )
	end_othello = 1;
else
	{
	brd->nxtbrd = NULL;		/* Reset Next Board pointer	*/

	/* Now obtain a memory block for the 'board' field of the descriptor.
	 */
	if ( (brd->board = (char *)malloc ( (long)BRD_SIZ )) == NULL )
		end_othello = 1;
	};

return ( brd );		/* Return pointer to new Board descriptor	*/
};


/*******************************************************************************
get_players()		-	Takes as its argument a pointer to a
				(previously initialised) Board descriptor
				structure (BOARD *)brd . Initialises the
				'player' field of that structure, by
				allocating memory for the PLAYER blocks and
				initialising those blocks.

				Returns TRUE on success, FALSE on failure.
*******************************************************************************/

extern int get_players ( brd )
register BOARD *brd;		/* Board descriptor to place Players	*/
{
register PLAYER *newplayer;	/* Pointer to blocks containing Players	*/


/* Allocate space for two players.
 */
if ( (newplayer = (PLAYER *)malloc ( 2L * (long)sizeof(PLAYER) )) == NULL )
	{
	end_othello = 1;
	return ( FALSE );
	}
else
	{
	/* Two players, pointing to each other so that each is defined
	 * as the opponent of the other.
	 *
	 * Remember that (newplayer + 1) points to the second PLAYER
	 * struct in the block, _not_ the second byte or field.
	 */
	newplayer->opponent = newplayer + 1;
	brd->player = newplayer->opponent->opponent = newplayer;


	/* Initialise the actual player data fields. Note the use of strdup(),
	 * which allocates memory for a string and then copies the given
	 * string into the newly-allocated position, and returns a pointer
	 * to it.
	 */
	brd->player->piece = PLAY0_PIECE;	/* Piece used by Player	*/
	brd->player->name  = strdup ( PLAY0_NAME );	/* Player's name*/
	brd->player->score = 0;			/* Player's score	*/
	brd->player->level = PLAY0_LEVEL;	/* Player's skill level	*/

	brd->player->opponent->piece = PLAY1_PIECE;		/* Piece*/
	brd->player->opponent->name  = strdup ( PLAY1_NAME );	/* Name */
	brd->player->opponent->score = 0;			/* Score*/
	brd->player->opponent->level = PLAY1_LEVEL;		/* Skill*/

	return ( TRUE );
	};
};


/* End file INIT.C */
