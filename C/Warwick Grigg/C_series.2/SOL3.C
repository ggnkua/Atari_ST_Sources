/* sol3.c: Prints the number of vowels in each word */

#include "stdio.h"

int vcount;    /* Declare a variable of type integer called
                  "vcount" */

int wcount;    /* Declare a variable of type integer called
                  "wcount" */

main()    /* Program starts here! */
{
    do_count();    /* call function "do_count" */
    return 0;      /* program finished OK */
}

do_count() /* count the vowels */
{
    int c;    /* temporary variable to store each
                 character read */

    vcount = 0;    /* initialise vowel count */
    wcount = 0;    /* initialise word count */

    c = getchar(); /* get the first character */

    while ( ((c>='a') && (c<='z')) || (c=='\n') ) {
	if (c=='\n') {
	    wcount = wcount+1;
	    printf("There are %d vowels in word %d\n", vcount, wcount);
                   /* print out the result */
	    vcount = 0;
	}
        if ( (c=='a') || (c=='e') || c=='i' || c=='o' ||
             (c=='u') ) {

             vcount = vcount+1;  /* one more vowel found */
        }
        c = getchar();
    }
}
