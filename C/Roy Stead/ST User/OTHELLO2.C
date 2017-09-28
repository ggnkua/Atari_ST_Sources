/* DO NOT LOAD THIS FILE UNCHANGED INTO THE HISOFT C INTERPRETER.
 * IT WON'T WORK.
 *
 * If you wish to use this file with the Hisoft C Interpreter then you
 * will have to _delete_ the two lines below which contain the symbol IC
 * as well as all of the lines between those two. This is necessary because
 * of the Hisoft package's non-standard manner of handling these pre-processor
 * commands. Try not to worry too much about what this means, we'll be dealing
 * with pre-processor commands in more detail in future articles.
 *
 * This small chunk of # commands are instructions to the compiler.
 * For now, you can ignore them, as we will be examining them next month.
 */
#include <stdio.h>		/* STandarD Input and Output Header	*/

#ifndef IC
#include <malloc.h>		/* Memory ALLOCation Header file	*/
#include <osbind.h>		/* Operating System BINDings Header	*/

#ifdef SOZOBON
#define malloc		lalloc	/* Sozobon C's malloc uses int argument	*/
#endif SOZOBON
#endif IC

#ifndef FALSE
#define TRUE	(1==1)
#define FALSE	(1==0)
#endif FALSE

/*******************************************************************************
     Set up global variables. These variables are usable by all functions.
*******************************************************************************/

char *board		= NULL;		/* Pointer to Othello Board	*/

/* The representation of the Othello pieces used in the screen display is
 * stored in the piece[] array, while (int)player indicates which player's
 * turn it is, and is an index into the piece[] array giving the piece used
 * by that player.
 */
char piece[2]		= { 'O', 'X' };
int player		= 0;

int end_othello		= 0;		/* Set non-zero to exit Othello	*/


/* Error messages for Othello.
 *
 * Note that we must explicitly state the size of the array [3] here if we
 * want to use this source code with packages, such as Hisoft C, which cannot
 * handle implicit array sizing ( where we would just write: char *errors[] = )
 */
char *errors[3] =	{				/* end_othello	*/
			"Not enough memory",		/*	1	*/
			"Error displaying Board",	/*	2	*/
			"Quit pressed"			/*	3	*/
			};


/*******************************************************************************
main()		-	Entry point of program
*******************************************************************************/

main()
{
int x, y;			/* Coordinates of the player's move	*/
void init();			/* Initialises global variables.	*/
void get_move();		/* Gets a move from the player.		*/
void show_board();		/* Displays Othello Board.		*/
int make_move();		/* Make the move specified.		*/


init();				/* Initialise Othello.			*/


/* Main loop - repeats until end_othello takes a non-zero value
 */
while ( !end_othello )
	{
	/* Read in a move from the player.
	 *
	 * Note that the player's move, translated into coordinates in the
	 * Othello Board, is "returned" via pointers to (int)x and (int)y .
	 */
	get_move ( &x, &y );

	/* The first thing we check is whether or not the player has quit,
	 * skipped a go or restarted the game. x is set to -1 to indicate
	 * the latter two options.
	 */
	if ( !end_othello && x != -1 )
		{
		if ( make_move ( x, y ) )
			{
			/* Switch to next player if the move given was legal.
			 */
			if ( player == 0 )
				player = 1;
			else
				player = 0;

			/* Re-display the Othello Board.
			 */
			show_board();
			}
		else
			{
			/* Move was illegal, so try again.
			 */
			printf ( ": Illegal Move: Press a Key" );

			Bconin ( 2 );

			/* Back space over previous message, erase
			 * it and then backspace back again.
			 */
			printf ("\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b");
			printf ("\b\b\b\b\b\b\b\b\b\b\b\b\b\b");
			printf ( "                             " );
			printf ("\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b");
			printf ("\b\b\b\b\b\b\b\b\b\b\b\b\b\b");
			};
		};
	};


/* Handle error codes.
 */
printf ( "\n\n%s\nPress a Key\n", errors[end_othello - 1] );

Bconin ( 2 );


/* Free block of memory used by Othello Board if necessary.
 */
if ( board != NULL )
	free ( board );
};


