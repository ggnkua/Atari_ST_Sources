/*******************************************************/
/*                                                     */
/*    BOUNCE.C - Draw bouncing balls                   */
/*                                                     */
/*    This program demonstrates an animation technique */
/*    using raster operations.                         */
/*******************************************************/
 
 
/*******************************************************/
/*                                                     */
/*    System Header Files & constants                  */
/*******************************************************/
 
 
#include <stdio.h>                  /* Standard IO */
#include <osbind.h>                 /* GEMDOS routines */
#include <gemdefs.h>                /* GEM AES */
#include <obdefs.h>                 /* VDI routines */

 
#define  FALSE     0 
#define  TRUE      !FALSE
 
 
/******************************************************/
/*  GEM Application Overhead                          */
/******************************************************/
 
 
/* Declare global arrays for VDI. */
typedef   int  WORD;                /* WORD is 16 bits */
WORD      contrl[12],               /* VDI control array */
          intout[128], intin[128],  /* VDI input arrays */
          ptsin[128], ptsout[128];  /* VDI output arrays */
        
WORD      screen_vhandle,            /* virtual screen workstation */
          screen_phandle,            /* physical screen workstation */
          screen_rez,                /* screen resolution 0,1, or 2 */
          color_screen,              /* flag if colour monitor */
          x_max,                     /* maximum x screen co-ordinate */
          y_max;                     /* maximum y screen co-ordinate */
        
typedef   struct    mfdbstr          /* GEM data structure */
{
     char  *addr;                    /* address of raster area */
     WORD  wide;                     /* width of raster in pixels */
     WORD  high;                     /* height of raster in pixels */
     WORD  word_width;               /* width of raster in words */
     WORD  format;                   /* standard or device specific */
     WORD  planes;                   /* number of planes in raster */
     WORD  reserv1, reserv2, reserv3;
} MFDB;
 
/*******************************************************/
/*   Application Specific Data                         */
/*******************************************************/
 
 
#define  W_BALL   48                 /* width of ball raster */
#define  H_BALL   48                 /* height of ball raster */
#define  NUM_BALLS 4                 /* number of balls to draw */
 
typedef  struct 
{
     int      x[2];                  /* x co-ordinate for each screen */
     int      y[2];                  /* y co-ordinate for each screen */
     float    dx;                    /* x velocity */
     float    dy;                    /* y velocity */
     int      delay;                 /* release delay timer */
} BALL_REC;
 
char *bitmap0,                      /* screen bitmaps */
     *bitmap1;
    
    
int draw_screen,                    /* 0 or 1; determines which */
     show_screen;                   /* screen to use for drawing */
    
    
BALL_REC  ball[NUM_BALLS];          /* a record for each ball */
 
float     gravity;                  /* acceleration */
 
MFDB ballMFDB,                      /* raster descriptors */
     maskMFDB, 
     scrMFDB[2];                    /* one for each screen */
 
 
/* define shapes */
unsigned short  ball_shape[48][3] = {          /* Line */
    0x0000, 0x0000, 0x0000,         /* 0 */
    0x0000, 0x0ff0, 0x0000, 
    0x0000, 0xffff, 0x0000, 
    0x0003, 0xffff, 0xC000, 
    0x0007, 0xffff, 0xE000, 
    0x001f, 0xffff, 0xf800, 
    0x007f, 0xffff, 0xfe00, 
    0x00ff, 0xffff, 0xff00, 
    0x01ff, 0xffff, 0xff80,          /* 8 */
    0x03ff, 0xffff, 0xffc0, 
    0x07ff, 0xffff, 0xffe0, 
    0x07ff, 0xffff, 0xffe0, 
    0x0fff, 0xffff, 0xfff0, 
    0x0fff, 0xffff, 0xfff0, 
    0x1fff, 0xffff, 0xfff8, 
    0x1fff, 0xffff, 0xfff8, 
    0x3fff, 0xffff, 0xfffc,         /* 16 */
    0x3fff, 0xffff, 0xfffc, 
    0x3fff, 0xffff, 0xfffc, 
    0x3fff, 0xffff, 0xfffc, 
    0x4fff, 0xffff, 0xfff2, 
    0x43ff, 0xffff, 0xffC2, 
    0x40ff, 0xffff, 0xff02, 
    0x401f, 0xffff, 0xf802, 
    0x4001, 0xffff, 0x8002,         /* 24 */
    0x4000, 0x07E0, 0x0002, 
    0x4000, 0x0000, 0x0002, 
    0x4000, 0x0000, 0x0002, 
    0x2000, 0x0000, 0x0004, 
    0x3800, 0x0000, 0x001c, 
    0x3e00, 0x0000, 0x007c, 
    0x3f80, 0x0000, 0x01fc, 
    0x1ff0, 0x0000, 0x0ff8,         /* 32 */
    0x1fff, 0x0000, 0xfff8, 
    0x0fff, 0xffff, 0xfff0, 
    0x0fff, 0xffff, 0xfff0, 
    0x07ff, 0xffff, 0xffE0, 
    0x07ff, 0xffff, 0xffE0, 
    0x03ff, 0xffff, 0xffc0, 
    0x01ff, 0xffff, 0xff80, 
    0x00ff, 0xffff, 0xff00,         /* 40 */
    0x007f, 0xffff, 0xfE00, 
    0x001f, 0xffff, 0xf800, 
    0x0007, 0xffff, 0xe000, 
    0x0003, 0xffff, 0xc000, 
    0x0000, 0xffff, 0x0000, 
    0x0000, 0x0ff0, 0x0000, 
    0x0000, 0x0000, 0x0000, 
    };
   
   
