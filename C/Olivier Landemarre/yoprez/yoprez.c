#include <osbind.h>
#include <gem.h>
#include <stdio.h>
#include "yoprez.h"
#ifdef __PUREC__
#include "biosdefs.h"
#else
#ifndef VsetMode
#define VsetMode(mode)							\
	(short)trap_14_ww((short)88,(short)(mode))
#endif
#endif


typedef struct 
{
    OBJECT  *tree;     /* Popup menu               */
    short  obnum;    /* Current object of <tree> */
} MYPOPINFO;


typedef struct
{
   long  id,
      valeur;
} COOKJAR;

char *nom_fenetre="AES resolution change";



OBJECT *rezs,*mods,*select,*sttt,*bpp;
MYPOPINFO resopop,resobpp,resosttt, modopop;


static COOKJAR *get_cookie(long cookie)
{
   long oldssp;
   COOKJAR  *cookie_ptr;

   oldssp = (long)Super ((void *)1L);
   if( oldssp == 0L)
   { 
   		oldssp = (long)Super((void *)0L);
   		cookie_ptr = *((COOKJAR **)0x05a0l);
   		Super((void *)oldssp);
   }
   else cookie_ptr = *((COOKJAR **)0x05a0l);
   

   if(cookie_ptr!=NULL)
   {
      do
      {
         if(cookie_ptr->id == cookie)
            return(cookie_ptr);
     
      } while((cookie_ptr++)->id != 0L)  ;
   }
   return(0l);
}

static void mywind_set_pt(int handle, int type, void *mypt, int a, int b)
{	unsigned long add=(unsigned long)mypt;
	unsigned short *pt1=(unsigned short *)&add, *pt2;
			pt2=pt1;
			pt2++;
			wind_set(handle,type,*pt1,*pt2,a,b);
}

static void prepare_select(int type)
{
	switch (type)
	{
		case 1:  /* ST TT modes */
			select[TYPE1].ob_state|=OS_SELECTED;
			select[TYPE2].ob_state&=~OS_SELECTED;
			select[TYPE3].ob_state&=~OS_SELECTED;
			select[MODO].ob_flags|=OF_HIDETREE;
			select[COL80].ob_flags|=OF_HIDETREE;
			select[VGA].ob_flags|=OF_HIDETREE;
			select[PAL].ob_flags|=OF_HIDETREE;
			select[OVERSCAN].ob_flags|=OF_HIDETREE;
			select[COMPAT].ob_flags|=OF_HIDETREE;
			select[VERTICAL].ob_flags|=OF_HIDETREE;
			resosttt.tree=sttt;
			
			select[RESO].ob_spec.tedinfo=(TEDINFO *)&resosttt;
			select[RESO].ob_width=sttt[0].ob_width;
		break;
		case 2:	/* Falcon modes */
			select[TYPE2].ob_state|=OS_SELECTED;
			select[TYPE1].ob_state&=~OS_SELECTED;
			select[TYPE3].ob_state&=~OS_SELECTED;
			select[MODO].ob_flags|=OF_HIDETREE;
			select[COL80].ob_flags&=~OF_HIDETREE;
			select[VGA].ob_flags&=~OF_HIDETREE;
			select[PAL].ob_flags&=~OF_HIDETREE;
			select[OVERSCAN].ob_flags&=~OF_HIDETREE;
			select[COMPAT].ob_flags&=~OF_HIDETREE;
			select[VERTICAL].ob_flags&=~OF_HIDETREE;
			resobpp.tree=bpp;
			
			select[RESO].ob_spec.tedinfo=(TEDINFO *)&resobpp;
			select[RESO].ob_width=bpp[0].ob_width;
		break;
		case 3:	/* Saga modes */
			select[TYPE3].ob_state|=OS_SELECTED;
			select[TYPE2].ob_state&=~OS_SELECTED;
			select[TYPE1].ob_state&=~OS_SELECTED;
			select[MODO].ob_flags&=~OF_HIDETREE;
			select[COL80].ob_flags|=OF_HIDETREE;
			select[VGA].ob_flags|=OF_HIDETREE;
			select[PAL].ob_flags|=OF_HIDETREE;
			select[OVERSCAN].ob_flags|=OF_HIDETREE;
			select[COMPAT].ob_flags|=OF_HIDETREE;
			select[VERTICAL].ob_flags|=OF_HIDETREE;
			resopop.tree=rezs;
			resopop.obnum=1;
			select[RESO].ob_spec.tedinfo=(TEDINFO *)&resopop;
			select[RESO].ob_width=rezs[0].ob_width;
			select[MODO].ob_width=mods[0].ob_width;
		break;
		default : break;
	}
}

