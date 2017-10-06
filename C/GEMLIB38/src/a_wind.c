/*
 * Aes window library interface
 *
 * ++jrb bammi@cadence.com
 * modified: mj -- ntomczak@vm.ucs.ualberta.ca
 * modified: cf -- felsch@tu-harburg.de
 */
#include "gem.h"


int wind_calc(int Type, int Parts, int InX,  int InY, int InW, int InH, int *OutX, int *OutY, int *OutW, int *OutH)
{
	aes_intin[0] = Type;
	aes_intin[1] = Parts;
	aes_intin[2] = InX;
	aes_intin[3] = InY;
	aes_intin[4] = InW;
	aes_intin[5] = InH;
   aes_control[0] = 108;
   aes_control[1] = 6;
   aes_control[2] = 5;
   aes_control[3] = 0;
   aes_control[4] = 0;
   aes(&aes_params);
	*OutX = aes_intout[1];
	*OutY = aes_intout[2];
	*OutW = aes_intout[3];
	*OutH = aes_intout[4];
	return aes_intout[0];
}


int wind_close(int WindowHandle)
{
	aes_intin[0] = WindowHandle;
   aes_control[0] = 102;
   aes_control[1] = 1;
   aes_control[2] = 1;
   aes_control[3] = 0;
   aes_control[4] = 0;
   aes(&aes_params);
	return aes_intout[0];
}


int wind_create(int Parts, int Wx, int Wy, int Ww, int Wh)
{
	aes_intin[0] = Parts;
	aes_intin[1] = Wx;
	aes_intin[2] = Wy;
	aes_intin[3] = Ww;
	aes_intin[4] = Wh;
   aes_control[0] = 100;
   aes_control[1] = 5;
   aes_control[2] = 1;
   aes_control[3] = 0;
   aes_control[4] = 0;
   aes(&aes_params);
	return aes_intout[0];
}


int wind_delete(int WindowHandle)
{
	aes_intin[0] = WindowHandle;
   aes_control[0] = 103;
   aes_control[1] = 1;
   aes_control[2] = 1;
   aes_control[3] = 0;
   aes_control[4] = 0;
   aes(&aes_params);
	return aes_intout[0];
}


int wind_find(int X, int Y)
{
	aes_intin[0] = X;
	aes_intin[1] = Y;
   aes_control[0] = 106;
   aes_control[1] = 2;
   aes_control[2] = 1;
   aes_control[3] = 0;
   aes_control[4] = 0;
   aes(&aes_params);
	return aes_intout[0];
}


int wind_get(int WindowHandle, int What, int *W1, int *W2, int *W3, int *W4)
{
	aes_intin[0] = WindowHandle;
	aes_intin[1] = What;
	if(What == WF_DCOLOR || What == WF_COLOR)
		aes_intin[2] = *W1;
   aes_control[0] = 104;
   aes_control[1] = 2;
   aes_control[2] = 5;
   aes_control[3] = 0;
   aes_control[4] = 0;
   aes(&aes_params);
	*W1 = aes_intout[1];
	*W2 = aes_intout[2];
	*W3 = aes_intout[3];
	*W4 = aes_intout[4];
	return aes_intout[0];
}


void wind_new(void)
{
   aes_control[0] = 109;
   aes_control[1] = 0;
   aes_control[2] = 0;
   aes_control[3] = 0;
   aes_control[4] = 0;
   aes(&aes_params);
}	


int wind_open(int WindowHandle, int Wx, int Wy, int Ww, int Wh)
{
	aes_intin[0] = WindowHandle;
	aes_intin[1] = Wx;
	aes_intin[2] = Wy;
	aes_intin[3] = Ww;
	aes_intin[4] = Wh;
   aes_control[0] = 101;
   aes_control[1] = 5;
   aes_control[2] = 1;
   aes_control[3] = 0;
   aes_control[4] = 0;
   aes(&aes_params);
	return aes_intout[0];
}


