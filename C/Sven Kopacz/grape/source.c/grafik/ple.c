#include <grape_h.h>
#include "grape.h"
#include "ple.h"
#include "penedit.h"

/* Polynom-Editor */

void fill_ple(int *pxy)
{ /* FÅllt ple.y von pxy[0] bis pxy[2] mit Werten von */
	/* pxy[1] bis pxy[3] */

	double m, dx, dy, x0,y0,x1;
	
	dx=(double)((double)pxy[2]-(double)pxy[0]);
	dy=(double)((double)pxy[3]-(double)pxy[1]);
	m=dy/dx;
	x1=(double)pxy[0];
	y0=(double)pxy[1];
	
	for(x0=pxy[0]; x0<=pxy[2]; ++x0)
		ple.y[x0]=m*(x0-x1)+y0;
	
}

void curve_to_free(void)
{
	/* öbernimmt Kurve in Freihand-Parameter */

	int x,pxy[4];
	double	z, x0, y0;
	
	/* Freihand ggf. lîschen */
	if(ple.curve_type < 4)
	{
		for(x=0; x < 512; ++x)
			ple.y[x]=-1;
	}
		
	if(ple.curve_type == 1)
	{/* Konstante */
		pxy[0]=0; pxy[2]=opledit[GEGRAPH].ob_width-1;
		pxy[1]=pxy[3]=ple.y1;
		fill_ple(pxy);
	}
	else if(ple.curve_type == 2)
	{/* Linie */
		pxy[0]=0; pxy[2]=opledit[GEGRAPH].ob_width-1;
		pxy[1]=ple.y1; pxy[3]=ple.y3;
		fill_ple(pxy);
	}
	else if(ple.curve_type == 3)
	{
		pxy[2]=ple.x1;
		pxy[3]=ple.y1;
	
		for(z=0; z<=1; z+=0.05)
		{
			x0=(1-z)*(1-z)*(1-z)*ple.x1;
			x0+=3*z*(1-z)*(1-z)*ple.x2;
			x0+=3*z*z*(1-z)*ple.x2;
			x0+=z*z*z*ple.x3;
			
			y0=pow(1-z,3)*ple.y1;
			y0+=3*z*(1-z)*(1-z)*ple.y2;
			y0+=3*z*z*(1-z)*ple.y2;
			y0+=z*z*z*ple.y3;
	
			pxy[0]=pxy[2];
			pxy[1]=pxy[3];
			pxy[2]=(int)x0;
			pxy[3]=(int)y0;
			fill_ple(pxy);
		}
		pxy[0]=pxy[2];
		pxy[1]=pxy[3];
		pxy[2]=ple.x3;
		pxy[3]=ple.y3;
		fill_ple(pxy);

	}
	else if(ple.curve_type == 4)
	{ /* Freihand-Kurve */
		pxy[2]=0; pxy[3]=ple.y[0];
		
		for(x=0; x < opledit[GEGRAPH].ob_width; ++x)
		{
			if(ple.y[x] > -1)
			{
				pxy[0]=pxy[2];
				pxy[1]=pxy[3];
				pxy[2]=x;
				pxy[3]=ple.y[x];
				fill_ple(pxy);
			}
		}
	}
	
}