static void switchrez(void)
{	int type=0, reso=0,wiscr=0; unsigned short extension=0;
		if(select[TYPE1].ob_state&OS_SELECTED) type=1;
		if(select[TYPE2].ob_state&OS_SELECTED) type=2;
		if(select[TYPE3].ob_state&OS_SELECTED) type=3;
		switch (type)
		{
			case 1: /* ST et TT resolutions */
				switch(resosttt.obnum)
				{
					case 1: /* STLow */
						reso=ST_LOW;
					break;
					case 2: /* STMid */
						reso=ST_MEDIUM;
					break;
					case 3: /* STHIGH */
						reso=ST_HIGH;
					break;
					case 4: /* TTLow */
						reso=TT_LOW;
					break;
					case 5: /* TTMid */
						reso=TT_MEDIUM;
					break;
					case 6: /* TTHigh */
						reso=TT_HIGH;
					break;
					default:
					break;
				}
			break;
			case 2: /* Falcon */
		/*		reso=3;*/
				wiscr=1;
				extension=resobpp.obnum-1;
				if(select[COL80].ob_state&OS_SELECTED) extension|=VIDEL_80COL;
				if(select[VGA].ob_state&OS_SELECTED) extension|=VIDEL_VGA;
				if(select[PAL].ob_state&OS_SELECTED) extension|=VIDEL_PAL;
				if(select[OVERSCAN].ob_state&OS_SELECTED) extension|=VIDEL_OVERSCAN;
				if(select[COMPAT].ob_state&OS_SELECTED) extension|=VIDEL_COMPAT;
				if(select[VERTICAL].ob_state&OS_SELECTED) extension|=VIDEL_VERTICAL;
			break;
			case 3: /* Saga */
			/*	reso=103;*/
				wiscr=1; /*103 */
				extension=resopop.obnum<<8;
				extension|=0x4000; /* mode ‚tendu pour SAGA */
				switch(modopop.obnum)
				{
					case 1 : /*1BPP*/
						extension|=0x8;
					break;
					case 2 : /*2BPP*/
						extension|=0x9;
					break;
					case 3 : /*4BPP*/
						extension|=0xA;
					break;
					case 5 : /*YUV*/
						extension|=0x6;
					break;
					case 6 : /*8bits chunckyP*/
						extension|=0x1;
					break;
					case 7 : /*15 bits*/
						extension|=0x3;
					break;
					case 8 : /*16 bits*/
						extension|=0x2;
					break;
					case 9 : /*24bits*/
						extension|=0x4;
					break;
					case 10 : /*32 bits*/
						extension|=0x5;
					break;
					case 4: /*8BPP non impl‚ment‚**/
					default:
					break;
				}
			break;
			default: break;
		}
		if(type!=0)
		{
			if(wiscr==0) shel_write(5/* rezchange*/,reso+2,wiscr,NULL,NULL);
			else shel_write(5/* rezchange*/,extension,wiscr,NULL,NULL);
		}
}

static void gere_events(int win_main_hdl)
{	int flag=1;
	short ev_mbclicks=0x101, ev_mbmask=0x0, ev_mbstate=0x000,
        ev_mmgpbuff[8], ev_mmox, ev_mmoy, 
        ev_mmbutton, ev_mmokstate, 
        ev_key, ev_mkreturn;




	while(flag==1)
	{       short ev_mflags,retour;
		ev_mflags=MU_MESAG;
		
		retour = evnt_multi(ev_mflags,
               ev_mbclicks, ev_mbmask, ev_mbstate,
               0, 0, 0, 
               0, 0,
               0, 0, 0, 
               0, 0,
               &ev_mmgpbuff[0], 0,
               &ev_mmox, &ev_mmoy, 
               &ev_mmbutton, &ev_mmokstate,&ev_key, &ev_mkreturn);
		if(retour & MU_MESAG)
		{
			switch(ev_mmgpbuff[0])
			{
				case WM_CLOSED:
				case AP_TERM:
					flag = 0;
				break;
				case WM_MOVED:
					wind_set(ev_mmgpbuff[3], WF_CURRXYWH,ev_mmgpbuff[4],ev_mmgpbuff[5],ev_mmgpbuff[6],ev_mmgpbuff[7]);
				break;
				case WM_TOPPED:
					wind_set(ev_mmgpbuff[3], WF_TOP,ev_mmgpbuff[4],ev_mmgpbuff[5],ev_mmgpbuff[6],ev_mmgpbuff[7]);
				break;
				case WM_TOOLBAR:
					switch (ev_mmgpbuff[4])
					{
						case TYPE1:
							prepare_select(1);
							mywind_set_pt( win_main_hdl, WF_TOOLBAR,(void *)select, 0, 0);
						break;
						case TYPE2:
							prepare_select(2);
							mywind_set_pt( win_main_hdl, WF_TOOLBAR,(void *)select, 0, 0);
						break;
						case TYPE3:
							prepare_select(3);
							mywind_set_pt( win_main_hdl, WF_TOOLBAR,(void *)select, 0, 0);
						break;
						case CANCEL:
							if(ev_mmgpbuff[5]>0) flag = 0;
						break;
						case APPLY:
								flag = 0;
								switchrez();
						break;
						default: 
						break;
					}
				break;
				default:
				break;
			}
		}

	}

}







