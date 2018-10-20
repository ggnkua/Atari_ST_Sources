#include <grape_h.h>
#include <esm.h>
#include "grape.h"
#include "undo.h"
#include "layer.h"
#include "mask.h"
#include "file_i_o.h"
#include "fill.h"
#include "ctcppt.h"
#include "maininit.h"
#include "new.h"
#include "preview.h"
#include "mforms.h"
#include "jobs.h"
#include "xrsrc.h"
#include "zoom.h"
#include "export.h"
#include "import.h"

void	clip_path(char *dst);
void	clear_clipboard(void);

/*
**********************
 Cut, Copy, Paste, Del 
**********************
*/

void sel_ssel(void)
{ /* Selektiert das Rahmenwerkzeug */
	int a;
	
	for(a=SDRAW; a <= SZOOM; ++a)
		ospecial[a].ob_state &= (~SELECTED);
		
	ospecial[SSELECT].ob_state |= SELECTED;
	dial_special(SSELECT);
	if(wspecial.open)
		s_redraw(&wspecial);
}

void del(void)
{
	if(sel_tool != SSELECT)
	{
		if(T_CCP || (!(form_alert(1,"[2][Grape:|L”schen ist nur im Rahmen-Modus|m”glich. Soll jetzt in den Rahmen-|Modus gewechselt werden?][OK|Abbruch]")-1)))
		{
			sel_ssel();
			if(T_CCP && T_CCPDIR)
				del();
		}
		return;
	}
	
	if(frame_data.ok)
		del_frame();
	else
		form_alert(1,"[3][Grape:|Es ist kein Bereich zum L”schen|angew„hlt.][Abbruch]");
}

void del_frame(void)
{
	unsigned char	*c, *m, *y;
	long					offs, lin_ad;
	int						a,b;
		
	if(!auto_reset(4))
		return;
	if(otoolbar[MASK_ED-1].ob_state & SELECTED)
	{
		if(!frame_to_undo(1))
			return;
	}
	else
	{
		if(!frame_to_undo(0))
			return;
	}
	
	/* Sonst Layerbereich l”schen */

	busy(ON);
	graf_mouse(BUSYBEE, NULL);

	if(otoolbar[MASK_ED-1].ob_state & SELECTED)
	{
		m=act_mask->this.mask;
	}
	else
	{
		c=act_lay->this.blue;
		m=act_lay->this.red;
		y=act_lay->this.yellow;
		act_lay->this.changes=1;
		actize_win_name();
	}
	
	/* Offsetvariablen */
	offs=(long)((long)frame_data.y*(long)first_lay->this.word_width);
	offs+=(long)frame_data.x;
	c+=offs; m+=offs; y+=offs;
	
	lin_ad=(long)first_lay->this.word_width-(long)frame_data.w;
	
	
	if(otoolbar[MASK_ED-1].ob_state & SELECTED)
		for(a=0; a < 	frame_data.h; ++a)
		{
			for(b=0; b < frame_data.w; ++b)
				*m++=0;
	
			m+=lin_ad;
		}
	else
		for(a=0; a < 	frame_data.h; ++a)
		{
			for(b=0; b < frame_data.w; ++b)
				*c++=*m++=*y++=0;
	
			c+=lin_ad; m+=lin_ad, y+=lin_ad;
		}
	
	/* Redraw */
	area_redraw(frame_data.x, frame_data.y, frame_data.w, frame_data.h);
	if(otoolbar[MASK_ED-1].ob_state & SELECTED)
		mask_changed(act_mask);
	else
		layer_changed(act_lay);
	busy(OFF);
	graf_mouse(ARROW, NULL);
}

void cut(void)
{
	if(sel_tool != SSELECT)
	{
		if(T_CCP || (!(form_alert(1,"[2][Grape:|Ausschneiden ist nur im Rahmen-Modus|m”glich. Soll jetzt in den Rahmen-|Modus gewechselt werden?][OK|Abbruch]")-1)))
		{
			sel_ssel();
			if(T_CCP && T_CCPDIR)
				cut();
		}
		return;
	}
	
	if(frame_data.ok)
		cut_frame();
	else
		form_alert(1,"[3][Grape:|Es ist kein Bereich zum Ausschneiden|angew„hlt.][Abbruch]");
}

void cut_frame(void)
{
	if(!copy_frame()) /* Daten in's Clipboard */
		return;	/* Da ging was schief */
	
	del_frame();
}

void paste(void)
{
	if(sel_tool != SSELECT)
	{
		if(T_CCP || (!(form_alert(1,"[2][Grape:|Einfgen ist nur im Rahmen-Modus|m”glich. Soll jetzt in den Rahmen-|Modus gewechselt werden?][OK|Abbruch]")-1)))
		{
			sel_ssel();
			if(T_CCP && T_CCPDIR)
				paste();
		}
		return;
	}
	
	if(frame_data.ok)
		paste_frame();
	else
		form_alert(1,"[3][Grape:|Es ist kein Bereich zum Einfgen|angew„hlt.][Abbruch]");
}

void paste_frame(void)
{
	int		fh, ret;
	char	name[32], path[128];

	strcpy(name, "SCRAP.*");
	fh=read_clipboard(name, path); /* šberschreibt name und path mit gefundener Datei */
	if(fh < 0)
		return;
	Fclose(fh);
	/* Identifikation des Dateiformats + Alert erfolgt sp„ter
		 durch "import_file"
	*/
	
	if(!auto_reset(4))
		return;

	busy(ON);
	graf_mouse(BUSYBEE, NULL);
	
	if(otoolbar[MASK_ED-1].ob_state & SELECTED)
		ret=import_file(path, name, NULL, &(act_mask->this), 1);
	else
		ret=import_file(path, name, &(act_lay->this),  NULL, 1);


	if(ret)
	{/* Import hat geklappt, redraw */
		area_redraw(frame_data.x, frame_data.y, frame_data.w, frame_data.h);
		if(otoolbar[MASK_ED-1].ob_state & SELECTED)
			mask_changed(act_mask);
		else
			layer_changed(act_lay);

		if(!(otoolbar[MASK_ED-1].ob_state & SELECTED))
		{
			act_lay->this.changes=1;
			actize_win_name();
		}
	}
	Fclose(fh);


	busy(OFF);
	graf_mouse(ARROW, NULL);
}

void clip_size(void)
{
	if(sel_tool != SSELECT)
	{
		if(T_CCP || (!(form_alert(1,"[2][Grape:|Die Clip-Gr”že kann nur im Rahmen-|Modus bestimmt werden. Soll jetzt|in den Rahmen-Modus gewechselt|werden?][OK|Abbruch]")-1)))
		{
			sel_ssel();
			if(T_CCP && T_CCPDIR)
				clip_size();
		}
		return;
	}
	
	clip_size_frame();
}

