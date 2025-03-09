#include <stddef.h>
#include <tos.h>
#include <string.h>
#include <screen.h>
#include "mcdrv1.h"
#include "mc_drvar.h"
#include "cookie.h"
unsigned int make_crc(char *buf,int len);

#define TIMER	((long *) 0x4baL)

#define  anmeldung	0
#define	id_request	1
#define	new_appl		2
#define	err_bell		3
#define	stop			4
#define	start			5
#define	storno		6

#define sync_size 10
#define tok_size  10
#define err_size	10
#define headsize  10

#define taste() Bconin(2)

/* defines for Reader */


/* Hilfsfunktionen */

#define for_me(a)	(a&(1<<my_num))
#define set_bit(b,a) (b|(1<<a))
#define reset_bit(b,a) (b & ~(1<<a))
#define pruef_bit(b,a) (b & (1<<a))


/* Ende Hilfsfunktionen */
/*
void out(const char *zeile,int wert)
{
char str[80];
Cconws(MCTR);
Cconws(" ");
itoa(my_num,str,10);
Cconws(str);
Cconws(" ");
Cconws(zeile);
Cconws(" ");
itoa(wert,str,10);
Cconws(str);
Cconws("\r\n");
}
*/
int	search_bit(int bits)
{
	int i;
	for (i=6;i>=0;i--)
	{
		if (!pruef_bit(bits,i)) return(i);
	}
	return(-1);
}


void	SYNC_RECIEVED(void)
{
int i;
int hlp;
	new_sync=TRUE;
	if (rpacket.an==127)
	{
		rpacket.von='P';
	}
	else
	{
		if (!num_locked)
		{
			my_num=search_bit(rpacket.an);
			rpacket.an=set_bit(rpacket.an,my_num);
			sync_rast=TRUE;
		}
		else
		{
			i=search_bit(rpacket.an);
			if (i!=my_num)
			{
				sync_rast=FALSE;
				hlp=last_sync;
				last_sync=rpacket.an;
			}
			if (i<my_num)
			{
				rpacket.an=(127 & (hlp<<1));
				last_sync=rpacket.an;
			}
			else
			{
				if (i==my_num)
				{
					sync_rast=TRUE;
					rpacket.an=set_bit(rpacket.an,my_num);
					i=my_num;i--;
					while (i>=0)
					{
						rpacket.an=reset_bit(rpacket.an,i--);
					}
				}
			}
		}
	}
	STATE=0;
	rpacket.crc_head=make_crc((char*)&rpacket,8);	
	SENDE(tok_size,(char *)&rpacket); /*weitegeben */
}

void	PRUEF_RECIEVED(void)
{
	switch(STATE)
	{
		case 0:	if (sync_rast)	STATE=1;
					else
					{
						rpacket.von='S';
						rpacket.an=(127 & (last_sync<<1));
						rpacket.size=sync_size;
						STATE=0;
					}
					rpacket.crc_head=make_crc((char*)&rpacket,8);	
					SENDE(tok_size,(char *)&rpacket); /*weitegeben */
					break;
		case 1:	if (my_num==0)
					{
						rpacket.von='T';
						rpacket.size=tok_size;
						rpacket.id=++state.tnum;
						rpacket.crc_head=make_crc((char*)&rpacket,8);	
					}
					SENDE(tok_size,(char *)&rpacket); /*weitegeben */
					break;
		case 2:	rpacket.von='S';
					rpacket.an=0;
					rpacket.size=sync_size;
					STATE=0;
					rpacket.crc_head=make_crc((char*)&rpacket,8);	
					SENDE(sync_size,(char *)&rpacket); /*weitegeben */
					break;
	}
}