void move_point(int ob)
{
	int	k, x, y, dum, ox=0, oy=0, osx, osy, minx, maxx, miny, maxy;
	
	objc_offset(opledit, GEGRAPH, &osx, &osy);

	minx=osx; maxx=osx+255;
	miny=osy;
	maxy=miny+opledit[GEGRAPH].ob_height-1;
	if(ob == GEP1)
		maxx=minx;
	if(ob == GEP3)
		minx=maxx;
	if(ob == GEP2)
	{
		++minx;
		--maxx;
		maxx-=opledit[GEP2].ob_width;
		maxy=miny+opledit[GEGRAPH].ob_height-opledit[GEP2].ob_height;
	}
		
	wind_update(BEG_UPDATE);
	wind_update(BEG_MCTRL);
	
	do
	{
		graf_mkstate(&x, &y, &k, &dum);
		if(ob == GEP2)
		{x-=opledit[GEP2].ob_width/2; y-=opledit[GEP2].ob_height/2;}
		if((x != ox) || (y != oy))
		{
			if(x < minx) x=minx;
			if(x > maxx) x=maxx;
			if(y < miny) y=miny;
			if(y > maxy) y=maxy;
			if((x != ox) || (y != oy))
			{
				opledit[ob].ob_y=y-osy;
				switch(ob)
				{
					case GEP1:
						ple.y1=255-(y-osy);
						w_objc_draw(&wpledit, GEYB1, 2, sx, sy, sw, sh);
					break;
					case GEP2:
						opledit[ob].ob_x=x-osx;
						ple.x2=x-osx;
						ple.y2=255-(y-osy+opledit[GEP2].ob_height/2);
					break;
					case GEP3:
						ple.y3=255-(y-osy);
						w_objc_draw(&wpledit, GEYB3, 2, sx, sy, sw, sh);
					break;
				}
				w_objc_draw(&wpledit, GEGRAPH, 2, sx, sy, sw, sh);
			}
			ox=x; oy=y;
		}
	}while(k & 3);
	w_objc_draw(&wpledit, GEGRAPH, 2, sx, sy, sw, sh);

	wind_update(END_MCTRL);
	wind_update(END_UPDATE);
}

void free_hand(void)
{
	int	k, x, y, t, dum, ox=0, oy=0, osx, osy, minx, maxx, miny, maxy;
	
	objc_offset(opledit, GEGRAPH, &osx, &osy);

	minx=osx; maxx=osx+255;
	miny=osy; maxy=miny+opledit[GEGRAPH].ob_height-1;
		
	wind_update(BEG_UPDATE);
	wind_update(BEG_MCTRL);
	
	do
	{
		graf_mkstate(&x, &y, &k, &dum);
		if((x != ox) || (y != oy))
		{
			if(x < minx) x=minx;
			if(x > maxx) x=maxx;
			if(y < miny) y=miny;
			if(y > maxy) y=maxy;
			if((x != ox) || (y != oy))
			{
				if(ox == 0)
					ox=x;
				if(ox <= x)
					for(t=ox+1; t <x; ++t)
						ple.y[t-osx]=-1;
				else
					for(t=x+1; t <ox; ++t)
						ple.y[t-osx]=-1;

				ple.y[x-osx]=opledit[GEGRAPH].ob_height-(y-osy)-1;
				w_objc_draw(&wpledit, GEGRAPH, 2, sx, sy, sw, sh);
			}
			ox=x; oy=y;
		}
	}while(k & 3);

	wind_update(END_MCTRL);
	wind_update(END_UPDATE);
}

