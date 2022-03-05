
/* MOLLY.C: Atari ST graphics demo for any resolution */
/* by Tim Victor and Philip Nelson, October, 1986     */

#include <osbind.h>

int handle;
int input[11],output[57];
int intin[100],intout[100],ptsin[100],ptsout[100],contrl[12];
int width,height,colors;

int xlate[] = {               /* Translate VDI colors to hardware */
     0,2,3,6,
     4,7,5,8,
     9,10,11,14,
     12,15,13,1     
     };

int pal[] = {                 /* Palette for color cycling        */
     0x700,0x720,0x750,0x770,
     0x370,0x070,0x072,0x075,
     0x077,0x037,0x007,0x207,
     0x507,0x707,0x703
     };

main()
{
     int i,rez,style;
     int draw_tone,draw_color;
     int pal_phase,pal_tone;
     int pts[4],savepal[16];
     int xpos,ypos,rad;
     int xdir,ydir,rdir;
     int most = 20;

     for (i=0;i<10;i++)
          input[i] = 1;
     input[10] = 2;

     handle = 1;
     v_opnvwk(input,&handle,output); /* Open virtual workstation */
     v_hide_c(handle);               /* Hide mouse */
     
     width = output[0];     /* Current workstation width */
     height = output[1];    /* Current height */
     colors = output[13]-1; /* Number of colors not counting backgrnd */

     pts[0]=pts[1]=0;
     pts[2]=width;
     pts[3]=height;
     vs_clip(handle,1,pts);        /* Turn on clipping */

     /* Save current color palette */
     for(i=0;i<16;i++) savepal[i] = Setcolor(i,-1);

     Setcolor(0,0);                /* Black background           */

     if(colors == 1)    /* Number of colors indicates resolution */
       {                /* Make adjustments if in monochrome     */
       most = 30;                  /* Bigger maximum circle      */
       vsf_interior(handle,2);     /* Select pattern for fill    */
       style = 0;                  /* First style                */
       vsf_style(handle,1);        /* Select style_index 1       */
       }

     while (1)                     /* Infinite loop */
     {
     vsf_color(handle,0);
     v_bar(handle,pts);            /* Clear screen */

     pal_phase=0;                  /* Color1 is tone0 */
     draw_tone=0;                  /* Draw circles in tone0 */
     rad=3;
     rdir=1;

     if(colors == 1) {           /* Rotate fill pattern if in mono */
       if(++style > 22) style = 1;
       vsf_style(handle,style);
       }

     /* Set random initial position and velocity */
     xpos= (unsigned int) Random() % (width - 2*rad) + rad;
     ypos= (unsigned int) Random() % (height - 2*rad) + rad;

     if ((xdir = (int) Random() % 7) == 0) xdir=1;
     if ((ydir = (int) Random() % 7) == 0) ydir=1;

     while(!Bconstat(2))           /* Loops until a key is pressed */
     {
          if (--pal_phase < 0)
          {
                pal_phase = colors;
                if (++draw_tone == colors) draw_tone=0;
          }

          if (pal_phase < colors)       /* Rotate color palette */
               for (i=0, pal_tone=pal_phase; i<colors; i++)
               {
                    if (++pal_tone == colors) pal_tone=0;
                    Setcolor( i+1, pal[pal_tone]);
               }

          if ((draw_color = draw_tone-pal_phase+1) < 1)
               draw_color += colors;
          vsf_color(handle,xlate[draw_color]);
          v_circle(handle,xpos,ypos,rad);

          if ((xpos+=xdir) + rad >= width && xdir>0) xdir *= -1;
          if ((xpos - rad) < 1 && xdir<0) xdir *= -1;
          if ((ypos+=ydir) + rad >= height && ydir>0) ydir *= -1;
          if ((ypos - rad) < 1 && ydir<0) ydir *= -1;

          rad += rdir;
          if (rad == 3 || rad == most) rdir *= -1;

     } /* End while */

     if ((Bconin(2) & 0x7f) == 13) break;    /* Quit if CR pressed */

     } /* end other while */

     v_show_c(handle,0);           /* Bring back the mouse */
     v_clsvwk(handle);             /* Close workstation    */

     /* Restore original palette */
     for(i=0;i<16;i++) Setcolor(i,savepal[i]);  

} /* End main */