int wind_set(int WindowHandle, int What, int W1, int W2, int W3, int W4)
{
	aes_intin[0] = WindowHandle;
	aes_intin[1] = What;

#ifdef __MSHORT__
	aes_intin[2] = W1;
	aes_intin[3] = W2;
	aes_intin[4] = W3;
	aes_intin[5] = W4;
#else
	/* for 32 bit ints stuff the address into aes_intin[2] and [3] */
	switch(What)
	{
		case WF_NAME: 
		case WF_INFO: 
		case WF_NEWDESK:
			{ 
				unsigned short *s = (unsigned short *)&W1;
				aes_intin[2] = s[0];
				aes_intin[3] = s[1];
				if(What == WF_NEWDESK)
					aes_intin[4] = W2;
			}
			break;
		default:
			aes_intin[2] = W1;
			aes_intin[3] = W2;
			aes_intin[4] = W3;
			aes_intin[5] = W4;
	}
#endif

   aes_control[0] = 105;
   aes_control[1] = 6;
   aes_control[2] = 1;
   aes_control[3] = 0;
   aes_control[4] = 0;
   aes(&aes_params);
	return aes_intout[0];
}


int wind_update(int Code)
{
	aes_intin[0] = Code;
   aes_control[0] = 107;
   aes_control[1] = 1;
   aes_control[2] = 1;
   aes_control[3] = 0;
   aes_control[4] = 0;
   aes(&aes_params);
	return aes_intout[0];
}


/*
 * Some usefull extensions.
*/
int wind_calc_grect(int Type, int Parts, GRECT *In, GRECT *Out)
{
	aes_intin[0] = Type;
	aes_intin[1] = Parts;
	aes_intin[2] = In->g_x;
	aes_intin[3] = In->g_y;
	aes_intin[4] = In->g_w;
	aes_intin[5] = In->g_h;
   aes_control[0] = 108;
   aes_control[1] = 6;
   aes_control[2] = 5;
   aes_control[3] = 0;
   aes_control[4] = 0;
   aes(&aes_params);
	Out->g_x = aes_intout[1];
	Out->g_y = aes_intout[2];
	Out->g_w = aes_intout[3];
	Out->g_h = aes_intout[4];
	return aes_intout[0];
}


int wind_create_grect(int Parts, GRECT *r)
{
	aes_intin[0] = Parts;
	aes_intin[1] = r->g_x;
	aes_intin[2] = r->g_y;
	aes_intin[3] = r->g_w;
	aes_intin[4] = r->g_h;
   aes_control[0] = 100;
   aes_control[1] = 5;
   aes_control[2] = 1;
   aes_control[3] = 0;
   aes_control[4] = 0;
   aes(&aes_params);
	return aes_intout[0];
}


void wind_get_grect(int WindowHandle, int What, GRECT *r)
{
	aes_intin[0] = WindowHandle;
	aes_intin[1] = What;
   aes_control[0] = 104;
   aes_control[1] = 2;
   aes_control[2] = 5;
   aes_control[3] = 0;
   aes_control[4] = 0;
   aes(&aes_params);
	r->g_x = aes_intout[1];
	r->g_y = aes_intout[2];
	r->g_w = aes_intout[3];
	r->g_h = aes_intout[4];
}


int wind_open_grect(int WindowHandle, GRECT *r)
{
	aes_intin[0] = WindowHandle;
	aes_intin[1] = r->g_x;
	aes_intin[2] = r->g_y;
	aes_intin[3] = r->g_w;
	aes_intin[4] = r->g_h;
   aes_control[0] = 101;
   aes_control[1] = 5;
   aes_control[2] = 1;
   aes_control[3] = 0;
   aes_control[4] = 0;
   aes(&aes_params);
	return aes_intout[0];
}


void wind_set_grect(int WindowHandle, int What, GRECT *r)
{
	aes_intin[0] = WindowHandle;
	aes_intin[1] = What;
	aes_intin[2] = r->g_x;
	aes_intin[3] = r->g_y;
	aes_intin[4] = r->g_w;
	aes_intin[5] = r->g_h;
   aes_control[0] = 105;
   aes_control[1] = 6;
   aes_control[2] = 1;
   aes_control[3] = 0;
   aes_control[4] = 0;
   aes(&aes_params);
}


void wind_set_str(int WindowHandle, int What, char *str)
{
	unsigned short *s = (unsigned short *)&str;

	aes_intin[0] = WindowHandle;
	aes_intin[1] = What;
	aes_intin[2] = s[0];
	aes_intin[3] = s[1];
   aes_control[0] = 105;
   aes_control[1] = 6;
   aes_control[2] = 1;
   aes_control[3] = 0;
   aes_control[4] = 0;
   aes(&aes_params);
}
