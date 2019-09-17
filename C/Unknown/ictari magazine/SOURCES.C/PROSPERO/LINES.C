/****************************************/
/*                                      */
/*  LINES.C   Draw kinetic line art     */
/*                                      */
/* This program demonstrates the        */
/* use of the polyline functions by     */
/* drawing lines between two pairs      */
/* of moving points on the screen.      */
/****************************************/


/*******************************************/
/* System Header Files & Constants */
/*******************************************/

#include <stdio.h>     /* Standard IO */
#include <osbind.h>    /* GEMDOS routines */
#include <gemdefs.h>   /* GEM AES */
#include <obdefs.h>    /* GEM constants */

#define FALSE 0
#define TRUE   !FALSE

/*****************************************/
/*       GEM Application Overhead        */
/*****************************************/

/* Declare global arrays for VDI.*/
typedef int WORD;                /* WORD is 16 bits */
WORD    contrl[12],              /* VDI control array */
        intout[128], intin[128], /* VDI input arrays */
        ptsin[128], ptsout[128]; /* VDI output arrays */

WORD    screen_vhandle,          /* virtual screen workstation */
        screen_phandle,          /* physical screen workstation */
        screen_rez,              /* screen resolution 0,1, or 2 */
        color_screen,            /* flag if colour monitor */
        x_max,                   /* maximum x screen co-ordinate */
        y_max;                   /* maximum y screen co-ordinate */

/******************************************/
/*       Application Specific Data        */
/******************************************/

/* Constant values for drawing area */
int x_lower,                       /* lowest x value */
    y_lower,                       /* lowest y value */
    x_upper,                       /* highest x value */
    y_upper;                       /* highest y value */

/******************************************/
/*        GEM Related Functions           */
/******************************************/

WORD open_vwork(phys_handle)
WORD phys_handle;
/*******************************************************/
/* Function: This function opens a virtual workstation */
/*                                                     */
/* Input:    phys_handle = physical workstation handle */
/*                                                     */
/* Output:   Returns handle of workstation.            */
/*******************************************************/
{
WORD work_in[11],
          work_out[57],
          new_handle;              /* handle of workstation */
int       i;

     for (i = 0; i <10; i++)
          work_in[i] = 1;
     work_in[10] = 2;
     new_handle = phys_handle;     /* use currently open workstation */
     v_opnvwk(work_in, &new_handle, work_out);
     v_clrwk(new_handle);          /* clear workstation */
     return(new_handle);
}

set_screen_attr()
/**************************************************************/
/* Function: Set global values about screen.                  */
/*                                                            */
/* Input:    None. Uses screen_vhandle.                       */
/*                                                            */
/* Output:   Sets x_max, y_max, color_screen, and screen_rez. */
/**************************************************************/
{
WORD work_out[57];

     vq_extnd(screen_vhandle, 0, work_out);
     x_max = work_out[0];
     y_max = work_out[1];
     screen_rez = Getrez();               /* 0 = low, 1 = med, 2 = high */
     color_screen = (screen_rez < 2);     /* mono 2, color 0 or 1 */
}
/*************************************************************/
/*                  Application Functions                    */
/*************************************************************/

long Rnd_rng(low, hi)
long low, hi;
/*********************************************************************/
/* Function: Generate a random number between low and hi, inclusive. */
/*                                                                   */
/* Input: low = lowest value in range.                               */
/*        hi  = highest value in range.                              */
/*                                                                   */
/* Output: Returns random number.                                    */
/*********************************************************************/
{
     hi++;                 /* include high value in range */
     return( (Random() % (hi - low)) + low);
     }

inchk(x,dx,lb,ub)
int  x,dx,lb,ub;
/**********************************************************************/
/* Function: This function tests whether a number (x) will be outside */
/*           a given range if a move (dx) is added to it. If the test */
/*           is true, the direction of movement is reversed.          */
/*                                                                    */
/* Input:    x    number to test                                      */
/*           dx   delta to add to x                                   */
/*           lb   lower bound                                         */
/*           ub   upper bound                                         */
/*                                                                    */
/* Output:   Returns new  dx  value.                                  */
/**********************************************************************/
{
     if ( x+dx <= lb || x+dx >= ub )
          dx*=-1;
     return(dx);
}

draw_frame()
/***************************************************/
/* Function : Draw a rounded rectangle border.     */
/*                                                 */
/* Input :    None.                                */
/*                                                 */
/* Output :   None.                                */
/***************************************************/
{
WORD pts[4];                         /* array to hold corner vertices */

/* Set boundaries for border rectangle */
     pts[0] = x_lower;               /* Upper left */
     pts[1] = y_lower;
     pts[2] = x_upper;               /* Lower right */
     pts[3] = y_upper;
     v_rbox(screen_vhandle, pts);    /* Draw a rounded box */
     return;
}

