#include <grape_h.h>
#include "grape.h"
#include "coled.h"
#include "xrsrc.h"

#define COLLAST COL1+259
void key_col_sel(void)
{
	int		was_open=wcolpal.open;
	int		ox, oy, ow, oh;
	int		was_top, dum;
	int		mx, my, swt, key, evnt;
	
	/* Alten Zustand merken */
	wind_get(0 ,WF_TOP, &was_top, &dum, &dum, &dum);
	if(was_open) 
		wind_get(wcolpal.whandle ,WF_CURRXYWH, &ox, &oy, &ow, &oh);
	

	/* Palette auf Screen bringen */
	fetz_her(&wcolpal);
	if(wcolpal.wx < sx)
		wcolpal.wx=sx;
	if(wcolpal.wy < sy)
		wcolpal.wy=sy;
	if(wcolpal.wx+wcolpal.ww > sx+sw)
		wcolpal.wx=sx+sw-wcolpal.ww;
	if(wcolpal.wy+wcolpal.wh > sy+sh)
		wcolpal.wy=sy+sh-wcolpal.wh;
	w_set(&wcolpal, CURR);
	
	evnt=0;
	while(evnt != MU_TIMER)
		w_dtimevent(&evnt, &mx, &my, &swt, &key, 50, 0);

	read_col_key();
		
	/* Alten Fensterzustand herstellen */

	if(!was_open)
		w_close(&wcolpal);
	else
	{
		wcolpal.wx=ox; wcolpal.wy=oy; wcolpal.ww=ow; wcolpal.wh=oh;
		w_set(&wcolpal, CURR);
	}
		
	if(w_find(was_top))
		w_top(w_find(was_top));
	else if(was_top == main_win.id)
		wind_set(main_win.id, WF_TOP, 0, 0 ,0 ,0);
}

void read_col_key(void)
{
	int evnt, swt, key, dum, leave=0;
	int	on_col=3, off_col=11, ob, mx, my;
	unsigned int scan;
	int	c1=-1, c2;
		
	wind_update(BEG_UPDATE);
	wind_update(BEG_MCTRL);

	ocolpal[CSELLED].ob_spec.bitblk->bi_color=3; /* 3=HellgrÅn, 11=DunkelgrÅn */
	objc_draw(ocolpal, CSELLED, 8, sx, sy, sw, sh);
	
	while(!leave)
	{
		evnt=evnt_multi(MU_BUTTON|MU_KEYBD|MU_TIMER, 258, 3, 0, 
							 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
							 pbuf, 300, 0, &dum, &dum, &dum,
							 &swt, &key, &dum);
		
		if(evnt & MU_KEYBD)
		{
			scan=key;
			scan=scan>>8;
			if (c1 == -1)
			{ /* c1 belegen */
				c1=scan;
				if( ((c1 >= 2) && (c1 <= 11)) ||
						((c1 >= 103) && (c1 <= 112))
					)
				/* Ziffer gedrÅckt */
					{c1=512; c2=scan;} /* c1=Spezial-Code fÅr Offset */
				
				else if(  ((c1 >= 16) && (c1 <= 25)) ||
									((c1 >= 30) && (c1 <= 38)) ||
									((c1 >= 44) && (c1 <= 50))
								)
				/* Buchstabe gedrÅckt */
				/* Merken und Blinkfarbe auf Gelb */
					{c1=scan; c2=-1; on_col=6; off_col=14;}
				else
					/* Irgendwas gedrÅckt */
					c1=c2=0;
			}
			else
			{ /* c2 belegen */
				c2=scan;
				if( ((c2 >= 2) && (c2 <= 11)) ||
						((c2 >= 103) && (c2 <= 112))
					)
				/* Ziffer gedrÅckt */
					c2=scan;
				else
				/* Irgendwas gedrÅckt */
					c1=c2=0;
			}
			
			if((c1 > -1) && (c2 > -1))
				leave=1;
		}
		if(evnt & MU_TIMER)
		{
			if(ocolpal[CSELLED].ob_spec.bitblk->bi_color==on_col)
				ocolpal[CSELLED].ob_spec.bitblk->bi_color=off_col;
			else
				ocolpal[CSELLED].ob_spec.bitblk->bi_color=on_col;
			objc_draw(ocolpal, CSELLED, 8, sx, sy, sw, sh);
		}
		if(evnt & MU_BUTTON)
		{
			c1=c2=0;
			leave=1;
		}
	}

	ocolpal[CSELLED].ob_spec.bitblk->bi_color=11; /* 3=HellgrÅn, 11=DunkelgrÅn */
	objc_draw(ocolpal, CSELLED, 8, sx, sy, sw, sh);

	if(c1 && c2)
		get_key_color(c1, c2);
	else if(evnt & MU_BUTTON)
	{
		/* Mausklick auch auswerten */
		graf_mkstate(&mx, &my, &dum, &dum);
		ob=objc_find(ocolpal, 0, 8, mx, my);
		if((ob >= COL1) && (ob <= COLLAST))
			color_dd(ocolpal, ob);
	}
			
	wind_update(END_MCTRL);
	wind_update(END_UPDATE);
}

