/*******************************************************************************

Program: Program: Othello
   Desc: A program to play Othello on the AtarI ST
 Author: Roy Stead
Created: 19/2/93

   File: computer.c
   Desc: Functions to handle the Computer-controlled Othello player.

  Notes: This code is written to accompany the _C'ing Straight_ C Tutorial
	 series, which started in the April 1993 issue of _Atari ST User_
	 magazine.

Updates:

Date		By	Comments

 19/2/93	RS	Moved stalemate check from game_over() to do_computer()

*******************************************************************************/

#include "othello.h"		/* OTHELLO program definitions.		*/

extern	void	kill_list(), pause(), bsshowtext();
extern	int	make_move();
extern	BOARD	*brddup();


/*******************************************************************************
do_computer()	-	Handle a single turn by a computer-controlled Player.
*******************************************************************************/

extern int do_computer ( brd )
register BOARD *brd;		/* Pointer to Board Descriptor structure*/
{
register BOARD *legal;		/* Linked list of legal moves.		*/
register int flipped;		/* Number of pieces flipped by move.	*/
int len;			/* Length of string in (char)outstr[]	*/
char outstr[80];		/* Used to store output text.		*/
BOARD *get_legal();		/* Returns linked list of legal moves.	*/
void get_best();		/* Obtains the best possible move.	*/
void lookahead();		/* Weight minimax by looking ahead.	*/


/* The first thing we do is obtain a list of all legal moves from this
 * position. If none are available, NULL is returnd.
 */
if ( (legal = get_legal (brd)) != NULL )
	{
	/* Weight the minimax value.
	 * The sophistication of the weighting depends on the level of this
	 * computer Player.
	 */
	lookahead ( legal, brd->player->level );

	get_best ( brd, legal );	/* Put best move in (BOARD *)brd */

	kill_list ( legal );	/* Erase legal moves found linked list.	*/

	/* At this point, we have our best legal move stored in the Board
	 * Descriptor pointed to by (BOARD *)brd, and we have deleted the two
	 * scratchpad linked lists used to obtain that best legal move.
	 *
	 * We now execute this move, if it really is a legal one (if it is not
	 * a legal move, then there are no legal moves available to the
	 * computer. We need do nothing, as Game Over will be checked for us
	 * on exit from this function).
	 */
	flipped = make_move ( brd );

	/* Update the scores.
	 */
	if ( flipped > 0 )
		{
		brd->player->score += flipped + 1;
		brd->player->opponent->score -= flipped;
		};

	brd->player = brd->player->opponent;	/* Switch to next Player.*/

	return ( FALSE );		/* Signal not a stalemate	*/
	}
else
	{
	/* Provide "No legal moves found" message.
	 *
	 * sprintf() behaves exactly like printf(), but takes an extra
	 * argument before the formatting string, which is a pointer to a
	 * string to which all output will be sent _instead of_ being sent to
	 * the screen. Like printf(), sprintf() returns the number of
	 * characters output.
	 */
	len = sprintf ( &outstr[0], "%s (%c) can\'t make a move",
					brd->player->name, brd->player->piece );

	brd->player = brd->player->opponent;	/* Switch to next player */


	if ( ( legal = get_legal (brd) ) == NULL )
		{
		/* If the opponent could make no legal moves either, then
		 * provide a message to that effect also.
		 */
		len += sprintf ( &outstr[len], "| %s (%c) can\'t make a move",
					brd->player->name, brd->player->piece );

		kill_list ( legal );
		};

	pause ( &outstr[0] );		/* Show text and wait for key	*/


	if ( legal == NULL )
		return ( TRUE );	/* Signal stalemate		*/
	else
		return ( FALSE );	/* Signal not a stalemate	*/
	};
};


/*******************************************************************************
get_legal()	-	Given a Board descriptor, this function will return a
			pointer to the first element of a linked list of all
			legal moves which are available to the Player specified
			in the Board Descriptor, given the state of the Board
			specified, or NULL if no legal moves are available or
			an error occurs.
*******************************************************************************/

