void line_fill(COM_BUF *cb, int px, int py, uchar *cp, uchar *mp, uchar *yp, uchar *bp, int *rx, int *ry, int *rw, int *rh)
{

	register uchar *bline1, *bline2;
	register uchar *cline1, *mline1, *yline1;
	register uchar	cmin,cmax,mmin,mmax,ymin,ymax;
	register int x;
	int		sx,ex,sy,ey;
	int		set, maxhi;
	long	offset;
	
	maxhi=first_lay->this.height;
	
	cmin=cb->cmin; cmax=cb->cmax;
	mmin=cb->mmin; mmax=cb->mmax;
	ymin=cb->ymin; ymax=cb->ymax;
	
	offset=(long)py*(long)first_lay->this.word_width;
	
	bline1=bp+offset;
	cline1=cp+offset;
	mline1=mp+offset;
	yline1=yp+offset;
	
	/* Breite bestimmen */
	/* nach links */
	sx=px;
	while( sx && (!bline1[sx]) &&
				(cline1[sx]>=cmin) && (cline1[sx]<=cmax) &&
				(mline1[sx]>=mmin) && (mline1[sx]<=mmax) &&
				(yline1[sx]>=ymin) && (yline1[sx]<=ymax)
				)
				bline1[sx--]=1;
	/* nach rechts */
	ex=px;
	while((ex < cb->line) && (!bline1[ex]) &&
				(cline1[ex]>=cmin) && (cline1[ex]<=cmax) &&
				(mline1[ex]>=mmin) && (mline1[ex]<=mmax) &&
			 	(yline1[ex]>=ymin) && (yline1[ex]<=ymax)
				)
				bline1[ex++]=1;

	
	/* Nach oben Zeilenweise scannen */
	sy=py;
	set=1;
	while(sy && set)
	{
		--sy;
		bline2=bline1-cb->line;
		cline1-=cb->line;
		mline1-=cb->line;
		yline1-=cb->line;
		set=0;
		for(x=sx; x<=ex; ++x)
		{
			if((!bline2[x]) && bline1[x] &&
				(cline1[x]>=cmin) && (cline1[x]<=cmax) &&
				(mline1[x]>=mmin) && (mline1[x]<=mmax) &&
			 	(yline1[x]>=ymin) && (yline1[x]<=ymax)
				)
				{bline2[x]=1; set=1;}
		}
		bline1=bline2;
	}
	if(!set) ++sy;

	/* Nach unten Zeilenweise scannen */
	ey=py;
	set=1;
	bline1=bp+offset;
	cline1=cp+offset;
	mline1=mp+offset;
	yline1=yp+offset;
	while((ey<maxhi) && set)
	{
		++ey;
		bline2=bline1+cb->line;
		cline1+=cb->line;
		mline1+=cb->line;
		yline1+=cb->line;
		set=0;
		for(x=sx; x<=ex; ++x)
		{
			if((!bline2[x]) && bline1[x] &&
				(cline1[x]>=cmin) && (cline1[x]<=cmax) &&
				(mline1[x]>=mmin) && (mline1[x]<=mmax) &&
			 	(yline1[x]>=ymin) && (yline1[x]<=ymax)
				)
				{bline2[x]=1; set=1;}
		}
		bline1=bline2;
	}
	if(!set) --ey;
	
	*rx=sx; *rw=ex-sx;
	*ry=sy; *rh=ey-sy;
}

