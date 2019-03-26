/* Example1.c: Prints the number of vowels in a word */

#include "stdio.h"

int vcount;    /* Declare a variable of type integer called
                  "vcount" */

main()    /* Program starts here! */
{
    do_count();    /* call function "do_count" */
    printf("There are %d vowels in the word\n", vcount);
                   /* print out the result */
    return 0;      /* program finished OK */
}

do_count() /* count the vowels */
{
    int c;    /* temporary variable to store each
                 character read */

    vcount = 0;    /* initialise vowel count */

    c = getchar(); /* get the first character */

    while ( (c>='a') && (c<='z') ) {
        if ( (c=='a') || (c=='e') || c=='i' || c=='o' ||
             (c=='u') ) {

             vcount = vcount+1;  /* one more vowel found */
        }
        c = getchar();
    }
}