void spec_act(int ob)
{
	/* Spiegeln und Scrollen */
	double b1;
	int		 c, buf[512], k, dum, scroll_val;
		
	opledit[ob].ob_x=TB_M_IMG_X+1;
	opledit[ob].ob_y=1;
	opledit[ob-1].ob_state |= SELECTED;
	w_objc_draw(&wpledit, ob-1, 8, sx, sy, sw, sh);

	if(ple.curve_type < 4)
	{
		switch(ob)
		{
			case GEUP:
				do
				{
					if(artpad) /* Arrows per Wacom bedienen? */
						scroll_val=((int)asgc->pressure+20)/20;
					else
						scroll_val=1;

					if(ple.y1 < 255)
					{
						ple.y1+=scroll_val;
						if(ple.y1 > 255) ple.y1=255;
						opledit[GEP1].ob_y=255-ple.y1;
						w_objc_draw(&wpledit, GEYB1, 2, sx, sy, sw, sh);
					}
					if(ple.y2 < 255)
					{
						ple.y2+=scroll_val;
						if(ple.y2 > 255-opledit[GEP2].ob_height/2) ple.y2=255-opledit[GEP2].ob_height/2;
						opledit[GEP2].ob_y=255-ple.y2-opledit[GEP2].ob_height/2;
					}
					if(ple.y3 < 255)
					{
						ple.y3+=scroll_val;
						if(ple.y3 > 255) ple.y3=255;
						opledit[GEP3].ob_y=255-ple.y3;
						w_objc_draw(&wpledit, GEYB3, 2, sx, sy, sw, sh);
					}
					w_objc_draw(&wpledit, GEGRAPH, 2, sx, sy, sw, sh);
					graf_mkstate(&dum, &dum, &k, &dum);
				}while(k & 1);
			break;
			case GEDOWN:
				do
				{
					if(artpad) /* Arrows per Wacom bedienen? */
						scroll_val=((int)asgc->pressure+20)/20;
					else
						scroll_val=1;

					if(ple.y1 > 0)
					{
						ple.y1-=scroll_val;
						if(ple.y1 < 0) ple.y1=0;
						opledit[GEP1].ob_y=255-ple.y1;
						w_objc_draw(&wpledit, GEYB1, 2, sx, sy, sw, sh);
					}
					if(ple.y2 > opledit[GEP2].ob_height)
					{
						ple.y2-=scroll_val;
						if(ple.y2 < opledit[GEP2].ob_height/2) ple.y2=opledit[GEP2].ob_height/2;
						opledit[GEP2].ob_y=255-ple.y2-opledit[GEP2].ob_height/2;
					}
					if(ple.y3 > 0)
					{
						ple.y3-=scroll_val;
						if(ple.y3 < 0) ple.y3=0;
						opledit[GEP3].ob_y=255-ple.y3;
						w_objc_draw(&wpledit, GEYB3, 2, sx, sy, sw, sh);
					}
					w_objc_draw(&wpledit, GEGRAPH, 2, sx, sy, sw, sh);
					graf_mkstate(&dum, &dum, &k, &dum);
				}while(k & 1);
			break;
			case GEVMIR:
				ple.y1=255-ple.y1;
				opledit[GEP1].ob_y=255-ple.y1;
				w_objc_draw(&wpledit, GEYB1, 2, sx, sy, sw, sh);
				ple.y2=255-ple.y2;
				opledit[GEP2].ob_y=255-ple.y2-opledit[GEP2].ob_height/2;
				ple.y3=255-ple.y3;
				opledit[GEP3].ob_y=255-ple.y3;
				w_objc_draw(&wpledit, GEYB3, 2, sx, sy, sw, sh);
				w_objc_draw(&wpledit, GEGRAPH, 2, sx, sy, sw, sh);
				do
				{
					graf_mkstate(&dum, &dum, &k, &dum);
				}while(k & 1);
			break;
			case GEHMIR:
				if(ple.curve_type > 1)
				{
					b1=ple.y1;
					ple.y1=ple.y3;
					ple.y3=b1;
					opledit[GEP1].ob_y=255-ple.y1;
					opledit[GEP3].ob_y=255-ple.y3;
					w_objc_draw(&wpledit, GEYB1, 2, sx, sy, sw, sh);
					w_objc_draw(&wpledit, GEYB3, 2, sx, sy, sw, sh);
					ple.x2=255-ple.x2;
					opledit[GEP2].ob_x=ple.x2;
					w_objc_draw(&wpledit, GEGRAPH, 2, sx, sy, sw, sh);
				}
				else
					Bell(); /* Gerade kann nicht h-gespiegelt werden */
				do
				{
					graf_mkstate(&dum, &dum, &k, &dum);
				}while(k & 1);
			break;
		}
	}
	else
	{
		switch(ob)
		{
			case GEUP:
				do
				{
					if(artpad) /* Arrows per Wacom bedienen? */
						scroll_val=((int)asgc->pressure+20)/20;
					else
						scroll_val=1;

					for(c=0; c < 512; ++c)
						if((ple.y[c] > -1) && (ple.y[c] < 255))
						{
							ple.y[c]+=scroll_val;
							if(ple.y[c] > 255) ple.y[c]=255;
						}
					w_objc_draw(&wpledit, GEGRAPH, 2, sx, sy, sw, sh);
					graf_mkstate(&dum, &dum, &k, &dum);
				}while(k & 1);
			break;
			case GEDOWN:
				do
				{
					if(artpad) /* Arrows per Wacom bedienen? */
						scroll_val=((int)asgc->pressure+20)/20;
					else
						scroll_val=1;

					for(c=0; c < 512; ++c)
						if(ple.y[c] > 0)
						{
							ple.y[c]-=scroll_val;
							if(ple.y[c] < 0) ple.y[c]=0;
						}
					w_objc_draw(&wpledit, GEGRAPH, 2, sx, sy, sw, sh);
					graf_mkstate(&dum, &dum, &k, &dum);
				}while(k & 1);
			break;
			case GEVMIR:
				for(c=0; c < 512; ++c)
					if(ple.y[c] > -1)
						ple.y[c]=255-ple.y[c];
				w_objc_draw(&wpledit, GEGRAPH, 2, sx, sy, sw, sh);
				do
				{
					graf_mkstate(&dum, &dum, &k, &dum);
				}while(k & 1);
			break;
			case GEHMIR:
				for(c=0; c < opledit[GEGRAPH].ob_width; ++c) buf[c]=ple.y[c];
				for(c=0; c < opledit[GEGRAPH].ob_width; ++c) ple.y[c]=buf[opledit[GEGRAPH].ob_width-c-1];
				w_objc_draw(&wpledit, GEGRAPH, 2, sx, sy, sw, sh);
				do
				{
					graf_mkstate(&dum, &dum, &k, &dum);
				}while(k & 1);
			break;
		}
	}

	opledit[ob].ob_x=TB_M_IMG_X;
	opledit[ob].ob_y=0;
	opledit[ob-1].ob_state &= (~SELECTED);
	w_objc_draw(&wpledit, ob-1, 8, sx, sy, sw, sh);
}

