#include <grape_h.h>
#include "grape.h"
#include "undo.h"
#include "layer.h"
#include "mask.h"
#include "preview.h"
#include "undocop.h"
#include "mforms.h"
#include "xrsrc.h"
#include "jobs.h"

/*

 UNDO 
 
*/

/*
	undo_start = Zeiger auf erstes Byte des aktuellen Blocks
	undo_end =   Zeiger auf Schreibposition
	undo_maxend = Zeiger auf maximale Schreibposition
								(bei erreichen resize_undo() aufrufen)

	undo_buffers = Anzahl der benutzten (allozierten) Blîcke
								
Undo-Eintrag: 
word info: 
     255 = Es folgt ein Zeigerpaar auf den nÑchsten Pufferblock
     			(falls NULL = Pufferende)
     254 = Es folgt ein Zeigerpaar auf den vorigen Pufferblock
     			(falls NULL = Pufferanfang)
     253 = ungÅltiger Eintrag, ignorieren
     			(z.B. ausgenullte EintrÑge nach dem Lîschen einer Ebene)
     			Trotzdem auf das Maskeflag achten um Grîûe zu bestimmen!!!
     			 
     sonstige: ID des Layers [ | 512 ] [ | 1024] [ | 2048]

falls ID des Layers:
word x-pos: X-Position des Blocks
word y-pos: Y-Position des Blocks
word width: Breite
word height: Hîhe

falls | 512:
n*char(grey): Alter Wert
sonst:
n*(char red, char yellow, char blue): Alte Werte

falls | 1024:
der nÑchste Block gehîrt gleich mit dazu
falls | 2048:
der vorherige Block gehîrt gleich mit dazu

immer:
long size: Gesamtgrîûe des Undo-Eintrags (incl. size!)


*/	

void	init_undo(void)
{
	if(undo_start)
		free(undo_start);
	undo_start=(unsigned char*)malloc(UNDO_BUFSIZ+64*64*3+14+14);
	if(undo_start)
	{
		undo_end=undo_start;
		*undo_end++=0;
		*undo_end++=254; /* Typ voriges Zeigerpaar */
		*(unsigned long*)undo_end=0l; /* Zeiger auf Blockanfang ist Null*/
		undo_end+=4;
		*(unsigned long*)undo_end=0l; /* Zeiger auf letzten Eintrag ist Null*/
		undo_end+=4;
		*undo_end++=0;
		*undo_end++=0;
		*undo_end++=0;
		*undo_end++=14; /* GesamtlÑnge */
		
		*undo_end++=0;
		*undo_end++=255; /* Typ nÑchstes Zeigerpaar */
		*(unsigned long*)undo_end=0l; /* Zeiger auf Blockanfang ist Null*/
		undo_end+=4;
		*(unsigned long*)undo_end=0l; /* Zeiger auf letzten Eintrag ist Null*/
		undo_end+=4;
		*undo_end++=0;
		*undo_end++=0;
		*undo_end++=0;
		*undo_end++=14; /* GesamtlÑnge */

		undo_end-=14; /* ZurÅcksetzen auf Eintrag */
		
		undo_maxend=(unsigned char*)((long)undo_start+UNDO_BUFSIZ);
		undo_buffers=1;
		undo_ok=1;
	}
	else
	{
		undo_ok=0;
		undo_buffers=0;
	}
	display_undo();
}

void	resize_help(void)
{
	int alert;
	
	alert=form_alert(1,"[1][Um Undo-Speicher zu erhalten,|betÑtigen Sie im Undo-Recorder|oder jetzt in dieser Box die|\'Reset\'-Taste.][Reset|Abbruch]");
	if(alert == 1)
	{/* Reset */
		free_undo();
		clear_undo();
		init_undo();
	}
}

