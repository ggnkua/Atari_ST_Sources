/*
				CONTROL FUNCTIONS
				-----------------
*/
#include <vdibind.h>

    WORD
v_opnwk( work_in, handle, work_out )
WORD work_in[];
WORD *handle;		/* Physical device handle */
WORD work_out[];	/* Output arguments array */
{
   i_intin( work_in );
   i_intout( work_out );
   i_ptsout( work_out + 45 );

   contrl[0] = 1;
   contrl[1] = 0;        /* no points to xform */
   contrl[3] = 11;        /* pass down xform mode also */
   vdi();

   *handle = contrl[6];    

   i_intin( intin );
   i_intout( intout );
   i_ptsout( ptsout );
   i_ptsin( ptsin );	/* must set in 68k land so we can ROM it */
}


    WORD
v_clswk( handle )
WORD handle;		/* Physical device handle */
{
    contrl[0] = 2;
    contrl[1] = 0;
    contrl[3] = 0;
    contrl[6] = handle;
    vdi();
}

    WORD
v_opnvwk( work_in, handle, work_out )
WORD work_in[];		/* Input arguments array */
WORD *handle;		/* Physical device handle */
WORD work_out[];	/* Output arguments array */
{
   i_intin( work_in );
   i_intout( work_out );
   i_ptsout( work_out + 45 );

   contrl[0] = 100;
   contrl[1] = 0;
   contrl[3] = 11;
   contrl[6] = *handle;
   vdi();

   *handle = contrl[6];    
   i_intin( intin );
   i_intout( intout );
   i_ptsout( ptsout );
   i_ptsin( ptsin );	/* must set in 68k land so we can ROM it */
}

    WORD
v_clsvwk( handle )
WORD handle;		/* Physical device handle */
{
    contrl[0] = 101;
    contrl[1] = 0;
    contrl[3] = 0;
    contrl[6] = handle;
    vdi();
}

    WORD
v_clrwk( handle )
WORD handle;		/* Physical device handle */
{
    contrl[0] = 3;
    contrl[1] = 0;
    contrl[3] = 0;
    contrl[6] = handle;
    vdi();
}

    WORD
v_updwk( handle )
WORD handle;		/* Physical device handle */
{
    contrl[0] = 4;
    contrl[1] = 0;
    contrl[3] = 0;
    contrl[6] = handle;
    vdi();
}

    WORD
vst_load_fonts( handle, select )
WORD handle;		/* Physical device handle */
WORD select;
{
    contrl[0] = 119;
    contrl[1] = 0;
    contrl[3] = 0;
    contrl[6] = handle;
    vdi();
    return( intout[0] );
}


vst_unload_fonts( handle, select )
WORD handle;		/* Physical device handle */
WORD select;
{
    contrl[0] = 120;
    contrl[1] = 0;
    contrl[3] = 0;
    contrl[6] = handle;
    vdi();
}


    WORD
vs_clip( handle, clip_flag, xy )
WORD handle;		/* Physical device handle */
WORD clip_flag;
WORD xy[];
{
    i_ptsin( xy );
    intin[0] = clip_flag;

    contrl[0] = 129;
    contrl[1] = 2;
    contrl[3] = 1;
    contrl[6] = handle;
    vdi();

    i_ptsin( ptsin );
}
