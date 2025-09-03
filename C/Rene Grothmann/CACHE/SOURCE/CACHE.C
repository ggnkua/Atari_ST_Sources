#include <aes.h>
#include <stdio.h>
#include <tos.h>
#include <stdlib.h>
#include <string.h>
#include "cache.h"

/* Diese Funktionen und Variablen sind im externen Assembler-Modul
  CACHEMOD.S deklariert */ 
  
extern int 
	emul, /* Nummer des emulierten Drives */ 
	drivenum, /* Nummer, unter dem der Cache angesprochen wird */
	size, /* Grîûe des Cache in Sektoren */
	overhead, /* öberlaufgrîûe plus Cachegrîûe */
	readonly, /* Flag fÅr Nur-Lesen */
	althelp; /* Flag, ob ALT-HELP den Cache lîscht */
extern char *infos; /* Zeiger auf Cache */

int instal(void); /* installiert den Cache (mit Malloc) */
int remov(void);  /* beseitigt den Cache (mit Memfree) */
void clear(void); /* Lîscht Inhalt von Cache */

OBJECT *tree;

/* Die folgenden Funktionen dienen zur Manipulation der Resource.
   Vorsicht: Es wurde die OBJECT-Struktur von Turbo-C V1.0
   verwendet! Dies ist die unter GEM öbliche. */

void emul_get(int i, int j)
{	if (emul==i) tree[j].ob_state|=SELECTED;
	else tree[j].ob_state&=~SELECTED;
}

void drive_get(int i, int j)
{	if (drivenum==i) tree[j].ob_state|=SELECTED;
	else tree[j].ob_state&=~SELECTED;
}

void emul_set(int i, int j)
{	if (tree[j].ob_state & SELECTED) emul=i; }

void drive_set(int i, int j)
{	if (tree[j].ob_state & SELECTED) drivenum=i; }

int dialog(void)
{	char s1[256],s2[256];
	int x,y,w,h,ret;
	if (rsrc_gaddr(R_TREE,FORM,&tree)==0) return 0;
	((TEDINFO *)(tree[FSIZE].ob_spec))->te_ptext=s1;
	((TEDINFO *)(tree[FOVERH].ob_spec))->te_ptext=s2;
	if (althelp) tree[FALTH].ob_state|=SELECTED;
	else tree[FALTH].ob_state&=~SELECTED;
	if (readonly) tree[FROM].ob_state|=SELECTED;
	else tree[FROM].ob_state&=~SELECTED;
	itoa(size/2,s1,10); itoa((overhead-size)/2,s2,10);
	emul_get(0,A1);
	emul_get(1,B1);
	emul_get(2,C1);
	emul_get(3,D1);
	emul_get(4,E1);
	emul_get(5,F1);
	emul_get(6,G1);
	emul_get(7,H1);
	emul_get(8,I1);
	emul_get(9,J1);
	emul_get(10,K1);
	emul_get(11,L1);
	emul_get(12,M1);
	emul_get(13,N1);
	emul_get(14,O1);
	emul_get(15,P1);
	drive_get(0,A2);
	drive_get(1,B2);
	drive_get(2,C2);
	drive_get(3,D2);
	drive_get(4,E2);
	drive_get(5,F2);
	drive_get(6,G2);
	drive_get(7,H2);
	drive_get(8,I2);
	drive_get(9,J2);
	drive_get(10,K2);
	drive_get(11,L2);
	drive_get(12,M2);
	drive_get(13,N2);
	drive_get(14,O2);
	drive_get(15,P2);
	form_center(tree,&x,&y,&w,&h);
	graf_mouse(M_OFF,0);
	form_dial(FMD_START,0,0,0,0,x,y,w,h);
	form_dial(FMD_GROW,0,0,0,0,x,y,w,h); /* kann entfernt werden */
	objc_draw(tree,0,25,x,y,w,h);
	graf_mouse(M_ON,0);
	ret=form_do(tree,FSIZE); /* Hier muss der Benutzer das
			Formular bearbeiten */
	tree[ret].ob_state &= ~SELECTED; /* Exit-Object wieder auf
			nicht selektiert umstellen */
	graf_mouse(M_OFF,0);
	form_dial(FMD_SHRINK,0,0,0,0,x,y,w,h); /* kann entfernt werden */
	form_dial(FMD_FINISH,0,0,0,0,x,y,w,h);
	graf_mouse(M_ON,0);
	if (ret==FOK)
	{	size=2*atoi(s1); if (size<10) size=10;
		overhead=size+2*atoi(s2);
		althelp=((tree[FALTH].ob_state & SELECTED)!=0);
		readonly=((tree[FROM].ob_state & SELECTED)!=0);
		emul_set(0,A1);
		emul_set(1,B1);
		emul_set(2,C1);
		emul_set(3,D1);
		emul_set(4,E1);
		emul_set(5,F1);
		emul_set(6,G1);
		emul_set(7,H1);
		emul_set(8,I1);
		emul_set(9,J1);
		emul_set(10,K1);
		emul_set(11,L1);
		emul_set(12,M1);
		emul_set(13,N1);
		emul_set(14,O1);
		emul_set(15,P1);
		drive_set(0,A2);
		drive_set(1,B2);
		drive_set(2,C2);
		drive_set(3,D2);
		drive_set(4,E2);
		drive_set(5,F2);
		drive_set(6,G2);
		drive_set(7,H2);
		drive_set(8,I2);
		drive_set(9,J2);
		drive_set(10,K2);
		drive_set(11,L2);
		drive_set(12,M2);
		drive_set(13,N2);
		drive_set(14,O2);
		drive_set(15,P2);
	}
	return ret; /* Der Knopf mit dem das Formular verlassen wurde */
}