void norm_buf(COM_BUF *cb)
{
	int	x,y,w,h;
	int	ax,ay,aw,ah;
	long	line, linecount, sub;
	
	uchar *cp, *mp, *yp, *bp;
	register uchar	*cline, *mline, *yline, *bline;
	register uchar cmin,cmax,mmin,mmax,ymin,ymax;
	register int px,pw;
	int		py, ph;
	long	*offsets;

	cmin=cb->cmin; cmax=cb->cmax;
	mmin=cb->mmin; mmax=cb->mmax;
	ymin=cb->ymin; ymax=cb->ymax;
	
	ax=cb->rx; ay=cb->ry;
	aw=1; ah=1;
	
	/* Array mit Direktoffsets fÅr Zeilen einrichten */
	line=cb->line;
	offsets=(long*)malloc((long)first_lay->this.height*sizeof(long));
	for(linecount=0, y=0; y < first_lay->this.height; ++y)
	{
		offsets[y]=linecount;
		linecount+=line;
	}

	/* Ursprungsadressen der Planes bestimmen */
	sub=offsets[cb->ry]+cb->rx;
	cp=cb->c-sub;
	mp=cb->m-sub;
	yp=cb->y-sub;
	bp=cb->b-sub;
	
	px=cb->rx; py=cb->ry;
	
_line_fill:
	line_fill(cb, px,py,cp,mp,yp,bp,&x,&y,&w,&h);
	/* Aus RÅckgabekoordinaten grîûtes Rechteck bilden */
	if(ax+aw < x+w) aw=x+w-ax;
	if(ax > x)
	{aw+=ax-x; ax=x;}
	if(ay+ah < y+h) ah=y+h-ay;
	if(ay > y)
	{ah+=ay-y; ay=y;}
	
	ph=ah;
	py=ay;
	cline=cp+offsets[py];
	mline=mp+offsets[py];
	yline=yp+offsets[py];
	bline=bp+offsets[py];

_scan_buf_y:
	/* Puffer scannen */
	px=ax;
	pw=aw;
	if(px) {--px; ++pw;}
	if(pw < line) ++pw;
	
_scan_buf_x:
	if( (!bline[px]) && (bline[px-1] || bline[px+1])
		&&(cline[px]>=cmin)&&(cline[px]<=cmax)
		&&(mline[px]>=mmin)&&(mline[px]<=mmax)
		&&(yline[px]>=ymin)&&(yline[px]<=ymax)
		)
			goto _line_fill;
	
	++px;
	if(pw--)
		goto _scan_buf_x;
	/* end x-loop */
			
	++py;
	cline+=line;
	mline+=line;
	yline+=line;
	bline+=line;
	if(ph--)
		goto _scan_buf_y;
	/*end y-loop */
	
	free(offsets);
	
	cb->rx=ax; cb->ry=ay;
	cb->rw=aw; cb->rh=ah;
}