void	resize_undo(void)
{
	unsigned char	*new, *ostart, *oend;
	int		alert;
	long	size, max;

	if(ounopt[UOFULL].ob_state & SELECTED)
	{
		size=UNDO_BUFSIZ*(long)(undo_buffers+1);
		size+=(long)((long)64*(long)64*(long)3+(long)24);
		size/=1024l;	/* In KB umrechnen */
		max=atol(ounopt[UOMEM].ob_spec.tedinfo->te_ptext);
		if(ounopt[UOKBMB].ob_spec.free_string[0]=='M')
			max*=1024;	/* in MB umrechnen */
		if((size > max) && (max > 267))
		{
			if(ounopt[UOFULL1].ob_state & SELECTED)
			{/* Mit Alert Abbrechen */
				undo_ok=0;
				graf_mouse(ARROW, NULL);
				alert=form_alert(2,"[1][Der Undo-Speicher hat die unter|\'Undo-Optionen\' festgelegte Grîûe|erreicht. Die Aufnahme wird jetzt|angehalten.][Hilfe|OK]");
				if(alert==1) /* Hilfe */
					resize_help();
				return;
			}
			else
			{/* Auto-Reset */
				free_undo();
				clear_undo();
				init_undo();
				return;
			}
		}
	}

	++undo_buffers;
	ostart=undo_start;
	oend=undo_end;
	new=(unsigned char*)malloc(UNDO_BUFSIZ+64*64*3+14+14);

	
	*undo_end++=0;
	*undo_end++=255; /* Typ nÑchstes Zeigerpaar */
	*(unsigned long*)undo_end=(unsigned long)new; /* Zeiger auf Blockanfang ist Null*/
	undo_end+=4;
	*(unsigned long*)undo_end=(unsigned long)(new+14); /* Zeiger auf letzten Eintrag ist Null*/
	undo_end+=4;
	*undo_end++=0;
	*undo_end++=0;
	*undo_end++=0;
	*undo_end++=14; /* GesamtlÑnge */

	if(new)
	{
		undo_start=new;
		undo_end=new;
		*undo_end++=0;
		*undo_end++=254; /* Typ voriges Zeigerpaar */
		*(unsigned long*)undo_end=(unsigned long)ostart; /* Zeiger auf Blockanfang ist Null*/
		undo_end+=4;
		*(unsigned long*)undo_end=(unsigned long)oend; /* Zeiger auf letzten Eintrag ist Null*/
		undo_end+=4;
		*undo_end++=0;
		*undo_end++=0;
		*undo_end++=0;
		*undo_end++=14; /* GesamtlÑnge */
	
		*undo_end++=0;
		*undo_end++=255; /* Typ nÑchstes Zeigerpaar */
		*(unsigned long*)undo_end=0; /* Zeiger auf Blockanfang ist Null*/
		undo_end+=4;
		*(unsigned long*)undo_end=0; /* Zeiger auf letzten Eintrag ist Null*/
		undo_end+=4;
		*undo_end++=0;
		*undo_end++=0;
		*undo_end++=0;
		*undo_end++=14; /* GesamtlÑnge */

		undo_end-=14; /* ZurÅcksetzen auf Eintrag */
		undo_maxend=(unsigned char*)((long)undo_start+UNDO_BUFSIZ);
		undo_ok=1;
		
		display_undo();
	}
	else
	{
		undo_ok=0;
		graf_mouse(ARROW, NULL);
		alert=form_alert(1,"[1][Kein Undo-Speicher mehr frei!|Die Aufnahme wird jetzt gestoppt.][Hilfe|OK]");
		if(alert==1) /* Hilfe */
			resize_help();
	}
}

void	free_undo(void)
{
	/* Gibt die beim ZurÅckspulen freigewordenen Puffer frei */
	
	if(ful)
	{
		do
		{
			--undo_buffers;
			free(ful->free_buffer);
			ful=ful->last;
			free(ful->next);
			ful->next=NULL;
		}while(ful);

	}
}

void	clear_undo(void)
{
	unsigned char	*before=NULL;
	int						*value;
	
	do
	{
		value=(int*)undo_start;
		if(*value != 254)
		{
			form_alert(1,"[3][Fehler in UNDO-Puffer|Verkettung!][Abbruch]");
			before=NULL;
			undo_ok=0;
		}
		else
		{
			before=*(unsigned char**)(undo_start+2);
			free(undo_start);
			undo_start=before;
		}
	}while(before);
		
}

void del_undo_entry(int id, int mask)
{
	/*
		Lîscht alle EintrÑge im UNDO-Puffer fÅr die Ebene oder
		Maske mit 'id'.
		
		mask: 0=id gilt fÅr Ebene, 1=id gilt fÅr Maske 
	*/
	
	unsigned char *wo;
	int		cont, layer, clayer, nul;
	long	subs;

	cont=1;
	
	wo=undo_end;

	nul=253;
	/* Soll-ID festlegen */
	clayer=id;
	if(mask)
	{
		clayer|=512;
		nul|=253;
	}
		
	do
	{
		subs=*(long*)(wo-4);
		wo=(unsigned char*)((long)wo-(long)subs);
		if((*(wo+1)) == 254)
		{ /* Blockstartmarkierung */
			wo=*(unsigned char**)(wo+6);
			if(!wo)
			{/* Ende (bzw. Anfang) markierung */
				cont=0;
			}
		}
		else if(*(wo+1) == 255)
		{/* Blockendemarkierung */
			/* ZurÅcksetzen auf vorigen Block */
			subs=*(long*)(wo-4);
			wo=(unsigned char*)((long)wo-(long)subs);
		}
		else
		{
			/* Ist-ID bestimmen */
			layer=*((int*)wo);
			layer&=1023; /* Ketten-Flags uninteressant */
			
			/* Gesuchter Eintrag? */
			if(layer == clayer)
				*((int*)wo)=nul;		/* Ja->Ausnullen */
		}
	}while(cont);
}

