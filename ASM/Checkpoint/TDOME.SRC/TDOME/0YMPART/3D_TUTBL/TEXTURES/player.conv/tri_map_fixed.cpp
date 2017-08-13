///////////////////////////////////////////////////////////////
// Triangle-Texturemapper   (w) defjam`2000
//
// TEXTURE HAS TO BE  256x256 x32
///////////////////////////////////////////////////////////////
//  V1.0: -Innerloop now uses 16|16 fixed point
//        -but the span-calc is still the lame m*p/delta_y ...
//        -BONUS!  rect_map!  (but also lame ...
//                    just splits the rectangle in 2 triangles


#include "main.h"
#include "datatypes.h"
#include "display.h"

//#define XW	320
//#define YW	200

#define MAX_X XW

int CLIP_TOP	= 0;
int CLIP_BOTTOM = YW-1;

int CLIP_LEFT	= 0;
int CLIP_RIGHT	= XW-1;


void tri_map(int x1,int y1,int x2,int y2,int x3,int y3,
             int u1,int v1,int u2,int v2,int u3,int v3,
             unsigned int *texture,
             unsigned int *screen);

void rect_map(int x1,int y1,int x2,int y2,int x3,int y3,int x4,int y4,
             int u1,int v1,int u2,int v2,int u3,int v3,int u4,int v4,
             unsigned int *texture,
             unsigned int *screen);
///////////////////////////////////////////////////////////////

void rect_map(int x1,int y1,int x2,int y2,int x3,int y3,int x4,int y4,
             int u1,int v1,int u2,int v2,int u3,int v3,int u4,int v4,
             unsigned int *texture,
             unsigned int *screen)  {
  tri_map(x1,y1,x2,y2,x3,y3,u1,v1,u2,v2,u3,v3,texture,screen);
  tri_map(x3,y3,x4,y4,x1,y1,u3,v3,u4,v4,u1,v1,texture,screen);
}



// Left / Right  Spanbuffers
int l_buff_x[1000]; int l_buff_u[1000]; int l_buff_v[1000];
int r_buff_x[1000]; int r_buff_u[1000]; int r_buff_v[1000];
int y_min,y_max;
void fill_scanbuff(int x1,int y1,int x2,int y2,
						 int u1,int v1,int u2,int v2);

void swap_tmf(int *w1,int *w2)
{
	int zw=*w2;
	*w2=*w1;
	*w1=zw;
}


