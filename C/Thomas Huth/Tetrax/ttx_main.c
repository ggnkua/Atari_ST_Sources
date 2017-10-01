/*### TTX_MAIN.C - The main loops and the 'shell' ###*/

/********************************************/
/* Tetrax - The XBIOS MODule player			*/
/*											*/
/* Written 2000 and (C) by Thomas Huth      */
/* See the readmes for more information		*/
/* Set tabsize to 4							*/
/********************************************/

#include <aes.h>
#include <osbind.h>
#include <string.h>
#include <stdlib.h>
#include "ttx_init.h"
#include "ttx_rsc.h"
#include "ttx_disk.h"
#include "ttx_aes.h"
#include "modmesag.h"
#include "xgriff.h"

#ifndef FALSE
#define FALSE 0
#define TRUE  (!0)
#endif

#define WINGADGETS	(NAME|CLOSER|MOVER|SMALLER)

#ifdef SOZOBON
extern short _app;			/* Accessory or Application? */
#endif

#ifdef __TURBOC__
#define SMALLER 0x4000
#define WF_BOTTOM       25
#define WF_ICONIFY      26
#define WF_UNICONIFY    27
#define WM_BOTTOMED     33
#define WM_ICONIFY      34
#define WM_UNICONIFY    35
#define WM_ALLICONIFY   36
#define AP_TERM         50
#define AP_RESCHG       57
#define AP_DRAGDROP     63
#define Pdomain(arg)	gemdos(0x119, (short)(arg))
#define lmemcpy memcpy
#endif

short	ap_id;				/* AES programm id */
void	*modbuf=0L;			/* Pointer to the module */
int 	msgbuf[8];			/* Mesage buffer */
short	whndl;				/* Window handle */
GRECT	wi;					/* To store window coordinates */
int 	mousx, mousy;		/* Mouse coordinates */
char	fmask[16];			/* File mask */
short	pdom;				/* FALSE=TOS-domain, TRUE=MiNT-domain */
short	exitflag=FALSE; 	/* FALSE=Continue, TRUE=end loop */
int 	dlgmode=1;			/* 0=iconified, 1=Main dialog, 2=setup dialog, 3=about dialog */
OBJECT *dlgs[4];
int 	freq=2;				/* 1=12kHz, 2=25kHz, 3=50kHz */
int 	eofrmode=1;         /* End of frame mode */
void	(*oldetvterm)();		/* Old etv_term pointer */

char skinpathname[256];
char skinfilename[64];


/* *** Special mesages *** */
void extramesages(void)
{
 switch(msgbuf[0])
  {
   case VA_START:
	 if(*(void **)&msgbuf[3])
	 {
	   getcommand(*(void **)&msgbuf[3]);
	   if(modbuf)
	   {
        if( mod_play(modbuf) )
          form_alert(1,"[3][Can't start playing!|(Sound system locked?)][Ok]");
       }
       if(dlgmode==1)  redraw_objc(MODNAME);
 	 }
	 break;
   case MOD_PLAY:
	 if(modbuf)
	   {
		mod_play(modbuf);
		sendmesag(msgbuf[1], MOD_OK);
	   }
	  else
	   sendmesag(msgbuf[1], MOD_NAK);
	 break;
   case MOD_STOP:
	 mod_stop();
	 sendmesag(msgbuf[1], MOD_OK);
	 break;
   case MOD_LOAD:
	 mod_stop();
	 getcommand(*(void **)&msgbuf[3]);
	 sendmesag(msgbuf[1], modbuf ? MOD_OK : MOD_NAK);
	 break;
   case MOD_CLEAR:
	 if(modbuf) { mod_stop(); accmfree(modbuf); }
	 modbuf=0L;
	 sendmesag(msgbuf[1], MOD_OK);
	 break;
  }
}

