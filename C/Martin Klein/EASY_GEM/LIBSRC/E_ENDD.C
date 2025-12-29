#include <vdi.h>
#include <easy_gem.h>

extern int handle;

void ende_dia()
{
	int t;
	maus_aus();
	for(t=0;t<=399;t+=2)
	{
		vsl_color(handle,1);
		line(t,0,0,t);
		vsl_color(handle,0);
		line(639,398-t,638-t,399);
	}
	for(t=400;t<=639;t+=2)
	{
		vsl_color(handle,1);
		line(t,0,t-399,399);
		vsl_color(handle,0);
		line(638-t,399,1037-t,0);
	}
	for(t=1;t<=399;t+=2)
	{
		vsl_color(handle,1);
		line(639,t,240+t,399);
		vsl_color(handle,0);
		line(400-t,0,0,400-t);		
	}
	vsl_color(handle,1);
	maus_an();
}
