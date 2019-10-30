/***********************/
/*  Fichier INITGEM.H  */
/***********************/
int contrl[12], intin[128], intout[128];
int ptsin[128], ptsout[128];
int work_in[12], work_out[57];
int gl_hchar, gl_wchar, gl_hbox, gl_wbox;
int glapid;
int _handle;

int InitGem()
{
  register int i;

  if((glapid = appl_init()) != -1)
  {
    for(i = 1; i < 10; work_in[i++] = 0);
    work_in[10] = 2;
    _handle = graf_handle(&gl_wchar,&gl_hchar,
                          &gl_wbox,&gl_hbox);
    work_in[0] = _handle;
    v_opnvwk(work_in, &_handle, work_out);
    return(TRUE);
  }
  else return(FALSE);
}

void CloseGem()
{
  v_clsvwk(_handle);
  appl_exit();
}