/* inst_remov installiert oder entfernt den Cache, je nachdem, ob
   er halt schon da ist odernicht. */

void inst_remov(void)
{
	if (infos==0) /* Cache nicht vorhanden? */
	{	infos=(char *)Malloc(size*516l);
		if (infos>0) 
			if (instal()) /* Kann sein, daû ein Fehler auftrat */
			form_alert(1,"[1][Cache installed.][Ok]");
			else
			form_alert(1,"[1][Couldn't instal cache.][Ok]");
		else
		form_alert(1,"[1][Out of memory.][Ok]");
	}
	else /* Cache vorhanden */
	{	if (remov()) /* Falls erfolgreich */
		{ form_alert(1,"[1][Cache removed.][Ok]"); 
		  if (Mfree(infos)!=0)
		  form_alert(1,"[1][Error in Mfree.|Suggest reboot!][Ok]");
		  infos=0; }
		else
		form_alert(1,"[1][Can't remove cache.|Better reboot!][Ok]");
	}
}

/* instal1 wird beim Anklicken des Accesories mit INSTAL aufgerufen.
   Es ruft nach Behandlung des Dialogs (Grîûe, Drive, usw.)
   instal_remov auf. */

void instal1(void)
{	int res;
	FILE *file;
	if (dialog()!=FOK) return;
	if (infos==0) inst_remov();
	else /* Cache schon da! */
	{ res=form_alert(2,
		"[2][Cache already installed.|Save Parameters?][Yes|No]");
	  if (res==1)
	  { file=fopen("cache.inf","w");
		if (file==0)
        { form_alert(1,"[1][Error on opening file.][Ok]");
          return; }
        fprintf(file,"renedrvi %d %d %d %d %d %d",
        	emul,drivenum,size,overhead,readonly,althelp);
        fclose(file);
      }
    }
}

/* remove1 wird auch Åber die Alertbox aufgerufen. */

void remove1(void)
{	if (infos!=0) inst_remov(); }

/* test_inf sucht nach einem File namens CACHE.INF und lÑdt
   von dort (falls vorhanden) die Parameter des Caches und installiert
   den Cache. */

void test_inf(void)
{	FILE *file;
	char s[256];
	file=fopen("cache.inf","r");
	if (file!=0)
	{	fscanf(file,"%s",s);
		if (strcmp(s,"renedrvi")==0)
		{	fscanf(file,"%d %d %d %d %d %d",
				&emul,&drivenum,&size,&overhead,&readonly,&althelp);
			inst_remov();
		}
		fclose(file);
	}
}

/* main ist ein typisches Accesorie Hauptprogramm, das stÑndig
   auf Action wartet. */

main()
{
	int menu_id,appl_id,event,res;
	int buffer[8];
	if ((appl_id=appl_init())==-1) return 1;
	if (rsrc_load("CACHE.RSC")==0) return 1;
	if ((menu_id=menu_register(appl_id,"  Cache  "))==-1) return 1;
	emul=0; drivenum=8;
	size=400; overhead=432;
	althelp=1; readonly=1;
	infos=0;
    test_inf();
	for (;;)
	{
		evnt_mesag(buffer);
		if ((buffer[0]==AC_OPEN)&&(buffer[4]==menu_id))
		{
		res=form_alert(3,"[1][Cache|by R. Grothmann          ]"
				"[Instal|Remove|Clear]");
			switch (res)
			{
				case 1 : instal1(); break;
				case 2 : remove1(); break;
				case 3 : clear(); break;
			}
		}
	}
}
	