void o_norm_buf(COM_BUF *cb)
{

	uchar is_o, is_u, is_l, is_r, w_o, w_u, w_r, w_l;
	int w, h, x;
	int stx, sty;
	int	mx,my,mw,mh;
	long add, y;
	uchar *sc, *sm, *sy, *sb, set_it;
	register uchar	*tc, *tm, *ty, *tb, *ttb, *ttc;
	register uchar cmin,cmax,mmin,mmax,ymin,ymax;
	

	add=(long)(cb->ry)*(long)(cb->line)+cb->rx;
	sc=cb->c-add;
	sm=cb->m-add;
	sy=cb->y-add;
	sb=cb->b-add;
	*(cb->b)=1;
	
	mx=cb->rx;
	my=cb->ry;
	mw=mh=1;
	
	cmin=cb->cmin;
	cmax=cb->cmax;
	mmin=cb->mmin;
	mmax=cb->mmax;
	ymin=cb->ymin;
	ymax=cb->ymax;
	
		

	do
	{
		stx=cb->rx;
		sty=cb->ry;
		w=1;
		h=1;
		set_it=0;

		is_o=is_u=is_r=is_l=1;
	
		do
		{
			w_o=is_o; w_u=is_u; w_l=is_l; w_r=is_r;
			
			is_o=is_u=is_l=is_r=0;
			
			if(w_l)
			{	--stx; ++w;}
			if(w_o)
			{ --sty; ++h;}
			if(w_r)
				++w;
			if(w_u)
				++h;
			
			if(stx < 0) stx=0;
			if(stx+w > cb->line) w=cb->line-stx;
			if(sty < 0) sty=0;
			if(sty+h > first_lay->this.height) h=first_lay->this.height-sty;
			
			/* Obere Zeile*/
			add=(long)sty*(long)cb->line+(long)stx;
			tc=sc+add;
			tm=sm+add;
			ty=sy+add;
			tb=sb+add;
			ttb=tb+cb->line;
			ttc=tb-cb->line;
			if(w_o)
			{
				/*von links nach rechts */
				for(x=0; x < w; ++x)
				{
					if((!tb[x])
					&&(ttb[x] || tb[x+1] || tb[x-1] || ttc[x])
					&&(tc[x] >= cmin)
					&&(tc[x] <= cmax)
					&&(tm[x] >= mmin)
					&&(tm[x] <= mmax)
					&&(ty[x] >= ymin)
					&&(ty[x] <= ymax))
					{
						is_o=set_it=1;
						tb[x]=1;
					}
				}
				/*von rechts nach links */
				for(x=w-1; x >=0 ; ++x)
				{
					if((!tb[x])
					&&(ttb[x] || tb[x+1] || tb[x-1] || ttc[x])
					&&(tc[x] >= cmin)
					&&(tc[x] <= cmax)
					&&(tm[x] >= mmin)
					&&(tm[x] <= mmax)
					&&(ty[x] >= ymin)
					&&(ty[x] <= ymax))
					{
						is_o=set_it=1;
						tb[x]=1;
					}
				}
			}

			/* Untere Zeile */
			add=(long)(sty+h-1)*(long)(cb->line)+(long)stx;
			tc=sc+add;
			tm=sm+add;
			ty=sy+add;
			tb=sb+add;
			ttb=tb-cb->line;
			ttc=tb+cb->line;
			if(w_u) 
			{ /* von links nach rechts */
				for(x=0; x < w; ++x)
				{
					if((!tb[x])
					&&(ttb[x] || tb[x-1] || tb[x+1] || ttc[x])
					&&(tc[x] >= cmin)
					&&(tc[x] <= cmax)
					&&(tm[x] >= mmin)
					&&(tm[x] <= mmax)
					&&(ty[x] >= ymin)
					&&(ty[x] <= ymax))
					{
						is_u=set_it=1;
						tb[x]=1;
					}
				}
				/*von rechts nach links */
				for(x=w-1; x >=0; ++x)
				{
					if((!tb[x])
					&&(ttb[x] || tb[x-1] || tb[x+1] || ttc[x])
					&&(tc[x] >= cmin)
					&&(tc[x] <= cmax)
					&&(tm[x] >= mmin)
					&&(tm[x] <= mmax)
					&&(ty[x] >= ymin)
					&&(ty[x] <= ymax))
					{
						is_u=set_it=1;
						tb[x]=1;
					}
				}
			}
			
			/* Linke Spalte */
			add=(long)sty*(long)cb->line+(long)stx;
			tc=sc+add;
			tm=sm+add;
			ty=sy+add;
			tb=sb+add;
			ttb=tb-add;
			ttc=tb+add;
			y=0;
			if(w_l) for(x=0; x < h; ++x)
			{
				if((!tb[y])
				&&(ttb[y] || tb[y+1] || tb[y-1] || ttc[y])
				&&(tc[y] >= cmin)
				&&(tc[y] <= cmax)
				&&(tm[y] >= mmin)
				&&(tm[y] <= mmax)
				&&(ty[y] >= ymin)
				&&(ty[y] <= ymax))
				{
					is_l=set_it=1;
					tb[y]=1;
				}
				y+=(long)cb->line;
			}
			
			/* Rechte Spalte */
			add=(long)sty*(long)cb->line+(long)stx;
			tc=sc+add+w-1;
			tm=sm+add+w-1;
			ty=sy+add+w-1;
			tb=sb+add+w-1;
			ttb=tb-add;
			ttc=tb+add;
			y=0;
			if(w_r) for(x=0; x < h; ++x)
			{
				if((!tb[y])
				&&(ttb[y] || tb[y-1] || tb[y+1] || ttc[y])
				&&(tc[y] >= cmin)
				&&(tc[y] <= cmax)
				&&(tm[y] >= mmin)
				&&(tm[y] <= mmax)
				&&(ty[y] >= ymin)
				&&(ty[y] <= ymax))
				{
					is_r=set_it=1;
					tb[y]=1;
				}
				y+=(long)cb->line;
			}
		}while(is_o || is_u || is_l || is_r);

		if(stx+w > mx+mw) mw=stx+w-mx;
		if(sty+h > my+mh) mh=sty+h-my;
		if(stx < mx)
		{ mw+=(mx-stx); mx=stx;}
		if(sty < my)
		{ mh+=(my-sty); my=sty;}
	
	}while(set_it);
		
	
	cb->rx=mx;
	cb->ry=my;
	cb->rw=mw; cb->rh=mh;
}

/*
void	o_kontur(uchar *buf, int sx, int sy, int l)
{
	/* direction: 1=rechts, 2=oben, 3=links, 4=unten */
	long ad;
	/*uchar		 new_dir[16][4];*/
	register uchar *l1, *l2, *l3;
	register int kind, dir, minx, miny, maxx, maxy;
	register int line=l, x=sx, y=sy;
	int			 minx_y, maxx_y, miny_x, maxy_x;
	
	uchar new_dir[]=
	{
		0,0,0,2,	3,0,0,0,	2,2,0,3,	0,0,1,0,
		0,0,2,1,	1,0,3,0,	1,0,2,3,	0,4,0,0,
		0,2,0,4,	4,3,0,0,	4,2,0,3,	0,1,4,0,
		0,1,2,4,	4,1,3,0,	4,1,2,3,	0,0,0,0
	};
	
	minx=maxx=x;
	miny=maxy=y;


