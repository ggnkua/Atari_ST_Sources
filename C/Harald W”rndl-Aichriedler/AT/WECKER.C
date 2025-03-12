/*
	WECKER.C
	
	(c) 1992 by Harald Wîrndl-Aichriedler
	
	V 0.01	10.04.92	NachrichtenÅbertragung Åber MSG
	V 1.00	11.04.92	Request-Protokoll,
						volle Funktionstauglichkeit
	V 1.01	17.05.92	Revisionen
	V 1.02	01.06.92	AusfÅhrung via AV-Protokoll
	V 1.03	11.06.92	Korrektur des GEMINI-Erkenners

*/


#include <tos.h>
#include <time.h>
#include <aes.h>
#include <stdlib.h>
#include <stdio.h>

#include <vaproto.h>


#define WORK_DIR	"C:\\WECKER\\"
#define LIST_FILE	WORK_DIR "WECKLIST.BIN"
#define KOMM_STR	WORK_DIR "TIME%04i.MUP"

#define SwTime		1500	/* alle 1.5 sec Nachfrage */
#define L_SIZE		200		/* 200 ListeeintrÑge zu 10 Bytes */
#define WECK_MSG	2422	/* Nachrichtennummer fÅr Weckerstart */
#define WECK_REQ	2423	/* Nachrichtennummer fÅr RÅckgabewert */


#define ON	2				/* ACC ein/ausgeschalten */
#define OFF	3
int ON_OFF = ON;

extern int _app;			/* ist Applikation ? */
int appl_id, gem_id;

typedef struct
{
	time_t	next, offset;
	int kommando;
} wecke;
wecke liste[L_SIZE+1];		/* Liste mit ZeiteintrÑgen */
int l_count = 0;			/* Anzahl vorhandener Elemente */
int sys_there;				/* ob System (1), oder Gemini(2) vorh. */

time_t now_time;

void do_for_time(void);
int  sort_in_liste(wecke *nachricht);
void del_aus_liste(int index);
void do_weck(wecke *nachricht);
void load_list(void);
void save_list(void);
void del_batch_file(int kommando_nr);
void av_progstart(char *name);


BASPAG *gemi_base;
SYSHDR *mine;
void get_sh(void);
void get_sh(void)
{
	mine = *(SYSHDR**)0x4f2L;
}

main()
{
	int in[8], d, evnt;
	wecke nachricht;

	if(_app)
	{
		Cconws("Programm nur als Accessory starten!\r\n");
		return 0;
	}
	Supexec((long(*)()) get_sh);
	
	if(menu_register(appl_id = appl_init(),"  Wecker...")>=0)
	{
		evnt_timer(5000,0);		/* Pause ... */
		while((gem_id = appl_find("GEMINI  ")) < 0)
			evnt_timer(200,0);	/* alles andere soll initialisieren */
		gemi_base = *mine->_run;

		time(&now_time);		/* Hole Zeit */
		load_list();

		while(1)
		{
			evnt = evnt_multi(MU_TIMER | MU_MESAG,
						0,0,0,0,0,0,0,0,0,0,0,0,0,
						in, SwTime, 0, /* Low/High-Counter Timer */
						&d,&d,&d,&d,&d,&d);
			time(&now_time);		/* Hole Zeit */
			if(evnt == MU_MESAG)
			{
				if(in[0] == AC_OPEN) 
				{
					ON_OFF = form_alert(ON_OFF,"[2]["
						"   Wecker| |"
						"Harald Wîrndl-Aichriedler|"
						"Version "__DATE__
					    "|Weckdienst ein/ausschalten]"
						"[ System | Gemini | aus ]");
					save_list();
				}
				if(in[0] == WECK_MSG)
				{
					int eintrag, c;
					nachricht = *(wecke*)(&in[3]);

					for(c=0; c<l_count; c++)
						if(liste[c].kommando == nachricht.kommando)
							del_aus_liste(c);
					eintrag = sort_in_liste(&nachricht);
					save_list();
					
					{	/* sende Request-Meldung */
						int buf[8] = {WECK_REQ,0,0};
						buf[1] = appl_id; buf[3] = eintrag;
						appl_write(in[1],16,buf);
					}
				}
			}
			if(ON_OFF != OFF && evnt == MU_TIMER)
			{
				wind_update(BEG_UPDATE);
				do_for_time();
				wind_update(END_UPDATE);
			}
		}
	}
	else
		while(evnt_timer(0,100));
	return 0;
}

void do_for_time(void)
{
	int c;

	if(gemi_base == *mine->_run)
		sys_there = 3;
	else if(system(NULL))
		sys_there = 2;
	else
		sys_there = 1;
	if(sys_there <= ON_OFF) return;

	for(c=0; liste[c].next <= now_time && c<l_count; c++)
	{
		wecke nachricht = liste[c];
		do_weck(&nachricht);
		del_aus_liste(c);
		if(nachricht.offset != 0)
		{
			nachricht.next += nachricht.offset*
				((now_time-nachricht.next)/nachricht.offset+1);
			sort_in_liste(&nachricht);
		}
		else
			del_batch_file(nachricht.kommando);
		save_list();
	}
}

int sort_in_liste(wecke *nachricht)
{
	int sort_in = 0, c;
	while(sort_in < l_count && nachricht->next >= liste[sort_in].next)
		sort_in++;
	if(sort_in != L_SIZE)	/* falls noch Platz, in Liste einfÅgen */
	{
		for(c=l_count; c>sort_in; c--)
			liste[c] = liste[c-1];
		liste[sort_in] = *nachricht;
		l_count++;
		return sort_in;
	}
	else
		return -1;
}

void del_aus_liste(int index)
{
	int c;
	l_count--;
	for(c=index; c<l_count; c++)
		liste[c] = liste[c+1];
}

void do_weck(wecke *nachricht)
{
	char command[128];
	int han;
	sprintf(command, KOMM_STR, nachricht->kommando);
	if((han = Fopen(command, FO_READ)) < 0)
	{
		nachricht->offset = 0;	/* das war das letzte mal */
		return;
	}
	Fclose(han);

	if(sys_there == 3)
		av_progstart(command);
	else
		system(command);
}

void save_list(void)
{
	int han;
	han = Fcreate(LIST_FILE, 0);
	if(han < 0)	return;
	Fwrite(han, 2, &l_count);
	Fwrite(han, l_count*sizeof(wecke), &liste[0]);
	Fwrite(han, 2, &ON_OFF);
	Fclose(han);
}

void load_list(void)
{
	int han, t;
	han = Fopen(LIST_FILE, FO_READ);
	if(han < 0)
		return;
	Fread(han, 2, &l_count);
	Fread(han, l_count*sizeof(wecke), &liste[0]);
	Fread(han, 2, &ON_OFF);

	/* zukÅnftige Ereignisse nÑherholen: */
	for(t=0; t<l_count; t++)
		if(liste[t].offset != 0)
			if(liste[t].next > now_time)
				liste[t].next -= ((liste[t].next-now_time)
								/liste[t].offset)*liste[t].offset;
	Fclose(han);
	save_list();
}

void del_batch_file(int kommando_nr)
{
	char dateiname[128];
	sprintf(dateiname, KOMM_STR, kommando_nr);
	Fdelete(dateiname);
}

void av_progstart(char *name)
{
	int buf[8] = {AV_STARTPROG,0,0};
	buf[1] = appl_id;
	*(char**)&buf[3] = name;
	*(char**)&buf[5] = NULL;
	appl_write(gem_id,16,buf);
	wind_update(END_UPDATE);
	evnt_timer(100,0);
	wind_update(BEG_UPDATE);
}
