#include <tos.h>
#include <stdlib.h>
#include <screen.h>
#include <ext.h>
#include "drv_ass.h"
#include "drv_type.h"

typedef struct
{
	int			*errbell;
	unsigned	long	ok;
	unsigned	long	errs;
	unsigned	long	errc;
}errstate;

int hlp=0;

errstate rec_proto={&hlp,0,0,0};

io_rec		*midi_io;
char		midi_buf[25000];

void set_errbell(int *errbell)
{
	rec_proto.ok=0L;
	rec_proto.errs=0L;
	rec_proto.errbell=errbell;
}

void do_install(void)
{
	midi_io=INSTALL(sizeof(midi_buf)-10,midi_buf);
}

void	clear_buff(void)
{
	do
	{	
		MIDEIN();
		delay(2);
	}	while (midi_io->nw!=midi_io->nl);
}

void AES_install(void)
{

#ifdef DOWNIRLV
 INST_2(4);
#endif
#ifdef MOUSEVEK
 INST_2(1);
#endif
#ifdef MAUSIKBD
 INST_2(3);
#endif
#ifdef ALLES
 INST_2(7);
#endif
#ifdef IRV_MOUS
 INST_2(5);
#endif
#ifdef NOTHING
 INST_2(0);
#endif
}


int mdstat(void)
{
 int nl,nw;
 nl=midi_io->nl; nw=midi_io->nw;
 if ((INTC!=0) || (nl!=nw)) return(-1);
 else return(0);
}

int fil_request(void)
{
int nl,nw,size;
long fuellung;

 nl=midi_io->nl; nw=midi_io->nw;
 if (INTC!=0) return(1);
 if (nl==nw) return(0);

	nw++;
	if (nw==midi_io->size) nw=0;
	size=midi_io->ibuf[nw];
	size<<=8;
	nw++;
	if (nw==midi_io->size) nw=0;
	size|=midi_io->ibuf[nw];
	if ((size<8) || (size>4500)) return(1);

	fuellung=(nw<nl) ? (nl-nw) :(midi_io->size-nw+nl);
	if (fuellung>(size-14)) return(1);
		else return(0);
}

#ifdef proto_on
void proto_out(char *msgtyp, int sender, int empf, int state) 
{
static char hlp[20];
int msg;

	if (*rec_proto.errbell >0)
	{
		msg = msgtyp[0];
		msg <<= 8;
		msg |= msgtyp[1];
		Save_pos();
		switch (state)
		{
			case 0: Goto_pos(1,50);break;
			case 1: 
			case 2: Goto_pos(2,50);break;
			case 3: 
			case 4: 
			case 5: Goto_pos(3,50);break; /*senden*/
		}
		Cconws("TYP:");Cconws(itoa(msg,hlp,10));
		Cconws(" ");Cconws(itoa(sender,hlp,10));
		Cconws(" => ");Cconws(itoa(empf,hlp,10));
		switch (state)
		{
			case 0: Cconws("      ");break; /*Auftrag*/
			case 1: Cconws(" >>>>>");break; /*sendung*/
			case 2: Cconws(" <<<<<");break; /*empfang*/
			case 3: Cconws(" ?????");break; /*request von aussen*/
			case 4: Cconws(" reply");break; /*senden*/
			case 5: Cconws(" >===>");break; /*durchreichen*/
		}
		Load_pos();
	}
	if (state==6)
	{
		msg = msgtyp[0];
		msg <<= 8;
		msg |= msgtyp[1];
		Cconws("TYP:");Cconws(itoa(msg,hlp,10));
		Cconws(" ");Cconws(itoa(sender,hlp,10));
		Cconws(" => ");Cconws(itoa(empf,hlp,10));
		Cconws(" TIME-OUT!!!???\r\n");
	}
}


#endif /* proto_on */
void err_out( int rec_err,int CRC_err)
{
static char hlp[20];

	switch (*rec_proto.errbell)
	{
		case 0:break;
		case 1: 
			if (rec_err)
			{
  				if (CRC_err) rec_proto.errc++;
  				   else rec_proto.errs++;
	  			Save_pos();
  				Goto_pos(0,57);
	  			Cconws("ok=");Cconws(ultoa(rec_proto.ok,hlp,10));
	  			Cconws(" #");Cconws(ultoa(rec_proto.errs,hlp,10));
	  			Cconws(" CRC");Cconws(ultoa(rec_proto.errc,hlp,10));
		  		Load_pos();
			} else rec_proto.ok++;
			break;
		case 2: 
			if (rec_err)
			{
				if (CRC_err) rec_proto.errc++;
  				   else rec_proto.errs++;
  			}
			else rec_proto.ok++;
		   	Save_pos();
			Goto_pos(0,57);
			Cconws("ok=");Cconws(ultoa(rec_proto.ok,hlp,10));
			Cconws(" #");Cconws(ultoa(rec_proto.errs,hlp,10));
  			Cconws(" CRC");Cconws(ultoa(rec_proto.errc,hlp,10));
		   	Load_pos();break;
	}
}


#define	out_count	8000

int lese(int len,char *buff)
{
int i=0;
int err1=0,err2=0;

if ((len<2) || (len>4500)) return(1);
do 
{
	if (midi_io->nw!=midi_io->nl)
	{
		midi_io->nw++;
		if (midi_io->nw==midi_io->size) midi_io->nw=0;
		buff[i++]=midi_io->ibuf[midi_io->nw];
		err1=0;
	}
	else err1++;
} while ((err1<out_count) && (i<len) && (0==INTC));

err2=INTC;
	if ((err1>=out_count) || (err2!=0)) 
	{
		return(1);
	}
	else return(0);
} 

long  SENDE(int len, char *buff)
{
	MSEND(len-1,buff);
	return(0);
}