unsigned short ball_mask[48][3] = {            /* Line */
    0x0000, 0x0000, 0x0000,         /* 0 */
    0x0000, 0x0ff0, 0x0000, 
    0x0000, 0xffff, 0x0000, 
    0x0003, 0xffff, 0xc000, 
    0x0007, 0xffff, 0xe000, 
    0x001f, 0xffff, 0xf800, 
    0x007f, 0xffff, 0xfe00, 
    0x00ff, 0xffff, 0xff00, 
    0x01ff, 0xffff, 0xff80,         /* 8 */
    0x03ff, 0xffff, 0xffc0, 
    0x07ff, 0xffff, 0xffe0, 
    0x07ff, 0xffff, 0xffe0, 
    0x0fff, 0xffff, 0xfff0, 
    0x0fff, 0xffff, 0xfff0, 
    0x1fff, 0xffff, 0xfff8, 
    0x1fff, 0xffff, 0xfff8, 
    0x3fff, 0xffff, 0xfffc,         /* 16 */
    0x3fff, 0xffff, 0xfffc, 
    0x3fff, 0xffff, 0xfffc, 
    0x3fff, 0xffff, 0xfffc, 
    0x7fff, 0xffff, 0xfffe, 
    0x7fff, 0xffff, 0xfffe, 
    0x7fff, 0xffff, 0xfffe, 
    0x7fff, 0xffff, 0xfffe, 
    0x7fff, 0xffff, 0xfffe,         /* 24 */
    0x7fff, 0xffff, 0xfffe, 
    0x7fff, 0xffff, 0xfffe, 
    0x7fff, 0xffff, 0xfffe, 
    0x3fff, 0xffff, 0xfffe, 
    0x3fff, 0xffff, 0xfffc, 
    0x3fff, 0xffff, 0xfffc, 
    0x3fff, 0xffff, 0xfffc, 
    0x1fff, 0xffff, 0xfff8,         /* 32 */
    0x1fff, 0xffff, 0xfff8, 
    0x0fff, 0xffff, 0xfff0, 
    0x0fff, 0xffff, 0xfff0, 
    0x07ff, 0xffff, 0xffe0, 
    0x07ff, 0xffff, 0xffe0, 
    0x03ff, 0xffff, 0xffc0, 
    0x01ff, 0xffff, 0xff80, 
    0x00ff, 0xffff, 0xff00,           /* 40 */
    0x007f, 0xffff, 0xfe00, 
    0x001f, 0xffff, 0xf800, 
    0x0007, 0xffff, 0xe000, 
    0x0003, 0xffff, 0xc000, 
    0x0000, 0xffff, 0x0000, 
    0x0000, 0x0ff0, 0x0000, 
    0x0000, 0x0000, 0x0000, 
    };
 
 
/*******************************************************/
/*                                                     */
/*    GEM Related Functions                            */
/*                                                     */
/*******************************************************/
 
