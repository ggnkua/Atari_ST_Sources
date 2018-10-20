void calc_graph(void)
{ /* Fr Polynom 5. Grades */
	double	n,z, m1,m2,m3,mg,x2s;
	
	/* x2 w„hlen */
	x2s=ple.x2+ple.x2s+ple.x2f;
	
	/* m1-m3,mg berechnen */
	m1=(ple.y2-ple.y1)/(ple.x2-ple.x1);
	m3=(ple.y3-ple.y2)/(ple.x3-ple.x2);
	m2=tan(0.5*(atan(m1)+atan(m3)));
	mg=-1/m2;
	
	/* f, e */
	ple.f=ple.y1;
	ple.e=m1;
	
	/* d */
	/* Z„hler */
	z=50*m1*ple.x3*pow(x2s,4);
	z-=32*m1*pow(x2s,3)*ple.x2*ple.x2;
	z+=64*ple.y1*pow(x2s,4);
	z-=40*ple.y1*pow(x2s,3)*ple.x3;
	z-=65*ple.y3*pow(x2s,4);
	z+=40*ple.y3*ple.x2*pow(x2s,3);
	z+=15*ple.x3*m3*pow(x2s,4);
	z-=8*m3*pow(x2s,3)*ple.x3*ple.x3;
	z+=2*m1*pow(ple.x3,5);
	z-=2*mg*pow(ple.x3,5);
	z+=20*m1*x2s*pow(ple.x3,4);
	z-=20*mg*x2s*pow(ple.x3,4);
	z+=25*ple.y1*pow(ple.x3,4);
	z+=25*mg*ple.x2*pow(ple.x3,4);
	/* Nenner */
	n=24*pow(x2s,3)*ple.x3*ple.x3;
	n-=24*x2s*x2s*pow(ple.x3,3);
	n+=11*pow(x2s,3)*ple.x3;
	n+=4*pow(ple.x3,4);
	n+=15*x2s*pow(ple.x3,3);
	n*=(-x2s)*3;
	
	ple.d=z/n;
	
	/* c */
	/* Z„hler */
	z=-3*ple.d*x2s*x2s*pow(ple.x3,4);
	z-=3*ple.d*ple.x3*ple.x3*pow(x2s,4);
	z-=4*m1*x2s*pow(ple.x3,4);
	z-=4*m1*ple.x3*pow(x2s,4);
	z+=4*mg*x2s*pow(ple.x3,4);
	z-=5*ple.y1*pow(ple.x3,4);
	z-=5*ple.y1*pow(x2s,4);
	z+=5*ple.y2*pow(ple.x3,4);
	z-=5*mg*ple.x2*pow(ple.x3,4);
	z-=ple.x3*m3*pow(x2s,4);
	/* Nenner */
	n=ple.x3-x2s;
	n*=2*pow(x2s,3)*pow(ple.x3,3);
	
	ple.c=z/n;
	
	/* b */
	/* Z„hler */
	z=2*ple.c*pow(ple.x3,3);
	z+=3*ple.d*ple.x3*ple.x3;
	z+=4*m1*ple.x3;
	z+=5*ple.y1;
	z-=5*ple.y3;
	z+=ple.x3*m3;
	/* Nenner */
	n=-pow(ple.x3,4);
	
	ple.b=z/n;
	
	/* a */
	/* Z„hler */
	z=4*ple.b*pow(ple.x3,3);
	z+=3*ple.c*ple.x3*ple.x3;
	z+=2*ple.d*ple.x3;
	z+=m1;
	z-=m3;
	/* Nenner */
	n=-5*pow(ple.x3,4);
	
	ple.a=z/n;
}

