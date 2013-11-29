/*
				OUTPUT FUNTIONS
				---------------
*/
#include <vdibind.h>

    WORD
v_pline( handle, count, xy )
WORD handle;		/* Physical device handle */
WORD count;
WORD xy[];
{
    i_ptsin( xy );

    contrl[0] = 6;
    contrl[1] = count;
    contrl[3] = 0;
    contrl[6] = handle;
    vdi();

    i_ptsin( ptsin );
}

    WORD
v_pmarker( handle, count, xy )
WORD handle;		/* Physical device handle */
WORD count;
WORD xy[];
{
    i_ptsin( xy );

    contrl[0] = 7;
    contrl[1] = count;
    contrl[3] = 0;
    contrl[6] = handle;
    vdi();

    i_ptsin( ptsin );
}


    WORD
v_gtext( handle, x, y, string)
WORD handle;		/* Physical device handle */
WORD x;
WORD y;
unsigned char *string;
{
    WORD i;

    ptsin[0] = x;
    ptsin[1] = y;
    i = 0;
    while (intin[i++] = *string++)
        ;

    contrl[0] = 8;
    contrl[1] = 1;
    contrl[3] = --i;
    contrl[6] = handle;
    vdi();
}


    WORD
v_fillarea( handle, count, xy)
WORD handle;		/* Physical device handle */
WORD count;
WORD xy[];
{
    i_ptsin( xy );

    contrl[0] = 9;
    contrl[1] = count;
    contrl[3] = 0;
    contrl[6] = handle;
    vdi();

    i_ptsin( ptsin );
}




    WORD
v_cellarray( handle, xy, row_length, el_per_row, num_rows, wr_mode, colors )
WORD handle;
WORD xy[4];
WORD row_length;
WORD el_per_row;
WORD num_rows;
WORD wr_mode;
WORD *colors;
{
    i_intin( colors );
    i_ptsin( xy );

    contrl[0] = 10;
    contrl[1] = 2;
    contrl[3] = row_length * num_rows;
    contrl[6] = handle;
    contrl[7] = row_length;
    contrl[8] = el_per_row;
    contrl[9] = num_rows;
    contrl[10] = wr_mode;
    vdi();

    i_intin( intin );
    i_ptsin( ptsin );
}

    WORD
v_contourfill( handle, x, y, index )
WORD handle;		/* Physical device handle */
WORD x;
WORD y;
WORD index;
{
    intin[0] = index;
    ptsin[0] = x;
    ptsin[1] = y;

    contrl[0] = 103;
    contrl[1] = 1;
    contrl[3] = 1;
    contrl[6] = handle;
    vdi();
}

    WORD
vr_recfl( handle, xy )
WORD handle;		/* Physical device handle */
WORD *xy;
{
    i_ptsin( xy );

    contrl[0] = 114;
    contrl[1] = 2;
    contrl[3] = 0;
    contrl[6] = handle;
    vdi();

    i_ptsin( ptsin );
}

    WORD
v_bar( handle, xy )
WORD handle;		/* Physical device handle */
WORD xy[];
{
    i_ptsin( xy );

    contrl[0] = 11;
    contrl[1] = 2;
    contrl[3] = 0;
    contrl[5] = 1;
    contrl[6] = handle;
    vdi();

    i_ptsin( ptsin );
}

    WORD
v_arc( handle, xc, yc, rad, sang, eang )
WORD handle;		/* Physical device handle */
WORD xc;
WORD yc;
WORD rad;
WORD sang;
WORD eang;
{
    ptsin[0] = xc;
    ptsin[1] = yc;
    ptsin[2] = 0;
    ptsin[3] = 0;
    ptsin[4] = 0;
    ptsin[5] = 0;
    ptsin[6] = rad;
    ptsin[7] = 0;
    intin[0] = sang;
    intin[1] = eang;

    contrl[0] = 11;
    contrl[1] = 4;
    contrl[3] = 2;
    contrl[5] = 2;
    contrl[6] = handle;
    vdi();
}

    WORD
