/****************************************************************/
/* BOUNCE.C       Draw Kinetic Box Art                          */
/*                                                              */
/* This program is similiar to LINES1.C. This program draws     */
/* boxes in colour and changes the colour palette to create     */
/* visual effects.                                              */
/****************************************************************/



/***************************************************************/
/*             System Header Files & Constants                 */
/***************************************************************/


#include  <stdio.h>                    /* Standard IO */
#include  <osbind.h>                   /* GEMDOS routines */
#include  <gemdefs.h>                  /* GEM AES */
#include  <obdefs.h>                   /* GEM constants */

#define  FALSE     0
#define  TRUE      !FALSE


/**********************************************************/
/*             GEM Application Overhead                   */
/**********************************************************/



/* Declare global arrays for VDI. */
typedef     int    WORD;               /* WORD is 16 bits */

WORD        contrl[12],                /* VDI control array */
            intout[128], intin[128],   /* VDI input arrays */
            ptsin[128], ptsout[128];   /* VDI output arrays */

WORD        screen_vhandle,            /* virtual screen workstation */
            screen_phandle,            /* physical screen workstation */
            screen_rez,                /* screen resolution 0,1, or 2 */
            color_screen,              /* flag if colour monitor */
            x_max,                     /* maximum x screen co-ordinate */
            y_max;                     /* maximum y screen co-ordinate */


/*********************************************************/
/*                                                       */
/*        Application specific Data                      */
/*                                                       */
/*********************************************************/


/* Constant values for drawing area */
int  x_lower,                       /* lowest x value */
     y_lower,                       /* lowest y value */
     x_upper,                       /* highest x value */
     y_upper;                       /* highest y value */

WORD pal_save[16],                 /* current palette */
     pal_wheel[16];                /* rotating palette */

WORD max_color = 16;

/*********************************************************/
/*                                                       */
/*        GEM-related Functions                          */
/*                                                       */
/*********************************************************/

WORD open_vwork(phys_handle)
WORD phys_handle;
/*********************************************************/
/*                                                       */
/* Function: This function opens a virtual workstation.  */
/*                                                       */
/* Input:  phys_handle = physical workstation handle     */
/*                                                       */
/* Output: Returns handle of workstation.                */
/*                                                       */
/*********************************************************/
{
WORD work_in[11],
                    work_out[57],
                     new_handle;       /* handle of workstation */
int                  i;

             for (i = 0; i < 10; i++)  /* set for default values */
                  work_in[i] = 1;           
             work_in[10] = 2;          /* use raster co-ordinates */
             new_handle = phys_handle; /* use currently open workstation */
             v_opnvwk(work_in, &new_handle, work_out);
             return(new_handle);
}
set_screen_attr()
/***********************************************************/
/*                                                         */
/*  Function: Set global values about screen.              */
/*                                                         */
/*  Input: None. Uses screen_vhandle.                      */
/*                                                         */
/*  Output: Sets x_max, y_max, color_screen, & screen_rez. */
/*                                                         */
/***********************************************************/
{
WORD work_out[57];

            vq_extnd(screen_vhandle, 0, work_out);
            x_max = work_out[0];
            y_max = work_out[1];
            screen_rez = Getrez();    /* 0 = low, 1 = medium , 2 = high */
            color_screen = (screen_rez < 2);   /* mono 2, color 0 or 1 */
}


/**********************************************************/
/*                                                        */
/*                Application Functions                   */
/*                                                        */
/**********************************************************/

long Rnd_rng(low, hi)
long low, hi;
/*******************************************************************/
/* Function : Generate a random number between lo & hi inclusive . */
/*                                                                 */
/* Input :    low = lowest value in range.                         */
/*            hi  = highest value in range.                        */
/*                                                                 */
/* Output :   Returns random number.                               */
/*******************************************************************/
{
     hi++;                   /* include high value in range */
     return( (Random() % (hi - low)) + low);
}


change_color()
/**********************************************************/
/* Function : Rotates color palette.                      */
/*                                                        */
/* Input    : None. Uses pal_wheel[]                      */
/*                                                        */
/* Output   : None.                                       */
/*                                                        */
/* Notes    : Color index 0 is not changed. Generally you */
/*            do not change this index because it is used */
/*            as the background color.                    */
/**********************************************************/
{
register       i;
register  WORD temp;


     temp = pal_wheel[1];            /* save first entry */
     for(i = 2; i < max_color; i++)  /* shift all entries down */
          pal_wheel[i-1] = pal_wheel[i];
     pal_wheel[max_color-1] = temp;  /* put first into last */
     Setpalette(pal_wheel);          /* change palette */
     return;
}