void	TOKEN_RECIEVED(void)
{
	switch(STATE)
	{
		case 0:	rpacket.von='S';
					rpacket.an=0;
					rpacket.size=sync_size;
					rpacket.crc_head=make_crc((char*)&rpacket,8);	
					SENDE(tok_size,(char *)&rpacket); /*weitegeben */
					break;
		case 1:	num_locked=TRUE;
					state.tnum=rpacket.id;
					rpacket.size=sync_size;
					STATE=2;
					rpacket.crc_head=make_crc((char*)&rpacket,8);	
					SENDE(tok_size,(char *)&rpacket); /*weitegeben */
					break;
		case 2:	time_out=0;
					if (rpacket.id==state.tnum)
					{
						if (state.s_status==TRUE)
						{
							SENDE(10,(char *)&spacket);
							SENDE(spacket.size-10,spacket.buff);
#ifdef proto_on
							proto_out(spacket.buff,spacket.von, spacket.an,1);
#endif /* proto_on */
						}
						SENDE(tok_size,(char *)&rpacket); /*weitegeben */
					}
					else
					{
						if (my_num!=0)
						{
							state.tnum=rpacket.id;
							SENDE(tok_size,(char *)&rpacket); /*weitegeben */
						}
					}
					break;
	}
}


void	ERROR_RECIEVED(void)
{
	switch(STATE)
	{
		case 0:	rpacket.von='S';
					rpacket.size=sync_size;
					rpacket.an=0;
					rpacket.crc_head=make_crc((char*)&rpacket,8);	
					SENDE(tok_size,(char *)&rpacket); /*weitegeben */
					break;
		case 1:	rpacket.von='S';
					rpacket.size=sync_size;
					rpacket.an=0;
					STATE=0;
					rpacket.crc_head=make_crc((char*)&rpacket,8);	
					SENDE(tok_size,(char *)&rpacket); /*weitegeben */
					break;
		case 2:	if (my_num==0)
					{
						rpacket.von='T';
						rpacket.size=tok_size;
						rpacket.id=(char) ++state.tnum;
						rpacket.crc_head=make_crc((char*)&rpacket,8);	
					}
					SENDE(tok_size,(char *)&rpacket); /*weitegeben */
					break;
	}
}

void rec_error(int err_crc)
{
	clear_buff();
	rpacket.von='E';
	rpacket.an=0;
	rpacket.size=err_size;
	rpacket.crc_head=make_crc((char*)&rpacket,8);	
	SENDE(err_size,(char *)&rpacket); /*senden */
	err_out(TRUE,err_crc);
}


void intern_msg(void)
{
	switch(rpacket.von)
	{
	case 'T':
			TOKEN_RECIEVED();
		break;
	case 'S':
			SYNC_RECIEVED();
		break;
	case 'E':
			ERROR_RECIEVED();
		break;
	case 'P':	/* PRUEF-Message */
			PRUEF_RECIEVED();
	 	break;
	case 'B':  /* BREAK */
		{/* Time_out-Behandlung abschalten 
			READER auf DAUER-FAIL */
			state.broken=TRUE;
			time_out=4;
			SENDE(rpacket.size,(char *)&rpacket); /*weitegeben */
		} /* case 'B' */
		break;
	default:rec_error(FALSE);
	}
}

int my_mail(int *len,char *buff)
{  /* Anfrage oder REPLY */

	XREPLY=TRUE;
	return_wert.as_int=0;

	*len=rpacket.size-10;
	return_wert.as_bits.von=rpacket.von;

	if (lese(*len,buff)) 
	{
		rec_error(FALSE);
		return(RFALSE);
	}

	if (rpacket.crc_data != make_crc(buff,*len)) 
	{
		rec_error(TRUE);
		return(RFALSE);
	}

	err_out(FALSE,FALSE);
				
	if (rpacket.von==my_num)
	{
		XREPLY=FALSE;
		state.s_status=FALSE;
		return_wert.as_bits.doubl=FALSE;
		return_wert.as_bits.reply=TRUE;
#ifdef proto_on
		proto_out(buff,rpacket.von, rpacket.an,2);
#endif /* proto_on */
	}
	else
	{
#ifdef proto_on
		proto_out(buff,rpacket.von, rpacket.an,3);
#endif /* proto_on */
		return_wert.as_bits.doubl=FALSE;
		return_wert.as_bits.reply=FALSE;
		rpacket.an=reset_bit(rpacket.an,my_num);
		if (rpacket.an!=0)
		{ /* Broadcast weitergeben*/
			if (rpacket.an==0x0080) 
			{
				rpacket.size=12;
				rpacket.crc_data=make_crc(buff,2);
			}
			rpacket.crc_head=make_crc((char*)&rpacket,8);	
			SENDE(10,(char *)&rpacket);
			SENDE(rpacket.size-10,buff);
		}
	}
		
	return(return_wert.as_int | RTRUE);
}



