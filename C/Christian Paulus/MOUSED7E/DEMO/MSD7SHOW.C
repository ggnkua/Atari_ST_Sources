/************************************************************************/
/*                                                                      */
/*    msd7show.c                                                        */
/*                                                                      */
/*    demo shape program for moused7e.prg                               */
/*                                                                      */
/*    how use data file given by moused7e.prg                           */
/*                                                                      */

         /* your compiler  */
         /* if you work with LATTICE write         */
         /* #define LATTICE                        */
#define MEGAMAX

#ifdef LATTICE
#define WORD short
#else
#define WORD int
#endif

                        /* constantes externes */
#ifndef LATTICE
WORD contrl[12], intin[128], ptsin[128], intout[128], ptsout[128];
#endif

WORD workin[] = { 1,1,1,1,1,1,1,1,1,1,2 }, workout[57];

WORD 
   handle;




   /************************************************************/
   /* This is data file given by moused7e.prg for your shape.  */

   /**** EXEMPLE.E struct vscm( moused ) ****/
WORD Md_exemple[] = {
   0x0001, 0x0001, 0x0001, 0x0000, 0x0001,
   0x8200, 0xB900, 0x6500, 0x1280, 0xE240, 0x0140, 0xFFBF, 0x0000, 
   0xFFDF, 0x0050, 0x0038, 0xFF94, 0x0054, 0x6E8E, 0x6A87, 0x0A83, 
   0x7C00, 0x4600, 0x8200, 0xE100, 0x0180, 0x0080, 0x0040, 0xFFFF, 
   0x0020, 0x0020, 0x0010, 0x0008, 0xFF88, 0x9104, 0x9102, 0xF101
   };
#define exemple() vsc_form(handle,Md_exemple)


   /************************************************************/



   /* exemple() redraw, in your C program, your mouse          */
   /* for shape defined by exemple.e                           */
   /* Name your data file myname.k, this function will name    */
   /* myname(). And will redraw the mouse for your datas       */
   /*                                                          */




/*********************************************************************/
/*       begin                                                       */
/*********************************************************************/

main()
{ WORD
    phys_handle,                             /* gestion physique   */
    ap_id,                                   /* identificateur     */
    dum;                                     /* variable divers    */

    ap_id = appl_init();                     /* ouverture          */
    handle = phys_handle =
             graf_handle ( &dum, &dum, &dum, &dum );
    v_opnvwk ( workin, &handle, workout );

                                              /* petit message    */
   puts( "Presser le bouton de la souris pour quitter    " );

                  /************************************************/
                  /* see just one line fopr redraw mouse          */
   exemple();
                  /* move your mouse, this shape showed is your   */
                  /************************************************/


   evnt_button( 1,1,1,                            /* wait button click   */
            &dum, &dum, &dum, &dum
            );

                                    /* sortie du programme... exit  */
    v_clsvwk( handle ); 
    appl_exit();
}