void get_key_color(int c1, int c2)
{
	int	tab1[]={16, 22, 4, 17, 19, 25, 20, 8, 14, 15,
							  0, 18, 3, 5, 6, 7, 9, 10, 11,
							   24, 23, 2, 21, 1, 13, 12
						};
						
	int	tab2[]={7,8,9,4,5,6,1,2,3,0};
	
	if(c1 == 512) /* Es wurde nur Ziffer gedrÅckt */
	{
		c1=colpal_obs.off;
	}
	else
	{/* Normale Taste */
		/* c1 Konvertieren */
		/* ab 44 auf ab 39 abbilden */
		if(c1 > 43)
			c1-=5;
		/* ab 30 auf ab 26 abbilden */
		if(c1 > 29)
			c1-=4;
		/* Das ganze ab 0 statt ab 16 */
		c1-=16;
		
		/* Wert aus Tabelle holen */
		c1=tab1[c1];
	}
	
	/* c2 Konvertieren */
	if(c2 > 102) /* Auf Ziffernblock */
		c2=tab2[c2-103];
	else /* ab 0 statt ab 2 */
		c2-=2;

	got_frame(c1, c2);	
	set_color(COL1+c1*10+c2);
}

void got_frame(int c1, int c2)
{
	int	x,y,w,h;
	
	if(colpal_obs.off  > c1)
		return;
	if(colpal_obs.off+colpal_obs.len <= c1)
		return;
	
	objc_offset(ocolpal, COL1, &x, &y);
	w=ocolpal[COL1].ob_width;
	h=ocolpal[COL1].ob_height;
	
	y+=(c1-colpal_obs.off)*h;
	x+=c2*w;
	
	form_blink(3, 50, x, y, w, h);
}

/* Farbe aus Palette setzen */

void set_color(int ob)
{
	CMY_COLOR col;
	
	/* ob=Objektnummer des Farbfelds */
	
	col.red=((U_OB*)(ocolpal[ob]_UP_))->color.r[0];
	col.yellow=((U_OB*)(ocolpal[ob]_UP_))->color.g[0];
	col.blue=((U_OB*)(ocolpal[ob]_UP_))->color.b[0];
	set_pen_col(&col);
}

/* Farb-Palette */
void dial_colpal(int ob)
{
	if((ob >= COL1) && (ob <= COLLAST))
		color_dd(ocolpal, ob);
	else if(ob == COLEDLS)
		colpal_load_save();
}

void colpal_load_save(void)
{
	int fh;
	
	fh=quick_io("Farb-Palette", paths.colpal_path, NULL, NULL, 0, magics.colpal);
	if(fh>0)
	{
		if(!(form_alert(1,"[1][Grape:|Die vorhandenen Farben|werden Åberschrieben!][OK|Abbruch]")-1))
			colpal_load(fh);
	}
	else if(fh < 0)
		colpal_save(-fh);
}

