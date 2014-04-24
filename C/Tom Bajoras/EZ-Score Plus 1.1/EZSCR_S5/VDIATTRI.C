/*
				ATTRIBUTE FUNCTIONS
				-------------------
*/
#include <vdibind.h>

    WORD
vswr_mode( handle, mode )
WORD handle;		/* Physical device handle */
WORD mode;
{
    intin[0] = mode;

    contrl[0] = 32;
    contrl[1] = 0;
    contrl[3] = 1;
    contrl[6] = handle;
    vdi();
    return( intout[0] );
}

    WORD
vs_color( handle, index, rgb )
WORD handle;		/* Physical device handle */
WORD index;
WORD *rgb;
{
    WORD i;

    intin[0] = index;
    for ( i = 1; i < 4; i++ )
        intin[i] = *rgb++;

    contrl[0] = 14;
    contrl[1] = 0;
    contrl[3] = 4;
    contrl[6] = handle;
    vdi();
}

    WORD
vsl_type( handle, style )
WORD handle;		/* Physical device handle */
WORD style;
{
    intin[0] = style;

    contrl[0] = 15;
    contrl[1] = 0;
    contrl[3] = 1;
    contrl[6] = handle;
    vdi();
    return( intout[0] );
}

    WORD
vsl_udsty( handle, pattern )
WORD handle;		/* Physical device handle */
WORD pattern;
{
    intin[0] = pattern;

    contrl[0] = 113;
    contrl[1] = 0;
    contrl[3] = 1;
    contrl[6] = handle;
    vdi();
}

    WORD
vsl_width( handle, width )
WORD handle;		/* Physical device handle */
WORD width;
{
    ptsin[0] = width;
    ptsin[1] = 0;

    contrl[0] = 16;
    contrl[1] = 1;
    contrl[3] = 0;
    contrl[6] = handle;
    vdi();
    return( ptsout[0] );
}

    WORD
vsl_color( handle, index )
WORD handle;		/* Physical device handle */
WORD index;
{
    intin[0] = index;

    contrl[0] = 17;
    contrl[1] = 0;
    contrl[3] = 1;
    contrl[6] = handle;
    vdi();
    return( intout[0] );
}

    WORD
vsl_ends( handle, beg_style, end_style)
WORD handle;		/* Physical device handle */
WORD beg_style;
WORD end_style;
{
    intin[0] = beg_style;
    intin[1] = end_style;

    contrl[0] = 108;
    contrl[1] = 0;
    contrl[3] = 2;
    contrl[6] = handle;
    vdi();
}


    WORD
vsm_type( handle, symbol )
WORD handle;		/* Physical device handle */
WORD symbol;
{
    intin[0] = symbol;

    contrl[0] = 18;
    contrl[1] = 0;
    contrl[3] = 1;
    contrl[6] = handle;
    vdi();
    return( intout[0] );
}


    WORD
vsm_height( handle, height )
WORD handle;		/* Physical device handle */
WORD height;
{
    ptsin[0] = 0;
    ptsin[1] = height;

    contrl[0] = 19;
    contrl[1] = 1;
    contrl[3] = 0;
    contrl[6] = handle;
    vdi();
    return( ptsout[1] );
}


    WORD
vsm_color( handle, index )
WORD handle;		/* Physical device handle */
WORD index;
{
    intin[0] = index;

    contrl[0] = 20;
    contrl[1] = 0;
    contrl[3] = 1;
    contrl[6] = handle;
    vdi();
    return( intout[0] );
}


    WORD
vst_height( handle, height, char_width, char_height, cell_width, cell_height )
WORD handle;		/* Physical device handle */
WORD height;
WORD *char_width;
WORD *char_height;
WORD *cell_width;
WORD *cell_height;
{
    ptsin[0] = 0;
    ptsin[1] = height;

    contrl[0] = 12;
    contrl[1] = 1;
    contrl[3] = 0;
    contrl[6] = handle;
    vdi();

    *char_width = ptsout[0];
    *char_height = ptsout[1];
    *cell_width = ptsout[2];
    *cell_height = ptsout[3];
}

    WORD
