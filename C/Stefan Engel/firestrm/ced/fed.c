#define REGISTRATION  "Registred to: Public domain by FireSTorm Atari Center"
#define NUMBER				5

/********


Registreringsinformation:

NUMBER		REGISTRATION
1                   "Christian Dahl ..."
2                   "Mikke Mattsson, FireSTorm BBS, 46-54-834731"
3                   "Bertil J„g†rd, STraight BBS, 46-31-363973"
4                   "Alexander Bochmann, Traveller-Box, 49-761-381571"
5                   "Public Domain by FireSTorm Atari Center"



********/

/**********
**
**
** Flaggor att s„nda med:
**
**	R  = Resetta terminalen innan menyn visas
**  S  = S„nd text till serieporten
**  L  = S„nd text lokalt
**  Y  = Fr†ga om meddelandet skall quotas, default Y
**  N  = Fr†ga om meddelandet skall quotas, default N
**  Q  = Quota utan att fr†ga
**  Pn = St„ller vilken port som skall anv„ndas
**  F  = Force Seriell utskrift
**
**
** Snabbtangenter:
**
**  <CTRL> + D = Žndra subjectet
**  <CTRL> + T = Žndra to
**  <CTRL> + A = B”rjan av raden
**  <CTRL> + E = Slutet av raden
**  <CTRL> + V = N„sta sida
**  <CTRL> + C = F”reg†ende sida
**  <CTRL> + U = L„gg in en tom rad
**  <CTRL> + Y = Ta bort rad
**  <CTRL> + K = Ta bort rad
**  <CTRL> + Z = Spara och avsluta
**  <CTRL> + S = Spara och avsluta
**  <CTRL> + Q = Avsluta (abort)
**  <CTRL> + W = Visa hj„lpfil
**  <CTRL> + R = Rita om sk„rmen
**  <CTRL> + L = Rita om sk„rmen
**
**
************/

#include <stdio.h>
#include <osbind.h>

int main(int,char **,char **);
void SetUpStructure(int,char **);
void RedrawMenu(int);
void GoToXY(int,int);
void ClearLowerCursor(void);
void ClearCurrentLine(void);
void GoDown(void);
void RedrawWholeText(void);
int savemessage(void);
int kill_text(void);
int wait_for_spacereturn(void);
void show_help_screen(void);
void move_left(void);
void move_right(void);
void InsertEmptyRow(void);
int move_up(int);
int FindTop(void);
int move_down(int);
void DeleteChar(int);
void DeleteCharFromCursorVT52(int);
void DeleteCharFromCursor(void);
void backspace(void);
void delete(void);
void AddCharToCursorVT52(int);
void AddChar(unsigned char,int);
void AddCharToCursor(void);
void InsertCharacter(unsigned char);
void KillMessageLine(void);
void KillLineOnScreen(void);
void PrintLowerLine(void);
void DeleteThisLine(void);
void KillToEndOfLine(void);
void MoveRow(char *,char *);
void StartEditSubject(void);
void StartEditTo(void);
void preform(unsigned char);
void Quote(void);
void SetupInternalFlags(char *);
int FindFlag(char *,char);
unsigned char character(void);
void ResetTerminal(void);
void MoveRowToMessage(void);
void MoveMessageToRow(void);
int FindPreviousRow(void);
int FindNextRow(void);
void NewLineHere(void);
void ReverseOn(void);
void ReverseOff(void);
void Print(char *,char *);
void Put(int,char *);
void ScrollUp(void);
void FixLastLine(void);


#define TAG            "\n\n- CeD 1.00, registred version!\n--- Speed is essential "

#define MAX            32000

#define	MAXWIDTH       76
#define TABWIDTH       4

#define SCREEN         2
#define SERIAL         pucko

#define TRUE           1
#define FALSE          0

#define NONE           0
#define YES            1
#define NO             2

#define CURSORUP       254
#define CURSORDOWN     253
#define CURSORLEFT     252
#define CURSORRIGHT    251
#define LOGOUT         255
#define ESC            27

#define TEXTSTART      4
#define TO             2
#define SUBJ           3
#define START          6
#define MAXTO          35
#define MAXSUBJ        71

#define SAVETEXT       0
#define RUN            1
#define ABORTTEXT      2
#define TIMEOUT        3
#define CARRIERLOST    4
#define RESETTERMINAL  0x0001
#define TOSERIAL       0x0002
#define TOLOCAL        0x0004
#define NOLL           0

#define ASCII          0
#define VT52COLOR      1
#define VT52MONO       2
#define ANSICOLOR      3
#define ANSIMONO       4
#define	AVATAR         5
#define VT52FALCON     6

#define QBBSASCII      0
#define QBBSVT52MONO   1
#define QBBSVT52COLOR  2
#define QBBSVT52STAND  3
#define QBBSANSI       4

struct                             /* Struktur Octopus anv„nder f”r MSGINFO.FSE       */
{
  char  Version[15];               /* Octopus version                                 */
  char  From[36];                  /* User who created msg                            */
  char  To[36];                    /* User who may read msg                           */
  char  Subj[72];                  /* Subject                                         */
  char  Sysop[36];                 /* Sysop name                                      */
  char  Systemname[80];            /* System name                                     */
  char  Areaname[35];              /* Area name (ATARI.028)                           */
  char  Areadesc[80];              /* Area description                                */
  char  Quotetext[80];             /* Quoted message text file                        */
  char  Userfile[80];              /* path & name from Userfile                       */
  unsigned short  messages;        /* Total messages in echo                          */
  unsigned long  seconds_left;     /* Seconds left 'today'                            */
  unsigned short timeout;          /* Timeout in seconds                              */
  char  emulation;                 /* Screen Emulation nr.                            */
  char  Port;                      /* Modem port(Bconin/out)                          */
  unsigned char screenlength;      /* Length of screen                                */
  unsigned char Scr_width;         /* Width of screen                                 */
  char Domain [13];                /* Domain, "" when unused                          */
  unsigned short OrgZone,
                 OrgNet,
                 OrgNode,
                 OrgPoint;
  unsigned short DestZone,
                 DestNet,
                 DestNode,
                 DestPoint;
  char Reserved [20];              /* Reserved for future                             */
} msginfo;

int shutdown=RUN;                  /* Avslutningsvariabel                             */
int Serial=FALSE;                  /* Skriva till serieporten?                        */
int SerialF=FALSE;                 /* Tvinga utskrift till serieporten                */
int Screen=FALSE;                  /* Till sk„rmen?                                   */
int Settings=NOLL;                 /* Flaggor till programmet                         */
int AskQuote=NONE;                 /* Fr†ga om quota                                  */
char message[MAX+5];               /* Meddelandebuffer                                */
long lmessage;                     /* L„ngd p† meddelande-buffer                      */
char out[90],out2[90];             /* Utskriftsbuffer                                 */
int topwindow;                     /* Pekare vart f”nstret i texten b”rjar            */
int currentline;                   /* Pekare till aktuell rad i texten                */
char currenttext[90];              /* Aktuell rad i snabbminne                        */
int X,Y,oldX;                      /* x och y-positions p† sk„rmen                    */
char crlf[]={13,10,0};             /* Str„ng f”r \r\n                                 */
char cr[]={13,0};                  /* Str„ng f”r \r                                   */
char fastdel[]={32,8,0};           /* Tar bort ett tecken                             */
long Time;                         /* Aktuell tid, och serienr p† vems version det „r */
char Esc = FALSE;                  /* Ingen Esc-code „n                               */
int pucko = 1;                     /* Vilken seriedevice som skall anv„nds            */
int QBBS = FALSE;                  /* QBBS-format p† MSGINFO.FSE                      */

