/*--------------------------------------------------------------------*/
/*---------------- HALL OF THE MOUNTAIN KING -------------------------*/
/*--------------------------------------------------------------------*/

#include <osbind.h>

                     
unsigned char note[26] = {0, 2, 3, 5,
                          7, 3, 7, 6, 
                          2, 6, 5, 1,
                          5, 0, 2, 3, 
                          5, 7, 3, 7,
                          12, 10, 7, 3,
                          7, 10};                       /* Note list */
                              
unsigned char time[26] = {1, 1, 1, 1,
                          1, 1, 2, 1,
                          1, 2, 1, 1,
                          2, 1, 1, 1,
                          1, 1, 1, 1, 
                          1, 1, 1, 1,
                          1, 4};                       /* Timing list */
                             
int x, 
    z, 
    modulation, 
    speed = 5000;                                      /* Tempo factor */
 
main()                                           /* Main control loop */
{
modulation = 0;
 
while (!Bconstat(2))
{
     for (x = 0; x < 26; x++)               /* Play one cycle of tune */
     {
          Note_On(note[x]+48+modulation);
          for (z = 0; z < speed*time[x]; z++);         /* timing loop */
          Note_Off(note[x]+48+modulation);
     }
     if (modulation < 36)
     {
     modulation = modulation+7;                   /* Modulate a fifth */
     }
     else modulation = 0;
}

}
 
Note_On(m)                                        /* Play a midi note */
unsigned char m;
{
     Bconout(3, 144);
     Bconout(3, m);
     Bconout(3, 127);
}
 
 
Note_Off(m)                                       /* Stop a midi note */
unsigned char m;
{
     Bconout(3, 144);
     Bconout(3, m);
     Bconout(3, 0);
}