vst_point( handle, point, char_width, char_height, cell_width, cell_height )
WORD handle;		/* Physical device handle */
WORD point;
WORD *char_width;
WORD *char_height;
WORD *cell_width;
WORD *cell_height;
{
    intin[0] = point;

    contrl[0] = 107;
    contrl[1] = 0;
    contrl[3] = 1;
    contrl[6] = handle;
    vdi();

    *char_width = ptsout[0];
    *char_height = ptsout[1];
    *cell_width = ptsout[2];
    *cell_height = ptsout[3];
    return( intout[0] );
}


    WORD
vst_rotation( handle, angle )
WORD handle;		/* Physical device handle */
WORD angle;
{
    intin[0] = angle;

    contrl[0] = 13;
    contrl[1] = 0;
    contrl[3] = 1;
    contrl[6] = handle;
    vdi();
    return( intout[0] );
}


    WORD
vst_font( handle, font )
WORD handle;		/* Physical device handle */
WORD font;
{
    intin[0] = font;

    contrl[0] = 21;
    contrl[1] = 0;
    contrl[3] = 1;
    contrl[6] = handle;
    vdi();
    return( intout[0] );
}


    WORD
vst_color( handle, index )
WORD handle;		/* Physical device handle */
WORD index;
{
    intin[0] = index;

    contrl[0] = 22;
    contrl[1] = 0;
    contrl[3] = 1;
    contrl[6] = handle;
    vdi();
    return( intout[0] );
}


    WORD
vst_effects( handle, effect )
WORD handle;		/* Physical device handle */
WORD effect;
{
    intin[0] = effect;

    contrl[0] = 106;
    contrl[1] = 0;
    contrl[3] = 1;
    contrl[6] = handle;
    vdi();
    return( intout[0] );
}

    WORD
vst_alignment( handle, hor_in, vert_in, hor_out, vert_out )
WORD handle;		/* Physical device handle */
WORD hor_in;
WORD vert_in;
WORD *hor_out;
WORD *vert_out;
{
    intin[0] = hor_in;
    intin[1] = vert_in;

    contrl[0] = 39;
    contrl[1] = 0;
    contrl[3] = 2;
    contrl[6] = handle;
    vdi();

    *hor_out = intout[0];
    *vert_out = intout[1];
}


    WORD
vsf_interior( handle, style )
WORD handle;		/* Physical device handle */
WORD style;
{
    intin[0] = style;

    contrl[0] = 23;
    contrl[1] = 0;
    contrl[3] = 1;
    contrl[6] = handle;
    vdi();
    return( intout[0] );
}


    WORD
vsf_style( handle, index )
WORD handle;		/* Physical device handle */
WORD index;
{
    intin[0] = index;

    contrl[0] = 24;
    contrl[1] = 0;
    contrl[3] = 1;
    contrl[6] = handle;
    vdi();
    return( intout[0] );
}

    WORD
vsf_color( handle, index )
WORD handle;		/* Physical device handle */
WORD index;
{
    intin[0] = index;

    contrl[0] = 25;
    contrl[1] = 0;
    contrl[3] = 1;
    contrl[6] = handle;
    vdi();
    return( intout[0] );
}


    WORD
vsf_perimeter( handle, per_vis )
WORD handle;		/* Physical device handle */
WORD per_vis;
{
    intin[0] = per_vis;

    contrl[0] = 104;
    contrl[1] = 0;
    contrl[3] = 1;
    contrl[6] = handle;
    vdi();
    return( intout[0] );
}

    WORD
vsf_udpat( handle, fill_pat, planes )
WORD handle;		/* Physical device handle */
WORD fill_pat[];
WORD planes;
{
    i_intin( fill_pat );

    contrl[0] = 112;
    contrl[1] = 0;
    contrl[3] = 16*planes;
    contrl[6] = handle;
    vdi();
    i_intin( intin );
}