int main(int argc,char *argv[],char *envp[])
{
  unsigned char tangent;

  Time = NUMBER;
  SetUpStructure(argc,argv);       /* S„tt upp intern struktur                        */

  Quote();                         /* Quota texten, och l„gg in i buffer              */
  MoveMessageToRow();

  if(Settings && RESETTERMINAL)
    ResetTerminal();
  RedrawMenu(TRUE);	               /* Rita upp menyn                                  */
  RedrawWholeText();               /* Skriv ut texten */

  do
  {
     tangent = character();        /* F† en tangent fr†n serie eller tang.bord       */
     preform(tangent);             /* Utf”r aktuell aktion                           */
  }while(shutdown == RUN);
  MoveRowToMessage();
  if(shutdown == SAVETEXT)
  {
    Print("\n\rSaving...","\n\rSaving...");
    shutdown = savemessage();      /* Spara meddelandet                              */
  }
  if(Settings && RESETTERMINAL)
    ResetTerminal();
  Print(REGISTRATION,REGISTRATION);
/*	SaySHAREWARE();*/
  Print("\n\rReturning...","\n\rReturning...");
  return shutdown;                 /* Returnera                                      */
}

/*
void SaySHAREWARE(void)
{
  long counter;
  char buff[90];
  short *Stack;

  Stack = Super((short *)NOLL);
  counter = *((long *)(0x4ba));
  counter += 200 * 5;
  if(Settings && RESETTERMINAL)
    ResetTerminal();
  sprintf(buff,"\n\r%s","");
  Print(buff,buff);
  sprintf(buff,"\n\r%s","");
  Print(buff,buff);
  sprintf(buff,"\n\r%s","        ((((((((((((((((                         ((((((((((((((");
  Print(buff,buff);
  sprintf(buff,"\n\r%s","       (((((                                     (((((         ((");
  Print(buff,buff);
  sprintf(buff,"\n\r%s","       (((((                                     (((((          ((");
  Print(buff,buff);
  sprintf(buff,"\n\r%s","       (((((                                     (((((          ((");
  Print(buff,buff);
 sprintf(buff,"\n\r%s","       (((((                     ((((((((((      (((((          ((");
  Print(buff,buff);
  sprintf(buff,"\n\r%s","       (((((                    (((      (((     (((((         ((");
  Print(buff,buff);
  sprintf(buff,"\n\r%s","       (((((                    (((      (((     (((((        ((");
  Print(buff,buff);
  sprintf(buff,"\n\r%s","       (((((                    (((((((((((      (((((      ((");
  Print(buff,buff);
  sprintf(buff,"\n\r%s","       (((((                    (((              (((((    ((");
  Print(buff,buff);
  sprintf(buff,"\n\r%s","       (((((                    (((              (((((  ((");
  Print(buff,buff);
  sprintf(buff,"\n\r%s","        (((((((((((((((((((      ((((((((((((    (((((((");
  Print(buff,buff);
  sprintf(buff,"\n\r%s","");
  Print(buff,buff);
  sprintf(buff,"\n\r%s","                                               version 1.00");
  Print(buff,buff);
  sprintf(buff,"\n\r%s","");
  Print(buff,buff);
  sprintf(buff,"\n\r%s","               This program is SHAREWARE! Please register!");
  Print(buff,buff);
  while(*((long *)(0x4ba)) < counter);
  Super(Stack);
}*/

void SetUpStructure(int argc,char *argv[])	/* S„tt upp strukturen */
{
  FILE *filehandle;
  int i;

  for(i = 0;i < argc;i++)       /* Leta fram om det finns n†gra options */
    if(argv[i][0] == '-')
    {
      SetupInternalFlags(argv[i]);
      break;
    }
  if((filehandle = fopen("COMMAND.CED","r")) != NULL)
  {
    fgets(out,10,filehandle);
      SetupInternalFlags(out);
      fclose(filehandle);
  }
}

void Put(int dest,char *string)
{
  register i;

  for(i = 0;*(string + i) != (char)NULL;i++)
     Bconout(dest,*(string + i));
}

void RedrawMenu(int i)		/* Ritar upp en meny */
{
  Print("H","[1;1H");
  ReverseOn();	
  sprintf(out,"l#%d/%d  %s\n\r",msginfo.messages+1,msginfo.messages,msginfo.Areadesc);
  sprintf(out2,"[2K[30m#%d/%d  %s\n\r",msginfo.messages+1,msginfo.messages,msginfo.Areadesc);
  Print(out,out2);
  if(i)
  {
    sprintf(out,"lFrom: %s  bN(Press CTRL-P for help)b@\n\r",msginfo.From);
    sprintf(out2,"[2KFrom: [37m%s  [36m(Press CTRL-P for help)\n\r",msginfo.From);
    Print(out,out2);
    sprintf(out,"l  To: %s\n\r",msginfo.To);
    sprintf(out2,"[2K[30m  To: [37m%s\n\r",msginfo.To);
    Print(out,out2);
    sprintf(out,"lSubj: %s\n\r",msginfo.Subj);
    sprintf(out2,"[2K[30mSubj: [37m%s\n\r",msginfo.Subj);
    Print(out,out2);
  }
  else
  {
    sprintf(out,"\n\n\n\r");
    Print(out,out);
  }
  ReverseOff();		/* R„tt f„rg */
}

void Print(char *t1,char *t2)		/* Allm„n runtin f”r att skriva ut text */
{				/* t1 = VT52-emulering			t2 = ANSI-emulering */
  if(Screen)
    Put(SCREEN,t1);		/* Om till sk„rmen skriv ut VT52 */
  if(Serial)					/* Om till porten skriv med r„tt emulering */
    switch(msginfo.emulation)
    {
      case ASCII        : exit(-1); break; /* ASCIIanv„ndare kan ej anv„nda CeD */
      case ANSICOLOR    :
      case ANSIMONO     :
      case AVATAR       : Put(SERIAL,t2); break;
      case VT52COLOR	:
      case VT52MONO		:
      case VT52FALCON	:	Put(SERIAL,t1); break;
    }
}

void ResetTerminal(void)   /* Resettar terminalen */
{
  ReverseOff();
  Print("ewqE","[?7l[?1l[?3l[?9l[?6l#5[4l[2J");
}

void GoToXY(int x,int y)
{
  if(Y == TO || Y == SUBJ)
    x += START;

  sprintf(out,"Y%c%c",(char)(y+32),(char)(x+32));
  sprintf(out2,"[%d;%dH",(char)(y+1),(char)(x+1));

  Print(out,out2);
}

void fGoToXY(int output,int x,int y)
{
  if(Y == TO || Y == SUBJ)
    x += START;

  sprintf(out,"Y%c%c",(char)(y+32),(char)(x+32));
  sprintf(out2,"[%d;%dH",(char)(y+1),(char)(x+1));

  if(output == SCREEN)
    Put(SCREEN,out);		/* Om till sk„rmen skriv ut VT52 */
  if(output == SERIAL)	/* Om till porten skriv med r„tt emulering */
    switch(msginfo.emulation){
      case ASCII        : exit(-1); break; /* ASCIIanv„ndare kan ej anv„nda CeD */
      case ANSICOLOR    :
      case ANSIMONO     :
      case AVATAR       : Put(SERIAL,out2); break;
      case VT52COLOR    :
      case VT52MONO     :
      case VT52FALCON   : Put(SERIAL,out); break;
    }
}

void ClearLowerCursor(void)
{
  Print("J","[0J");
}

