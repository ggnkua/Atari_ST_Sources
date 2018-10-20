#include <grape_h.h>
#include "grape.h"
#include "penedit.h"
#include "fill.h"
#include "maininit.h"
#include "zoom.h"
#include "mforms.h"
#include "undo.h"
#include "varycopy.h"


void do_magic_mask(MAG_MASK *msk)
{
	register uchar *cc, *mm, *yy, *ms;
	register int	ww=msk->w;
	register long ldif=(long)first_lay->this.word_width-(long)ww;
	register long sc, sm, sy;
	long start=(long)first_lay->this.word_width*(long)msk->sy+(long)msk->sx;
	register int xc,yc;
	_frame_data oframe=frame_data;
	
	int mplumin=((U_OB*)(ospecial[STOLC]_UP_))->color.r[0];
	int yplumin=((U_OB*)(ospecial[STOLC]_UP_))->color.g[0];
	int cplumin=((U_OB*)(ospecial[STOLC]_UP_))->color.b[0];

	frame_data.x=msk->sx; frame_data.y=msk->sy;
	frame_data.w=msk->w; frame_data.h=msk->h;
	if(!frame_to_undo_mouse(NULL, &(act_mask->this), 0))
	{
		frame_data=oframe;
		return;	/* Da kam nicht 1 ->Fehler bzw. Abbruch */
	}
	frame_data=oframe;
		
	cc=msk->c+start;	mm=msk->m+start;	yy=msk->y+start;
	sc=sm=sy=0;	
	for(yc=msk->h; yc > 0; --yc)
	{
		for(xc=ww; xc > 0; --xc)
		{
			sc+=*cc++; sm+=*mm++;	sy+=*yy++;
		}
		cc+=ldif;	mm+=ldif;	yy+=ldif;
	}

	/* Durchschnitte ausrechnen */
	sc/=(long)(msk->w*msk->h);
	sm/=(long)(msk->w*msk->h);
	sy/=(long)(msk->w*msk->h);
	
	ms=msk->mask+start;
	cc=msk->c+start;	mm=msk->m+start;	yy=msk->y+start;

	/* Welchen Bereich einfÑrben? */
	if(((sc>128)&&((sm>128)||(sy>128))) || ((sm>128)&&(sy>128)))
	{/* Den dunklen */
		sc-=cplumin; if(sc < 0) sc=0;
		sm-=mplumin; if(sm < 0) sm=0;
		sy-=yplumin; if(sy < 0) sy=0;
		for(yc=msk->h; yc > 0; --yc)
		{
			for(xc=ww; xc > 0; --xc)
			{
				if(((*cc>=sc)&&((*mm>=sm)||(*yy>=sy))) || ((*mm>=sm)&&(*yy>=sy)))
					*ms++=255;
				else
					*ms++=0;
				++cc; ++mm; ++yy;
			}
			cc+=ldif;	mm+=ldif;	yy+=ldif; ms+=ldif;
		}
	}
	else
	{/* Den hellen */
		sc+=cplumin; if(sc > 255) sc=255;
		sm+=mplumin; if(sm > 255) sm=255;
		sy+=yplumin; if(sy > 255) sy=255;
		for(yc=msk->h; yc > 0; --yc)
		{
			for(xc=ww; xc > 0; --xc)
			{
				if(((*cc<=sc)&&((*mm<=sm)||(*yy<=sy))) || ((*mm<=sm)&&(*yy<=sy)))
					*ms++=255;
				else
					*ms++=0;
				++cc; ++mm; ++yy;
			}
			cc+=ldif;	mm+=ldif;	yy+=ldif; ms+=ldif;
		}
	}
}

void magic_mask(int wid)
{
	int				stx, sty, ox, oy, mx, my, k, dum, vx, vy, vw, vh;
	int				dsx, dsy, dex, dey;
	MAG_MASK	msk;
	LAY_LIST	*l=first_lay;
		
  /* Erste sichtbare Plane finden */
	while(l->next && !(l->this.visible)) l=l->next;
	if(!(l->this.visible))
	{/* Keine sichtbare Ebene->Keine Magic-Mask! */
		Bell();
		return;
	}

	msk.c=l->this.blue;
	msk.m=l->this.red;
	msk.y=l->this.yellow;
	msk.mask=act_mask->this.mask;
	painted_mask=act_mask;
	
	wind_get(wid, WF_WORKXYWH, &stx, &sty, &vw, &vh);
	sty+=(otoolbar[0].ob_height+OTBB);
	/* TatsÑchlich sichtbarer Bereich: */
	vx=main_win.ox*MZOP; vy=main_win.oy*MZOP;
	vw=vw*MZOP; vh=vh*MZOP;
	if(vw > first_lay->this.width) vw=first_lay->this.width;
	if(vh > first_lay->this.height) vh=first_lay->this.height;
	ox=oy=0;
	auto_reset(0);
	graf_mouse(USER_DEF, UD_SLASSO);
	do
	{
		graf_mkstate(&mx, &my, &k, &dum);
		mx-=stx; mx+=main_win.ox;	mx=mx*MZOP;
		my-=sty; my+=main_win.oy;	my=my*MZOP;
		if((mx < vx) || (mx > vx+vw) || (my < vy) || (my > vy+vh))
		{mx=ox; my=oy;} /* AusfÅhrungsversuch vereiteln */
		if((mx != ox)||(my != oy))
		{
			ox=mx; oy=my;
			dsx=mx-8; dsy=my-8; dex=mx+8; dey=my+8;
			if(dsx < 0) dsx=0;
			if(dsy < 0) dsy=0;
			if(dex > vx+vw) dex=vx+vw;
			if(dey > vy+vh) dey=vy+vh;
			msk.sx=dsx; msk.sy=dsy;
			msk.w=dex-dsx; msk.h=dey-dsy;
			do_magic_mask(&msk);
			if(otoolbar[MASK_VIS-1].ob_state & SELECTED)
				area_redraw(msk.sx, msk.sy, msk.w, msk.h);
		}
	}while(k&2);
	graf_mouse(ARROW, NULL);
	actize_win_name();
}

