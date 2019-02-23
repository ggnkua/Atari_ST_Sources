/************************************************
*    Simple blitter example                     *
*                                               *
*    this program demonstrates using the        *
*    Gem blit routines to scroll a region       *
*    of the screen around.                      *
*                                               *
*    by Samuel Streeper                         *
*    COPYRIGHT 1990 by Antic Publishing, Inc.   *
************************************************/

#include <obdefs.h>
#include <gemdefs.h>
#include <osbind.h>

int phys_handle;    /* physical workstation handle */
int handle;         /* virtual workstation handle */
int ret;            /* dummy return variable */

int    contrl[12];
int    intin[128];
int    ptsin[128];
int    intout[128];
int    ptsout[128];

int work_in[11];
int work_out[57];
int pxyarray[10];

MFDB screen;        /* memory form descriptor block for the screen  */
                    /* some compiler define this as a FDB...        */

int antic[] =        /* connect the dots to show a graphic "A" */
    {
        40,5,
        5,65,
        18,75,
        30,55,
        50,55,
        62,75,
        75,65,
        50,19,
        42,35,
        45,40,
        35,40,
        47,15,
        40,5
    };

/****************************************************************/
/* open virtual workstation                                     */
/****************************************************************/
open_vwork()
{
    register int i;
    for(i=0;i<10;work_in[i++]=1);
    work_in[10]=2;
    handle=phys_handle;
    v_opnvwk(work_in,&handle,work_out);
}

main()
{
    /* Set up Gem... */

    appl_init();
    phys_handle=graf_handle(&ret,&ret,&ret,&ret);
    open_vwork();

    /* Set up the screen memory form definition block.    */
    /* Do this immediately after open_vwork()            */
    /* Only needs to be done once...                    */
    init_mfdb();


    /* Now do the example */

    example();


    /* Clean up and exit */

    v_clsvwk(handle);
    appl_exit();
}

example()
{
    register int i, j;
    int corners[8];
    int write_mode = 3;            /* just copy the source rectangle */

    v_clrwk(handle);               /* clear the screen */
    v_pline(handle,13,antic);      /* put graphic on screen */

top:
    /* Do the blit to scroll region vertically.        */
    for (i=0; i<21; i++)
    {
        if (Cconis()) goto end;

        Vsync();            /* slow this thing down! */

        /**** tell the blitter where to blit from and to ****/

        corners[0] = 0;                 /* top corner x, source */
        corners[1] = i*5;               /* top corner y, source */
        corners[2] = 80;                /* bot corner x, source */
        corners[3] = corners[1] + 80;   /* bot corner y, source */

        corners[4] = 0;                 /* top corner x, dest */
        corners[5] = (i+1) * 5;         /* top corner y, dest */
        corners[6] = 80;                /* bot corner x, dest */
        corners[7] = corners[5] + 80;   /* bot corner y, dest */

        /**** the actual Gem blit call ****/
        vro_cpyfm(handle, write_mode, corners, &screen, &screen);
    }

    /* Do blit to scroll region horozontally.    */
    for (i=0; i<21; i++)
    {
        if (Cconis()) goto end;

        Vsync();                /* slow this thing down! */

        corners[0] = i * 5;
        corners[1] = 100;
        corners[2] = corners[0] + 80;
        corners[3] = 180;
        corners[4] = (i+1) * 5;
        corners[5] = 100;
        corners[6] = corners[4] + 80;
        corners[7] = 180;

        vro_cpyfm(handle, write_mode, corners, &screen, &screen);
    }

    /* Do blit to scroll region diagonally.    */
    for (i=0; i<21; i++)
    {
        if (Cconis()) goto end;

        Vsync();                /* slow this thing down! */

        corners[0] = 105 - (i * 5);
        corners[1] = 105 - (i * 5);
        corners[2] = corners[0] + 80;
        corners[3] = corners[1] + 80;
        corners[4] = corners[0] - 5;
        corners[5] = corners[1] - 5;
        corners[6] = corners[2] - 5;
        corners[7] = corners[3] - 5;

        vro_cpyfm(handle, write_mode, corners, &screen, &screen);
    }

    goto top;        /* do this forever or until keypress */
                     /* whichever comes first! */
end:
    Crawcin();
}

init_mfdb()
{
    register MFDB *fdbp = &screen;
    register int temp;

    fdbp->fd_addr    = Logbase();            /* logical screen base    */
    fdbp->fd_w    = work_out[0] + 1;         /* screen pixel width    */
    fdbp->fd_h    = work_out[1] + 1;         /* screen pixel height    */
    fdbp->fd_wdwidth    = fdbp->fd_w/16;     /* screen int width    */
    fdbp->fd_stand    = 0;

    /* number of bitplanes for screen */
    switch(work_out[13])
    {
        case 16: temp = 4; break;
        case 08: temp = 3; break;
        case 04: temp = 2; break;
        default: temp = 1; break;
    }
    fdbp->fd_nplanes = temp;
}