void	display_undo(void)
{
	char	text[255];
	long	size;

	size=UNDO_BUFSIZ*(long)undo_buffers;
	size+=(long)((long)64*(long)64*(long)3+(long)24);
	size/=1024l;
	
	ltoa(size, text, 10);
	strcat(text, " KByte  ");
	strcpy(oundo[UDISPLAY].ob_spec.tedinfo->te_ptext,text);
	
	if(wundorec.open)
	{
		w_objc_draw(&wundorec, UDISPLAY, 1, sx, sy, sw, sh);
	}
}

void sel_undo(int ob)
{
	oundo[ob-1].ob_state|=SELECTED;
	++oundo[ob].ob_x; ++oundo[ob].ob_y;
	w_objc_draw(&wundorec, ob-1, 2, sx, sy, sw, sh);
}

void unsel_undo(int ob)
{
	oundo[ob-1].ob_state&=(~SELECTED);
	--oundo[ob].ob_x; --oundo[ob].ob_y;
	w_objc_draw(&wundorec, ob-1, 2, sx, sy, sw, sh);
}

void dial_undo(int ob)
{
	/* Buttons selektieren */
	switch(ob)
	{
		case UB1: case UB2: case UB3: case UF1: case UF2: case UF3:
		 sel_undo(ob);
		break;
	}
	
	/* Aktion */
	switch(ob)
	{
		case UB1:
			rw_undo(1);
		break;
		case UB2:
			rw_undo(2);
		break;
		case UB3:
			rw_undo(3);
		break;
		case UF1:
			ff_undo(1);
		break;
		case UF2:
			ff_undo(2);
		break;
		case UF3:
			ff_undo(3);
		break;
		case UCL:
			free_undo();
			clear_undo();
			init_undo();
			oundo[UCL].ob_state &= (~SELECTED);
			w_objc_draw(&wundorec, UCL,1, sx,sy,sw,sh);
		break;
		case UON:
			if(oundo[UON].ob_state & SELECTED)
			{
				oundo[ULED].ob_spec.bitblk->bi_color=3;
				undo_on=1;
			}
			else
			{
				oundo[ULED].ob_spec.bitblk->bi_color=11;
				undo_on=0;
			}
			w_objc_draw(&wundorec, ULED, 1, sx, sy, sw, sh);
		break;
		case UALL:
			if(oundo[UALL].ob_state & SELECTED)
				oundo[URLED].ob_spec.bitblk->bi_color=6;
			else
				oundo[URLED].ob_spec.bitblk->bi_color=14;
			w_objc_draw(&wundorec, URLED, 1, sx, sy, sw, sh);
		break;
	}

	/* Buttons de-selektieren */
	switch(ob)
	{
		case UB1: case UB2: case UB3: case UF1: case UF2: case UF3:
		 unsel_undo(ob);
		break;
	}
}