void read_col_pal(CMY_COLOR *pal)
{ /* Aus einem 260-groûen CMY-Feld die Farbpalette fÅllen */
	int a;
	
	for(a=0; a <260; ++a)
		fill_colpal_ob(COL1+a, pal[a].red, pal[a].yellow, pal[a].blue);
}

void write_col_pal(CMY_COLOR *pal)
{ /* Ein 260-groûes CMY-Feld mit der Farbpalette fÅllen */
	int a;
	
	for(a=0; a < 260; ++a)
	{
		pal[a].red=((U_OB*)(ocolpal[COL1+a]_UP_))->color.r[0];
		pal[a].yellow=((U_OB*)(ocolpal[COL1+a]_UP_))->color.g[0];
		pal[a].blue=((U_OB*)(ocolpal[COL1+a]_UP_))->color.b[0];
	}
}

void colpal_load(int fh)
{
	CMY_COLOR	col_pal[260];

	wind_update(BEG_MCTRL);
	graf_mouse(BUSYBEE, NULL);
	
	/* Farben laden */
	Fread(fh, 260*sizeof(CMY_COLOR), col_pal);
	read_col_pal(col_pal);
	
	Fread(fh, sizeof(colpal_obs), &colpal_obs);
	
	Fclose(fh);
	
	graf_mouse(ARROW, NULL);
	wind_update(END_MCTRL);

	if(T_WINPOS)
	{
		wcolpal.wx=colpal_obs.wx;
		wcolpal.wy=colpal_obs.wy;
		wcolpal.ww=colpal_obs.ww;
		wcolpal.wh=colpal_obs.wh;
		w_set(&wcolpal, CURR);
		set_colpal_slide();
	}
	
	s_redraw(&wcolpal);
}

void colpal_save(int fh)
{
	CMY_COLOR	col_pal[260];

	write_col_pal(col_pal);
	
	wind_update(BEG_MCTRL);
	graf_mouse(BUSYBEE, NULL);

	Fwrite(fh, 260*sizeof(CMY_COLOR), col_pal);
	
	colpal_obs.wx=wcolpal.wx;
	colpal_obs.wy=wcolpal.wy;
	colpal_obs.ww=wcolpal.ww;
	colpal_obs.wh=wcolpal.wh;
	
	Fwrite(fh, sizeof(colpal_obs), &colpal_obs);
	Fclose(fh);

	graf_mouse(ARROW, NULL);
	wind_update(END_MCTRL);
}

void	colpal_arrowed(WINDOW *win, int *pbuf)
{
	int r=0;
	
	switch(pbuf[4])
	{
		case WA_UPLINE:
			if(colpal_obs.off)
			{
				--colpal_obs.off;
				r=1;
			}
		break;
		case WA_DNLINE:
			if(colpal_obs.off < (26-colpal_obs.len))
			{
				++colpal_obs.off;
				r=1;
			}
		break;
		
		case WA_UPPAGE:
			if(colpal_obs.off)
			{
				colpal_obs.off-=colpal_obs.len;
				if(colpal_obs.off < 0) colpal_obs.off=0;
				r=1;
			}
		break;
		case WA_DNPAGE:
			if(colpal_obs.off < (26-colpal_obs.len))
			{
				colpal_obs.off+=colpal_obs.len;
				if(colpal_obs.off > 26-colpal_obs.len)
					colpal_obs.off=26-colpal_obs.len;
				r=1;
			}
		break;
	}
	
	if(r)
	{
		set_colpal_slide();
		colpal_redraw();
	}
}

void	colpal_vslid(WINDOW *win, int *pbuf)
{
	long	l;
	
	l=pbuf[4];
	l*=(long)((long)26-(long)colpal_obs.len);
	l/=1000l;
	
	if(l != colpal_obs.off)
	{
		colpal_obs.off=(int)l;
		set_colpal_slide();
		colpal_redraw();
	}
}

