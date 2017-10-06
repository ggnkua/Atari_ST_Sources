#include <aes.h>	  /* GEM-Defines */
#include <vdi.h>
#include <osbind.h>
#include <minimum.h>
#include "m_glass.h"


/* ***Programm beim GEM abmelden*** */
void GEM_exit(void)
{
 v_clsvwk(vhandle);
 appl_exit();
}

/* ***Programm beim GEM anmelden*** */
void GEM_init(void)
{
 int work_in[12], i;
 ap_id=appl_init();
 vhandle=graf_handle(&i, &i, &i, &i);
 for(i=0;i<10;i++) work_in[i]=1;  work_in[10]=2;
 v_opnvwk(work_in, &vhandle, work_out);
 if(vhandle<0)
  {
   form_alert(1,"[3][v_opnvwk hat|nicht geklappt!][Abbruch]");
   appl_exit(); exit(-1);
  }
 x_aufl=work_out[0]; y_aufl=work_out[1];
 wind_get(0, WF_WORKXYWH, &deskx, &desky, &deskw, &deskh); /* Desktopgr”že */
 graf_mouse(ARROW, 0L);
}

/* ***MFDBs einrichten*** */
void mfdb_init(void)
{
 pic1mfdb.fd_addr=pic1addr;
 pic1mfdb.fd_nplanes=planes;

 pic2mfdb.fd_addr=pic2addr;
 pic2mfdb.fd_nplanes=planes;

 pic3mfdb.fd_addr=pic3addr;
 pic3mfdb.fd_nplanes=planes;
}

/* ***Mausflgag setzen*** */
void setmouseflag(void)
{
 form_dial(0, 0, 0, 0, 0, dialogx, dialogy, dialogw, dialogh);
 objc_draw(tree, MAINBOX, 4, dialogx, dialogy, dialogw, dialogh);
 do
  {
   wahl=form_do(tree, 0);
   switch(wahl)
	{
	 case MFCROSSB:
	   tree[MFCROSSB].ob_state^=CROSSED;
	   objc_draw(tree, MFCROSSB, 1, dialogx, dialogy, dialogw, dialogh);
	   evnt_timer(0x01F4,0x00); break;
	 case WUCROSSB:
	   tree[WUCROSSB].ob_state^=CROSSED;
	   objc_draw(tree, WUCROSSB, 1, dialogx, dialogy, dialogw, dialogh);
	   evnt_timer(0x01F4,0x00); break;
	}
  }
 while(wahl!=OKBUTTON);
 tree[OKBUTTON].ob_state=NORMAL;
 form_dial(3, 0, 0, 0, 0, dialogx, dialogy, dialogw, dialogh);
 mouseflag=!(tree[MFCROSSB].ob_state & CROSSED);
 w_updateflag=tree[WUCROSSB].ob_state & CROSSED;
 if(tree[FSTRBUT].ob_state & SELECTED)	blowup=1;
 if(tree[SCNDRBUT].ob_state & SELECTED)  blowup=2;
 if(tree[THRDRBUT].ob_state & SELECTED)  blowup=3;
}

/* ***Vergr”žern*** */
void blow_up(register unsigned char *src, register unsigned int *dest, int step)
{
 register int x, y;
 for(y=0; y<wi_h/2/step*planes; y++)
  {
   for(x=0; x<wi_w/16/step; x++)
	 *dest++ = *(dest+wi_w/16/step) = (table[(*src)>>4]<<8) | table[(*src++) & 0x0F];
   dest+=x;
  }
}