void clip_size_frame(void)
{
	int		fh, ret, x, y;
	char	name[32], path[128];
	
	strcpy(name, "SCRAP.*");
	
	fh=read_clipboard(name, path);
	if(fh < 0)
		return;
	Fclose(fh);
	
	/* Rahmen ausschalten? */
	if(frame_data.vis)
		draw_win_frame();

	busy(ON);
	
	/* Identifikation des Dateiformats & Gr”že auslesen	*/
	ret=get_graf_size(path, name, &x, &y);
	busy(OFF);

	if(ret < 1)
	{
		if(frame_data.vis)
			draw_win_frame();
		return;
	}
	
	if((x > first_lay->this.width) || (y > first_lay->this.height))
	{
		form_alert(1,"[3][Grape:|Der Rahmen kann nicht angepažt werden,|da er die Gr”že der Hauptdatei ber-|schreiten wrde.][Abbruch]");
		if(frame_data.vis)
			draw_win_frame();
		return;
	}

	if(!frame_data.ok)
	{frame_data.x=0; frame_data.y=0; frame_data.wid=main_win.id;}
	
	frame_data.w=x; frame_data.h=y;
	
	if(frame_data.x+frame_data.w > first_lay->this.width)
		frame_data.x=first_lay->this.width-frame_data.w;
	if(frame_data.y+frame_data.h > first_lay->this.height)
		frame_data.y=first_lay->this.height-frame_data.h;
	
	frame_data.ok=1; frame_data.vis=1;
	draw_win_frame();
}

void copy(void)
{
	if(sel_tool != SSELECT)
	{
		if(T_CCP || (!(form_alert(1,"[2][Grape:|Kopieren ist nur im Rahmen-Modus|m”glich. Soll jetzt in den Rahmen-|Modus gewechselt werden?][OK|Abbruch]")-1)))
		{
			sel_ssel();
			if(T_CCP && T_CCPDIR)
				copy();
		}
		return;
	}
	
	if(frame_data.ok)
		copy_frame();
	else
		form_alert(1,"[3][Grape:|Es ist kein Bereich zum Kopieren|angew„hlt.][Abbruch]");
}

int copy_frame(void)
{
	/* 0:Daten nicht geschrieben, 1: alles ok */

	int						fh, a, b;
	unsigned char *c, *m, *y, *buf;
	long					offs, lin_ad, siz, l;
	ESM_HEADERTYP esmh;
	
	fh=write_clipboard("SCRAP.ESM");
	if(fh < 0)
		return(0);

	busy(ON);
	graf_mouse(BUSYBEE, NULL);

	strcpy(esmh.kennung, "TMS\0");
	esmh.head_size=(int)sizeof(ESM_HEADERTYP);
	
	esmh.breite=frame_data.w;
	esmh.hoehe=frame_data.h;
	
	esmh.tiefe=24; /* 24 Bit */
	
	esmh.bildart=4; /* CMY */
	
	esmh.tiefe_rot=esmh.tiefe_gruen=esmh.tiefe_blau=8;
	esmh.tiefe_schwarz=0;
	
	esmh.version=5;
	
	esmh.xdpi=atoi(onew[ONDPI].ob_spec.tedinfo->te_ptext);
	esmh.ydpi=esmh.xdpi;
	
	esmh.file_hoehe=frame_data.h;
	
	esmh.start_zeile=0;
	esmh.end_zeile=frame_data.h-1;
	
	esmh.maske=0;
	
	for(a=0; a < 256; ++a)
		esmh.red_tab[a]=esmh.green_tab[a]=esmh.blue_tab[a]=(unsigned char)a;
	
	strcpy(esmh.copyright, "Grape");

	esmh.reserved[0]=esmh.reserved[1]=esmh.reserved[2]=esmh.reserved[3]=0;
	
	Fwrite(fh, sizeof(ESM_HEADERTYP), &esmh);
	
	/* Offsetvariablen */
	if(otoolbar[MASK_ED-1].ob_state & SELECTED)
	{
		c=m=y=act_mask->this.mask;
	}
	else
	{
		c=act_lay->this.blue;
		m=act_lay->this.red;
		y=act_lay->this.yellow;
	}
	offs=(long)((long)frame_data.y*(long)first_lay->this.word_width);
	offs+=(long)frame_data.x;
	c+=offs; m+=offs; y+=offs;
	
	lin_ad=(long)first_lay->this.word_width-(long)frame_data.w;

	siz=(long)frame_data.w * (long) frame_data.h * 3;

	/* Bilddaten schreiben */
	buf=(unsigned char*)malloc(siz);
	if(!buf)
	{	/* Ganzer Block auf einmal geht nicht! Lahmarsch-Methode
			zeilenweise probieren
		*/
		buf=(unsigned char*)malloc(frame_data.w * 3);
		if(!buf) /* Geht auch nicht! */
		{
			for(a=0; a < 	frame_data.h; ++a)
			{
				for(b=0; b < frame_data.w; ++b)
				{
					Fwrite(fh, 1, c++);
					Fwrite(fh, 1, m++);
					Fwrite(fh, 1, y++);
				}
				c+=lin_ad; m+=lin_ad, y+=lin_ad;
			}
		}
		for(a=0; a < 	frame_data.h; ++a)
		{
			l=0;
			for(b=0; b < frame_data.w; ++b)
			{
				buf[l++]=*c++;
				buf[l++]=*m++;
				buf[l++]=*y++;
			}
			c+=lin_ad; m+=lin_ad, y+=lin_ad;
			Fwrite(fh, l, buf);
		}
	}
	else
	{	
		l=0;
		for(a=0; a < 	frame_data.h; ++a)
		{
			for(b=0; b < frame_data.w; ++b)
			{
				buf[l++]=*c++;
				buf[l++]=*m++;
				buf[l++]=*y++;
			}
			c+=lin_ad; m+=lin_ad, y+=lin_ad;
		}
		Fwrite(fh, l, buf);
	}
	
	free(buf);
	Fclose(fh);

	busy(OFF);
	graf_mouse(ARROW, NULL);

	return(1);
}

void copy_vis(void)
{
	if(sel_tool != SSELECT)
	{
		if(T_CCP || (!(form_alert(1,"[2][Grape:|Kopieren ist nur im Rahmen-Modus|m”glich. Soll jetzt in den Rahmen-|Modus gewechselt werden?][OK|Abbruch]")-1)))
		{
			sel_ssel();
			if(T_CCP && T_CCPDIR)
				copy_vis();
		}
		return;
	}
	
	if(frame_data.ok)
		copy_frame_vis();
	else
		form_alert(1,"[3][Grape:|Es ist kein Bereich zum Kopieren|angew„hlt.][Abbruch]");
}

