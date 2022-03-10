#define SERIAL  1
#define CONSOLE 2

#define RTS_ON  Offgibit(~0x08)

#define NOCARRIERTO 30

#include <stdio.h>
#include <string.h>
#include <time.h>
#include <stdlib.h>
#include <tos.h>
#include <ext.h>

#include "bink.h"
#include "com_st.h"
#include "externs.h"
#include "msgs.h"

#include "faxascii.h"

#define BLOCKSIZE 	0x1000L
#define HEADERSIZE	0x10
#define RINGTIMEOUT 18

typedef struct
{
	char title[6];
	int version, reserved, page_wid, page_cnt, coding;
} zyxel_header;

zyxel_header m_head;

void build_tables(void);

int carrier;
byte *rec_block;
char ans[82];

char curr_fn[PATH_MAX];
struct date datum;
struct time zeit;

char disc_ans[]={"DISCONNECT"};
int  pages;
char disco_response[80], gpr[40];
char con_str[80];
byte lead_0[256], trail_0[256];

void send_command(char cmd[])
{
	/* Cauxout */
	
	while(Bconstat(SERIAL)) Bconin(SERIAL);

	while(*cmd) Bconout(SERIAL,*cmd++);

	Bconout(SERIAL,ASC_CR);
}

int get_response_quick(char *ans, int to)
{
	int i, rv, fertig, c;
	time_t start;

	fertig=FALSE;
	i=0;
	start=time(NULL);

	while(!fertig)
	{
		if(Bconstat(SERIAL))
		{
			c=(char) Bconin(SERIAL);
			if( ((c==0x0A)&(i>=2)) || (i>=70) )
			{
				rv=fertig=TRUE;
				ans[i]=0;
			}
			else
			{
				if( (c>=0x20) )
					ans[i++]=c;
			}
		}
		else if ((time(NULL)-start)>to)
		{
			fertig=TRUE;
			strcpy(ans,"timeout");
			status_line(msgtxt[M_FAX_DEBUG], ans);
			rv=FALSE;
		}
	}

	return rv;
}

int get_response_quick_ltd(char *ans, int to)
{
	int i, rv, fertig, c;
	time_t start;

	fertig=FALSE;
	i=0;
	start=time(NULL);

	while(!fertig)
	{
		if(Bconstat(SERIAL))
		{
			c=(char) Bconin(SERIAL);
			if( ((c==0x0A)&(i>=2)) || (i>=40) )
			{
				rv=fertig=TRUE;
				ans[i]=0;
			}
			else
            {
				if( (c>=0x20) )
					ans[i++]=c;
			}
		}
		else if ((time(NULL)-start)>to)
		{
			fertig=TRUE;
			strcpy(ans,"timeout");
			status_line(msgtxt[M_FAX_DEBUG], ans);
			rv=FALSE;
		}
	}

	return rv;
}

/* get response, return answer */
int get_resp_ra(char *ans, int to)
{
	int i, rv, fertig, c;
	time_t start;

	fertig=FALSE;
	i=0;
	start=time(NULL);

	while(!fertig)
	{
		if(Bconstat(SERIAL))
		{
			c=(char) Bconin(SERIAL);
			if( ((c==0x0A)&(i>=2)) || (i>=70) )
			{
				rv=fertig=TRUE;
				ans[i]=0;
			}
			else
			{
				if( (c>=0x20) ) ans[i++]=c;
			}
		}
		else if ((time(NULL)-start)>to)
		{
			fertig=TRUE;
			strcpy(ans,"timeout");
			status_line(msgtxt[M_FAX_DEBUG], ans);
			rv=FALSE;
		}
	}

	return rv;
}

void test_for_rec_fax_file(void)
{
	int f;
  
	if((f=open(curr_fn,O_RDONLY))>0)
	{
		close(f);
		curr_fn[strlen(curr_fn)-1]='x';
	}
}

void make_next_name(void)
{
	char pfn[15];

	getdate(&datum);
	gettime(&zeit);
	sprintf(pfn,"FR%02d%02d%02d.F%02d",
			datum.da_mon, datum.da_day, zeit.ti_hour, zeit.ti_min);
	strcpy(curr_fn,fax_inbound);
	strcat(curr_fn,pfn);
	test_for_rec_fax_file();
}

/*
long get_con(void)
{
	carrier= ((*mfp_reg_ptr & 0x02)==0);
	return 0;
}
*/

