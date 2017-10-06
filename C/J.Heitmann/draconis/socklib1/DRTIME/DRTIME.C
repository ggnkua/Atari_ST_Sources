/* 
	This simple program should demonstrate how easy to implement a 
	own internet application with the Draconis Socket Library.
	
	This application establishes a simple connection to the time
	service of a foreign host.
	
	If the application is installed as an accessory, it checks the
	time after the establishment of a connection and if the difference
	is more than 5 minutes it ask if the time should be set.
	
	If the application is executed by it's menu entry or as a program
	it displays the host time always.
	
	(c) J.Heitmann
	Part of the Draconis Internet Package
	
*/

#include <aes.h>
#include <ctype.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <ext.h>
#include "..\drsocket\stsocket.h"

void check_time(int flg);
void load_time_server(void);
void user_info(int flg, time_t time_information);

int appl_id;
int connected = 0;
char time_host[64] = "server.test.com";

/* -------------
   | Main part |
   ------------- */
void main(void)
{
int which, msg[8];
int mouse_x, mouse_y, mouse_b;
int k_state, k_return, clicks;

appl_id = appl_init();

load_time_server();

if (!_app)
	{
	menu_register(appl_id, "  Time-Checker");
	for (;;)
		{
		which = evnt_multi(MU_MESAG|MU_TIMER,
											 0, 0, 0,
											 0, 0, 0, 0, 0,
											 0, 0, 0, 0, 0,
											 msg, 5000, 0,
											 &mouse_x, &mouse_y, &mouse_b,
											 &k_state, &k_return, &clicks);

		if (which & MU_MESAG)
			{
			switch(msg[0])
				{	
				case AC_OPEN:
					form_alert(1, "[1][Draconis socket|programming demonstration.][Ok]");
					if (get_connected() == 2)
						check_time(1);
					break;
				}
			}
		
		if (which & MU_TIMER)
			{
			if (!connected)
				{
				if (get_connected() == 2)
					{
					check_time(0);
					connected = 1;
					}
				}
			else
				{
				if (get_connected() < 2)
					connected = 0;
				}
			}
		}
	}
else
	{
	if (get_connected() == 2)
		check_time(1);
	else
		form_alert(1, "[3][No active connection][Ok]");
	}
	
appl_exit();
}

/* ------------------
   | check the time |
   ------------------ */
void check_time(int flg)
{
struct servent *serv;
struct hostent *host;
struct sockaddr_in remote;
int s;
time_t time_information;
int nx;
struct fd_set fd_chk;
struct timeval tval;

if (time_host[0])
	{
	serv = getservbyname("time", "tcp");
	if (!serv)
		{
		if (flg)
			form_alert(1, "[3][Unknown service 'time'][Ok]");
		return;
		}
	
	remote.sin_family = AF_INET;
	remote.sin_port = serv->s_port;
	if (isdigit(time_host[0]))
		remote.sin_addr.s_addr = inet_addr(time_host);
	else
		{
		host = gethostbyname(time_host);
		memcpy(&remote.sin_addr.s_addr, host->h_addr, host->h_length);
		}

	s = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
	if (!s)
		{
		if (flg)
			form_alert(1, "[3][Unable to create socket][Ok]");
		return;
		}
	
	if (!connect(s, (struct sockaddr *)&remote, (int)sizeof(remote)))
		{
		FD_ZERO(&fd_chk);
		FD_SET(s, &fd_chk);
		
		tval.tv_sec = 30;
		tval.tv_usec = 0;
		
		nx = select(s + 1, &fd_chk, NULL, NULL, &tval);
		if (nx && FD_ISSET(s, &fd_chk))
			{
			if (recv(s, &time_information, sizeof(time_information), 0) == sizeof(time_information))
				user_info(flg, time_information);
			}
		else
			form_alert(1, "[3][Unable to get time information][Ok]");
		}
	else
		if (flg)
			form_alert(1, "[3][Unable to connect][Ok]");
			
	close_socket(s);
	}
}

/* --------------------------------
   | Load time server information |
   -------------------------------- */
void load_time_server(void)
{
FILE *fh;
char *s;

fh = fopen("DRTIME.CNF", "r");
if (fh)
	{
	if (!fgets(time_host, (int)sizeof(time_host), fh))
		time_host[0] = 0;

	s = strchr(time_host, '\n');
	if (s) *s = 0;
		
	fclose(fh);
	}
}
 
/* ------------------------------------------------------------
   | Inform user about time and ask if the time should be set |
   ------------------------------------------------------------ */
void user_info(int flg, time_t time_information)
{
struct tm *loctm;
struct date locdate;
struct time loctime;
time_t currtime;
char buf[50], *s;

time_information -= 2208988800L;

if (!flg)
	{
	currtime = time(NULL);
	
	if (labs(time_information - currtime) < 5 * 60)
		return;
	}
	
sprintf(buf, "[1][Host-time:| |%s][Set|Exit]", ctime(&time_information));
s = strchr(buf, '\n');
if (s) *s = ' ';
	
if (form_alert(2, buf) == 1)
	{
	loctm = localtime(&time_information);

	locdate.da_day 	= loctm->tm_mday;
	locdate.da_mon 	= loctm->tm_mon + 1;
	locdate.da_year =	loctm->tm_year + 1900;
	
	loctime.ti_hour	= loctm->tm_hour;
	loctime.ti_min	= loctm->tm_min;
	loctime.ti_sec  = loctm->tm_sec;
	loctime.ti_hund = 0;

	setdate(&locdate);
	settime(&loctime);
	}
}
