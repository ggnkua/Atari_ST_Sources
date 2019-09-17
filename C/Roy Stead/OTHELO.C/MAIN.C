/*******************************************************************************

Program: Othello
   Desc: A program to play Othello on the AtarI ST
 Author: Roy Stead
Created: 19/2/93

   File: main.c
   Desc: Entry point and main controlling loop.

  Notes: This code is written to accompany the _C'ing Straight_ C Tutorial
	 series, which started in the April 1993 issue of _Atari ST User_
	 magazine.

Updates:

Date		By	Comments

*******************************************************************************/

#include "othello.h"		/* OTHELLO program definitions.		*/


extern	void	setup_board(), show_board(), do_human(), pause();
extern	int	do_computer(), get_players(), game_over();
extern	BOARD	*brdcreat();


/*******************************************************************************
	Set up extern variables: These variables are visible to all files.
*******************************************************************************/

int end_othello		= 0;		/* Set non-zero to exit Othello	*/


/*******************************************************************************
Set up static variables: These variables are visible to this file only.
*******************************************************************************/

/* Error messages for Othello.
 */
static char *errors[3] =
			{				/* end_othello	*/
			"Not enough memory",		/*	1	*/
			"Error displaying Board",	/*	2	*/
			"Quit pressed"			/*	3	*/
			};


/*******************************************************************************
main()		-	Entry point of program.
*******************************************************************************/

main()
{
register BOARD *brd;		/* The main Othello Board descriptor.	*/
register int stalemate;		/* TRUE if no legal moves for anyone.	*/


/* Create the main Othello Board.
 */
if ( (brd = brdcreat()) != NULL )
	{
	if ( get_players ( brd ) )	/* Initialise Players		*/
		{
		setup_board ( brd );	/* Set up Othello Board.	*/
		show_board ( brd );	/* Display Othello Board.	*/
		};
	};


/* Main loop - repeats until end_othello takes a non-zero value
 */
while ( !end_othello )
	{
	/* Handle a single turn for a computer or human Player.
	 */
	if ( brd->player->level >= 0 )
		{
		/* Handle the computer-controlled Player's turn - note that
		 * do_computer() now returns TRUE if the computer could
		 * find no legal moves for itself _or_ for the human player.
		 *
		 * This facility used to be in the function game_over(), but
		 * has been shifted into do_computer() to speed up execution.
		 */
		stalemate = do_computer ( brd );
		}
	else
		{
		do_human ( brd );	/* Handle a human Player's turn	*/

		stalemate = FALSE;
		};

	show_board ( brd );		/* Redisplay Othello Board.	*/

	if ( game_over ( brd, stalemate ) )	/* If Game Over found...*/
		{
		setup_board ( brd );	/* ...Set up Board for new game	*/
		show_board ( brd );	/* Redisplay Othello Board.	*/
		};
	};


/* Display the error code, waiting for a key press after it is displayed.
 */
pause ( errors[end_othello - 1] );


while ( brd != NULL )	/* Free Othello Board descriptor memory block.	*/
	{
	if ( brd->board != NULL )
		free ( brd->board );

	if ( brd->player != NULL )
		{
		if ( brd->player < brd->player->opponent )
			free ( brd->player );
		else
			free ( brd->player->opponent );
		};

	free ( brd );

	brd = brd->nxtbrd;
	};
};


/* End of File MAIN.C */
