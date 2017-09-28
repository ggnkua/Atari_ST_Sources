/*******************************************************************************

Program: Program: Othello
   Desc: A program to play Othello on the AtarI ST
 Author: Roy Stead
Created: 19/2/93

   File: do_move.c
   Desc: Functions to perform an Othello move.

  Notes: This code is written to accompany the _C'ing Straight_ C Tutorial
	 series, which started in the April 1993 issue of _Atari ST User_
	 magazine.

Updates:

Date		By	Comments

 19/2/93	RS	Adjusted make_move() and subsidiary functions to make
				use of new offset field instead of x and y.

*******************************************************************************/

#include "othello.h"		/* OTHELLO program definitions.		*/


/* Directional offsets used to move in a straight line through the Othello
 * Board. These constants are pre-calculated in an array to take advantage
 * of compile-time calculation, and thus speed up the make_move() function,
 * where they are made use of.
 *
 * The order in which these constants appear in the array is important, and
 * is used in is_trail() to speed up and simplify edge detection.
 */
static int drn_ary[8] =
			{
			-1 - BRD_W,		/* Left and up		*/
			-1,			/* Left			*/
			BRD_W - 1,		/* Left and down	*/
			-(BRD_W),		/* Up			*/
			BRD_W,			/* Down			*/
			1 - BRD_W,		/* Right and up		*/
			1,			/* Right		*/
			BRD_W + 1		/* Right and down	*/
			};

/*******************************************************************************
make_move()		-	Check the legality of placing a piece belonging
				to the specified Player at the specified square
				of the specified Othello Board.

				All of the above information is given in the
				Board descriptor pointed to by the passed-in
				(BOARD *)brd .

				If the move is legal, then it will be
				executed on the board provided.

				The number of pieces flipped by this move is
				returned (zero indicates an illegal move).
*******************************************************************************/

extern int make_move ( brd )
register BOARD *brd;		/* Pointer to Othello Board descriptor	*/
{
register int d_off;		/* Index to obtain Directional offsets.	*/
register int cur_off;		/* Offset to the current square.	*/
register int flipped = 0;	/* Holds number of pieces flipped.	*/
int is_trail();			/* Check if trail exists in some dirn.	*/
int flip_trail();		/* Flip all opponent's pieces in trail.	*/


/* If the proposed move is to a non-empty square then it is automatically
 * illegal.
 */
if ( *(brd->board + brd->offset) != EMPTY )
	return ( 0 );


/* Since the is_trail() and flip_trail() functions will corrupt the
 * coordinates of the current square, make a note of them to restore them
 * after every call to either of those functions.
 */
cur_off = brd->offset;


/* We loop around all eight neighbours of the current piece.
 */
for ( d_off = 0; d_off < 8; d_off++ )
	{
	/* If we find a valid trail of pieces in this direction then the move
	 * is valid. Otherwise, continue checking other directions.
	 */
	if ( is_trail ( brd, d_off ) )
		{
		/* Having found a valid trail of pieces, we execute the move
		 * by flipping all opponent's pieces in the trail.
		 *
		 * (int)flipped is simultaneously increased by the number of
		 * pieces flipped on this trail.
		 */
		brd->offset = cur_off;	/* Restore current square.	*/

		flipped += flip_trail ( brd, drn_ary[d_off] );
		};

	brd->offset = cur_off;		/* Restore current square.	*/
	};


/* Set Minimax value of this move.
 *
 * This value is used by the get_best() function to decide which move is
 * the best for a computer-controlled Player to make.
 */
if ( flipped > 0 )
	{
	brd->minimax = brd->player->score + flipped + flipped + 1 -
						brd->player->opponent->score;
	};

/* Return the number of pieces which were flipped in the course of making this
 * move. If zero is returned, the move was an illegal one.
 */
return ( flipped );
};


/*******************************************************************************
is_trail()		-	This function attempts to follow a trail of
				pieces in the direction specified, starting
				from the current square on the specified Board.

				If the trail consists of an unbroken line of
				pieces belonging to the opponent of the current
				Player followed by a piece belonging to
				the current Player then TRUE is returned,
				otherwise FALSE.

				The direction is specified as an index into
				the (static int)drn_ary[] array, which is used
				to look up a value which is to be successively
				added to the pointer offset to the current
				square. It's done in this roundabout manner
				to simplify and speed up edge detection.

				As usual, the Othello Board, current Player and
				current square are given in the structure
				pointed to by (BOARD *)brd .
*******************************************************************************/

