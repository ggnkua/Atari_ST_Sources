/*
Jump! Marken im TURBO C Editor.
Geschrieben von Stefan Dreckmann mit TURBO C V2.0
und (ein bischen) MAS-68K V1.5
*/

/*---------Includes----------------------------*/
#include<aes.h>
#include<tos.h>
#include<string.h>
#include<stdlib.h>

/*---------Defines-----------------------------*/
#define ACC_NAME "  Jump! "
#define AUS 0
#define EIN !AUS
#define TASTATUR 1
#define MY_EVENT MU_MESAG | MU_TIMER
#define EVNT_TIME 200
#define TC_NAME "TC      "
/*
TC_NAME (fÅr appl_find()) MUSS! 8 Zeichen
haben! (Rest: Leerzeichen)
*/

#define SCAN_F1 0x3B0000L
#define SCAN_F10 0x440000L
#define SCAN_SHIFT_F1 0x540000L
#define SCAN_SHIFT_F10 0x5D0000L
#define CONTROL 4
#define SHIFT 1
#define NOTSTART 14
#define CONTROL_L 0x260012L
#define RETURN 0x1C000DL
#define ESCAPE 0x01001BL
#define SHIFT_PFEIL_LINKS 0x4B0034L
#define CONTROL_Y 0x2C0019L
#define INSERT 0x520000L

#define PAUSE 300
#define PAEUSCHEN 50

#define MAX_GEDULD 10
#define MAXMARKE 10
#define RUECKSPRUNG MAXMARKE-1
#define BELEGT 1

#define TRAP_ZWO 34

/*-----------globale Variablen-----------------*/
int accStatus=AUS;    /* Staus des Accessories */

IOREC* ioPtr;     /* Zeiger auf IOREC_Struktur */
long* bufferAdr; /* Anfang des Tastaturpuffers */

void (*trapZwoAdr)();   /* Originaladr.Trap #2 */
OBJECT** TCobjAdr;  /* Adresse 'Find Line' Box */
char* inputAdr;     /* Adresse Inputzeile */
int formDo;         /* Flag fÅr form_do() */
int objcDraw;       /* Flag fÅr object_draw() */


typedef struct
  {
  char string[10];  /* Platz fÅr den Ziffern */
  int belegt;       /* Belegungsflag */
  }marken;
marken marke[MAXMARKE];/* ein Feld von Marken */

/*-----Funktionsdeklarationen------------------*/
extern void kuckma_rein(void);/* Assemblerteil */

void acc_init(void);
int alert(int button,int meldung);
void init_iorec(void);
void switch_acc(void);
int switch_on(void);
void switch_off(void);
void action_keybd(int lesemarke);
char* get_inputAdr(void);
void tastendruck(long code);
int call_formular(void);
void formular_entfernen(void);
void gehezu_marke(int nr,int flag);
void marke_merken(int nr);
void zeile_merken(void);
void marke_entfernen(void);
void zeile_anpassen(int nr);
void autoswitch(void);

/*--------Hauptprogramm------------------------*/
main()
  {
  int dummy;   
  int event,alteLesemarke,keybdLesemarke;
  int i;
  int msgBuf[8];     /* der Messagepuffer */
  
  acc_init();
  init_iorec();
  
  for(i=0;i<MAXMARKE;i++)/* alle Marken... */
    marke[i].belegt= !BELEGT;/* ...unbelegt */
    
  keybdLesemarke = alteLesemarke = ioPtr->ibufhd;
  
  for(;;)   /* Endlosschleife, da Accessory */
    { /* Warte auf Message- oder Zeitereignis: */
    event=evnt_multi(MY_EVENT,0,0,0,0,0,0,0,0,0,
                    0,0,0,0,msgBuf,EVNT_TIME,0,
                    &dummy,&dummy,&dummy,&dummy,
                    &dummy,&dummy);
                    
    /* Tastendruck */
    if(accStatus && (keybdLesemarke = 
                 ioPtr->ibufhd) != alteLesemarke)
      action_keybd(alteLesemarke =
                                 keybdLesemarke);       
    else if(event & MU_MESAG)    /* Nachricht */
      if(msgBuf[0] == AC_OPEN)/*ACC angeklickt */
        switch_acc(); /* ein- oder ausschalten */
      else if(msgBuf[0] == AC_CLOSE && accStatus)
        autoswitch();/* auf AC_CLOSE reagieren */
    }
  }  