_kontur:
	ad=(long)y*(long)line;
	
	l1=buf+ad-line;
	l2=buf+ad;
	l3=buf+ad+line;

	/* Ersten Wert bestimmen */
	kind=l1[x]+(l2[x-1]<<1)+(l2[x+1]<<2)+(l3[x]<<3);
	if((kind==11) || (kind==10))
		dir=2;
	else
		dir=1;
	
	do
	{	
		if(x < minx) {minx=x; minx_y=y;}
		if(x > maxx) {maxx=x; maxx_y=y;}
		if(y < miny) {miny=y; miny_x=x;}
		if(y > maxy) {maxy=y; maxy_x=x;}
		l2[x]=1;
		kind=l1[x]+(l2[x-1]<<1)+(l2[x+1]<<2)+(l3[x]<<3);
set(x,y);
		dir=new_dir[(kind-1)*4+dir-1];
		switch(dir)
		{
			case 1:
				++x;
			break;
			case 2:
				--y;
				l1-=line; l2-=line; l3-=line;
			break;
			case 3:
				--x;
			break;
			case 4:
				++y;
				l1+=line; l2+=line; l3+=line;
			break;
		}
	}
	while((x != sx) || (y != sy));
	
	ad=(long)maxx_y*line;
	l2=buf+ad;
	x=maxx+1;
	if(l2[x])
	{/* Das war noch nicht die Ñuûerste Grenze, weil rechts von 
			maxx die Farbe ok ist */
	 /* NÑchsten Anschlag suchen... */
		while(l2[x] && x < line) ++x;
		--x;
		y=maxx_y;
		sx=x; sy=y;
		goto _kontur;	
	}
}

int o_norm_buf(COM_BUF *cb)
{
	/* speed_fill in einzelnen Schritten aufrufen 
		 Dabei Hîhe immer durch 3 teilen 
		 Return:
		 1=ok
		 0=kein Speicher
	*/
	
	long	siz;
	register long hi, line;
	register int x, yc, mx;	
	register uchar	*b, *c, *m, *y;
	register uchar cmin,cmax,mmin,mmax,ymin,ymax;

	cmin=cb->cmin; cmax=cb->cmax;
	mmin=cb->mmin; mmax=cb->mmax;
	ymin=cb->ymin; ymax=cb->ymax;
	
	siz=(long)cb->line*(long)cb->ry+(long)cb->rx;
	
	c=cb->c-siz;
	m=cb->m-siz;
	y=cb->y-siz;
	b=cb->start_buf;
	
	mx=first_lay->this.width;
	line=cb->line;
	hi=first_lay->this.height;

	for(yc=0; yc < hi; ++yc)
	{
		for(x=0; x < mx; ++x)
		{
			if(	(c[x]>=cmin) && (c[x]<=cmax) &&
					(m[x]>=mmin) && (m[x]<=mmax) &&
				 	(y[x]>=ymin) && (y[x]<=ymax)
				)
				b[x]=1;
		}
		c+=line; m+=line; y+=line; b+=line;
	}

	/* rechten Anschlag finden */
	x=0;
	b=cb->b;
	while(b[x] && x < line) ++x;
	--x;
	
	kontur(cb->start_buf, cb->rx/*+x*/, cb->ry, cb->line, cb);
	
/*	debug_display(cb->start_buf, cb->line, hi);*/
	return(0);
}
*/