/*******************************************************************************
get_move()		-	Get a move from the player.

				Reads in two characters from the player,
				and translates them into coordinates in the
				Othello board. Those coordinates are then
				placed into two integers via the pointers
				(int *)x and (int *)y passed in.
*******************************************************************************/

void get_move ( x, y )
int *x, *y;
{
char c;				/* The character typed by the player.	*/
void show_board();		/* Displays Othello Board.		*/
void setup_board();		/* Set up Board for a new game.		*/


/* We first of all obtain a single character from the player,
 * repeating this as many times as is necessary before we get a
 * valid one.
 */
do	{
	/* The ampersand (&) performs a bitwise AND operation.
	 * we use it here because we are only interested in the
	 * lower word of the value returned from Bconin(), as that
	 * word contains the ASCII code of the character typed.
	 */
	c = (char)(Bconin ( 2 ) & 0x00FF);

	/* Convert a lower-case character into an upper-case one.
	 * Note the use of the -= operator, which subtracts the result of the
	 * right-hand side from the variable on the left, exactly as if we had
	 * used "c = c - ('a' - 'A');" Similarly, we can use other shorthand
	 * operators, such as +=, *=, /=, %=, etc, etc.
	 */
	if ( c >= 'a' && c <= 'z' )
		c -= 'a' - 'A';

	/* Note that valid characters are ''A' to 'H', 'Q', 'R' and ESC
	 */
	}
	while ( !((c >= 'A' || c <= 'H') ||
		c == 'Q' || c == 'R' || c == '\x1B') );


*y = c - 'A';

if ( c != '\x1B' )
	putchar ( c );		/* Echo character to the screen		*/


/* We onlt bother to obtain the second character from the user if the first
 * was a coordinate, rather than a command.
 */
if ( c >= 'A' && c <= 'H' )
	{
	/* Next we repeat the operation but we're looking for a digit
	 * from '1' to '8' this time.
	 */
	do	{
		c = (char)(Bconin ( 2 ) & 0x00FF);

		if ( c >= 'a' && c <= 'z' )
			c -= 'a' - 'A';

		/* Valid characters are '1' to '8' and 'Q', 'R' or ESC
		 */
		}
		while ( (c < '1' || c > '8') &&
			c != 'Q' && c != 'R' && c != 0x1B );


	if ( c >= '1' && c <= '8' )
		{
		putchar ( c );		/* Echo character to the screen	*/

		*x = c - '1';
		};
	};


/* Handle commands given by the user.
 */
if ( c == 'Q' )				/* Quit program			*/
	end_othello = 3;

if ( c == 0x1B )			/* ESC pressed = skip a turn	*/
	{
	/* Switch to next player.
	 */
	if ( player == 0 )
		player = 1;
	else
		player = 0;

	show_board();
	};

if ( c == 'R' )				/* Restart (new game)		*/
	setup_board();

if ( c == 0x1B || c == 'R' )		/* Signal no move entered	*/
	*x = -1;
};


/*******************************************************************************
show_board()		-	Displays the entire Othello Board.

				Since we are using a memory block, and we no
				longer put EOS characters on the end of each
				line of the Board, this	function is now a
				little more complex than it was last month.

				This function also now detects a Game Over.
*******************************************************************************/