/*-----Funktionsdefinitionen-------------------*/
/*-----Accessory installieren------------------*/    
void acc_init(void)
  {
  extern _app;
  int ap_id;
  
  if(_app)    /* Wenn Accessory, _app == 0 */
    {
    alert(1,0); /*soll als PRG gestartet werden*/
    exit(0);
    }
/* beim AES anmelden und in MenÅleiste eintr. */
  ap_id=appl_init();
  menu_register(ap_id,ACC_NAME);
  }


/* Iorec initialisieren,Pufferanfang ermitteln */
void init_iorec(void)
  {
  ioPtr=Iorec(TASTATUR);/* Zeiger auf Struktur */
  bufferAdr=ioPtr->ibuf;/* Zeiger auf Buffer  */
  }

/*---Meldungen mittels form_alert()------------*/
int alert(int button,int meldung)
  {
  static char* meldungen[]=
    {
    "[3][Dieses Programm nur|als Accessory "
                            "starten.][Ach so]",
    "[2][         Jump!    |hilft TC auf die "
                 "SprÅnge][ Ein | Aus |Lîschen]",
    "[3][Dieses Accessory nur|mit TURBO C "
                            "benutzen!][Na gut]",
    "[3][Fehler beim Einschalten|von Jump!]"
                                      "[Mist!]",
    "[1][Diese Taste ist nicht belegt!]"
                                    "[Ach so!]",
    "[3][Dies ist die RÅcksprungtaste!]"
                            "[ Egal! |Abbruch]",
    };

  return(form_alert(button,meldungen[meldung]));
  }
  
/*--Acc. ein- oder ausschalten-----------------*/
void switch_acc(void)
  {
  int i,but,antwort;
  
  but = (accStatus == AUS) ? 1 : 2;
  if( (antwort=alert(but,1)) == 1)  /* ein? */
    if(appl_find(TC_NAME) >= 0)/* Hauptprogramm
                                        ist TC */
      if(switch_on() == 0) /* Einschalten
                                  erfolgreich? */
        accStatus=EIN;     /* Flag setzen */
      else
        alert(1,3);
    else
      {
      alert(1,2);
      accStatus=AUS;
      }
  else if(antwort==2)  /* ausschalten? */
    accStatus=AUS;     /* Flag lîschen */
  else                 /* lîschen */
    for(i=0;i<MAXMARKE;i++)
      marke[i].belegt = !BELEGT;
  }
  
/*---ACC einschalten---------------------------*/
int switch_on(void)
  {
  if(accStatus == AUS) /* ist es jetzt aus? */
    {
    if((inputAdr=get_inputAdr()) != 0)
      return 0;
    else
      return 1;
    }
  return 0;
  }
  
/*------auf Tastendruck reagieren--------------*/
void action_keybd(int lesemarke)
  {
  long code;
  int index;
  int flag = AUS;
  
  code = *(bufferAdr + lesemarke/4); /* Code 
                                        lesen */
  if(code >= SCAN_F1 && code <= SCAN_F10)
    {           /* Funktionstaste ohne SHIFT ? */
    accStatus=AUS;        /* Acc zeitweise aus */
    index=(int)(code >> 16) - 0x3B;/* Scancode in
                           Feldindex umrechnen */
    if( marke[index].belegt )/* Taste belegt? */
      {
      if(Kbshift(-1) == CONTROL)
        flag = EIN;
      gehezu_marke(index,flag);/* Marke
                                   anspringen */
      }
    else
      alert(1,4);
    accStatus=EIN;           /* Acc wieder ein */
    }
  else if(code >= SCAN_SHIFT_F1 &&
         code <= SCAN_SHIFT_F10) /* mit SHIFT? */
    {
    accStatus=AUS;
    index=(int)(code >> 16) - 0x54;  /* Scancode
                       in Feldindex umrechnen */
    marke_merken(index);
    accStatus=EIN;
    }
  }
  