void n_speed_buf(COM_BUF *cb, uchar *stack)
{
	/* tested/went_to: 1=links, 2=oben, 4=rechts, 8=unten */
	uchar	went_to;
	
	register uchar	*cc, *mm, *yy, *bb;
	register uchar	cmin,cmax,mmin,mmax,ymin,ymax;
	register long	line;
	register int		x, y, maxx, maxy, minx, miny;
	
	cc=cb->c-cb->rx;
	mm=cb->m-cb->rx;
	yy=cb->y-cb->rx;
	bb=cb->b-cb->rx;

	line=cb->line;
	
	cmin=cb->cmin; cmax=cb->cmax;
	mmin=cb->mmin; mmax=cb->mmax;
	ymin=cb->ymin; ymax=cb->ymax;
	
	went_to=0;
	
	maxx=minx=x=cb->rx;
	maxy=miny=y=cb->ry;
	
	do
	{
		_test_next:
/*set_kpix(x,y);*/
		
		/* Links testen */
		if(!(bb[x] & 1))
		{		bb[x] |= 1;
			if((!bb[x-1]) &&
					(cc[x-1]>=cmin) && (cc[x-1]<=cmax) &&
					(mm[x-1]>=mmin) && (mm[x-1]<=mmax) &&
					(yy[x-1]>=ymin) && (yy[x-1]<=ymax))
			{		/*if(went_to) bb[x]=(bb[x]&15)|went_to;*/
			bb[x]|=went_to;
				--x; if(x < minx) minx=x;
				went_to=16; goto _test_next;}
		}
		
		/* Oben testen */
		if(!(bb[x] & 2))
		{
			bb[x] |= 2;
			if((!((bb-line)[x])) &&
					((cc-line)[x]>=cmin) && ((cc-line)[x]<=cmax) &&
					((mm-line)[x]>=mmin) && ((mm-line)[x]<=mmax) &&
					((yy-line)[x]>=ymin) && ((yy-line)[x]<=ymax))
			{		/*if(went_to) bb[x]=(bb[x]&15)|went_to;*/
			bb[x]|=went_to;
				--y; went_to=32; cc-=line;mm-=line;yy-=line;bb-=line;
				if(y < miny) miny=y;
				goto _test_next;}
		}
		
		/* Rechts testen */
		if(!(bb[x] & 4))
		{
			bb[x] |= 4;
			if((!bb[x+1]) &&
					(cc[x+1]>=cmin) && (cc[x+1]<=cmax) &&
					(mm[x+1]>=mmin) && (mm[x+1]<=mmax) &&
					(yy[x+1]>=ymin) && (yy[x+1]<=ymax))
			{		/*if(went_to) bb[x]=(bb[x]&15)|went_to;*/
			bb[x]|=went_to;
				++x; if(x > maxx) maxx=x;
				went_to=64; goto _test_next;}
		}
		
		/* Unten testen */
		if(!(bb[x] & 8))
		{
			bb[x] |= 8;
			if((!((bb+line)[x])) &&
					((cc+line)[x]>=cmin) && ((cc+line)[x]<=cmax) &&
					((mm+line)[x]>=mmin) && ((mm+line)[x]<=mmax) &&
					((yy+line)[x]>=ymin) && ((yy+line)[x]<=ymax))
			{		/*if(went_to) bb[x]=(bb[x]&15)|went_to;*/
			bb[x]|=went_to;
				++y; if(y > maxy) maxy=y;
				went_to=128; cc+=line;mm+=line;yy+=line;bb+=line;
				goto _test_next;}
		}
		/* Ich kann nirgends hin */
		/* Sackgasse oder RÅckweg? */
		if(bb[x] & 240) /* RÅckweg! went_to holen */
			went_to=bb[x] & 240;
		/* (Bei Sackgasse steht der RÅckweg schon in went_to! */
		
		switch(went_to)
		{
			case 16: /* zurÅck nach rechts */
				++x; went_to=0;
			goto _test_next;

			case 32:	/* zurÅck nach unten */
				++y; went_to=0; cc+=line;mm+=line;yy+=line;bb+=line;
			goto _test_next;

			case 64: /* zurÅck nach links */
				--x; went_to=0;
			goto _test_next;

			case 128: /* zurÅck nach oben */
				--y; went_to=0; cc-=line;mm-=line;yy-=line;bb-=line;
			goto _test_next;

		}
		/* Nichts hat geklappt, ich bin wieder am Startpunkt! */

	}while(bb[x] != 15);

	cb->rx=minx; cb->ry=miny;
	cb->rw=maxx-minx+1;
	cb->rh=maxy-miny+1;
}


void o_speed_buf(COM_BUF *cbuf, uchar *stack)
{
/*
	sf_debug=(uchar*)Physbase()+(long)cbuf->ry*(long)sw+cbuf->rx;
	sf_debug2=sw;
*/
	
	sf_stack=stack;
	sf_buf=cbuf->b;
	sf_cc=cbuf->c;
	sf_mm=cbuf->m;
	sf_yy=cbuf->y;
	
	sf_cmin=cbuf->cmin;
	sf_cmax=cbuf->cmax;
	sf_mmin=cbuf->mmin;
	sf_mmax=cbuf->mmax;
	sf_ymin=cbuf->ymin;
	sf_ymax=cbuf->ymax;
	
	sf_line=cbuf->line;
	
	sf_x=cbuf->rx;
	sf_y=cbuf->ry;
	
	as_speed_fill();
	
	cbuf->rx=sf_minx;
	cbuf->ry=sf_miny;
	cbuf->rw=sf_maxx-sf_minx+1;
	cbuf->rh=sf_maxy-sf_miny+1;
}