WORD open_vwork(phys_handle)
WORD phys_handle;
/*******************************************************/
/* Function: This function opens a virtual workstation.*/
/*                                                     */
/* Input:  phys_handle  = physical workstation handle  */
/*                                                     */
/* Output: Returns handle of workstation               */
/*******************************************************/
{
WORD work_in[11], 
          work_out[57], 
          new_handle;               /* handle of workstation */
int       i;
 
     for (i = 0; i < 10; i++)       /* set for default values */
          work_in[i] = 1;
     work_in[10] = 2;               /* use raster co-ordinates */
     new_handle = phys_handle;      /* use currently open workstation */
     v_opnvwk(work_in, &new_handle, work_out);
     return(new_handle);
}
 
set_screen_attr()
/*********************************************************/
/*                                                       */
/* Function: Set global values about screen.             */
/*                                                       */
/* Input: None. Uses screen_vhandle.                     */
/*                                                       */
/* Output: Sets x_max, y_max, color_screen, & screen_rez */
/*                                                       */
/*********************************************************/
{
WORD work_out[57];
 
     vq_extnd(screen_vhandle, 0, work_out);
     x_max = work_out[0];
     y_max = work_out[1];
     screen_rez = Getrez();               /* 0 = low, 1 = med, 2 = high */
     color_screen = (screen_rez < 2);     /* mono 2, color 0 or 1 */
}


/*********************************************************/
/*                                                       */
/*   Application Functions                               */
/*                                                       */
/*********************************************************/


long Rnd_rng(low,hi)
long low, hi;
/*********************************************************/
/*                                                       */
/*   Function: Generate a random number between low and  */
/*             hi, inclusive.                            */
/*                                                       */
/*   Input: low = lowest value in range.                 */
/*          hi = highest value in range.                 */
/*                                                       */
/*   Output: returns random number.                      */
/*********************************************************/
{
     hi++;                          /* include hi value in range */
     return( (Random() % (hi - low)) + low);
}

char *set_bitmap(new_map)
char **new_map;
/****************************************************************/
/*                                                              */
/*   Function: Allocate memory for new screen bitmap.           */
/*                                                              */
/*   Input: new_map = pointer to a pointer for the new bitmap.  */
/*                                                              */
/*   Output: Returns current bitmap address and sets new_map    */
/*           to address of new bitmap location.                 */
/****************************************************************/
{
long x;

/* allocate new screen bitmap */
     x = (long)Malloc(32256L);      /* get 32 kbytes */
     if (!(x % 256))                /* on half page boundary */
          *new_map = (char *) x;
     else                           /* move to boundary */
          *new_map = (char *)(x + (256 - (x % 256)));
/* return current bitmap */
     return( (char *)Logbase() );
}


set_up_rasters()
/***********************************************************/
/* Function: Sets up global MFDB to point to rasters.      */
/*                                                         */
/* Input: None. Uses global FDBs and rasters listed above. */
/*                                                         */
/* Output: Sets appropriate fields in FDBs.                */
/***********************************************************/
{


/* Ball raster */
     ballMFDB.addr       =  (char *)ball_shape;
     ballMFDB.wide       =  W_BALL;   /* width in pixels */
     ballMFDB.high       =  H_BALL;   /* height in pixels */
     ballMFDB.word_width =  3;        /* width in WORDS */
     ballMFDB.format     =  0;
     ballMFDB.planes     =  1;        /* monochrome has 1 plane */
     
     
/* Mask raster */
     maskMFDB.addr       =   (char *)ball_mask;
     maskMFDB.wide       =    W_BALL;   /* width in pixels */
     maskMFDB.high       =    H_BALL;   /* height in pixels */
     maskMFDB.word_width =    3;        /* width in WORDS */
     maskMFDB.format     =    0;
     maskMFDB.planes     =    1;        /* monochrome has 1 plane */
     
     
/* Screen raster area */
     scrMFDB[0].wide          =    640;
     scrMFDB[0].high          =    400;
     scrMFDB[0].word_width    =    40;
     scrMFDB[0].format        =    0;
     scrMFDB[0].planes        =    1;  /* monochrome has 1 plane */
     if (screen_rez == 0)              /* low resolution */
     {
          scrMFDB[0].wide     =    320;
          scrMFDB[0].high     =    200;
          scrMFDB[0].word_width = 20;
          scrMFDB[0].planes   =    4;
     }
     else if (screen_rez == 1)          /* medium resolution */
     {
          scrMFDB[0].wide     =   640;
          scrMFDB[0].high     =   200;
          scrMFDB[0].planes   =   2;
     }
     
     
/* second bitmap same as first */
     scrMFDB[1].wide          =   scrMFDB[0].wide;
     scrMFDB[1].high          =   scrMFDB[0].high;
     scrMFDB[1].word_width    =   scrMFDB[0].word_width;
     scrMFDB[1].format        =   scrMFDB[0].format;
     scrMFDB[1].planes        =   scrMFDB[0].planes;
     
     
     scrMFDB[0].addr     =    bitmap0;
     scrMFDB[1].addr     =    bitmap1;
     
     
     return;
}