void	colpal_sized(WINDOW *win, int *pbuf)
{
	int	a, r=0;

	/* Neue Grîûe berechnen */
	wind_calc(WC_WORK, win->kind, pbuf[4], pbuf[5], pbuf[6], pbuf[7], &pbuf[4], &pbuf[5], &pbuf[6], &pbuf[7]);
	a=(pbuf[7]-ocolpal[GCPHEAD].ob_height	)/ocolpal[COL1].ob_height;
	
	if(a < 1) a=1;
	if(a > 26) a=26;
	if(pbuf[6] > ocolpal[0].ob_width+2) pbuf[6]=ocolpal[0].ob_width+2;
	if(pbuf[6] < ocolpal[CSELLED].ob_x+ocolpal[CSELLED].ob_width)
		pbuf[6]=ocolpal[CSELLED].ob_x+ocolpal[CSELLED].ob_width;
	if((a != colpal_obs.len) || (pbuf[6] != win->aw))
	{
		w_calc(win);
		win->ah=ocolpal[GCPHEAD].ob_height+ocolpal[COL1].ob_height*a;
		win->aw=pbuf[6];
		w_wcalc(win);
		w_set(win, CURR);

		if(a <= colpal_obs.len)
		{ /* Kleiner->auf Redraw verzichten */
			colpal_obs.len=a;
			set_colpal_slide();
		}
		else
		{ /* Grîûer->evtl. pos. etc. neu setzen */
			colpal_obs.len=a;
			if(colpal_obs.off+colpal_obs.len > 26)
			{
				colpal_obs.off=26-colpal_obs.len;
				r=1;
			}
			set_colpal_slide();
			if(r)
				colpal_redraw();
		}
	}
}

void set_colpal_slide(void)
{
	long	a, l;
	int		c, h, x;
	
	/* Slidergrîûe */
	l=colpal_obs.len;
	l*=1000;
	l/=26;
	
	wcolpal.vsiz=(int)l;
	
	l=(long)((long)colpal_obs.off*(long)1000);
	a=26-colpal_obs.len;
	if(!a)
		l=1000;
	else
		l/=a;
	wcolpal.vpos=(int)l;
	w_set(&wcolpal, VSLIDE);
	
	/* Buchstaben neu setzen */
	for(c=0; c < 26; ++c)
		ocolpal[CPLETTER+c].ob_spec.tedinfo->te_ptext[0]=65+c+colpal_obs.off;
	
	/* Userdef-Position anpassen */

	/* Obere verstecken */
	for(x=0; x < colpal_obs.off; ++x)
		for(c=0; c < 10; ++c)
			ocolpal[COL1+x*10+c].ob_flags |= HIDETREE;
	/* Untere verstecken */
	for(x=colpal_obs.off+colpal_obs.len; x < 26; ++x)
		for(c=0; c < 10; ++c)
			ocolpal[COL1+x*10+c].ob_flags |= HIDETREE;

	/* Sichtbaren Rest nach oben und aufdecken */
	h=ocolpal[COL1].ob_height;
	for(x=colpal_obs.off; x < colpal_obs.off+colpal_obs.len; ++x)
		for(c=0; c < 10; ++c)
		{
			ocolpal[COL1+x*10+c].ob_flags &= (~HIDETREE);
			ocolpal[COL1+x*10+c].ob_y = h*(x-colpal_obs.off);
		}
}


void colpal_redraw(void)
{
	int	x, y, w, h;
	
	objc_offset(ocolpal, CPREDRAW, &x, &y);
	w=ocolpal[CPREDRAW].ob_width;
	h=ocolpal[CPREDRAW].ob_height;
	w_redraw(&wcolpal, x, y, w, h, 0);
}



/* Farb-Editor */


void set_grey(CMY_COLOR *col)
{
	unsigned int mr,mg,mb,mc;

	mr=255-col->blue;
	mg=255-col->red;
	mb=255-col->yellow;
	/* RGB->Grey Hibyte(77*R+151*G+28*B) */
	mc=77*mr+151*mg+28*mb;
	mc=mc >> 8;
	col->grey=(unsigned char)255-mc;
}


