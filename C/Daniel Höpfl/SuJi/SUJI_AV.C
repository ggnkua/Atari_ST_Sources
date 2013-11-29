#include "SuJi_glo.h"

int av_server=-1;
unsigned long av_server_kennt=0;
char *av_string=NULL;
unsigned long *av_del_list;

int get_av_server(void)
{
	char *server;
	char such[9];
	int i;
	int av_server=-1;

	server=getenv("AVSERVER");
	if(server)
	{
		for(i=0;i<8;i++)
			such[i]=' ';
		such[8]='\0';

		for(i=0;i<9 && server[i];i++)
		{
			if(server[i])
				such[i]=server[i];
		}

		av_server=mt_appl_find(such,&global);
	}

	if(av_server<0) av_server=mt_appl_find ("JINNEE  ",&global);
	if(av_server<0) av_server=mt_appl_find ("GEMINI  ",&global);
	if(av_server<0) av_server=mt_appl_find ("THING   ",&global);
	if(av_server<0) av_server=mt_appl_find ("EASE    ",&global);
	if(av_server<0) av_server=mt_appl_find ("AVSERVER",&global);
	if(av_server<0) av_server=mt_appl_find ("MAGXDESK",&global);
	if(av_server<0) av_server=0;

	return av_server;
}

void init_av_protokoll(void)
{
	int msg[8];

	av_server=get_av_server();

	msg[0]=AV_PROTOKOLL;
	msg[1]=ap_id;
	msg[2]=0;
	msg[3]=0x18;	/* Wir k”nnen: Quoting und VA_FONTCHANGED */
	msg[4]=0;
	msg[5]=0;
	*(char **)(&(msg[6]))=prog_name;
	mt_appl_write(av_server,16,msg,&global);

	av_server=-1;
}

void exit_av_protokoll(void)
{
	int msg[8];

	if(av_server==-1)
		av_server=get_av_server();

	msg[0]=AV_EXIT;
	msg[1]=ap_id;
	msg[2]=0;
	msg[3]=ap_id;
	msg[4]=0;
	msg[5]=0;
	msg[6]=0;
	msg[7]=0;
	mt_appl_write(av_server,16,msg,&global);

	av_server=-1;
}
