/*  ED_ICON.C
 *
 *  aus: Wir basteln uns ein CPX
 *       CPX-Kurs Teil 2
 *       TOS Magazin
 *
 *  (c)1992 by Richard Kurz
 *  Vogelherdbogen 62
 *  7992 Tettnang
 *
 *  Erstellt mit Pure C
 */

#include <aes.h>
#include <vdi.h>
#include <tos.h>
#include <stdio.h>
#include <stddef.h>
#include <string.h>
#include <portab.h>
#include "cpx.h"
#include "link_glo.h"
#include "linkcpx.h"

/* Nur zur Beruhigung von Pure C.    */
struct foobar
{
    WORD    dummy;
    WORD    *image;
};

/* Externe Variablen.											*/
extern GRECT  *w_rect;	/* Die Koordinaten des Fensters.        */
extern XCPB   *xcpb;   	/* Zeiger auf die XControl-Funktionen.  */
extern OBJECT *dialog, 	/* Zeiger auf unsere Dialoge.		*/
			  *iedit; 

/* Globale Variablen.											*/
static int handle;		/* VDI-Handle.							*/

static int open_work(void)
/* ôffnet eine VDI-Workstation.									*/
{
		static int workin[12], workout[57];
		int i;
		
      	for (i=1;i<10;workin[i++]=1);
      	workin[10]=2;
      	i=workin[0]=xcpb->handle;
      	v_opnvwk(workin,&i,workout);
      	if(!i) form_alert(1,"[3][VDI-Workstation konnte|nicht geîffnet werden][ OK ]");
      	return(i);
} /* open_work */

static void draw_icon(int x, int y, int w, int h)
/* Zeichnet das vergrîûerte Icon ohne Clipping 					*/
{
	int i,j,tx,sx,sy,px[8];
	int ic,ib;
	
	vsl_color(handle,1);
	vsf_color(handle,1);
	vsf_perimeter(handle,1);
	vsf_interior(handle,FIS_SOLID);
	vsf_style(handle,0);
	
    x++; y++; tx=x;
	sx=w/32; sy=h/24;
	
	graf_mouse(M_OFF,NULL);
	
	for(ic=0,ib=15,j=0;j<24;j++,y+=sy)
	{
		for(i=0,x=tx;i<32;i++,x+=sx)
		{
			if(iedit[IKLEIN].ob_spec.bitblk->bi_pdata[ic] & (1<<ib))
			{
				px[0]=x;
				px[1]=y;
				px[2]=x+sx-2;
				px[3]=y+sy-2;
				v_bar(handle,px);
			}
			if(--ib<0)
			{
				ic++;
				ib=15;
			}
		}
	}
	graf_mouse(M_ON,NULL);
} /* draw_icon */

static void clipping(GRECT *c, int flag)
/* Vereinfachung von vs_clip().									*/
{
	int px[4];	

	px[0]=c->g_x;
	px[1]=c->g_y;
	px[2]=c->g_w+c->g_x-1;
	px[3]=c->g_h+c->g_y-1;
	vs_clip(handle,flag,px);
} /* clipping */

static void paint_icon(void)
/* Zeichnet das Icon unter Beachtung der Rechteckliste.			*/
{
	GRECT r,clip,*pclip;

    objc_offset(iedit,IGROSS,&r.g_x,&r.g_y);
    r.g_w=iedit[IGROSS].ob_width;
    r.g_h=iedit[IGROSS].ob_height;
	
	pclip=(xcpb->GetFirstRect)(&r);	/* Das erste Rechteck holen.	*/
	while(pclip)					/* Solange Rechtecke da sind.	*/
	{
		clip=*pclip;				/* Koordinaten sichern.	Ist		*/
									/* wichtig, da pclip auf lokale	*/
									/* Variablen zeigt.				*/
		clipping(&clip,TRUE);		/* Clipping einschalten.		*/
		draw_icon(r.g_x,r.g_y,r.g_w,r.g_h); /* Zeichnen.			*/
		pclip=(xcpb->GetNextRect)();/* NÑchstes Rechteck holen.		*/
	}
	clipping(&clip,FALSE);			/* Clipping aus.				*/
} /* paint_icon */

static void paint_pix(int x, int y, int w, int h)
/* Zeichnet ein Pixel unter Beachtung der Rechteckliste.			*/
{
	GRECT r,clip,*pclip;
	int px[4];

    px[0]=r.g_x=x;
    px[1]=r.g_y=y;
    px[2]=x+w;
    px[3]=y+h;
    r.g_w=w+1;
    r.g_h=h+1;
	
	pclip=(xcpb->GetFirstRect)(&r);	/* Erstes Rechteck holen.		*/
	while(pclip)					/* Solange Rechtecke da sind.	*/
	{
		clip=*pclip;				/* Koordinaten sichern.	Ist		*/
									/* wichtig, da pclip auf lokale	*/
									/* Variablen zeigt.				*/
		clipping(&clip,TRUE);		/* Clipping an.					*/
		v_bar(handle,px);			/* Zeichnen.					*/
		pclip=(xcpb->GetNextRect)();/* NÑchstes Rechteck holen.		*/
	}
	clipping(&clip,FALSE);			/* Clipping aus.				*/
} /* paint_pix */

