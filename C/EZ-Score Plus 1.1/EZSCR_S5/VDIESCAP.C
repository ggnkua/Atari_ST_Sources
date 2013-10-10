/*
				ESCAPE FUNCTIONS
				----------------
*/
#include <vdibind.h>

    WORD
vq_chcells( handle, rows, columns )
WORD handle;		/* Physical device handle */
WORD *rows;
WORD *columns;
{
    contrl[0] = 5;
    contrl[1] = 0;
    contrl[3] = 0;
    contrl[5] = 1;
    contrl[6] = handle;
    vdi();

    *rows = intout[0];
    *columns = intout[1];
}

    WORD
v_exit_cur( handle )
WORD handle;		/* Physical device handle */
{
    contrl[0] = 5;
    contrl[1] = 0;
    contrl[3] = 0;
    contrl[5] = 2;
    contrl[6] = handle;
    vdi();
}

	WORD
v_enter_cur( handle )
WORD handle;		/* Physical device handle */
{
    contrl[0] = 5;
    contrl[1] = 0;
    contrl[3] = 0;
    contrl[5] = 3;
    contrl[6] = handle;
    vdi();
}

	WORD
v_curup( handle )
WORD handle;		/* Physical device handle */
{
    contrl[0] = 5;
    contrl[1] = 0;
    contrl[3] = 0;
    contrl[5] = 4;
    contrl[6] = handle;
    vdi();
}

    WORD
v_curdown( handle )
WORD handle;		/* Physical device handle */
{
    contrl[0] = 5;
    contrl[1] = 0;
    contrl[3] = 0;
    contrl[5] = 5;
    contrl[6] = handle;
    vdi();
}

    WORD
v_curright( handle )
WORD handle;		/* Physical device handle */
{
    contrl[0] = 5;
    contrl[1] = 0;
    contrl[3] = 0;
    contrl[5] = 6;
    contrl[6] = handle;
    vdi();
}

    WORD
v_curleft( handle )
WORD handle;		/* Physical device handle */
{
    contrl[0] = 5;
    contrl[1] = 0;
    contrl[3] = 0;
    contrl[5] = 7;
    contrl[6] = handle;
    vdi();
}

v_curhome ( handle )
WORD handle;		/* Physical device handle */
{
    contrl[0] = 5;
    contrl[1] = 0;
    contrl[3] = 0;
    contrl[5] = 8;
    contrl[6] = handle;
    vdi();
}

    WORD
v_eeos( handle )
WORD handle;		/* Physical device handle */
{
    contrl[0] = 5;
    contrl[1] = 0;
    contrl[3] = 0;
    contrl[5] = 9;
    contrl[6] = handle;
    vdi();
}

    WORD
v_eeol( handle )
WORD handle;		/* Physical device handle */
{
    contrl[0] = 5;
    contrl[1] = 0;
    contrl[3] = 0;
    contrl[5] = 10;
    contrl[6] = handle;
    vdi();
}


 
    WORD
vs_curaddress( handle, row, column )
WORD handle;		/* Physical device handle */
WORD row;
WORD column;
{
    intin[0] = row;
    intin[1] = column;

    contrl[0] = 5;
    contrl[1] = 0;
    contrl[3] = 2;
    contrl[5] = 11;
    contrl[6] = handle;
    vdi();
}



    WORD
v_curtext( handle, string )
WORD handle;		/* Physical device handle */
BYTE *string; 
{
    WORD *intstr;

    intstr = intin;
    while (*intstr++ = *string++)
      ;

    contrl[0] = 5;
    contrl[1] = 0;
    contrl[3] = ((int)(intstr - intin)-1);
    contrl[5] = 12;
    contrl[6] = handle;
    vdi();
}
 

    WORD
v_rvon( handle )
WORD handle;		/* Physical device handle */
{
    contrl[0] = 5;
    contrl[1] = 0;
    contrl[3] = 0;
    contrl[5] = 13;
    contrl[6] = handle;
    vdi();
}

    WORD
