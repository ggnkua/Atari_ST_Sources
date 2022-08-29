
int contrl[12], intin[128], intout[128], ptsin[128], ptsout[128],
    work_in[12], work_out[57],  /*frher work_in[11] !!!*/
    msgbuff[8], handle, apid, dummy;

openwork()
{
    register int i;
    apid = appl_init();
    handle = graf_handle(&dummy,&dummy,&dummy,&dummy);
    for (i=0; i<10; work_in[i++]=1);
    work_in[10]=2;
    v_opnvwk(work_in,&handle,work_out);
}

closework()
{
    v_clsvwk(handle);
    appl_exit();
}
