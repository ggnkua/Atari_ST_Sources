/*#define debug*/
#define iodebug

#include <stdio.h>
#include <stdlib.h>
#include <tos.h>
#include <atarierr.h>
#include <sockerr.h>
#include <lowlevel.h>

#include "network.h"
#include "slip.h"
#define	S_END	192
#define	S_ESC	219
#define S_ESC_END 220
#define S_ESC_ESC 221

#define ADD_BLOCK 2048
/* Max. tries when Fwrite(ser.port) returns 0 */
#define MAX_NULL_TRY 50

extern void timer_malloc(void);
extern void check_malloc(void);

void		ip_in(uchar	*buf, uint len);


uchar		*in_buf=NULL;
slip_buf *out_buf=NULL;
uint		in_len=0, last_esc=0;

int	slip_send(uchar	*buf, uint	len)
{ /* Send len bytes of buffer buf on Serial Line via Slip */
	slip_buf **prev, *sb;
	uchar	*sbuf, *mbuf;
	uint	len2, blen=len;
	
#ifdef iodebug
if(db_handle > -1)
	Dftext("[SLIP getting send buf]\r\n");
#endif

	if(low_ready() != E_OK) 
	{
#ifdef iodebug
if(db_handle > -1)
	Dftext("[SLIP send dropping - port closed]\r\n");
#endif
		return(ENETDOWN);
	}
	
#ifdef iodebug
if(db_handle > -1)
	Dftext("[SLIP send getting memory]\r\n");
#endif
	mbuf=sbuf=tmalloc(len*2+2);
	if(!sbuf)
	{
#ifdef iodebug
if(db_handle > -1)
	Dftext("[SLIP send dropping - no memory]\r\n");
#endif
		return(ENSMEM);
	}
	*sbuf++=S_END;
	len2=1;
	
	while(len--)
	{
		*sbuf=*buf++;
		switch(*sbuf)
		{
			case S_END:
				*sbuf++=S_ESC; ++len2;
				*sbuf=S_ESC_END;
			break;
			case S_ESC:
				*sbuf++=S_ESC; ++len2;
				*sbuf=S_ESC_ESC;
			break;
		}
		++sbuf;
		++len2;
	}
	*sbuf=S_END; ++len2;
	sbuf=mbuf;
	
	/* Cat to outgoing queue */
#ifdef iodebug
if(db_handle > -1)
	Dftext("[SLIP send queueing...");
#endif
	while(!set_flag(SLIP_SEM))
	{/* A user process could be waiting here or the kernel-server,
			if an incoming TCP-segment is answered immediately.
			Thus we have to perform the timer_malloc to prevent a
			deadlock.
			 */
			check_malloc();
	}
	
	;
#ifdef iodebug
if(db_handle > -1)
	Dftext("ok]\r\n");
#endif
	prev=&out_buf;
	while(*prev)
		prev=&((*prev)->next);
#ifdef iodebug
if(db_handle > -1)
	Dftext("[SLIP send getting queue-memory...");
#endif
	*prev=sb=(slip_buf*)tmalloc(len2);
#ifdef iodebug
if(db_handle > -1)
	Dftext("ok]\r\n");
#endif
	if(sb==NULL)
	{
#ifdef iodebug
if(db_handle > -1)
	Dftext("[SLIP send dropping - no queue memory...");
#endif
		clear_flag(SLIP_SEM);
		ifree(mbuf);
#ifdef iodebug
if(db_handle > -1)
	Dftext("ok]\r\n");
#endif
		return(ENSMEM);
	}
	/* Fill buffer-data */
	sb->next=NULL;
	sb->len=len2;
	sb->buf=mbuf;
	clear_flag(SLIP_SEM);
	return(blen);
}

void slip_out(void)
{/* Why is the output performed via a timed queue?
		Well, going from a users "send"-call to slip_out (via tcp_send
		and ip_send) would result in the user-process using the
		port_handle for output on the serial line. Since he didn't
		open it, he should not use it. */
		
/* Transmit first buffer from outgoing queue */
	uint	len;
	int		ioutlen, null_try=0;
	long	outlen;
	uchar	*buf;
	slip_buf	*sb, *memo;
	
	if(out_buf==NULL)
		return;	/* Nothing to send */

#ifdef iodebug
if(db_handle > -1)
	Dftext("[Slip out starting...");
#endif
	while(!set_flag(SLIP_SEM)) timer_malloc();
#ifdef iodebug
if(db_handle > -1)
	Dftext("ok]\r\n");
#endif
	buf=out_buf->buf;
	len=out_buf->len;

if(db_handle > -1)
{
	Dftext("[SLIP-Output ");
	Dfnumber(len);
	Dftext(" Bytes...");
}
	do
	{
		outlen=low_write(len, buf);
		ioutlen=(int)outlen;
		if(outlen==0)
		{
			timer_malloc();		/* Do something while waiting */
			++null_try;
			if(null_try >= MAX_NULL_TRY)
			{
if(db_handle > -1)
	Dftext("0-write, aborting]\r\n");
				clear_flag(SLIP_SEM);
				return;
			}
		}
		if(outlen < 0)	/* Error on Fwrite, try again on next timer */
		{
if(db_handle > -1)
{
	Dftext("error ");
	Dfnumber(outlen);
	Dftext("]\r\n");
}
			clear_flag(SLIP_SEM);
			return;
		}
		len-=ioutlen;
		buf+=ioutlen;
	}while(len > 0);

if(db_handle > -1)
{
	Dftext("ok]\r\n");
}
	
	/* All sent, delete buffer */
	buf=out_buf->buf;
	sb=out_buf->next;
	memo=out_buf;
	out_buf=sb;
	clear_flag(SLIP_SEM);
	ifree(buf);
	ifree(memo);
}