void	ff_undo(int mode)
{
	/* mode = 1  Ein Frame vorwÑrts
					  2  Solange vorwÑrts wie Maus gedrÅckt
					  3  Bis Pufferende
	*/
	unsigned char *wo, *nstart, *nend, hi, lo;
	int		px, py, width, height, a, swx, swy, ww, wh, dum;
	int		cont, mx=-1, my=-1, mw=-1, mh=-1, mask_mode, kette;
	int		alx=-1, aly, alw, alh;
	long	pw, dad, subs;
	int		layer, olayer=-1;
	LAYER *l;
	MASK  *lm;

	wind_update(BEG_UPDATE);
	if(mode == 3)
		graf_mouse(BUSYBEE, NULL);
	
	wind_get(main_win.id, WF_WORKXYWH, &swx, &swy, &ww, &wh);
	swy+=otoolbar[0].ob_height+OTBB; wh-=otoolbar[0].ob_height+OTBB;
	pw=(long)first_lay->this.word_width;
	cont=0;
	do
	{
		if(*(undo_end+1) == 254)
		{ /* Blockstartmarkierung */
			/* Åbergehen */
			undo_end+=14;
			cont=1;
		}
		else if(*(undo_end+1) == 255)
		{
			nstart=*(unsigned char**)(undo_end+2);
			nend=*(unsigned char**)(undo_end+6);
			if(!nstart)
			{/* Endemarkierung */
				Bell();
				cont=0;
				kette=0;
			}
			else
			{
				cont=1;
				undo_start=nstart;
				undo_end=nend;
				undo_maxend=(unsigned char*)((long)undo_start+UNDO_BUFSIZ);
				
				/* Neuen Block ggf. aus FREE-Liste entfernen */
				if(ful)
				{
					if((ful->free_buffer != undo_start) || (ful->next))
						form_alert(1,"[3][Fehler in UNDO-Verkettung!][Abbruch]");
					else
					{
						ful=ful->last;
						free(ful->next);
						ful->next=NULL;
					}
				}
			}
		}
		else
		{
			wo=undo_end;
			
			hi=*wo++;
			lo=*wo++;
			layer=(int)((int)hi*(int)256+(int)lo);
			if(layer != olayer)
			{
				if(mx != -1)
				{/* Update-Info rausschicken */
					if(olayer & 512)
						m_area_changed(mx, my, mw, mh, find_mask_list_id(olayer&255));
					else
						l_area_changed(mx, my, mw, mh, find_lay_list_id(olayer&255));
				}
				mx=-1;
				
				olayer=layer;
				if(layer & 1024)
					kette=1;
				else
					kette=0;
					
				if(layer & 512)
				{
					if((layer & 255) != 253)
						lm=find_mask_id(layer & 255);
					else
					{
						lm=NULL;
						kette=1;
					}
					mask_mode=1;
				}
				else
				{
					if((layer & 255) != 253)
						l=find_layer_id(layer & 255);
					else
					{
						l=NULL;
						kette=1;
					}
					mask_mode=0;
				}
			}
			
			hi=*wo++;
			lo=*wo++;
			px=(int)((int)hi*(int)256+(int)lo);
		
			hi=*wo++;
			lo=*wo++;
			py=(int)((int)hi*(int)256+(int)lo);
		
			hi=*wo++;
			lo=*wo++;
			width=(int)((int)hi*(int)256+(int)lo);
		
			hi=*wo++;
			lo=*wo++;
			height=(int)((int)hi*(int)256+(int)lo);
			
			/* Umfassendes Rechteck berechnen */
			if(mx == -1)
			{/* Init */
				mx=px; my=py; mw=width; mh=height;
			}
			else
			{
				if((mx + mw) < (px+width))
					mw=px+width-mx;
				if((my + mh) < (py+height))
					mh=py+height-my;
				if(mx > px)
				{	mw+=mx-px; mx=px;}
				if(my > py)
				{	mh+=my-py; my=py;}
			}
			/* Gesamtrechteck fÅr mode 3 */
			if(mode==3)
			{
				if(alx == -1)
				{/* Init */
					alx=px; aly=py; alw=width; alh=height;
				}
				else
				{
					if((alx + alw) < (px+width))
						alw=px+width-alx;
					if((aly + alh) < (py+height))
						alh=py+height-aly;
					if(alx > px)
					{	alw+=alx-px; alx=px;}
					if(aly > py)
					{	alh+=aly-py; aly=py;}
				}
			}
			
			if(mask_mode)
				subs=(long)((long)width*(long)height);
			else
				subs=(long)((long)width*(long)height*(long)3);
			undo_end=(unsigned char*)((long)wo+(long)subs+(long)4);
			
			dad=(long)((long)py*(long)pw+(long)px);
			if(mask_mode)
			{ /* Grey-Eintrag (1 Byte) */
				if(lm)
				{
					uc_height=height-1; uc_width=width-1;
					uc_ldif=pw-width;
					uc_uend=wo;
					uc_m=(uchar*)lm->mask+dad;
					undo_swap_m();
					wo=uc_uend;
				}
				else /* Maske wurde gelîscht */
					wo+=width*height;
			}
			else
			{ /* RGB-Eintrag (3 Byte) */
				if(l)
				{
					uc_height=height-1; uc_width=width-1;
					uc_ldif=pw-width;
					uc_uend=wo;
					uc_c=(uchar*)l->blue+dad; uc_m=(uchar*)l->red+dad; uc_y=(uchar*)l->yellow+dad;
					undo_swap_cmy();
					wo=uc_uend;
				}
				else /* Layer zu diesem Puffereintrag wurde gelîscht */
					wo+=3*width*height;
			}
			
			if(mode < 3)
				area_redraw(px,py,width,height);
			else if (mode == 3)
				cont=1;
			if(mode == 2)
				graf_mkstate(&dum, &dum, &cont, &dum);
		}
	}while(cont || kette);
	if(mode == 1)
	{
		do
		{
			graf_mkstate(&dum, &dum, &a, &dum);
		}while(a);
	}
	else if (mode == 3)
	{
		area_redraw(alx,aly,alw,alh);
		graf_mouse(ARROW, NULL);
	}
	wind_update(END_UPDATE);
	
	if(mx != -1)
	{/* Update-Info rausschicken */
		if(layer & 512)
			m_area_changed(mx, my, mw, mh, find_mask_list_id(layer&255));
		else
			l_area_changed(mx, my, mw, mh, find_lay_list_id(layer&255));
	}
}

