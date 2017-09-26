#include <stdio.h>
#include <stdlib.h>
#include <screen.h>
#include <tos.h>
/*#include <aes.h>*/
#include <mt_aes.h>
#include <sockinit.h>
#include <rsdaemon.h>
#include <in.h>
#include <inet.h>
#include <netdb.h>
#include <mt_sock.h>

extern	int set_flag(int bit_nr);
extern	void	clear_flag(int bit_nr);
#define MT_COPY_SEM 0

int rs_do(int *pbuf);
long cdecl rs_thread(int *pbuf);

#define SEMA_NAME 'RsDm'

int ap_id;

int main(void)
{
	int pbuf[8];
	if (_app)
	{ /* Als Programm gestartet */
		(_GemParBlk.global[0])=0;
		ap_id=MT_appl_init(_GemParBlk.global);
		if ( ! (_GemParBlk.global[0]))
		{/* Aus Auto-Ordner gestartet... */
			Cconws("\r\nRSDAEMON.PRG kann nicht aus dem AUTO-Ordner gestartet werden!\r\n");
			Bell();
			return(0);
		}
	}
	else /* Als Accessory gestartet */
	{
		ap_id=MT_appl_init(_GemParBlk.global);
		if(ap_id < 0)
			return(0);
	}

	if(sock_init()<0) return(0);

	do
	{
		MT_evnt_mesag(pbuf, _GemParBlk.global);
	}while(rs_do(pbuf));

	return(0);
}

int rs_do(int *pbuf)
{
	THREADINFO thi;
	
	if((pbuf[0]==AP_TERM) || (pbuf[0]==AP_RESCHG)) return(0);
	if(pbuf[0]!=RSDAEMON_MSG) return(1);
	if(pbuf[3]!=RSD_REQUEST_IP) return(1);

	/* Start a thread */
  thi.proc = (void *) rs_thread; 
  thi.user_stack = NULL; 
  thi.stacksize = 4096L; 
  thi.mode = 0; 
  thi.res1 = 0L; 
	while(!set_flag(MT_COPY_SEM)); /* This sema will by cleared by the Thread */
  MT_shel_write(SHW_THR_CREATE, 1, 0, (char*)&thi, (char*)pbuf, _GemParBlk.global); 
	/* Wait until the thread has copied the pbuf-contents to its own memory */
	while(!set_flag(MT_COPY_SEM));
	clear_flag(MT_COPY_SEM);

	return(1); 
}
	
long cdecl rs_thread(int *in_pbuf)
{/* Get a DNS reply and send answer AES-message to requesting app */
	char		*c;
	hostent	*he;
	int lokal_global[15], pbuf[8];
	int	app, thread_ap_id;

	uchar		buf[1024];
	ulong		ip, *rip[2], dum;
	hostent	host;
	
	/* Copy the pbuf contents to my lokal pbuf, afterwards the main
	   app may continue */
	for(ip=0; ip < 8; ++ip) pbuf[ip]=in_pbuf[ip];
	clear_flag(MT_COPY_SEM);

	/* Init thread with AES */
	thread_ap_id=MT_appl_init(lokal_global);
	
	app=pbuf[1];
	pbuf[1]=thread_ap_id;

	/* Get hostname */
	c=*((char**)&(pbuf[5]));

	he=MT_gethostbyname(c, buf, &dum, &(rip[1]), &host);
	if(he==NULL)
	{
		pbuf[3]=RSD_IP_UNKNOWN;
		MT_appl_write(app, 16, pbuf, lokal_global);
		return(1);
	}

	if(he->h_addr_list[0]==0)
	{
		pbuf[3]=RSD_IP_UNKNOWN;
		MT_appl_write(app, 16, pbuf, lokal_global);
		return(1);
	}
	
	ip=*(ulong*)(he->h_addr_list[0]);

	pbuf[3]=RSD_IP_FOUND;
	pbuf[5]=(int)(ip>>16);
	pbuf[6]=(int)(ip & 0xffff);	
	MT_appl_write(app, 16, pbuf, lokal_global);
	
	MT_appl_exit(lokal_global);
	
	return(0);
}