/****************************************************************/
/* ANIMATE.C   Demonstrate animation techniques                 */
/*                                                              */
/* This program shows how two bitmaps are used for animation.   */
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
typedef   int  WORD;                 /* WORD is 16 bits */

WORD      contrl[12],                /* VDI control array */
          intout[128], intin[128],   /* VDI input arrays */
          ptsin[128], ptsout[128];   /* VDI output arrays */

WORD      screen_vhandle,            /* virtual screen workstation */
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
#define   SQSIZE     10            /* size of a square */

char *screen1,                     /* logical base of current screen */
     *screen2;                     /* logical base of new screen */

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
int       i;

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


set_base()
/**********************************************************/
/* Function : Allocate memory for new screen bitmap.      */
/*                                                        */
/* Input    : None                                        */
/*                                                        */
/* Output   : Sets screen1, screen2.                      */
/**********************************************************/
{
#define BOUNDARY
long x;

/* allocate new screen bitmap */
     x = (long)Malloc(32256L);     /* get 32 kbytes */
     if (!(x % BOUNDARY))          /* on half page boundary */
          screen2 = (char *) x;
     else                          /* move to boundary */
          screen2 = (char *)(x + (BOUNDARY - (x % BOUNDARY)));

/* get current screen */
     screen1   = (char *)Logbase();
     return;
}

draw_box(a1, a2)
WORD a1[], a2[];
/*********************************************************/
/* Function : Draw two vertical lines of boxes.          */
/*                                                       */
/* Input    : a1 = array for first line of boxes.        */
/*            a2 = array for second line of boxes.       */
/*                                                       */
/* Output   : None.                                      */
/*********************************************************/
{
          for (a1[1] = a2[1] = 10, a1[3] = a2[3] = a1[1] + SQSIZE;
               a1[1] < y_max - 20;
               a1[1]+=30, a2[3]+=30, a1[3]+=30, a2[3]+=30)
          {
               vr_recfl(screen_vhandle, a1);
               vr_recfl(screen_vhandle, a2);
          }
          return;
}

animate()
/*********************************************************/
/* Function : Use single bitmap to animate boxes.        */
/*                                                       */
/* Input    : None.                                      */
/*                                                       */
/* Output   : None.                                      */
/*********************************************************/
{
WORD p11[4], p12[4];               /* squares  x  co-ordinate */

     p11[0] = SQSIZE * 2;          /* square 1 on screen 1 start */
     p11[2] = p11[0] + SQSIZE;
     
     p12[0] = x_max - (SQSIZE * 2);  /* square 2 on screen 1 start */
     p12[2] = p12[0] + SQSIZE;
     
     v_clrwk(screen_vhandle);      /* clear screen */
                                   /* set XOR drawing mode */
     vswr_mode(screen_vhandle, MD_XOR);
     draw_box(p11, p12);           /* draw initial squares */
     
     while (p12[0] > SQSIZE+5)
     {
          draw_box(p11, p12);
          p11[0]++; p11[2]++;      /* move along  x  values */
          p12[0]--; p12[2]--;
          draw_box(p11, p12);
          Vsync();
     }
}
animate2()
/*********************************************************/
/* Function : Use multiple bitmaps to animate boxes.     */
/*                                                       */
/* Input    : None. Uses screen1 and screen2.            */
/*                                                       */
/* Output   : None.                                      */
/*********************************************************/
{
WORD p11[4], p12[4],             /* screen 1 squares  x  co-ordinate */

     p21[4], p22[4];             /* screen 2 squares  x  co-ordinate */
     
     p11[0] = SQSIZE * 2;        /* square 1 on screen 1 start */
     p11[2] = p11[0] + SQSIZE;
     
     p12[0] = x_max - (SQSIZE * 2);    /* square 2 on screen 1 start */
     p12[2] = p12[0] + SQSIZE;
     
     p21[0] = (SQSIZE * 2 + 1);    /* square 1 on screen 2 start */
     p21[2] = p21[0] + SQSIZE;
     
     p22[0] = x_max - (SQSIZE * 2 + 1); /* square 2 on screen2 start */
     p22[2] = p22[0] + SQSIZE;
     
     Setscreen(screen1, screen1, -1);
     v_clrwk(screen_vhandle);      /* clear screen */
     Setscreen(screen2, screen2, -1);
     v_clrwk(screen_vhandle);      /* clear screen */
                                   /* set XOR drawing mode */
     vswr_mode(screen_vhandle, MD_XOR);
                                   /* draw initial squares */
     Setscreen(screen1, -1L, -1);
     draw_box(p11, p12);
     Setscreen(screen2, -1L, -1);
     draw_box(p21, p22);
     
     while (p12[0] > SQSIZE+5)
     {                             /* show new and draw on old */
          Setscreen(screen1, screen2, -1);
          Vsync();
          draw_box(p11, p12);      /* erase */
          p11[0]+=2; p11[2]+=2;    /* move along  x  axis */
          p12[0]-=2; p12[2]-=2;
          draw_box(p11, p12);      /* draw */
                                   /* show old and draw on new */
          Setscreen(screen2, screen1, -1);
          Vsync();
          draw_box(p21, p22);      /* erase */
          p21[0]+=2; p21[2]+=2;    /* move along  x  axis */
          p22[0]-=2; p22[2]-=2;
          draw_box(p21, p22);      /* draw */
     }
     Setscreen(screen1, screen1, -1);
}
 
/**********************************************************/
/*                                                        */
/*                      Main Program                      */
/*                                                        */
/**********************************************************/

main()
{
int  ap_id;                        /* application init verify */
WORD gr_wchar, gr_hchar,           /* values for VDI handle */
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

     set_base();
     animate1();
     Crawcin();
     animate2();

/*********************************************************/
/*    Program Clean-up and Exit                          */
/*********************************************************/
     
     Mfree(screen2);                 /* return memory */
     
/* Wait for keyboard before exiting program */     
     Crawcin();                   /* GEMDOS character input */
     v_clsvwk(screen_vhandle);    /* close workstation */
     appl_exit();                 /* end program */
}

/*********************************************************/

