/****************************************************************/
/* COLOR.C             Color demonstration program              */
/*                                                              */
/* This program shows the use of the color palette.             */
/****************************************************************/



/***************************************************************/
/*             System Header Files & Constants                 */
/***************************************************************/


#include  <stdio.h>                    /* Standard IO */
#include  <osbind.h>                   /* GEMDOS routines */
#include  <gemdefs.h>                  /* GEM AES */
#include  <obdefs.h>                   /* GEM constants */

#define   FALSE     0
#define   TRUE      !FALSE


/**********************************************************/
/*             GEM Application Overhead                   */
/**********************************************************/



/* Declare global arrays for VDI. */
typedef   int  WORD;                   /* WORD is 16 bits */

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


/* define colors */
/*#define   RED      0*/
/*#define   GREEN    1*/
/*#define   BLUE     2*/

/* rotating palette */
WORD pal_wheel[] = {
     0x000, 0x007, 0x070, 0x700, 0x077, 0x707, 0x770, 0x777,
     0x000, 0x111, 0x222, 0x333, 0x444, 0x555, 0x666, 0x777,
     0x000, 0x007, 0x070, 0x700, 0x077, 0x707, 0x770, 0x777,
     0x000, 0x111, 0x222, 0x333, 0x444, 0x555, 0x666, 0x777
};

/* current palette */
WORD save_pal[16];

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


check_table(handle)
WORD handle;
/**********************************************************/
/* Function: Check if color lookup table is supported.    */
/*                                                        */
/* Input:    handle    = handle of device to check.       */
/*                                                        */
/* Output:   0         = table supported.                 */
/*           1         = not supported.                   */
/**********************************************************/
{
WORD work_out[57];

     vq_extnd(handle, 1, work_out);        /* do extended inquire */
     return(work_out[5]);                  /* return flag */
}

show_palette()
/******************************************************************/
/* Function: Draw a set of squares to show current color settings */
/*                                                                */
/* Input   : None                                                 */
/*                                                                */
/* Output  : None                                                 */
/******************************************************************/
{
register i;
WORD     pxy[4];

     for (i = 0; i < 16; i++)      /* ST supports up to 16 colors */
     {
          pxy[0] = (i % 4) * 40 + 20;
          pxy[1] = (i / 4) * 40 + 20;
          pxy[2] = pxy[0] + 35;
          pxy[3] = pxy[1] +35;
          vsf_color(screen_vhandle, i); /* set fill color */
          vr_recfl(screen_vhandle, pxy);
      }
}


change_palette()
/*********************************************************/
/* Function: Change palette index 3 using VDI function.  */
/*                                                       */
/* Input:    None.                                       */
/*                                                       */
/* Output:   None.                                       */
/*********************************************************/
{
WORD rgb[3],                       /* new settings */
     srgb[3];                      /* saved settings */
long delta;                        /* use long to slow down */

/* inquire current value for index 3 */
     vq_color(screen_vhandle, 3, 0, srgb);


/* initialize */
     rgb[RED] = 0;
     rgb[GREEN] = 0;
     rgb[BLUE] = 0;
     delta = 1;
/* loop around colors */
     for (rgb[BLUE] = 0; rgb[BLUE] < 1000; rgb[BLUE] += delta)
          vs_color(screen_vhandle, 3, rgb);
     
     for (rgb[RED] = 0, rgb[GREEN] = 0; rgb[RED] < 1000;
               rgb[RED] += delta, rgb[GREEN]+= delta)
          vs_color(screen_vhandle, 3, rgb);
     
     for (; rgb[BLUE] > 0; rgb[BLUE] -= delta, rgb[GREEN] -= delta)
          vs_color(screen_vhandle, 3, rgb);
     
     for (; rgb[RED] > 0; rgb[RED] -= delta)
          vs_color(screen_vhandle, 3, rgb);
     
     Crawcin();
     vs_color(screen_vhandle, 3, srgb);  /* restore color */
}

rot_palette()
/*********************************************************/
/* Function: Use XBIOS call to set entire palette.       */
/*                                                       */
/* Input:    None. Uses array   pal_wheel[].             */
/*                                                       */
/* Output:   None.                                       */
/*********************************************************/
{
register i;

/* save current palette */
     for (i = 0; i < 16; i++)
          save_pal[i] = Setcolor(i, -1);   /* read current value */
     
     for (i = 0; i < 16; i++)
     {
          Setpalette(&pal_wheel[i]);       /* set base of palette */
          show_palette();
          Crawcin();
     }
     
     Setpalette(save_pal);                 /* restore original */
}

/**********************************************************/
/*                                                        */
/*                      Main Program                      */
/*                                                        */
/**********************************************************/

main()
{
int ap_id;                        /* application init verify */

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


     v_clrwk(screen_vhandle);
     
     if ( !check_table(screen_vhandle))   /* check for color table */
     {
           printf("***> Color look-up table not supported <***\n");
           printf("Color palette function will have no effect\n");
           printf("Press any key\n");
           Crawcin();
     }
     
     vsf_interior(screen_vhandle, 1);  /* set solid fill */
     show_palette();                   /* show current palette */
     Crawcin();
     change_palette();                 /* reset values */
     Crawcin();
     rot_palette();


/*********************************************************/
/*    Program Clean-up and Exit                          */
/*********************************************************/
     
     
/* Wait for keyboard before exiting program */     
     Crawcin();                   /* GEMDOS character input */
     v_clsvwk(screen_vhandle);    /* close workstation */
     appl_exit();                 /* end program */
}

/*********************************************************/