void	rw_undo(int mode)
{
	/* mode = 1  Ein Frame rÅckwÑrts
					  2  Solange rÅckwÑrts wie Maus gedrÅckt
					  3  Bis Pufferanfang
	*/
	unsigned char *wo, *nstart, *nend, hi, lo;
	int		px, py, width, height, a, swx, swy, ww, wh, dum;
	int		cont, mx=-1, my=-1, mw=-1, mh=-1, mask_mode, kette;
	int		alx=-1, aly, alw, alh;
	long	pw, dad, subs;
	FREE_UNDO_LIST	*nful;
	int		layer, olayer=-1;
	LAYER	*l;
	MASK  *lm;
	
	wind_update(BEG_UPDATE);
	if(mode == 3)
		graf_mouse(BUSYBEE, NULL);
	wind_get(main_win.id, WF_WORKXYWH, &swx, &swy, &ww, &wh);
	swy+=otoolbar[0].ob_height+OTBB; wh-=otoolbar[0].ob_height+OTBB;

	pw=(long)first_lay->this.word_width;
	cont=0;
	
	do
	{
		wo=undo_end;
		subs=*(long*)(wo-4);
		wo=(unsigned char*)((long)wo-(long)subs);
		undo_end=wo;
		if((*(undo_end+1)) == 254)
		{ /* Blockstartmarkierung */
			nstart=*(unsigned char**)(undo_end+2);
			nend=*(unsigned char**)(undo_end+6);
			if(!nstart)
			{/* Endemarkierung */
				undo_end+=14; /* Wieder auf Ende setzen */
				Bell();
				cont=0;
				kette=0;
			}
			else
			{
				/* Buffer frei geben */
				nful=(FREE_UNDO_LIST*)malloc(sizeof(FREE_UNDO_LIST));
				if(!nful)
				{
					form_alert(1,"[3][Kein Speicher frei!][Abbruch]");
					return;
				}
				ful->next=nful;
				nful->last=ful;
				nful->next=NULL;
				nful->free_buffer=undo_start;
				ful=nful;

				cont=1;
				undo_start=nstart;
				undo_end=nend;
				undo_maxend=(unsigned char*)((long)undo_start+UNDO_BUFSIZ);
			}
		}
		else if(*(undo_end+1) == 255)
		{/* Blockendemarkierung */
			cont=1;
			/* ZurÅcksetzen auf vorigen Block */
			wo=undo_end;
			subs=*(long*)(wo-4);
			wo=(unsigned char*)((long)wo-(long)subs);
			undo_end=wo;
		}
		else
		{
			wo=undo_end;
	
				hi=*wo++;
				lo=*wo++;
				layer=(int)((int)hi*(int)256+(int)lo);
				if(layer != olayer)
				{
					if(mx != -1)
					{/* Update-Info rausschicken */
						if(olayer & 512)
							m_area_changed(mx, my, mw, mh, find_mask_list_id(olayer&255));
						else
							l_area_changed(mx, my, mw, mh, find_lay_list_id(olayer&255));
					}
					mx=-1;
					
					olayer=layer;
					if(layer & 2048)
						kette=1;
					else
						kette=0;
						
					if(layer & 512)
					{
						if((layer & 255) != 253)
							lm=find_mask_id(layer & 255);
						else
						{
							lm=NULL;
							kette=1;
						}
						mask_mode=1;
					}
					else
					{
						if((layer & 255) != 253)
							l=find_layer_id(layer & 255);
						else
						{
							l=NULL;
							kette=1;
						}
						mask_mode=0;
					}
				}
				hi=*wo++;
				lo=*wo++;
				px=(int)((int)hi*(int)256+(int)lo);
			
				hi=*wo++;
				lo=*wo++;
				py=(int)((int)hi*(int)256+(int)lo);
			
				hi=*wo++;
				lo=*wo++;
				width=(int)((int)hi*(int)256+(int)lo);
			
				hi=*wo++;
				lo=*wo++;
				height=(int)((int)hi*(int)256+(int)lo);

				/* Umfassendes Rechteck berechnen */
				if(mx == -1)
				{/* Init */
					mx=px; my=py; mw=width; mh=height;
				}
				else
				{
					if((mx + mw) < (px+width))
						mw=px+width-mx;
					if((my + mh) < (py+height))
						mh=py+height-my;
					
					if(mx > px)
					{
						mw+=mx-px; mx=px;
					}
					if(my > py)
					{
						mh+=my-py; my=py;
					}
				}
				/* Gesamtrechteck fÅr mode 3 */
				if(mode==3)
				{
					if(alx == -1)
					{/* Init */
						alx=px; aly=py; alw=width; alh=height;
					}
					else
					{
						if((alx + alw) < (px+width))
							alw=px+width-alx;
						if((aly + alh) < (py+height))
							alh=py+height-aly;
						if(alx > px)
						{	alw+=alx-px; alx=px;}
						if(aly > py)
						{	alh+=aly-py; aly=py;}
					}
				}
			
				
				dad=(long)((long)py*(long)pw+(long)px);
				if(mask_mode)
				{
					if(lm)
					{
						uc_height=height-1; uc_width=width-1;
						uc_ldif=pw-width;
						uc_uend=wo;
						uc_m=(uchar*)lm->mask+dad;
						undo_swap_m();
						wo=uc_uend;
					}
					else /* Maske wurde gelîscht */
						wo+=width*height;
				}
				else
				{
					if(l)
					{
						uc_height=height-1; uc_width=width-1;
						uc_ldif=pw-width;
						uc_uend=wo;
						uc_c=(uchar*)l->blue+dad; uc_m=(uchar*)l->red+dad; uc_y=(uchar*)l->yellow+dad;
						undo_swap_cmy();
						wo=uc_uend;
					}
					else /* Layer zu diesem Puffereintrag wurde gelîscht */
						wo+=3*width*height;
				}
				
				cont=0;
				if(mode < 3)
				{
					area_redraw(px,py,width,height);
				}
				else if (mode == 3)
					cont=1;
				if(mode == 2)
					graf_mkstate(&dum, &dum, &cont, &dum);

		}

	}while(cont || kette);
	if(mode == 1)
	{
		do
		{
			graf_mkstate(&dum, &dum, &a, &dum);
		}while(a);
	}
	else if (mode == 3)
	{
		area_redraw(alx,aly,alw,alh);
		graf_mouse(ARROW, NULL);
	}
	wind_update(END_UPDATE);
	if(mx != -1)
	{/* Update-Info rausschicken */
		if(layer & 512)
			m_area_changed(mx, my, mw, mh, find_mask_list_id(layer&255));
		else
			l_area_changed(mx, my, mw, mh, find_lay_list_id(layer&255));
	}
}

