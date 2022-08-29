/* Sample program 4.5 in C:   Velocity value as Tone frequency */


# include <geminit.h>

int status, tonh, velocity;

main()   
{
openwork(); printf("\33E");
   printf("  The velocity (loudness) of the key played is translated\n");
   printf("   to pitch (frequency) and played back.  \n");
   printf("   (If there is no Synhti, there is no action!)\n");
   printf("    To terminate, strike any key \n\n");

   while (bios(1,2)!=-1) 
   {  if (bios(1,3)==-1)
      { status=bios(2,3)&0xff; 
        if ((status&144)==144||(status&128)==128) 
         {  tonh=bios(2,3); 
            velocity=bios(2,3); 

                                         /* generate a tone               */
            bios(3,3,status);            /* Start or stop a tone          */
            bios(3,3,velocity);          /* The old generator setting     */
                                         /* changes to new tone           */
            bios(3,3,velocity);          /* And also the amplifier.       */

         }
      }
   }

closework();
}

