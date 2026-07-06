/*  ABC p51  eg 5.5                 */
/*  continue statment and  passes() */
/*  tested and working 27/11/86     */


#include <stdio.h>
int ticks = 200;
int sum,n,i,totpas;
FILE *fptr;
main()
     {
/*   A file (TEXT3.DAT) must be set up containing first the number of
     marks in the file, and then the actual marks which are to be graded.
     Do this using 1st_word or set up a file as outlined in the last 
     program.
*/
     fptr = fopen("TEXT3.DAT","r");

     if ( fptr == NULL)
          {    printf("error on open file\n");}
     else
      {  
          printf("total passes = %d\n",passes());
          
          fclose(fptr); 
      }         

     delay(ticks);
     }

passes()
     { 
     char g;
     int listsize,mark,m,psum=0;

     if (fscanf(fptr,"%d",&listsize)< 1) return(-1);

     for (m=1;m<=listsize;m++)
          {
           if (fscanf(fptr,"%d",&mark)>0)
               { 
                    if ((g=grade(mark)) == NULL) continue;
                    if (g == 'e') continue;
                    printf("grade = %c\n",g);
                    psum++;
               }
           else 
               return(-1);
          }
     return(psum);
     }

grade(mark)
     int mark;
     {
          char g ;
          switch(mark/20)
               {
                   case 0:  g = 'e'; break;
                   case 1:  g = 'd'; break;
                   case 2:  g = 'c'; break;
                   case 3:  g = 'b'; break;
                   case 4:  g = 'a'; break;
               }
          return(g);
     }
