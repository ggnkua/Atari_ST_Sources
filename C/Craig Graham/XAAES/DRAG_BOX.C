/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include <VDI.H>
#include "XA_DEFS.H"
#include "XA_TYPES.H"
#include "K_DEFS.H"
#include "XA_GLOBL.H"

/*
	Ghost outline dragging routines - all coded to work with full rectangles instead of outlines
*/
void drag_box(short w, short h, short xs, short ys, short bx, short by, short bw, short bh, short *xe, short *ye)
{
	short x,y,mb, idx, idy, dx,dy, odx=-1, ody=-1;
	short pnt[4];
	
	vq_mouse(V_handle, &mb, &x, &y);
	vswr_mode(V_handle, MD_XOR);

	vsf_color(V_handle,BLACK);
	vsf_perimeter(V_handle,0);
	
	idx=x-xs; idy=y-ys;
	
	while(mb)
	{
		vq_mouse(V_handle, &mb, &x, &y);
		dx=x-idx; dy=y-idy;
		
		if (dx<bx)		/* Ensure we are inside the bounding rectangle */
		{
			dx=bx;
		}else{
			if (dx+w>bx+bw) dx=bx+bw-w-1;
		}
		if (dy<by)
		{
			dy=by;
		}else{
			if (dy+h>by+bh) dy=by+bh-h-1;
		}
		
		if ((dx!=odx)||(dy!=ody))
		{
			v_hide_c(V_handle);
			if (odx!=-1)
#if SOLID_BOXES
				v_bar(V_handle,pnt);		/* This is a real man's GUI - dragged boxs can be done as solid */

			pnt[0]=dx; pnt[1]=dy; pnt[2]=dx+w; pnt[3]=dy+h;
			v_bar(V_handle,pnt);
#else
			{
				pnt[0]=odx; pnt[1]=ody; pnt[2]=odx+w-1; pnt[3]=ody+1;
				v_bar(V_handle,pnt);
				pnt[0]=odx+w; pnt[1]=ody; pnt[2]=odx+w+1; pnt[3]=ody+h-1;
				v_bar(V_handle,pnt);
				pnt[0]=odx+w; pnt[1]=ody+h; pnt[2]=odx+1; pnt[3]=ody+h+1;
				v_bar(V_handle,pnt);
				pnt[0]=odx; pnt[1]=ody+1; pnt[2]=odx+1; pnt[3]=ody+h;
				v_bar(V_handle,pnt);
			}
				
			pnt[0]=dx; pnt[1]=dy; pnt[2]=dx+w-1; pnt[3]=dy+1;
			v_bar(V_handle,pnt);
			pnt[0]=dx+w; pnt[1]=dy; pnt[2]=dx+w+1; pnt[3]=dy+h-1;
			v_bar(V_handle,pnt);
			pnt[0]=dx+w; pnt[1]=dy+h; pnt[2]=dx+1; pnt[3]=dy+h+1;
			v_bar(V_handle,pnt);
			pnt[0]=dx; pnt[1]=dy+1; pnt[2]=dx+1; pnt[3]=dy+h;
			v_bar(V_handle,pnt);
#endif
			v_show_c(V_handle, 1);
			odx=dx; ody=dy;
		}
	}
	
	if (odx!=-1)
	{
		v_hide_c(V_handle);
		pnt[0]=dx; pnt[1]=dy; pnt[2]=dx+w-1; pnt[3]=dy+1;
		v_bar(V_handle,pnt);
		pnt[0]=dx+w; pnt[1]=dy; pnt[2]=dx+w+1; pnt[3]=dy+h-1;
		v_bar(V_handle,pnt);
		pnt[0]=dx+w; pnt[1]=dy+h; pnt[2]=dx+1; pnt[3]=dy+h+1;
		v_bar(V_handle,pnt);
		pnt[0]=dx; pnt[1]=dy+h; pnt[2]=dx+1; pnt[3]=dy+1;
		v_bar(V_handle,pnt);
		v_show_c(V_handle, 1);
	}

	vswr_mode(V_handle, MD_TRANS);
	
	*xe=dx; *ye=dy;
}

void rubber_box(short sx, short sy, short minw, short minh, short *lastw, short *lasth)
{
	short x,y,mb,dw,dh, odw=-1, odh=-1;
	short pnt[4];
	
	vswr_mode(V_handle, MD_XOR);
	vq_mouse(V_handle, &mb, &x, &y);

	vsf_color(V_handle,BLACK);
	vsf_perimeter(V_handle,0);

	while(mb)
	{
		vq_mouse(V_handle, &mb, &x, &y);
		dw=x-sx; dh=y-sy;
		
		if (dw<minw)
			dw=minw;

		if (dh<minh)
			dh=minh;
		
		if ((dw!=odw)||(dh!=odh))
		{
			v_hide_c(V_handle);
			if (odw!=-1)
			{
				pnt[0]=sx; pnt[1]=sy; pnt[2]=sx+odw-1; pnt[3]=sy+1;
				v_bar(V_handle,pnt);
				pnt[0]=sx+odw; pnt[1]=sy; pnt[2]=sx+odw+1; pnt[3]=sy+odh-1;
				v_bar(V_handle,pnt);
				pnt[0]=sx+odw; pnt[1]=sy+odh; pnt[2]=sx+1; pnt[3]=sy+odh+1;
				v_bar(V_handle,pnt);
				pnt[0]=sx; pnt[1]=sy+odh; pnt[2]=sx+1; pnt[3]=sy+1;
				v_bar(V_handle,pnt);
			}
			pnt[0]=sx; pnt[1]=sy; pnt[2]=sx+dw-1; pnt[3]=sy+1;
			v_bar(V_handle,pnt);
			pnt[0]=sx+dw; pnt[1]=sy; pnt[2]=sx+dw+1; pnt[3]=sy+dh-1;
			v_bar(V_handle,pnt);
			pnt[0]=sx+dw; pnt[1]=sy+dh; pnt[2]=sx+1; pnt[3]=sy+dh+1;
			v_bar(V_handle,pnt);
			pnt[0]=sx; pnt[1]=sy+dh; pnt[2]=sx+1; pnt[3]=sy+1;
			v_bar(V_handle,pnt);

			v_show_c(V_handle, 1);
			odw=dw; odh=dh;
		}
	}
	
	if (odw!=-1)
	{
		v_hide_c(V_handle);
		pnt[0]=sx; pnt[1]=sy; pnt[2]=sx+dw-1; pnt[3]=sy+1;
		v_bar(V_handle,pnt);
		pnt[0]=sx+dw; pnt[1]=sy; pnt[2]=sx+dw+1; pnt[3]=sy+dh-1;
		v_bar(V_handle,pnt);
		pnt[0]=sx+dw; pnt[1]=sy+dh; pnt[2]=sx+1; pnt[3]=sy+dh+1;
		v_bar(V_handle,pnt);
		pnt[0]=sx; pnt[1]=sy+dh; pnt[2]=sx+1; pnt[3]=sy+1;
		v_bar(V_handle,pnt);
		v_show_c(V_handle, 1);
	}

	vswr_mode(V_handle, MD_TRANS);
	
	*lastw=dw; *lasth=dh;
}