static void plot_pix(int i,int j, int flag)
/* Setzt bzw. lîscht ein Pixel.									*/
{
	
	static int paint,lx,ly;
	int x,y,w,h,sx,sy;
	int ic,ib;
	
    objc_offset(iedit,IGROSS,&x,&y);
    w=iedit[IGROSS].ob_width;
    h=iedit[IGROSS].ob_height;
	sx=w/32;
	sy=h/24;
	
	i=(i-x)/sx;
	j=(j-y)/sy;

	if(i<0 || i>31 || j<0 || j>23) return;
	if(!flag && i==lx && j==ly) return;
	lx=i;
	ly=j;
	
	ic=j*2;
	if(i<=15) ib=0x8000>>i;
	else {ib=0x8000>>(i-16); ic++;}

	if(flag)
	{
		if(iedit[IKLEIN].ob_spec.bitblk->bi_pdata[ic] & ib) paint=FALSE;
		else paint=TRUE;
	}
	if(paint)
	{
		vsl_color(handle,1);
		vsf_color(handle,1);
		iedit[IKLEIN].ob_spec.bitblk->bi_pdata[ic] |= ib;
	}
	else
	{
		vsl_color(handle,0);
		vsf_color(handle,0);
	 	iedit[IKLEIN].ob_spec.bitblk->bi_pdata[ic] &= (0xffff ^ ib);
	}
	graf_mouse(M_OFF,NULL);
	paint_pix(x+i*sx+1,y+j*sy+1,sx-2,sy-2);
    objc_draw(iedit,IRAHMEN,MAX_DEPTH,
                w_rect->g_x,w_rect->g_y,w_rect->g_w,w_rect->g_h);
	graf_mouse(M_ON,NULL);
} /* plot_pix */

static void shift_icon(int r)
/* Verschiebt das Icon um ein Pixel in die Richtung r.			*/
{
	long *icn;
	
	int x;
	
	icn= (long *)iedit[IKLEIN].ob_spec.bitblk->bi_pdata;
	
	switch(r)
	{
		case 1:	for(x=0;x<24;x++)
				{
					icn[x]<<=1;
					icn[x]&=0xfffffffeL;
				} break;
		case 3:	for(x=0;x<24;x++)
				{
					icn[x]>>=1;
					icn[x]&=0x7fffffffL;
				} break;
		case 0: for(x=0;x<23;x++) icn[x]=icn[x+1];
				icn[23]=0; break;
		case 2: for(x=23;x>0;x--) icn[x]=icn[x-1];
				icn[0]=0; break;
	}
} /* shift_icon */

