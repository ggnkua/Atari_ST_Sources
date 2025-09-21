
open_work()
{
     int i;
     handle = phys_handle;

     for (i=0; i<10; work_in[i++]=1);
     work_in[10]=2;
     v_opnvwk(work_in,&handle,work_out);
}

close_work()
{
     v_clsvwk(handle);
     appl_exit();
}