draw_boxes()
/**********************************************************/
/* Function : Do kinetic box art.                         */
/*                                                        */
/* Input    : None.                                       */
/*                                                        */
/* Output   : None.                                       */
/**********************************************************/
{

#define   BOX_MAX   40
#define   BOX_MIN   4

WORD box[4],                         /* array for box corners */
     bcx, bcy,                       /* center co-ordinates */
     bsize,                          /* current box size */
     bdx, bdy,                       /* deltas for box */
     bdsize;                         /* delta for size */

WORD cur_color;                      /* current drawing color */

do                                   /* begin screen control loop */
{
     v_clrwk(screen_vhandle);         /* clear screen */

/* Initialize line corners */
     bsize     = BOX_MIN;
     bdsize    = 4;
     bcx  = Rnd_rng( (long)(x_lower+bsize), (long)(x_upper-bsize));
     bcy  = Rnd_rng( (long)(y_lower+bsize), (long)(y_upper-bsize));
     bdx       = Rnd_rng( -10L, 10L);
     bdy       = Rnd_rng( -10L, 10L);
     
     cur_color = 1;                /* start color index */

/* Box drawing loop begins here */
do
{
     box[0] = bcx - bsize;    /* set corner co-ordinates */
     box[1] = bcy - bsize;
     box[2] = bcx + bsize;
     box[3] = bcy + bsize;
                              /* set color to draw */
     vsf_color(screen_vhandle, cur_color);
     cur_color++;             /* set new color */
     if (cur_color >= max_color)
          cur_color = 1;
     vr_recfl(screen_vhandle, box);     /* Draw box */
          
/* Calculate new size */
     bsize += bdsize;
    
/* check ranges */
     if (bsize < BOX_MIN)
     {
          bsize = BOX_MIN;
          bdsize = -bdsize;
     }
     if (bsize > BOX_MAX)
     {
          bsize = BOX_MAX;
          bdsize = -bdsize;
     }
/* calculate new corners */
     bcx += bdx;
     bcy += bdy;
         
     if ((bcx - bsize) <= x_lower)
     {
          bcx = x_lower + bsize;
          bdx = -bdx;
          }
          if ((bcx + bsize) >= x_upper)
          {
               bcx = x_upper - bdsize;
               bdx = -bdx;
          }
               
          if ((bcy - bdsize) <= y_lower)
          {
               bcy = y_lower + bsize;
               bdy = -bdy;
          }
          if ((bcy + bsize) >= y_upper)
          {
               bcy = y_upper - bsize;
               bdy = -bdy;
          }
               
          /* change colors */
          change_color();
     } while ( !Cconis() );   /* check if key pressed */
} while ( (Crawcin() & 0x7F) != 27);   /* escape key exits */
     return;
}
     
 
/**********************************************************/
/*                                                        */
/*                      Main Program                      */
/*                                                        */
/**********************************************************/

main()
{
int    ap_id;                     /* application init verify */
int    i;

WORD gr_wchar, gr_hchar,          /* values for VDI handle */
            gr_wbox, gr_hbox;

/**********************************************************/
/*                                                        */
/*               Initialize GEM Access                    */
/*                                                        */
/**********************************************************/

   
   ap_id = appl_init();           /* Initializes AES routines */
   if (ap_id < 0)                 /* no calls can be made to AES */
   {                              /* use GEMDOS */
        Cconws("***> Initialization Error. <***\n");
        Cconws("Press any key to continue.\n");
        Crawcin();
        exit(-1);                 /* set exit value to show error */
   }
     
     
   screen_phandle =               /* Get handle for screen */
        graf_handle(&gr_wchar, &gr_hchar, &gr_wbox, &gr_hbox);
   screen_vhandle = open_vwork(screen_phandle);
   set_screen_attr();             /* Get screen attributes */

/*********************************************************/
/*     Application Specific Routines                     */
/*********************************************************/

                                  /* replace used for multicolors */
     vswr_mode(screen_vhandle, MD_REPLACE);

/* set boundaries */
     x_lower = 10;
     y_lower = 10;
     x_upper = x_max - 10;
     y_upper = y_max - 10;
     
/* load palettes */
     for (i = 0; i < 16; i++)
     {
          pal_save[i] = Setcolor(i, -1);
          pal_wheel[i] = pal_save[i];
     }

/* start program */
     draw_boxes();                 /* Do box art */
     Setpalette(pal_save);         /* restore palette */
     

/*********************************************************/
/*    Program Clean-up and Exit                          */
/*********************************************************/
     
     
     v_clsvwk(screen_vhandle);    /* close workstation */
     appl_exit();                 /* end program */
}

/*********************************************************/