void show_board()
{
char thispiece;			/* A piece on the board.		*/
int x, y;			/* Offsets into the Board "array."	*/
int cnt0, cnt1;			/* Count of pieces owned by players.	*/
char get_piece();		/* Get value of specific piece.		*/
void setup_board();		/* Set up Board for a new game.		*/


/* Resets the count of pieces owned to zero.
 * Note that every C expression has a value. The value of an assignment is
 * the value assigned, thus the value of "cnt1 = 0;" is zero, which can
 * iself be assigned to a variable, as happens here.
 */
cnt0 = cnt1 = 0;


printf ( "%cE", 0x1B );		/* VT52 control code - clears the screen*/


printf ( "  12345678\n  ________ \n" );

for ( y = 0; y < 8; y++ )
	{
	/* This first putchar() will ensure that the leftmost column of the
	 * Board will contain one of the letters 'A' to 'H', depending on
	 * the line. Note that a char is merely an 8-bit integer like any
	 * other integer. It only "becomes" an ASCII code when we use it as
	 * such.
	 */
	putchar ( 'A' + y );
	putchar ( '|' );

	for ( x = 0; x < 8; x++ )
		{
		thispiece = get_piece(x,y);

		/* putchar() returns -1 on errors, so we can test its value
		 * within the conditional, with no need for a separate
		 * statement or another variable.
		 */
		if ( (putchar ( thispiece )) == - 1 )
			{
			end_othello = 2;

			return;		/* Exit function, but no return value */
			};

		/* Update the count of pieces owned by each player.
		 *
		 * Note the use of "cnt0++", which increments (adds one to)
		 * the variable cnt0, exactly as if we had typed the expression
		 * "cnt0 = cnt0 + 1" or "x += 1". "cnt0++" is preferred here,
		 * though, not only because it saves typing, but it also
		 * allows the compiler to generate slightly more efficent code.
		 * Similarly, "cnt0--" would decrement (subtract one from) the
		 * variable cnt0.
		 */
		if ( thispiece == piece[0] )
			cnt0++;
		else
			{
			if ( thispiece == piece[1] )
				cnt1++;
			};
		};

	putchar ( '|' );
	putchar ( '\n' );		/* Output '\n' at end of line	*/
	};

printf ( "  ÿÿÿÿÿÿÿÿ \n\n" );
printf ( "Score:\t%c: %d\t\t%c: %d\n", piece[0], cnt0, piece[1], cnt1 );


/* Check to see if the game is over.
 * This happens if all of the squares are filled or if either player has no
 * pieces remaining on the board. A Game Over is also forced when neither
 * player has any legal moves available, but we'll cover that next month
 * when we add a computer player to the program.
 */
if ( (cnt0 + cnt1) == 64 || cnt0 == 0 || cnt1 == 0 )
	{
	printf ( "\nGame Over: " );

	if ( cnt0 == cnt1 )
		printf ( "It was a draw" );
	else
		{
		if ( cnt0 > cnt1 )
			player = 0;
		else
			player = 1;

		printf ( "Player \'%c\' has won", piece[player] );
		};

	printf ( ".\n\nPress a Key\n" );  /* Wait for a key press.	*/
	Bconin ( 2 );

	setup_board();			/* Set up board for new game.	*/
	}
else
	{
	/* Game not over, so prompt user to enter a move.
	 */
	printf ( "\n\nCommands available: " );
	printf ( "Q (Quit), R (Restart), ESC (skip a go)\n\n");
	printf ( "Type your move, player \'%c\' (e.g. A7): ", piece[player] );
	};
};


/*******************************************************************************
make_move()		-	Check the legality of placing a piece belonging
				to the current (int)player at square (int)x
				on line (int)y of the Othello Board.

				If the move is legal, then perform it and
				return TRUE, otherwise return FALSE.
*******************************************************************************/

