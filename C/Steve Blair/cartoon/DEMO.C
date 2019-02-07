/* Demo program for the Cartoonist     */
/* by Steve Blair                      */
/*                                     */ 
/* (c) 1987 by Antic Publishing, Inc.  */
/*                                     */
/* Developed for Alcyon C              */

#include  "gemdefs.h"
#include  "osbind.h"

extern    int  init();
extern    long do_raster();
extern    int  load_sprite();

struct
     {
          long addr;
          int  word_length;
          int  byte_length;
          int  width;
          int  height;
          int  new_x;
          int  new_y;
          int  x;
          int  y;
          char new;
          char enable;
          char plane;
          char frame;
          char next_frame;
          char advance_frame;
          char last_frame;
          char filler;
     }    raster[16];

int  dum,
     pal[16],
     old_pal[16],
     x = 3, y = 2,
     ex, ey;

long screen;

int  contrl[12],
     intin[128],
     intout[128],
     ptsin[128],
     ptsout[128],
     handle,
     work_in[12],
     work_out[57];

char pathname[40] = "A:*.ANI",
     filename[40];

main()
{
     appl_init();
     handle = graf_handle(&dum, &dum, &dum, &dum);
     for(dum = 0; dum < 10; work_in[dum++] = 1);
     work_in[10] = 2;
     v_opnvwk(work_in, &handle, work_out);

     for(dum = 0; dum < 16; dum++)
          old_pal[dum] = Setcolor(dum, -1);

     screen = Physbase();

     dum = init(raster);      /* initialize the raster routines */

     do   {
          Setpallete(old_pal);
          pathname[0] = Dgetdrv() + 'A';
          fsel_input(pathname, filename, &dum);
          Dsetdrv(pathname[0] - 'A');
          if(dum)
          {
               graf_mouse(256, 0x0L);
               v_clrwk(handle);

               load_sprite(filename, pal);

               for(dum = 0; dum < 16; dum++)
                    if(raster[dum].addr != 0x0L)
                    {
                         raster[dum].advance_frame = (char)(-1);
                         raster[dum].enable = (char)(1);
                    }

               do   {
                    do_raster(1);       /* 1 = tell GEM where to find */
                                        /* the physical display */
                                        /* 0 = don't tell GEM where to */
                                        /* the physical display */
               }    while(!Bconstat(2));

               v_clrwk(handle);
               graf_mouse(257, 0x0L);
          }
     }    while(dum);

     Setscreen(screen, screen, -1);     /* return to original screen */
     Setpallete(old_pal);               /* and pallete */

     graf_mouse(257, 0x0L);
     v_clsvwk(handle);
     appl_exit();
}
     

