/*
				INPUT FUNCTIONS
				---------------
*/
#include <vdibind.h>

    WORD
vsin_mode( handle, dev_type, mode )
WORD handle;		/* Physical device handle */
WORD dev_type;
WORD mode;
{
    intin[0] = dev_type;
    intin[1] = mode;

    contrl[0] = 33;
    contrl[1] = 0;
    contrl[3] = 2;
    contrl[6] = handle;
    vdi();
}

    WORD
vrq_locator( handle, initx, inity, xout, yout, term )
WORD handle;		/* Physical device handle */
WORD initx;
WORD inity;
WORD *xout;
WORD *yout;
WORD *term;
{
    ptsin[0] = initx;
    ptsin[1] = inity;

    contrl[0] = 28;
    contrl[1] = 1;
    contrl[3] = 0;
    contrl[6] = handle;
    vdi();

    *xout = ptsout[0];
    *yout = ptsout[1];
    *term = intout[0];
}


vsm_locator( handle, initx, inity, xout, yout, term )
WORD handle;		/* Physical device handle */
WORD initx;
WORD inity;
WORD *xout;
WORD *yout;
WORD *term;
{
    ptsin[0] = initx;
    ptsin[1] = inity;

    contrl[0] = 28;
    contrl[1] = 1;
    contrl[3] = 0;
    contrl[6] = handle;
    vdi();

    *xout = ptsout[0];
    *yout = ptsout[1];
    *term = intout[0];
    return( (contrl[4] << 1) | contrl[2] );
}

    WORD
vrq_valuator( handle, val_in, val_out, term )
WORD handle;		/* Physical device handle */
WORD val_in;
WORD *val_out;
WORD *term;
{
    intin[0] = val_in;

    contrl[0] = 29;
    contrl[1] = 0;
    contrl[3] = 1;
    contrl[6] = handle;
    vdi();

    *val_out = intout[0];
    *term = intout[1];
}


    WORD
vsm_valuator( handle, val_in, val_out, term, status )
WORD handle;		/* Physical device handle */
WORD val_in;
WORD *val_out;
WORD *term;
WORD *status;
{
    intin[0] = val_in;

    contrl[0] = 29;
    contrl[1] = 0;
    contrl[3] = 1;
    contrl[6] = handle;
    vdi();

    *val_out = intout[0];
    *term = intout[1];
    *status = contrl[4];
}

    WORD
vrq_choice( handle, in_choice, out_choice )
WORD handle;		/* Physical device handle */
WORD in_choice;
WORD *out_choice;
{
    intin[0] = in_choice;

    contrl[0] = 30;
    contrl[1] = 0;
    contrl[3] = 1;
    contrl[6] = handle;
    vdi();

    *out_choice = intout[0];
}

    WORD
vsm_choice( handle, choice )
WORD handle;		/* Physical device handle */
WORD *choice;
{
    contrl[0] = 30;
    contrl[1] = 0;
    contrl[3] = 0;
    contrl[6] = handle;
    vdi();

    *choice = intout[0];
    return( contrl[4] );
}

    WORD
vrq_string( handle, length, echo_mode, echo_xy, string)
WORD handle;		/* Physical device handle */
WORD length;
WORD echo_mode;
WORD echo_xy[];
BYTE *string;
{
    WORD    count;

    intin[0] = length;
    intin[1] = echo_mode;
    i_ptsin( echo_xy );

    contrl[0] = 31;
    contrl[1] = echo_mode;
    contrl[3] = 2;
    contrl[6] = handle;
    vdi();

    for (count = 0; count < contrl[4]; count++)
      *string++ = intout[count];
    *string = 0;  
    i_ptsin( ptsin );
}

    WORD
vsm_string( handle, length, echo_mode, echo_xy, string )
WORD handle;		/* Physical device handle */
WORD length;
WORD echo_mode;
WORD echo_xy[];
BYTE *string;
{
    WORD    count;

    intin[0] = length;
    intin[1] = echo_mode;
    i_ptsin( echo_xy );

    contrl[0] = 31;
    contrl[1] = echo_mode;
    contrl[3] = 2;
    contrl[6] = handle;
    vdi();

    for (count = 0; count < contrl[4]; count++)
      *string++ = intout[count];
    *string = 0;  
    i_ptsin( ptsin );
    return( contrl[4] );
}


    WORD
vsc_form( handle, cur_form )
WORD handle;		/* Physical device handle */
WORD *cur_form;
{
    i_intin( cur_form );

    contrl[0] = 111;
    contrl[1] = 0;
    contrl[3] = 37;
    contrl[6] = handle;
    vdi();

    i_intin( intin );
}

    WORD
vex_timv( handle, tim_addr, old_addr, scale )
WORD handle;		/* Physical device handle */
WORD *scale;
LONG tim_addr;
LONG *old_addr;
{
    i_ptr( tim_addr );

    contrl[0] = 118;
    contrl[1] = 0;
    contrl[3] = 0;
    contrl[6] = handle;
    vdi();

    m_lptr2( old_addr );
    *scale = intout[0];
}

    WORD
v_show_c( handle, reset )
WORD handle;		/* Physical device handle */
WORD reset;
{
    intin[0] = reset;

    contrl[0] = 122;
    contrl[1] = 0;
    contrl[3] = 1;
    contrl[6] = handle;
    vdi();
}

    WORD
v_hide_c( handle )
WORD handle;		/* Physical device handle */
{
    contrl[0] = 123;
    contrl[1] = 0;
    contrl[3] = 0;
    contrl[6] = handle;
    vdi();
}

    WORD
vq_mouse( handle, status, px, py )
WORD handle;		/* Physical device handle */
WORD *status;
WORD *px;
WORD *py;
{
    contrl[0] = 124;
    contrl[1] = 0;
    contrl[3] = 0;
    contrl[6] = handle;
    vdi();

    *status = intout[0];
    *px = ptsout[0];
    *py = ptsout[1];
}

    WORD
vex_butv( handle, usercode, savecode )
WORD handle;		/* Physical device handle */
LONG usercode;
LONG *savecode;
{
    i_ptr( usercode );   

    contrl[0] = 125;
    contrl[1] = 0;
    contrl[3] = 0;
    contrl[6] = handle;
    vdi();

    m_lptr2( savecode );
}

    WORD
vex_motv( handle, usercode, savecode )
WORD handle;		/* Physical device handle */
LONG usercode;
LONG *savecode;
{
    i_ptr( usercode );

    contrl[0] = 126;
    contrl[1] = 0;
    contrl[3] = 0;
    contrl[6] = handle;
    vdi();

    m_lptr2( savecode );
}


    WORD
vex_curv( handle, usercode, savecode )
WORD handle;		/* Physical device handle */
LONG usercode;
LONG *savecode;
{
    i_ptr( usercode );

    contrl[0] = 127;
    contrl[1] = 0;
    contrl[3] = 0;
    contrl[6] = handle;
    vdi();

    m_lptr2( savecode );
}

    WORD
vq_key_s( handle, status )
WORD handle;		/* Physical device handle */
WORD *status;
{
    contrl[0] = 128;
    contrl[1] = 0;
    contrl[3] = 0;
    contrl[6] = handle;
    vdi();

    *status = intout[0];
}