int	slip_recv(uchar	*buf, uint len)
{ /* Receive from Serial Line via Slip and put in buffer
		 buf until END encountered or len bytes reached */
	
	uint	recv;
	uchar	c;
	long	fres;
	
	if(low_ready() != E_OK) return(ENETDOWN);

	recv=0;
	while(1)
	{
		fres=0;
		do
		{	fres=low_read(1, &c);	}
		while(fres == 0);
	
		if(fres < 0) return((int)fres);
	
		switch(c)
		{
			case S_END:
				if(recv > 0) return(recv);
			break;
			case S_ESC:
				fres=0;
				do
				{ fres=low_read(1, &c); }
				while(fres == 0);
				if(fres < 0) return((int)fres);
				switch(c)
				{
					case S_ESC_END:
						c=S_END;
					break;
					case S_ESC_ESC:
						c=S_ESC;
					break;
				}
			/* No break here->fall into default */
			default:
				if(recv < len)
					buf[recv++]=c;
				else
					return(EMSGSIZE);
			break;
		}
	}
}

void slip_in(uchar *buf, uint len)
{
	uchar	c, *temp;

	static int	bufsiz;
		
	if(!in_buf)
	{ 
		in_buf=imalloc(len+ADD_BLOCK);
		if(!in_buf) return;
		bufsiz=len+ADD_BLOCK;
	}
	else
	{
		if(in_len+len > bufsiz)
		{
			temp=imalloc(in_len+len+ADD_BLOCK);
			if(!temp) return;
			block_copy(temp, in_buf, in_len);
			ifree(in_buf);
			in_buf=temp;
			bufsiz=in_len+len+ADD_BLOCK;
		}
	}

if(db_handle > -1)
{
	Dftext("[SLIP processing ");
	Dfnumber(len);
	Dftext(" incoming Bytes]\r\n");
}
	while(len--)
	{
		c=in_buf[in_len++]=*buf++;
		if(last_esc)
		{
			if(c==S_ESC_END) in_buf[in_len-1]=S_END;
			if(c==S_ESC_ESC) in_buf[in_len-1]=S_ESC;
		}

		if(c==S_ESC)
			{last_esc=1;	--in_len;}
		else
			last_esc=0;

		if(c==S_END)
		{
			--in_len;
			if(in_len)
			{
if(db_handle > -1)
{
	Dftext("[SLIP passing ");
	Dfnumber(in_len);
	Dftext(" Bytes to IP]\r\n");
}


				ip_in(in_buf, in_len);
				ifree(in_buf);
				if(len)
				{	in_buf=imalloc(len+ADD_BLOCK);
					bufsiz=len+ADD_BLOCK;
				}
				else
					in_buf=NULL;
				in_len=0;
			}
		}
	}
}

void slip_timer_jobs(void)
{/* Poll serial Line */
	static	uchar	buf[1024];
	static	long	ierr;

	if(low_ready() != E_OK) return;

	/* Send pending buffers */
	slip_out();

	ierr=low_read(1024, buf);
		if(ierr <= 0) 
		{
	
if((ierr<0)&&(db_handle > -1))
{
	Dftext("[SLIP error ");
	Dfnumber(ierr);
	Dftext(" reading from port]\r\n");
}
			return;
		}
		
if(db_handle > -1)
{
	Dftext("[SLIP read ");
	Dfnumber(ierr);
	Dftext(" Bytes from port]\r\n");
}
		
	slip_in(buf, (uint)ierr);
	
}

void slip_abort(void)
{
	/* Try to send all remaining buffers */
	/* Especially those TCP-reset that were initiated by
	   tcp_abort()! */
	int 			retry=0;
	slip_buf 	old_first, *sb;
	
	while(out_buf != NULL)
	{
		old_first=*out_buf;
		slip_out();
		iwait(ABORT_FREQ);
		if((old_first.len==out_buf->len)&&(old_first.buf==out_buf->buf))
		{ /* Couldn't send, first buffer still same size */
			++retry;
			if(retry > ABORT_RETRY)
			{/* Must be something wrong with the port */
				immed_loop:
				if(out_buf != NULL)
				{/* Delete (all) pending send buffer(s) */
					ifree(out_buf->buf);
					sb=out_buf->next;
					ifree(out_buf);
					out_buf=sb;
					if(ABORT_IMMED) goto immed_loop;
				}
			}
		}
		else
			retry=0;
	}
	
	if(in_buf)
		ifree(in_buf);
	in_buf=NULL;
	in_len=0;
	last_esc=0;
}