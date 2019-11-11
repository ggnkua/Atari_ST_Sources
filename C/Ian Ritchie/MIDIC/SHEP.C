

/*------------------------------------------------------------------------*/
/*----------------------- SHEPARD SCALE ---------------------------------*/
/*------------------------------------------------------------------------*/


#include <osbind.h> 
                             
unsigned char x, 
              vel = 120;                  /* maximum velocity */
int z;
 
main()                                   /* Main control loop */
{
initialise();
 
while (!Bconstat(2))                     /* look for a keypress */
{
     for (x = 0; x < 12; x++)         /* Play one cycle of scale*/
     {
          Note_On(x+48, x*10);
          Note_On(x+60, vel);
          Note_On(x+72, vel-x*10);

          for (z = 0; z < 90000; z++);          /* timing loop */

          Note_Off(x+48);
          Note_Off(x+60);
          Note_Off(x+72);
     }
}

initialise();

}

 
Note_On(m, v)                                /* Play a midi note */
unsigned char m, v;
{
     Bconout(3, 144);
     Bconout(3, m);
     Bconout(3, v);
}
 
 
Note_Off(m)                       /* Stop a midi note */
unsigned char m;
{
     Bconout(3, 144);
     Bconout(3, m);
     Bconout(3, 0);
}
 
 
 
 
 
initialise()
{
int x;
 
     while (Bconstat(3))
     {
          Bconin(3);                   /* Clear midi input buffer */
     }
     for (x = 0; x < 128; x++)         /* send all notes off */
     {
          Bconout(3, 144); Bconout(3, x); Bconout(3, 0);
     }
}