/*--Adresse der Eingabezeile ermitteln---------*/
char* get_inputAdr(void)
  {
  OBJECT* adr;
  
  TCobjAdr=0;              /* Adresse auf 0 */
  if(call_formular())  /* Dialogbox aufrufen */
    {
    if(TCobjAdr == 0 || *TCobjAdr == 0)/* Fehler
                             (z.B im Desktop) */
      {
      formular_entfernen();
      return 0;
      }
    adr= *TCobjAdr;      /* Adresse Åbernehmen */
  
  /* das gesuchte Objekt muû "EDITABLE" sein: */
    while(adr->ob_flags != EDITABLE)   
      {
      if(adr->ob_next >0) /* entweder nÑchstes 
                              Elternobjekt... */
        adr = *TCobjAdr + adr->ob_next;
      else if(adr->ob_head >0)    /* ...oder
                           nÑchstes Kindobjekt */
        adr = *TCobjAdr + adr->ob_head;
      else       /* falls keines mehr Åbrig... */
        {
        formular_entfernen();
        return 0;          /* ...Notfall!!! */
        }
      }
    formular_entfernen();
    marke_entfernen();
    return(adr->ob_spec.tedinfo->te_ptext);/*Adr.
              des Eingabestrings zurÅckliefern */
    }
  return 0;
  }
  
/*-------'Find Line' Formular holen------------*/
int call_formular(void)
  {
  int time_out=0;         /* "RundenzÑhler" */
  
  formDo=0;          /* form_do - Flag lîschen */
  objcDraw=0;    /* object_draw - Flag lîschen */
  trapZwoAdr=Setexc(TRAP_ZWO,kuckma_rein);/* Ass.
                             Routine einhÑngen */
	Kbshift(CONTROL); /* CONTROL */
  tastendruck(CONTROL_L);/* Tastendruck
                         CONTROL L simulieren */
  while( !objcDraw )/* warten bis TC reagiert */
    {
    evnt_timer(PAEUSCHEN,0);
    if(time_out++ >= MAX_GEDULD)/*klappt nicht*/
      {
      Setexc(TRAP_ZWO,trapZwoAdr);/* Original
                          routine einhÑngen */
      Kbshift(0);         /* normal */
      return 0;
      }
    }
  Kbshift(0);             /* Tastatur normal */
  while( !formDo )/* warten bis die Box fertig */
    evnt_timer(PAEUSCHEN,0);
  Setexc(TRAP_ZWO,trapZwoAdr); /* Original
                            routine einhÑngen */
  
  return 1;
  }

/*----Formular entfernen-----------------------*/
void formular_entfernen(void)
  {
  tastendruck(RETURN); /* RETURN simulieren */
  }
  
/*---Simulation eines Tastendrucks-------------*/
void tastendruck(long code)
  {
  *(bufferAdr) = code; /* Code an den Anfang des
                     Tastaturpuffers schreiben */
  ioPtr->ibuftl=0;       /* Schreib- und */
  ioPtr->ibufhd=ioPtr->ibufsiz;  /* Lesemarke
                                     versetzen */
  while( ioPtr->ibufhd == ioPtr->ibufsiz )  
    evnt_timer(PAEUSCHEN,0);/* warten bis Zeichen
                                   ausgelesen */
  }
  
