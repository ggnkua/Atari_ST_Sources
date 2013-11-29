/*
				INQUIRE FUNCTIONS
				-----------------
*/
#include <vdibind.h>

    WORD
vq_extnd( handle, owflag, work_out )
WORD handle;		/* Physical device handle */
WORD owflag;
WORD work_out[];
{
    i_intin( intin );	/* must set in 68k land so we can ROM it */
    i_ptsin( ptsin );	/* since bss can't have initialized data */

    i_intout( work_out );
    i_ptsout( work_out + 45 );
    intin[0] = owflag;

    contrl[0] = 102;
    contrl[1] = 0;
    contrl[3] = 1;
    contrl[6] = handle;
    vdi();

    i_intout( intout );
    i_ptsout( ptsout );
}

    WORD
vq_color( handle, index, set_flag, rgb )
WORD handle;		/* Physical device handle */
WORD index;
WORD set_flag;
WORD rgb[];
{
    intin[0] = index;
    intin[1] = set_flag;

    contrl[0] = 26;
    contrl[1] = 0;
    contrl[3] = 2;
    contrl[6] = handle;
    vdi();

    rgb[0] = intout[1];
    rgb[1] = intout[2];
    rgb[2] = intout[3];
}

    WORD
vql_attributes( handle, attributes )
WORD handle;		/* Physical device handle */
WORD attributes[];
{
    i_intout( attributes );

    contrl[0] = 35;
    contrl[1] = 0;
    contrl[3] = 0;
    contrl[6] = handle;
    vdi();

    i_intout( intout );
    attributes[3] = ptsout[0];
}

    WORD
vqm_attributes( handle, attributes )
WORD handle;		/* Physical device handle */
WORD attributes[];
{
    i_intout( attributes );

    contrl[0] = 36;
    contrl[1] = 0;
    contrl[3] = 0;
    contrl[6] = handle;
    vdi();

    i_intout( intout );
    attributes[3] = ptsout[1];
}

    WORD
vqf_attributes( handle, attributes )
WORD handle;		/* Physical device handle */
WORD attributes[];
{
    i_intout( attributes );

    contrl[0] = 37;
    contrl[1] = 0;
    contrl[3] = 0;
    contrl[6] = handle;
    vdi();

    i_intout( intout );
}

    WORD
vqt_attributes( handle, attributes )
WORD handle;		/* Physical device handle */
WORD attributes[];
{
    i_intout( attributes );
    i_ptsout( attributes+6 );

    contrl[0] = 38;
    contrl[1] = 0;
    contrl[3] = 0;
    contrl[6] = handle;
    vdi();

    i_intout( intout );
    i_ptsout( ptsout );
}


    WORD
vqt_extent( handle, string, extent )
WORD handle;		/* Physical device handle */
WORD extent[];
BYTE string[];
{
    WORD *intstr;

    intstr = intin;
    while (*intstr++ = *string++)
        ;
    i_ptsout( extent );

    contrl[0] = 116;
    contrl[1] = 0;
    contrl[3] = ((int)(intstr - intin)-1);
    contrl[6] = handle;
    vdi();

    i_ptsout( ptsout );
}

    WORD
vqt_width( handle, character, cell_width, left_delta, right_delta )
WORD handle;		/* Physical device handle */
WORD *cell_width;
WORD *left_delta;
WORD *right_delta;
BYTE character;
{
    intin[0] = character;

    contrl[0] = 117;
    contrl[1] = 0;
    contrl[3] = 1;
    contrl[6] = handle;
    vdi();

    *cell_width = ptsout[0];
    *left_delta = ptsout[2];
    *right_delta = ptsout[4];
    return( intout[0] );
}

    WORD
vqt_name( handle, element_num, name )
WORD handle;		/* Physical device handle */
WORD element_num;
BYTE name[];
{
    WORD i;

    intin[0] = element_num;

    contrl[0] = 130;
    contrl[1] = 0;
    contrl[3] = 1;
    contrl[6] = handle;
    vdi();

    for (i = 0 ; i < 32 ; i++)
	name[i] = intout[i + 1];
    return( intout[0] );
}

    WORD
vq_cellarray( handle, xy, row_len, num_rows, el_used, rows_used, stat, colors )
WORD handle;		/* Physical device handle */
WORD xy[];
WORD row_len;
WORD num_rows;
WORD *el_used;
WORD *rows_used;
WORD *stat;
WORD colors[];
{
    i_ptsin( xy );
    i_intout( colors );

    contrl[0] = 27;
    contrl[1] = 2;
    contrl[3] = 0;
    contrl[6] = handle;
    contrl[7] = row_len;
    contrl[8] = num_rows;
    vdi();

    *el_used = contrl[9];
    *rows_used = contrl[10];
    *stat = contrl[11];
    i_ptsin( ptsin );
    i_intout( intout );
}

    WORD
vqin_mode( handle, dev_type, mode )
WORD handle;		/* Physical device handle */
WORD dev_type;
WORD *mode;
{
    intin[0] = dev_type;

    contrl[0] = 115;
    contrl[1] = 0;
    contrl[3] = 1;
    contrl[6] = handle;
    vdi();

    *mode = intout[0];
}


    WORD
vqt_font_info( handle, minADE, maxADE, distances, maxwidth, effects )
WORD handle;		/* Physical device handle */
WORD *minADE;
WORD *maxADE;
WORD distances[];
WORD *maxwidth;
WORD effects[];
{
    contrl[0] = 131;
    contrl[1] = 0;
    contrl[3] = 0;
    contrl[6] = handle;
    vdi();

    *minADE = intout[0];
    *maxADE = intout[1];
    *maxwidth = ptsout[0];
    distances[0] = ptsout[1];
    distances[1] = ptsout[3];
    distances[2] = ptsout[5];
    distances[3] = ptsout[7];
    distances[4] = ptsout[9];
    effects[0] = ptsout[2];
    effects[1] = ptsout[4];
    effects[2] = ptsout[6];
}
