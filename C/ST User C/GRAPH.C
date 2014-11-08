/*******************************************************************************

Program: Othello
   Desc: A program to play Othello on the AtarI ST
 Author: Roy Stead
Created: 19/2/93

   File: graph.c
   Desc: Graphics routines.

  Notes: This code is written to accompany the _C'ing Straight_ C Tutorial
	 series, which started in the April 1993 issue of _Atari ST User_
	 magazine.

Updates:

Date		By	Comments

*******************************************************************************/

#include "othello.h"		/* OTHELLO program definitions.		*/

extern	char	get_key();
extern	int	end_othello;


/*******************************************************************************
show_board()		-	Displays the entire Othello Board, a pointer
				to which is passed in (BOARD *)brd .

				This function also detects a Game Over.
*******************************************************************************/

extern void show_board ( brd )
register BOARD *brd;			/* The Othello Board to display.*/
{
register int x;				/* General looping variable.	*/
register PLAYER *player0, *player1;	/* Ptrs to the two players.	*/


printf ( "%cE", ESC );		/* VT52 control code - clears the screen*/


/* Display the header line above the Board.
 */
printf ( "  " /* two spaces*/ );
for ( x = 0; x < BRD_W; x++ )
	{
	if ( x < 9 )			/* Only needed for wider Board	*/
		putchar ( '1' + x );
	else
		{
		if ( x == 9 )
			putchar ( '0' );
		else
			putchar ( 'A' + x - 10 );
		};
	};

printf ("\n  " /* two spaces */ );
for ( x = 0; x < BRD_W; x++ )
	putchar ( '_' );
printf (" \n" );


for ( brd->offset = 0; brd->offset < BRD_SIZ; (brd->offset)++ )
	{
	if ( At_left(brd) )
		{
		putchar ( 'A' + (brd->offset / 8) );	/* Show line	*/
		putchar ( '|' );
		};

	if ( (putchar ( *(brd->board + brd->offset) )) == - 1 )
		{
		end_othello = 2;		/* Putchar() error	*/

		return;		/* Exit function, but no return value */
		};

	if ( At_right(brd) )
		{
		putchar ( '|' );
		putchar ( '\n' );	/* Output '\n' at end of line	*/
		};
	};

printf ("  " /* two spaces */ );
for ( x = 0; x < BRD_W; x++ )		/* Underline Board.		*/
	putchar ( 'ÿ' );
printf (" \n\n" );


/* Set (PLAYER *)player0 to point to Player Zero, and (PLAYER *)player1 to
 * point to Player One, to fascilitate the display of names with the score.
 */
if ( brd->player->piece == PLAY0_PIECE )
	{
	player0 = brd->player;
	player1 = brd->player->opponent;
	}
else
	{
	player0 = brd->player->opponent;
	player1 = brd->player;
	};

/* Show the current score.
 */
printf ( "Score:\t%s (%c): %d\t\t%s (%c): %d\n",
			player0->name, player0->piece, player0->score,
			player1->name, player1->piece, player1->score );


/* Prompt user to enter a move if the user is human.
 */
if ( brd->player->level < 0 )
	{
	printf ( "\n\nCommands available: " );
	printf ( "Q (Quit), R (Restart), ESC (skip a go)\n\n" );
	printf ( "Type your move, player %s (%c) (e.g. A7): ",
					brd->player->name, brd->player->piece );
	};
};


/*******************************************************************************
The functions which follow are not commented for two reasons.

Firstly, they should be self-explanatory, and secondly they are merely
stop-gap functions, provided to perform simple output-to-screen operations.

They are here to provide a screen interface which is under our control and
through which all screen output from this program is to pass. As we move into
the world of GEM, in coming months, these functions will gradually be extended
and/or replaced until we end up with a full GEM screen interface without
having the problems of having to rewrite large chunks of the rest of our
program every time we make a change to the way text is shown on-screen.
*******************************************************************************/

extern void showtext ( str )
char *str;
{
printf ( str );
};


extern void bsshowtext ( str )
char *str;
{
int x;

x = printf ( str );

for ( ; x ; x-- )
	putchar ( '\b' );
};


extern void pause ( str )
char *str;
{
int len;
char outstr[90];
void bsshowtext();


len = sprintf ( &outstr[0], "%s: Press A Key", str );
bsshowtext ( &outstr[0] );


get_key();		/* Wait for a key press		*/

do	{		/* Erase text			*/
	len--;
	outstr[len] = SPC;
	}
	while ( len != 0 );

bsshowtext ( &outstr[0] );
};


extern void showchar ( c )
char c;
{
putchar ( c );
};


extern void moveleft ( x )
int x;
{
while ( x-- )
	putchar ( '\b' );
};


/* End file GRAPH.C */
