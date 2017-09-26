#include <tos.h>
#include <aes.h>
#include <stdlib.h>
#include <hsmod.h>

typedef struct
{
	char	pen_active;
	int		x;
	int		y;
	char	flags;
	int		press;
}PACKET;

typedef struct
{
	unsigned char	keys;
	char	x;
	char	y;
}MPACK;

int open_aux(char *path, long baud);

void in_loop(int hd);
void (*mousevec)(MPACK *mp);

void main(void)
{
	int er;
	char num[10];
	
	Cconws("\r\nInitialisiere Modem2..\r\n");
	er=open_aux("U:\\DEV\\MODEM2", 9600l);
	if(er < 0)
	{
		Cconws("\r\nFehler ");
		Cconws(itoa(er, num, 10));
		return;
	}

	mousevec=(Kbdvbase()->kb_mousevec);
	Cconws("Ok\r\n");
	in_loop(er);
}

int open_aux(char *path, long baud)
{
	long hd, var, var2;
	int	 hdi;
	
	hd=Fopen(path, FO_RW);
	if(hd < 0)
		return(-1);

	hdi=(int)hd;	
	
	/* Parameter setzen */
	var=baud;
	hd=Fcntl(hdi, (long)&var, TIOCIBAUD);
	if(hd < 0)
		return(-2);		/* Fehler Eingabespeed*/
	var=baud;
	hd=Fcntl(hdi, (long)&var, TIOCOBAUD);
	if(hd < 0)
		return(-3);	/* Fehler Ausgabespeed */

	var=0;
	hd=Fcntl(hdi, (long)&var, TIOCGFLAGS);
	if(hd < 0)
		return(-4); /* Fehler Flags erfragen */

	var2=TF_STOPBITS|TF_CHARBITS|TF_FLAG;
	var2<<=16;
	var2=~var2;
	var&=var2;
	var2=TF_1STOP|TF_8BIT/*|T_RTSCTS*/;
	var2<<=16;
	var|=var2;
	
	hd=Fcntl(hdi, (long)&var, TIOCSFLAGS);
	if(hd < 0)
		return(-5);	/* Fehler Protokoll */

	return((int)hdi);
}

void output(PACKET *pack)
{
	static int l_x=-1, l_y=-1;
	
	MPACK	mp;
	
	if(pack->pen_active==0) return;
	mp.keys=0xf8+(((pack->flags)>>3) && 3);
	mp.x=0;
	mp.y=0;
	asmousevec(&mp);
}

void ooutput(PACKET *pack)
{
	showxy(0,3,pack->x);
	showxy(5,3,pack->y);
	if(pack->pen_active)
	{
		if(pack->flags & (1<<4)) showxy(0,2,1);
		else										 showxy(0,2,0);
		if(pack->flags & (1<<3)) showxy(3,2,1);
		else										 showxy(3,2,0);
		showxy(6,2,pack->press);
	}
	else
	{
		showxy(0,2,2);
		showxy(3,2,2);
		showxy(6,2,-1);
	}
}

void in_loop(int hd)
{
	PACKET	pack;
	unsigned char		buf[1024], pack_len;
	long 		 s_in, cnt, pack_ok;

	
	appl_init();

	pack_ok=pack_len=0;
	
	while(1)
	{
		evnt_timer(20,0);

		s_in=Fread(hd, 1024, buf);
		cnt=0;

		while(cnt < s_in)
		{
			if(buf[cnt] & 128)
			{
				if(pack_len == 7)
					pack_ok=1;
				pack_len=0;
			}
			
			/* Byte auswerten */
			switch(pack_len)
			{
				case 0:	/* Statusfeld: 7=Sync, 6=Pen da, 5=1, 6-0=0 */
					if(buf[cnt] & (1<<6)) pack.pen_active=1;
					else									pack.pen_active=0;
				break;
				case 1:
					pack.x=(int)buf[cnt]*128;	/* Hi X */
				break;
				case 2:
					pack.x+=buf[cnt];			/* Lo X */
				break;
				case 3:
					pack.flags=buf[cnt];	/* Flags (Buttons) */
				break;
				case 4:
					pack.y=(int)buf[cnt]*128;	/* Hi Y */
				break;
				case 5:
					pack.y+=buf[cnt];			/* Lo Y */
				break;
				case 6:
					pack.press=(int)buf[cnt];
					if(pack.press > 63) pack.press-=64;
					else	pack.press+=64;
				break;
			}
			
			if(pack_ok)
			{
				output(&pack);
				pack_ok=0;
			}

			++cnt;
			++pack_len;
		}

	}	
}