void ClearCurrentLine(void)
{
  sprintf(out,"%cl",13);
  Print(out,"[2K");
}

void GoDown(void)           /* G† ett steg ner†t */
{
  Print("B","[1B");
}

void GoUp(void) 	          /* G† ett steg upp†t */
{
  Print("A","[1A");
}

void RedrawWholeText(void)		/* Ritar om hela texten i f”nstret */
{
  char *msg,m[90],*tom;
  int i;

  msg = topwindow + message;

  GoToXY(0,TEXTSTART);
  ClearLowerCursor();
  for(i = TEXTSTART;i < (int)msginfo.screenlength;i++)
  {
    ClearCurrentLine();

    tom = m;
    while(*msg != 10)
    {
      if(*msg == NOLL)
      {
        i = msginfo.screenlength;
   	    break;
      }
      *tom = *msg;
      msg++,tom++;
    }
    *(tom++) = 13;
    *tom = NOLL;
    Print(m,m);
    msg++;
    GoDown();
  }
  GoToXY(X,Y);
}

int savemessage(void)		/* Sparar meddelandet */
{
  FILE *filehandle;

  if(!QBBS)
  {
    if((filehandle = fopen("MSGINFO.FSE","wb")) != NULL)
    {
      if(fwrite((char *)(&msginfo),sizeof(msginfo),1,filehandle) != 1)
      {
        printf("\nError during write of messageinfofile!!");
        exit(-1);
      }
      fclose(filehandle);
    }
  }
	else{
	  if((filehandle = fopen("MSGINFO.FSE","wb")) != NULL){
			fprintf(filehandle,"%s\n",msginfo.From);
			fprintf(filehandle,"%s\n",msginfo.To);
			fprintf(filehandle,"%s\n",msginfo.Subj);
    	fprintf(filehandle,"%d\n",NOLL);
    	fprintf(filehandle,"%d\n",NOLL);
	    fprintf(filehandle,"%s\n",msginfo.Areadesc);
			fprintf(filehandle,"%d\n",msginfo.messages);
			fclose(filehandle);
		}
	}
	if((filehandle = fopen("MSGTEXT.FSE","wb")) != NULL){ /* msginfo.Quotetext */
		for(;lmessage > NOLL && (message[lmessage] == NOLL || message[lmessage] == 10 ||
					message[lmessage] == 13 || message[lmessage] == ' ');lmessage--);
		lmessage++;
		fwrite(message,lmessage,1,filehandle);
/*		fprintf(filehandle,"%s",TAG);*/
		fclose(filehandle);
	}
	return(NOLL);
}

int CheckMFP(void)		/* Kollar om carrier finns p† MFP-porten */
{
	short *Stack;
	char mfp;

	Stack = Super((short *)NOLL);
	mfp = *((char *)(0xfffffa01));
	Super(Stack);
	if(!(mfp & 2))
		return TRUE;
	return FALSE;
}

int CheckSCC(int select)		/* Kollar om carrier finns p† SCC */
{
	short *Stack;
	int		scc;

	Stack = Super((short *)NOLL);
	scc = (GetDcd);

	section data

	xdef	_GetDcd

_GetDcd:
	move.b	#0,$ffff8c85.w	; SCC Channel B, Read Register 0
	move.b	$ffff8c85,d0	; read value into d1, DCD is bit #3.

	and.l	#$8,d0		; And DCD mask
	rts										; back to main

	END
	Super(Stack);
	return scc;
}

int CheckCarrier(void)			/* Kollar om carrier finns */
{
	if(SerialF)
		return TRUE;
	switch(SERIAL){
		case  1 :	/* AUX */
		case  6 :	/* MODEM1 */
							return CheckMFP();	/* Kolla vanlig MFP-port */

		case  2 : /* Lokal sk„rm, ingen carrier */
							return FALSE;

		case  3 :	/* MIDI */
							return TRUE;							/* MIDI, alltid carrier */

		case  7 :	/* MODEM2 */
							return CheckSCC(5);
		case  8 :	/* SERIAL1 */
							return TRUE;
    case  9 :	/* SERIAL2 */
							return CheckSCC(1);
		default :	return FALSE;
	}
	return FALSE;
}

unsigned char character(void)		/* Inv„ntar/tolkar en tangenttryckning */
{
	int timeout;
	long character = NOLL,t;

	timeout = msginfo.timeout;		/* Inaktivitetstimeout */

	do{
		if(Screen){
		  if(Bconstat(SCREEN) == -1){
				character = Bconin(SCREEN);		/* H„mta tangent */
				if(!(character & 0xFF)){
					switch(character){					/* En lokal konstighet */
						case 0x4B0000 : character = CURSORLEFT;		/* V„nster */
														break;
						case 0x4D0000 : character = CURSORRIGHT;	/* H”ger */
														break;
						case 0x480000 : character = CURSORUP;			/* Upp */
														break;
						case 0x500000 : character = CURSORDOWN;		/* Ner */
														break;
						default				: character = NOLL;
														break;
					}
				}
			}
		}
  	if(Serial){					/* Ta emot tangenter fr†n serieporten? */
    	if(Bconstat(SERIAL) == -1){
				character = Bconin(SERIAL);
				character &= 0xFF;
				if(character == ESC)	/* Ja, se till att konvertera piltangenter */
					Esc = TRUE;
				if(Esc){
					switch(character){
						case 'A'	: character = CURSORUP,Esc = FALSE;		/* Upp enl. VT-52 */
												break;
						case 'B'	: character = CURSORDOWN,Esc = FALSE;	/* Ner enl. VT-52 */
												break;
						case 'C'	: character = CURSORRIGHT,Esc = FALSE;/* H”ger enl. VT-52 */
												break;
						case 'D'	: character = CURSORLEFT,Esc = FALSE;	/* V„nster enl. VT-52 */
												break;

						case '['	:
						case ESC	: character = NOLL;
												break;
						default		: Esc = FALSE;
					}
				}
				else
					Esc = FALSE;
			}
		}
		time(&t);
		if(t != Time){
			Time = t;
			timeout-=2;
			msginfo.seconds_left-=2;
			if(Serial)
				if(!CheckCarrier())
					shutdown = CARRIERLOST,character = LOGOUT;
		}
		if(timeout < NOLL || msginfo.seconds_left < NOLL)
			character = LOGOUT,shutdown = TIMEOUT;
	} while((character & 0xFF) == NOLL);

	return (unsigned char)(character & 0xFF);
}

int kill_text(void)
{
	int tang,ret;

	GoToXY(0,0);
	if(Y == SUBJ || Y == TO)
		ReverseOff();
	ClearCurrentLine();
	Print("Abort message [y/N] ","Abort message [y/N] ");
	do{
		tang = character();				/* H„mta en tangent */
		switch(tang){
			case 'y' :		/* Yes */
			case 'Y' :	ret = TRUE,tang = NOLL;
									Print("Yes","Yes");
									break;
			case 13  :		/* Return */
			case 'n' :		/* No */
			case 'N' :	ret = FALSE,tang = NOLL;
									Print("No","No");
									break;
			default  : tang = TRUE;
		}
	} while(tang != NOLL);
	if(Y == SUBJ || Y == TO)
		ReverseOn();
	return ret;
}

int wait_for_spacereturn(void)		/* V„ntar p† space eller return */
{
	unsigned char tangent;

	tangent = 0;
	do{
		tangent = character();
		if(tangent == 17 || tangent == 'S' || tangent == 's')
			return(TRUE);
	} while((tangent != ' ') && (tangent != 13));
	return FALSE;
}