static int is_trail ( brd, index )
register BOARD *brd;		/* Board and position to start from	*/
register int index;		/* Direction of trail			*/
{
int start;			/* Offset of starting square.		*/


start = brd->offset;


/* Continue moving in the direction given by offset (int)drn_ary[index] until
 * we reach a piece which does not belong to the opponent of the current
 * Player or we threaten to fall off the edge of the board.
 */
do	{
	/* We return FALSE in the cases when we are about to wander off the
	 * left- or right-hand side of the board. We don't need to check for
	 * wandering off the top or bottom, as that is covered by the
	 * check for a valid offset below.
	 *
	 * Note that using the index into the offsets array, combined with the
	 * ordering of the array itself, allows us to check this case quickly.
	 */
	if ( (At_left(brd) && index <= 2) || (At_right(brd) && index >= 5) )
		return ( FALSE );

	brd->offset += drn_ary[index];	/* Take one step in direction	*/

	if ( brd->offset < 0 || brd->offset >= BRD_SIZ )
		return ( FALSE );	/* Ensure new offset is valid	*/
	}
	while ( *(brd->board + brd->offset) == brd->player->opponent->piece );

#ifdef DEBUG
/* Debugging code used to let me know which trails the program is accepting as
 * valid, and which it is dismissing, and gives me a little information about
 * each valid trail located. This code is not compiled for the final program.
 *
 * Note that those of you using the Hisoft C Interpreter should delete the
 * "#ifdef DEBUG" line above and the #endif which follows if you wish to make
 * use of this debugging code. For some reason, Hisoft C ignores this code
 * even if DEBUG has been defined in this file.
 *
 * Because of Hisoft C's problem with automatics, you will also need to move
 * the automatic variable declarations (of (int)x and (char)outstr[]) to the
 * head of this function.
 */
if ( *(brd->board + brd->offset) == brd->player->piece &&
				brd->offset != (start + drn_ary[index]) )
	{
	int x;
	char outstr[90];

	x = sprintf ( &outstr[0], "Valid %c%c %c trail found ",
			((index == 0 || index == 3 || index == 5) ? '^' :
				((index == 1) ? '<':
					((index == 6) ? '>' : 'v') )),
			((index <= 2) ? '<' :
				((index >= 5) ? '>' :
					((index == 3) ? '^' : 'v' ))),
			brd->player->piece );

	x += sprintf ( &outstr[x],
			"from %c%c (%d = \'%c\') to %c%c (%d = \'%c\')",
			(start / BRD_W) + 'A',
			(start % BRD_W) +
				(( (start % BRD_W) < 10) ? '1' :
					( ((start % BRD_W) == 10) ?
						('0' - 10) :
						('A' - 11) )),
			start,
			*(brd->board + start),
			(brd->offset / BRD_W) + 'A',
			(brd->offset % BRD_W) +
				(( (brd->offset % BRD_W) < 10) ? '1' :
					( ((brd->offset % BRD_W) == 10) ?
						('0' - 10) :
						('A' - 11) )),
			brd->offset,
			*(brd->board + brd->offset) );

	bsshowtext ( &outstr[0] );
	};
#endif /* DEBUG */


/* Check that the piece at the end of the trail belongs to the current Player
 * and that at least one intermediate piece was detected (i.e. that the end
 * of the trail is not in a square adjacent to the start of the trail).
 * If so return TRUE (valid trail), else, return FALSE (trail invalid).
 */
if ( *(brd->board + brd->offset) == brd->player->piece &&
				brd->offset != (start + drn_ary[index]) )
	{
	return ( TRUE );
	}
else
	return ( FALSE );
};


/*******************************************************************************
flip_trail()		-	This function attempts to invert a trail of
				pieces belonging to the opponent of the
				specified Player on the specified Board,
				starting at the specified square, in the
				direction specified. The trail is assumed to
				be a valid one, and the number of pieces
				actually flipped is returned.

				The direction is specified as an offset
				(int dirn) to be successively added to the
				pointer offset to the current square.

				As usual, the Othello Board, current Player and
				current square are given in the Board
				descriptor pointed to by (BOARD *)brd .
*******************************************************************************/

static int flip_trail ( brd, dirn )
register BOARD *brd;		/* Board and poisiotn to start from.	*/
register int dirn;		/* Direction of trail.			*/
{
register int flipped = 0;	/* Number of pieces actually flipped.	*/


/* Continue moving in the direction given by offset (int)dirn until we reach
 * a piece which does not belong to the opponent of the current Player.
 */
do	{
	/* Flip the piece.
	 */
	*(brd->board + brd->offset) = brd->player->piece;
	flipped++;

	brd->offset += dirn;		/* Move in specified direction	*/
	}
	while ( *(brd->board + brd->offset) == brd->player->opponent->piece );


/* Return number of pieces flipped, compensating for the newly-placed piece.
 */
return ( flipped - 1 );
};

/* End of File DO_MOVE.C */
