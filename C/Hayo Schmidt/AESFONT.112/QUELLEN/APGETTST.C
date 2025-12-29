/* appl_getinfo()-Test	*/
/* Hayo Schmidt 1995		*/

#include <aes.h>
#include <vdi.h>
#include <stdio.h>
#include <tos.h>

int gl_apid,
	 handle;
	
int work_in[12],
	 work_out[57];
int back;

int appl_getinfo(int ap_gtype, int *ap_gout1, int *ap_gout2,
										 int *ap_gout3, int *ap_gout4);
										 
appl_xgetinfo(int type,int *out1,int *out2,int *out3,int *out4);

int getcookie(long cookie, long *p_value);

int main(void)
{
	register int i;
	int  a,b,c,d;
	int additional;
	char name[32];
	
	if (appl_init() == -1)
		return gl_apid;
			
	for ( i = 1; i < 10; work_in[i++] = 1 )
		;
	
	work_in[10] = 2;
	work_in[0] = handle = graf_handle(&d,&d,&d,&d); 	
 	v_opnvwk( work_in, &handle, work_out );

	if (appl_find("?AGI\0\0\0\0") >= 0)
		printf("\r\n?AGI eingebaut\r\n");
	else
		printf("\r\n?AGI NICHT eingebaut\r\n");

	back = appl_getinfo(0, &a,&b,&c,&d);
	printf("AES:  return %d   H”he %d   ID %d   Typ %d\r\n",  back,a,b,c);
	back = appl_getinfo(1, &a,&b,&c,&d);
	printf("ICON: return %d   H”he %d   ID %d   Typ %d\r\n",  back,a,b,c);
	for (i = 3; i < 16; i++)
	{
		back = appl_getinfo(i, &a,&b,&c,&d);
		printf("Mode %d: return %d   ap_gout1 %d   ap_gout2 %d   ap_gout3 %d   ap_gout4 %d\r\n", i, back, a, b, c, d);
	}
	while(Cconis() == 0)
		;
	Cconin();

	v_clsvwk(handle);		
	appl_exit();
	
	return 0;
}

int appl_getinfo(int ap_gtype, int *ap_gout1, int *ap_gout2,
										 int *ap_gout3, int *ap_gout4)
{
	AESPB aespb;
	
	aespb.contrl 	= _GemParBlk.contrl;
   aespb.global 	= _GemParBlk.global;
   aespb.intin  	= _GemParBlk.intin;
   aespb.intout 	= _GemParBlk.intout;
   aespb.addrin 	= (int *) _GemParBlk.addrin;
   aespb.addrout	= (int *) _GemParBlk.addrout;
	
	_GemParBlk.contrl[0] = 130;
	_GemParBlk.contrl[1] = 1;
	_GemParBlk.contrl[2] = 5;
	_GemParBlk.contrl[3] = 0;
	_GemParBlk.contrl[4] = 0;
	_GemParBlk.intin[0] = ap_gtype;
	_crystal(&aespb);
	*ap_gout1 = _GemParBlk.intout[1];
	*ap_gout2 = _GemParBlk.intout[2];
	*ap_gout3 = _GemParBlk.intout[3];
	*ap_gout4 = _GemParBlk.intout[4];
	return (_GemParBlk.intout[0]);			
}

appl_xgetinfo(int type,int *out1,int *out2,int *out3,int *out4)
{
    static int has_agi=-1; long cookie;

    if (has_agi<0)
        has_agi=(_GemParBlk.global[0]>=0x400 /* AES 4.0? */
            || (getcookie('MagX',&cookie)
                && ((int **)cookie)[2][24]>=0x200) /* MagiC! 2.0? */
            || appl_find("?AGI")==0); /* "?AGI"? */
    if (has_agi)
        return appl_getinfo(type,out1,out2,out3,out4);
    else
	    return 0;
}

/* -------------------------------------------- */
typedef struct
{
   long cookie_id;            /* Cookie-ID   */
   long cookie_value;         /* Cookie-Wert */
} COOKIE;

int getcookie(long cookie, long *p_value)
{
   /*  Cookie auslesen                          */
   /*  ---------------                          */
   /*  cookie          Kennung                  */
   /*  p_value         Wert programmabh„ngig    */
   /*  max_cookies     Anzahl m”glicher Cookies */
	
	register long usp;
   COOKIE *cookiejar;

   usp = Super(0L);
   cookiejar = (COOKIE *) *((long *) 0x5a0L);
   Super( (void *) usp);
	
   if (cookiejar == 0L)
      return 0;
   else
   {
	   do                                     /* Cookie-Suchschleife  */
      {
         if (cookiejar->cookie_id == cookie)
         {
            if (p_value) /* nur wenn kein Nullpointer */
            	*p_value = cookiejar->cookie_value;
            return 1;
         }
      }
      while (cookiejar++->cookie_id != 0);
   }
   return 0;
}