void show_help_screen(void)       /* Visar hj„lp-sk„rmen */
{
  FILE *filehandle;
  int x,y,i,waiter;
  char loadstring[100];

  Print("H","[1;1H");
  ReverseOn();
	Print("l","[2K");
	strcpy(loadstring,"  CeD, the fullscreeneditor for Atari BBS systems, written by Christian Dahl!\n\r");
  Print(loadstring,loadstring);
	Print("l","[2K");
	strcpy(loadstring,"               This editor is a registred sharewareprogram. \n\r");
  Print(loadstring,loadstring);
	Print("l","[2K");
	sprintf(loadstring,"          %s\n\r",REGISTRATION);
  Print(loadstring,loadstring);
	Print("l","[2K");
	strcpy(loadstring,"  Programmer: Christian Dahl on 2:203/611.4 or di3dah@f_utbserv.adbutb.hks.se\n\r");
  Print(loadstring,loadstring);
  ReverseOff();
  Print("KJl","[0J");   /* Rensa nedre delen av hj„lpf”nstret */

  x = 0,y = 4,waiter = 0;
  GoToXY(x,y);

  filehandle = fopen("CEDHELP.TXT","r");   /* ™ppna hj„lpfilen */
  if(filehandle != NULL){
    while(fgets(loadstring,99,filehandle) != NULL){
      for(i = NOLL;i < 100;i++)
        if(loadstring[i] == 10)
          loadstring[i] = 0;
      Print(loadstring,loadstring);
			Print(cr,cr);
      y++,waiter++;
      if(waiter > (msginfo.screenlength - 5)){
        waiter = 0;
        if(wait_for_spacereturn())
					return;
      }
      if(y > (msginfo.screenlength-1)){	/* Dax att scrolla den andra sk„rmen upp†t? */
				Print(cr,cr);
    		ScrollUp();
			}
			else
				Print(crlf,crlf);
    }
    fclose(filehandle);       /* St„ng hj„lpfilen */
  }
  else{       /* Hittade inte hj„lpfilen */
    sprintf(out,"\n\n\n\n			    CEDHELP.TXT not found!");
    Print(out,out);
  }
  wait_for_spacereturn();
}

void fastUp(void)
{
	Print("A","[A");
}

void fastDown(void)
{
	Print("B","[B");
}

void fastLeft(void)
{
	Print("D","[D");
}

void fastRight(void)
{
	Print("C","[C");
}

void move_left(void)			/* Flyttar cursorn v„nster i brevet */
{
	if(X == NOLL){	/* Flytta upp till raden ovanf”r sist */
		if(move_up(FALSE)){
			X = strlen(currenttext);
			GoToXY(X,Y);
		}
	}
	else{			/* Flytta vanligt till v„nster */
		X--;
		fastLeft();		/* GoToXY(X,Y); */
	}
	oldX = X;
}

void move_right(void)			/* Flyttar cursorn h”ger i brevet */
{
	if(X >= strlen(currenttext)){	/* Flytta upp till raden nedanf”r f”rst */
		if(move_down(FALSE)){
			X = NOLL;
			GoToXY(X,Y);
		}
	}
	else{			/* Flytta vanligt till h”ger */
		X++;
		fastRight();		/* GoToXY(X,Y); */
	}
	oldX = X;
}

void InsertEmptyRow(void)		/* L„gger in en tom rad vid aktuell cursor */
{
	sprintf(out,"%cL",13);
	sprintf(out2,"%c[1L",13);
	Print(out,out2);
}

int move_up(int i)			/* Flyttar cursorn upp†t i brevet */
{
	int oldoldX;

	if(Y == SUBJ){
		StartEditTo();
		return TRUE;
	}
	if(Y == TO)
		return FALSE;
	if(Y == TEXTSTART){	/* Scrolla upp†t */
		MoveRowToMessage();
		if(FindPreviousRow()){
			MoveMessageToRow();
			InsertEmptyRow();
			Print(currenttext,currenttext);
			X = oldX;
			if(X > strlen(currenttext))
				X = strlen(currenttext);
			if(i)
				GoToXY(X,Y);
			topwindow = currentline;
			return TRUE;
		}
		else
			return FALSE;
	}
	else{			/* Flytta vanligt upp†t */
		MoveRowToMessage();
		Y--;
		FindPreviousRow();
		MoveMessageToRow();
		oldoldX = X;
		X = oldX;
		if(X > strlen(currenttext))
			X = strlen(currenttext);
		if(i)
			if(X == oldoldX)
				fastUp();
			else
				GoToXY(X,Y);
		return TRUE;
	}
	return FALSE;
}

int FindPreviousRow(void)		/* Hittar f”reg†ende rad */
{
	char *msg;

	if(currentline == NOLL)
		return FALSE;
	currentline--;
	if(message[currentline] == 10 || message[currentline+1] == NOLL){
		if(currentline != NOLL){
			currentline--;
				msg = message + currentline;
				while(*msg != 10){
					if(currentline == NOLL)
						return TRUE;
					msg--,currentline--;
				}
		}
		else
			return TRUE;
	}
	else
		return FALSE;
	currentline++;
	return TRUE;
}

void ScrollUp(void)			/* Scrollar upp sk„rmen */
{
	sprintf(out,"%cjY$ Mk",13);
	sprintf(out2,"%c7[5;0H[1M8",13);
	Print(out,out2);
}

int FindTop(void)
{
	int i,j;
	char *msg;

	i = msginfo.screenlength - TEXTSTART - 1;
	j = currentline;
	if(j == NOLL)
		return j;
	j--;
	if(message[j] == 10){
		if(j != NOLL){
			j--;
			msg = message + j;
			while(i > NOLL){
				if(j == NOLL)
					return j;
				if(*msg == 10)
					i--;
				msg--,j--;
			}
		}
		else
			return j;
	}
	else
		return j;
	j+=2;
	return j;
}

int move_down(int i)			/* Flyttar cursorn ned†t i brevet */
{
	int oldoldX;

	if(Y == SUBJ){
		NewLineHere();
		return TRUE;
	}
	if(Y == TO){
		NewLineHere();
		return TRUE;
	}
	if(Y >= (msginfo.screenlength-1)){	/* Scrolla ned†t */
		MoveRowToMessage();
		if(FindNextRow()){
			MoveMessageToRow();
			topwindow = FindTop();
			ScrollUp();
			Print(currenttext,currenttext);
			X = oldX;
			if(X > strlen(currenttext))
				X = strlen(currenttext);
			if(i)
				GoToXY(X,Y);
			return TRUE;
		}
		else
			return FALSE;
	}
	else{			/* Flytta vanligt ned†t */
		MoveRowToMessage();
		if(FindNextRow())
			Y++;
		else
			return FALSE;
		MoveMessageToRow();
		oldoldX = X;
		X = oldX;
		if(X > strlen(currenttext))
			X = strlen(currenttext);
		if(i)
			if(X == oldoldX)
				fastDown();
			else
				GoToXY(X,Y);
		return TRUE;
	}
	return FALSE;
}

int FindNextRow(void)			/* Hittar n„sta rad i brevet */
{
	int i = currentline;
	char *msg;

	if(currentline >= MAX)
		return FALSE;
	msg = message + currentline;
	while(*msg != 10){
		if(*msg == NOLL){
			currentline = i;
			return FALSE;
		}
		msg++,currentline++;
	}
	currentline++;
	return TRUE;
}

