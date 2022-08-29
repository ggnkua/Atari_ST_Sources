/* Example program No. 4.2 in C */

#include <geminit.h>
int status, toneh, velocity;

main()   
{
openwork();
   printf("    Play a Chord!\n");
   printf("    To terminate hit any key!\n\n");

   while (bios(1,2)!=-1) 
   {  if (bios(1,3)==-1)
      { status=bios(2,3)&0xff; 
        if (status==144||status==128) 
         {  toneh=bios(2,3); 
            velocity=bios(2,3); 
            putchord (4);  
            putchord (7);  
            putchord (12); 
         }
      }
   }

closework();
}

/*------------------- Helper function for sound output --------------------*/

putchord (offset) 
int offset;       
{
   bios(3,3,status);       
   bios(3,3,toneh+offset);  
   bios(3,3,velocity);     
}