/* ***Doppelte Gr”že*** */
void normalblowup(int faktor)
{
  register int div;

  /* Die Maus darf nicht ganz am Bildschirmrand sein: */
  div=4*faktor;
  if(mausx-wi_w/div<0)	mausx=wi_w/div;
  if(mausx+wi_w/div>x_aufl)  mausx=x_aufl-wi_w/div;
  if(mausy-wi_h/div<0)	mausy=wi_h/div;
  if(mausy+wi_h/div>y_aufl)  mausy=y_aufl-wi_h/div;

  /* MFDBs auf die richtige Gr”že bringen: */
  div=2*faktor;
  pic1mfdb.fd_w=wi_w/div; pic1mfdb.fd_h=wi_h/div; pic1mfdb.fd_wdwidth=wi_w/32/faktor;
  pic2mfdb.fd_w=wi_w/div; pic2mfdb.fd_h=wi_h/div; pic2mfdb.fd_wdwidth=wi_w/32/faktor;
  pic3mfdb.fd_w=wi_w; pic3mfdb.fd_h=wi_h; pic3mfdb.fd_wdwidth=wi_w/16;

  /* Bildschirm unter der Maus kopieren: */
  div=4*faktor;
  xy[0]=mausx-wi_w/div;  xy[1]=mausy-wi_h/div;
  xy[2]=mausx+wi_w/div-1;xy[3]=mausy+wi_h/div-1;
  xy[4]=0;				 xy[5]=0;
  xy[6]=pic2mfdb.fd_w-1; xy[7]=pic2mfdb.fd_h-1;
  if(w_updateflag)	 wind_update(BEG_UPDATE);
  if(mouseflag) 	 graf_mouse(M_OFF, 0L);
  vro_cpyfm(vhandle, S_ONLY, xy, &scrnmfdb, &pic1mfdb);
  if(mouseflag)   graf_mouse(M_ON, 0L);
  if(w_updateflag)	 wind_update(END_UPDATE);

  /* MFDB ver„ndern: */
  vr_trnfm(vhandle, &pic1mfdb, &pic2mfdb);
  switch(faktor)
   {
   case 1:
	  blow_up(pic2addr, pic3addr, 1);
	  break;
   case 2:
	  blow_up(pic2addr, pic1addr, 2);
	  blow_up(pic1addr, pic3addr, 1);
	  break;
   }
  pic1mfdb.fd_w=wi_w; pic1mfdb.fd_h=wi_h; pic1mfdb.fd_wdwidth=wi_w/16;
  vr_trnfm(vhandle, &pic3mfdb, &pic1mfdb);

  xy[0]=0;			 xy[1]=0;
  xy[2]=wi_w-1; 	 xy[3]=wi_h-1;
  xy[4]=wi_x;		 xy[5]=wi_y;
  xy[6]=wi_x+wi_w-1; xy[7]=wi_y+wi_h-1;

  /* Auf den Bildschirm kopieren: */
  if(w_updateflag)	 wind_update(BEG_UPDATE);
  wind_get(wi_handle, WF_FIRSTXYWH, &xyclip[0], &xyclip[1], &rw, &rh);
  do
   {
   xyclip[2]=xyclip[0]+rw-1;  xyclip[3]=xyclip[1]+rh-1;
   vs_clip(vhandle, 1, xyclip);
   vro_cpyfm(vhandle, S_ONLY, xy, &pic1mfdb, &scrnmfdb);  /* Copy */
   wind_get(wi_handle, WF_NEXTXYWH, &xyclip[0], &xyclip[1], &rw, &rh);
   }
  while(rw!=0 && rh!=0);
  if(w_updateflag)	 wind_update(END_UPDATE);
}

/* ***Mega-Vergr”žern*** */
void megablowup(void)
{
 register int x, y;
 int color;

 if(mausx<3)  mausx=3;
 if(mausx>x_aufl-3)  mausx=x_aufl-3;
 if(mausy<3)  mausy=3;
 if(mausy>y_aufl-3)  mausy=y_aufl-3;

 for(x=0; x<7; x++)
  for(y=0; y<7; y++)
   {
	if(mouseflag)  graf_mouse(M_OFF, 0L);
	v_get_pixel(vhandle, x+mausx-3, y+mausy-3, xy, &color);
	if(mouseflag)  graf_mouse(M_ON, 0L);
	vsf_color(vhandle, color);
	xy[0]=wi_x+wi_w*x/5;	   xy[1]=wi_y+wi_h*y/5;
	xy[2]=wi_x-1+wi_w*(x+1)/5; xy[3]=wi_y-1+wi_h*(y+1)/5;
	if(w_updateflag)  wind_update(BEG_UPDATE);
	wind_get(wi_handle, WF_FIRSTXYWH, &xyclip[0], &xyclip[1], &rw, &rh);
	do
	 {
	  xyclip[2]=xyclip[0]+rw-1;  xyclip[3]=xyclip[1]+rh-1;
	  vs_clip(vhandle, 1, xyclip);
	  v_bar(vhandle, xy);		 /* Draw */
	  wind_get(wi_handle, WF_NEXTXYWH, &xyclip[0], &xyclip[1], &rw, &rh);
	 }
	while(rw!=0 && rh!=0);
	if(w_updateflag)  wind_update(END_UPDATE);
   }
}