int	READER(int *len,char *buff)
{

	/* 1. lesen eines Blocks */
	XREPLY=FALSE;
	if (fil_request())
	{ /* Bytes im Buffer */
		last_msg=*TIMER;
		state.broken=FALSE;
		if (lese(10,(char *)&rpacket))
		{ /* fehlerbehandlung */
			rec_error(FALSE);
			return(RFALSE);
		}
		/* 10 Bytes sind da oder Fehler */
		if (rpacket.crc_head!=make_crc((char*)&rpacket,8))
		{
			rec_error(TRUE);
			return(RFALSE);
		}
		if (rpacket.size==10)
		{	/* Sonderpakete */
			intern_msg();
			err_out(FALSE,FALSE);
			return(RFALSE);
		} /* ende Sonderpakete */
		else
		{
			if (for_me(rpacket.an) || (rpacket.von==my_num))
				return(my_mail(len,buff));
			else
			{
				*len=rpacket.size-10;
				if (lese(*len,buff)) 
				{
					rec_error(FALSE);
					return(RFALSE);
				}
				err_out(FALSE,FALSE);
#ifdef proto_on
		        proto_out(buff,rpacket.von, rpacket.an,5);
#endif /* proto_on */
				SENDE(headsize,(char *) &rpacket);
				SENDE(*len,buff);
				return(RFALSE);
			}
		}
	}
	else
	{
		if (((*TIMER-last_msg)>1200) && (num_locked) )
		{
			last_msg=*TIMER;
			
			if (!state.broken)
			{time_out++;
             if (state.s_status)
             {	
             	time_out=1;
#ifdef proto_on
	        	proto_out(spacket.buff,spacket.von, spacket.an,6);
#endif /* proto_on */
	         }
			 if (my_num==0) 
			 {
			  rec_error(FALSE);
			 }
			}
		}
		if (time_out>3) return(RFAIL);
	}
	return(RFALSE);
}

int reciever_anz(int an) 
{
	register i=0,j=0;
	for (i=0;i<7;i++) 
		if (pruef_bit(an,i)) j++;
	return(j);
}

int	SENDER(int an,int LEN,char *buff)
{
#ifdef proto_on
	proto_out(buff,my_num,an,0);
	if (state.s_status==TRUE)
	{
		Cconws("MIDI_COM ERROR !!!!\r\n");
		Cconws("NEUE SENDUNG UEBERSCHREIBT Vorhandene\r\n");
		Bconstat(2);
		return(FAIL);
	}
	if (LEN>4400)
	{
		Cconws("MIDI_COM ERROR !!!!\r\n");
		Cconws("UNSINNIGE SENDEGR™SSE\r\n");
		Bconstat(2);
		return(FAIL);
	}
#endif /* proto_on */
	if (reciever_anz(an)==1)
		spacket.an=an;
	else 	spacket.an=set_bit(an,7); /* Broadcast-Flag */
	spacket.an &= 0x00FF;
	spacket.size=LEN+10;
	spacket.crc_data=make_crc(buff,LEN);
	spacket.von=(char)my_num;
	memcpy(spacket.buff,buff,(long)LEN);
	spacket.crc_head=make_crc((char*)&spacket,8);	
	return(state.s_status=TRUE);
}

