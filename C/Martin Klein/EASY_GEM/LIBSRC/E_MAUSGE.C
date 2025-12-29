#include <aes.h>

int maus_get(int *x,int *y)
{
	int ret,dum;
	
	evnt_button(1,0,0,x,y,&ret,&dum);
	return ret;
}

int mausxy(int *x,int *y)
{
	int ret,dum;
	
	evnt_button(1,3,1,x,y,&ret,&dum);
	return ret;
}