void MoveRowToMessage(void)	/* Flytta aktuell rad till buffer */
{
	int i,j;
	char *msg,*cur;

	if(Y == TO){
		MoveRow(currenttext,msginfo.To);
		return;
	}
	if(Y == SUBJ){
		MoveRow(currenttext,msginfo.Subj);
		return;
	}

	for(i = currentline;message[i] != 10 && message[i] != NOLL;i++);	/* Ber„kna l„ngd */
	if((i - currentline) != strlen(currenttext)){
		if(((i - currentline) + lmessage) > MAX)	/* Inte spara f”r stora brev */
			return;
		j = strlen(currenttext) - (i - currentline);
		if(j < NOLL){			/* Flytta upp†t i minne */
			msg = message + i + j;
			cur = message + i;
			i = lmessage - i;
			for(lmessage += j;i >= NOLL;i--,msg++,cur++)
				*msg = *cur;
		}
		if(j > NOLL){			/* Flytta ned†t i minne */
			msg = message + lmessage + j;
			cur = msg - j;
			i = lmessage - i + j;
			for(lmessage += j;i >= NOLL;msg--,cur--,i--)
				*msg = *cur;
		}
	}
	msg = message + currentline;
	cur = currenttext;						/* Flytta buffer till text */
	for(i = strlen(currenttext);i > NOLL;i--,msg++,cur++)
		*msg = *cur;
}

void MoveMessageToRow(void)	/* Flytta aktuell bufferrad till rad */
{
	char *msg,*row;

	msg = message + currentline;
	row = currenttext;
	while(*msg != 13 && *msg != 10 && *msg != NOLL)
		*(row++) = *(msg++);
	*row = NOLL;
}

void DeleteChar(int i)		/* Tar bort ett tecken i str„ngen */
{
	char *msg;

	msg = currenttext + i;
	for(;*msg != NOLL && *msg != 10;msg++){
		*msg = *(msg+1);
	}
}

void DeleteCharFromCursorVT52(int out)	/* Ta bort tecken med VT52 */
{
	char *msg;

	fGoToXY(out,X,Y);
	msg = currenttext + X;
	while(*msg == ' ')
		msg++;
	if(*msg == NOLL || *msg == 10){
		Print(fastdel,fastdel);
		return;
	}
	Put(out,currenttext + X);
	Put(out," ");
	fGoToXY(out,X,Y);
}

void DeleteCharFromCursor(void)		/* Tar bort en char fr†n aktuell rad */
{
	if(Screen)
		DeleteCharFromCursorVT52(SCREEN);
  if(Serial)					/* Om till porten skriv med r„tt emulering */
		switch(msginfo.emulation){
			case ASCII			: exit(-1); break; /* ASCIIanv„ndare kan ej anv„nda CeD */
			case ANSICOLOR	:
			case ANSIMONO		:
			case AVATAR			:	fGoToXY(SERIAL,X,Y);
												Put(SERIAL,"[1P");
												break;
			case VT52COLOR	:
			case VT52MONO		:
			case VT52FALCON	:	DeleteCharFromCursorVT52(SERIAL);
												break;
		}
}

void PrintToEndOfLine(void)
{
	GoToXY(X,Y);
	Print(currenttext + X,currenttext + X);
	GoToXY(X,Y);
}

void ReFormatText(int keyins, int ReDraw)		/* Formaterar om akutellt stycke */
{
	int redrawStartX,redrawStartY,redrawEndY,AddRedrawRow;
	int i,j,k;
	char *msg,*cur;
	char buff[90];

	redrawStartY = Y,redrawEndY = Y;
	if(X != NOLL)						/* Kom ih†g vilka rader vi m†ste rita om */
		redrawStartX = X - 1;
	else
		redrawStartX = NOLL;

	for(j = currentline;message[j] != NOLL && message[j] != 10;j++);	/* Hitta radslut */
	if((j-currentline) >= MAXWIDTH){	/* Kolla om l„ngden ”verskider max */
		for(k = currentline + MAXWIDTH - 2;message[k] != ' ' && k >= NOLL && message[k] != 10;k--);		/* Hitta space */
		if(message[k] == ' ')
			k++;										/* Bryt vid position k */
		else
			k += MAXWIDTH/2;
	}
	if((k-currentline) < redrawStartX)		/* Se till att bryt rad vid r„tt st„lle! */
		redrawStartX = k - currentline;

	i = currentline;		/* Hitta vart vi kan bryta ord */
	do{
		for(j = i;message[j] != NOLL && message[j] != 10;j++);	/* Hitta radslut */
		if((j-i) < MAXWIDTH)	/* Kolla om l„ngden ”verskider max */
			break;
		if(message[j-1] == ' '){		/* Formatera om stycke */
			AddRedrawRow = FALSE,redrawEndY++;
			for(k = i + MAXWIDTH - 2;message[k] != ' ' && k >= NOLL && message[k] != 10;k--);		/* Hitta space */
			if(message[k] == ' ')
				k++;										/* Bryt vid position k */
			else
				k += MAXWIDTH/2;
			i = k;

			msg = message + j;
			if(*msg == NOLL)					/* Se till att vi inte f”rst”r nollan */
				*(msg+1) = NOLL;
			for(j -= k;j > NOLL;j--,msg--)
				*msg = *(msg-1);
			*msg = 10;
			i++;
		}
		else{									/* Formatera om endast denna rad */
			AddRedrawRow = TRUE,redrawEndY++;
			for(k = i + MAXWIDTH - 2;message[k] != ' ' && k >= NOLL && message[k] != 10;k--);		/* Hitta space */
			if(message[k] == ' ')
				k++;										/* Bryt vid position k */
			else
				k += MAXWIDTH/2;
			i = k;

			lmessage++;
			k = lmessage - k;
			msg = message + lmessage;	/* Bered plats f”r linefeed */
			if(*msg == NOLL)					/* Se till att vi inte f”rst”r nollan */
				*(msg+1) = NOLL;
			for(;k >= NOLL;k--,msg--)			/* Flytta minne */
				*msg = *(msg-1);
			message[i] = 10;			/* L„gg in en linefeed */
			i++;
		}
	} while(TRUE);

	message[lmessage] = NOLL;
	i = redrawStartX;
	msg = message + redrawStartX + currentline;
	if(ReDraw){
		while(redrawStartY <= redrawEndY){	/* Rita om l„mpligt omr†de p† sk„rmen */
			cur = buff;
			while(*msg != NOLL && *msg != 10)
				*cur = *msg,cur++,msg++;
			*cur = NOLL;
			GoToXY(i,redrawStartY);
			if(redrawStartY == redrawEndY && AddRedrawRow && keyins)
				InsertEmptyRow();
			Print(buff,buff);
			KillToEndOfLine();
			redrawStartY++;
			if(redrawStartY >= msginfo.screenlength)
				break;
			if(*msg == NOLL)
				break;
			msg++,i = NOLL;
		}
		GoToXY(X,Y);
		MoveMessageToRow();
	}
}

int move_text_up(void)	/* Flyttar texten upp, ret TRUE om omformatering beh”vs */
{
	int i,j;
	char *msg;

	MoveRowToMessage();
	for(i = currentline;message[i] != 10;i++)		/* Leta p† radslut */
		if(message[i] == NOLL)			/* Om ingen fler rad, l„gg inte ihop */
			return FALSE;
	for(j = lmessage - i,msg = message + i;j >= NOLL;j--,msg++)
		*msg = *(msg+1);			/* Ta bort linefeeden */
	lmessage--;
	i = currentline,j = NOLL;
	for(i = currentline;message[i] != 10 && message[i] != NOLL;i++,j++);	/* Leta p† radslut */
	if(j >= MAXWIDTH)		/* Om raden l„ngre „n normalt, meddelan omformatering */
		return TRUE;
	MoveMessageToRow();	/* Plocka in raden i tillf„llig rad */
	return FALSE;
}

