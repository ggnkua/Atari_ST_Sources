/* Using the VDI: Program I */
/*      By R.A.Waddilove    */
/*      Digital Wizdom C    */

/* short is a 16-bit integer and is    */
/* equivalent to most C compilers' int */

short   control[12],            /* These arrays are used by  */
        intin[128],             /* GEM and you don't need to */
        ptsin[128],             /* worry about them. Define  */
        intout[128],            /* them, then forget them.   */
        ptsout[128];

short   handle,                 /* virtual workstation handle */
        app_id;                 /* application's id number */

short   work_in[12],        /* hold various parameters which set the */
        work_out[57];       /* line type, fill pattern, text style etc. */

main()
{
    short i;                    /* loop counter, nothing important */
    app_id = appl_init();       /* initialise GEM AES arrays, return id */
    for ( i=0; i<10; ++i )      /* set line type, text style, fill style */
        work_in[i] = 1;         /* text style and other parameters */
    work_in[10] = 0;            /* raster coordinates ie. pixels */
    v_opnvwk(work_in, &handle, work_out);   /* open virtual workstation */

    v_clrwk(handle);            /* clear the screen */
    v_gtext(handle, 16, 16,"This is a test...");    /* print some text */
    v_gtext(handle, 16, 32,"Click the mouse button..."); /* more text */
    wait();                     /* wait for mouse click */

    v_clsvwk(handle);           /* close virtual workstation */
    appl_exit();                /* tell GEM we've finished */
}

wait()
{
    short x, y, button;
    do {
        vq_mouse(handle, &button, &x, &y);  /* get mouse x,y,button state */
    } while ( button==0 );      /* wait until a button is pressed */
}
