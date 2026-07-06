# include <stdio.h>
# define TEXT "Your full name is"

main()
{
char ch;
char fname [20], lname [20];

printf ( "Enter your first name: " );
scanf ( "%s", fname );
printf ( "\n\n" );
printf ( "Hi, %s!  Enter your last name: ", fname );
scanf ( "%s", lname );
printf ( "\n\n" );
printf ( "%s %s %s.\n\n", TEXT, fname, lname );
ch = getchar();
ch = getchar();
}