void backspace(void)			/* Ta bort ett tecken */
{
	if(X == NOLL){			/* Flytta upp raden till f”reg†ende */
		if(Y == TO || Y == SUBJ)
			return;
		if(currentline != NOLL){
			move_up(TRUE);
			X = strlen(currenttext);
			if(move_text_up()){					/* Flytta upp texten */
				ReFormatText(FALSE,TRUE);	/* Om raden „r l„ngre „n sk„rmen, formatera om den */
				if(X > strlen(currenttext))
					X = strlen(currenttext);
				GoToXY(X,Y);
			}
			else
				if(Y != (msginfo.screenlength-1)){
					GoDown();								/* Annars ta bort raden under bara */
					KillLineOnScreen();
					PrintToEndOfLine();
					FixLastLine();
				}
		}
	}
	else{
		DeleteChar(--X);			/* Ta bort tecknet i str„ngen */
		DeleteCharFromCursor();	/* Skriv ut str„ngen framm†t */
	}
	oldX = X;
}

void delete(void)			/* Ta bort ett tecken */
{
	if(X == strlen(currenttext)){	/* Flytta upp raden till f”reg†ende */
		if(Y == TO || Y == SUBJ)
			return;
		if(move_text_up()){					/* Flytta upp texten */
			ReFormatText(FALSE,TRUE);	/* Om raden „r l„ngre „n sk„rmen, formatera om den */
			X = strlen(currenttext);
			GoToXY(X,Y);
		}
		else
			if(Y != (msginfo.screenlength-1)){
				GoDown();								/* Annars ta bort raden under bara */
				KillLineOnScreen();
				PrintToEndOfLine();
				FixLastLine();
			}
	}
	else{
		DeleteChar(X);			/* Ta bort tecknet i str„ngen */
		DeleteCharFromCursor();	/* Skriv ut str„ngen framm†t */
	}
	oldX = X;
}

void AddCharToCursorVT52(int out)	/* L„gg till tecken till VT52-sk„rm */
{
	Put(out,currenttext + X - 1);
	fGoToXY(out,X,Y);
}

void AddChar(unsigned char tangent,int i)	/* L„gger till tangenten */
{
	int j;
	char *msg;

	j = strlen(currenttext) + 1;
	msg = currenttext + j;
	for(;i <= j;msg--,j--){
		*msg = *(msg-1);
	}
	currenttext[i] = tangent;
}

void AddCharToCursor(void)
{
	if(Screen)
		AddCharToCursorVT52(SCREEN);
  if(Serial)					/* Om till porten skriv med r„tt emulering */
		switch(msginfo.emulation){
			case ASCII			: exit(-1); break; /* ASCIIanv„ndare kan ej anv„nda CeD */
			case ANSICOLOR	:
			case ANSIMONO		:
			case AVATAR			:	Put(SERIAL,"[1@");
												out[0] = *(currenttext + X - 1);
												out[1] = NOLL;
												Put(SERIAL,out);
												break;
			case VT52COLOR	:
			case VT52MONO		:
			case VT52FALCON	:	AddCharToCursorVT52(SERIAL);
												break;
		}
}

void InsertCharacter(unsigned char tangent)
{
	int i,x;
	char *msg;

	if(Y == TO && strlen(currenttext) >= MAXTO)
		return;
	if(Y == SUBJ && strlen(currenttext) >= MAXSUBJ)
		return;

	if(strlen(currenttext) >= MAXWIDTH){		/* Byt rad */
		x = X;
		i = strlen(currenttext);
		if(x == i){				/* Bara flytta ner aktuellt ord */
			msg = currenttext + i - 1;
			while(*msg != ' ' && x > NOLL)
				msg--,x--;
			if(x == NOLL)			/* L†††††††ng rad, sl† return bara */
				NewLineHere();
			else{
				i -= x+1;
				X = x;
				GoToXY(X,Y);
				NewLineHere();
				X = i+1;
				GoToXY(X,Y);
			}
		}
		else{
			AddChar(tangent,X);			/* L„gg till tangenten till buffern */
			X++;
			MoveRowToMessage();
			ReFormatText(TRUE,TRUE);			/* Flytta ner ett ord till raden efter */
			if(X > strlen(currenttext)){
				i = X - strlen(currenttext);
				move_right();
				X = i;
				GoToXY(X,Y);
			}
			return;
		}
	}
	AddChar(tangent,X);			/* L„gg till tangenten till buffern */
	X++;
	AddCharToCursor();			/* Uppdatera sk„rmen */
	oldX = X;
}

void KillMessageLine(void)		/* Tar bort aktiv rad i brevet */
{
	char *msg,*cur;

	if(message[currentline] == NOLL)
		return;
	lmessage -= strlen(currenttext) + 1;
	msg = message + currentline;
	cur = message + currentline + strlen(currenttext) + 1;
	while(*msg != NOLL){
		*msg = *cur;
		msg++,cur++;
	}
}

void KillLineOnScreen(void)		/* Ta bort en rad p† sk„rmen */
{
	sprintf(out,"%cM",13);
	sprintf(out2,"%c[1M",13);
	Print(out,out2);
}

void PrintLowerLine(void)		/* Skriver ut l„gsta raden p† aktuell pos */
{
	int i;
	char *msg,txt[90],*cur;

	msg = message + topwindow;
	for(i = TEXTSTART;i < (msginfo.screenlength-1);msg++){
		if(*msg == 10)
			i++;
		if(*msg == NOLL)
			return;
	}
	cur = txt;
	while(*msg != 10 && *msg != NOLL){
		*cur = *msg;
		cur++,msg++;
	}
	*cur = NOLL;
	Print(txt,txt);
}

void FixLastLine(void)
{
	GoToXY(0,msginfo.screenlength-1);
	PrintLowerLine();
	GoToXY(X,Y);
}

void DeleteThisLine(void)		/* Tar bort aktuell rad */
{
	if(Y == TO || Y == SUBJ)
		return;
	MoveRowToMessage();
	KillMessageLine();
	MoveMessageToRow();
	X = oldX;
	if(X > strlen(currenttext))
		X = strlen(currenttext);
	KillLineOnScreen();
	FixLastLine();
}

void KillToEndOfLine(void)
{
	Print("K","[0K");
}

void ReverseOn(void)
{
	int MagicScreen;

	if(Screen)
    Put(SCREEN,"b c/");
	MagicScreen = Screen;
	Screen = FALSE;
	Print("b@cA","[0;37;45m");
	Screen = MagicScreen;
}

void ReverseOff(void)
{
	int MagicScreen;

	if(Screen)
    Put(SCREEN,"b/c ");
	MagicScreen = Screen;
	Screen = FALSE;
	Print("bAc@","[1;37;40m");
	Screen = MagicScreen;
}

void NewLineHere(void)
{
	int i;

	if(Y == SUBJ){
		MoveRow(currenttext,msginfo.Subj);
		ReverseOff();
		X = oldX = NOLL,Y = TEXTSTART;
		currentline = topwindow;
		GoToXY(X,Y);
		MoveMessageToRow();		/* H„mta ny rad */
		return;
	}
	if(Y == TO){
		StartEditSubject();
		return;
	}

	i = currentline;
	AddChar('L',X);				/* L„gg till f”r linefeed till buffern */
	MoveRowToMessage();
	message[i + X] = 10;	/* Linefeed */
	currentline = i + X + 1;
	MoveMessageToRow();		/* H„mta ny rad */
	KillToEndOfLine();
	if(Y == (msginfo.screenlength-1)){		/* Uppdatera sk„rmen */
		topwindow = FindTop();
		ScrollUp();
		Print(currenttext,currenttext);
	}
	else{
		Y++;
		GoDown();
		InsertEmptyRow();
		Print(currenttext,currenttext);
	}
	X = oldX = NOLL;
	GoToXY(X,Y);					
}

