#include <ec_gem.h>
#include <hsmod.h>

#define BUFSIZE 200

int cx, cy, ok;
char	*line[BUFSIZE];
WINDOW	win;

void quit(WINDOW *win);
void mini_term(void);
void term_out(char *text);
int open_aux(char *path, long baud);
void new_line(void);

void main(void)
{
	e_start_as(ACC|PRG,"MiniTerm");
	
	if(ap_type & (ACC|PRG))
	{
		uses_txwin();
		mini_term();
	}
	
	e_quit();
}

void mini_term(void)
{
	TINFO		twin;
	int			a, evnt, dum, swt, key, y_off, io_ok=0, port, evret, scan=0;
	char		*c, path[128], buf[1024];
	long 		rsv_ob, s_in, cnt;
	
	for(a=0; a < BUFSIZE; ++a)
	{
		line[a]=(char*)malloc(256);
		line[a][0]=0;
	}
	for(a=0; a < 25; ++a)
	{
		line[a][0]=' ';
		line[a][1]=0;
	}

	cx=0;
	cy=0;
	
	strcpy(line[cy++], "Mini-Terminal V0.1  Sven Kopacz");
	strcpy(line[cy++], "-------------------------------");
	
	while(strlen(line[0]) < 80) strcat(line[0],  " ");
	
	w_init(&win);
	twin.text=line;
	win.tinfo=&twin;
	win.name="MiniTerm";
	w_text(&win);
	win.do_align=SIZE;
	
	win.closed=quit;
	ok=1;
	
	y_off=cy-1;
	
	if(find_cookie('RSVF', &rsv_ob))
	{
		if(!rsv_ob)
			strcpy(line[1], "RSVF-Cookie ist leer.");
		else while(ok)
		{
			if((*(unsigned char*)(rsv_ob+4)) & 128)
			{
				++io_ok;
				itoa(cy-y_off, line[cy], 10);
				strcat(line[cy], ":");
				c=*(char**)rsv_ob;
				strcat(line[cy],c);
				/*
				if((*(unsigned char*)(rsv_ob+4)) & 64)
					strcat(line[cy], " GEMDOS");
				if((*(unsigned char*)(rsv_ob+4)) & 128)
					strcat(line[cy], " BIOS");
				*/
				rsv_ob+=8;
				cy++;
			}
			else
			{
				if((*(long*)rsv_ob == -1) || (*(long*)rsv_ob == 0))
					ok=0;
				else
					rsv_ob=*(long*)rsv_ob;
			}
		};
		
		ok=1;
	}
	else
		strcpy(line[1], "RSVF-Cookie nicht gefunden.");
	
	t_calc(&win);
	w_open(&win);
	w_txchange(&win);
	w_txfit(&win, T_HFIT|T_VFIT);

	if(io_ok)
	{ /* mind. 1 Schnittstelle gefunden */
		port=0;
		strcpy(line[cy++], "Schnittstelle w„hlen:");
		while(io_ok)
		{
			if(  (!w_devent(&evnt, &dum, &dum, &swt, &key)) &&
					 (evnt & MU_KEYBD)
				)
			{
				key&=255;
				if((key >= 49) && (key < 49+io_ok))
				{
					port=key-48;
					io_ok=0;
				}
				else
					Bell();
			}
			if(!ok)
				io_ok=0;
		}
		if(port)
		{
			strcpy(path, "U:\\DEV\\");
			strcat(path, &(line[port+y_off][2]));
			strcpy(line[cy++],"----------------------");
			strcpy(line[cy++],path);
			w_txchange(&win);
			w_txgoto(&win, 0, cy-1);
			if(form_alert(1,"[2][Terminal oder Scanner?][Terminal|Scanner]") == 1)
				port=open_aux(path, 57600l);
			else
			{
				port=open_aux(path, 9600l);
				scan=1;
			}
			if(port < 0)
				term_out("Fehler beim ™ffnen.");
		}
	}
	
	line[cy][0]='_';
	line[cy][1]=0;
	
	while(ok)
	{
		evret=w_dtimevent(&evnt, &dum, &dum, &swt, &key, 100,0);
		if(((evret==-2) || (evret==0)) && (port >= 0))
		{
			if(evnt & MU_KEYBD)
			{
				buf[0]=key & 255;
				if(buf[0])
					Fwrite(port, 1, buf);
			}
			if(evnt & MU_TIMER)
			{
				s_in=Fread(port, 1024, buf);
				cnt=0;

				while(cnt < s_in)
				{
					while(cnt < s_in)
					{
						if(scan)
						{
							if(buf[cnt] < 0)
								cx=0;
							itoa(buf[cnt], &(line[cy][cx]), 10);
							++cx;
							if(abs(buf[cnt]) > 9)
								++cx;
							if(abs(buf[cnt]) > 99)
								++cx;
							line[cy][cx++]=' ';
						}
						else
						{
							if(cx >= 255)
							{
								line[cy][255]=0;
								new_line();
								cx=0;
							}
							if(buf[cnt] > 31)
								line[cy][cx++]=buf[cnt];
							else if(buf[cnt] == 13)
							{
								if(cx == 0)
									line[cy][cx++]=' ';
								line[cy][cx]=0;
								new_line();
								cx=0;
								strcpy(line[cy], " ");
							}
							else if(buf[cnt] == 8)
							{
								--cx;
								if(cx < 0)
									cx=0;
							}
						}
						++cnt;
					}
				}
				if(cx >= 255)
				{
					line[cy][cx]=0;
					new_line();
					cx=0;
				}
				line[cy][cx]='_';
				line[cy][cx+1]=0;
				line[cy+1][0]=0;
				if(s_in)
				{
					w_txchange(&win);
					w_txgoto(&win, 0, cy-1);
				}
			}
		}
	}

	w_kill(&win);

	Fclose(port);
	
	for(a=0; a < BUFSIZE; ++a)
		free(line[a]);
}

