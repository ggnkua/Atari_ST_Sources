/* Don't worry about these # lines - we'll cover these in a future	*/
/* article, okay?							*/
#ifndef IC
#include <osbind.h>		/* Operating System BINDings		*/
#endif IC

/************************************************************************/
/* The first thing we do is set up an array which we will use as our	*/
/* Othello board. Note that since we use char's for the individual	*/
/* squares, and terminate each line with '\0' (the standard C string	*/
/* terminator) then we can display each line using printf() very easily.*/
/*									*/
/* If we had used int's or long's or some other data type then our	*/
/* show_line() function (see below) would have to look more complicated	*/
/************************************************************************/

char board[8][9] =	{
			{ '.', '.', '.', '.', '.', '.', '.', '.', '\0' },
			{ '.', '.', '.', '.', '.', '.', '.', '.', '\0' },
			{ '.', '.', '.', '.', '.', '.', '.', '.', '\0' },
			{ '.', '.', '.', 'X', 'O', '.', '.', '.', '\0' },
			{ '.', '.', '.', 'O', 'X', '.', '.', '.', '\0' },
			{ '.', '.', '.', '.', '.', '.', '.', '.', '\0' },
			{ '.', '.', '.', '.', '.', '.', '.', '.', '\0' },
			{ '.', '.', '.', '.', '.', '.', '.', '.', '\0' }
			};

/* Note that, since we are using a null-terminated array of char's to	*/
/* represent each line of the board, we could have written the above	*/
/* in the form of strings. Have a go at this and I'll give you the	*/
/* answer next month.							*/


/************************************************************************/
/* main()	-	This is the first function to be executed in	*/
/*			each and every C program. A main() function	*/
/*			must always appear in your code.		*/
/************************************************************************/

main()
{
void show_board();		/* Declare function returning nothing	*/


/* Display the Othello board.						*/
show_board();


printf ( "\n\nPress a key" );
Bconin ( 2 );				/* Wait for a key press		*/
};


/************************************************************************/
/* show_board()		-	Displays the Othello board.		*/
/*									*/
/*				This function takes no arguments, hence	*/
/*				the "()" after its name, and returns	*/
/*				no values, hence the "void" in front.	*/
/************************************************************************/

void show_board()
{
int line;				/* Declare int used for line No	*/
int show_first_line();			/* Declare function returns int	*/
void show_next_line();			/* Declare function, returns	*/
					/* nothing, but see below.	*/

printf ( " ________ \n" );

line = show_first_line();		/* Display the first line	*/


/* We'll deal with loops like the while() loop next month, but here is	*/
/* simple while() loop for you to look at. If I told you that this	*/
/* repeats the "show_next_line ( &line );" statement until it reachs	*/
/* the bottom of our board, could you work out what the syntax of a	*/
/* while() loop is? The answer will be given in next month's column.	*/

while ( line < 7 )
	show_next_line ( &line );	/* Note pointer usage		*/

printf ( " ÿÿÿÿÿÿÿÿ \n" );
};


/************************************************************************/
/* show_first_line()	-	Takes no arguments, just displays the	*/
/*				First line of the Othello board and	*/
/*				Returns the line number of that line.	*/
/************************************************************************/

int show_first_line()		/* Declare type of thing to be returned	*/
{
int foo = 0;			/* Line number in the board		*/
void show_line();		/* Display a line of the Othello board	*/

show_line ( foo );		/* Display this line of the board	*/

return ( foo );			/* Return the line number.		*/
};


/************************************************************************/
/* show_next_line()	-	Takes a single argument which is a	*/
/*				pointer to an int which holds the	*/
/*				number  of the current line of the	*/
/*				Othello board. It then calculates and	*/
/*				displays the following line.		*/
/*									*/
/*				Note the usage of a pointer to the line	*/
/*				number, which removes the need to	*/
/*				explicitly return a value.		*/
/************************************************************************/

void show_next_line ( x )	/* Declare that function returns nothing*/
int *x;				/* Declare type of argument to function	*/
{
void show_line();		/* Display a line of the Othello board	*/

*x = *x + 1;			/* Get the number of the next line	*/

show_line ( *x );		/* Display this line of the board	*/
};


/************************************************************************/
/* show_line()		-	This function takes a single argument	*/
/*				(int x) and displays that line of the	*/
/*				Othello board.				*/
/*									*/
/*				No values are returned (hence the void)	*/
/************************************************************************/

void show_line ( x )		/* Declare nothing returned by function	*/
int x;
{
/* Display line (int x) of the Othello board.				*/
printf ( "|%s|\n", &board[x][0] );

/*----------------------------------------------------------------------*/
/* Note that we have used a rather odd-looking format to describe the	*/
/* line of our board which we wish to display ("&board[x][0]").		*/
/*									*/
/* What this means is that we are taking the address of the first char	*/
/* on the x'th line of the array "board". Several tutorials may tell	*/
/* you that we could use simply "board[x]" here instead. That is wrong.	*/
/* Or rather, "board[x]" would work on many C compilers, but can cause	*/
/* odd problems on many others. I use this format both for this reason	*/
/* (it makes the code more portable) and also because this format makes	*/
/* it abundantly clear that what we are dealing with is a pointer into	*/
/* and array, rather than a simple array. As a result, it is far easier	*/
/* (to my mind) to see what the code is doing, and so easier to debug.	*/
/*----------------------------------------------------------------------*/
};