static BOARD *get_legal ( brd )
register BOARD *brd;		/* Pointer to Board Descriptor.		*/
{
register BOARD *first;		/* First possible move.			*/
register BOARD *currbrd;	/* General Board Descriptor pointer	*/


/* Duplicate current Board and point to the duplicate with (BOARD *)first .
 */
if ( (first = currbrd = brddup (brd)) == NULL )
	return ( NULL );

/* Loop through all possible moves on the Board, building up a linked list
 * of all legal moves and their effects.
 *
 * Study this loop carefully. Don't move on to look at the get_best() function
 * until you are sure you can see what this function is doing.
 */
for ( currbrd->offset = 0; currbrd->offset < BRD_SIZ; (currbrd->offset)++ )
	{
	/* Check whether this move is legal...
	 */
	if ( make_move ( currbrd ) > 0 )
		{
		/* It is legal, and its consequences are in the
		 * Board Descriptor pointed to by (BOARD *)currbrd,
		 * so create a new duplicate of the _original_ Board,
		 * pointing to it from the (BOARD *)nxtbrd field of
		 * the 'current' Board Descriptor.
		 *
		 * Note: We duplicate the original as the "current"
		 *	 Board has been modified by make_move().
		 *	 This implies that we must physically copy
		 *	 the current square coords across afterwards.
		 */
		if ( (currbrd->nxtbrd = brddup (brd)) == NULL )
			return ( NULL );

		/* Make the new Board into the new
		 * "current" Board before we carry on.
		 */
		currbrd->nxtbrd->offset = currbrd->offset;
		currbrd = currbrd->nxtbrd;
		};
	};


/* The final entry in the 'legal moves' linked list is a dummy Board
 * Descriptor, which was never filled in, so delete and unlink it.
 */
if ( first->nxtbrd == NULL )
	{
	/* The entire list consists only of this dummy entry, so delete it,
	 */
	free ( first->board );
	free ( first );

	return ( NULL );			/* Signal no legal moves  */
	}
else
	{
	/* Find penultimate Board Descriptor in this linked list.
	 */
	currbrd = first;
	while ( currbrd->nxtbrd->nxtbrd != NULL )
		currbrd = currbrd->nxtbrd;

	free ( currbrd->nxtbrd->board );	/* Delete final Board	  */
	free ( currbrd->nxtbrd );

	currbrd->nxtbrd = NULL;			/* Unlink it.		  */

	return ( first );			/* Return linked list.	  */
	};
};


/*******************************************************************************
lookahead()	-	Given a list of legal responses, looks ahead (int)level
			moves and weights the minimax field of each element
			of the list passed in according to the likely outcome
			of that move in (int)level moves time.
*******************************************************************************/

static void lookahead ( legal, level )
register BOARD *legal;		/* Linked list of legal moves.		*/
int level;			/* Number of moves to look ahead.	*/
{
register BOARD *next;		/* Pointer to next item in legal list.	*/
register BOARD *brd;		/* Pointer to current item in legal.	*/
register BOARD *response;	/* Linked list of legal responses.	*/
register BOARD *scratch;	/* Pointer to scratchpad Board Desc.	*/
int flipped, lastflip;		/* Pieces flipped this/last turn.	*/
int x, y;			/* General looping variables.		*/
char outstr[80];		/* Used to store output text.		*/
BOARD *get_legal();		/* Returns linked list of legal moves.	*/
void get_best();		/* Obtains the best possible move.	*/


if ( level < 1 )		/* No lookahead, so return immediately	*/
	return;

next = legal;			/* Start at head of list (BOARD *)legal	*/

do	{
	brd = next;		/* Pointer to 1st item in list.	*/
	next = brd->nxtbrd;	/* This will be 1st next time.	*/


	flipped = lastflip = 1;	/* Set up scratchpad variables.	*/

	if ( (scratch = brddup (brd) ) == NULL )
		return;

	/* Note: Never, Never, Never, Never, Never use nested ternary
	 * operators (as I've done in this sprintf() statement) - it makes
	 * your code very awkward to read and understand. Not to mention debug.
	 */
	sprintf ( &outstr[0], "Contemplating %c%c...",
			(scratch->offset / BRD_W) + 'A',
			(scratch->offset % BRD_W) +
				(( (scratch->offset % BRD_W) < 10) ? '1' :
					( ((scratch->offset % BRD_W) == 10) ?
							('0' - 10) :
							('A' - 11) )) );
	bsshowtext ( &outstr[0] );

	/* Look (int)level moves ahead in the game for each legal move in
	 * the (BOARD *)legal linked list. As we look ahead, we adjust the
	 * minimax field for the linked list entry to reflect the board
	 * in moves to come, assuming that the opponent will always use the
	 * best move available to her. If a stalemate is the consequence then
	 * we halt the lookahead at that point.
	 */
	for ( x = 0; x < level && (flipped != 0 || lastflip != 0); x++ )
		{
		/* Must do this twice for each move - once for the opponent's
		 * response to the original move, and once for our reply.
		 */
		for ( y = 0; y < 2; y++ )
			{
			lastflip = flipped;

			scratch->player = scratch->player->opponent;

			/* Get list of legal responses to the move in the
			 * (BOARD *)scratch scratchpad Board Descriptor.
			 */
			if ( (response = get_legal (scratch)) != NULL )
				{
				/* Get the best possible response and store it
				 * in the (BOARD *)scratch temporary Board
				 * Descriptor.
				 */
				get_best ( scratch, response );

				kill_list ( response );	   /* Kill list	*/

				/* Adjust the board field of (BOARD *)scratch to
				 * look like it would after the opponent's best
				 * response was played.
				 */
				if ( (flipped = make_move (scratch)) > 0 )
					{
					/* Update the minimax field of the
					 * original move in the passed-in list.
					 */
					if ( scratch->player == brd->player )
						{
						brd->minimax += flipped +
								flipped + 1;
						}
					else
						{
						brd->minimax -= flipped +
								flipped + 1;
						};
					};
				}
			else
				flipped = 0;	/* No legal response	*/
			};
		};

	free ( scratch->board );		/* Reclaim scratch	*/
	free ( scratch );
	}
	while ( next != NULL );		/* Carry on to end	*/
};


