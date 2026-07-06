/*  ABC p65  eg 7.3                */
/*    fill array with spaces       */
/*    only one dimensional arrays implemented in GST C.          */
/*    This can be overcome using an index into the table(letter)
      with an offset following it ie.  index[row][col]           */
/*    tested and working    5/12/86                              */

#include <stdio.h>
#define ROWMAX 7
#define COLMAX 5

int ticks = 200;
char  *index[ROWMAX];
/* This will not work in GST C
               char letter[ROWMAX][COLMAX];
*/
char letter[35];

main()
     {
     int row,col;

/* ****** must add this to simulate 2 dim array***********************/

     int i;
     for (i=0; i<ROWMAX; i++)
          index[i]=&letter[COLMAX*i];

/******* array can now be accessed using:      index[a][b]; **********/

          for (row= 0;row<ROWMAX;row++)
               for (col=0;col<COLMAX;col++) index[row][col]='z';

          for (row=0;row<ROWMAX;row++) 
            { 
               for (col=0;col<COLMAX;printf("%c",index[row][col++]));
               printf("\n");
           
            }
          printf("x\n");

     delay(ticks);
     }