int make_move ( x, y )
int x, y;			/* Coordinates to place new piece.	*/
{
int x_off;			/* x-offset from <x,y>			*/
int y_off;			/* y-offset from <x,y>			*/
int was_legal = FALSE;		/* Assume legal is illegal at first.	*/
int opposing();			/* Check if pieces is opponent's.	*/
int follow_trail();		/* Check if trail exists in some dirn.	*/
void flip_trail();		/* Flip all opponent's pieces in trail.	*/
void set_piece();		/* Set value of specific piece.		*/
char get_piece();		/* Get value of specific piece.		*/


/* If the proposed move is to a non-empty square then it is automatically
 * illegal.
 */
if ( get_piece (x, y) != '.' )
	return ( FALSE );


/* We loop around all eight neighbours of the current piece.
 *
 * Note that there is no need in this instance to check whether the coordinates
 * given are off the Board, as that is checked in the opposing() function.
 */
for ( y_off = -1; y_off < 2; y_off++ )
	{
	for ( x_off = -1; x_off < 2; x_off++ )
		{
		/* Don't include the current piece (the one a <x,y>) in this
		 * search.
		 */
		if ( x_off != 0 || y_off != 0 )
			{
			if ( opposing ( x + x_off, y + y_off) )
				{
				/* We have found an adjacent piece which
				 * belongs to the opponent.
				 *
				 * If we find a valid trail of pieces in this
				 * direction then the move is valid, so return
				 * TRUE. Otherwise continue checking other
				 * directions.
				 */
				if ( follow_trail (x, y, x_off, y_off) )
					{
					/* Having found a valid trail of pieces,
					 * we execute the move by flipping any
					 * opponent's pieces in the trail.
					 */
					flip_trail (x, y, x_off, y_off);

					/* Set the (int)was_legal flag to
					 * indicate that this move is a legal
					 * one.
					 */
					was_legal = TRUE;
					};
				};
			};
		};
	};

/* Return a flag indicating whether this move was a legal one.
 */
return ( was_legal );
};


/*******************************************************************************
follow_trail()		-	Given a position on the Board (x, y), this
				function attempts to follow a trail of pieces
				in the direction specified.

				If the trail consists of an unbroken line of
				pieces belonging to the opponent of the current
				(int)player followed by a piece belonging to
				the current (int)player then TRUE is returned,
				otherwise FALSE.

				The direction is specified as a pair of offsets
				(int x_dirn and y_dirn) to be successively added
				to the <x,y> coordinates.
*******************************************************************************/

int follow_trail ( x, y, x_dirn, y_dirn )
int x, y;			/* Coordinates of start of trail.	*/
int x_dirn, y_dirn;		/* Direction of trail.			*/
{
int opposing();			/* Check if piece belongs to opponent.	*/
char get_piece();		/* Get value of specific piece.		*/


/* Continue moving in the direction given by <x_dirn, y_dirn> until we reach
 * a piece which does not belong to the opponent of the current (int)player.
 *
 * This is a do{}while loop since we must move one square in the required
 * direction before we can make the first test.
 */
do	{
	x += x_dirn;
	y += y_dirn;
	}
	while ( opposing (x, y) );


/* Check whether we have reached the edge of the Board.
 * If so, this trail is not a good one, and so return FALSE.
 */
if ( x < 0 || x > 7 || y < 0 || y > 7 )
	return ( FALSE );


/* Check if the piece at the end of the trail is an empty square.
 * If so, this trail is not a good one (it should end in a piece owned by the
 * current (int)player), and so return FALSE. Else, return TRUE (trail valid).
 */
if ( get_piece (x, y) == '.' )
	return ( FALSE );
else
	return ( TRUE );
};


/*******************************************************************************
flip_trail()		-	Given a position on the Board (x, y), this
				function attempts to follow a trail of pieces
				in the direction specified.

				A trail consists of an unbroken line of pieces
				belonging to the opponent of the current
				(int)player, followed by a piece belonging to
				the current (int)player.

				Every one of the opponents pieces in the trail
				is flipped over to become a piece belonging to
				the current (int)player.

				The direction is specified as a pair of offsets
				(int x_dirn and y_dirn) to be successively added
				to the <x,y> coordinates.

				Finally, note that this function assumes that
				the trail to be flipped both exists and is a
				valid one, having been previously checked by
				follow_trail().
*******************************************************************************/