int copy_frame_vis(void)
{
	/* 0:Daten nicht geschrieben, 1: alles ok */

	int						fh;
	unsigned char *c, *m, *y, *buf;
	long					l, w, uw, h, lin_ad, a, b;
	ESM_HEADERTYP esmh;
	
	fh=write_clipboard("SCRAP.ESM");
	if(fh < 0)
		return(0);

	busy(ON);
	graf_mouse(BUSYBEE, NULL);

	strcpy(esmh.kennung, "TMS\0");
	esmh.head_size=(int)sizeof(ESM_HEADERTYP);
	
	esmh.breite=frame_data.w;
	esmh.hoehe=frame_data.h;
	
	esmh.tiefe=24; /* 24 Bit */
	
	esmh.bildart=4; /* CMY */
	
	esmh.tiefe_rot=esmh.tiefe_gruen=esmh.tiefe_blau=8;
	esmh.tiefe_schwarz=0;
	
	esmh.version=5;
	
	esmh.xdpi=atoi(onew[ONDPI].ob_spec.tedinfo->te_ptext);
	esmh.ydpi=esmh.xdpi;
	
	esmh.file_hoehe=frame_data.h;
	
	esmh.start_zeile=0;
	esmh.end_zeile=frame_data.h-1;
	
	esmh.maske=0;
	
	for(a=0; a < 256; ++a)
		esmh.red_tab[a]=esmh.green_tab[a]=esmh.blue_tab[a]=(unsigned char)a;
	
	strcpy(esmh.copyright, "Grape");

	esmh.reserved[0]=esmh.reserved[1]=esmh.reserved[2]=esmh.reserved[3]=0;
	
	Fwrite(fh, sizeof(ESM_HEADERTYP), &esmh);
	
	if(!get_vis_frame(&c, &m, &y, &h, &w, &uw))
	{
		graf_mouse(ARROW, NULL);
		form_alert(1,"[3][Nicht genug Pufferspeicher!][Abbruch]");
		return(0);
	}
	/* Offsetvariablen */
	lin_ad=uw-w;
	
	l=w*h*3;
	
	/* Bilddaten schreiben */
	buf=(unsigned char*)malloc(l);
	if(!buf)
	{	/* Ganzer Block auf einmal geht nicht! Lahmarsch-Methode
			zeilenweise probieren
		*/
		buf=(unsigned char*)malloc(frame_data.w * 3);
		if(!buf) /* Geht auch nicht! */
		{/* Superlahmarsch, jedes Byte einzeln! */
			for(a=0; a < 	h; ++a)
			{
				for(b=0; b < w; ++b)
				{
					Fwrite(fh, 1, c++);
					Fwrite(fh, 1, m++);
					Fwrite(fh, 1, y++);
				}
				c+=lin_ad; m+=lin_ad, y+=lin_ad;
			}
		}
		for(a=0; a < 	h; ++a)
		{
			l=0;
			for(b=0; b < w; ++b)
			{
				buf[l++]=*c++;
				buf[l++]=*m++;
				buf[l++]=*y++;
			}
			c+=lin_ad; m+=lin_ad, y+=lin_ad;
			Fwrite(fh, l, buf);
		}
	}
	else
	{
		l=0;
		for(a=0; a < 	h; ++a)
		{
			for(b=0; b < w; ++b)
			{
				buf[l++]=*c++;
				buf[l++]=*m++;
				buf[l++]=*y++;
			}
			c+=lin_ad; m+=lin_ad, y+=lin_ad;
		}
		Fwrite(fh, l, buf);
	}
	
	Fclose(fh);
	free(buf);
	free(c); free(m); free(y);

	busy(OFF);
	graf_mouse(ARROW, NULL);

	return(1);
}

int get_vis_frame(unsigned char **c_buf, unsigned char **m_buf, unsigned char **y_buf, long *h, long *w, long *uw)
{
	/* Kopiert alles, was im Selektionsrahmen sichtbar ist
	   in einen Bufferbereich. Der Speicher dafr wird ebenfalls
	   angefordert und ist vom Aufrufer ber free_buf() freizugeben
	   
	   in c/m/y_buf wird der Zeiger auf den Speicherbereich vermerkt
	   h und w liefern die Ausmaže des Speicherbereichs,
	   uw ist die tats„chlich benutzte Breite
	   (w ist das n„chste vielfache von 6)
	   
	   Rckgabe: 1=OK, 0=Fehler, d.h. kein Speicher 
	*/
	
	long siz, wid;

	wid=((frame_data.w+5)/6)*6;
	siz=wid*(long)frame_data.h;
	*c_buf=calloc(siz, 1);
	if(!c_buf)
		return(0);
	*m_buf=calloc(siz, 1);
	if(!m_buf)
	{free(c_buf);	return(0);}
	*y_buf=calloc(siz, 1);
	if(!y_buf)
	{free(c_buf); free(m_buf); return(0);}
	
	*h=frame_data.h;
	*w=frame_data.w;
	*uw=wid;
	
	vis_to_buf(*c_buf, *m_buf, *y_buf, frame_data.x, frame_data.y, wid, frame_data.h);
	return(1);
}

void vis_to_buf(unsigned char *c_buf, unsigned char *m_buf, unsigned char *y_buf, long x, long y, long w, long h)
{
	/* Kopiert den sichtbaren Bereich x/y/w/h als eine CMY-Ebene
		 in die buf-Bereiche. Die Maske wird nicht beachtet
		 Achtung! w muž vielfaches von 6 sein!!
		 Die Puffer mssen vorher gel”scht werden
	*/
	
	LAY_LIST	*l=first_lay;
	long 			p_off, l_dif;
	

	
  /* Letzte Plane finden, die nicht incl. weiž-deckend ist */
	while(l->next && ((l->this.type != 2) ||
				((l->this.type == 2)	&& !(l->this.visible)))
			 ) l=l->next;
	p_off=(long)y*(long)first_lay->this.word_width;
	p_off+=(long)x;

	l_dif=first_lay->this.word_width-w;

	dst_lines=h;
	dst_width=w/6;
	dst_2width=w/2;
	src_offset=l_dif;
		
	while(l)
	{
		if(l->this.visible)
		{
			(unsigned char*)src_red=(unsigned char*)l->this.red+p_off; 
			(unsigned char*)src_blue=(unsigned char*)l->this.blue+p_off;
			(unsigned char*)src_yellow=(unsigned char*)l->this.yellow+p_off;
			dst_red=m_buf; dst_blue=c_buf; dst_yellow=y_buf;
			layeradd_mode=0;
			if(l->this.type)
				layeradd_mode|=1;
			if(l->this.visible & DISABLED)
				layeradd_mode|=2;
			layer_add();
		}
		l=l->prev;
	}
}

void free_buf(void *p)
{
	/* Gibt Speicher frei, wichtig fr Module, die andere Prozež-ID
	   haben
	 */
	free(p);
}

void select_all(void)
{
	if(sel_tool != SSELECT)
	{
		if(T_CCP || (!(form_alert(1,"[2][Grape:|\'Alles ausw„hlen\' ist nur im Rahmen-|Modus m”glich. Soll jetzt in den|Rahmen-Modus gewechselt werden?][OK|Abbruch]")-1)))
		{
			sel_ssel();
			select_all();
		}
		return;
	}
	
	select_all_frame();
}

void select_all_frame(void)
{
	/* Rahmen ausschalten? */
	if(frame_data.vis)
		draw_win_frame();

	if(!frame_data.ok)
		frame_data.wid=main_win.id;
	
	frame_data.x=0; frame_data.y=0;
	frame_data.w=first_lay->this.width;
	frame_data.h=first_lay->this.height;
	
	frame_data.ok=1; frame_data.vis=1;
	draw_win_frame();
}