v_rvoff( handle )
WORD handle;		/* Physical device handle */
{
    contrl[0] = 5;
    contrl[1] = 0;
    contrl[3] = 0;
    contrl[5] = 14;
    contrl[6] = handle;
    vdi();
}

    WORD
vq_curaddress( handle, row, column )
WORD handle;		/* Physical device handle */
WORD *row;
WORD *column;
{
    contrl[0] = 5;
    contrl[1] = 0;
    contrl[3] = 0;
    contrl[5] = 15;
    contrl[6] = handle;
    vdi();

    *row = intout[0];
    *column = intout[1];
}

    WORD
vq_tabstatus( handle )
WORD handle;		/* Physical device handle */
{
    contrl[0] = 5;
    contrl[1] = 0;
    contrl[3] = 0;
    contrl[5] = 16;
    contrl[6] = handle;
    vdi();
    return( intout[0] );
}

    WORD
v_hardcopy( handle )
WORD handle;		/* Physical device handle */
{
    contrl[0] = 5;
    contrl[1] = 0;
    contrl[3] = 0;
    contrl[5] = 17;
    contrl[6] = handle;
    vdi();
}

    WORD
v_dspcur( handle, x, y )
WORD handle;		/* Physical device handle */
WORD x;
WORD y;
{
    ptsin[0] = x;
    ptsin[1] = y;

    contrl[0] = 5;
    contrl[1] = 1;
    contrl[3] = 0;
    contrl[5] = 18;
    contrl[6] = handle;
    vdi();
}

    WORD
v_rmcur( handle )
WORD handle;		/* Physical device handle */
{
    contrl[0] = 5;
    contrl[1] = 0;
    contrl[3] = 0;
    contrl[5] = 19;
    contrl[6] = handle;
    vdi();
}

    WORD
v_form_adv( handle )
WORD handle;		/* Physical device handle */
{
    contrl[0] = 5;
    contrl[1] = 0;
    contrl[3] = 0;
    contrl[5] = 20;
    contrl[6] = handle;
    vdi();
}

    WORD
v_output_window( handle, xy )
WORD handle;		/* Physical device handle */
WORD xy[];
{
    i_ptsin( xy );

    contrl[0] = 5;
    contrl[1] = 2;
    contrl[3] = 0;
    contrl[5] = 21;
    contrl[6] = handle;
    vdi();

    i_ptsin( ptsin );
}

    WORD
v_clear_disp_list( handle )
WORD handle;		/* Physical device handle */
{
    contrl[0] = 5;
    contrl[1] = 0;
    contrl[3] = 0;
    contrl[5] = 22;
    contrl[6] = handle;
    vdi();
}

    WORD
v_bit_image( handle, filename, aspect, scaling, num_pts, xy )
WORD handle;		/* Physical device handle */
WORD aspect;
WORD scaling;
WORD num_pts;
WORD xy[];
BYTE *filename;
{
    WORD i;

    for (i = 0; i < 4; i++)
	ptsin[i] = xy[i];
    intin[0] = aspect;
    intin[1] = scaling;
    i = 2;
    while (intin[i++] = *filename++)
        ;

    contrl[0] = 5;
    contrl[1] = num_pts;
    contrl[3] = --i;
    contrl[5] = 23;
    contrl[6] = handle;
    vdi();
}

    WORD
vs_palette( handle, palette )
WORD handle;		/* Physical device handle */
WORD palette;
{
    contrl[0] = 5;
    contrl[1] = 0;
    contrl[3] = 1;
    contrl[5] = 60;
    contrl[6] = handle;
    intin[0] = palette;
    vdi();
    return( intout[0] );
}

    WORD
