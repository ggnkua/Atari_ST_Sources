#include <stdio.h>
/* #include <uproto.h> */

#define Num_Elements 255
#define Newline '\n'              /* Newline, white space character         */
#define Tab     '\t'              /* Tab    , white space character         */
#define Space   ' '               /* Space  , white space character         */
#define In    1                   /* in a word                              */
#define Out   0                   /* out of a word                          */
#define True  -1                  /* Flag to return boolean true            */
#define False 0                   /* Flag to return boolean false           */
#define End_chreadable 128        /* Const for max ASCII char to process    */
#define Ch_offset ('a'-'A')       /* ASCII Constant offset from Captial     */

/* Prototype functions                                                      */

void update_char_list(int list[],int chrs);
void print_ch_table(int list[]);
int  white_space_check(int chrs);
int  print_misc(int list[],int start_ch, int fin_ch);
void initialise_array(int array[],int size);
void main(void);

    /* Checks char read if White Space.
     * Returns True if char is white or False if not.                       */
int
white_space_check(int chrs)
{
    /* A flag to hold boolean result of character test.
     * Flag boolean value is returned.                                      */

int white;
    switch(chrs)
    {   /* Constants defined for White space chars.
         * Falling break for White cases
         */
        case Newline: case Tab: case Space:
        white = True;
        break;
        default:
        white = False;
        break;
    }                                    
    return (white);
}


    /* Updates Character count in char array passed                         */
void
update_char_list(int list[],int chrs)
{   /* Use ASCII value of char passed for corresponding position in
    * char array to increment count value of that char.
    */
   list[chrs]++;
}


    /* Initialises an array referenced to, by assigning Null char to each            
     * position in the array.                                               */

void
initialise_array(int array[],int size)
{   /* size=number of elements in array for loop coumter to count too       */
int i;                    /* Counter for each position in the array         */
    for (i=0;i<=size;i++) {
        array[i] = 0;      /* zero array!                  */
    }
}


    /* Accepts text from file/keyboard and displays two tables.
     * 1st table gives counts of initial letters of words in text.
     * 2nd table displays counts of final letters of words in text.
     * Also displays a count of misc chars in text and Number of valid
     * words in the text.                                                   */

void
main(void)
{   /* Initialises variables used                                           */
int fstletword[Num_Elements], /* Inits arrays to hold char counts           */
    lstletword[Num_Elements],
    no_of_words = 0,          /* Keep track of number of words in text      */
    word   = Out,             /* Flag to signify if reading a word or not   */
    lastch = Space,           /* Stores last char read                      */
    ch     = Space;           /* Stores current char read                   */

    /* Clears 1st & last char arrays                                        */
    initialise_array(fstletword,Num_Elements);
    initialise_array(lstletword,Num_Elements);

    /* Reads chars in until end of file cntrl code read                     */

    while (( ch=getchar() ) != EOF) {

    /* Checks char read.  If its not whitespace and were not reading a word
     * then Update 1st char list and set word flag = In (true). Increment
     * number of words read so far                                          */

        if (!white_space_check(ch)) {
            if (word == Out) {
            /* Start of a new word.  Update initial char count.             */
                update_char_list(fstletword,ch);
                no_of_words++;/* Increment number of words read             */
                word = In;    /* Set flag to 'In' a word                    */
            }
        }

     /* Check if not in a word anymore.
      * If new char read is white and lastchar is not and word flag = 'In'
      * Update last char list.                                              */

        else if ((!white_space_check(lastch)) && (word == In)) {
            update_char_list(lstletword,lastch);
            word = Out;       /* reset word flag to 'Out'(false)            */
        }
        lastch = ch;          /* store char read and loop back
                              /* for another.                               */
    }
    /* end of input has been reached                                        */

    printf("\nNo. of Words = %d\n",no_of_words); /* Display number of words
                                                * read.                     */
    print_ch_table(fstletword);  /* Display 1st char table                  */
    print_ch_table(lstletword);  /* Display last char table                 */
}                                /* Also displays misc chars read           */


    /* Displays table of chars and their counts.Takes char array to display */
void
print_ch_table(int list[])
{
int tot = 0,                     /* Keeps track of times char occured       */
    chr = 0,                     /* Loop counter to step through array      */
    Ucase_cnt,                   /* Count value of Upper case char          */
    Lcase_cnt;                   /* Count value of Lower case char          */

    /* Loops through letters A to z, tabulating them & their counts.        */

    for (chr='A';chr<='Z';chr++) {         /* Letters only. No misc         */
        Ucase_cnt = list[chr];             /* Single Upper case char count  */
        Lcase_cnt = list[(chr+Ch_offset)]; /* Single Lower case char count  */

        /* If both Upper & Lower case chars in list have a count then
         * echo them to screen with the total of their counts.              */

        if ( (Ucase_cnt>0) && (Lcase_cnt>0) )
            {
            /* If char is 'B' then chr+Ch_offset is 'b'                     */
            printf("%c/%c\t%d\n",chr,(chr+Ch_offset),(Ucase_cnt+Lcase_cnt));
            }

        /* Only Upper case char has count; echo to screen with count value
         * only.

        else if (Ucase_cnt>0)
            {
            printf("%c\t%d\n",chr,Ucase_cnt);
            }

        /* Only Lower case char has count; echo to screen with count value
         * only                                                             */

        else if (Lcase_cnt>0)
            {
            printf("%c\t%d\n",(chr+Ch_offset),Lcase_cnt);
            }
    }
    /* End of Upper & Lower case letters in alphabet to show.               */

    /* Totals counts of all misc chars with counts and displays as one word */

    tot = tot+print_misc(list,(Space+1),('A'));
    tot = tot+print_misc(list,('Z'+1),('a'));
    tot = tot+print_misc(list,('z'+1),End_chreadable);

    /* If any misc chars with count then they will have been echoed to
     * screen and their total count value echoed too(below).                */

    if (tot>0) {
        printf(" \t%d\n\n",tot); /* echo total count for all misc in limmits */
    }
    /* End of valid misc chars in ASCII set.                                */
}
    /* End of chars to display in tables.                                   */


    /* Echos misc chars with counts to screen as one word.
     * returns total of count value for all misc chars passed.              */

int
print_misc(int list[],int start_ch, int fin_ch)
{   /* Accepts limmits for valid misc chars to be echoed to screen with
     * total count value being returned.                                    */

int misc,    /* Misc char space                                              */
    tot = 0; /* Keeps track of total value of counts for all misc chars      */
    for (misc=start_ch;misc<fin_ch;misc++) {
        if (list[misc]>0) {
           tot+=list[misc];
           printf("%c",misc); /* echo misc char to screen next to last one  */
        }
    }
return (tot);                   /* total count of all misc chars passed in    */
}