void object_frame(int wid)
{
	CMY_COLOR scol;
	int				rx,ry, rw, rh, stx, sty, kont_fill;
	uchar			c,m,y, *cc, *mm, *yy, *fbuf, *gbuf;
	int				mx, my, dum;
	long			ad;
	LAYER			*lay;
	MASK			*mask;

	int mplumin=((U_OB*)(ospecial[STOLC]_UP_))->color.r[0];
	int yplumin=((U_OB*)(ospecial[STOLC]_UP_))->color.g[0];
	int cplumin=((U_OB*)(ospecial[STOLC]_UP_))->color.b[0];

	/* Evtl. erstmal Rahmen abschalten */
	if(frame_data.ok && frame_data.vis)
	{
		draw_win_frame();
		frame_data.vis=0;
	}
		
	busy(ON);
	graf_mouse(BUSYBEE, NULL);

	/* nur Kontur fllen */
	kont_fill=1;
	
	graf_mkstate(&mx, &my, &dum, &dum);
		
	wind_get(wid, WF_WORKXYWH, &stx, &sty, &dum, &dum);
	mx-=stx; 
	mx+=main_win.ox;
	mx=mx*MZOP;
	my-=sty;
	my-=(otoolbar[0].ob_height+OTBB);
	my+=main_win.oy;
	my=my*MZOP;
	
	ad=(long)my*(long)act_lay->this.word_width+(long)mx;

	if(otoolbar[MASK_ED-1].ob_state & SELECTED)
	{ /* in Maske */
		cc=mm=yy=(unsigned char*)act_mask->this.mask+ad;
		c=m=y=*cc;
		mask=&(act_mask->this);
		lay=NULL;
	}
	else
	{ /* in Ebene */
		cc=(unsigned char*)act_lay->this.blue+ad;
		mm=(unsigned char*)act_lay->this.red+ad;
		yy=(unsigned char*)act_lay->this.yellow+ad;
		c=*cc; m=*mm; y=*yy;
		lay=&(act_lay->this);
		mask=NULL;
	}

	scol.blue=c;
	scol.red=m;
	scol.yellow=y;
	set_grey(&scol);

	fbuf=compare_buf(lay, mask, mx, my, c, m, y, cplumin, mplumin, yplumin, kont_fill, &rx, &ry, &rw, &rh, &gbuf);
	if(!fbuf)
	{
		graf_mouse(ARROW, NULL);
		busy(OFF);
		form_alert(1,"[3][Fr diese Aktion steht nicht|genug Pufferspeicher zur|Verfgung!][Abbruch]");
		return;
	}
	free(fbuf);

	frame_data.x=rx; frame_data.y=ry;
	frame_data.w=rw; frame_data.h=rh;

	graf_mouse(ARROW, NULL);
	busy(OFF);
	
	frame_data.ok=1;
	draw_win_frame();
	frame_data.vis=1;
}