/* *** Mesage events *** */
void mesages(void)
{
 OBJECT *dlg;
 static short olddlgmode=0;

 dlg=dlgs[dlgmode];

 switch(msgbuf[0])
  {
   case AC_OPEN:
   case WM_TOPPED:
       wind_set(whndl, WF_TOP, 0L, 0L);
       break;
   case WM_MOVED:
       wind_set(whndl, WF_CURRXYWH, msgbuf[4], msgbuf[5], msgbuf[6], msgbuf[7]);
       wind_calc(WC_WORK, WINGADGETS, msgbuf[4], msgbuf[5], msgbuf[6], msgbuf[7],
              &dlg->ob_x, &dlg->ob_y, &dlg->ob_width, &dlg->ob_height);
       break;
   case WM_REDRAW:
       wdial_redraw(whndl, dlg, (GRECT *)&msgbuf[4]);
       break;
   case WM_BOTTOMED:
       wind_set(whndl, WF_BOTTOM, 0L, 0L);
       break;
   case WM_ALLICONIFY:
   case WM_ICONIFY:
       wind_get(whndl, WF_CURRXYWH, &wi.g_x, &wi.g_y, &wi.g_w, &wi.g_h);
       olddlgmode=dlgmode;
       dlgmode=0;
       wind_set(whndl, WF_ICONIFY, msgbuf[4], msgbuf[5], msgbuf[6], msgbuf[7]);
       wind_get(whndl, WF_WORKXYWH, &itree->ob_x, &itree->ob_y, &itree->ob_width, &itree->ob_height);
       itree[ICNFICON].ob_x=(itree[ICNFBOX].ob_width-itree[ICNFICON].ob_width)/2;
       itree[ICNFICON].ob_y=(itree[ICNFBOX].ob_height-itree[ICNFICON].ob_height)/2;
       wdial_redraw(whndl, itree, (GRECT *)&msgbuf[4]);
       break;
   case WM_UNICONIFY:
       dlgmode=olddlgmode;
       wind_set(whndl, WF_UNICONIFY, wi.g_x, wi.g_y, wi.g_w, wi.g_h);
       wdial_redraw(whndl, dlgs[dlgmode], &wi);
       break;
   case AP_TERM:
   case AP_RESCHG:
       mod_stop();
       if(modbuf)  accmfree(modbuf);
       modbuf=0L;
   case AC_CLOSE:
   case WM_CLOSED:
       exitflag=TRUE;
       break;
   case AP_DRAGDROP:
       dragdrop(msgbuf[7]);
       if(modbuf)
        if( mod_play(modbuf) )
         form_alert(1,"[3][Can't start playing!|(Sound system locked?)][Ok]");
       if(dlgmode==1)  redraw_objc(MODNAME);
       break;
   default:
       extramesages();
       break;
  }
}