void dial_coled(int ob)
{
	CMY_COLOR	c;

	switch(ob)
	{
		case GCECOL:
			color_dd(ocoled, GCECOL);
		break;
		case -GCECOL:	/* Falls Color-DD Ziel */
			c.red=((U_OB*)(ocoled[GCECOL]_UP_))->color.r[0];
			c.yellow=((U_OB*)(ocoled[GCECOL]_UP_))->color.g[0];
			c.blue=((U_OB*)(ocoled[GCECOL]_UP_))->color.b[0];
			set_col_ed(&c); /* Macht alles die Funktion */
		break;
		
		/* ob-1 bei den Slidern, weil das Touchexit-Objekt ein Image
			 (das Child des eigentlichen Sliders) ist */
		case GCECS:
			slide(ocoled, ob-1, 0, 255, ((U_OB*)(ocoled[GCECOL]_UP_))->color.b[0], sl_cec);
		break;
		case GCECB:
			bar(&wcoled, ob, 0, 255, sl_cec);
		break;
		
		case GCEMS:
			slide(ocoled, ob-1, 0, 255, ((U_OB*)(ocoled[GCECOL]_UP_))->color.r[0], sl_cem);
		break;	
		case GCEMB:
			bar(&wcoled, ob, 0, 255, sl_cem);
		break;

		case GCEYS:
			slide(ocoled, ob-1, 0, 255, ((U_OB*)(ocoled[GCECOL]_UP_))->color.g[0], sl_cey);
		break;	
		case GCEYB:
			bar(&wcoled, ob, 0, 255, sl_cey);
		break;
		
		case GCESWS:
			c.red=((U_OB*)(ocoled[GCECOL]_UP_))->color.r[0];
			c.yellow=((U_OB*)(ocoled[GCECOL]_UP_))->color.g[0];
			c.blue=((U_OB*)(ocoled[GCECOL]_UP_))->color.b[0];
			set_grey(&c);
			slide(ocoled, ob, 0, 255, c.grey, sl_grey);
		break;
		case GCESWB:
			bar(&wcoled, ob, 0, 255, sl_grey);
		break;
		
		case GCOLEDLS:
			c.red=((U_OB*)(ocoled[GCECOL]_UP_))->color.r[0];
			c.yellow=((U_OB*)(ocoled[GCECOL]_UP_))->color.g[0];
			c.blue=((U_OB*)(ocoled[GCECOL]_UP_))->color.b[0];
			if(quick_io("Farbe", paths.col_path, &c, &c, sizeof(CMY_COLOR), magics.col) == QIOLOAD)
			{
				set_col_ed(&c);
			}
		break;
		
		case GCECMY:
			ocoled[GCECL].ob_spec.bitblk->bi_color=0;
			ocoled[GCEML].ob_spec.bitblk->bi_color=0;
			ocoled[GCEYL].ob_spec.bitblk->bi_color=0;
			ocoled[GCECS].ob_spec.bitblk->bi_color=5;
			ocoled[GCEMS].ob_spec.bitblk->bi_color=7;
			ocoled[GCEYS].ob_spec.bitblk->bi_color=6;
			ocoled[GCECR].ob_spec.bitblk->bi_color=5;
			ocoled[GCEMR].ob_spec.bitblk->bi_color=7;
			ocoled[GCEYR].ob_spec.bitblk->bi_color=6;
		
			itoa(((U_OB*)(ocoled[GCECOL]_UP_))->color.b[0], ocoled[CCOLVAL].ob_spec.tedinfo->te_ptext, 10);
			itoa(((U_OB*)(ocoled[GCECOL]_UP_))->color.r[0], ocoled[MCOLVAL].ob_spec.tedinfo->te_ptext, 10);
			itoa(((U_OB*)(ocoled[GCECOL]_UP_))->color.g[0], ocoled[YCOLVAL].ob_spec.tedinfo->te_ptext, 10);
			s_redraw(&wcoled);
		break;
		case GCERGB:
			ocoled[GCECL].ob_spec.bitblk->bi_color=2;
			ocoled[GCEML].ob_spec.bitblk->bi_color=3;
			ocoled[GCEYL].ob_spec.bitblk->bi_color=4;
			ocoled[GCECS].ob_spec.bitblk->bi_color=2;
			ocoled[GCEMS].ob_spec.bitblk->bi_color=3;
			ocoled[GCEYS].ob_spec.bitblk->bi_color=4;
			ocoled[GCECR].ob_spec.bitblk->bi_color=1;
			ocoled[GCEMR].ob_spec.bitblk->bi_color=1;
			ocoled[GCEYR].ob_spec.bitblk->bi_color=1;
			itoa(255-((U_OB*)(ocoled[GCECOL]_UP_))->color.b[0], ocoled[CCOLVAL].ob_spec.tedinfo->te_ptext, 10);
			itoa(255-((U_OB*)(ocoled[GCECOL]_UP_))->color.r[0], ocoled[MCOLVAL].ob_spec.tedinfo->te_ptext, 10);
			itoa(255-((U_OB*)(ocoled[GCECOL]_UP_))->color.g[0], ocoled[YCOLVAL].ob_spec.tedinfo->te_ptext, 10);
			s_redraw(&wcoled);
		break;
	}
}