void frame(int wid)
{
	OBJECT	*poptext;
	int	ptx, pty, ptw, pth;
	int	psx, psy, psw, psh;
	int wx, wy, ww, wh, pxy[10], cxy[10], mx, my, ox, oy, mk, dum;
	int x1, y1, x2, y2, *mvx, *mvy;
	int obw, obh, ecke, mover, kante;
	int	sel, ow, oh, nw, nh, old_x, old_y, old_w, old_h;
	int	*stx, *sty, ms_x, ms_y;
	double h_zu_b;
	_frame_data old_frame=frame_data, orgframe;
	
	xrsrc_gaddr(0, FRAMESIZE, &poptext, xrsrc);
	form_center(poptext, &ptx, &pty, &ptw, &pth);
	
	frame_data.wid=wid;

	if(Kbshift(-1) & 4) /* CTRL gedrckt? */
	{
		object_frame(wid); /*->Ja, Objekt suchen */
		return;
	}
		
	if(frame_data.ok)
	{
		old_x=frame_data.x;
		old_y=frame_data.y;
		old_w=frame_data.w;
		old_h=frame_data.h;
		h_zu_b=(double)frame_data.h/(double)frame_data.w;
	}
	else
		h_zu_b=0;
	
	ecke=0;
	kante=0;
	mover=0;
	
	
	wind_get(wid, WF_WORKXYWH, &wx, &wy, &ww, &wh);
	wy+=otoolbar[0].ob_height+OTBB;
	wh-=otoolbar[0].ob_height+OTBB;
	if(ww > (first_lay->this.width/DZOP-main_win.ox))
		ww=(first_lay->this.width/DZOP-main_win.ox);
	if(wh > (first_lay->this.height/DZOP-main_win.oy))
		wh=(first_lay->this.height/DZOP-main_win.oy);

	wind_update(BEG_UPDATE);
	wind_update(BEG_MCTRL);
	graf_mouse(THIN_CROSS, NULL);
	
	vswr_mode(handle, 3);
	vsl_type(handle, 1);
  vsl_width(handle, 1);
  vsl_color(handle, 1);
  vsl_ends(handle, 0, 0);
  vsm_type(handle, 0);

	cxy[0]=wx; cxy[1]=wy;
	cxy[2]=wx+ww-1; cxy[3]=wy+wh-1;

	graf_mkstate(&mx, &my, &mk, &dum);
	/* Auf Planedaten umrechnen */
	mx=(mx-wx)*MZOP+wx;
	my=(my-wy)*MZOP+wy;

	ms_x=ox=mx; ms_y=oy=my;

	sel=0;
		
	if(frame_data.ok && frame_data.vis)
	{ /* alten Frame l”schen */
		draw_win_frame();
		
		/* Frameobjekte auf Zoom setzen */
		orgframe=frame_data;
		frame_data.x=frame_data.x/DZOP;	frame_data.y=frame_data.y/DZOP;
		frame_data.w=frame_data.w/DZOP;	frame_data.h=frame_data.h/DZOP;
		obw=oframe[FLO].ob_width;
		obh=oframe[FLO].ob_height;
		/* F0 auf Rahmen Minus obw/h /2 setzen */
		oframe[0].ob_x=frame_data.x+wx-main_win.ox-obw/2; 
		oframe[0].ob_y=frame_data.y+wy-main_win.oy-obh/2;
		oframe[0].ob_width=frame_data.w+obw; 
		oframe[0].ob_height=frame_data.h+obh;
		/* FMID genau auf Rahmen setzen */
		oframe[FMID].ob_x=obw/2; oframe[FMID].ob_y=obh/2;
		oframe[FMID].ob_width=frame_data.w; oframe[FMID].ob_height=frame_data.h;
		/* Linke Seite X */
		oframe[FLO].ob_x=oframe[FL].ob_x=oframe[FLU].ob_x=0;
		/* Rechte Seite X */
		oframe[FRO].ob_x=oframe[FR].ob_x=oframe[FRU].ob_x=
			oframe[0].ob_width-obw;
		/* Mitte X */
		oframe[FO].ob_x=oframe[FU].ob_x=
			(oframe[0].ob_width-obw)/2;
		/* Oben Y */
		oframe[FLO].ob_y=oframe[FO].ob_y=oframe[FRO].ob_y=0;
		/* Unten Y */
		oframe[FLU].ob_y=oframe[FU].ob_y=oframe[FRU].ob_y=
			oframe[0].ob_height-obh;
		/* Mitte Y */
		oframe[FR].ob_y=oframe[FL].ob_y=
			(oframe[0].ob_height-obh)/2;
		frame_data=orgframe;

		graf_mkstate(&x1, &y1, &dum, &dum);
		sel=objc_find(oframe, 0, 8, x1, y1);
		if(sel > 0)
		{
			x1=frame_data.x; y1=frame_data.y;
			x2=frame_data.x+frame_data.w-1;
			y2=frame_data.y+frame_data.h-1;
			
			switch(sel)
			{
				case FMID:
					mvx=mvy=NULL;
					sel=1;
					mover=1;
					graf_mouse(USER_DEF, UD_ALLDIR);
				break;
				case FLO:
					mvx=&x1; mvy=&y1;
					stx=&x2; sty=&y2;
					ecke=1;
					graf_mouse(USER_DEF, UD_DIA2);
				break;
				case FO:
					mvx=NULL; mvy=&y1;
					kante=FO;
					graf_mouse(USER_DEF, UD_UPDN);
				break;
				case FRO:
					mvx=&x2; mvy=&y1;
					stx=&x1; sty=&y2;
					ecke=1;
					graf_mouse(USER_DEF, UD_DIA1);
				break;
				case FL:
					mvx=&x1; mvy=NULL;
					kante=FL;
					graf_mouse(USER_DEF, UD_LFRT);
				break;
				case FR:
					mvx=&x2; mvy=NULL;
					kante=FR;
					graf_mouse(USER_DEF, UD_LFRT);
				break;
				case FLU:
					mvx=&x1; mvy=&y2;
					stx=&x2; sty=&y1;
					ecke=1;
					graf_mouse(USER_DEF, UD_DIA1);
				break;
				case FU:
					mvx=NULL; mvy=&y2;
					kante=FU;
					graf_mouse(USER_DEF, UD_UPDN);
				break;
				case FRU:
					mvx=&x2; mvy=&y2;
					stx=&x1; sty=&y1;
					ecke=1;
					graf_mouse(USER_DEF, UD_DIA2);
				break;
			}
		}
		else
			sel=0;
	}
	
	if(!sel)
	{
		x1=x2=frame_data.x=mx-wx+main_win.ox*MZOP; frame_data.w=1;
		y1=y2=frame_data.y=my-wy+main_win.oy*MZOP; frame_data.h=1;
		mvx=&x2; mvy=&y2;
	}
	
	orgframe=frame_data;
	frame_data.x=frame_data.x/DZOP;	frame_data.y=frame_data.y/DZOP;
	frame_data.w=frame_data.w/DZOP;	frame_data.h=frame_data.h/DZOP;
	pxy[0]=frame_data.x+wx-main_win.ox; pxy[1]=frame_data.y+wy-main_win.oy;
	pxy[2]=frame_data.x+wx+frame_data.w-1-main_win.ox; pxy[3]=frame_data.y+wy-main_win.oy;
	pxy[4]=frame_data.x+wx+frame_data.w-1-main_win.ox; pxy[5]=frame_data.y+wy+frame_data.h-1-main_win.oy;
	pxy[6]=frame_data.x+wx-main_win.ox; pxy[7]=frame_data.y+wy+frame_data.h-1-main_win.oy;
	pxy[8]=frame_data.x+wx-main_win.ox; pxy[9]=frame_data.y+wy-main_win.oy;
	graf_mouse(M_OFF, NULL);
	vs_clip(handle, 1, cxy);
	v_pline(handle, 5, pxy);
	vs_clip(handle, 0, cxy);
	graf_mouse(M_ON, NULL);
	frame_data=orgframe;
	
	/* Koordinaten in Infobox eintragen */
	if(frame_data.w < 0) {psx=frame_data.x+frame_data.w; psw=-frame_data.w;}
	else {psx=frame_data.x; psw=frame_data.w;}
	if(frame_data.h < 0) {psy=frame_data.y+frame_data.h; psh=-frame_data.h;}
	else {psy=frame_data.y; psh=frame_data.h;}
	itoa(psx, poptext[FR_X].ob_spec.tedinfo->te_ptext, 10);
	itoa(psy, poptext[FR_Y].ob_spec.tedinfo->te_ptext, 10);
	itoa(psw, poptext[FR_W].ob_spec.tedinfo->te_ptext, 10);
	itoa(psh, poptext[FR_H].ob_spec.tedinfo->te_ptext, 10);
	/* Position fr Infobox auf Screenebene */
	if((mx-wx)/DZOP+main_win.ox > psx/DZOP)
		ptx=(mx-wx)/DZOP+wx+16;
	else
		ptx=(mx-wx)/DZOP+wx-ptw-2;
	if((my-wy)/DZOP+main_win.oy > psy/DZOP)
		pty=(my-wy)/DZOP+wy+16;
	else
		pty=(my-wy)/DZOP+wy-pth-2;
	if(ptx < sx+1) ptx=sx+1;
	if(ptx+ptw > sx+sw) ptx=sx+sw-ptw;
	if(pty < sy) pty=sy;
	if(pty+pth > sy+sh) pty=sy+sh-pth;
	poptext[0].ob_x=ptx; poptext[0].ob_y=pty;
	screen_buf(FMD_START, ptx-1, pty-1, ptw+1, pth+1);
	objc_draw(poptext, 0, 8, sx, sy, sw, sh);	
	
	sel=0;

	do
	{
		graf_mkstate(&mx, &my, &mk, &dum);
	
		if(mx < wx) mx=wx;
		if(mx > wx+ww-1) mx=wx+ww-1;
		if(my < wy) my=wy;
		if(my > wy+wh-1) my=wy+wh-1;
		
		/* Auf Planedaten umrechnen */
		mx=(mx-wx)*MZOP+wx;
		my=(my-wy)*MZOP+wy;
		
		if((mx != ox) || (my != oy))
		{
			screen_buf(FMD_FINISH, ptx-1, pty-1, ptw+1, pth+1);
			sel=1;
			graf_mouse(M_OFF, NULL);
			vs_clip(handle, 1, cxy);
			v_pline(handle, 5, pxy);
			vs_clip(handle, 0, cxy);
			graf_mouse(M_ON, NULL);


			if(mvx)
				*mvx=mx-wx+main_win.ox*MZOP;
			if(mvy)
				*mvy=my-wy+main_win.oy*MZOP;

			if((!mvx) && (!mvy))
			{/* Moven */
				x1=old_x+(mx-ms_x); x2=old_x+old_w-1+(mx-ms_x);
				y1=old_y+(my-ms_y); y2=old_y+old_h-1+(my-ms_y);
			}

			if(ecke && (Kbshift(-1) & 3) && (h_zu_b > 0))
			{ /* Proportionen */
				ow=abs(*stx-*mvx); oh=abs(*sty-*mvy);
				nw=(int)((float)oh/h_zu_b);
				nh=(int)((float)ow*h_zu_b);
		
				if((abs(nw) > abs(ow)))
				{/* Breite „ndern */
					if(x1 < x2)
					{
						if(mvx==&x1)
							*mvx=*stx-nw;
						else
							*mvx=*stx+nw;
					}
					else
					{
						if(mvx==&x1)
							*mvx=*stx+nw;
						else
							*mvx=*stx-nw;
					}
				}
				else
				{/* H”he „ndern */
					if(y1 < y2)
					{
						if(mvy==&y1)
							*mvy=*sty-nh;
						else
							*mvy=*sty+nh;
					}
					else
					{
						if(mvy==&y1)
							*mvy=*sty+nh;
						else
							*mvy=*sty-nh;
					}
				}

				if(*mvx < 0) *mvx=0;
				if(*mvx >= first_lay->this.width)
					*mvx=first_lay->this.width-1;

				if(*mvy < 0) *mvy=0;
				if(*mvy >= first_lay->this.height)
					*mvy=first_lay->this.height-1;
			}

			if(kante && (Kbshift(-1) & 3) && (h_zu_b > 0))
			{ /* Kantenproportionen */
				switch(kante)
				{
					case FU:
						if(y2 > y1) /* ohne umkippen gezogen */
							y1=old_y-(y2-(old_h+old_y-1));
						else
							y1=old_y+old_h-1-(y2-old_y);
						if(y1 < 0) y1=0;
						if(y1 >= first_lay->this.height)
							y1=first_lay->this.height-1;
					break;
					case FO:
						if(y1 < y2) /* ohne umkippen gezogen */
							y2=old_y+old_h-1-(y1-old_y);
						else
							y2=old_y-(y1-(old_h+old_y-1));
						if(y2 < 0) y2=0;
						if(y2 >= first_lay->this.height)
							y2=first_lay->this.height-1;
					break;
					
					case FR:
						if(x2 > x1) /* ohne umkippen gezogen */
							x1=old_x-(x2-(old_w+old_x-1));
						else
							x1=old_x+old_w-1-(x2-old_x);
						if(x1 < 0) x1=0;
						if(x1 >= first_lay->this.width)
							x1=first_lay->this.width-1;
					break;
					case FL:
						if(x1 < x2) /* ohne umkippen gezogen */
							x2=old_x+old_w-1-(x1-old_x);
						else
							x2=old_x-(x1-(old_w+old_x-1));
						if(x2 < 0) x2=0;
						if(x2 >= first_lay->this.width)
							x2=first_lay->this.width-1;
					break;
				}
				if((kante==FU) || (kante==FO))
				{/* Breite anpassen */
					nh=abs(y1-y2);
					ow=(int)((double)nh/h_zu_b);
					nw=ow-(x2-x1);
					x1=x1-nw/2;
					x2=x2+nw/2;
					if(x1 < 0) x1=0;
					if(x2 >= first_lay->this.width)
						x2=first_lay->this.width-1;
				}
				else
				{/* H”he anpassen */
					nw=abs(x1-x2);
					oh=(int)((double)nw*h_zu_b);
					nh=oh-(y2-y1);
					y1=y1-nh/2;
					y2=y2+nh/2;
					if(y1 < 0) y1=0;
					if(y2 >= first_lay->this.height)
						y2=first_lay->this.height-1;
				}
			}
			
			if(mover && (Kbshift(-1) & 3) && (h_zu_b > 0))
			{ /* Snap-Position */
				ow=old_x-((old_x/old_w)*old_w);
				oh=old_y-((old_y/old_h)*old_h);
				if(x1 < x2)
				{
					nw=x2-x1;
					x1=ow+((x1/old_w)*old_w);
					x2=x1+nw;
				}
				else
				{
					nw=x1-x2;
					x2=ow+((x2/old_w)*old_w);
					x1=x2+nw;
				}
				if(y1 < y2)
				{
					nh=y2-y1;
					y1=oh+((y1/old_h)*old_h);
					y2=y1+nh;
				}
				else
				{
					nh=y1-y2;
					y2=oh+((y2/old_h)*old_h);
					y1=y2+nh;
				}
			}

			frame_data.x=x1; frame_data.y=y1;
			frame_data.w=x2-x1+1; frame_data.h=y2-y1+1;	

			if(frame_data.x < 0) frame_data.x=0;
			if(frame_data.y < 0) frame_data.y=0;
			if(frame_data.x+frame_data.w > first_lay->this.width)
				frame_data.x=first_lay->this.width-frame_data.w;
			if(frame_data.y+frame_data.h > first_lay->this.height)
				frame_data.y=first_lay->this.height-frame_data.h;

			orgframe=frame_data;
			frame_data.x=frame_data.x/DZOP;	frame_data.y=frame_data.y/DZOP;
			frame_data.w=frame_data.w/DZOP;	frame_data.h=frame_data.h/DZOP;
			pxy[0]=frame_data.x+wx-main_win.ox; pxy[1]=frame_data.y+wy-main_win.oy;
			pxy[2]=frame_data.x+wx+frame_data.w-1-main_win.ox; pxy[3]=frame_data.y+wy-main_win.oy;
			pxy[4]=frame_data.x+wx+frame_data.w-1-main_win.ox; pxy[5]=frame_data.y+wy+frame_data.h-1-main_win.oy;
			pxy[6]=frame_data.x+wx-main_win.ox; pxy[7]=frame_data.y+wy+frame_data.h-1-main_win.oy;
			pxy[8]=frame_data.x+wx-main_win.ox; pxy[9]=frame_data.y+wy-main_win.oy;
			graf_mouse(M_OFF, NULL);
			vs_clip(handle, 1, cxy);
			v_pline(handle, 5, pxy);
			vs_clip(handle, 0, cxy);
			graf_mouse(M_ON, NULL);
			frame_data=orgframe;

			/* Koordinaten in Infobox eintragen */
			if(frame_data.w < 0) {psx=frame_data.x+frame_data.w-1; psw=-frame_data.w;}
			else {psx=frame_data.x; psw=frame_data.w;}
			if(frame_data.h < 0) {psy=frame_data.y+frame_data.h-1; psh=-frame_data.h;}
			else {psy=frame_data.y; psh=frame_data.h;}
			itoa(psx, poptext[FR_X].ob_spec.tedinfo->te_ptext, 10);
			itoa(psy, poptext[FR_Y].ob_spec.tedinfo->te_ptext, 10);
			itoa(psw, poptext[FR_W].ob_spec.tedinfo->te_ptext, 10);
			itoa(psh, poptext[FR_H].ob_spec.tedinfo->te_ptext, 10);
			/* Position fr Infobox auf Screenebene */
			if((mx-wx)/DZOP+main_win.ox > psx/DZOP)
				ptx=(mx-wx)/DZOP+wx+16;
			else
				ptx=(mx-wx)/DZOP+wx-ptw-2;
			if((my-wy)/DZOP+main_win.oy > psy/DZOP)
				pty=(my-wy)/DZOP+wy+16;
			else
				pty=(my-wy)/DZOP+wy-pth-2;
			if(ptx < sx+1) ptx=sx+1;
			if(ptx+ptw > sx+sw) ptx=sx+sw-ptw;
			if(pty < sy) pty=sy;
			if(pty+pth > sy+sh) pty=sy+sh-pth;
			poptext[0].ob_x=ptx; poptext[0].ob_y=pty;
			screen_buf(FMD_START, ptx-1, pty-1, ptw+1, pth+1);
			objc_draw(poptext, 0, 8, sx, sy, sw, sh);	

			ox=mx;
			oy=my;	
		}
	}while(mk & 3);
	
	if((!frame_data.w) || (!frame_data.h)) /* Rahmen hat Null Breite/H”he */
		sel=0;

	screen_buf(FMD_FINISH, ptx-1, pty-1, ptw+1, pth+1);
	/* Rahmen l”schen */
	graf_mouse(M_OFF, NULL);
	vs_clip(handle, 1, cxy);
	v_pline(handle, 5, pxy);
	vs_clip(handle, 0, cxy);
	graf_mouse(M_ON, NULL);

	frame_data.ok=frame_data.vis=sel;	

	if(sel)
	{ /* Kleinste Koordinaten nach links oben */
		if(x2 < x1)
		{
			sel=x1; x1=x2; x2=sel;
		}
		if(y2 < y1)
		{
			sel=y1; y1=y2; y2=sel;
		}
		frame_data.x=x1; frame_data.y=y1;
		frame_data.w=x2-x1+1; frame_data.h=y2-y1+1;	

		if(frame_data.x < 0) frame_data.x=0;
		if(frame_data.y < 0) frame_data.y=0;
		if(frame_data.x+frame_data.w > first_lay->this.width)
			frame_data.x=first_lay->this.width-frame_data.w;
		if(frame_data.y+frame_data.h > first_lay->this.height)
			frame_data.y=first_lay->this.height-frame_data.h;
			
		draw_win_frame();
	}


	graf_mouse(ARROW, NULL);
	wind_update(END_MCTRL);
	wind_update(END_UPDATE);

	if((old_frame.x != frame_data.x) || (old_frame.y != frame_data.y)
		||(old_frame.w != frame_data.w) || (old_frame.h != frame_data.h)
		||(old_frame.ok != frame_data.ok) || (old_frame.vis != frame_data.vis))
		new_preview_sel();
	if(old_frame.ok != frame_data.ok)
		check_what_export();
}

