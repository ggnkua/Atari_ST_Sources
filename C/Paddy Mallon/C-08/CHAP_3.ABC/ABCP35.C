/*   ABC p35/36  eg 3.2                 */
/*   file I/O                           */
/*                                      */
/*  Finally got this to work - the problem was that in the line 
                    FILE *fptr,*fopen();
     *fopen() was being re-initialised by this declaration
     and was not  then being linked  in to the program properly.

     By leaving out *fopen() ,this cured the problem.
     tested and working 23/11/86                                      */

         #include stdio.h
         #define gap fprintf(fptr,"\n\n\n\n\n");

         #define allstars fprintf(fptr,"*****\n");
         #define endstars fprintf(fptr,"*   *\n");
         #define midstars fprintf(fptr,"  *  \n");
         FILE *fptr;
 
     main()

           {   
               fptr = fopen("results.text","w");
               if ( fptr == NULL)
                    {   printf("error on opening file \n"); }
               else
                    {
                         bigH(); gap;
                         bigI(); gap;
                         fclose(fptr);
                    }                    

           }

     bigH()
          {   
               endstars;endstars;endstars;
               allstars;
               endstars;endstars;endstars;
          }
     bigI()
          {    
               allstars;
               midstars; midstars;midstars;
               midstars; midstars;
               allstars;
          }          