void stick(int wid)
{
	_frame_data oframe=frame_data;
	
	CMY_COLOR dcol;
	int				rx,ry, rw, rh, stx, sty, kont_fill;
	uchar			c,m,y, *cc, *mm, *yy, *fbuf, *gbuf;
	int				mx, my, dum;
	long			ad;
	LAY_LIST	*ll=first_lay;
	LAYER			*lay;
	MASK			*mask;

	int mplumin=((U_OB*)(ospecial[STOLC]_UP_))->color.r[0];
	int yplumin=((U_OB*)(ospecial[STOLC]_UP_))->color.g[0];
	int cplumin=((U_OB*)(ospecial[STOLC]_UP_))->color.b[0];

	busy(ON);
	graf_mouse(BUSYBEE, NULL);

	/* Bei CTRL nur Kontur fÅllen, bei Shift richtig fÅllen aber
		 per Kontur-Algo  */
	kont_fill=0;
	if(Kbshift(-1) & 4)
		kont_fill=1;
	if(Kbshift(-1) & 3)
		kont_fill=-1;
	
	graf_mkstate(&mx, &my, &dum, &dum);
		
	wind_get(wid, WF_WORKXYWH, &stx, &sty, &dum, &dum);
	mx-=stx; 
	mx+=main_win.ox;
	mx=mx*MZOP;
	my-=sty;
	my-=(otoolbar[0].ob_height+OTBB);
	my+=main_win.oy;
	my=my*MZOP;
	
	/* Erste sichtbare Ebene finden */
	while(ll && (ll->this.visible==0)) ll=ll->next;

	if(!ll)
	{/* Keine Ebene ist sichtbar */
		Bell();
		return;
	}
		
	/* Ebenen Parameter */
	ad=(long)my*(long)ll->this.word_width+(long)mx;
	cc=(unsigned char*)ll->this.blue+ad;
	mm=(unsigned char*)ll->this.red+ad;
	yy=(unsigned char*)ll->this.yellow+ad;
	c=*cc; m=*mm; y=*yy;
	lay=&(ll->this);
	mask=NULL;

	fbuf=compare_buf(lay, mask, mx, my, c, m, y, cplumin,mplumin,yplumin, kont_fill, &rx, &ry, &rw, &rh, &gbuf);

	if(!fbuf)
	{
		graf_mouse(ARROW, NULL);
		busy(OFF);
		form_alert(1,"[3][FÅr diese Aktion steht nicht|genug Pufferspeicher zur|VerfÅgung!][Abbruch]");
		return;
	}

	actize_win_name();
	auto_reset(0);

	frame_data.x=rx; frame_data.y=ry;
	frame_data.w=rw; frame_data.h=rh;
	/* Maske in Undo */
	frame_to_undo(1);

	dcol.blue=255;
	dcol.red=255;
	dcol.yellow=255;
	dcol.grey=255;

	copy_buf_to_dest(gbuf, NULL, &(act_mask->this), &dcol, 0, NULL, 0, rx, ry, rw, rh); 

	frame_data=oframe;		
	free(fbuf);
	area_redraw(rx, ry, rw, rh);

	graf_mouse(ARROW, NULL);
	busy(OFF);
}