void flip_trail ( x, y, x_dirn, y_dirn )
int x, y;			/* Coordinates of start of trail.	*/
int x_dirn, y_dirn;		/* Direction of trail.			*/
{
int opposing();			/* Check if piece belongs to opponent.	*/
void set_piece();		/* Set value of specific piece.		*/


/* Continue moving in the direction given by <x_dirn, y_dirn> until we reach
 * a piece which does not belong to the opponent of the current (int)player,
 * which marks the end of the trail.
 *
 * This is a do{}while loop since we must move one square in the required
 * direction before we can make the first test.
 */
do	{
	set_piece ( x, y, piece[player] );	/* Flip the piece	*/

	x += x_dirn;
	y += y_dirn;
	}
	while ( opposing (x, y) );
};


/*******************************************************************************
opposing()	-	Takes as arguments the coordinates of a piece on the
			Board ( int x, int y ).

			Returns TRUE if there is a piece at coordinates <x,y>
			which does not belong to (int)player.
*******************************************************************************/

int opposing ( x, y )
int x, y;			/* Coordinates of piece to check.	*/
{
char thispiece;			/* Holds piece at position <x,y>.	*/
char get_piece();		/* Get value of specific piece.		*/


/* If this piece is off the Board then return FALSE automatically.
 */
if ( x < 0 || x > 7 || y < 0 || y > 7 )
	return ( FALSE );

thispiece = get_piece (x, y);		/* Get piece at position  <x,y>	*/


if ( thispiece != piece[player]  && thispiece != '.' )
	return ( TRUE );
else
	return ( FALSE );
};


/*******************************************************************************
init()		-	Initialises global variables.
*******************************************************************************/

void init()
{
void setup_board();			/* Set up Board for a new game.	*/


/* The major variable is the Board itself. We use malloc() to obtain a block
 * of memory 8*8 bytes long, room for an 8x8 Othello Board.
 */
board = (char *)malloc ( (long)(8 * 8) );

/* You should always check the value of the pointer returned from malloc()
 */
if ( board == NULL )
	end_othello = 1;
else
	setup_board();
};


/*******************************************************************************
setup_board()		-	Setups a blank Board ready for a new game.
*******************************************************************************/

void setup_board()
{
int x;				/* Looping variable.			*/
void set_piece();		/* Set value of specific piece.		*/
void show_board();		/* Displays Othello Board.		*/


/* First move of the game goes to player zero.
 */
player = 0;

for ( x = 0; x < 64; x++ )
	*(board + x) = '.';	/* An empty square is denoted by '.'	*/


/* Othello starts off with the central four pieces already on the Board.
 */
set_piece ( 3, 3, piece[0] );
set_piece ( 3, 4, piece[1] );
set_piece ( 4, 3, piece[1] );
set_piece ( 4, 4, piece[0] );


show_board();			/* Display the Othello Board		*/
};


/*******************************************************************************
get_piece()		-	Returns the value of the piece at position
				(int)x on line (int)y of the Board.

				The value returned is a char (a member of the
				char piece[] array) indicating which player's
				piece is at this square, or '.' if the
				square is empty.
*******************************************************************************/

char get_piece ( x, y )
int x, y;			/* Coordinates of square to check.	*/
{
/* Note the use off offsets with the (char *)board pointer to address an
 * individual element of the memory block.
 */
return ( *(board + (8 * y) + x) );
};


/*******************************************************************************
set_piece()		-	Actually change the piece at position (int)x on
				line (int)y of the Board to a new piece, given
				by (char)newpiece .
*******************************************************************************/

void set_piece ( x, y, newpiece )
int x, y;			/* Coordinates to place new piece.	*/
char newpiece;			/* New value of piece.			*/
{
/* Change the Board to reflect the player's move.
 */
*(board + (8 * y) + x) = newpiece;
};


/* End of File OTHELLO2.C */
