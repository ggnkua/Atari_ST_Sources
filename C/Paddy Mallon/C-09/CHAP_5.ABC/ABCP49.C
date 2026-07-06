/*  ABC p49       eg 5.4              */
/*  do                                */
/*  tested and working     25/11/86   */       


#include <stdio.h>
int ticks = 200;
FILE *fptr,*fptr2;

main()
     {
     int kount;
     char ch;

/* A data file must be set up for this program to process.
   If you do not want to set one up using 1st_word then take the comment
   marks (/*) from around the following code and this will do the 
   business.
*/

/*     fptr2 = fopen("text2.dat","w");      
     if(fptr2 == NULL)                     
          {printf("error on open 2\n");}   
     else                                           
          {fprintf(fptr2,"computer programmer\n"); 
           fclose(fptr2);
          }
 */    
     fptr = fopen("text2.dat","r");

     if ( fptr == NULL)
          {    printf("error on open file\n");}
     else
     {
     kount = syllables();
     printf("kount = %d\n",kount);
     fclose(fptr); 
     }

  
     delay(ticks);
     }


syllables()
     {    char ch;
          int changes =0 ,previousvowel=0;

          do
               {
                  ch = getc(fptr);
                    if (vowel(ch))
                         {    
                          if ( !previousvowel) changes++;
                              previousvowel = 1;
                         }
                    else if (consonant(ch)) previousvowel = 0;
               }
          while ( ch != '\n');
          return(changes);
     }
vowel(ch)
          char ch ;
     {
          switch(ch)
               {
                   default: return(0);

                   case 'u': case 'U':return(1);
                   case 'a': case 'A':return(1);
                   case 'e': case 'E':return(1);
                   case 'i': case 'I':return(1);
                   case 'o': case 'O':return(1);
               }
     }
consonant(ch)
          char ch;
     {
          switch(ch)
               {
                   default: return(1);

                   case 'u': case 'U':return(0);
                   case 'a': case 'A':return(0);
                   case 'e': case 'E':return(0);
                   case 'i': case 'I':return(0);
                   case 'o': case 'O':return(0);
               }
     }