void set_col_ed(CMY_COLOR *c)
{
	long	width=ocoled[GCECB].ob_width-ocoled[GCECS].ob_width;
	long	l;

	set_grey(c);

	/* Userdef setzen */
	sl_cec(c->blue);
	sl_cem(c->red);
	sl_cey(c->yellow);
	
	/* Slider setzen */
	l=width*(long)c->blue;
	l/=256;
	ocoled[GCECS-1].ob_x=(int)l;
	
	l=width*(long)c->red;
	l/=256;
	ocoled[GCEMS-1].ob_x=(int)l;
	
	l=width*(long)c->yellow;
	l/=256;
	ocoled[GCEYS-1].ob_x=(int)l;

	l=width*(long)c->grey;
	l/=256;
	ocoled[GCESWS].ob_x=(int)l;
		
	if(ocoled[GCECMY].ob_state & SELECTED)
	{/*	CMY-Zahlen */
		itoa(ocoled[GCECS-1].ob_x, ocoled[CCOLVAL].ob_spec.tedinfo->te_ptext, 10);
		itoa(ocoled[GCEMS-1].ob_x, ocoled[MCOLVAL].ob_spec.tedinfo->te_ptext, 10);
		itoa(ocoled[GCEYS-1].ob_x, ocoled[YCOLVAL].ob_spec.tedinfo->te_ptext, 10);
	}
	else
	{/* RGB-Zahlen */
		itoa(255-ocoled[GCECS-1].ob_x, ocoled[CCOLVAL].ob_spec.tedinfo->te_ptext, 10);
		itoa(255-ocoled[GCEMS-1].ob_x, ocoled[MCOLVAL].ob_spec.tedinfo->te_ptext, 10);
		itoa(255-ocoled[GCEYS-1].ob_x, ocoled[YCOLVAL].ob_spec.tedinfo->te_ptext, 10);
	}
	
	w_objc_draw(&wcoled, 0, 8, sx, sy, sw, sh);
}

void set_grey_slide(void)
{
	CMY_COLOR c;
	long	width=ocoled[GCECB].ob_width-ocoled[GCECS].ob_width;
	long	l;
	int x, y, w,h;
	
	c.red=((U_OB*)(ocoled[GCECOL]_UP_))->color.r[0];
	c.yellow=((U_OB*)(ocoled[GCECOL]_UP_))->color.g[0];
	c.blue=((U_OB*)(ocoled[GCECOL]_UP_))->color.b[0];
	set_grey(&c);
	l=width*(long)c.grey;
	l/=256;
	ocoled[GCESWS].ob_x=(int)l;
	
	objc_offset(ocoled, GCESWB, &x, &y);
	w=ocoled[GCESWB].ob_width; h=ocoled[GCESWB].ob_height;
	w_objc_draw(&wcoled, 0, 8, x, y, w, h);
}

