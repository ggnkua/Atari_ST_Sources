#include <aes.h>

typedef  char BYTE;
typedef  long LONG;
typedef  int WORD;

#include "recog.rsh" 

int rk_rsc_init(void)
{ 
	long s;
	int i;
	for(i=0;i<NUM_TI;i++)
	{
	
		s=(long) rs_tedinfo[i].te_ptext;
		rs_tedinfo[i].te_ptext=rs_strings[s];
		s=(long) rs_tedinfo[i].te_ptmplt;
		rs_tedinfo[i].te_ptmplt=rs_strings[s];
		s=(long) rs_tedinfo[i].te_pvalid;
		rs_tedinfo[i].te_pvalid=rs_strings[s];
	}
	for(i=0;i<NUM_OBS;i++)
	{ 
		switch(rs_object[i].ob_type)
		{ 
			case G_TEXT: case G_BOXTEXT:
			case G_FTEXT: case G_FBOXTEXT:
				s=(long)rs_object[i].ob_spec.free_string;
				rs_object[i].ob_spec.tedinfo=&rs_tedinfo[s];
				break;
			case G_BUTTON: case G_STRING: case G_TITLE:
				s=(long)rs_object[i].ob_spec.free_string;
				rs_object[i].ob_spec.free_string=rs_strings[s];
				break;
			default:
				break;
		}
	}
	for(i=0;i<NUM_OBS;i++)
	{  
		rsrc_obfix(&rs_object[i],0);
	}
	return(1);
}

void rk_rsrc_gaddr(int b,OBJECT **o)
{
	switch(b)
	{
		case 0: *o=&rs_object[T0OBJ]; break;
		case 1: *o=&rs_object[T1OBJ]; break;
		case 2: *o=&rs_object[T2OBJ]; break;
		case 3: *o=&rs_object[T3OBJ]; break;
		case 4: *o=&rs_object[T4OBJ]; break;
	}
}
