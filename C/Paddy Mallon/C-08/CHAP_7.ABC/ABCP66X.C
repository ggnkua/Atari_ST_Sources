/*  ABC p66  eg 7.4                */
/*    arrays as parameters         */
/*    This program had to be changed to implement the 2 dimensional
      array - as this cannot be passed as a parameter in GST C , I 
      have passed an array of pointers to the single dimension array
      "letter[]" . This index can then be used with offsets to simulate
      a 2 dimensional array.                                           */
/*   Tested and working 7/12/86    */


#include <stdio.h>
#define ROWMAX 7
#define COLMAX 5

int ticks = 200;
/* char letter[ROWMAX][COLMAX]; This cannot be used   */
int row,col;
char *index[ROWMAX];
char letter[36];

main()
     {
/* *******must add this to simulate 2 dim array***********************/
   
     int i;
     for (i=0; i<ROWMAX; i++) index[i]=&letter[COLMAX*i];

/*********************************************************************/
/*   fill the array with spaces                                      */

     for (row=0;row<ROWMAX;row++)
          for(col=0;col<COLMAX;index[row][col++]=' ');
/********************************************************************/

     makeH(index);

/********************************************************************/
/*  print the array on screen          */

     for (row=0; row<ROWMAX;row++)
     {
     for (col=0; col<COLMAX; printf("%c",index[row][col++]));
     printf("\n");
     }

/********************************************************************/

     printf("finished\n");
     delay(ticks);
     }

makeH(mat)
     
     char *mat[];
     {
          fillcol(0,mat);
          fillcol(COLMAX-1,mat);
          fillrow(3,mat);
     }

fillrow(row,matrix)
     int row;
     char *matrix[];
     {
          int c;
          for ( c=0; c<COLMAX; matrix[row][c++]='*');
     }

fillcol(col,matrix)
     int col;
     char *matrix[];
     {
          int r;
          for ( r=0; r<ROWMAX; matrix[r++][col]='*');
     }

