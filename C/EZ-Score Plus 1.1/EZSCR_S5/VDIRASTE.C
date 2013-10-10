/*
				RASTER OPERATIONS
				-----------------
*/
#include <vdibind.h>

    WORD
vro_cpyfm( handle, wr_mode, xy, srcMFDB, desMFDB )
WORD handle;		/* Physical device handle */
WORD wr_mode;
WORD xy[], *srcMFDB;
WORD *desMFDB;
{
    intin[0] = wr_mode;
    i_ptr( srcMFDB );
    i_ptr2( desMFDB );
    i_ptsin( xy );

    contrl[0] = 109;
    contrl[1] = 4;
    contrl[3] = 1;
    contrl[6] = handle;
    vdi();

    i_ptsin( ptsin );
}

    WORD
vrt_cpyfm( handle, wr_mode, xy, srcMFDB, desMFDB, index )
WORD handle;		/* Physical device handle */
WORD wr_mode;
WORD *srcMFDB;
WORD *desMFDB;
WORD xy[];
WORD *index;
{
    intin[0] = wr_mode;
    intin[1] = *index++;
    intin[2] = *index;
    i_ptr( srcMFDB );
    i_ptr2( desMFDB );
    i_ptsin( xy );

    contrl[0] = 121;
    contrl[1] = 4;
    contrl[3] = 3;
    contrl[6] = handle;
    vdi();

    i_ptsin( ptsin );
}

    WORD
vr_trnfm( handle, srcMFDB, desMFDB )
WORD handle;		/* Physical device handle */
WORD *srcMFDB;
WORD *desMFDB;
{
    i_ptr( srcMFDB );
    i_ptr2( desMFDB );

    contrl[0] = 110;
    contrl[1] = 0;
    contrl[3] = 0;
    contrl[6] = handle;
    vdi();
}

    WORD
v_get_pixel( handle, x, y, pel, index )
WORD handle;		/* Physical device handle */
WORD x;
WORD y;
WORD *pel;
WORD *index;
{
    ptsin[0] = x;
    ptsin[1] = y;

    contrl[0] = 105;
    contrl[1] = 1;
    contrl[3] = 0;
    contrl[6] = handle;
    vdi();

    *pel = intout[0];
    *index = intout[1];
}
