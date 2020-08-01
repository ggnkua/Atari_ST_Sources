/* @(#)hello.c, SozobonX examples
 * 
 * hello world 
 * sample program for XdLibs library and SozobonX distribution
 */

#include	<stdio.h>

	/* program identification
	 *
	 * 'ident' command should be able to print some id strings extracted
	 * from your program.
	 * The Patchlevel strings form the library is always included.
	 * You can add of course some more strings:
	 */
#define VERSION "1.0"

static char Ident_prog[] = 
	"$" "Id: hello, v " VERSION " " __DATE__ " SozobonX $";

	/*
	 * You can use similiar strings in your source files and programs.
	 * For strings to be included in the binary you can use the
	 * string cat feature of hcc, to prevent ident to tell something
	 * wrong about the source file.
	 * "$" "Id: <name>,v <version> <date> $"
	 * but
	 * $Id: hello.c, v1.0, SozobonX examples
	 */


/* 
 * The most common way for the identification of a file by the user
 * is the 'what' command. It prints all the strings like the first
 * one in this file. To inlude such a string in the binary just define a
 * variable like following one:
 * "@(" "#)<name>,v <version> <date> <company, etc>"
 */
static char this_is[] = 
			"@(" "#)hello.tos, v" VERSION " " __DATE__ " SozobonX examples";


	/* the following variables are for usage in your program,
	 * e.g in error messages:
	 * fprintf(stderr, "%s: <the message>\n", myname);
	 */
char *myname = "hello";
char *mypath = "";

/* They are extraced by the function
 * getmyname()
 * if available.
 * 
 */

char	*getmyname(char *argv[])
{
	char	*p, *s;

	if (argv[0] && **argv) {
		mypath = argv[0];
		p = basename(mypath);
		if (p != mypath) 
			p[-1] = '\0';
		if (s = suffix(p))
			*s = '\0';

		return(p);
	}
	return(myname);
}	/* getmyname	*/



main(int argc, char *argv[])
{

	if (argc)
		myname = getmyname(argv);
				
	printf("\nHello world\n\n");
	
	printf("This is '%s', in path\n\t%s\\ \ncompiled with\n\t%s\n"
		   "on " __DATE__ ", " __TIME__ "\n",
		    myname, mypath, __VERSION__);

	return(0);

}	/* main	*/