/*-----Marke anspringen------------------------*/
void gehezu_marke(int nr,int flag)
  {
  char* position;
  long code;
  char rueck[10];                 

  if(flag)            /* falls gewÅnscht... */
    zeile_merken();   /* akt. Zeile merken */
  if(call_formular()) /* Formular aufrufen */
    {
    if(nr != RUECKSPRUNG)/* es ist nicht die 
                              RÅcksprungtaste */
      {   /* Zeile fÅr RÅcksprung merken: */
      strcpy(marke[RUECKSPRUNG].string,inputAdr);
      marke[RUECKSPRUNG].belegt = BELEGT;/* Bele
                          gungsflag RÅcksprung */
      }
    else /* Falls es die RÅcksprungraste war */
      strcpy(rueck,inputAdr); /* Zeilennummer
                             zwischenspeichern */
    position=marke[nr].string;/* Zeiger auf den
                                 Zeilenstring */
    tastendruck(ESCAPE); /* ESCAPE-Taste
                                     simulieren */
    while ((code=(long)*position++) != 0)
      tastendruck(code); /* Tastendruck auf
                       Zifferntaste simulieren */
    formular_entfernen();    /* bewirkt Sprung */
    marke_entfernen();   
    if(flag)           /* falls Kopierfunktion */
      zeile_anpassen(nr);/* fertig zum EinfÅgen */
    if(nr == RUECKSPRUNG) /* RÅcksprungtaste */
      strcpy(marke[RUECKSPRUNG].string,rueck);
                     /* gespeicherte Nr. holen */
    }
  }
  
/*-----Marke festlegen-------------------------*/
void marke_merken(int nr)
  {
  if(nr == RUECKSPRUNG)/* RÅcksprungtaste sollte
                           nicht belegt werden */
    if(alert(2,5) == 2)/* Warnung akzeptiert? */
      return;            /* keine Aktion */
      
  if(call_formular())   /* Formular aufrufen */
    {
    strcpy(marke[nr].string,inputAdr);  /* Zeilen
                            string Åbernehmen */
    formular_entfernen();
    marke_entfernen();
    marke[nr].belegt = BELEGT;/* Belegungsflag */
    }
  }

/*-------Zeile in den Zwischenspeicher---------*/
void zeile_merken(void)
  {
  Kbshift(CONTROL); /* CONTROL */
  tastendruck(CONTROL_Y);/* Zeile lîschen
                       (kommmt in den Buffer) */
  evnt_timer(PAUSE,0);   /* Reaktion abwarten */
  tastendruck(INSERT);/* Zeile wieder einfÅgen */
  evnt_timer(PAUSE,0);  /* wieder warten */
  Kbshift(0);           /* Tastatur normal */
  }
  
/*---------Marke entfernen---------------------*/
void marke_entfernen(void)
  {
  Kbshift(SHIFT);          /* SHIFT */
  tastendruck(SHIFT_PFEIL_LINKS);   /* Cursor an
                       den Anfang der Zeile...*/
  Kbshift(0);              /* Tastatur normal */
  }


/*-----------Zeilennummer erhîhen--------------*/
void zeile_anpassen(int nr)
  {
  int akt_zeile;
  int zeile,i;
  
  akt_zeile=atoi(marke[nr].string);
  for(i=0;i < MAXMARKE;i++)
    if((zeile=atoi(marke[i].string))>=akt_zeile)
      itoa(++zeile,marke[i].string,10);
  }
  
/*-----automatisches Ein-/Ausschalten----------*/
void autoswitch(void)
  {
  int msg[8];
  int dummy;
  
  for(;;)
    {
    evnt_mesag(msg);  /* auf Nachricht warten */
    if(msg[0] == AC_CLOSE)/* Neustart des ACCs */
      {
      evnt_multi(MY_EVENT,0,0,0,0,0,0,0,0,0,0,0,
                 0,0,msg,PAUSE,0,&dummy,&dummy,
                 &dummy,&dummy,&dummy,&dummy);
      if(appl_find(TC_NAME) < 0)/* neues Haupt
                        programm ist nicht TC */
        accStatus = AUS;    /* ACC ausschalten */
      break;             /* Schleife abbrechen */
      }
    else if(msg[0] == AC_OPEN)     /* ACC soll 
                              gestartet werden */
      if(Kbshift(-1) == NOTSTART)  /* aber nur
                                 per Notstart */
        {
        accStatus = AUS;   /* Flag auf Aus */
        switch_acc();      /* Startroutine */
        break;           /* Schleife verlassen */
        }
    }
  }