init_ball()
/*******************************************************/
/*                                                     */
/*  Function: Initialize ball variables.               */
/*                                                     */
/*  Input: None.                                       */
/*                                                     */
/*  Output: Set ball position, movement, and speed.    */
/*******************************************************/
{
int  i;
WORD work_out[57];

                                        /* get distance between pixels */
     vq_extnd(screen_vhandle, 0, work_out);  
                                        /* determine acceleration factor */ 
     gravity = 9800000 / ( 3600 * (float)work_out[4]);      
     
     for (i = 0; i < NUM_BALLS; i++)
     {
          ball[i].x[0]  = ball[i].x[1] = 0;
          ball[i].y[0]  = ball[i].y[1] = 0;
          ball[i].dx  = Rnd_rng(1L, 10L);     /* x movement */
          ball[i].dy  = 0;                    /* start at top of arc */
          ball[i].delay = Rnd_rng(1L, 100L);
     }
}


draw_ball(x, y)
WORD x, y;
/*********************************************************/
/* Function : Draw a ball at the specified co-ordinates. */
/*                                                       */
/* Input :    x    = x co-ordinate of upper left corner. */
/*                                                       */
/*            y    = y co-ordinate of upper left corner. */
/*                                                       */
/*            Raster must be set.                        */
/*                                                       */
/* Output :   None.                                      */
/*********************************************************/
{
WORD pxy[8],
     color_index[2];
          
     color_index[0] = 1;            /* foreground color value */
     color_index[1] = 0;            /* Background color value */
     
/* Set co-ordinate array */
     pxy[0] = 0;                    /* source x1 co-ordinate */
     pxy[1] = 0;                    /* source y1 co-ordinate */
     pxy[2] = W_BALL - 1;           /* source x2 co-ordinate */
     pxy[3] = H_BALL - 1;           /* source y2 co-ordinate */
     pxy[4] = x;                    /* destination x1 co-ordinate */
     pxy[5] = y;                    /* destination y1 co-ordinate */
     pxy[6] = x + pxy[2];           /* destination x2 co-ordinate */
     pxy[7] = y + pxy[3];           /* destination y2 co-ordinate */
     
     
/* use mask to erase area under ball */
     color_index[0] = 0;            /* 1 bits set to background color */
     vrt_cpyfm(screen_vhandle, MD_TRANS, pxy,
          &maskMFDB, &scrMFDB[draw_screen], color_index);


/* draw ball */
     color_index[0] = 1;            /* 1 bits set to foreground color */
     vrt_cpyfm(screen_vhandle, MD_TRANS, pxy,
          &ballMFDB, &scrMFDB[draw_screen], color_index);
}


erase_ball(x, y)
WORD x, y;
/*********************************************************/
/* Function : Draw a ball at the specified co-ordinates. */
/*                                                       */
/* Input :    x    = x co-ordinate of upper left corner. */
/*                                                       */
/*            y    = y co-ordinate of upper left corner  */
/*                                                       */
/*            Rasters must be set.                       */
/*                                                       */
/* Output :   None.                                      */
/*********************************************************/
{
WORD pxy[8],
     color_index[2];
     
     
     color_index[0] = 0;            /* foreground color value. */
     color_index[1] = 0;            /* Background color value. */


/* Set co-ordinate array */
     pxy[0] = 0;                    /* source x1 co-ordinate */
     pxy[1] = 0;                    /* source y1 co-ordinate */
     pxy[2] = W_BALL - 1;           /* source x2 co-ordinate */
     pxy[3] = H_BALL - 1;           /* source y2 co-ordinate */
     pxy[4] = x;                    /* destination x1 co-ordinate */
     pxy[5] = y;                    /* destination y1 co-ordinate */
     pxy[6] = x + pxy[2];           /* destination x2 co-ordinate */
     pxy[7] = y + pxy[3];           /* destination y2 co-ordinate */


/* use mask to erase area under ball */
     color_index[0] = 0;            /* 1 bits set to background color */
     vrt_cpyfm(screen_vhandle, MD_TRANS, pxy,
          &maskMFDB, &scrMFDB[draw_screen], color_index);
}