int	all_to_undo(LAYER *layer, MASK *mask)
{	/* lay/mask: Zu puffernde Ebene/Maske, anderer Parameter NULL
		 return: 1=alles bestens, 0=Fehler (z.B. kein Speicher)
	*/

	int	r=1;
	_frame_data frame_old=frame_data;
	
	frame_data.x=frame_data.y=0;
	frame_data.w=first_lay->this.width;
	frame_data.h=first_lay->this.height;

	r=frame_to_undo_ws(layer, mask);

	frame_data=frame_old;
	return(r);
}

int cdecl undo_buf(GRECT *area, LAYER *layer, MASK *mask, int auto_res)
{ /* NUR FöR MODULE */
	/* Layer kann immer gesetzt sein, wird aber nur beachtet, wenn
		mask=NULL ist. Der beachtete Bereich wird in den Undo-Buffer
		kopiert.
		auto_reset: 1=soll beachtet werden, 0=ignorieren
		(0 benîtigt, falls eine Aktion aus mehreren kleinen besteht!)
		
		Return: 1=alles ok, 0=Problem (z.B. kein Speicher)
		 */
		
	int	r=1;
	_frame_data frame_old=frame_data;
	
	if(auto_res)
		if(!auto_reset(6))
			return(0);
	
	frame_data.x=area->g_x;
	frame_data.y=area->g_y;
	frame_data.w=area->g_w;
	frame_data.h=area->g_h;
	if(mask)
		r=frame_to_undo_ws(NULL, mask);
	else if(layer)
		r=frame_to_undo_ws(layer, NULL);
		
	frame_data=frame_old;
	return(r);
}

int frame_to_undo(int lay_or_mask)
{	/* lay_or_mask: 0=Layer im Frame in den Undopuffer, 1=Maske
		 return: 1=alles bestens, 0=Fehler (z.B. kein Speicher)
	*/

	if(lay_or_mask)
		return(frame_to_undo_ws(NULL, &(act_mask->this)));
	
	return(frame_to_undo_ws(&(act_lay->this), NULL));
}

int	auto_reset(int typ)
{	/* Typ entsprechend der Auflistung in Undo-Options 
		 (ZÑhlung beginnt bei 0) 
		Return: 1=ok, 0=kein Speicher
	*/

	if((oundo[UALL].ob_state & SELECTED) && (ounopt[UORES1+typ].ob_state & SELECTED))
	{
		free_undo();
		clear_undo();
		init_undo();
		if(!undo_ok)
		{
			if(form_alert(2,"[2][Grape:|Nicht genug Speicher fÅr|den UNDO-Buffer. Operation |trotzdem ausfÅhren?][OK|Abbruch]")==2)
				return(0); /* Undo-Init ist schiefgegangen */
			else
				return(1); /* Was dem Anwender aber egal ist */
		}
	}
	return(1);
}

int		frame_to_undo_ws(LAYER *lay, MASK *mask)
{
	return(frame_to_undo_mouse(lay, mask, 1));
}

