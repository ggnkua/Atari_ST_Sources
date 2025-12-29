#include <tos.h>

int random(int von,int bis)
{
	int zufall,bereich;
	
	bereich=bis-von+1;
	zufall=(int)Random();
	if(zufall<0)zufall*=-1;
	zufall%=bereich;
	return zufall+von;
}