void draw_frame_clip(GRECT *todo)
{
	int obw, obh, wx, wy, ww, wh, pxy[10], exy[10];
	GRECT clip;
	_frame_data	orgframe=frame_data;
	
	wind_get(frame_data.wid, WF_WORKXYWH, &wx, &wy, &ww, &wh);
	wy+=otoolbar[0].ob_height+OTBB;
	wh-=otoolbar[0].ob_height+OTBB;
	
	wind_update(BEG_UPDATE);
	wind_update(BEG_MCTRL);
	
	vswr_mode(handle, 3);
	vsl_type(handle, 1);
  vsl_width(handle, 1);
  vsl_color(handle, 1);
  vsl_ends(handle, 0, 0);
  vsm_type(handle, 0);
  vsf_interior(handle, 1);
  vsf_color(handle, 1);
  vsf_perimeter(handle, 1);

	clip.g_x=wx; clip.g_y=wy; clip.g_w=ww; clip.g_h=wh;

	if(rc_intersect(todo, &clip))
	{
		pxy[0]=clip.g_x; pxy[1]=clip.g_y;
		pxy[2]=clip.g_x+clip.g_w-1; pxy[3]=clip.g_y+clip.g_h-1;
		vs_clip(handle, 1, pxy);
		
		if(frame_data.ok)
		{ /* Frame zeichnen/l”schen (je nachdem ob er schon da ist)*/
			frame_data.x=frame_data.x/DZOP;
			frame_data.y=frame_data.y/DZOP;
			frame_data.w=frame_data.w/DZOP;
			frame_data.h=frame_data.h/DZOP;

			pxy[0]=frame_data.x+wx-main_win.ox; pxy[1]=frame_data.y+wy-main_win.oy;
			pxy[2]=frame_data.x+wx+frame_data.w-1-main_win.ox; pxy[3]=frame_data.y+wy-main_win.oy;
			pxy[4]=frame_data.x+wx+frame_data.w-1-main_win.ox; pxy[5]=frame_data.y+wy+frame_data.h-1-main_win.oy;
			pxy[6]=frame_data.x+wx-main_win.ox; pxy[7]=frame_data.y+wy+frame_data.h-1-main_win.oy;
			pxy[8]=frame_data.x+wx-main_win.ox; pxy[9]=frame_data.y+wy-main_win.oy;
			
			graf_mouse(M_OFF, NULL);
			v_pline(handle, 5, pxy);
			graf_mouse(M_ON, NULL);
	
			/* Ecken zeichnen */
			obw=oframe[FLO].ob_width;
			obh=oframe[FLO].ob_height;
			/* Obere Reihe */
			exy[0]=pxy[0]-obw/2; exy[1]=pxy[1]-obh/2;
			exy[2]=exy[0]+obw; exy[3]=exy[1]+obh;
			v_bar(handle, exy);
			exy[0]+=frame_data.w/2; exy[2]+=frame_data.w/2;
			v_bar(handle, exy);
			exy[0]+=frame_data.w/2; exy[2]+=frame_data.w/2;
			v_bar(handle, exy);
			/* Untere Reihe */
			exy[0]=pxy[6]-obw/2; exy[1]=pxy[7]-obh/2;
			exy[2]=exy[0]+obw; exy[3]=exy[1]+obh;
			v_bar(handle, exy);
			exy[0]+=frame_data.w/2; exy[2]+=frame_data.w/2;
			v_bar(handle, exy);
			exy[0]+=frame_data.w/2; exy[2]+=frame_data.w/2;
			v_bar(handle, exy);
			/* Mitte rechts & links */
			exy[1]-=frame_data.h/2; exy[3]-=frame_data.h/2;
			v_bar(handle, exy);
			exy[0]=pxy[0]-obw/2; exy[2]=exy[0]+obw;
			v_bar(handle, exy);
			
			frame_data=orgframe;
		}
		
		vs_clip(handle, 0, pxy);
	}
	
	wind_update(END_MCTRL);
	wind_update(END_UPDATE);
}