void MoveRow(char *from,char *to)		/* Flyttar en str„ng */
{
	while(*from != NOLL)
		*to = *from,to++,from++;
	*to = NOLL;
}

void StartEditSubject(void)			/* B”rja editera subjectet */
{
	if(Y >= TEXTSTART)
		MoveRowToMessage();
	if(Y == TO)
		MoveRow(currenttext,msginfo.To);
	if(Y == SUBJ)
		MoveRow(currenttext,msginfo.Subj);

	ReverseOn();

	MoveRow(msginfo.Subj,currenttext);
	Y = SUBJ;
	X = strlen(msginfo.Subj);
	GoToXY(X,Y);
}

void StartEditTo(void)				/* B”rja editera To */
{
	if(Y >= TEXTSTART)
		MoveRowToMessage();
	if(Y == TO)
		MoveRow(currenttext,msginfo.To);
	if(Y == SUBJ)
		MoveRow(currenttext,msginfo.Subj);

	ReverseOn();

	MoveRow(msginfo.To,currenttext);
	Y = TO;
	X = strlen(msginfo.To);
	GoToXY(X,Y);
}

void ShowNextPage(void)		/* Bl„ddrar fram en sida */
{
	int i;
	char *msg;

	MoveRowToMessage();		/* Flytta in texten till brevet */
	msg = message + topwindow;		/* Hitta sista raden p† aktuell sida */
	for(i = TEXTSTART;i < (msginfo.screenlength-1);msg++){
		if(*msg == 10)
			i++,topwindow = msg - message + 1;
		if(*msg == NOLL)
			break;
	}
	currentline = topwindow;			/* Stega fram till aktuell rad */
	for(i = TEXTSTART;i < Y;i++)
		if(!FindNextRow())
			break;
	Y = i;
	MoveMessageToRow();
	X = oldX;
	if(X > strlen(currenttext))
		X = strlen(currenttext);
	RedrawWholeText();						/* Visa texten */
}

void ShowPrevPage(void)		/* Bl„ddrar tillbaka en sida */
{
	int i;
	char *msg;

	MoveRowToMessage();		/* Flytta in texten till brevet */
	msg = message + topwindow;		/* Hitta ny rad p† f”reg†ende sida */
	for(i = TEXTSTART;i < msginfo.screenlength;msg--){
		if(*msg == 10)
			i++,topwindow = msg - message + 1;
		if(msg <= message){
			topwindow = NOLL;
			break;
		}
	}
	currentline = topwindow;			/* Stega fram till aktuell rad */
	for(i = TEXTSTART;i < Y;i++)
		if(!FindNextRow())
			break;
	Y = i;
	MoveMessageToRow();
	X = oldX;
	if(X > strlen(currenttext))
		X = strlen(currenttext);
	RedrawWholeText();						/* Visa texten */
}

void preform(unsigned char tangent)	/* Utf”r n†nting */
{
	switch(tangent){
		case 17 : if(kill_text())
								shutdown = ABORTTEXT;		/* <CTRL> + Q */
							else{
								RedrawMenu(FALSE);	/* Rita ut f”rsta raden i menyn */
								if(Y == SUBJ || Y == TO)
									ReverseOn();
								GoToXY(X,Y);
							}
							break;

		case 19 : 												/* <CTRL> + S */
		case 26 : shutdown = SAVETEXT;		/* <CTRL> + Z */
							break;

		case 21 : X = oldX = strlen(currenttext);	/* <CTRL> + U */
							GoToXY(X,Y);
							NewLineHere();
							break;

		case 22 : ShowNextPage();					/* <CTRL> + V */
							break;

		case 3	: ShowPrevPage();					/* <CTRL> + C */
							break;

		case 12 : 												/* <CTRL> + L */
		case 18 : MoveRowToMessage();			/* <CTRL> + R */
							RedrawMenu(TRUE);		/* Rita upp menyn */
							RedrawWholeText();	/* Skriv ut texten */
							if(Y == TO || Y == SUBJ)
								ReverseOn();
							break;

		case 1	:	X = oldX = NOLL; GoToXY(X,Y); break;	/* <CTRL> + A */

		case 5	:	X = oldX = strlen(currenttext);	/* <CTRL> + E */
							GoToXY(X,Y); break;

		case 8	: backspace();			/* Backspace */
							break;

		case 127:	delete();					/* Delete */
							break;

		case 11 :										/* <CTRL> + K */
		case 25	: DeleteThisLine();	/* <CTRL> + Y  Ta bort aktuell rad */
							break;

		case 13 : NewLineHere();		/* Ny rad nu genast */
							break;

		case 4	: StartEditSubject();	/* <CTRL> + D */
							break;

		case 20 : StartEditTo();		/* <CTRL> + T */
							break;

		case 9	: {									/* TAB */
								int i;

									if(X < (MAXWIDTH - TABWIDTH))
										for(i = TABWIDTH-(X % TABWIDTH);i > NOLL;i--)
											InsertCharacter(' ');
							}
							break;

		case CURSORLEFT:					/* Cursor left */
							move_left();
							break;

		case CURSORRIGHT:					/* Cursor right */
							move_right();
							break;

		case CURSORUP:					/* Cursor up */
							move_up(TRUE);
							break;

		case CURSORDOWN:					/* Cursor down */
							move_down(TRUE);
							break;

		case LOGOUT	: break;			/* Loggutkod */

		default : if(tangent < ' '){
								MoveRowToMessage();
								show_help_screen();
								RedrawMenu(TRUE);		/* Rita upp menyn */
								RedrawWholeText();	/* Skriv ut texten */
								if(Y == TO || Y == SUBJ)
									ReverseOn();
							}
							else
								InsertCharacter(tangent);		/* Ett tecken att l„gga in */
							break;
	}
}

void FixMax80(int fixer)		/* Kapar raderna till max 80 tecken */
{
	char *msg,*cur,*de;
	int i,j;

	if(fixer){			/* QBBS quote */
		currentline = NOLL;
		msg = message;				/* Reformatera alla rader ”ver 85 tecken */
		do{
			for(i = NOLL;*msg != 10 && *msg != NOLL;msg++,i++);
			if(i > 85)
				ReFormatText(FALSE,FALSE);
			else
				currentline += i + 1,msg = currentline + message;
		} while(*msg != NOLL);

		currentline = NOLL;	/* Fixa till > f”r varje quoterad (QBBS) */
		if(message[NOLL] != NOLL || message[NOLL + 1] != NOLL){
			do{
				MoveMessageToRow();
				for(i = strlen(currenttext),msg = currenttext + i;i >= NOLL;i--,msg--)
					*(msg+3) = *msg;
				currenttext[NOLL] = ' ';
				currenttext[NOLL+1] = '>';
				currenttext[NOLL+2] = ' ';
				MoveRowToMessage();
			} while(FindNextRow());
		}
		currentline = NOLL;
	}

	msg = message;
	while(*msg != NOLL){		/* Kolla igenom hela brevet */
		for(i = NOLL;*msg != NOLL && *msg != 10;i++,msg++);	/* Hitta l„ngd */
		if(i > MAXWIDTH){		/* St”rre „n till†tet! */
			de = msg;
			msg -= i - MAXWIDTH;
			cur = msg;
			for(j = lmessage - (msg - message);j >= NOLL;j--,de++,cur++)	/* Flytta upp */
				*cur = *de;
			lmessage -= i - MAXWIDTH;
		}
		if(*msg == NOLL)
			break;
		else
			msg++;
	}
}

