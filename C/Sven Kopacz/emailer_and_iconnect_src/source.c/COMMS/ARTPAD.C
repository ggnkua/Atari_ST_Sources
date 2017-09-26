#include <tos.h>
#include <aes.h>
#include <stdlib.h>
#include <hsmod.h>
#include <asgard.h>

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
int t_x, t_y;

#define XMIN 50
#define XMAX 4800
#define YMIN 50
#define YMAX 3700

void in_loop(int hd);
extern long mousevec;
extern void asmousevec(void);
extern MPACK mp;

ASG_COOKIE *asgc, my_asg;

void main(void)
{
	int er;
	
	appl_init();
	if(find_cookie('asGT', (long*)&asgc)==0)
	{
		asgc=&my_asg;
		if(make_cookie('asGT', (long)asgc, 0, 0)==0)
		{
			form_alert(1,"[2][Der ArtPad-Cookie konnte nicht angelegt werden.|Die Drucksensitivit„t kann nicht genutzt werden.][OK]");
			asgc=NULL;
		}
	}
	else
		asgc->maxpress=254;

	er=open_aux("U:\\DEV\\MODEM2", 9600l);
	if(er < 0)
	{
		switch(er)
		{
			case -1:
				form_alert(1,"[3][ArtPad:|Kann Schnittstelle nicht ”ffnen.][Abbruch]");
			break;
			case -2:
				form_alert(1,"[3][ArtPad:|Kann In-Baudrate nicht setzen.][Abbruch]");
			break;
			case -3:
				form_alert(1,"[3][ArtPad:|Kann Out-Baudrate nicht setzen.][Abbruch]");
			break;
			case -4:
				form_alert(1,"[3][ArtPad:|Kann Flags nicht erfragen.][Abbruch]");
			break;
			case -5:
				form_alert(1,"[3][ArtPad:|Kann Protokoll nicht erfragen.][Abbruch]");
			break;
		}
		return;
	}

	mousevec=(long)(Kbdvbase()->kb_mousevec);
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
	/* X = 50-4800 
		 Y = 50-3700 */
	int		 dx,dy;
	static int oldbutt=0;
	
	if(pack->pen_active==0)
	{ /* Kein Stift mehr da, vorher Taste gedrckt? */
		if(oldbutt==0) return;
		mp.keys=0xf8;
		mp.x=mp.y=0;
		asmousevec();
		oldbutt=0;
		return;
	}
	oldbutt=pack->flags;
	mp.keys=0xf8+pack->flags;
	dx=pack->x-t_x; dy=pack->y-t_y;
	do
	{
		if(dx > 127)				{mp.x=127; dx-=127;}
		else if(dx < -128)	{mp.x=-128; dx+=128;}
		else								{mp.x=dx; dx=0;}

		if(dy > 127)				{mp.y=127; dy-=127;}
		else if(dy < -128)	{mp.y=-128; dy+=128;}
		else								{mp.y=dy; dy=0;}
		if(asgc)
			asgc->pressure=pack->press;
		asmousevec();
	}while(dx || dy);
	t_x=pack->x; t_y=pack->y;
}

void in_loop(int hd)
{
	int			sw,sh,dum;
	PACKET	pack;
	unsigned char		buf[1024], pack_len;
	long 		 s_in, cnt, pack_ok;
	double	 x_fac, y_fac, c;
	static 	 int reinit=0;
	
	wind_get(0,WF_CURRXYWH,&dum, &dum, &sw, &sh);
	x_fac=(double)sw/(double)(XMAX-XMIN);
	y_fac=(double)sh/(double)(YMAX-YMIN);
	graf_mkstate(&t_x, &t_y, &dum, &dum);
	
	pack_ok=pack_len=0;
	
	while(1)
	{
		evnt_timer(10,0);
		if(reinit < 400)
		{/* Nach vier Sekunden neu initialisieren, damit dazugeh„ngte
				Tools wie WinCom oder Screensaver auch die Mauspakete
				abbekommen */
			 ++reinit;
			 if(reinit==400)
					mousevec=(long)(Kbdvbase()->kb_mousevec);
		}
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
					if(pack.x < XMIN) pack.x=XMIN;
					if(pack.x > XMAX) pack.x=XMAX;
					pack.x-=XMIN;
					c=pack.x; c*=x_fac; pack.x=(int)c;
				break;
				case 3:		/* Flags (Buttons) */
					pack.flags=0;
					if(buf[cnt] & (1<<3))
						pack.flags|=2;
					if(buf[cnt] & (1<<4))
						pack.flags|=1;
				break;
				case 4:
					pack.y=(int)buf[cnt]*128;	/* Hi Y */
				break;
				case 5:
					pack.y+=buf[cnt];			/* Lo Y */
					if(pack.y < YMIN) pack.y=YMIN;
					if(pack.y > YMAX) pack.y=YMAX;
					pack.y-=YMIN;
					c=pack.y; c*=y_fac; pack.y=(int)c;
				break;
				case 6:
					pack.press=(int)buf[cnt];
					if(pack.press > 63) pack.press-=64;
					else	pack.press+=64;
					pack.press*=2;
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