vqp_films( handle, names )
WORD handle;		/* Physical device handle */
BYTE names[];
{
    WORD   i;

    contrl[0] = 5;
    contrl[1] = 0;
    contrl[3] = 0;
    contrl[5] = 91;
    contrl[6] = handle;
    vdi();

    for (i = 0; i < contrl[4]; i++);
        names[i] = intout[i];
}

    WORD
vqp_state( handle, port, filmnum, lightness, interlace, planes, indexes )
WORD handle;		/* Physical device handle */
WORD *port;
WORD *filmnum;
WORD *lightness;
WORD *interlace;
WORD *planes;
WORD *indexes;
{
    WORD i;

    contrl[0] = 5;
    contrl[1] = 0;
    contrl[3] = 0;
    contrl[5] = 92;
    contrl[6] = handle;
    vdi();

    *port = intout[0];
    *filmnum = intout[1];
    *lightness = intout[2];
    *interlace = intout[3];
    *planes = intout[4];
    for (i = 5; i < contrl[4]; i++);
        *indexes++ = intout[i];
}

    WORD
vsp_state( handle, port, filmnum, lightness, interlace, planes, indexes )
WORD handle;		/* Physical device handle */
WORD port;
WORD filmnum;
WORD lightness;
WORD interlace;
WORD planes;
WORD *indexes;
{
    WORD i;

    intin[0] = port; 
    intin[1] = filmnum; 
    intin[2] = lightness;
    intin[3] = interlace;
    intin[4] = planes;
    for (i = 5; i < 20; i++);
        intin[i] = *indexes++;

    contrl[0] = 5;
    contrl[1] = 0;
    contrl[3] = 20;
    contrl[5] = 93;
    contrl[6] = handle;
    vdi();
}

    WORD
vsp_save( handle )
WORD handle;		/* Physical device handle */
{
    contrl[0] = 5;
    contrl[1] = 0;
    contrl[3] = 0;
    contrl[5] = 94;
    contrl[6] = handle;
    vdi();
}

    WORD
vsp_message( handle )
WORD handle;		/* Physical device handle */
{
    contrl[0] = 5;
    contrl[1] = 0;
    contrl[3] = 0;
    contrl[5] = 95;
    contrl[6] = handle;
    vdi();
}



    WORD
vqp_error( handle )
WORD handle;		/* Physical device handle */
{
    contrl[0] = 5;
    contrl[1] = 0;
    contrl[3] = 0;
    contrl[5] = 96;
    contrl[6] = handle;
    vdi();
    return( intout[0] );
}

    WORD
v_meta_extents( handle, min_x, min_y, max_x, max_y )
WORD handle;		/* Physical device handle */
WORD min_x;
WORD min_y;
WORD max_x;
WORD max_y;
{
    ptsin[0] = min_x;
    ptsin[1] = min_y;
    ptsin[2] = max_x;
    ptsin[3] = max_y;

    contrl[0] = 5;
    contrl[1] = 2;
    contrl[3] = 0;
    contrl[5] = 98;
    contrl[6] = handle;
    vdi();
}

    WORD
v_write_meta( handle, num_ints, ints, num_pts, pts )
WORD handle;		/* Physical device handle */
WORD num_ints;
WORD ints[];
WORD num_pts;
WORD pts[];
{
    i_intin( ints );
    i_ptsin( pts );

    contrl[0] = 5;
    contrl[1] = num_pts;
    contrl[3] = num_ints;
    contrl[5] = 99;
    contrl[6] = handle;
    vdi();

    i_intin( intin );
    i_ptsin( ptsin );
}

    WORD
vm_filename( handle, filename )
WORD handle;		/* Physical device handle */
BYTE *filename;
{
    WORD *intstr;

    intstr = intin;
    while( *intstr++ = *filename++ )
        ;

    contrl[0] = 5;
    contrl[1] = 0;
    contrl[3] = ((int)(intstr - intin)-1);
    contrl[5] = 100;
    contrl[6] = handle;
    vdi();
}