void fill(int wid)
{
	_frame_data oframe=frame_data;
	
	CMY_COLOR scol;
	int				rx,ry, rw, rh, stx, sty, tol_fill, kont_fill;
	uchar			c,m,y, *cc, *mm, *yy, *fbuf, *gbuf;
	int				mx, my, dum;
	long			ad;
	LAYER			*lay;
	MASK			*mask;

	int mplumin=((U_OB*)(ospecial[STOLC]_UP_))->color.r[0];
	int yplumin=((U_OB*)(ospecial[STOLC]_UP_))->color.g[0];
	int cplumin=((U_OB*)(ospecial[STOLC]_UP_))->color.b[0];

	busy(ON);
	graf_mouse(BUSYBEE, NULL);

	/* Bei ALT die Toleranz auf FÅllung Åbertragen */
	if(Kbshift(-1) & 8)
		tol_fill=1;
	else tol_fill=0;

	/* Bei CTRL nur Kontur fÅllen, bei Shift richtig FÅllen aber
	   per Kontur-Algo */
  kont_fill=0;
	if(Kbshift(-1) & 4)
		kont_fill=1;
	if(Kbshift(-1) & 3)
		kont_fill=-1;
	
	graf_mkstate(&mx, &my, &dum, &dum);
		
	wind_get(wid, WF_WORKXYWH, &stx, &sty, &dum, &dum);
	mx-=stx; 
	mx+=main_win.ox;
	mx=mx*MZOP;
	my-=sty;
	my-=(otoolbar[0].ob_height+OTBB);
	my+=main_win.oy;
	my=my*MZOP;
	
	ad=(long)my*(long)first_lay->this.word_width+(long)mx;

	if(otoolbar[MASK_ED-1].ob_state & SELECTED)
	{ /* Maske fÅllen */
		cc=mm=yy=(unsigned char*)act_mask->this.mask+ad;
		c=m=y=*cc;
		mask=&(act_mask->this);
		lay=NULL;
	}
	else
	{ /* Ebene fÅllen */
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

	fbuf=compare_buf(lay, mask, mx, my, c, m, y, cplumin,mplumin,yplumin, kont_fill, &rx, &ry, &rw, &rh, &gbuf);

	if(!fbuf)
	{
		graf_mouse(ARROW, NULL);
		busy(OFF);
		form_alert(1,"[3][FÅr diese Aktion steht nicht|genug Pufferspeicher zur|VerfÅgung!][Abbruch]");
		return;
	}

	actize_win_name();
	auto_reset(0);
	frame_data.x=rx; frame_data.y=ry;
	frame_data.w=rw; frame_data.h=rh;
	if(otoolbar[MASK_ED-1].ob_state & SELECTED)
	/* In Maske in Undo */
		frame_to_undo(1);
	else /* Ebene */
		frame_to_undo(0);

	copy_buf_to_dest(gbuf, lay, mask, &(pen.col), tol_fill, &scol, 1, rx, ry, rw, rh); 

	frame_data=oframe;		
	free(fbuf);
	area_redraw(rx, ry, rw, rh);

	graf_mouse(ARROW, NULL);
	busy(OFF);
}

uchar	*compare_buf(LAYER *lay, MASK *mask, int stx, int sty, int c, int m, int y, int c_tol, int m_tol, int y_tol, int nur_kontur, int *rx, int *ry, int *rw, int *rh, uchar **use_buf)
{
	/* Erstellt einen Maskenpuffer fÅr Ebene l oder Maske m
		 (gewÅnschte Eintragen, andere auf NULL)
		 ab Startpunkt stx/sty. Dabei wird ab diesem Punkt mit der
		 Farbe c,m,y verglichen und dabei die Toleranzen c_tol...
		 berÅcksichtigt.
		 Die Funktion liefert einen Zeiger auf den Puffer und in
		 x,y,w,h die Koordinaten, in denen relevante Pufferdaten
		 zu finden sind.
		 Der gelieferte Zeiger enstpricht der Anfangsadresse
		 (fÅr free()) und in use_buf wird auûerdem der Zeiger auf
		 die Position des Puffers geliefert, der der Plane-Koordinate
		 0,0 entspricht

		 nur_kontur: =0 normaler FÅll-Algo
		 						 =1 nur Kontur in den Puffer schreiben
		 						 =-1 normal FÅllen aber per Kontur-Algo
		 						 		 
		 Im Puffer steht an jeder Koordinate 0 oder 1 mit
		 0   :Farbe paût nicht
		 !=0 :Farbe entspricht Vorgaben
		 
		 Ist zu wenig Speicher frei, liefert die Funktion NULL
	*/
	
	long		ad, siz, line, off;
	int			x;
	uchar		*obuf;
	COM_BUF	cbuf;
	
	cbuf.rx=stx;
	cbuf.ry=sty;
	
	/* Adressen Åbertragen */

	ad=(long)first_lay->this.word_width*(long)sty+(long)stx;
	if(lay)
	{
		cbuf.c=(unsigned char*)(lay->blue)+ad;
		cbuf.m=(unsigned char*)(lay->red)+ad;
		cbuf.y=(unsigned char*)(lay->yellow)+ad;
	}
	else if(mask)
		cbuf.c=cbuf.m=cbuf.y=(unsigned char*)(mask->mask)+ad;
	else return(NULL);
	
	line=cbuf.line=first_lay->this.word_width;
	
	/* Farbgrenzen Åbertragen */
	if(c > c_tol) cbuf.cmin=c-c_tol;
	else cbuf.cmin=0;
	if(m > m_tol) cbuf.mmin=m-m_tol;
	else cbuf.mmin=0;
	if(y > y_tol) cbuf.ymin=y-y_tol;
	else cbuf.ymin=0;
	
	if(c < 255-c_tol) cbuf.cmax=c+c_tol;
	else cbuf.cmax=255;
	if(m < 255-m_tol) cbuf.mmax=m+m_tol;
	else cbuf.mmax=255;
	if(y < 255-y_tol) cbuf.ymax=y+y_tol;
	else cbuf.ymax=255;

	/* Pufferspeicher reservieren */
	/* Dabei zwei Zeilen mehr (oben und unten) fÅr speed_fill */
	
	siz=(long)(first_lay->this.height+2)*(long)first_lay->this.word_width;
	obuf=cbuf.obuf=(uchar*)calloc(siz,1);
	if(!cbuf.obuf) return(NULL);

	cbuf.start_buf=obuf+line;
		
	/* Startpunktadresse des Puffers eintragen */
	/* (eine Zeile mehr weil die erste als Rand benutzt wird) */
	cbuf.b=cbuf.obuf+(long)cbuf.line+ad;


	/* Falls nur_kontur oder per_kontur? */
	if(nur_kontur == 1)
		kontur_buf(&cbuf, 1);
	else if(nur_kontur == -1)
		kontur_buf(&cbuf, 0);
	else
	{/* Normal fÅllen */
		/* Rand (oben, rechts, unten) des Puffers fÅllen */
		/* oben */
		for(x=0; x < line; ++x)
			*obuf++=15;
	
		/* ganz Rechts (word_width)
			 damit nicht von links ums Eck gefÅllt wird
			 und rechts (width) damit nicht von rechts...*/
	
		obuf=cbuf.obuf+first_lay->this.width;
		off=line-first_lay->this.width-1;
		for(x=0; x < first_lay->this.height+2; ++x)
		{
			*obuf=1;
			obuf[off]=15;
			obuf+=line;
		}
		obuf-=line;
		obuf+=off;
	
		/* Und schlieûlich noch unten */
		for(x=0; x < line; ++x)
			*obuf--=15;

		fill_buf(&cbuf);
	}

	*rw=cbuf.rw; *rh=cbuf.rh;
	*rx=cbuf.rx; *ry=cbuf.ry;

	*use_buf=cbuf.start_buf;
	return(cbuf.obuf);
}

void kontur_buf(COM_BUF *cb, int nur_kontur)
{
	long	siz;
	register long hi, line;
	register int xc, yc, mx, flag;	
	register uchar	*b, *bo, *bu, *c, *m, *y;
	register uchar cmin,cmax,mmin,mmax,ymin,ymax;

	cmin=cb->cmin; cmax=cb->cmax;
	mmin=cb->mmin; mmax=cb->mmax;
	ymin=cb->ymin; ymax=cb->ymax;
	
	if((cmin==cmax) && (mmin==mmax) && (ymin==ymax))
	{
		kontur_buf_mono(cb, nur_kontur);
		return;
	}
	
	siz=(long)cb->line*(long)cb->ry+(long)cb->rx;
	
	c=cb->c-siz;
	m=cb->m-siz;
	y=cb->y-siz;
	b=cb->start_buf;

	kontur(cb);

	if(!nur_kontur)
	{
		line=cb->line;
		siz=(long)cb->ry*line;
		c+=siz;
		m+=siz;
		y+=siz;
		b+=siz;
		bo=b-line;
		bu=b+line;
		
		mx=cb->rx+cb->rw-1;
		hi=cb->rh;
	
		
		for(yc=0; yc < hi; ++yc)
		{
			flag=0;
			for(xc=cb->rx; xc < mx; ++xc)
			{
				if(b[xc])
				{
					/* Als Start oder Ende-Pixel akzeptieren? */
					/* Rechts darf keiner im Buffer gesetzt sein und
						 Farbe rechts davon muû stimmen, dann Start
						 sonst Ende */
					if(!(b[xc+1]))
					{
						if((c[xc+1]>=cmin) && (c[xc+1]<=cmax) &&
								(m[xc+1]>=mmin) && (m[xc+1]<=mmax) &&
						 		(y[xc+1]>=ymin) && (y[xc+1]<=ymax)
						 	)
						 	flag=1;
						 else
						 	flag=0;
					}
				}
				else 
				{
					if(((flag & 1) || (b[xc-1]||b[xc+1]||bo[xc]||bu[xc]))  &&
						(c[xc]>=cmin) && (c[xc]<=cmax) &&
						(m[xc]>=mmin) && (m[xc]<=mmax) &&
					 	(y[xc]>=ymin) && (y[xc]<=ymax)
					 	)				
						b[xc]=1;
				}
			}
			c+=line; m+=line; y+=line; b+=line; bo+=line; bu+=line;
		}
	}
}

void kontur_buf_mono(COM_BUF *cb, int nur_kontur)
{
	/* Wie norm-buf, aber die Farb Min/Max-werte sind gleich! */
	
	long	siz;
	register long hi, line;
	register int xc, yc, mx, flag;	
	register uchar	*b, *bo, *bu, *c, *m, *y;
	register uchar cmin, mmin, ymin;

	cmin=cb->cmin;
	mmin=cb->mmin;
	ymin=cb->ymin;
	
	siz=(long)cb->line*(long)cb->ry+(long)cb->rx;
	
	c=cb->c-siz;
	m=cb->m-siz;
	y=cb->y-siz;
	b=cb->start_buf;

	kontur_mono(cb);

	if(!nur_kontur)
	{
		line=cb->line;
		siz=(long)cb->ry*line;
		c+=siz;
		m+=siz;
		y+=siz;
		b+=siz;
		bo=b-line;
		bu=b+line;
		
		mx=cb->rx+cb->rw-1;
		hi=cb->rh;
	
		
		for(yc=0; yc < hi; ++yc)
		{
			flag=0;
			for(xc=cb->rx; xc < mx; ++xc)
			{
				if(b[xc])
				{
					/* Als Start oder Ende-Pixel akzeptieren? */
					/* Rechts darf keiner im Buffer gesetzt sein und
						 Farbe rechts davon muû stimmen, dann Start
						 sonst Ende */
					if(!(b[xc+1]))
					{
						if((c[xc+1]==cmin) &&
								(m[xc+1]==mmin) &&
						 		(y[xc+1]==ymin)
						 	)
						 	flag=1;
						 else
						 	flag=0;
					}
				}
				else 
				{
					if(((flag & 1) || (b[xc-1]||b[xc+1]||bo[xc]||bu[xc]))  &&
						(c[xc]==cmin) &&
						(m[xc]==mmin) &&
					 	(y[xc]==ymin)
					 	)				
						b[xc]=1;
				}
			}
			c+=line; m+=line; y+=line; b+=line; bo+=line; bu+=line;
		}
		}
}

void	kontur(COM_BUF *cb)
{
	long ad;
	uchar					 *buf;
	register uchar *l1, *l2, *l3, *b;
	register uchar	cmin,cmax,mmin,mmax,ymin,ymax;
	register int kind;
	register int line, x, y;
	int			sx,sy, max_w;
	int			dir, hi, minx, miny, maxx, maxy, maxx_y;
	
	/* direction: 1=rechts, 2=oben, 3=links, 4=unten */
	uchar new_dir[]=
	{
		0,0,0,2,	3,0,0,0,	2,2,0,3,	0,0,1,0,
		0,0,2,1,	1,0,3,0,	1,0,2,3,	0,4,0,0,
		0,2,0,4,	4,3,0,0,	4,2,0,3,	0,1,4,0,
		0,1,2,4,	4,1,3,0,	4,1,2,3,	0,0,0,0
	};

	hi=first_lay->this.height-1;
	line=cb->line;
	x=cb->rx; y=cb->ry;
	buf=cb->start_buf;
	max_w=first_lay->this.width;
	
	cmin=cb->cmin; cmax=cb->cmax;
	mmin=cb->mmin; mmax=cb->mmax;
	ymin=cb->ymin; ymax=cb->ymax;
	
	minx=maxx=x;
	miny=maxy=maxx_y=y;


	ad=(long)cb->ry*(long)cb->line+cb->rx;
	l1=cb->c-ad;
	l2=cb->m-ad;
	l3=cb->y-ad;
	ad=(long)maxx_y*line;
	b=buf+ad;
	l1+=ad;
	l2+=ad;
	l3+=ad;

	do
	{
	 /* NÑchsten Anschlag suchen... */
		while(((l1)[x]>=cmin) && ((l1)[x]<=cmax) &&
					((l2)[x]>=mmin) && ((l2)[x]<=mmax) &&
					((l3)[x]>=ymin) && ((l3)[x]<=ymax) &&
					(x < max_w)
					) ++x;
		--x;
		y=maxx_y;
		sx=x; sy=y;

		ad=(long)cb->ry*(long)cb->line+cb->rx;
		l1=cb->c-ad;
		l2=cb->m-ad;
		l3=cb->y-ad;
		
		ad=(long)y*(long)line;
		
		l1+=ad;
		l2+=ad;
		l3+=ad;
			
		b=buf+ad;
		
		/* Ersten Wert bestimmen */
		kind=0;
		if(	(y > 0) &&
				((l1-line)[x]>=cmin) && ((l1-line)[x]<=cmax) &&
				((l2-line)[x]>=mmin) && ((l2-line)[x]<=mmax) &&
				((l3-line)[x]>=ymin) && ((l3-line)[x]<=ymax)
			)
			kind+=1;
		if(	(y < hi) &&
				((l1+line)[x]>=cmin) && ((l1+line)[x]<=cmax) &&
				((l2+line)[x]>=mmin) && ((l2+line)[x]<=mmax) &&
				((l3+line)[x]>=ymin) && ((l3+line)[x]<=ymax)
			)
			kind+=8;
		if(	(x > 0) &&
				((l1)[x-1]>=cmin) && ((l1)[x-1]<=cmax) &&
				((l2)[x-1]>=mmin) && ((l2)[x-1]<=mmax) &&
				((l3)[x-1]>=ymin) && ((l3)[x-1]<=ymax)
			)
			kind+=2;
		if( (x < max_w-1) &&
				((l1)[x+1]>=cmin) && ((l1)[x+1]<=cmax) &&
				((l2)[x+1]>=mmin) && ((l2)[x+1]<=mmax) &&
				((l3)[x+1]>=ymin) && ((l3)[x+1]<=ymax)
			)
			kind+=4;
			
		if((kind==11) || (kind==10))
			dir=2;
		else
			dir=1;
		
		do
		{	
			if(x > maxx) {maxx=x; maxx_y=y;}
			if(x < minx) minx=x;
			if(y < miny) miny=y;
			if(y > maxy) maxy=y;
			b[x]=1;

			kind=0;
			if(	(y > 0) &&
					((l1-line)[x]>=cmin) && ((l1-line)[x]<=cmax) &&
					((l2-line)[x]>=mmin) && ((l2-line)[x]<=mmax) &&
					((l3-line)[x]>=ymin) && ((l3-line)[x]<=ymax)
				)
				kind+=1;
			if(	(y < hi) &&
					((l1+line)[x]>=cmin) && ((l1+line)[x]<=cmax) &&
					((l2+line)[x]>=mmin) && ((l2+line)[x]<=mmax) &&
					((l3+line)[x]>=ymin) && ((l3+line)[x]<=ymax)
				)
				kind+=8;
			if(	(x > 0) &&
					((l1)[x-1]>=cmin) && ((l1)[x-1]<=cmax) &&
					((l2)[x-1]>=mmin) && ((l2)[x-1]<=mmax) &&
					((l3)[x-1]>=ymin) && ((l3)[x-1]<=ymax)
				)
				kind+=2;
			if( (x < max_w-1) &&
					((l1)[x+1]>=cmin) && ((l1)[x+1]<=cmax) &&
					((l2)[x+1]>=mmin) && ((l2)[x+1]<=mmax) &&
					((l3)[x+1]>=ymin) && ((l3)[x+1]<=ymax)
				)
				kind+=4;
	
			dir=new_dir[(kind-1)*4+dir-1];
			switch(dir)
			{
				case 1:
					++x;
				break;
				case 2:
					--y;
					l1-=line; l2-=line; l3-=line; b-=line;
				break;
				case 3:
					--x;
				break;
				case 4:
					++y;
					l1+=line; l2+=line; l3+=line; b+=line;
				break;
			}
		}
		while((x != sx) || (y != sy));
		
		ad=(long)cb->ry*(long)cb->line+cb->rx;
		l1=cb->c-ad;
		l2=cb->m-ad;
		l3=cb->y-ad;
		ad=(long)maxx_y*line;
		b=buf+ad;
		l1+=ad;
		l2+=ad;
		l3+=ad;
			
		x=maxx+1;
	}while(	(x < max_w) &&
			((l1)[x]>=cmin) && ((l1)[x]<=cmax) &&
			((l2)[x]>=mmin) && ((l2)[x]<=mmax) &&
			((l3)[x]>=ymin) && ((l3)[x]<=ymax)
			);
			
	cb->rx=minx;
	cb->ry=miny;
	cb->rw=maxx-minx+1;
	cb->rh=maxy-miny+1;

}

void	kontur_mono(COM_BUF *cb)
{
	/* Wie kontur, aber alle Farb Min/Max-Werte sind gleich! */
	
	long ad;
	uchar					 *buf;
	register uchar *l1, *l2, *l3, *b;
	register uchar	cmin,mmin,ymin;
	register int kind;
	register int line, x, y;
	int			sx,sy, max_w;
	int			dir, hi, minx, miny, maxx, maxy, maxx_y;
	
	/* direction: 1=rechts, 2=oben, 3=links, 4=unten */
	uchar new_dir[]=
	{
		0,0,0,2,	3,0,0,0,	2,2,0,3,	0,0,1,0,
		0,0,2,1,	1,0,3,0,	1,0,2,3,	0,4,0,0,
		0,2,0,4,	4,3,0,0,	4,2,0,3,	0,1,4,0,
		0,1,2,4,	4,1,3,0,	4,1,2,3,	0,0,0,0
	};

	hi=first_lay->this.height-1;
	line=cb->line;
	x=cb->rx; y=cb->ry;
	buf=cb->start_buf;
	max_w=first_lay->this.width;
	
	cmin=cb->cmin;
	mmin=cb->mmin;
	ymin=cb->ymin;
	
	minx=maxx=x;
	miny=maxy=maxx_y=y;


	ad=(long)cb->ry*(long)cb->line+cb->rx;
	l1=cb->c-ad;
	l2=cb->m-ad;
	l3=cb->y-ad;
	ad=(long)maxx_y*line;
	b=buf+ad;
	l1+=ad;
	l2+=ad;
	l3+=ad;

	do
	{
	 /* NÑchsten Anschlag suchen... */
		while(((l1)[x]==cmin) &&
					((l2)[x]==mmin) &&
					((l3)[x]==ymin) &&
					(x < max_w)
					) ++x;
		--x;
		y=maxx_y;
		sx=x; sy=y;

		ad=(long)cb->ry*(long)cb->line+cb->rx;
		l1=cb->c-ad;
		l2=cb->m-ad;
		l3=cb->y-ad;
		
		ad=(long)y*(long)line;
		
		l1+=ad;
		l2+=ad;
		l3+=ad;
			
		b=buf+ad;
		
		/* Ersten Wert bestimmen */
		kind=0;
		if(	(y > 0) &&
				((l1-line)[x]==cmin) &&
				((l2-line)[x]==mmin) &&
				((l3-line)[x]==ymin)
			)
			kind+=1;
		if(	(y < hi) &&
				((l1+line)[x]==cmin) &&
				((l2+line)[x]==mmin) &&
				((l3+line)[x]==ymin)
			)
			kind+=8;
		if(	(x > 0) &&
				((l1)[x-1]==cmin) &&
				((l2)[x-1]==mmin) &&
				((l3)[x-1]==ymin)
			)
			kind+=2;
		if( (x < max_w-1) &&
				((l1)[x+1]==cmin) &&
				((l2)[x+1]==mmin) &&
				((l3)[x+1]==ymin)
			)
			kind+=4;
			
		if((kind==11) || (kind==10))
			dir=2;
		else
			dir=1;
		
		do
		{	
			if(x > maxx) {maxx=x; maxx_y=y;}
			if(x < minx) minx=x;
			if(y < miny) miny=y;
			if(y > maxy) maxy=y;
			b[x]=1;

			kind=0;
			if(	(y > 0) &&
					((l1-line)[x]==cmin) &&
					((l2-line)[x]==mmin) &&
					((l3-line)[x]==ymin)
				)
				kind+=1;
			if(	(y < hi) &&
					((l1+line)[x]==cmin) &&
					((l2+line)[x]==mmin) &&
					((l3+line)[x]==ymin)
				)
				kind+=8;
			if(	(x > 0) &&
					((l1)[x-1]==cmin) &&
					((l2)[x-1]==mmin) &&
					((l3)[x-1]==ymin)
				)
				kind+=2;
			if( (x < max_w-1) &&
					((l1)[x+1]==cmin) &&
					((l2)[x+1]==mmin) &&
					((l3)[x+1]==ymin)
				)
				kind+=4;
	
			dir=new_dir[(kind-1)*4+dir-1];
			switch(dir)
			{
				case 1:
					++x;
				break;
				case 2:
					--y;
					l1-=line; l2-=line; l3-=line; b-=line;
				break;
				case 3:
					--x;
				break;
				case 4:
					++y;
					l1+=line; l2+=line; l3+=line; b+=line;
				break;
			}
		}
		while((x != sx) || (y != sy));
		
		ad=(long)cb->ry*(long)cb->line+cb->rx;
		l1=cb->c-ad;
		l2=cb->m-ad;
		l3=cb->y-ad;
		ad=(long)maxx_y*line;
		b=buf+ad;
		l1+=ad;
		l2+=ad;
		l3+=ad;
			
		x=maxx+1;
	}while(	(x < max_w) &&
			((l1)[x]==cmin) && 
			((l2)[x]==mmin) &&
			((l3)[x]==ymin)
			);
			
	cb->rx=minx;
	cb->ry=miny;
	cb->rw=maxx-minx+1;
	cb->rh=maxy-miny+1;

}

void fill_buf(COM_BUF *cbuf)
{
	if_debug=(uchar*)Physbase()+(long)cbuf->ry*(long)sw+cbuf->rx;
	if_debug2=sw;
	
	if_buf=cbuf->b;
	if_cc=cbuf->c;
	if_mm=cbuf->m;
	if_yy=cbuf->y;
	
	if_cmin=cbuf->cmin;
	if_cmax=cbuf->cmax;
	if_mmin=cbuf->mmin;
	if_mmax=cbuf->mmax;
	if_ymin=cbuf->ymin;
	if_ymax=cbuf->ymax;

	if_line=cbuf->line;
	if_mline=-(cbuf->line);
	
	if_x=cbuf->rx;
	if_y=cbuf->ry;
	
	as_iter_fill();
	
	cbuf->rx=if_minx;
	cbuf->ry=if_miny;
	cbuf->rw=if_maxx-if_minx+1;
	cbuf->rh=if_maxy-if_miny+1;
}

void copy_lay_to_dest(uchar *buf, LAYER *lay, MASK *mask, int use_mask, int rx, int ry, int rw, int rh)
{
	/*
		buf=Bufferadresse. EnthÑlt 1 und 0, fÅr jede 1 wird in die
			 Zielebene der Quellpixel aus source_lay Åbertragen

		use_mask: 0=Maske ignorieren, 1=Maske beachten, falls aktiviert
							(nur beim Kopieren in Ebenen)		 

		 x,y,w,h: Zu beachtender Bereich
	*/
	register uchar *mm;
	register int c_x, c_y;
	register long	ad, ldif;
	COPY_DSCR cd;
	LAYER *source_col=find_layer_id(pen.source_lay_id);
	
	ad=(long)first_lay->this.word_width*(long)ry+(long)rx;
	ldif=first_lay->this.word_width-rw;
		
	/* Erstmal Buffer zu Maske umfunktionieren, d.h. 0=255, 1=0 */
	mm=buf+ad;
	for(c_y=rh; c_y > 0; --c_y)
	{
		for(c_x=rw; c_x > 0; --c_x)
		{
			if(*mm)
				*mm++=0;
			else
				*mm++=255;
		}
		mm+=ldif;
	}

	/* Falls Maskierung gewÅnscht, Masken addieren */
	if(lay && use_mask && (otoolbar[MASK_ON-1].ob_state & SELECTED))
		add_masks(buf+ad, (uchar*)act_mask->this.mask+ad, buf+ad, ldif, ldif, ldif, rw, rh);

	/* COPY-Descriptor fÅllen */
	cd.sc=(uchar*)source_col->blue+ad;
	cd.sm=(uchar*)source_col->red+ad;
	cd.sy=(uchar*)source_col->yellow+ad;
	cd.dw=rw; cd.dh=rh;
	cd.sldif=cd.dldif=cd.mldif=ldif;
	cd.mode=1;
	cd.mask=buf+ad;
		
	if(lay)
	{ /* Ebene fÅllen */
		cd.dc=(uchar*)lay->blue+ad;
		cd.dm=(uchar*)lay->red+ad;
		cd.dy=(uchar*)lay->yellow+ad;
	}
	else
	{
		cd.dc=(unsigned char*)mask->mask+ad;
		cd.dm=cd.dy=NULL;
	}
	vary_copy(&cd);
}

void copy_buf_to_dest(uchar *buf, LAYER *lay, MASK *mask, CMY_COLOR *col, int tol, CMY_COLOR *scol, int use_mask, int rx, int ry, int rw, int rh)
{
	/*
		buf=Bufferadresse. EnthÑlt 1 und 0, fÅr jede 1 wird in die
			 Zielebene die Farbe col eingetragen, oder, falls als
			 Quellfarbe eine Ebene gesetzt ist, die Quellpixel Åbertragen.
		l,m: GewÅnschtes Ziel eintragen, andere uf NULL setzen
		tol: Bei Toleranzabweichungen diese Abweichung auch auf 
		     Zielfarbe anwenden.
		     DafÅr notwendig:
		 scol: Quellfarbe

		use_mask: 0=Maske ignorieren, 1=Maske beachten, falls aktiviert
							(nur beim Kopieren in Ebenen)		 

		 x,y,w,h: Zu beachtender Bereich
	*/
	
	register uchar *cc, *mm, *yy, *bb, *ms;
	register uchar c, m, y, mv;
	register int c_x, c_y, new_c, new_m, new_y, sc, sm, sy;
	register long	ad;
	register unsigned char *d_tab;
 	register unsigned int	*m_tab1, *m_tab2, z1, z2, z3;
 	register unsigned int	**m_tabs;
 	m_tabs=mul_adr;
 	d_tab=div_tab;

	if(pen.source_lay_id > -1) /* Quelle ist nicht Farbe sondern Ebene */
	{
		copy_lay_to_dest(buf, lay, mask, use_mask, rx, ry, rw, rh);
		return;
	}


	if(scol)
	{	
		sc=scol->blue;
		sm=scol->red;
		sy=scol->yellow;
	}

	ad=(long)first_lay->this.word_width*(long)ry+(long)rx;
	
	if(lay)
	{ /* Ebene fÅllen */
		cc=(uchar*)lay->blue+ad;
		mm=(uchar*)lay->red+ad;
		yy=(uchar*)lay->yellow+ad;
		if(use_mask && (otoolbar[MASK_ON-1].ob_state & SELECTED))
			ms=(uchar*)act_mask->this.mask+ad;
		else
			ms=NULL;
	}
	else	
		cc=(unsigned char*)mask->mask+ad;
	
	bb=buf+ad;
	

	set_grey(col);
	
	ad=first_lay->this.word_width;	

	if(mask)
	{/* In Maske schreiben */
		c=col->grey; 
		if(tol)
		{/* Mit Toleranzanpassung */
			set_grey(scol);
			sc=scol->grey;
			for(c_y=0; c_y < rh; ++c_y)
			{
				for(c_x=0; c_x < rw; ++c_x)
				{
					if(bb[c_x])
					{
						new_c=(int)c+(int)cc[c_x]-sc;
						if(new_c > 255) new_c=255;
						if(new_c < 0) new_c=0;
						cc[c_x]=(uchar)new_c;
					}
				}
				bb+=ad;
				cc+=ad;
			}
		}
		else
		{/* Ohne Toleranz */
			for(c_y=0; c_y < rh; ++c_y)
			{
				for(c_x=0; c_x < rw; ++c_x)
				{
					if(bb[c_x])
					{
						cc[c_x]=c;
					}
				}
				bb+=ad;
				cc+=ad;
			}
		}
	}

	else

	{ /* In Ebene */
		c=col->blue;
		m=col->red;
		y=col->yellow;

		if(ms)
		{/* Maske beachten */
			if(tol)
			{/* Mit Toleranzanpassung kopieren */
				for(c_y=0; c_y < rh; ++c_y)
				{
					for(c_x=0; c_x < rw; ++c_x)
					{
						if(bb[c_x])
						{
							new_c=(int)c+(int)cc[c_x]-sc;
							if(new_c > 255) new_c=255;
							if(new_c < 0) new_c=0;
							new_m=(int)m+(int)mm[c_x]-sm;
							if(new_m > 255) new_m=255;
							if(new_m < 0) new_m=0;
							new_y=(int)y+(int)yy[c_x]-sy;
							if(new_y > 255) new_y=255;
							if(new_y < 0) new_y=0;

							mv=ms[c_x];
							m_tab1=m_tabs[mv]; m_tab2=m_tabs[255-mv];
							z1=m_tab1[new_c]; z2=m_tab1[new_m]; z3=m_tab1[new_y];
							z1+=m_tab2[cc[c_x]]; z2+=m_tab2[mm[c_x]]; z3+=m_tab2[yy[c_x]];
							cc[c_x]=d_tab[z1];
							mm[c_x]=d_tab[z2];
							yy[c_x]=d_tab[z3];
						}
					}
					bb+=ad;
					cc+=ad;
					mm+=ad;
					yy+=ad;
					ms+=ad;
				}
			}
			else
			{/* Ohne Anpassung */
				for(c_y=0; c_y < rh; ++c_y)
				{
					for(c_x=0; c_x < rw; ++c_x)
					{
						if(bb[c_x])
						{
							mv=ms[c_x];
							m_tab1=m_tabs[mv]; m_tab2=m_tabs[255-mv];
							z1=m_tab1[c]; z2=m_tab1[m]; z3=m_tab1[y];
							z1+=m_tab2[cc[c_x]]; z2+=m_tab2[mm[c_x]]; z3+=m_tab2[yy[c_x]];

							cc[c_x]=d_tab[z1];
							mm[c_x]=d_tab[z2];
							yy[c_x]=d_tab[z3];
						}
					}
					bb+=ad;
					cc+=ad;
					mm+=ad;
					yy+=ad;
					ms+=ad;
				}
			}
		}
		else	
		{/* Maske nicht beachten */
			if(tol)
			{/* Mit Toleranzanpassung kopieren */
				for(c_y=0; c_y < rh; ++c_y)
				{
					for(c_x=0; c_x < rw; ++c_x)
					{
						if(bb[c_x])
						{
							new_c=(int)c+(int)cc[c_x]-sc;
							if(new_c > 255) new_c=255;
							if(new_c < 0) new_c=0;
							cc[c_x]=(uchar)new_c;

							new_c=(int)m+(int)mm[c_x]-sm;
							if(new_c > 255) new_c=255;
							if(new_c < 0) new_c=0;
							mm[c_x]=(uchar)new_c;

							new_c=(int)y+(int)yy[c_x]-sy;
							if(new_c > 255) new_c=255;
							if(new_c < 0) new_c=0;
							yy[c_x]=(uchar)new_c;
						}
					}
					bb+=ad;
					cc+=ad;
					mm+=ad;
					yy+=ad;
				}
			}
			else
			{/* Ohne Anpassung */
				for(c_y=0; c_y < rh; ++c_y)
				{
					for(c_x=0; c_x < rw; ++c_x)
					{
						if(bb[c_x])
						{
							cc[c_x]=c;
							mm[c_x]=m;
							yy[c_x]=y;
						}
					}
					bb+=ad;
					cc+=ad;
					mm+=ad;
					yy+=ad;
				}
			}
		}
		
	}
}
