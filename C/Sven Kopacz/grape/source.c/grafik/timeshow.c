#include <grape_h.h>
#include "grape.h"
#include "mforms.h"
#include "timeshow.h"

MFORM *tms[]={&T1,&T2,&T3,&T4,&T5,&T6,&T7,&T8,&T9,&TA,&TB,&TC,&TD,&TE,&TF,&TG,&TH};

void timeshow(long so_far, long total)
{
	static int last_set=-1;
	double of, m;

	if(so_far==-1)
	{
		last_set=-1;
		graf_mouse(ARROW,NULL);
		return;
	}
	
	of=(double)((double)so_far/(double)total);
	m=17*of;
	if(m<0)m=0;
	if(m>16)m=16;
	if((int)m != last_set)
	{
		graf_mouse(USER_DEF, tms[(int)m]);
		last_set=(int)m;
	}
}

void timeoff(void)
{
	timeshow(-1,-1);
}