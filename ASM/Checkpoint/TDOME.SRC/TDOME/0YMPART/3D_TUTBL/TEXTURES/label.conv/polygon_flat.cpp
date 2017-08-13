
#include "main.h"

#include "display.h"

#include "polygon_flat.h"

int ymin,ymax;

int leftSpan[2048];
int rightSpan[2048];


#define swapInt(a,b) a^=b; b^=a; a^=b;


/*
int calc_span(int x0,int y0,int x1,int y1)
{
	int *span;
	int length;
	int dx;

	if(y0<ymin) ymin=y0;	if(y0>ymax) ymax=y0;
	if(y1<ymin) ymin=y1;	if(y1>ymax) ymax=y1;


	if(y0==y1)
		return 0;


	if(y0>y1)
	{
		span=leftSpan;
		swapInt(x0,x1);
		swapInt(y0,y1);
		//printf("\nleft");  printf("%i %i    %i %i",x0,y0, x1,y1);
	}
	else
	{
		span=rightSpan;
	}

	span+=y0;

	length=(y1-y0);
	
	dx=x1-x0;
	dx<<=12;
	x0<<=12;
	x0+=(1<<11);	// + 0.5

	if(length)
	{
		dx/=length;
	}

	length++;
	do
	{
		*span++=(x0>>12);
		x0+=dx;
	}while(--length);

	return 0;
}
*/

int calc_span(int x0,int y0,int x1,int y1)
{
	int *span;
	int length;

	double dx,dl,xx;
	double adjust_right=0;

	if(y0<ymin) ymin=y0;	if(y0>ymax) ymax=y0;
	if(y1<ymin) ymin=y1;	if(y1>ymax) ymax=y1;

	if(y0>y1)
	{
		span=leftSpan;
		swapInt(x0,x1);
		swapInt(y0,y1);
	}
	else
	{
		span=rightSpan;
		adjust_right=0.5f;
	}

	span+=y0;

	length=(y1-y0);
	if(length==0) return 0;
	
	dl = length;

	dx = (x1-x0);
	dx = dx/(dl);

	xx = x0;

//	length++;

	do
	{
		*span++=(int)xx;;
		xx+=dx;
	}while(--length);

	return 0;
}




int polygon_flat(double xd0,double yd0,
				 double xd1,double yd1,
				 double xd2,double yd2,
				 u32 color_in)
{
	int x0,y0,x1,y1,x2,y2;
	int *leftS,*rightS;
	u32 *frameBuffer;
	u32 color = color_in;

	int length;

	int t;

	x0=(int)(xd0);
	y0=(int)(yd0);
	x1=(int)(xd1);
	y1=(int)(yd1);
	x2=(int)(xd2);
	y2=(int)(yd2);

	
	ymin =  65536;
	ymax = -ymin;

	/*
	if(y1<ymin) ymin=y1;	if(y1>ymax) ymax=y1;
	if(y2<ymin) ymin=y2;	if(y2>ymax) ymax=y2;
	*/

	//printf("\n%i %i    %i %i    %i %i",x0,y0, x1,y1, x2,y2);

	calc_span(x0,y0,x1,y1);
	calc_span(x1,y1,x2,y2);
	calc_span(x2,y2,x0,y0);


	if(ymin>ymax)
	{
		ymin=ymin;
	}


	length=ymax-ymin;
	if(length==0) return 0;	//<---- SO IST'S RICHTIG!!!

	if( leftSpan[ymin+length/2] < rightSpan[ymin+length/2] )
	{
		leftS =leftSpan;
		rightS=rightSpan;
	}
	else
	{
		leftS =rightSpan;
		rightS=leftSpan;
	}


	do
	{
		x0=leftS[ymin];
		x1=rightS[ymin];

		if(x0>x1)
		{
			t=x0;
			x0=x1;
			x1=t;
		}

		frameBuffer=rgbBuffer[ymin];
		frameBuffer+=x0;

		x1=x1-x0;
		x1++;
		if(x1>=0)
		{
			do
				*frameBuffer++=color;
			while(--x1);
		}
		ymin++;
	}while(--length);

	return 0;
}

/*
int draw_Polygon_n_vertices(Polygon_2D *p)
{
	int i;
	int x0,y0,x1,y1,x2,y2;
	int *leftS,*rightS;

	u32 *frameBuffer;
	u32 *polygonIndexBufferPtr;

	u32 color = p->color;

	int length;
	int t;

	static int counter=0;
	counter = counter;

	ymin =  65536;
	ymax = -ymin;

	// caclulate spans
	for(i=0;i<(p->amount_vertices-1);i++)
	{
		calc_span( p->xt[i],p->yt[i], p->xt[i+1],p->yt[i+1] );
	}
	i=p->amount_vertices - 1;
	calc_span( p->xt[i],p->yt[i], p->xt[0],p->yt[0] );

	if(ymin>ymax)
	{
		ymin=ymin;
	}
	//-------------------------------------------------------------------

	length=ymax-ymin;
	if(length==0) return 0;	//<---- SO IST'S RICHTIG!!!

	if( leftSpan[ymin+length/2] < rightSpan[ymin+length/2] )
	{
		leftS =leftSpan;
		rightS=rightSpan;
	}
	else
	{
		leftS =rightSpan;
		rightS=leftSpan;
	}

//length++;	//<---BUG!!!
	do
	{
		x0=leftS[ymin];
		x1=rightS[ymin];

		if(x0>x1)
		{
			t=x0;
			x0=x1;
			x1=t;
		}

		frameBuffer = rgbBuffer[ymin];
		frameBuffer+=x0;

		polygonIndexBufferPtr = polygonIndexBuffer[ymin];
		polygonIndexBufferPtr+= x0;

		x1=x1-x0;
		x1++;
		if(x1>=0)
		{
			do
			{
				*frameBuffer++=color;
				*polygonIndexBufferPtr++ = current_polygon_index;
			}
			while(--x1);
		}
		ymin++;
	}while(--length);

	counter++;

	return 0;
}
*/
