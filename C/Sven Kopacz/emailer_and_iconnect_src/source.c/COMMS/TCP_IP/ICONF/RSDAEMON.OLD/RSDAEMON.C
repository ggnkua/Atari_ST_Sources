#include <stdio.h>
#include <stdlib.h>
#include <screen.h>
#include <tos.h>
#include <aes.h>
#include <sockinit.h>
#include <rsdaemon.h>
#include <in.h>
#include <inet.h>
#include <netdb.h>

int rs_do(int *pbuf);

int ap_id;

int main(void)
{
	int pbuf[8];
	if (_app)
	{ /* Als Programm gestartet */
		(_GemParBlk.global[0])=0;
		ap_id=appl_init();
		if ( ! (_GemParBlk.global[0]))
		{/* Aus Auto-Ordner gestartet... */
			Cconws("\r\nRSDAEMON.PRG kann nicht aus dem AUTO-Ordner gestartet werden!\r\n");
			Bell();
			return(0);
		}
	}
	else /* Als Accessory gestartet */
	{
		ap_id=appl_init();
		if(ap_id < 0)
			return(0);
	}

	if(sock_init()<0) return(0);

	do
	{
		evnt_mesag(pbuf);
	}while(rs_do(pbuf));

	return(0);
}

int rs_do(int *pbuf)
{
	int			app;
	char		*c;
	hostent	*he;
	ulong		ip;

	if(pbuf[0]==AP_TERM) return(0);
	if(pbuf[0]!=RSDAEMON_MSG) return(1);
	if(pbuf[3]!=RSD_REQUEST_IP) return(1);
	app=pbuf[1];
	pbuf[1]=ap_id;

	c=*((char**)&(pbuf[5]));


	he=gethostbyname(c);
	if(he==NULL)
	{
		pbuf[3]=RSD_IP_UNKNOWN;
		appl_write(app, 16, pbuf);
		return(1);
	}

	if(he->h_addr_list[0]==0)
	{
		pbuf[3]=RSD_IP_UNKNOWN;
		appl_write(app, 16, pbuf);
		return(1);
	}
	
	ip=*(ulong*)(he->h_addr_list[0]);

	pbuf[3]=RSD_IP_FOUND;
	pbuf[5]=(int)(ip>>16);
	pbuf[6]=(int)(ip & 0xffff);	
	appl_write(app, 16, pbuf);

	return(1);
}