int cdecl p_plgraph(PARMBLK *pblk)
{
	int	pxy[10];
	double n,z;

	/* Rahmen zeichnen */
	
	pxy[0]=pblk->pb_xc;
	pxy[1]=pblk->pb_yc;
	pxy[2]=pblk->pb_xc+pblk->pb_wc-1;
	pxy[3]=pblk->pb_yc+pblk->pb_hc-1;

	vs_clip(handle, 1, pxy);

	vswr_mode(handle, 1);
	vsl_color(handle, 1);
	vsl_width(handle, 1);

	vsf_color(handle, 8);
	vsf_interior(handle, 1);
	vsf_perimeter(handle, 0);

	pxy[0]=pblk->pb_x;
	pxy[1]=pblk->pb_y;
	pxy[2]=pblk->pb_x+pblk->pb_w-1;
	pxy[3]=pblk->pb_y+pblk->pb_h-1;

	++pxy[0]; ++pxy[1]; --pxy[2]; --pxy[3];
	vr_recfl(handle, pxy);
	--pxy[0]; --pxy[1]; ++pxy[2]; ++pxy[3];

	pxy[4]=pxy[2]; pxy[5]=pxy[3];
	pxy[3]=pxy[1];
	pxy[6]=pxy[0]; pxy[7]=pxy[5];
	pxy[8]=pxy[0]; pxy[9]=pxy[1];
	v_pline(handle, 5, pxy);
	
	
	/* Kurve zeichnen */

	if(ple.curve_type == 1)
	{/* Konstante */
			pxy[0]=(int)(pblk->pb_x)+(opledit[GEP1].ob_width)/2;
			pxy[2]=(int)(pblk->pb_x+ple.x3)+(opledit[GEP1].ob_width)/2;
			pxy[1]=pxy[3]=pblk->pb_y+pblk->pb_h-1-ple.y1+(opledit[GEP1].ob_height)/2;
			v_pline(handle, 2, pxy);
	}
	else if(ple.curve_type == 2)
	{/* Linie */
			pxy[0]=(int)(pblk->pb_x)+(opledit[GEP1].ob_width)/2;
			pxy[2]=(int)(pblk->pb_x+ple.x3)+(opledit[GEP1].ob_width)/2;
			pxy[1]=pblk->pb_y+pblk->pb_h-1-ple.y1+(opledit[GEP1].ob_height)/2-ple.y1;
			pxy[3]=pblk->pb_y+pblk->pb_h-1-ple.y3+(opledit[GEP1].ob_height)/2-ple.y3;
			v_pline(handle, 2, pxy);
	}
	else if(ple.curve_type == 3)
	{/* Polynom 5. Grades */
		z=0;
		pxy[2]=(int)(pblk->pb_x+z)+(opledit[GEP1].ob_width)/2;
		n=pblk->pb_y+pblk->pb_h-1;
		n=n-(ple.a*pow(z,5)+ple.b*pow(z,4)+ple.c*pow(z,3)+ple.d*z*z+ple.e*z+ple.f);
		if(n <= pblk->pb_y) n=pblk->pb_y+1;
		if(n >= pblk->pb_y+pblk->pb_h-1) n=pblk->pb_y+pblk->pb_h-2;
		n+=(pblk->pb_h-opledit[GEP1].ob_height)/2;
		pxy[3]=(int)n;

		for(z=0; z < 256; z+=ple.step)
		{
			pxy[0]=pxy[2]; pxy[1]=pxy[3];
			pxy[2]=(int)(pblk->pb_x+z)+(opledit[GEP1].ob_width)/2;
			n=pblk->pb_y+pblk->pb_h-1;
			n=n-(ple.a*pow(z,5)+ple.b*pow(z,4)+ple.c*pow(z,3)+ple.d*z*z+ple.e*z+ple.f);
			if(n <= pblk->pb_y) n=pblk->pb_y+1;
			if(n >= pblk->pb_y+pblk->pb_h-1) n=pblk->pb_y+pblk->pb_h-2;
			n+=(pblk->pb_h-opledit[GEP1].ob_height)/2;
			pxy[3]=(int)n;
			v_pline(handle, 2, pxy);
		}
	}

	vs_clip(handle, 0, pxy);
	
	return(0);
}

/* Polynom 2. Grades */
int cdecl o_plgraph(PARMBLK *pblk)
{
	int	pxy[10];
	double	n,z;
	
	/* b Berechnen */
	/* Z„hler */
	z=(((ple.y3-ple.y1)*ple.x2)/65025l)*ple.x2;
	z=z+ple.y1-ple.y2;
	/* Nenner */
	n=(ple.x2*ple.x2)/255-ple.x2;
	
	ple.b=z/n;
	
	/* a berechnen */
	/* Z„hler */
	z=ple.y3-255*ple.b-ple.y1;
	ple.a=z/65025l;
	
	/* c berechnen */
	ple.c=ple.y1;
	
	/* Rahmen zeichnen */
	
	pxy[0]=pblk->pb_x;
	pxy[1]=pblk->pb_y;
	pxy[2]=pblk->pb_x+pblk->pb_w-1;
	pxy[3]=pblk->pb_y+pblk->pb_h-1;
	
	vswr_mode(handle, 1);
	vsl_color(handle, 1);
	vsl_width(handle, 1);

	vsf_color(handle, 8);
	vsf_interior(handle, 1);
	vsf_perimeter(handle, 0);

	vs_clip(handle, 1, pxy);
	++pxy[0]; ++pxy[1]; --pxy[2]; --pxy[3];
	vr_recfl(handle, pxy);
	--pxy[0]; --pxy[1]; ++pxy[2]; ++pxy[3];

	pxy[4]=pxy[2]; pxy[5]=pxy[3];
	pxy[3]=pxy[1];
	pxy[6]=pxy[0]; pxy[7]=pxy[5];
	pxy[8]=pxy[0]; pxy[9]=pxy[1];
	v_pline(handle, 5, pxy);
	
	
	/* Kurve zeichnen */

	for(z=0; z < 256; ++z)
	{
		pxy[0]=pxy[2]=(int)(pblk->pb_x+z);
		n=pblk->pb_y+pblk->pb_h-1;
		n=n-(ple.a*z*z+ple.b*z+ple.c);
		pxy[1]=pxy[3]=(int)n;
		v_pline(handle, 2, pxy);
	}

	vs_clip(handle, 0, pxy);
	
	return(0);
}

