 
/*-------------------------------------------------------------------*/
/*----------------------- Midi Initialisation -----------------------*/
/*-------------------------------------------------------------------*/
 
#include <osbind.h>


main()
{
     initialise();
}
 
initialise()
{
int x;
 
     while (Bconstat(3))               /* test the buffer for data */
     {
          Bconin(3);                   /* Clear midi input buffer */
     }
     for (x = 0; x < 128; x++)         /* send all notes off */
     {
          Bconout(3, 144); Bconout(3, x); Bconout(3, 0);
     }
}