int		frame_to_undo_mouse(LAYER *lay, MASK *mask, int mouse)
{	/* lay/mask: Zu puffernde Ebene/Maske, anderer Parameter NULL
		 es wird nur der Bereich im Frame beachtet! Falls Framedaten
		 ungÅltig->GROSSE MALAISE!
		 mouse: Mit Mausanzeige(1) oder nicht (0)
		 return: 1=alles bestens, 0=Fehler (z.B. kein Speicher)
	*/
	
	_frame_data frame_old=frame_data;
	long	size, h_rest=frame_data.h, h_done;
	int		flags=4, h_mouse=0, tw;

	if(!undo_on)
		return(1);	/* Undo gar nicht an->ist schon ok:-) */
		
	if(mouse) graf_mouse(258, NULL);
	while(frame_data.h)
	{	
		
		if(mask)
			tw=frame_data.w;
		else
			tw=frame_data.w*3;
		if(undo_end+tw+14+14+14 >= undo_maxend)
		{
			resize_undo();
			if(!undo_ok)
			{
				graf_mouse(259,NULL);
				if(form_alert(2,"[2][Soll die Aktion trotzdem|fortgesetzt werden?][OK|Abbruch]")==2)
					return(0);
				else
					return(1);
			}
		}

		if(mouse)
		{
			++h_mouse;
			switch(h_mouse)
			{
				case 1:
					graf_mouse(USER_DEF, UD_UNDO_1);
				break;
				case 2:
					graf_mouse(USER_DEF, UD_UNDO_2);
				break;
				case 3:
					graf_mouse(USER_DEF, UD_UNDO_3);
				break;
				case 4:
					graf_mouse(USER_DEF, UD_UNDO_4);
					h_mouse=0;
				break;
			}
		}


		if(mask)
			size=(long)((long)frame_data.h*(long)frame_data.w+(long)14+(long)14);
		else /* Drei mal so viel */
			size=(long)((long)frame_data.h*(long)frame_data.w*(long)3+(long)14+(long)14);

		/* Flags fÅr diesen Durchlauf */
		if(flags == 4) /* Nur falls das der erste Durchlauf ist */
			if(undo_end+size <=undo_maxend) /* und alles rein paût */
				flags=0;
		
		/* Hîhe solange reduzieren bis es paût */		
		while(undo_end + size > undo_maxend)
		{
			if(mask)
				size-=frame_data.w;
			else
				size-=frame_data.w*3;
			--frame_data.h;
		}
		/* Unterroutine den Block kopieren lassen */
		if(!part_frame_to_undo(lay, mask, flags))
		{
			if(form_alert(2,"[2][Grape:|Nicht genug Speicher fÅr|den UNDO-Buffer. Operation |trotzdem ausfÅhren?][OK|Abbruch]")==2)
				return(0); /* Undo ist schiefgegangen */
			else
				return(1); /* Was dem Anwender aber egal ist */
		}

		h_done=frame_data.h;
		frame_data.y+=frame_data.h;
		frame_data.h=(int)h_rest-frame_data.h;
		h_rest-=h_done;

		/* Flags fÅr den nÑchsten Durchlauf: */
		if(flags==4) /* Das war die erste Runde */
			flags=4+8;
		if(!frame_data.h) /* Das war die letzte Runde */
			flags=8;
	}
	if(mouse) graf_mouse(259,0);
	/* Endemarkierung in Undopuffer schreiben */
	
	*undo_end++=0;
	*undo_end++=255; /* Typ nÑchstes Zeigerpaar */
	*(unsigned long*)undo_end=0; /* Zeiger auf Blockanfang ist Null*/
	undo_end+=4;
	*(unsigned long*)undo_end=0; /* Zeiger auf letzten Eintrag ist Null*/
	undo_end+=4;
	*(unsigned long*)undo_end=14; /* Zeiger auf Grîûe*/
	undo_end+=4;
	
	undo_end-=14;	/* ZurÅcksetzen auf Ende-Eintrag */
	
	frame_data=frame_old;
	return(1);
}

int part_frame_to_undo(LAYER *lay, MASK *mask, int flags)
{
	/*
			lay oder mask: Zeiger auf die zu puffernde Ebene/Maske

		 Per "flags" wird die Verkettung geregelt:
		 flags: |4=Der nÑchste Block soll dazu gehîren
		 flags: |8=Der vorherige Block gehîrt auch dazu
		 
		 Gibt 0 fÅr Abbruch oder 1 zurÅck (Dann wurde der Block
		 entweder im Undobuffer gesichert oder Undo ist garnicht an)
	*/
	
	register long					lin_ad, offs, size;
	register unsigned char	*c, *m, *y;

	if((!undo_on) || (!undo_ok))
		return(1); /* Undo ist nicht aktiv->ok zurÅck */

	/* Bereich umkopieren */
	if(mask)
	{
		m=mask->mask;
		*undo_end++=2|flags; /* 512 */
		*undo_end++=mask->id;
		size=(long)((long)14+(long)frame_data.w*(long)frame_data.h);
	}
	else
	{
		c=lay->blue;
		m=lay->red;
		y=lay->yellow;
		*undo_end++=flags;
		*undo_end++=lay->id;
		size=(long)((long)14+(long)frame_data.w*(long)frame_data.h*(long)3);
	}

	/* Offsetvariablen */
	offs=(long)((long)frame_data.y*(long)first_lay->this.word_width);
	offs+=(long)frame_data.x;
	c+=offs; m+=offs; y+=offs;
	
	lin_ad=(long)first_lay->this.word_width-(long)frame_data.w;
	
	*(int*)undo_end=frame_data.x;
	undo_end+=2;
	*(int*)undo_end=frame_data.y;
	undo_end+=2;
	*(int*)undo_end=frame_data.w;
	undo_end+=2;
	*(int*)undo_end=frame_data.h;
	undo_end+=2;

	uc_height=frame_data.h-1; uc_width=frame_data.w-1;
	uc_ldif=lin_ad;
	uc_uend=undo_end;
	uc_c=c; uc_m=m; uc_y=y;
	if(mask)
		undo_copy_m();
	else
		undo_copy_cmy();

	undo_end=uc_uend;
	
	*(long*)undo_end=size;
	undo_end+=4;


	return(1);	
}