int edit_icon(void)
/* Der Icon-Editor.												*/
{
    GRECT r1;           /* Koordinaten-Feld.                    */
    WORD msg[8];        /* Puffer fÅr Xform_do.                 */
    WORD button,        /* Welches Schweinderl Ñhh button.      */
         ende;          /* Flag fÅr's ENDE.                     */
	int mx,my,mb,mk;	/* Maus-Parameter.						*/
	char *items[8];     /* Zeiger-Feld fÅr die PopUp-MenÅs.     */
	UWORD *icn;			/* Zeiger auf die Icon-Daten.			*/
	
    /* Unser Dialog muû angepaût werden.                        */
    iedit[ROOT].ob_x=w_rect->g_x;
    iedit[ROOT].ob_y=w_rect->g_y;

	/* Icon-Daten holen.										*/    
	memcpy(iedit[IKLEIN].ob_spec.bitblk->bi_pdata,
			dialog[CICON].ob_spec.bitblk->bi_pdata,96L);
	strcpy(iedit[ISTRING].ob_spec.tedinfo->te_ptext,
			dialog[CITEXT].ob_spec.tedinfo->te_ptext);

	/* Dialog zeichnen.											*/
	objc_draw(iedit,ROOT,MAX_DEPTH,
                w_rect->g_x,w_rect->g_y,w_rect->g_w,w_rect->g_h);
	/* VDI-Workstation îffnen.									*/
    handle=open_work();
    if(!handle) return(FALSE);
	/* Das vergrîûerte Icon wird gezeichnet.					*/
	paint_icon();

	ende=FALSE;
    do
    { 
		/* Die Verwaltung des Dialogs Åbernimmt XControl.		*/
        button=(*xcpb->Xform_do)(iedit,0,msg);
		/* Doppel-Klicks ausmaskieren.							*/
   		if((button!=-1)&&(button & 0x8000))
        	button &= 0x7fff;
		switch(button) 
		{
			case IGROSS:
			/* Es wurde auf das vergrîûerte Icon geklickt, der	*/
			/* Anwender mîchte zeichnen.						*/
				graf_mkstate(&mx,&my,&mb,&mk);
				plot_pix(mx,my,TRUE);
				graf_mkstate(&mx,&my,&mb,&mk);
				while(mb)
				{
					plot_pix(mx,my,FALSE);
					graf_mkstate(&mx,&my,&mb,&mk);
				}
				break;

			case IUP: case ILEFT: case IDOWN: case IRIGHT:
			/* Das Icon soll um ein Pixel verschoben werden.	*/
				switch(button)
				{
					case IUP: 	shift_icon(0); break;
					case ILEFT: shift_icon(1); break;
					case IDOWN:	shift_icon(2); break;
					case IRIGHT:shift_icon(3); break;
				}
				objc_draw(iedit,IGROSS,MAX_DEPTH,
           			w_rect->g_x,w_rect->g_y,w_rect->g_w,w_rect->g_h);
				paint_icon();
				objc_draw(iedit,IRAHMEN,MAX_DEPTH,
           			w_rect->g_x,w_rect->g_y,w_rect->g_w,w_rect->g_h);
	        	iedit[button].ob_state &= ~SELECTED;
				objc_draw(iedit,button,MAX_DEPTH,
           			w_rect->g_x,w_rect->g_y,w_rect->g_w,w_rect->g_h);
				break;

			case IDEL: case IDEL2:
			/* SchnÅff, jemand will das Icon lîschen.			*/
				mk=form_alert(2,"[2][ |ICON lîschen?][ Ja | Nein ]");
				if(mk==1)
				{
					memset((char *)iedit[IKLEIN].ob_spec.bitblk->bi_pdata,
							0,96L);
   					objc_draw(iedit,IGROSS,MAX_DEPTH,
                			w_rect->g_x,w_rect->g_y,w_rect->g_w,w_rect->g_h);
   					objc_draw(iedit,IRAHMEN,MAX_DEPTH,
                			w_rect->g_x,w_rect->g_y,w_rect->g_w,w_rect->g_h);
				}
	        	iedit[button].ob_state &= ~SELECTED;
				objc_draw(iedit,IDEL,MAX_DEPTH,
           			w_rect->g_x,w_rect->g_y,w_rect->g_w,w_rect->g_h);
				break;

			case DATEI:
			/* PopUp zum Laden bzw. Sichern des Icons.			*/
            	items[0]="  Quellcode laden   ";
            	items[1]="  Quellcode sichern ";
            
            	objc_offset(iedit,DATEI,&r1.g_x,&r1.g_y);
            	r1.g_w=iedit[DATEI].ob_width;
            	r1.g_h=iedit[DATEI].ob_height;
            
            	mk=(*xcpb->Popup)(items,2,-1,3,&r1,w_rect);
				if(mk==0)
				{
					icn=read_icon();
					if(icn!=NULL)
					{
						memcpy(
							iedit[IKLEIN].ob_spec.bitblk->bi_pdata,
							icn,96L);
						objc_draw(iedit,IGROSS,MAX_DEPTH,
                			w_rect->g_x,w_rect->g_y,w_rect->g_w,w_rect->g_h);
						paint_icon();
   						objc_draw(iedit,IRAHMEN,MAX_DEPTH,
                			w_rect->g_x,w_rect->g_y,w_rect->g_w,w_rect->g_h);
					}
				}
				else if(mk==1)
					write_icon((UWORD *)iedit[IKLEIN].ob_spec.bitblk->bi_pdata);
            	break;
            
			case IOK:
			/* OK, die Icon-Daten mÅssen gesichert werden.		*/
				memcpy(dialog[CICON].ob_spec.bitblk->bi_pdata,
						iedit[IKLEIN].ob_spec.bitblk->bi_pdata,96L);
				strcpy(dialog[CITEXT].ob_spec.tedinfo->te_ptext,
						iedit[ISTRING].ob_spec.tedinfo->te_ptext);
			case IABBRUCH:
			/* Und TschÅû.										*/
	        	iedit[button].ob_state &= ~SELECTED;
				ende=TRUE;
				break;

			default:
            /* Wenn Xform_do -1 zurÅckliefert, ist etwas im     */
            /* Busche, bzw. im Message-Puffer. Der Aufbau des   */
            /* Puffers ist Ñhnlich wie bei evnt_mesag.          */
 	            if(button==-1)
    	        {
        	        switch(msg[0])
            	    {
                	    case WM_CLOSED:
                    	case AC_CLOSE:
                    	/* Das CPX-Modul wird geschlossen!		*/
                    	/* Nichts wie raus hier, aber nicht die	*/
                    	/* VDI-Workstation vergessen.			*/
							v_clsvwk(handle);
                        	return(TRUE);
        	            case WM_REDRAW:
        	            /* XControl zeichnet den Dialog neu. Da	*/
        	            /* es unser groûes Icon nicht kennt, 	*/
        	            /* mÅssen wir es selber zeichnen.		*/
							paint_icon();
            	        default:
                	        break;
	                }
    	        }
				break;
		}
    } while(!ende);
    /* Unbedingt die VDI-Workstation schlieûen!!!				*/
	v_clsvwk(handle);
	return(FALSE);
}; /* edit_icon */