/* Geraden-Žnn„herung */

int cdecl plgraph(PARMBLK *pblk)
{
	int	pxy[10];
	double	n,z,m,y, x0, x0p, y0, y0p;
	
	/* m1 Berechnen */
	ple.a=(ple.y2-ple.y1)/(ple.x2-ple.x1);
	
	/* m3 berechnen */
	ple.c=(ple.y3-ple.y2)/(ple.x3-ple.x2);
	
	/* m2 berechnen */
	ple.b=tan(0.5*(atan(ple.a)+atan(ple.c)));
	
	
	/* Rahmen zeichnen */
	
	pxy[0]=pblk->pb_x;
	pxy[1]=pblk->pb_y;
	pxy[2]=pblk->pb_x+pblk->pb_w-1;
	pxy[3]=pblk->pb_y+pblk->pb_h-1;
	
	vswr_mode(handle, 1);
	vsl_color(handle, 1);
	vsl_width(handle, 1);

	vsf_color(handle, 8);
	vsf_interior(handle, 1);
	vsf_perimeter(handle, 0);

	vs_clip(handle, 1, pxy);
	++pxy[0]; ++pxy[1]; --pxy[2]; --pxy[3];
	vr_recfl(handle, pxy);
	--pxy[0]; --pxy[1]; ++pxy[2]; ++pxy[3];

	pxy[4]=pxy[2]; pxy[5]=pxy[3];
	pxy[3]=pxy[1];
	pxy[6]=pxy[0]; pxy[7]=pxy[5];
	pxy[8]=pxy[0]; pxy[9]=pxy[1];
	v_pline(handle, 5, pxy);
	
	
	/* Kurve zeichnen */
	/* Erster Teil */
	n=(ple.b-ple.a)/ple.x2;
	m=(ple.c-ple.b)/(ple.x3-ple.x2);
	m=ple.a;
	x0=ple.x1=0;
	x0p=(ple.x2-ple.x1)/ple.x2;
	y0=ple.y1;
	y0p=(ple.y2-ple.y1)/ple.x2;
	for(z=0; z<ple.x2; ++z)
	{
		pxy[0]=pxy[2]=(int)(pblk->pb_x+z);
		y=m*(z-1-x0)+y0;
		pxy[1]=pxy[3]=(int)(255-y)+pblk->pb_y;
		v_pline(handle, 2, pxy);
/*		x0+=x0p;*/
/*		y0+=y0p;*/
		m+=n;
	}
	/* Zweiter Teil */
	n=(ple.c-ple.b)/(ple.x3-ple.x2);
	m=ple.b;
/*	x0=ple.x3;*/
	x0p=(ple.x3-ple.x2)/(ple.x3-ple.x2);
/*	y0=ple.y3;*/
	y0p=(ple.y3-ple.y2)/(ple.x3-ple.x2);
	for(z=ple.x2; z<255; ++z)
	{
		pxy[0]=pxy[2]=(int)(pblk->pb_x+z);
		y=m*(z-x0)+y0;
		pxy[1]=pxy[3]=(int)(255-y)+pblk->pb_y;
		v_pline(handle, 2, pxy);
/*		x0+=x0p;*/
/*		y0+=y0p;*/
		m+=n;
	}

	vs_clip(handle, 0, pxy);
	
	return(0);
}

void slide_x2s(int barob, int slob, double *val, double fac)
{
	int	ox, mx, k, dum;
	
	wind_update(BEG_UPDATE);
	wind_update(BEG_MCTRL);

	objc_offset(opledit, barob, &ox, &dum);
	
	ple.step=5;
	ple.draw=0;
	do
	{
		graf_mkstate(&mx, &dum, &k, &dum);
		if(((mx-ox) >=0) && ((mx -ox) <= 255))
		{
			if((mx-ox) != opledit[slob].ob_x)
			{
				opledit[slob].ob_x=mx-ox;
				w_objc_draw(&wpledit, barob, 2, sx, sy, sw, sh);
				*val=(128-opledit[slob].ob_x);
				*val*=fac;
				calc_graph();
				w_objc_draw(&wpledit, GEGRAPH, 2, sx, sy, sw, sh);
			}
		}
			
	}while(k&3);
	ple.step=2;
	ple.draw=-1;
	calc_graph();
	w_objc_draw(&wpledit, GEGRAPH, 2, sx, sy, sw, sh);

	wind_update(END_MCTRL);
	wind_update(END_UPDATE);
}
