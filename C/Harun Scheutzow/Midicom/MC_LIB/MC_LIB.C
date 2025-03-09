#include <stddef.h>			 /* Standard-Definitionen */
#include <string.h>      /* String-Library */
#include <extdef.h>
#include "mc_lib.h"


static	int		apl_num;
static	io_rec	io_ptr;

static long get_cookie(void)
{
	COOKIE  *cokie;
	
	cokie = 	*CJAR;
	if (cokie) 
	{
		while (cokie->tag.aslong != 0) 
		{
			if (!strncmp(cokie->tag.aschar, "MICO",4))
			{
				infos=(CINFO *)cokie->value;
			}
			cokie++;
		}
	}
	return(0);
}

long mygemdos(msg_typ *mc_msg)
{
 long   old_super_stack,erg;
 
 old_super_stack = Super( 0L );
 erg=MC_direct_call(mc_msg);
 Super((void *) old_super_stack );
 return( erg );
}

int get_mc_sys(syspar *sys,all_proc *allprocs)
{

  long		test;
  msg_typ   mc_msg;

	if (MiNT==0)
	{
		(void)Supexec(get_cookie);
		if (infos==NULL) MiNT=2;
			else	MiNT=1;
	}
	if (MiNT==1)
	{
		mc_msg.what =   0;
		*sys        = (sys_par *)mygemdos(&mc_msg);
		mc_msg.what =   1;
		*allprocs 	= (all_proc )mygemdos(&mc_msg);
		return(1);
	}
	else
	if (MiNT==2)
	{

    	mc_msg.what =   0;
	    test        =   trap111(&mc_msg);
    	if (test>0)	/* ist MIDI-COM nicht aktiviert, existiert GEMDOS 111 nicht =>-34*/
	    {
			*sys    = (sys_par *) test;
			mc_msg.what =   1;
			*allprocs = (all_proc) trap111(&mc_msg);
			return(1);
		}
	}
  return(0);
}

long	mc_message(msg_typ *mc_msg)
{
	if (MiNT==0)
	{
		(void)Supexec(get_cookie);
		if (infos==NULL) MiNT=2;
			else	MiNT=1;
	}
	if (MiNT==1)
		return(mygemdos(mc_msg));
	else
	    return(trap111(mc_msg));
}

long write_message(int what, int apl_num, int an, int size,char *name,void *ptr)
{
  msg_typ   mc_msg;

  mc_msg.what =   what;
  mc_msg.size=size;
  mc_msg.ptr=ptr;
  mc_msg.name=name;
  mc_msg.an=an;
  mc_msg.fill=apl_num;
  return(mc_message(&mc_msg));
}


int anmeld_ring(char *name,int buff_size)
{
 buff_size-=1;
 if (buff_size<4000) buff_size=4000;
 if (buff_size>30000) buff_size=30000;
 if (io_ptr.ibuf==NULL)
 {
  io_ptr.ibuf=Malloc(buff_size);
 };
 io_ptr.size=buff_size;	  /* groesse des Buffers      */
 io_ptr.   nl  =0;           /* naechste Leseposition    */
 io_ptr.   nw  =0;           /* naechste Schreibposition */
 io_ptr.   blow=0;           /* status/fehler            */
 io_ptr.   bhig=-1;          /* Ack: msg gelesen         */
 apl_num=(int)write_message(_ASSIGN,0,0,0,name,&io_ptr);
 if (apl_num>=0) return(apl_num);
 return(FALSE);
}


void abmeld_ring(void)
{
   write_message(_GOOD_BYE,apl_num,0,0,NULL,NULL);
   if (io_ptr.ibuf)
   {
   	Mfree(io_ptr.ibuf);
   }
}

long transmit(int size,int an,char *name,void *dat_adr)
{  
 return(write_message(_SEND_DATA,apl_num,an,size,name,dat_adr));
}

typedef	union
{
	int asint;
	char	aschar[2];
}konv1;

int lese(char *bufa1,int *esc,int *len)
{
 int i;
 konv1	help;
 
 *esc=0;
 if (io_ptr.nl==io_ptr.nw) return(FALSE);
 help.aschar[0]=io_ptr.ibuf[io_ptr.nl++];
 if (io_ptr.nl==io_ptr.size) io_ptr.nl=0;
 help.aschar[1]=io_ptr.ibuf[io_ptr.nl++];
 if (io_ptr.nl==io_ptr.size) io_ptr.nl=0;
 if (help.asint>4000)
 {
   	*esc=help.asint;
	help.aschar[0]=io_ptr.ibuf[io_ptr.nl++];
	if (io_ptr.nl==io_ptr.size) io_ptr.nl=0;
	help.aschar[1]=io_ptr.ibuf[io_ptr.nl++];
	if (io_ptr.nl==io_ptr.size) io_ptr.nl=0;
	*len=help.asint;
 }
 for (i=0;i<=help.asint-3;i++)
 {
	bufa1[i]=io_ptr.ibuf[io_ptr.nl++];
	if (io_ptr.nl==io_ptr.size) io_ptr.nl=0;
 }
 return(TRUE);
}

void get_Karte(void)
{
 write_message(_GET_VERW,apl_num,0,0,NULL,NULL);
}

void set_unitime(void)
{
 write_message(_UNITIME,apl_num,0,0,NULL,NULL);
}


int mc_busy(void)
/* ring geschlossen und im sende-Modus */
{
 return(((io_ptr.blow & 7)==7) && ((io_ptr.blow & 64)==64));
}

int mc_closed(void)
/* ring geschlossen */
{
 return(((io_ptr.blow & 7)==7));
}

int mc_neustat(void)
/* ring-Verwaltung wurde ge„ndert */
{
 return(((io_ptr.blow & 2048)==2048));
}