/*******************************************************************************
get_best()	-	Given a Board descriptor and a list of all legal moves,
			this function chooses the best possible move from the
			list and returns that move in the current square
			fields of the passed-in Board Descriptor.

			The method used is to select the move which results in
			the maximum number of pieces belonging to the Player,
			_and_ the minimum number of pieces belonging to the
			opponent: the minimax method. The actual minimax value
			is calculated in make_move() for every move as it is
			made.

			If there are several equal-best moves then one will be
			chosen at random _unless_ one of those moves is in a
			corner square of the Board, in which case that move
			will be performed in preference to other apparently
			equally-good moves. This latter, by the way, is a small
			example of a heuristic. It doesn't take much Othello
			playing to learn that the corner squares are valuable.
*******************************************************************************/

static void get_best ( brd, legal )
register BOARD *brd;		/* Board Descriptor to return move in.	*/
register BOARD *legal;		/* Linked list of legal moves.		*/
{
register BOARD *currbrd;	/* Pointer into legal moves list.	*/
register BOARD *best;		/* Linked list of best possible moves.	*/
register BOARD *currbest;	/* Best possible move, general pointer.	*/
int n;				/* General purpose int variable.	*/
int mfound = 0;			/* Moves found.				*/


/* First legal move is initially the best move.
 */
if ( ( best = currbest = brddup (legal) ) == NULL )
	return;

mfound = 1;

currbrd = legal;

while ( currbrd != NULL )
	{
	if ( currbrd->minimax == best->minimax )
		{
		/* Equivalent moves, in terms of value, so add this move to
		 * our list of best moves found.
		 */
		if ( ( currbest->nxtbrd = brddup (currbrd) ) == NULL )
			return;

		/* String the current move onto the end of the best
		 * moves found so far linked list.
		 */
		currbest = currbest->nxtbrd;
		mfound++;
		}
	else
		{
		if ( currbrd->minimax > best->minimax )
			{
			/* We've found a better move than the current best move,
			 * so erase the current best moves list and replace it
			 * with a copy of this Board Descriptor.
			 */
			kill_list ( best );	/* Erase current list	*/

			/* Make the current Board Descriptor the entirety of
			 * the best-move-found-so-far linked list.
			 */
			if ( (best = currbest = brddup (currbrd)) == NULL )
				return;

			mfound = 1;
			};
		};

	currbrd = currbrd->nxtbrd;
	};


currbest = best;
if ( mfound > 1 )
	{
	/* If We have a choice of best moves then quickly skim through the
	 * list to see if any of them are in a corner square.
	 */
	currbrd = best;
	do	{
		currbest = currbrd;		/* Ptr to 1st item in list. */
		currbrd = currbest->nxtbrd;	/* Will be 1st next time.   */

		/* Check whether this move is a corner square.
		 * If it is, then use it in preference to all others.
		 */
		if ( At_top(currbest) || At_bottom(currbest) )
			if ( At_left(currbest) || At_right(currbest) )
				mfound = 0;	/* Signal found corner	*/
		}
		while ( (currbrd != NULL) && mfound );	/* Carry on to end   */

	if ( mfound != 0 )
		{
		/* Select a random move from the best-moves-found linked list.
		 */
		currbest = best;
		if ( best->nxtbrd != NULL )
			{
			/* Get random number from zero to (int)mfound
			 */
			n = (int)rand() % mfound;

			while ( n )	/* Choose n'th move from list	*/
				{
				currbest = currbest->nxtbrd;

				n--;
				};
			};
		};
	};

/* Put the offset of the move chosen into the passed-in Board Desc.
 */
brd->offset = currbest->offset;

kill_list ( best );		/* Erase best-move-found  linked list.	*/
};

/* End of File COMPUTER.C */
