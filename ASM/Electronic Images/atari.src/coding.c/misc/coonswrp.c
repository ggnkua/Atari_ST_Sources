/* Coons_warp: warps the picture in source image into a rectangular
 * destination image according to four boundary curves, using a
 * bilinear Coons patch.
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define SHIFT 16        /* number of fractional bits in fixed point coords */
#define SCALE (1<<SHIFT)

typedef struct {        /* 2-D POINT OR VECTOR */
   short x, y;
} Points;

typedef struct {      
    int px;
    int dx;
    int py;
    int dy;
} Ipoint;

static char *pic;
static Ipoint pua[320];
static Points pts0[320],pts1[320],pts2[320],pts3[320];
static int wib1=0,wib2=0;

void coons_warp(int nu,int nv,Points *pu0,Points *p1v,Points *pu1,Points *p0v)
{   register Ipoint *pu;
    register char *scr = (char *) 0xa0000;
    int u, v, du, dv, fv;
    Points p00, p01, p10, p11;
    nu--; nv--; pu1+=nu; p0v+=nv;
    p00.x = (p0v[ 0].x + pu0[  0].x)>>1;        /* upper left patch corner */
    p00.y = (p0v[ 0].y + pu0[  0].y)>>1;
    p10.x = (pu0[nu].x + p1v[  0].x)>>1;        /* upper right */
    p10.y = (pu0[nu].y + p1v[  0].y)>>1;
    p11.x = (p1v[nv].x + pu1[-nu].x)>>1;        /* lower right */
    p11.y = (p1v[nv].y + pu1[-nu].y)>>1;
    p01.x = (pu1[ 0].x + p0v[-nv].x)>>1;        /* lower left */
    p01.y = (pu1[ 0].y + p0v[-nv].y)>>1;
    du = SCALE/nu;
    dv = SCALE/nv;
    for (pu=pua, u=0; u<=nu; u++, pu++) {
	pu->dx = (pu1[-u].x - pu0[u].x)*dv ;
	pu->dy = (pu1[-u].y - pu0[u].y)*dv ;
	pu->px = pu0[u].x*SCALE ;
	pu->py = pu0[u].y*SCALE ;
    }
    WaitVBL();
    SetColour(0,0,0,0);
    for (fv=0, v=0; v<=nv; v++, fv+=dv) {
	int fv2 = SCALE-fv;
	int qx = (p0v[-v].x*SCALE-fv2*p00.x-fv*p01.x+(SCALE/2));
	int qy = (p0v[-v].y*SCALE-fv2*p00.y-fv*p01.y+(SCALE/2));
	int dqx = ((p1v[v].x-p0v[-v].x)*SCALE-fv2*(p10.x-p00.x)-fv*(p11.x-p01.x)) /nu;
	int dqy = ((p1v[v].y-p0v[-v].y)*SCALE-fv2*(p10.y-p00.y)-fv*(p11.y-p01.y)) /nu;
	for (pu=pua, u=nu; u>=0; u--, pu++) {
		int x,y;
#pragma aux coons param [esi,edi] = 	\
"		mov 	eax,[esi]	"\
"		add	eax,ecx		"\
"		sar	eax,16		"\
"		mov	ebx,8[esi]	"\
"		add	ebx,edx		"\
"		sar	ebx,16		"\
"		add	ecx,[dqx]	"\
"		add	edx,[dqy]	"\
		mov	eax,[esi]
		add	eax,4[esi]
		mov	ebx,8[esi]
		add	ebx,12[esi]
		mov	[esi],eax
		mov	8[esi],ebx
			
	 	/*x = (pu->px+qx) >> SHIFT;
		y = (pu->py+qy) >> SHIFT;
		*scr++ = *((pic+800)+x+(y<<8));
	    	qx += dqx;
	    	qy += dqy;
	    	pu->px += pu->dx;
	    	pu->py += pu->dy;
		*/
	}
	scr += (319-nu);
    }
    SetColour(0,30,30,30);
}

void test(void)
{ 	int i;
	for (i=0;i<256;i++)
	{	pts0[i].x = i;
		pts0[i].y = 0;
		pts2[i].x = 255-wib1;
		pts2[i].y = 159-wib2;
	}
	for (i=0;i<256;i++)
	{	pts1[i].x = 255;
		pts1[i].y = i;
		pts3[i].x = 0;
		pts3[i].y = (159-i);
	}
	coons_warp(256,160,pts0,pts1,pts2,pts3);
}
int main(void)
{ 	SetMode(0x13);
    	pic = (char *)alloc_read_file("chaos.raw");
	Setpal(pic+32);
	while (wib1<300)
	{	test();
		wib1+=8;
		wib2+=1;
	}
	free(pic);
	SetMode(0x03);
	return 0;
}