void Kill1013(char *from)			/* Tar bort eventuella radmatningar */
{
	while(*from != NOLL)
		if(*from == 10 || *from == 13)
			*from = NOLL;
		else
			from++;
}

void Quote(void)	/* Allocerar textbuffer och laddar in text */
{
  FILE *filehandle;
	int quote,fixfrom = FALSE;
	char tang;

  if((filehandle = fopen("MSGINFO.FSE","r")) != NULL){	/* F”rs”k med Octopus-formatet */
		if(fread((char *)(&msginfo),sizeof(msginfo),1,filehandle) != 1){
			QBBS = TRUE,fixfrom = TRUE;
			rewind(filehandle);
	    fgets(msginfo.From,35,filehandle);	/* Fr†n vem?  Anv„nd QBBSformatet */
			Kill1013(msginfo.From);
  	  fgets(msginfo.To,35,filehandle);		/* Till vem? */
			Kill1013(msginfo.To);
    	fgets(msginfo.Subj,71,filehandle);	/* Anledning */
			Kill1013(msginfo.Subj);
    	fgets(out,10,filehandle);						/* Emulering??? */
	    fgets(out2,10,filehandle);					/* ??? */
	    fgets(msginfo.Areadesc,79,filehandle);	/* Messagebasens namn */
			Kill1013(msginfo.Areadesc);
    	fgets(out,10,filehandle);						/* Antal brev i arean */
			msginfo.messages = atoi(out);				/* Brev i arean */

			fclose(filehandle);
			if((filehandle = fopen("DORINFO1.DEF","r")) != NULL){
	    	fgets(out,40,filehandle);						/* SysOps f”rnamn */
	    	fgets(out,40,filehandle);						/* SysOps efternamn */
	    	fgets(out,40,filehandle);						/* Connect bps */
	    	fgets(out,40,filehandle);						/* User f”rnamn */
	    	fgets(out,40,filehandle);						/* User efternamn */
	    	fgets(out,40,filehandle);						/* User hemort */
	    	fgets(out,40,filehandle);						/* Emulering */
				msginfo.emulation = atoi(out);			/* Tolka emulering */
	    	fgets(out,40,filehandle);						/* Sk„rml„ngd */
				msginfo.screenlength = atoi(out);
	    	fgets(out,40,filehandle);						/* S„kerhetsniv† */
	    	fgets(out,40,filehandle);						/* Tid kvar */
				msginfo.seconds_left = atoi(out);
				msginfo.timeout = 2*60;							/* S„tt timeouten */
				switch(msginfo.emulation){		/* Konvertera till r„tt emulering */
					case QBBSASCII			: msginfo.emulation = ASCII;			break;
					case QBBSVT52MONO		: msginfo.emulation = VT52MONO;		break;
					case QBBSVT52COLOR	: msginfo.emulation = VT52COLOR;	break;
					case QBBSVT52STAND	: msginfo.emulation = VT52COLOR;	break;
					case QBBSANSI				: msginfo.emulation = ANSICOLOR;	break;
					default : break;
				}
			}
			else{					/* Anv„nd standard om DORINFO1.DEF inte finns */
				msginfo.timeout = 2*60;							/* S„tt timeouten */
				msginfo.seconds_left = 30*60;				/* S„tt Tid kvar */
				msginfo.screenlength = 24;					/* Sk„rml„ngd */
				msginfo.emulation = 1;							/* Emulering att anv„nda */
			}
		}
		else
			if(pucko == 1)
				pucko = msginfo.Port;	/* Se till att anv„nda samma port som Octopus */
    fclose(filehandle);

		if((!CheckCarrier() && Serial) || msginfo.Port == 2)	/* Om ingen carrier, anta lokalmode */
			Serial = FALSE,Screen = TRUE;
	  if(SerialF)							/* F = S„nd till serieporten */
  	  Serial = TRUE;
	}
	message[NOLL] = NOLL,quote = TRUE,lmessage = NOLL,X = oldX = NOLL,Y = TEXTSTART;
	currentline = NOLL,topwindow = NOLL;
	if((filehandle = fopen("MSGTEXT.FSE","r")) != NULL){ /* msginfo.Quotetext */
		if(AskQuote != NONE){
			if(AskQuote == YES){
				Print("Quote [Y/n] ? ","Quote [Y/n] ? ");
				do{
					tang = character();				/* H„mta en tangent */
					switch(tang){
						case 13  :		/* Return */
						case 'y' :		/* Yes */
						case 'Y' :	quote = TRUE,tang = NOLL;
												Print("Yes","Yes");
												break;
						case 'n' :		/* No */
						case 'N' :	quote = FALSE,tang = NOLL;
												Print("No","No");
												break;
						default  : tang = TRUE;
					}
				} while(tang != NOLL);
			}
			if(AskQuote == NO){
				Print("Quote [y/N] ? ","Quote [y/N] ? ");
				do{
					tang = character();				/* H„mta en tangent */
					switch(tang){
						case 'y' :		/* Yes */
						case 'Y' :	quote = TRUE,tang = NOLL;
												Print("Yes","Yes");
												break;
						case 13  :		/* Return */
						case 'n' :		/* No */
						case 'N' :	quote = FALSE,tang = NOLL;
												Print("No","No");
												break;
						default  : tang = TRUE;
					}
				} while(tang != NOLL);
			}
		}
		if(quote)
			lmessage = fread(message,1,MAX,filehandle);
		if(message[lmessage-1] == 10){
			message[lmessage] = NOLL;
			message[lmessage+1] = NOLL;
		}
		else{
			message[lmessage++] = 10;
			message[lmessage] = NOLL;
		}
		FixMax80(fixfrom);
		fclose(filehandle);
	}
	time(&Time);
}

void SetupInternalFlags(char *options)  /* S„tter upp flaggorna korrekt */
{
	int offset;

  if(FindFlag(options,(char)'R') > NOLL)	/* R = Resetta terminalen */
    Settings |= RESETTERMINAL;
  if(FindFlag(options,(char)'S') > NOLL)	/* S = S„nd till serieporten */
    Serial = TRUE;
  if(FindFlag(options,(char)'L') > NOLL)	/* L = S„nd lokalt */
    Screen = TRUE;
  if(FindFlag(options,(char)'Q') > NOLL)	/* Q = Fr†ga inte om quote */
    AskQuote = NONE;
  if(FindFlag(options,(char)'Y') > NOLL)	/* Y = Fr†ga Quote, Yes default */
    AskQuote = YES;
  if(FindFlag(options,(char)'N') > NOLL)	/* N = Fr†ga Quote, No default */
    AskQuote = NO;
	if((offset = FindFlag(options,(char)'P')) > 0)	/* P = St„ll porthastighet */
		pucko = atoi(options + offset + 1);
  if(FindFlag(options,(char)'F') > NOLL)	/* F = S„nd till serieporten */
    Serial = TRUE,SerialF = TRUE;
}

int FindFlag(char *string,char flagga)  /* Hittar en flagga i str„ngen */
{
  int i;

  for(i = 0;*(string + i) != 0;i++)
    if((*(string + i) == flagga) || (*(string + i) == flagga - 'A' + 'a'))
      return i;
  return -1;
}


/* End of Code */