void receive(int f)
{
	int not_stopped=TRUE;
	byte *lz, c;
	int key, disc_ptr=0;
	int zeros=0, eolns=0, eleven0=FALSE, carrier_da=TRUE;
	size_t count=0;
	time_t noca_time;

	noca_time=time(NULL);
	lz=rec_block;

	while(not_stopped)
	{
		if(Bconstat(SERIAL))
		{
			c=*lz++=(byte) Bconin(SERIAL);
			count++;
			
			if (count==BLOCKSIZE)
			{
				write(f,rec_block,count);
				count=0;
				lz=rec_block;
			}

			if(disc_ans[disc_ptr]==c)
			{
				disc_ptr++;
				
				if(disc_ptr==10) /* DISCONNECT */
				{
                  not_stopped=FALSE;
				}
			}
			else
				disc_ptr=0;

			if( zeros+lead_0[c]>=11 )
				eleven0=TRUE;
			else
			{
				if(c)
				{
					zeros=trail_0[c];
					eolns=0;
                }
				else
					zeros+=trail_0[c];
			}
			
			if( (eleven0) && c)
			{
				eleven0=FALSE;
				eolns++;
				zeros=trail_0[c];
				if(eolns>5)
                {
					status_line(msgtxt[M_FAX_RESULT], pages);
					pages++;
					eolns=0;
					
					if (count) /* gute Zeit den Puffer zu leeren */
					{
						write(f,rec_block,count);
						count=0;
						lz=rec_block;
					}
					
					carrier_da=TRUE;    /* zur Sicherheit */
					
					/* sind noch ein paar Bytes da? */
					while(Bconstat(SERIAL))
					{
						c=*lz++=(byte) Bconin(SERIAL);
					}

					/* N„chste Seite mit DC2 anfordern 
					Bconout(SERIAL, ASC_DC2);
					get_response_quick_ltd(con_str, 4);
					if(!strchr(con_str,'/'))
					{
						Bconout(SERIAL, ASC_DC2);
						get_response_quick_ltd(con_str, 4);
					}
					*/
				}/* ENDIF eop detected   */
			}/* end: mal wieder ein EOL  */
		} /* END es sind Bytes abzuholen */
		else if(Bconstat(CONSOLE))
		{
			key=(int)Bconin(CONSOLE);
			if(key=='h')
			{
				Bconout(SERIAL, ASC_CAN);
				delay(5);
				send_command("ATH");  /* Aufhaengen */
				not_stopped=FALSE;
			}
		}
		else /* sonst nix zu tun */
		{
			carrier = CARRIER;
			/*Supexec(get_con);*/ /* setzt carrier true/false */
			if(carrier)
			{
				noca_time=time(NULL);
				carrier_da=TRUE;    
				/* kann das immer noch schiefgehen ??? */
            }
			else
			{
				if(carrier_da)
				{
					carrier_da=FALSE;
					noca_time=time(NULL);
				}
				else
					if( (time(NULL)-noca_time)>NOCARRIERTO )
						not_stopped=FALSE;
			}
		}
	} /* ende der receive-loop */

	/* DISCONNECT oder Carrier ist weg */
	if(count>12)
		count-=12;
	else
		count=0;

	if (count) /* Rest rausschreiben */
	{
		write(f,rec_block,count);
	}

	get_resp_ra(disco_response, 2); /* rest of disconnect String */

	get_resp_ra(gpr, 3);            /* No carrier */

	status_line(msgtxt[M_FAX_RESULT], pages);
}

void fill_header(void)
{
	int resolution, coding, rec_wid;
	char *pos;

	strcpy(m_head.title,"ZyXEL");
	m_head.version = 2;
	m_head.reserved= 0;

	pos=memchr(con_str,'V',40);
	if (pos)
	{
		pos++; 			/* String is: VnTnRnLnCnPxxxxxxx... */
		resolution=*pos++ & 0x01; /* vertical resolution */
		pos++; 			/* skip "T" */
		coding=*pos++ & 0x01;   	/* coding */
		pos++; 			/* skip "R" */
		rec_wid=*pos++ & 0x03;    /* recording width */
		switch(rec_wid)
		{
			case 1:
				m_head.page_wid=2048;
				break;
				
			case 2:
				m_head.page_wid=2432;
				break;
				
			case 0:
			default:
				m_head.page_wid=1728;
				break;
		}
	}
	else
	{
		m_head.page_wid=1728;
		resolution=0;
		coding=0;
	}

	m_head.page_cnt= pages;
	m_head.coding  = resolution | (coding<<1);
}