void dial_pledit(int ob)
{
	int x, ox, dum;
	
	if(ob == GEUP-1) ob=GEUP;
	if(ob == GEDOWN-1) ob=GEDOWN;
	if(ob == GEVMIR-1) ob=GEVMIR;
	if(ob == GEHMIR-1) ob=GEHMIR;
	
	switch(ob)
	{
		case GEP1:
		case GEP2:
		case GEP3:
			move_point(ob);
		break;
		

		case GEUP:
		case GEDOWN:
		case GEVMIR:
		case GEHMIR:
			spec_act(ob);
		break;
		
		case GEE1:
			if(ple.curve_type == 1)
				break;
			if(ple.curve_type == 4)
				if(form_alert(1,"[1][Grape:|Die Freihandkurve geht durch|diese Aktion verloren!][OK|Abbruch]")-1)
				{
					opledit[ob].ob_state&=(~SELECTED);
					opledit[GEE4].ob_state|=SELECTED;
					s_redraw(&wpledit);
					break;
				}
			ple.curve_type=1;
			opledit[GEP1].ob_flags&=(~HIDETREE);
			opledit[GEP2].ob_flags|=HIDETREE;
			opledit[GEP3].ob_flags|=HIDETREE;
			s_redraw(&wpledit);
		break;
		case GEE2:
			if(ple.curve_type == 2)
				break;
			if(ple.curve_type == 4)
				if(form_alert(1,"[1][Grape:|Die Freihandkurve geht durch|diese Aktion verloren!][OK|Abbruch]")-1)
				{
					opledit[ob].ob_state&=(~SELECTED);
					opledit[GEE4].ob_state|=SELECTED;
					s_redraw(&wpledit);
					break;
				}
			ple.curve_type=2;
			opledit[GEP1].ob_flags&=(~HIDETREE);
			opledit[GEP2].ob_flags|=HIDETREE;
			opledit[GEP3].ob_flags&=(~HIDETREE);
			s_redraw(&wpledit);
		break;
		case GEE3:
			if(ple.curve_type == 3)
				break;
			if(ple.curve_type == 4)
				if(form_alert(1,"[1][Grape:|Die Freihandkurve geht durch|diese Aktion verloren!][OK|Abbruch]")-1)
				{
					opledit[ob].ob_state&=(~SELECTED);
					opledit[GEE4].ob_state|=SELECTED;
					s_redraw(&wpledit);
					break;
				}
			ple.curve_type=3;
			opledit[GEP1].ob_flags&=(~HIDETREE);
			opledit[GEP2].ob_flags&=(~HIDETREE);
			opledit[GEP3].ob_flags&=(~HIDETREE);
			s_redraw(&wpledit);
		break;
		case GEE4:
		curve_to_free();
				s_redraw(&wpledit);
			if(ple.curve_type != 4)
			{
				curve_to_free();
				ple.curve_type=4;
				opledit[GEP1].ob_flags|=HIDETREE;
				opledit[GEP2].ob_flags|=HIDETREE;
				opledit[GEP3].ob_flags|=HIDETREE;

				s_redraw(&wpledit);
			}
		break;

		case GEGRAPH:
			if(ple.curve_type < 4)
			{
				switch(ple.curve_type)
				{
					case 3:
						move_point(GEP2); break;
					case 2:
						graf_mkstate(&x, &dum, &dum, &dum);
						objc_offset(opledit, GEGRAPH, &ox, &dum);
						if((x-ox) < opledit[GEGRAPH].ob_width/2)
							move_point(GEP1);
						else
							move_point(GEP3);
					break;
					case 1:
						move_point(GEP1); break;
				}
			}
			else
				free_hand();
		break;
		case GEY1:
			if(ple.curve_type < 4)
				move_point(GEP1);
		break;
		case GEY3:
			if(ple.curve_type < 4)
				move_point(GEP3);
		break;
		
		case GESET:
			curve_to_free();
			if(ple_target.p1)
				*ple_target.p1=ple;
			if(ple_target.p2)
				*ple_target.p2=ple;
			if(ple_target.p3)
				*ple_target.p3=ple;
			s_redraw(&wpened);
			unsel(opledit, ob);
		break;

		case GEOK:
			curve_to_free();
			if(ple_target.p1)
				*ple_target.p1=ple;
			if(ple_target.p2)
				*ple_target.p2=ple;
			if(ple_target.p3)
				*ple_target.p3=ple;
			s_redraw(&wpened);
		case GEABBRUCH:
			unsel(opledit, ob);
			w_close(&wpledit);
		break;	
		
		case GPLEDLS:
			if(quick_io("Polynom", paths.poly_path, &ple, &ple, sizeof(POLYNOM), magics.poly)==QIOLOAD)
			{/* Neu aufbauen */
				opledit[GEE1].ob_state&=(~SELECTED);
				opledit[GEE2].ob_state&=(~SELECTED);
				opledit[GEE3].ob_state&=(~SELECTED);
				opledit[GEE4].ob_state&=(~SELECTED);
				opledit[GEE1-1+ple.curve_type].ob_state|=SELECTED;
			
				opledit[GEP1].ob_flags&=(~HIDETREE);
				opledit[GEP2].ob_flags&=(~HIDETREE);
				opledit[GEP3].ob_flags&=(~HIDETREE);
				switch(ple.curve_type)
				{
					case 4:
						opledit[GEP1].ob_flags|=HIDETREE;
					case 1:
						opledit[GEP3].ob_flags|=HIDETREE;
					case 2:
						opledit[GEP2].ob_flags|=HIDETREE;
					break;
				}
				
				opledit[GEP1].ob_y=opledit[GEGRAPH].ob_height-ple.y1-1;
				opledit[GEP2].ob_x=ple.x2;
				opledit[GEP2].ob_y=opledit[GEGRAPH].ob_height-ple.y2-1;
				opledit[GEP3].ob_y=opledit[GEGRAPH].ob_height-ple.y3-1;
				s_redraw(&wpledit);
			}
		break;
	}
}