void tri_map(int x1,int y1,int x2,int y2,int x3,int y3,
             int u1,int v1,int u2,int v2,int u3,int v3,
             unsigned int *texture,
             unsigned int *screen)    {

	u32 *scr_temp;
	int p,xp;
	int dx,du,dv;
	int xl,ul,vl,xr,ur,vr;
	int *l_x,*l_u,*l_v,*r_x,*r_u,*r_v;  // Buffer Pointers

	s32 u1616;
	s32 v1616;
	s32 u;
	s32 v;

	y_min=+100000;
	y_max=-100000;
	if (y1<y_min) y_min=y1;
	if (y2<y_min) y_min=y2;
	if (y3<y_min) y_min=y3;

	if (y1>y_max) y_max=y1;
	if (y2>y_max) y_max=y2;
	if (y3>y_max) y_max=y3;


	if ( (y1<CLIP_TOP)&&(y2<CLIP_TOP)&&(y3<CLIP_TOP) )
		return;
		
	if ( (y1>CLIP_BOTTOM)&&(y2>CLIP_BOTTOM)&&(y3>CLIP_BOTTOM) )
		return;

	if(y_min<CLIP_TOP)		y_min = CLIP_TOP;
	if(y_max>CLIP_BOTTOM)	y_max = CLIP_BOTTOM;

	fill_scanbuff(x1,y1,x2,y2,u1,v1,u2,v2);
	fill_scanbuff(x2,y2,x3,y3,u2,v2,u3,v3);
	fill_scanbuff(x3,y3,x1,y1,u3,v3,u1,v1);

	l_x=l_buff_x;
	l_u=l_buff_u;
	l_v=l_buff_v;
	r_x=r_buff_x;
	r_u=r_buff_u;
	r_v=r_buff_v;
	l_x+=y_min;     // Set Buffers to Startline
	l_u+=y_min;
	l_v+=y_min;
	r_x+=y_min;
	r_u+=y_min;
	r_v+=y_min;

	screen+=(y_min*MAX_X);

	for(p=y_min;p<=y_max;p++)
	{
		xl=*l_x++;
		xr=*r_x++; 

		if(xr<xl)
		{
			swap_tmf(&xr,&xl);
			swap_tmf((int*)&l_x,(int*)&r_x);
			swap_tmf((int*)&l_u,(int*)&r_u);
			swap_tmf((int*)&l_v,(int*)&r_v);			
		}

		ul=*l_u++;
		ur=*r_u++;

		vl=*l_v++;
		vr=*r_v++;

		dx=(xr-xl)+1;			// +1 , falls dx=0  !!!
		du=(ur-ul);
		dv=(vr-vl);

		du=((du<<16)/dx);   // 16|16 fixed interpolation
		u1616=(ul<<16);

		dv=((dv<<16)/dx);   // 16|16 fixed interpolation
		v1616=(vl<<16);

		int clip_x;
		if(xl<CLIP_LEFT)
		{
			clip_x = CLIP_LEFT-xl;
			u1616+=(clip_x*du);
			v1616+=(clip_x*dv);
			xl = 0;
			dx-=clip_x;
		}

		if(xr>CLIP_RIGHT)
		{
			clip_x = xr-CLIP_RIGHT;
			dx-=clip_x;
		}

		scr_temp=(screen+xl);

		for (xp=0;xp<dx;xp++)
		{
			u = (u1616>>16)&0x00ff;
			v = (v1616>>16)&0x00ff;
			*scr_temp++ = texture[v*256 + u];
			u1616+=du;
			v1616+=dv;
		}
		screen+=MAX_X;
	}
}


void fill_scanbuff(int x1,int y1,int x2,int y2,
						 int u1,int v1,int u2,int v2)
{
	int *b_x,*b_u,*b_v;
	int d_y;
	int i;
	
	double xd,ud,vd;
	double d_x,d_u,d_v;

	if (y2<y1)
	{
		b_x=l_buff_x;        // write to Left_Buffer
		b_u=l_buff_u;
		b_v=l_buff_v;

		swap_tmf(&x1,&x2);
		swap_tmf(&y1,&y2);
		swap_tmf(&u1,&u2);
		swap_tmf(&v1,&v2);
	}
	else
	{
		b_x=r_buff_x;   	    // write to Right_Buffer
		b_u=r_buff_u;
		b_v=r_buff_v;
	}

	d_y=(y2-y1);

	int clip_top=0;
	int clip_lines=0;
	if(y1<CLIP_TOP)
	{
		clip_top = CLIP_TOP-y1;
		clip_lines+= clip_top;
		y1 = CLIP_TOP;
	}

	if(y2>CLIP_BOTTOM)
	{
		clip_lines+= (y2-CLIP_BOTTOM);
	}

	if (d_y>0)
	{
		d_x=(x2-x1);
		d_u=(u2-u1);
		d_v=(v2-v1);

		b_x+=y1;
		b_u+=y1;
		b_v+=y1;

		xd = x1;
		ud = u1;
		vd = v1;

		double d_y_div = 1.f/d_y;
		d_x*=d_y_div;
		d_u*=d_y_div;
		d_v*=d_y_div;

		// adjust clipping
		d_y-=clip_lines;	// decrease by clipping length
		xd+=d_x*clip_top;
		ud+=d_u*clip_top;
		vd+=d_v*clip_top;

		for(i=0;i<=d_y;i++)
		{
			*b_x++=xd;
			*b_u++=ud;
			*b_v++=vd;
			xd+=d_x;
			ud+=d_u;
			vd+=d_v;
		}
	}
}