void write_header(int out_f)
{
	int i;
	byte *out_ptr;

	out_ptr=rec_block;
 
	for(i=0; i<6; i++)
	{
		*out_ptr++=m_head.title[i];
	}

	*out_ptr++ = m_head.version & 0xFF;
	*out_ptr++ = (m_head.version >> 8);
	*out_ptr++ = m_head.reserved & 0xFF;
	*out_ptr++ = m_head.reserved >> 8;
	*out_ptr++ = m_head.page_wid & 0xFF;
	*out_ptr++ = m_head.page_wid >> 8;
	*out_ptr++ = m_head.page_cnt & 0xFF;
	*out_ptr++ = m_head.page_cnt >> 8;
	*out_ptr++ = m_head.coding & 0xFF;
	*out_ptr++ = m_head.coding >> 8;

	write(out_f,rec_block,HEADERSIZE);
}

int receive_fax(int out_file)
{
	int aborted=FALSE, faxconnect, nocarr;

	/* Faxconnect hat der Mailer schon festgestellt */
	carrier = CARRIER;
	/*Supexec(get_con);*/
    faxconnect=carrier;
	RTS_ON;
	
	if(Bconstat(SERIAL))
	{
		get_response_quick_ltd(con_str, 4);	/* und abholen */
		status_line(msgtxt[M_FAX_DEBUG], con_str);
	}
	
	if(faxconnect)
	{
		nocarr=TRUE;		/* hier verkehrt herum setzen */
							/* den "Rest" des Connect-Strings anfordern */

/*
		Bconout(SERIAL, ASC_DC2);
		get_response_quick_ltd(con_str, 4);
		if(!strchr(con_str,'/'))
		{
			status_line(msgtxt[M_FAX_NOTZYXEL]);
			faxconnect=FALSE;
		}
*/
	}
	else
	{
		status_line(msgtxt[M_FAX_CLOST]);
		nocarr=TRUE;
		faxconnect=FALSE;
	}

	if(!faxconnect && !nocarr) /* try it again */
	{
		get_response_quick(con_str, 4);
		status_line(msgtxt[M_FAX_DEBUG], con_str);
		faxconnect=!strncmp(con_str,"CONNECT FAX",11L);
		nocarr=!(strncmp(con_str,"NO CARRIER",10));
	}
	
	if(!faxconnect && !nocarr) /* and again */
	{
		get_response_quick(con_str, 4);
		status_line(msgtxt[M_FAX_DEBUG], con_str);
		faxconnect=!strncmp(con_str,"CONNECT FAX",11L);
    }

	if(faxconnect)
    {
		pages=1;
		
		fill_header();
		write_header(out_file); /* reserve space for header update */
		receive(out_file);
		/*hang_up();*/
		fill_header();
		
		if(lseek(out_file, 0L, SEEK_SET))
		{
			status_line(msgtxt[M_FAX_UPDATEF]);
        }
		else
			write_header(out_file);
	}
	else
    {
    	status_line(msgtxt[M_FAX_NOCONNECT]);
		aborted=TRUE;
	}
	
	return aborted;
}

int create_and_get(void)
{
	int rv=0, rec_fax_file;

	make_next_name();

	status_line(msgtxt[M_FAX_TRYING], curr_fn);  
	
	if( (rec_fax_file=open(curr_fn,O_WRONLY|O_TRUNC|O_CREAT)) > 0 )
	{
		rv=receive_fax(rec_fax_file);
		close(rec_fax_file);
		if(rv) remove(curr_fn);
	}
	else
	{
		status_line(msgtxt[M_FAX_CREATERROR]);
		rv=-1;
	}
	
	return rv;
}

int fax_recieve(void)
{
	int mrv;
  
	mrv=0;

	build_tables();
	
	if( (rec_block=(byte *)malloc(BLOCKSIZE))==NULL)
	{ 
		status_line(msgtxt[M_FAX_RAMERROR]);
		return 0;
	}

	status_line(msgtxt[M_FAX_STARTED]);
	
	create_and_get();

	status_line(msgtxt[M_FAX_STOPPED]);
	 
	free(rec_block);
	return mrv;
}

/***************  Standard routines **************************************/
void build_tables(void)
{
	int i, j, l0, t0;

	/* ist halt noch ne Initialisierung */  
	/* mfp_reg_ptr=(byte *) 0xFFFA01L; */

	for(i=0;i<256;i++)
	{
		l0=t0=0;
		
		for(j=0;j<8;j++)
			if( !(i & (0x80 >> j)))
				t0++;
			else
				break;
				
		for(j=0;j<8;j++)
			if( !(i & (0x01 << j)))
				l0++;
			else
				break;
        
		lead_0[i]=l0;
		trail_0[i]=t0;
	}
}