void sl_grey(int c)
{
	CMY_COLOR col;
	int	dif, nc, nm, ny;
	
	col.red=((U_OB*)(ocoled[GCECOL]_UP_))->color.r[0];
	col.yellow=((U_OB*)(ocoled[GCECOL]_UP_))->color.g[0];
	col.blue=((U_OB*)(ocoled[GCECOL]_UP_))->color.b[0];
	set_grey(&col);

	dif=c-col.grey;
	nc=col.blue+dif;
	nm=col.red+dif;
	ny=col.yellow+dif;
	
	if(nc < 0) nc=0;
	if(nc > 255) nc=255;
	if(nm < 0) nm=0;
	if(nm > 255) nm=255;
	if(ny < 0) ny=0;
	if(ny > 255) ny=255;
	
	col.blue=(uchar)nc;
	col.red=(uchar)nm;
	col.yellow=(uchar)ny;
	set_grey(&col);

	set_col_ed(&col);	
	w_objc_draw(&wcoled, GCECB, 8, sx, sy, sw, sh);
	w_objc_draw(&wcoled, GCEMB, 8, sx, sy, sw, sh);
	w_objc_draw(&wcoled, GCEYB, 8, sx, sy, sw, sh);
}

void sl_cec(int c)
{
	int a, b;

	b=((U_OB*)(ocoled[GCECOL]_UP_))->color.w*ocoled[GCECOL].ob_height;
	
	for(a=0; a < b; ++a)
		((U_OB*)(ocoled[GCECOL]_UP_))->color.b[a]=c;

	if(ocoled[GCECMY].ob_state & SELECTED) /*	CMY-Zahlen */
		itoa(c, ocoled[CCOLVAL].ob_spec.tedinfo->te_ptext, 10);
	else /* RGB-Zahlen */
		itoa(255-c, ocoled[CCOLVAL].ob_spec.tedinfo->te_ptext, 10);
	
	w_objc_draw(&wcoled, GCECOL, 2, sx, sy, sw, sh);
	w_objc_draw(&wcoled, CCOLVAL, 8, sx, sy, sw, sh);
	set_grey_slide();
}
void sl_cem(int c)
{
	int a, b;

	b=((U_OB*)(ocoled[GCECOL]_UP_))->color.w*ocoled[GCECOL].ob_height;
	
	for(a=0; a < b; ++a)
		((U_OB*)(ocoled[GCECOL]_UP_))->color.r[a]=c;

	if(ocoled[GCECMY].ob_state & SELECTED) /*	CMY-Zahlen */
		itoa(c, ocoled[MCOLVAL].ob_spec.tedinfo->te_ptext, 10);
	else /* RGB-Zahlen */
		itoa(255-c, ocoled[MCOLVAL].ob_spec.tedinfo->te_ptext, 10);
	
	w_objc_draw(&wcoled, GCECOL, 2, sx, sy, sw, sh);
	w_objc_draw(&wcoled, MCOLVAL, 8, sx, sy, sw, sh);
	set_grey_slide();
}
void sl_cey(int c)
{
	int a, b;

	b=((U_OB*)(ocoled[GCECOL]_UP_))->color.w*ocoled[GCECOL].ob_height;
	
	for(a=0; a < b; ++a)
		((U_OB*)(ocoled[GCECOL]_UP_))->color.g[a]=c;

	if(ocoled[GCECMY].ob_state & SELECTED) /*	CMY-Zahlen */
		itoa(c, ocoled[YCOLVAL].ob_spec.tedinfo->te_ptext, 10);
	else /* RGB-Zahlen */
		itoa(255-c, ocoled[YCOLVAL].ob_spec.tedinfo->te_ptext, 10);
	
	w_objc_draw(&wcoled, GCECOL, 2, sx, sy, sw, sh);
	w_objc_draw(&wcoled, YCOLVAL, 8, sx, sy, sw, sh);
	set_grey_slide();
}