/* *** Mouse click *** */
void mouseclick(void)
{
 int choice, ret, i;
 OBJECT *dlg;
 int modechanged=0;

 if(dlgmode==0)  return;
 dlg=dlgs[dlgmode];

 if( (choice=objc_find(dlg, ROOT, 2, mousx, mousy)) == -1 )  return;
 if( dlg[choice].ob_state & DISABLED )	return;

 if( dlg[choice].ob_flags&TOUCHEXIT )
   { dlg[choice].ob_state^=SELECTED; redraw_objc(choice); }
  else
   { if( form_button(dlg, choice, 1, &choice) ) return; }

 if(dlgmode==1)      /* Main dialog */
   {
    switch(choice)
     {
      case LOADBUT:
        mod_stop();
        strcat(pathname, fmask);
        if( fselector(pathname, filename, &ret, "Choose a MOD") == 0 )	break;
        for(i=strlen(pathname) ; i>=0; i--)
         if( pathname[i]=='\\' ) break;
        strcpy(fmask, &pathname[i+1]);
        pathname[i+1]=0;
        if(ret==0) break;
        load_mod();
        redraw_objc(MODNAME);
        break;
      case PLAYBUT:
        if(modbuf)
          {
           if( mod_play(modbuf) )
            form_alert(1,"[3][Can't start playing!|(Sound system locked?)][Ok]");
          }
         else
          form_alert(1, "[3][You must first|load a module!][ OK ]");
        break;
      case STOPBUT:
        mod_stop();
        break;
      case BWARDBUT:
        mod_backward();
        evnt_timer(10,0);
        break;
      case FWARDBUT:
        mod_forward();
        evnt_timer(10,0);
        break;
      case SETUPBUT:
        dlgmode=2;
        modechanged=TRUE;
        wind_calc(WC_BORDER, WINGADGETS, maindlg->ob_x, maindlg->ob_y,
          setupdlg->ob_width, setupdlg->ob_height, &wi.g_x, &wi.g_y, &wi.g_w, &wi.g_h);
        wind_set(whndl, WF_CURRXYWH, wi.g_x, wi.g_y, wi.g_w, wi.g_h);
        wind_calc(WC_WORK, WINGADGETS, wi.g_x, wi.g_y, wi.g_w, wi.g_h,
             &setupdlg->ob_x, &setupdlg->ob_y, &setupdlg->ob_width, &setupdlg->ob_height);
        wdial_redraw(whndl, dlgs[dlgmode], (GRECT *)&wi);
        break;
      case ABOUTBUT:
        dlgmode=3;
        modechanged=TRUE;
        wind_calc(WC_BORDER, WINGADGETS, maindlg->ob_x, maindlg->ob_y,
          aboutdlg->ob_width, aboutdlg->ob_height, &wi.g_x, &wi.g_y, &wi.g_w, &wi.g_h);
        wind_set(whndl, WF_CURRXYWH, wi.g_x, wi.g_y, wi.g_w, wi.g_h);
        wind_calc(WC_WORK, WINGADGETS, wi.g_x, wi.g_y, wi.g_w, wi.g_h,
             &aboutdlg->ob_x, &aboutdlg->ob_y, &aboutdlg->ob_width, &aboutdlg->ob_height);
        wdial_redraw(whndl, dlgs[dlgmode], (GRECT *)&wi);
        break;
      case EXITBUT:
        exitflag=TRUE;
        break;
     }
   }
  else if(dlgmode==2)     /* Setup dialog */
   {
    switch(choice)
     {
      case EOFRBUT:
        if(  wdial_popupbutn(dlg, EOFRBUT, eofrpop, &eofrmode) )
          mod_setup(2, eofrmode-FRLOW);
        break;
      case FREQBUT:
        if(  wdial_popupbutn(dlg, FREQBUT, freqpop, &freq) )
          mod_setup(0, freq-FRLOW);
        break;
/*
      case MSBUT:
        if( wdial_popupbutn(dlg, MSBUT, mostepop, &i) )
          mod_setup(MSUMOSTE, i-MONO);
        break;
*/
      case LSKINBUT:
        strcat(skinpathname, ( pdom ? "*.rsc" : "*.RSC") );
        if( fselector(skinpathname, skinfilename, &ret, "Choose a skin") == 0 )
          break;
        for(i=strlen(skinpathname) ; i>=0; i--)
          if( skinpathname[i]=='\\' )  break;
        strcpy(&skinpathname[i+1], skinfilename);
        loadskin(skinpathname);
        skinpathname[i+1] = 0;
        wdial_redraw(whndl, dlgs[dlgmode], (GRECT *)&wi);
        break;
      case SUOKAY:
        dlgmode=1;
        modechanged=TRUE;
        wind_calc(WC_BORDER, WINGADGETS, setupdlg->ob_x, setupdlg->ob_y,
          maindlg->ob_width, maindlg->ob_height, &wi.g_x, &wi.g_y, &wi.g_w, &wi.g_h);
        wind_set(whndl, WF_CURRXYWH, wi.g_x, wi.g_y, wi.g_w, wi.g_h);
        wind_calc(WC_WORK, WINGADGETS, wi.g_x, wi.g_y, wi.g_w, wi.g_h,
             &maindlg->ob_x, &maindlg->ob_y, &maindlg->ob_width, &maindlg->ob_height);
        wdial_redraw(whndl, dlgs[dlgmode], (GRECT *)&wi);
        break;
      }
   }
  else if(dlgmode==3)        /* About dialog */
   {
    if(choice==ABOKAY)
      {
        dlgmode=1;
        modechanged=TRUE;
        wind_calc(WC_BORDER, WINGADGETS, aboutdlg->ob_x, aboutdlg->ob_y,
          maindlg->ob_width, maindlg->ob_height, &wi.g_x, &wi.g_y, &wi.g_w, &wi.g_h);
        wind_set(whndl, WF_CURRXYWH, wi.g_x, wi.g_y, wi.g_w, wi.g_h);
        wind_calc(WC_WORK, WINGADGETS, wi.g_x, wi.g_y, wi.g_w, wi.g_h,
             &maindlg->ob_x, &maindlg->ob_y, &maindlg->ob_width, &maindlg->ob_height);
        wdial_redraw(whndl, dlgs[dlgmode], (GRECT *)&wi);
       }
   }

 if( !(dlg[choice].ob_flags & RBUTTON) )
   dlg[choice].ob_state&=~SELECTED;			/* Unselect object */
 if( !modechanged )
   redraw_objc(choice);
}