void	draw_win_frame(void)
{	/* Liest Rechteck-Liste aus, clipped mit xywh und Screen */
	/* setzt CLIP und ruft draw_frame. */

	GRECT scr, rect, todo, mouse;
	int		xywh[4], d, obw, obh;
	_frame_data	orgframe=frame_data;

	obw=oframe[FLO].ob_width;
	obh=oframe[FLO].ob_height;
	
	wind_get(main_win.id, WF_WORKXYWH, &rect.g_x, &rect.g_y, &rect.g_w, &rect.g_h);

	frame_data.x=frame_data.x/DZOP;
	frame_data.y=frame_data.y/DZOP;
	frame_data.w=frame_data.w/DZOP;
	frame_data.h=frame_data.h/DZOP;
	todo.g_x=frame_data.x-obw/2-main_win.ox+rect.g_x;
	todo.g_y=frame_data.y-obh/2-main_win.oy+rect.g_y+otoolbar[0].ob_height+OTBB;
	todo.g_w=frame_data.w+obw;
	todo.g_h=frame_data.h+obh;
	frame_data=orgframe;
	
	if(!rc_intersect(&rect, &todo))
		return;

	graf_mkstate(&(mouse.g_x), &(mouse.g_y), &d, &d);
	mouse.g_x-=16; /* da Hot-Spot unbekannt muž mit doppeltem */
	mouse.g_y-=16; /* Rechteck gerechnet werden */
	mouse.g_h=mouse.g_w=32;

	wind_update(BEG_UPDATE);
	graf_mouse(M_OFF, NULL);

	/* Screen-Gr”že */
	wind_get(0, WF_WORKXYWH, &scr.g_x, &scr.g_y, &scr.g_w, &scr.g_h);
	/* erstes Redraw-Rechteck */
	wind_get(main_win.id, WF_FIRSTXYWH, &rect.g_x, &rect.g_y, &rect.g_w, &rect.g_h);

	while (rect.g_w && rect.g_h)
	{
		if (rc_intersect(&scr, &rect))
		{ /* Liegt im Bildschirm */
			if (rc_intersect(&todo, &rect))
			{ /* Liegt im zu redrawenden Rechteck, rect enth„lt jetzt */
				/* Schnittfl„che */
				xywh[0]=rect.g_x;
				xywh[1]=rect.g_y;
				xywh[2]=rect.g_x+rect.g_w-1;
				xywh[3]=rect.g_y+rect.g_h-1;
				if (handle > -1)
					vs_clip(handle, 1, xywh);
				draw_frame_clip(&rect);

				if (handle > -1)
					vs_clip(handle, 0, xywh);
			}
		}
		wind_get(main_win.id, WF_NEXTXYWH, &rect.g_x, &rect.g_y, &rect.g_w, &rect.g_h);

	}

	graf_mouse(M_ON, NULL);

	wind_update(END_UPDATE);
	
}