v_pieslice( handle, xc, yc, rad, sang, eang )
WORD handle;		/* Physical device handle */
WORD xc;
WORD yc;
WORD rad;
WORD sang;
WORD eang;
{
    ptsin[0] = xc;
    ptsin[1] = yc;
    ptsin[2] = 0;
    ptsin[3] = 0;
    ptsin[4] = 0;
    ptsin[5] = 0;
    ptsin[6] = rad;
    ptsin[7] = 0;
    intin[0] = sang;
    intin[1] = eang;

    contrl[0] = 11;
    contrl[1] = 4;
    contrl[3] = 2;
    contrl[5] = 3;
    contrl[6] = handle;
    vdi();
}

    WORD
v_circle( handle, xc, yc, rad )
WORD handle;		/* Physical device handle */
WORD xc;
WORD yc;
WORD rad;
{
    ptsin[0] = xc;
    ptsin[1] = yc;
    ptsin[2] = 0;
    ptsin[3] = 0;
    ptsin[4] = rad;
    ptsin[5] = 0;

    contrl[0] = 11;
    contrl[1] = 3;
    contrl[3] = 0;
    contrl[5] = 4;
    contrl[6] = handle;
    vdi();
}

    WORD
v_ellarc( handle, xc, yc, xrad, yrad, sang, eang )
WORD handle;		/* Physical device handle */
WORD xc;
WORD yc;
WORD xrad;
WORD yrad;
WORD sang;
WORD eang;
{
    ptsin[0] = xc;
    ptsin[1] = yc;
    ptsin[2] = xrad;
    ptsin[3] = yrad;
    intin[0] = sang;
    intin[1] = eang;

    contrl[0] = 11;
    contrl[1] = 2;
    contrl[3] = 2;
    contrl[5] = 6;
    contrl[6] = handle;
    vdi();
}

    WORD
v_ellpie( handle, xc, yc, xrad, yrad, sang, eang)
WORD handle;		/* Physical device handle */
WORD xc;
WORD yc;
WORD xrad;
WORD yrad;
WORD sang;
WORD eang;
{
    ptsin[0] = xc;
    ptsin[1] = yc;
    ptsin[2] = xrad;
    ptsin[3] = yrad;
    intin[0] = sang;
    intin[1] = eang;

    contrl[0] = 11;
    contrl[1] = 2;
    contrl[3] = 2;
    contrl[5] = 7;
    contrl[6] = handle;
    vdi();
}

    WORD
v_ellipse( handle, xc, yc, xrad, yrad )
WORD handle;		/* Physical device handle */
WORD xc;
WORD yc;
WORD xrad;
WORD yrad;
{
    ptsin[0] = xc;
    ptsin[1] = yc;
    ptsin[2] = xrad;
    ptsin[3] = yrad;

    contrl[0] = 11;
    contrl[1] = 2;
    contrl[3] = 0;
    contrl[5] = 5;
    contrl[6] = handle;
    vdi();
}


    WORD
v_rbox( handle, xy )
WORD handle;		/* Physical device handle */
WORD xy[];
{
    i_ptsin( xy );

    contrl[0] = 11;
    contrl[1] = 2;
    contrl[3] = 0;
    contrl[5] = 8;
    contrl[6] = handle;
    vdi();

    i_ptsin( ptsin );
}


    WORD
v_rfbox( handle, xy )
WORD handle;		/* Physical device handle */
WORD xy[];
{
    i_ptsin( xy );

    contrl[0] = 11;
    contrl[1] = 2;
    contrl[3] = 0;
    contrl[5] = 9;
    contrl[6] = handle;
    vdi();

    i_ptsin( ptsin );
}

    WORD
v_justified( handle, x, y, string, length, word_space, char_space)
WORD handle;		/* Physical device handle */
WORD x;
WORD y;
WORD length;
WORD word_space;
WORD char_space;
BYTE string[];
{
    WORD *intstr;

    ptsin[0] = x;
    ptsin[1] = y;
    ptsin[2] = length;
    ptsin[3] = 0;
    intin[0] = word_space;
    intin[1] = char_space;
    intstr = &intin[2];
    while (*intstr++ = *string++)
        ;

    contrl[0] = 11;
    contrl[1] = 2;
    contrl[3] = (int) (intstr - intin) - 1;
    contrl[5] = 10;
    contrl[6] = handle;
    vdi();
}
