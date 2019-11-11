#include "define.h"

extern WORD  gl_apid;

/* special LATTICE variable */
int _MNEED = 1;	/* should be upper case to work with all linkers */

WORD    xwork,ywork,hwork,wwork;
FDB     scr_mfdb,mem_mfdb;
BYTE *resolution = "[3][This program doesn't | work in Low res ][ Cancel ]";
WORD    gl_hchar;
WORD    gl_wchar;
WORD    gl_wbox;
WORD    gl_hbox;
WORD    handle;
/*
WORD    contrl[12];
WORD    intin[128];
WORD    ptsin[128];
WORD    intout[128];
WORD    ptsout[128];
*/
WORD work_in[11];
WORD work_out[57];
WORD pxyarray[10];

/*-------------------------*/
/*      CO-exec            */
/*-------------------------*/
VOID CO_exec()
{
        graf_mouse(ARROW,0);
        graf_mouse(M_OFF,0);
 /*       wind_update(BEG_UPDATE);*/
        ic_main();
/*        wind_update(FALSE);*/
        graf_mouse(M_ON,0);
}
/*-------------------------*/
/*      CO_term            */
/*-------------------------*/
VOID CO_term(term_type)
WORD term_type;
{
        switch(term_type)
        {
        case 0:
                v_clsvwk(handle);
                Mfree(mem_mfdb.fd_addr);
        case 1:
                appl_exit();
        }
}
/*-------------------------*/
/*        CO_init          */
/*-------------------------*/
WORD CO_init()
{
WORD i;
LONG buff_size;
        if (appl_init() == -1)
                return(2);
        if (!Getrez())
        {
                form_alert(1,resolution);
                return(1);
        }
        for(i=0; i<10; work_in[i++]=1);
        work_in[10]=2;
        handle=graf_handle(&gl_wchar,&gl_hchar,&gl_wbox,&gl_hbox);
        v_opnvwk(work_in,&handle,work_out);
        if (handle == 0)
                return (1);
        scr_mfdb.fd_addr = 0x0L;      /* FDB for the screen */
        mem_mfdb.fd_w = work_out[0] + 1;
        mem_mfdb.fd_h = gl_hchar * 23;
        mem_mfdb.fd_wdwidth = (mem_mfdb.fd_w) >> 4;
        vq_extnd(handle, 1, work_out);
        mem_mfdb.fd_nplanes = work_out[4];
        buff_size = (LONG)(mem_mfdb.fd_w >> 3) *
                (LONG)mem_mfdb.fd_h *
                (LONG)mem_mfdb.fd_nplanes;
        if (!(mem_mfdb.fd_addr = Malloc(buff_size)))
                return(1);
        wind_get(0, WF_WORKXYWH, &xwork, &ywork, &wwork, &hwork);
        return (0);
}
/*-------------------------*/
/*        main             */
/*-------------------------*/
VOID main()
{
WORD term_type;
     if (!(term_type=CO_init()))
          CO_exec();
     CO_term(term_type);
}