int	REPLY(int LEN,char *buff)
{
#ifdef proto_on
	if (LEN>4500)
	{
		Cconws("MIDI_COM ERROR !!!!\r\n");
		Cconws("REPLY zu GROSS !!!!\r\n");
		Cconws("BITTE HIER BOOTEN\r\n");
		Bconstat(2);
	}
	if (! XREPLY)
	{
		Cconws("MIDI_COM ERROR !!!!\r\n");
		Cconws(">>>>>>>>>>>UNDEFINIERTER REPLY !!!!\r\n");
		Cconws("BITTE HIER BOOTEN\r\n");
		Bconstat(2);
	}
#endif /* proto_on */
	rpacket.an=0;
	rpacket.size=LEN+10;
	rpacket.crc_data=make_crc(buff,LEN);
	rpacket.crc_head=make_crc((char*)&rpacket,8);	
#ifdef proto_on
	proto_out(buff,rpacket.von, rpacket.an,4);
#endif /* proto_on */
	SENDE(headsize,(char *) &rpacket);
	SENDE(LEN,buff);
	return(0);
}

/* Commandshell */
int	CMD(int cmd,int *par1,int *par2)
{
	switch (cmd)
	{
	case	anmeldung : AES_install();
							clear_buff();
							my_num=7;
							STATE=0;
							num_locked=FALSE;
							new_sync=FALSE;
							time_out=4;
							rpacket.von='S';
							rpacket.an=0;
							rpacket.size=sync_size;
							rpacket.crc_head=make_crc((char*)&rpacket,8);	
							SENDE(sync_size,(char *) &rpacket);
							return(0);
	case	new_appl:	if (new_sync)
							{ 
								new_sync=FALSE;
							  	return(TRUE);
							}
							else
							return(FALSE);
	case	err_bell:	set_errbell(par1);
							return(0);
	case	id_request: if (num_locked) return(my_num);
								else return(FAIL);
	case	stop:			state.broken=TRUE;
							clear_buff();
							rpacket.von='B';
							rpacket.an=-1;
							rpacket.size=sync_size;
							rpacket.crc_head=make_crc((char*)&rpacket,8);	
							SENDE(sync_size,(char *) &rpacket);
							if (num_locked && (time_out<=3))
							{
								do {state.broken=TRUE;} while (!fil_request());
							}
							clear_buff();
							time_out=4;
							break;
	case	start:		state.broken=FALSE;
							time_out=0;
							rec_error(FALSE);
							break;
	case	storno:		state.s_status=FALSE;
							break;
	default:		return(-15);
	}
	return(0);
}
/* ende Commandshell */

/* Cookie-Teil */
static long install_cookies(void)
{
	COOKIE  *cokie;
	long	found=0;
	int		i=16;
		
	cokie=*CJAR;
	if (!cokie)
	{
		*CJAR=cokie=Malloc(i*8);
		if (cokie)
		{
			cokie->tag.aslong = 0;
			cokie->value=i;
		}
	}
	if (cokie) 
	{
		while (cokie->tag.aslong != 0) 
		{
			if (!strncmp(cokie->tag.aschar, MCTR,4))
			{
				cokie->value=(long)&port;
				found=1;
			}
			cokie++;
		}
		if (!found)
		{
			strncpy(cokie->tag.aschar,MCTR,4);
			found=cokie->value;
			cokie->value=(long) &port;
			cokie++;
			cokie->tag.aslong = 0; 
			cokie->value=found; 
		}
		return(0);
	}
	return(FAIL);
}

/* ende COOKIES */

long premiere(void)
{
	do_install();
	(void)install_cookies();
	last_msg=*TIMER;
	return(0);
}

void main(void)
{
	Cconws("Schnittstellentreiber\r\n");
	Cconws("     --MIDI--\r\n");
	Cconws("  fr MIDI_COM.ACC\r\n");
	(void)Supexec(premiere);
	Ptermres(256L + BP->p_tlen + BP->p_dlen + BP->p_blen, 0);
}