void undo_options(void)
{
	if(!wunopt.open)
	{
		/* Alte Einstellung merken */
		memo_abbruch(ounopt);
		/* popup Merken */
		if(ounopt[UOKBMB].ob_spec.free_string[0]=='K')
			set_ext_type(ounopt, UOKBMB, 1);
		else
			set_ext_type(ounopt, UOKBMB, 2);
		/* Speichertext merken */	
		strcpy(&(ounopt[UOMEM].ob_spec.tedinfo->te_ptext[4]),
					&(ounopt[UOMEM].ob_spec.tedinfo->te_ptext[0]));
		
		/* Fenster initialisieren */
		wunopt.dinfo=&dunopt;
		w_dial(&wunopt, D_CENTER);
		wunopt.name="[Grape] Undo-Optionen";
		w_set(&wunopt, NAME);
		dunopt.dedit=UOMEM;
		w_open(&wunopt);
	}
	else
		w_top(&wunopt);
}

void dial_unopt(int ob)
{
	OBJECT *popup;
	int			pret, x, y;
	long		max;
		
	switch(ob)
	{
		case UOFULL:
			/* Rest in Speicherverbruach en/disablen */
			if(ounopt[ob].ob_state & SELECTED)
			{ /* enablen */
				ounopt[UOMEM].ob_state &= (~DISABLED);
				ounopt[UOKBMB].ob_state &= (~DISABLED);
				ounopt[UOFULL1].ob_state &= (~DISABLED);
				ounopt[UOFULL2].ob_state &= (~DISABLED);
			}
			else
			{ /* disablen */
				ounopt[UOMEM].ob_state |= DISABLED;
				ounopt[UOKBMB].ob_state |= DISABLED;
				ounopt[UOFULL1].ob_state |= DISABLED;
				ounopt[UOFULL2].ob_state |= DISABLED;
			}
			w_objc_draw(&wunopt, UOMEM, 8, sx, sy, sw, sh);
			w_objc_draw(&wunopt, UOKBMB, 8, sx, sy, sw, sh);
			w_objc_draw(&wunopt, UOFULL1, 8, sx, sy, sw, sh);
			w_objc_draw(&wunopt, UOFULL2, 8, sx, sy, sw, sh);
		break;
		case UOKBMB:
			xrsrc_gaddr(0,KBMBPOP, &popup, xrsrc);
			objc_offset(ounopt, UOKBMB, &x, &y);
			pret=form_popup(popup, x, y);
			if(pret == 1)
				strcpy(ounopt[UOKBMB].ob_spec.free_string, "KB");
			else if(pret == 2)
				strcpy(ounopt[UOKBMB].ob_spec.free_string, "MB");
			if(pret > 0)
				w_objc_draw(&wunopt, UOKBMB, 8, sx, sy, sw, sh);
		break;
			
		case UOABBRUCH:
			recall_abbruch(ounopt);
			/* popup wiederherstellen */
			pret=ounopt[UOKBMB].ob_type >> 8;
			if(pret == 1)
				strcpy(ounopt[UOKBMB].ob_spec.free_string, "KB");
			else if(pret == 2)
				strcpy(ounopt[UOKBMB].ob_spec.free_string, "MB");
			/* Speichertext wiederherstellen */	
			strcpy(&(ounopt[UOMEM].ob_spec.tedinfo->te_ptext[0]),
						&(ounopt[UOMEM].ob_spec.tedinfo->te_ptext[4]));

			
		case UOOK:
			if(ounopt[UOFULL].ob_state & SELECTED)
			{
				max=atol(ounopt[UOMEM].ob_spec.tedinfo->te_ptext);
				if(ounopt[UOKBMB].ob_spec.free_string[0]=='M')
					max*=1024;	/* in KB umrechnen */
				if(max < 268)
				{
					form_alert(1,"[3][Grape:|Der Undo-Puffer muû|mindestens 268 KB groû|sein.][Abbruch]");
					w_unsel(&wunopt, ob);
					break;
				}
			}

			w_unsel(&wunopt, ob);
			w_close(&wunopt);
			w_kill(&wunopt);
		break;
	}
}