/* *** The main loop *** */
void tetraloop(void)
{
 int wichevnt, useevnts, i;

 /* Init the window: */
 wind_calc(WC_BORDER, WINGADGETS, maindlg->ob_x, maindlg->ob_y,
        maindlg->ob_width, maindlg->ob_height, &wi.g_x, &wi.g_y, &wi.g_w, &wi.g_h);
 whndl=wind_create(WINGADGETS, 0, 0, wi.g_w, wi.g_h);
 if(whndl<0)
  {
   form_alert(1,"[3][No more windows!][I'll close some]");
   return;
  }
 /* Set the window name: */
#ifdef TTX_DSP
 wind_set(whndl, WF_NAME, "TetraxDSP", 0L);
#else
 wind_set(whndl, WF_NAME, " Tetrax ", 0L);
#endif
 wind_open(whndl, wi.g_x, wi.g_y, wi.g_w, wi.g_h);	/* Open window */

 wdial_redraw(whndl, maindlg, &wi); /* Draw dialog */

 do
  {
#ifdef TTX_DSP
   useevnts = MU_MESAG|MU_BUTTON;
#else
   if(playflag && eofrmode<=2)
     useevnts = MU_MESAG|MU_BUTTON|MU_TIMER;
   else
     useevnts = MU_MESAG|MU_BUTTON;
#endif
   wichevnt=evnt_multi(useevnts, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
              msgbuf, 0, 0, &mousx, &mousy, &i, &i, &i, &i);

   if(wichevnt & MU_TIMER) checkbuf();
   if(wichevnt & MU_MESAG) mesages();
   if(wichevnt & MU_BUTTON) mouseclick();
  }
 while( !exitflag );

 if( msgbuf[0]!=AC_CLOSE )     /* Close and delete window */
  {
   wind_close(whndl);
   wind_delete(whndl);
  }

}


/* *** A new etv_term vector for anormal program terminations *** */
void myetvterm()
{
 mod_stop();
 Setexc(258, oldetvterm);
}


/* *** The main function *** */
short main(int argc, char *argv[])
{
 if( !_app || Pdomain(1)<0L )			/* Try to enter MiNT-Domain */
   { pdom=FALSE; Pdomain(0); }
  else
   { pdom=TRUE; Pdomain(1); }

 enterGEM();

 if( mod_init() )   /* Player initialisieren */
  {
   form_alert(1,"[3][Tetrax error:|Can't init the player|(not enough memory?)][Cancel]");
   if(_app)
     { exitGEM(); exit(-1); }
    else
     { while(-1) evnt_timer(32000,32000); }
  }

 pathname[0]='A'+Dgetdrv(); pathname[1]=':';	/* prepare path name */
 Dgetpath(&pathname[2], 0);
 strcat(pathname, "\\");
 strcpy(fmask, ( pdom ? "*.mod" : "*.MOD") );

 strcpy(skinpathname, pathname);
 skinfilename[0] = 0;

 /* Accessory: */
 if(!_app)
  {
   while(-1)
	{
	 if(playflag && eofrmode<=2)
	  {
	   int d;
	   do
	    {
         d=evnt_multi(MU_MESAG|MU_TIMER,1,1,1,0,0,0,0,0,0,0,0,0,0,
                 msgbuf, 1,0, &d,&d,&d,&d,&d,&d);
         checkbuf();
        }
       while( (d & MU_MESAG)==0 );
	  }
	  else
	   evnt_mesag(msgbuf);
	 switch(msgbuf[0])
	  {
	   case AC_OPEN:
		 tetraloop();
		 exitflag=FALSE;
		 break;
	   case AP_TERM:
	   case AP_RESCHG:
		 mod_stop();
		 if(modbuf)  accmfree(modbuf);
		 modbuf=0L;
		 break;
	   default:
		 if(msgbuf[0]>=0x4000) extramesages();
		 break;
	  }
	}
  }

 /* Normal programm: */

 oldetvterm=Setexc(258, myetvterm);

 if(argc>1)		getcommand(argv[1]);
 if(modbuf)		mod_play(modbuf);
 tetraloop();

 Setexc(258, oldetvterm);

 mod_stop();
 if(modbuf)		accmfree(modbuf);
 exitGEM();

 return(0);
}
