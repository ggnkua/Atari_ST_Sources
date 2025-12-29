#include <vdi.h>

extern int _umr[],handle;

void clip(int x1,int y1,int x2,int y2)
{

	_umr[0]=x1;
	_umr[1]=y1;
	_umr[2]=x2;
	_umr[3]=y2;
	vs_clip(handle,1,_umr);
}

void clip_off(void)
{
	vs_clip(handle,0,_umr);
}