calc_ball()
/**************************************************************/
/* Function : Calculate new position for balls.               */
/*                                                            */
/* Input :    Uses ball position variables.                   */
/*                                                            */
/* Output :   New ball position, acceleration, and direction. */
/**************************************************************/
{
int i;


for (i = 0; i < NUM_BALLS; i++)
{
    ball[i].delay--;                /* count down */
    if (ball[i].delay > 0)          /* do not release ball */
         continue;
    
    
    
    ball[i].dy += gravity;          /* change velocity */
    /* change position */
    ball[i].y[draw_screen] = ball[i].y[show_screen] + ball[i].dy;
    ball[i].x[draw_screen] = ball[i].x[show_screen] + ball[i].dx;



/* check range */
      /* left edge */
    if (ball[i].x[draw_screen] < 0)
    {
         ball[i].x[draw_screen] = 0;
         ball[i].dx = -ball[i].dx;
    }
    /* right edge less width of ball */
    if (ball[i].x[draw_screen] > (x_max - W_BALL))
    {
         ball[i].x[draw_screen] = x_max - W_BALL;
         ball[i].dx = -ball[i].dx;
    }
      
      
    /* top of screen */
    if (ball[i].y[draw_screen] < 0)
    {
         ball[i].y[draw_screen] = 0;
         ball[i].dy = 0;
    }
    /* bottom of screen */
    if (ball[i].y[draw_screen] > (y_max - H_BALL))
    {         /* at bottom of arc ball bounces losing energy */
         ball[i].y[draw_screen] = y_max - H_BALL;
         ball[i].dy = -ball[i].dy * 0.975;
    }
}
return;
}


bounce_ball()
/*********************************************************/
/* Function : Bounce balls on screen.                    */
/*                                                       */
/* Input :    None.                                      */
/*                                                       */
/* Output :   None.                                      */
/*********************************************************/


{
int i;

    do
    {                               /* draw balls on hidden screen */
        for (i = 0; i < NUM_BALLS; i++)
             draw_ball(ball[i].x[draw_screen], ball[i].y[draw_screen]);
                                 /* switch screens */
        if (draw_screen)
        {
             draw_screen = 0;
             show_screen = 1;
        }
        else
        {
             draw_screen = 1;
             show_screen = 0;
        }
        Setscreen(scrMFDB[draw_screen].addr,
             scrMFDB[show_screen].addr, -1L);
        Vsync();
                                     /* erase balls */
        for (i = 0; i < NUM_BALLS; i++)
             erase_ball(ball[i].x[draw_screen], ball[i].y[draw_screen]);
                                 /* calculate new ball positions */
        calc_ball();
    } while (!Cconis());
}

/*********************************************************/
/*    Main Program                                       */
/*********************************************************/


main()
{
int ap_id;                          /* application inititialize verify */


WORD gr_wchar, gr_hchar,            /* values for VDI handle */
     gr_wbox, gr_hbox;


/*********************************************************/
/*    Initialize GEM Access                              */
/*********************************************************/
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
     
     
    bitmap0 = set_bitmap(&bitmap1);
    set_up_rasters();
    do
    {
         show_screen = 0;               /* set to current screen */
         draw_screen = 1;               /* set to background screen */
         Setscreen(bitmap1, -1L, -1L);  /* clear screens */
         v_clrwk(screen_vhandle);
         Setscreen(bitmap0, -1L, -1L);
         v_clrwk(screen_vhandle);
         init_ball();
         bounce_ball();                 /* exits on keypress */
    } while ( (Crawcin() & 0x7F) != 27);
     
     
/*********************************************************/
/*    Program Clean-up and Exit                          */
/*********************************************************/
     
     
     
    Setscreen(bitmap0, bitmap0, -1L);
    Mfree(bitmap1);                     /* return secondary bitmap */
    v_clsvwk(screen_vhandle);            /* close workstation */
    appl_exit();                        /* end program */
}

/*********************************************************/

              
     
     

     
      

     
     