/* *************************** */

int write_clipboard(char *name)
{
	/* ™ffnet die Clipboard-Datei 'name' zum Schreiben */
	/* und liefert das Dateihandle */
	/* Ist ein Fehler aufgetreten, wird ein Alert ausge-*/
	/* gegeben und -1 geliefert */
	
	long	fh;
	char	path[256];

	clear_clipboard();	
	clip_path(path);
	
	strcat(path, name);
	fh=Fcreate(path, 0);
	if(fh < 0)
	{
		form_alert(1,"[3][Grape:|Das Clipboard l„žt sich|nicht ”ffnen.][Abbruch]");
		return(-1);
	}
	else
		return((int)fh);
}

int read_clipboard(char *name, char *dpath)
{
	/* ™ffnet die erste Clipboard-Datei, die auf 'name' pažt
		 zum Lesen und liefert das Dateihandle
		 ACHTUNG! name muž grož genug sein, um den kompletten Namen
		 der ge”ffneten Datei aufzunehmen (wird n„mlich darber bergeben)
		 und path muž genug Platz fr den Pfad bieten.
		 Der Clippfad wird immer, der Name nur im Erfolgsfall geschrieben
		 Ist ein Fehler aufgetreten (leeres Clipboard),
		 wird ein Alert ausge-
		 gegeben und -1 geliefert
	*/
	
	long	fh;
	char	path[256], opath[256];
	DTA		*old=Fgetdta(), dta;
	
	clip_path(path);
	strcpy(opath, path);
	strcpy(dpath, path);
	strcat(path, name);
	Fsetdta(&dta);
	if(!Fsfirst(path, 0))
		strcat(opath, dta.d_fname);
	Fsetdta(old);
	
	fh=Fopen(opath, FO_READ);
	if(fh < 0)
	{
		form_alert(1,"[3][Grape:|Das Clipboard enth„lt keine Grafik.][Abbruch]");
		return(-1);
	}

	strcpy(name, dta.d_fname);
	
	return((int)fh);
}

void clear_clipboard(void)
{
	/* L”scht alle SCRAP.* aus dem Clipboard */
	char	path[256], dpath[256], dfile[256];
	DTA		*old=Fgetdta(), dta;	

	clip_path(dpath);
	strcpy(path, dpath);
	strcat(path, "*.*");
	Fsetdta(&dta);
	
	if(!Fsfirst(path, 0))
	{
		do
		{
			strcpy(dfile, dpath);
			strcat(dfile, dta.d_fname);
			Fdelete(dfile);
		}while(!Fsnext());
	}
	Fsetdta(old);
}

void clip_path(char *dst)
{
	/* Schreibt den Clipboard-Pfad in dst. Clipboard wird ggf.
		 angelegt.
		 Pfad endet immer auf '\'
	*/
	long	ssp;
	char	path[256], *tosscrap;
	
	path[0]=0;

	if(!(scrp_read(path) && path[0]))
	{ /* Clipboard suchen und anlegen */
		shel_envrn(&tosscrap, "CLIPBRD");
	  if (!tosscrap) 
	  {
		  shel_envrn(&tosscrap, "SCRAPDIR");
		  if (!tosscrap)
			{
				tosscrap ="X:\\CLIPBRD";
				ssp = Super(0L);
				*tosscrap = (char) (*((int *) 0x446)+65);    /* Bootlaufwerk */
				Super((void*)ssp);
			}
			else
				++tosscrap;
		}
		else
			++tosscrap;

		strcpy(path, tosscrap);
		if(path[strlen(path)-1] != '\\')
			strcat(path,"\\");

		scrp_write(path);
	}/* end not exist */

	if(path[strlen(path)-1] != '\\')
		strcat(path,"\\");

	strcpy(dst, path);
}

void paste_mode(void)
{
	if(!wpmode.open)
	{
		/* Alte Einstellung merken */
		memo_abbruch(opmode);
		
		/* Fenster initialisieren */
		wpmode.dinfo=&dpmode;
		w_dial(&wpmode, D_CENTER);
		wpmode.name="[Grape]";
		w_set(&wpmode, NAME);
		w_open(&wpmode);
	}
	else
		w_top(&wpmode);
}

void dial_pmode(int ob)
{
	switch(ob)
	{
		case PMABBRUCH:
			recall_abbruch(opmode);
		case PMOK:
			w_unsel(&wpmode, ob);
			w_close(&wpmode);
			w_kill(&wpmode);
		break;
	}
}