void main(void)
{	
	
	short dummy,ww,wh, actualrez;
	int win_main_handle;
	COOKJAR *vdo;
	
	vdo=get_cookie('_VDO');
	appl_init();
	if(rsrc_load("yoprez.rsc"))
	{
		(void)rsrc_gaddr(R_TREE,RESOLUTION,&rezs);
		(void)rsrc_gaddr(R_TREE,REZMODE,&mods);
		(void)rsrc_gaddr(R_TREE,SELECT,&select);
		(void)rsrc_gaddr(R_TREE,STTT,&sttt);
		(void)rsrc_gaddr(R_TREE,BPP,&bpp);
		resopop.tree=rezs;
		resopop.obnum=1;
		modopop.tree=mods;
		modopop.obnum=1;
		resosttt.obnum=1;
		resobpp.obnum=1;
		select[RESO].ob_type=G_POPUP;
		select[RESO].ob_spec.tedinfo=(TEDINFO *)&resopop;
		select[MODO].ob_type=G_POPUP;
		select[MODO].ob_spec.tedinfo=(TEDINFO *)&modopop;
		actualrez=Getrez();
		if(vdo && vdo->valeur >= 0x30000L/*(actualrez==3) || (actualrez==3) || (actualrez==103)*/)
		{
			if(actualrez==103) prepare_select(3);
			else 
			{	unsigned long mode;
				mode=VsetMode(-1);
				if(mode&0x4000)  prepare_select(3);
				else
				{
					prepare_select(2);
					if(mode&VIDEL_80COL) select[COL80].ob_state|=OS_SELECTED;
					if(mode&VIDEL_VGA) select[VGA].ob_state|=OS_SELECTED;
					if(mode&VIDEL_PAL) select[PAL].ob_state|=OS_SELECTED;
					if(mode&VIDEL_OVERSCAN) select[OVERSCAN].ob_state|=OS_SELECTED;
					if(mode&VIDEL_COMPAT) select[COMPAT].ob_state|=OS_SELECTED;
					if(mode&VIDEL_VERTICAL) select[VERTICAL].ob_state|=OS_SELECTED;
					resobpp.obnum=(mode&0x7)+1;
					if((mode&0x7)<3) resosttt.obnum=(mode&0x7)+1;
				}
			}
		}
		else
		{
			prepare_select(1);
			switch (actualrez)
			{
				case ST_MEDIUM:
					resosttt.obnum=2;
				break;
				case ST_HIGH:
					resosttt.obnum=3;
				break;
				case TT_LOW:
					resosttt.obnum=4;
				break;
				case TT_MEDIUM:
					resosttt.obnum=5;
				break;
				case TT_HIGH:
					resosttt.obnum=6;
				break;
				case ST_LOW:
				default :
					resosttt.obnum=1;
				break;
			}
			
		}
		
		wind_calc(0,MOVER|CLOSER|NAME,0,0,select->ob_width,select->ob_height,&dummy,&dummy,&ww,&wh);
		win_main_handle=wind_create(MOVER|CLOSER|NAME,0,0,ww,wh);
		if(win_main_handle>0)
		{	short x,y,w,h;
		/*	unsigned short *pt1=(unsigned short *)&select, *pt2;
			pt2=pt1;
			pt2++;
			wind_set(win_main_handle,WF_TOOLBAR,*pt1,*pt2,0,0);*/
			mywind_set_pt(win_main_handle, WF_NAME,(void *)nom_fenetre, 0, 0);
			mywind_set_pt(win_main_handle, WF_TOOLBAR,(void *)select, 0, 0);
			

			wind_get(0,WF_WORKXYWH,&x,&y,&w,&h); /* on r‚cupŠre la taille de l'‚cran sans passer par la VDI */
			if(wind_open(win_main_handle,(w-ww)>>1,(h-wh)>>1,ww,wh))
			{
					gere_events(win_main_handle);
					wind_close(win_main_handle);
			}
			wind_delete(win_main_handle);
		}
		rsrc_free();
	}
	appl_exit();
}