draw_lines()
/***************************************************/
/* Function : Do kinetic line art.                 */
/*                                                 */
/* Input    : None.                                */
/*                                                 */
/* Output   : None.                                */
/***************************************************/
{
int  line_number,                   /* loop control */
     k;

WORD px1, py1,                      /* endpoint 1 for line p */
     px2, py2,                      /* endpoint 2 for line p */
     pdx1, pdx2,                    /* delta x for endpoints */
     pdy1, pdy2;                    /* delta y for endpoints */

WORD rx1, ry1,                      /* variables for line r */
     rx2, ry2,
     rdx1, rdx2,
     rdy1, rdy2;

WORD pxy[100], rxy[100];            /* arrays to hold 2 sets of 25 lines */

do                                  /* begin screen control loop */
{
     v_clrwk(screen_vhandle);       /* clear screen */
     draw_frame();                  /* draw border */
/* Initialize line endpoints */
/* Line P endpoints */
     px1 = Rnd_rng( (long)x_lower, (long)x_upper);
     py1 = Rnd_rng( (long)y_lower, (long)y_upper);
     px2 = Rnd_rng( (long)x_lower, (long)x_upper);
     py2 = Rnd_rng( (long)y_lower, (long)y_upper);
     pdx1 = Rnd_rng( -10L, 10L);
     pdy1 = Rnd_rng( -10L, 10L);
     pdx2 = Rnd_rng( -10L, 10L);
     pdy2 = Rnd_rng( -10L, 10L);
     rx1 = Rnd_rng( (long)x_lower, (long)x_upper);
     ry1 = Rnd_rng( (long)y_lower, (long)y_upper);
     rx2 = Rnd_rng( (long)x_lower, (long)x_upper);
     ry2 = Rnd_rng( (long)y_lower, (long)y_upper);
     rdx1 = Rnd_rng( -10L, 10L);
     rdy1 = Rnd_rng( -10L, 10L);
     rdx2 = Rnd_rng( -10L, 10L);
     rdy2 = Rnd_rng( -10L, 10L);

/* Each point requires 4 elements in the pxy or rxy array. The current */
/* line drawn is held in elements 96, 97, 98, and 99 for the  x and  y */
/* co-ordinates of the first endpoint and the  x and y co-ordinates of */
/* the second endpoint, respectively. The next line to be erased is in */
/* elements 0, 1, 2, and 3.                                            */

     for( k=0; k<100; k++ )
          pxy[k] = rxy[k] = 0;     /* clear arrays */
     vsl_color(screen_vhandle,1);  /* Set color to black */
/* Line drawing loop begins here */
/* Change loop end value to draw any number of lines */
     do
     {
          rxy[96] = rx1; rxy[97] = ry1;  /* Set next line to */
          rxy[98] = rx2; rxy[99] = ry2;  /* be drawn */
          pxy[96] = px1; pxy[97] = py1;
          pxy[98] = px2; pxy[99] = py2;
          v_pline(screen_vhandle, 2, &pxy+96);  /* Draw polyline using */
          v_pline(screen_vhandle, 2, &rxy+96);  /* 2 vertices ( one line) */
          
          v_pline(screen_vhandle, 2, &pxy);  /* Redraw first line */
          v_pline(screen_vhandle, 2, &rxy);  /* to erase it */
          
          for( k=0; k<96; k++)     /* Shift endpoints in arrays */
          {
          pxy[k] = pxy[k+4];
          rxy[k] = rxy[k+4];
          }
          
          /* Calculate endpoints of next lines */
          px1 += pdx1;   py1 += pdy1;
          px2 += pdx2;   py2 += pdy2;
          rx1 += rdx1;   ry1 += rdy1;
          rx2 += rdx2;   ry2 += rdy2;
          rdx1 = inchk(rx1, rdx1, x_lower, x_upper);
          rdx2 = inchk(rx2, rdx2, x_lower, x_upper);
          rdy1 = inchk(ry1, rdy1, y_lower, y_upper);
          rdy2 = inchk(ry2, rdy2, y_lower, y_upper);
          pdx1 = inchk(px1, pdx1, x_lower, x_upper);
          pdx2 = inchk(px2, pdx2, x_lower, x_upper);
          pdy1 = inchk(py1, pdy1, y_lower, y_upper);
          pdy2 = inchk(py2, pdy2, y_lower, y_upper);
     } while (!Cconis());          /* check if key pressed */
} while ((Crawcin() & 0x7F) != 27);      /* escape key exits */
     return;
}
/**********************************************************/

main()
{
int  ap_id;                     /* application init verify */
WORD gr_wchar, gr_hchar,          /* values for VDI handle */
     gr_wbox, gr_hbox;

/**********************************************************/


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


     vsl_type(screen_vhandle, 1);  /* Set polyline pattern to solid */
     vsl_width(screen_vhandle, 1); /* Set line width */
     vsf_color(screen_vhandle, 0); /* Set fill color to 0 (white) */
     vswr_mode(screen_vhandle, MD_XOR);
/* set boundaries */
     x_lower = 10;
     y_lower = 10;
     x_upper = x_max - 10;
     y_upper = y_max - 10;
/* start program */
     draw_lines();                 /* Do line art */
     
/********************************************************/
/*                                                      */
/*             Program Clean-up and Exit                */
/*                                                      */
/********************************************************/

     
     v_clsvwk(screen_vhandle);     /* close workstation */
     appl_exit();                  /* end program */
}
                                 