/* ***Fenster ”ffnen und Lupe darstellen*** */
int mag_glass(void)
{
 int whichevnt;
 int i;

 /* Window erstellen und ”ffnen:*/
 wi_handle=wind_create(NAME|CLOSER|FULLER|MOVER|SIZER, deskx ,desky,
			deskw, deskh);	  /* Window anmelden */
 if(wi_handle<0)
  { form_alert(1,"[3][Kein Fenster brig!][Abbruch]");
	return(-1); }
 wind_set(wi_handle, WF_NAME, "Magicfying Glass", 0L); /* Name setzen */
 wind_calc(WC_BORDER, NAME|CLOSER|FULLER|MOVER|SIZER, 0, 0, 128, 104,
		 &wi_x, &wi_y, &wi_w, &wi_h);
 wi_x=deskx+(deskw-wi_w)/2;  wi_y=desky+(deskh-wi_h)/2;
 graf_growbox(x_aufl/2, y_aufl/2, 2, 1, wi_x, wi_y, wi_w, wi_h);
 wind_open(wi_handle, wi_x, wi_y, wi_w, wi_h);	  /* Window ”ffnen */

 /* Hauptschleife: */
 do
 {
  whichevnt=evnt_multi(MU_TIMER|MU_MESAG|MU_BUTTON, 0, 3, 0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0,msgbuff, 15, 0, &mausx, &mausy, &i, &i, &i, &i);

  if(whichevnt & MU_MESAG)	  /* Ereignisse auswerten */
   switch(msgbuff[0])
   {
	case WM_TOPPED:
	  wind_set(msgbuff[3], WF_TOP, 0L, 0L);
	  break;
	case WM_FULLED:
	  msgbuff[4]=deskx; msgbuff[5]=desky;
	  msgbuff[6]=deskw; msgbuff[7]=deskh;
	 case WM_SIZED:
	  wind_calc(WC_WORK, NAME|CLOSER|FULLER|MOVER|SIZER, 0, 0,
			msgbuff[6], msgbuff[7], &wi_x, &wi_y, &wi_w, &wi_h);
	  switch(blowup)
	   {
		case 1: wi_w &= 0xFFE0; wi_h &= 0xFFFC; break;
		case 2: wi_w=(wi_w+32) & 0xFFC0; wi_h &= 0xFFF8; break;
	   }
	  wind_calc(WC_BORDER, NAME|CLOSER|FULLER|MOVER|SIZER, wi_x, wi_y,
			wi_w, wi_h, &wi_x, &wi_y, &msgbuff[6], &msgbuff[7]);
	case WM_MOVED:
	  wind_set(msgbuff[3], WF_CURRXYWH, msgbuff[4], msgbuff[5],
			msgbuff[6], msgbuff[7]);
	  break;
	case AC_OPEN:
	  setmouseflag();
	  wind_get(wi_handle, WF_WORKXYWH, &wi_x, &wi_y, &wi_w, &wi_h);
	  wi_w=(wi_w+32) & 0xFFC0; wi_h &= 0xFFF8;
	  wind_calc(WC_BORDER, NAME|CLOSER|FULLER|MOVER|SIZER, wi_x, wi_y,
			wi_w, wi_h, &wi_x, &wi_y, &wi_w, &wi_h);
	  wind_set(wi_handle, WF_CURRXYWH, wi_x, wi_y, wi_w, wi_h);
	  break;
   }

  wind_get(wi_handle, WF_WORKXYWH, &wi_x, &wi_y, &wi_w, &wi_h);

  switch(blowup)
   {
   case 1: normalblowup(1); break;
   case 2: normalblowup(2); break;
   case 3: megablowup(); break;
   }

 }
 while( (msgbuff[0]!=WM_CLOSED || msgbuff[3]!=wi_handle)
	  && msgbuff[0]!=AC_CLOSE );

 if(msgbuff[0]!=AC_CLOSE)
  {   wind_close(wi_handle);	 /* Fenster schliežen */
   wind_delete(wi_handle); }  /* Fenster abmelden */

 graf_shrinkbox(x_aufl/2, y_aufl/2, 2, 1, wi_x, wi_y, wi_w, wi_h);
 return(0);
}


/* ***Start*** */
main(void)
{
 long dummy;

 GEM_init();

 wind_update(BEG_UPDATE);
 vq_extnd(vhandle, 1, work_out);
 planes=work_out[4];
 wind_calc(WC_WORK, NAME|CLOSER|FULLER|MOVER|SIZER, deskx, desky,
		   deskw, deskh, &wi_x, &wi_y, &max_x, &max_y);
 dummy=(long)max_x*(long)max_y*(long)planes/8L;
 pic1addr=Malloc(dummy);
 pic2addr=Malloc(dummy/4L);
 pic3addr=Malloc(dummy);
 if(pic1addr<0 || pic2addr<0 || pic3addr<0)
  {
   form_alert(1,"[3][Nicht genug Speicher|brig!][Abbruch]");
   GEM_exit();
   exit(-1);
  }
 mfdb_init();
 for(dummy=MAINBOX; dummy<OKBUTTON+1; dummy++)	rsrc_obfix(tree, (int)dummy);
 form_center(tree, &dialogx, &dialogy, &dialogw, &dialogh);
 wind_update(END_UPDATE);

 if(_app)
   {					/* Normales Programm */
   setmouseflag();
   mag_glass();
   GEM_exit();
   }
  else
   {					/* Accessory */
   menu_id=menu_register(ap_id,"  Magicfying Glass");
   while(-1)
	{
	 evnt_mesag(msgbuff);
	 if(msgbuff[0]==AC_OPEN)  mag_glass();
	 }
   }

 return 0;
}
