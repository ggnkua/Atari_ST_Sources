extern int contrl[], intout[], ptsin[], ptsout[];

extern long intin[]; 	/* For long assignment purposes 	*/

v_fsm_createclient(handle,alloc,release,refreshptr,error,
		fileopen,fileclose,fileseek,fileread,
		nvirts,aspectnum,aspectdenom,clientp)

int  handle;
long alloc,release,refreshptr,error;
long fileopen,fileclose,fileseek,fileread;
long nvirts,aspectnum,aspectdenom,clientp;
{
   contrl[0] = 140;
   contrl[6] = handle;
   intin[0] = alloc;
   intin[1] = release;
   intin[2] = refreshptr;
   intin[3] = error;
   intin[4] = fileopen;
   intin[5] = fileclose;
   intin[6] = fileseek;
   intin[7] = fileread;
   intin[8] = nvirts;
   intin[9] = aspectnum;
   intin[10] = aspectdenom;
   intin[11] = clientp;
   vdi();
}

v_fsm_killclient(handle,clientp)
int handle;
long clientp;
{
   contrl[0] = 141;
   contrl[6] = handle;
   intin[0] = clientp;
   vdi();
}

v_fsm_readfont(handle,fname,clientp,fontp)
int handle;
char fname[];
long clientp;
long fontp;
{
   int i;
   
   contrl[0] = 142;
   contrl[6] = handle;

   i = 0;
   while(fname[i])
   {
	ptsin[i] = fname[i];
  	ptsin[i] &= 0xff;
	i++;
   }
   ptsin[i] = 0;
   intin[0] = clientp;
   intin[1] = fontp;
   vdi();
}
   
v_fsm_killfont(handle,fontp,clientp)
int handle;
long fontp;
long clientp;
{
   contrl[0] = 143;
   contrl[6] = handle;
   intin[0] = fontp;
   intin[1] = clientp;
   vdi();
}

v_fsm_getheights(handle, xsize, ysize, rotation, skew,
			fontp, clientp)
int handle;
long xsize, ysize, rotation, skew, fontp, clientp;   
{
   contrl[0] = 144;
   contrl[6] = handle;
   intin[0] = xsize;
   intin[1] = ysize;
   intin[2] = rotation;
   intin[3] = skew;
   intin[4] = fontp;
   intin[5] = clientp;
   vdi();
}

v_fsm_fontxformpoint(handle,ptx,pty,xsize,ysize,rotation,skew,
			fontp,clientp,xp,yp)
int handle;
long ptx,pty,xsize,ysize,rotation,skew,fontp,clientp,xp,yp;
{
   contrl[0] = 145;
   contrl[6] = handle;
   intin[0] = ptx;
   intin[1] = pty;
   intin[2] = xsize;
   intin[3] = ysize;
   intin[4] = rotation;
   intin[5] = skew;
   intin[6] = fontp;
   intin[7] = clientp;
   intin[8] = xp;
   intin[9] = yp;
   vdi();
}

v_fsm_char(handle,gascii,charflag,xsize,ysize,rotation,skew,
		fontp,clientp,fsmoption,fsmoutputp)
int  handle,gascii,charflag;
long xsize,ysize,rotation,skew,fontp,clientp,fsmoption,fsmoutputp;
{
   contrl[0] = 146;
   contrl[6] = handle;
   ptsin[0] = gascii;
   ptsin[1] = charflag;
   intin[0] = xsize;
   intin[1] = ysize;
   intin[2] = rotation;
   intin[3] = skew;
   intin[4] = fontp;
   intin[5] = clientp;
   intin[6] = fsmoption;
   intin[7] = fsmoutputp;
   vdi();
}