void new_line(void)
{
	int		a;
	char	*ml=line[0];
	
	++cy;
	if(cy < BUFSIZE-1)
		return;
		
	for(a=0; a < BUFSIZE-1; ++a)
		line[a]=line[a+1];

	cy=BUFSIZE-2;
	line[cy]=ml;
	line[cy][0]=0;
}

int open_aux(char *path, long baud)
{
	long hd, var, var2;
	int	 hdi;
	char nl[128];
	
	hd=Fopen(path, FO_RW);
	if(hd < 0)
		return((int)hd);

	hdi=(int)hd;	
	
	/* Parameter setzen */
	var=baud;
	hd=Fcntl(hdi, (long)&var, TIOCIBAUD);
	if(hd < 0)
	{
		ltoa(hd, nl, 10);
		strcat(nl, " Fehler Eingabespeed");
		term_out(nl);
	}	
	var=baud;
	hd=Fcntl(hdi, (long)&var, TIOCOBAUD);
	if(hd < 0)
	{
		ltoa(hd, nl, 10);
		strcat(nl, " Fehler Ausgabespeed");
		term_out(nl);
	}	
	var=0;
	hd=Fcntl(hdi, (long)&var, TIOCGFLAGS);
	if(hd < 0)
	{
		ltoa(hd, nl, 10);
		strcat(nl, " Fehler Flags erfragen");
		term_out(nl);
	}
	var2=TF_STOPBITS|TF_CHARBITS|TF_FLAG;
	var2<<=16;
	var2=~var2;
	var&=var2;
	var2=TF_1STOP|TF_8BIT;
	if(baud != 9600)
		var2|=T_RTSCTS;
	var2<<=16;
	var|=var2;
	
	hd=Fcntl(hdi, (long)&var, TIOCSFLAGS);
	if(hd < 0)
	{
		ltoa(hd, nl, 10);
		strcat(nl, " Fehler Protokoll");
		term_out(nl);
	}	

	/* Parameter erfragen */
	var=-1;
	hd=Fcntl(hdi, (long)&var, TIOCIBAUD);
	if(hd >= 0)
	{
		ltoa(var, nl, 10);
		strcat(nl, " Eingabespeed");
		term_out(nl);
	}	
	else
	{
		ltoa(hd, nl, 10);
		strcat(nl, " Fehler Eingabespeed");
		term_out(nl);
	}	

	var=-1;
	hd=Fcntl(hdi, (long)&var, TIOCOBAUD);
	if(hd >= 0)
	{
		ltoa(var, nl, 10);
		strcat(nl, " Ausgabespeed");
		term_out(nl);
	}	
	else
	{
		ltoa(hd, nl, 10);
		strcat(nl, " Fehler Ausgabespeed");
		term_out(nl);
	}	

	var=0;
	hd=Fcntl(hdi, (long)&var, TIOCGFLAGS);
	if(hd >= 0)
	{
		var>>=16;
		if(var & TF_1STOP)
			term_out("1 Stopbit");
		else if(var & TF_15STOP)
			term_out("1.5 Stopbit");
		else if(var & TF_2STOP)
			term_out("2 Stopbit");
			
		if(!(var & TF_CHARBITS))
			term_out("8 Bit pro Zeichen");
		else if(var & TF_7BIT)
			term_out("7 Bit pro Zeichen");
		else if(var & TF_6BIT)
			term_out("6 Bit pro Zeichen");
		else if(var & TF_5BIT)
			term_out("5 Bit pro Zeichen");
		
		if(var & T_TANDEM)
			term_out("XON/XOFF aktiv");
		if(var & T_RTSCTS)
			term_out("RTS/CTS aktiv");
			
		if(var & T_EVENP)
			term_out("Gerade Parit„t");
		else if(var & T_ODDP)
			term_out("Ungerade Parit„t");
		else
			term_out("Keine Parit„t");
	}	
	else
	{
		ltoa(hd, nl, 10);
		strcat(nl, " Fehler Flags erfragen");
		term_out(nl);
	}	
	
	return(hdi);
}

void term_out(char *text)
{
	strcpy(line[cy++],text);
	w_txchange(&win);
	w_txgoto(&win, 0, cy-1);
}

void quit(WINDOW *win)
{
	ok=0;
	w_close(win);
}

