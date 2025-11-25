/****************************************************************************
'
'               Header fuer Mystery-Applikationen unter MEGAMAX-C
'                          Copyright PARROT-BERLIN
'
'
' Dieser Header stellt I/O-Routinen fÅr MEGAMAX-C, sowie einige Systemvari-
' ablen von Mystery-Systems zur VerfÅgung.
' Es sind ausschlieûlich die angebotenen I/O-Routinen zu verwenden, die
' RS232C-Schnittstelle darf nicht umkonfiguriert werden.
'
' Die angebotenen I/O-Routinen zeichnen sich dadurch aus, dass sie auf Kon-
' trollcodes, Carrierverlust, Timeout und Ueberschreiten der maximalen Benut-
' zerzeit reagieren und per longjmp Stellen im Programm anspringen, die vor-
' her mit setjmp markiert wurden. Generell lassen sich vier Typen von Events
' unterscheiden, fuer die zwei Environmentbuffer angelegt wurden (Termina-
' te_env und Break_env).
'                                                       
' Benutzung der Jump-buffer                            
'                                                       
' Event        abfragende Routinen      Buffer         
'                                                       
' Carrier_lost Mbputchar/Mbgetchar      Terminate_env    
' t>tmax       Mbputchar                Terminate_env   
' timeout      Mbgetchar                Terminate_env   
' CTRL-X       ctrl                     Break_env       
'                                                       
'
' Prinzipiell muessen die Environmentbuffer vor der Benutzung von I/O-Routi-
' nen korrekt gesetzt sein, da es sonst zu Abstuerzen kommt. Damit die ganze
' Angelegenheit nicht unnoetig kompliziert wird, wird empfohlen, nur
' Break_env zu veraendern, damit das Programm auf CTRL_X reagiert.
'
' Die Routinen sind weitgehend den Standardroutinen von C nachempfunden, als
' weitere Parameter werden jedoch haeufig BRK, NBRK und NCTRL verwendet. Die-
' se Parameter legen fest, ob die Ausgabe abgebrochen werden kann oder nicht.
' NCTRL wirkt dabei wie NBRK mit der zusaetzlichen Eigenschaft, dass RS232C
' generell nicht auf Kontrollcodes abgefragt wird.
'
' Als weitere Besonderheit soll noch erwaehnt werden, dass die MORE- und die
' Slow-Option beim Programmstart von Mystery-Systems uebernommen werden,
' weiterhin weist Mbgets den Inline-Editor von Mystery-Systems auf.

' Die compilierten Programme mÅssen die Extension .APP haben!!
'
'
' Sofern die folgenden Funktionen nicht ausreichend sein sollten oder
' Unklarheiten bestehen, bitte die PARROT unter (030) 724467 anrufen und
' eine PM an den Syop senden, bzw. eine Nachricht ins Visitors.brd setzen.
' 
'
' ACHTUNG: DIE ROUTINEN DIESES FILES SIND NICHT PUBLIC-DOMAIN, SIE DUERFEN
'          ABER NICHTKOMMERZIELL VERWERTET WERDEN.
'
'
'            Mit freundlichen Gruessen
'
'                     Horst
'
'
'
'***************************************************************************/

#include <osbind.h>
#include <define.h>
#include <string.h>
#include <stdio.h>
#include <errno.h>
#include <ctype.h>


/****************************************************************************

          Defines und Strukturen
          
****************************************************************************/

#define   AUX             1
#define   CON             2

#define   DEL          0x7F        /* Deletecodes f. verschiedene Computer */
#define   BS              8

#define   CTRL_E          5
#define   BEL             7
#define   CR             13
#define   CTRL_S         19
#define   UP_ARROW       22       
#define   DOWN_ARROW     23    
#define   CTRL_X         24
#define   RIGHT_ARROW    25
#define   LEFT_ARROW     26
#define   ESC            27 

#define   F1             59L       /* Scancodes */ 
#define   F2             60L
#define   F3             61L
#define   F4             62L
#define   F5             63L
#define   F6             64L
#define   F7             65L
#define   F8             66L
#define   F9             67L
#define   F10            68L


#define   A_ae          132        /* Umlaute, Sonderzeichen */
#define   A_oe          148        /* A=Atari, Am=Amiga, M=Mac, PC=PC, E=EASCII */
#define   A_ue          129
#define   A_AE          142
#define   A_OE          153
#define   A_UE          154
#define   A_SZ          158
#define   A_PA          0xDD

#define   PC_SZ         0xE1    /* Rest ist wie Atari */

#define   SCRNWIDTH      79
#define   BACKSPACE       Mbprintf(NCTRL,"\b \b")
#define   CRLF            Mbprintf(NCTRL,"\r\n")
#define   BELL            Mbputchar('\007',NBRK)                                     /* leer ist, ausserdem WERDEN KEINE USERINPUTS GESCHLUCKT */
#define   VT_LEFT         Rsout("\033[D")
#define   VT_RIGHT        Rsout("\033[C")
#define   VT_STORE        Rsout("\0337")
#define   VT_REST         Rsout("\0338")
#define   VT_INSERT       Rsout("\033[4h")
#define   VT_OVER         Rsout("\033[4l")
#define   VT_DEL          Rsout("\033[1P")
#define   VT_DELEOL       Rsout("\033[K") 

#define SCRN(a) bios(3,2,ESC); bios(3,2,a)

#define CRSR_UP SCRN('A')
#define CRSR_DOWN SCRN('B')
#define CRSR_RT SCRN('C')
#define CRSR_LT SCRN('D')
#define CLRSCRN SCRN('E')
#define HOME SCRN('H')
#define DEL_EOP SCRN('J')
#define DEL_EOL SCRN('K')
#define INSRT_LIN SCRN('L')
#define KILL_LIN SCRN('M')
#define CRSR_OFF SCRN('f')
#define CRSR_ON SCRN('e')
#define DEL_BOS SCRN('d')
#define STORE_CRSR SCRN('j')
#define RESTORE_CRSR SCRN('k')
#define DEL_LIN SCRN('l')
#define DEL_BOL SCRN('o')
#define REV_ON SCRN('p')
#define REV_OFF SCRN('q')
#define WRAP_ON SCRN('v')
#define WRAP_OFF SCRN('w')
#define BGD_WHITE SCRN('c'); bios(3,2,0x30);
#define BGD_BLACK SCRN('c'); bios(3,2,0x31);

#define GOTO(x,y) SCRN('Y'); bios(3,2,y+32); bios(3,2,x+32)


#define   NBRK            0
#define   BRK             1
#define   NCTRL           2


typedef struct
{
     unsigned BATCHING: 1;         /* true, wenn Batchbetrieb */
     unsigned NOENTRY: 1;          /* true, wenn kein access auf rootdirectory moeglich ist */
     unsigned SYSOUT:  1;          /* true, wenn System logoff durchfuehrte */
     unsigned CARRIER_LOST: 1;     /* true wenn carrier-lost */
     unsigned TOUT: 1;             /* true wenn timeout */
     unsigned TMAX: 1;             /* true wenn maxtime ueberschritten */
     unsigned BELLOFF: 1;          /* true wenn belloff */
     unsigned LOCAL: 1;            /* true wenn localbetrieb */
     unsigned SLOW: 1;             /* true fuer langsame Ausgabe */
     unsigned CAT: 1;              /* true, wenn Katalog geladen */
     unsigned MORE: 1;             /* true fuer Anhalten bei Boards u. Mails */
     unsigned DIROWNER: 1;         /* true, wenn User Owner des aktuellen Directories ist */
     unsigned ERROR: 1;            /* bei true werden Fehler angezeigt */ 
     unsigned LONG: 1;             /* true, wenn langer Catalog angezeigt werden soll */
     unsigned UPDATE: 1;           /* true, wenn Catalog zurueckgeschrieben werden muss */
     unsigned LOGOUT: 1;           /* true bei logout durch den user */
} FLAG;

typedef struct
{
     unsigned KILL_MAIL: 1;        /* true, wenn Mail gelesen wurde und geloescht werden kann */
     unsigned PRINTER: 1;          /* wenn true, erfolgen Ausgaben auch auf Printer */
     unsigned OPTION: 1;           /* wenn true, Option zum Schreiben nach dem Lesen eines Boards */
     unsigned EXPAND: 1;           /* wenn true, kein cr-lf vor und nach errors */
     unsigned NO_ECHO: 1;          /* wenn true, einmalig kein Echo bei Mbgets */
     unsigned HIDE: 1;             /* wenn true, Ausgabe erst ab 'logged in at... */
     unsigned INTERPRET: 1;        /* ermoeglicht UP_ARROW und DOWN_ARROW */
     unsigned INSERT: 1;           /* true, wenn Userterminal auf Insert geschaltet wurde */
     unsigned EDITLINE: 1;         /* true, wenn Zeile im Editor editiert werden soll */
     unsigned INFO: 1;             /* true, wenn bei Catalogen das Readdatum der Items ausgegeben werden soll */
     unsigned NOSPOOL: 1;          /* gesetzt durch Option Nospool beim Einloggen->Read-zugriffe werden nicht registriert */
     unsigned INFOLINE: 1;         /* wenn true, wird Infoline angezeigt */
} FLAG2;
  
typedef struct 
{
     char NAME[21];
     char CLASS[3];           
     char GROUP[5];      
     char DATE[9];
     char TIME[9];
     char CALLS[7]; 
} USER;

typedef struct 
{
     char *IBUFF;
     int IBUFSIZ;
     int IBUFTL;
     int IBUFHD;
     int IBUFLOW;
     int IBUFHI;
     long *OBUFF;
     int OBUFSIZ;
     int OBUFTL;
     int OBUFHD;
     int OBUFLOW;
     int OBUFHI;
} RSIOREC;

typedef struct 
{
     unsigned sec:  5;
     unsigned min:  6;
     unsigned hour: 5;
} ZEITFELD;

typedef struct 
{
     int SEKUNDEN;
     int MINUTEN;
     int STUNDEN;
} UHRZEIT;

typedef struct
{
     FLAG    *APP_FLAG;        /* Pointer auf Systemflags1           */
     FLAG2   *APP_FLAG2;       /* Pointer auf Systemflags2           */
     USER    *APP_USER;        /* Pointer auf Userdaten              */ 
     char    *APP_SYSPATH;     /* Pfad ins Systemdirectory           */
     char    *APP_CATBUFF;     /* Pointer auf Catalogbuffer          */
     long    *APP_CATCOUNT;    /* LÑnge des Catalogs                 */
     long    APP_CALLS;        /* aktuelle Zahl der Anrufe           */
     int     APP_TMAX;         /* maximale Benutzerzeit in min.      */
     long    APP_LOGINTIME;    /* Einlogzeit in s (24:00=0s)         */
     int     APP_BAUD;         /* aktuelle Baudrate                  */
     int     APP_SCREENSIZE;   /* Screengroesse des Users in Zeilen  */ 
     char    *APP_ICNVRT;      /* Pointer auf Inputwandlungstabelle  */
     char    *APP_OCNVRT;      /* Pointer auf Outputwandlungstabelle */
} APP_PAR;

extern long atol();

/****************************************************************************

        Fuer den Programmierer der Applikation interessante Variablen
           
****************************************************************************/

FLAG  *Flag;                   /* Pointer auf Mystery Flags         */
FLAG2 *Flag2;                  /* Pointer auf Mystery Flag2         */
USER  *User;                   /* Pointer auf Userstruktur          */
long Calls;                    /* Anzahl der Anrufer                */
long Time;                     /* Zwischenspeicher fuer Zeiten in s */
int  Touttime=60;              /* Zeit fuer Timeout in s            */
int  Tmax;                     /* aktuelle maximale Benutzerzeit    */
long Login_time;               /* Einlogzeit des Users in Sekunden  */
int Cr_count;                  /* Zeilenzaehler fuer MORE           */ 
jmp_buf Terminate_env;         /* fuehrt normalerweise nach exit    */
jmp_buf Break_env;             /* muss vor I/O definiert werden     */
int Screensize;                /* Groesse (Zeilen) des Userscreens  */
char *Convert_oarray;          /* Zeiger auf Outputwandlungstabelle */
char *Convert_iarray;          /* Zeiger auf Inputwandlungstabelle  */

/****************************************************************************

*****************************************************************************

                         some stuff
                         
****************************************************************************/

char *Rsbuff;
int Last_char=0;
long *hz_200 = (long *) 0x000004ba;

UHRZEIT Uhrzeit;


int Last_input;                /* gespeichert durch ctrl bei NBRK */

RSIOREC *new_rsiorec;

short int *MFP = 0xFFFA01;

APP_PAR *App_par;   /* bekommen wir als erstes Argument uebergeben */

long Ti()                          /* Uhrzeit in Sekunden   */
{
     long time;

     Zeit();
     time = Uhrzeit.STUNDEN * 3600L + Uhrzeit.MINUTEN * 60L + (long)Uhrzeit.SEKUNDEN;
     return(time);
}

Carrier()                /* prueft auf CARRIER */
{
     short int  n;         
     long save_ssp;

     save_ssp = Super(0L);
     n = *MFP;
     Super(save_ssp);
     n = !((n & 2) >> 1);        
     return(n);                 /* n=true if carrier */                        
}


/***************************************************************************/
/*                                                                         */
/* Erlaeuterungen zu I/O und Longjumps                                     */
/*                                                                         */
/* Terminate_env muss vor allen I/O-Operationen korrekt gesetzt sein.      */
/*                                                                         */
/* Break_env muss vor allen Ausgabeoperationen gesetzt sein, bei denen     */
/* BRK erlaubt ist.                                                        */
/*                                                                         */
/*                                                                         */
/*                                                                         */
/***************************************************************************/


Sterminal()     /* 0 oder Zeichen von RS232C                */
                /* wenn !Carrier(), dann wird kein Zeichen  */
{               /* angenommen                               */
     int c=0;
                           
     if(Bconstat(AUX)&&Carrier())                           
          c = Bconin(AUX);
          
     return(c);
}

Terminal()           /* Holt Zeichen von der Console */
{
     long c=0;
     int scancode;
     
     if(Bconstat(CON))
     {
          c=Bconin(CON);
          scancode=c>>16;
      
          if(scancode>71 && scancode<81)
          {
               switch(scancode)
               {
               
                    case 75:  c=LEFT_ARROW;
                              break;
                              
                    case 77:  c=RIGHT_ARROW;
                              break;
                              
                    default:  c=0;
                              break;          
               }
               
          }
                                        
     }
     
     return((int)c);
}

/****************************************************************************


          Vom Programmierer der Applikation zu benutzende I/O-Routinen


****************************************************************************/


Mbgetchar()         /* wartet auf Eingabe von RS232C oder Tastatur   */
{                   /* Exit mit char oder CR und Flag.TOUT=1 bei     */
                    /* Timeout oder Flag.CARRIER_LOST=1 bei Carrier- */
                    /* verlust */
                    
     int c; 
     Time = Ti();

     Last_char=0;

     do
     {
         if(!(c=con_legal(Terminal())))
               c=legal(Sterminal()); 
          
          if(Tout() || Carrier_lost())
               longjmp(Terminate_env,0);       /* Session beenden */            
     }
     while(!c);
 
     return(c);
}

Mbputchar(c,mode)        /* Ausgabe auf Schirm und RS232C */
char c;
int mode;                         
{
     char in, auxout1, auxout2, conout1, conout2;

     if(Flag->LOCAL)
          conout1=Convert_oarray[2*(unsigned)c];
          
     else
     {
          auxout1=Convert_oarray[2*(unsigned)c];
          auxout2=Convert_oarray[2*(unsigned)c+1];
          conout1=c;
     }
          
     if((Carrier_lost() || Maxtime_exceeded()) && mode==BRK)
     {
          CRLF;
          longjmp(Terminate_env,0);
     }
      
     if(conout1=='\n')
     {
          Cr_count++;
          Bconout(CON,conout1);
     }
               
     else
     {
          if(conout1 != ESC)
               Bconout(CON,conout1);
     }
     
     if(Carrier())
     {
          Bconout(AUX,auxout1);


          if(auxout2 && Carrier())
               Bconout(AUX,auxout2);          
     }
     
     if(Flag->MORE && conout1=='\n')
     {
          if(Cr_count>(Screensize-1))
          {
               Cr_count=1;
               Mbprintf(NBRK,"<===MORE===>");
               in=More_getchar();
              
               Mbprintf(NBRK,"\r            \r");
               
               if((in==CTRL_X || in=='q') && mode==BRK)
                    longjmp(Break_env,0);
               
               if(in==CTRL_E || in=='Q')
                    longjmp(Terminate_env,0);
          }
     }
}

/* wie printf, jedoch ueber Screen und RS232C. Max. 10 Parameter! */
/* mode (BRK, NBRK, NCTRL) bestimmt, ob abgebrochen werden kann.  */            

Mbprintf(mode,pointer,p0,p1,p2,p3,p4,p5,p6,p7,p8,p9)
int mode;
char *pointer,*p0,*p1,*p2,*p3,*p4,*p5,*p6,*p7,*p8,*p9;
{
     char puffer[161];

     sprintf(puffer,pointer,p0,p1,p2,p3,p4,p5,p6,p7,p8,p9);
     mbtype((long) strlen(puffer),puffer,mode);
}

Mbgets(line,count)  /* Routine holt count Zeichen von der Con- */
char *line;         /* sole oder RS232C                        */
int count;
{
     unsigned char inp; 
     char buffer[160];
     int i=0;
     int crsr=0;

     if(Flag2->EDITLINE)
     {
          i=crsr=strlen(line);
          
          Mbprintf(NBRK,"\r\n%s",line);
          
          if(i==count)
          {
               CRSR_LT;
               VT_LEFT;
               crsr--;
          }
          
          else
               Flag2->EDITLINE=0;     
     }

     else
          line[0]='\0';
  
               
     while (i < (count+Flag2->EDITLINE)) 
     {
          inp=Mbgetchar();
    
          if(is_controll(inp))
               handle_ctrl(inp,&crsr,&i,line);
          
          else 
          {
               if (inp == '\r') 
                    break;
            
               if(i==crsr)
               {
                    line[i++] = inp; line[i] = '\0';
                    Mbputchar(inp,BRK);
                    crsr++;
               }
               
               else
               {
                    if(!Flag2->EDITLINE)
                    {
                         l_insert(inp,line+crsr);
                         crsr++;
                         i++;
                    }     
               }   
          }
     }
     
     if(Flag2->INSERT)
     {
          VT_OVER;
          Flag2->INSERT=0;
     }     
          
     Cr_count=0;     
     CRLF;

}

/* wie scanf, jedoch ueber Screen und RS232C. Max. 10 Parameter! */
/* maximale Stringlaenge muss vorgegeben werden                  */

Mbscanf(count,format,p0,p1,p2,p3,p4,p5,p6,p7,p8,p9)
int count;
char *format,*p0,*p1,*p2,*p3,*p4,*p5,*p6,*p7,*p8,*p9;

{
     char puffer[180];

     Mbgets(puffer,count);
     strcat(puffer," @ @ @ @ @ @ @ @ @ @ ");  /* das ist hier noetig!! */            
     sscanf(puffer,format,p0,p1,p2,p3,p4,p5,p6,p7,p8,p9);
}

Mbputfile(source)   /* gibt geoeffnetes File aus */
FILE *source;
{         
     char c;
     jmp_buf breakstore;
     
     Save_env(Break_env,breakstore); /* Environment saven */
     
     if(!setjmp(Break_env))
     {
          while((c = getc(source)) !=EOF)
          {
               charout(c,BRK);
               ctrl(BRK);
          }
     }
     
     fclose(source);
     
     Save_env(breakstore,Break_env); /* Environment wieder herstellen */
}

/****************************************************************************

     Andere Routinen, die nuetzlich sein koennten
     
****************************************************************************/

Empty_rsbuf()  /* loescht RS232C-Eingabepuffer */
{
     new_rsiorec->IBUFHD = new_rsiorec->IBUFTL = 0;
}

Elapsed_time()      /* returns die seit dem Einloggen verstrichene Zeit in Minuten */
{
     long zeit;

     zeit=Ti()-Login_time;

     if(zeit<0)
          zeit += 86400;

     return((int)(zeit/60));
}

Change(pointer) /* setzt String in Grossbuchstaben um */
char *pointer;
{
     while(*pointer)
          *pointer++=toupper(*pointer);
}

/****************************************************************************

               stuff cont.
               
****************************************************************************/

legal(c)  /*  Ueberprueft Eingaben des Users auf Legalitaet */
int c;    /*  und wandelt ggf auch Deletecodes um */

{
     int back;
     static int store;
     
     if(!c)
          return(FALSE);
   
     if(store=='[')
     {
          switch(c)
          {
               case 'A':      store=0;
                              return(UP_ARROW);
                              break;
                              
               case 'B':      store=0;
                              return(DOWN_ARROW);
                              break;
                              
               case 'C':      store=0;
                              return(RIGHT_ARROW);
                              break;
                              
               case 'D':      store=0;
                              return(LEFT_ARROW);
                              break;
                              
               default:       if(c!='1')
                                   store=0;
                              
                              else
                                   return(FALSE);
          }                          
     
     }

     if(store==ESC)
     {
          if(c == '[')
          {     
               store=c;
               return(FALSE);
          }
          
          else
               store=0;
     }
     
     if(c==CTRL_S)
          Time=Ti();

     if(c==ESC)
          store=ESC;

     back=(unsigned)Convert_iarray[c];
   
       
     return(back);
}

con_legal(c)  /*  Ueberprueft Eingaben von der Console auf Legalitaet */
int c;        /*  und wandelt ggf auch Deletecodes um */
{
     int back;
     
     switch(c)
     {
          case CTRL_S:   Time=Ti();
                         back=0;
                         break;
          case DEL:
          case BS:
          case CR:               
          case UP_ARROW:
          case DOWN_ARROW:
          case LEFT_ARROW:
          case RIGHT_ARROW:   
          case A_ae:
          case A_oe:
          case A_ue:
          case A_AE:
          case A_OE:
          case A_UE:
          case A_PA:
          case A_SZ:     back=c;
                         break;
                               
          default:       back=(c<32 || c>126) ? 0 : c;
                     
     }
     
     return(back);
}

More_getchar()      /* eigenes getchar fuer more, weil sonst ctrl-x nicht beruecksichtigt wird */  
{                  
     int c, store; 
     Time = Ti();

     store=Touttime;
     Touttime=300;
     
     do
     {
       if(!(c=Terminal()))
          c=Sterminal();
          
       c=more_legal(c);   
          
       if(Carrier_lost())
          longjmp(Terminate_env,0);       /* Session beenden */
          
       if(Maxtime_exceeded())
          longjmp(Terminate_env,0);       /* Session beenden */
          
       if(Tout())
          longjmp(Terminate_env,0);
     }
     while(!c);

     Touttime=store;
     
     return(c);
}

more_legal(c)  /*  Ueberprueft Eingaben auf Legalitaet */
int c;  

{
     int back;
     
     return(back=((c<32 || c>126) && c!=CTRL_X && c!=CR) ? 0 : c);
}

Rsout(string) /* Ausgabe nur ueber Rs323c */
char *string;
{
     while(*string)
     {
          if(Carrier())
               Bconout(AUX,*string);

          string++;
     }          
}


charout(c,mode)          /* Ausgabe fuer Mailbox */
char c;
int mode;
{
     while(new_rsiorec->OBUFHD != new_rsiorec->OBUFTL);

     Mbputchar(c,mode);

     if(Flag->SLOW)
          Wait(30L);
}


ctrl(mode)         /* stellt fest, welcher code, wartet bei CTRL_S */
int mode;
{
     register int c;
     
     if(mode==NCTRL)
          return;

     if(!(c=Last_char))               
          if(!(c=Terminal()))
               if(!(c=Sterminal()))
                    return;
          
     Last_char=0;
               
     if(c==CTRL_S)
     {
          c=halt(mode);
     }
     
     Empty_rsbuf();
     
     if(mode!=NBRK && c==CTRL_X)
     {     
          Cr_count=0;
          CRLF;
          longjmp(Break_env,0);
     }
    
     else
          Last_char=c; 
}    
          
halt(mode)    /* wartet auf naechstes Zeichen des Users */
int mode;
{
     int c;
     
     Time=Ti();
     
     Cr_count=0;

     do
     {
          if(!(c=Terminal()))
               c=Sterminal();
               
          if(c==CTRL_S)
               c=0;
               
     }
     while(!Tout() && !Carrier_lost() && !c);
          
     Flag->TOUT=0;
     return(c);
}          

mbtype(count,buff,mode)  /* gibt Daten ueber Screen und RS232C aus */
register long count;   
register char *buff;
int mode;             
{

     long counter=0;
 
     while(counter < count)
     {
          charout(*buff,mode);
          ctrl(mode);
          counter++;
          buff++;
     }
}

Mbwrite(count,buff) /* wie Write, jedoch ueber Screen und RS232C */
long count;
char *buff;
{
     mbtype(count,buff,BRK);
}


handle_ctrl(input,crsr,end,buffer)
int input,*crsr,*end;
char *buffer;
{
     int back=TRUE;
     int i;
    
     switch(input)
     {
          case BS:            if(*crsr>0)
                              {
                                   if(*end == *crsr)
                                   {
                                        buffer[--(*end)]= '\0';
                                        (*crsr)--;
                                        BACKSPACE;
                                   }
                                   
                                   else
                                   {
                                        backdelete(buffer+(*crsr)--);
                                        (*end)--;
                                   }
                              }
                              
                              else
                              {
                                   if(!Flag->BELLOFF)
                                        BELL;
                              }
                              
                              break;
                     
          case DEL:           if(*end>0)
                              {
                                   if(*end == *crsr)
                                   {
                                        buffer[(*end)--]='\0';
                                        (*crsr)--;
                                        BACKSPACE;
                                   }
                                   
                                   else
                                   {
                                        l_delete(buffer+(*crsr));
                                        (*end)--;
                                        
                                        if(*end == *crsr)
                                        {
                                             Flag2->INSERT=0;
                                             VT_OVER;
                                        }     
                                   }

                               }
                               
                               else
                               {
                                   if(!Flag->BELLOFF)
                                        BELL;
                               }
                              
                               break;
                                                                          
          case LEFT_ARROW:     if(*crsr>0)
                               {
                                   CRSR_LT;
                                   VT_LEFT;
                                   (*crsr)--;

                                   if(!Flag2->INSERT)
                                   {
                                        Flag2->INSERT=1;
                                        VT_INSERT;
                                   }     
                               }
                                        
                               else
                               {
                                   if(!Flag->BELLOFF)
                                        BELL;
                               }
                              
                               break;
                                        
          case RIGHT_ARROW:    if(*crsr < *end)
                               {
                                   CRSR_RT;
                                   VT_RIGHT;
                                   (*crsr)++;
                                   
                                   if(*crsr == *end)
                                   {
                                        Flag2->INSERT=0;
                                        VT_OVER;
                                   }     
                               }
                                        
                               break;
                                        
     }                                        

     return(back);
} 


backdelete(pointer)
char *pointer;
{
     Flag2->EDITLINE=0;
     VT_LEFT;
     CRSR_LT;
     STORE_CRSR;
     CRSR_OFF;
     VT_DEL;
     strcpy(pointer-1,pointer);
     printf("%s ",pointer-1);
     fflush(stdout);
     RESTORE_CRSR;
     CRSR_ON;
}

l_delete(pointer)
char *pointer;
{
     Flag2->EDITLINE=0;
     STORE_CRSR;
     CRSR_OFF;
     VT_DEL;
     strcpy(pointer,pointer+1);
     printf("%s ",pointer);
     fflush(stdout);
     RESTORE_CRSR;
     CRSR_ON;
}                                                    

l_insert(inp,pointer)
char *pointer;
int inp;
{
     char buffer[190];

     strcpy(buffer,pointer);
     *pointer= inp;
     *(pointer+1)= '\0';

     Mbputchar(inp,BRK);
     STORE_CRSR;
     CRSR_OFF;
     printf("%s",buffer);
     fflush(stdout);
     RESTORE_CRSR;
     CRSR_ON;
     strcat(pointer,buffer);
}
  

is_controll(c)
int c;
{
     return(c==BS || c==DEL || c==LEFT_ARROW || c==RIGHT_ARROW);
}


Maxtime_exceeded()       /* returns true, if maxtime exceeded    */
{
     if(Elapsed_time() < Tmax)
          return(FALSE);

     Flag->TMAX=1;
     return(TRUE);
}

long Fetch_ticks()  /* holt ticks aus 200hz-Counter */
{
     long save_ssp,ticks;
     
     save_ssp=Super(0L);
     ticks=*hz_200;
     Super(save_ssp);
     
     return(ticks);
}
     
Wait(n)                     /* wartet n millisekunden (kleinste Aufloesung 5 ms) */
long n;
{
     long startticks, ticks, sollticks;
     
     sollticks = n/5;              /* ein tick = 5ms */
     startticks = Fetch_ticks();    

     for(;;)
     {
     
          ticks=Fetch_ticks()-startticks;
          
          if(ticks<0)
               ticks+=0xEFFFFFFFL;
               
          if(ticks>=sollticks)
               break;
     }     
}


Save_env(source,dest) /* speichert Environment in dest */
jmp_buf source, dest;
{
     int x;
     
     for(x=0;x<9;x++)
          dest[x]=source[x];
}

Zeit()
{


     int time;
     ZEITFELD *pointer;
     
     pointer=(ZEITFELD *)&time;
     
     time = Tgettime();
     Uhrzeit.STUNDEN = pointer->hour;
     Uhrzeit.MINUTEN = pointer->min;
     Uhrzeit.SEKUNDEN = pointer->sec * 2;
}

Carrier_lost()     /* True wenn weder Carrier noch Lokalbetrieb */
{
     int flag;
     flag = !Carrier() && !Flag->LOCAL;
     Flag->CARRIER_LOST = flag;
     return(flag);
}

Tout()                    /* True, wenn Timeout   */
{
     int flag = FALSE;
     long x;

     x = Ti() - Time;
   
     if(x < 0L)
          x += 86400;
          
     if(x > ((long) Touttime))
     {
          flag = TRUE;
          Flag->TOUT = TRUE;
     }
     
     return(flag);
}

prepare()        /* exit vorbereiten */
{
     Flag2->EDITLINE=0;
     Flag2->INSERT=0;
     VT_OVER;
}

/****************************************************************************

     Beginn von main mit ein paar Beispielen
     
****************************************************************************/

main(argc,argv)     /* Start des Programms */
int argc;
char *argv[];
{
     char inputbuffer[21];
     
     if(argc==1)
          exit(1);                        /* ohne Argumente wollen wir nicht */

     App_par=(APP_PAR *)atol(argv[1]);    /* wir holen Variablen */
    
     Flag=(FLAG *)(App_par->APP_FLAG);
     Flag2=(FLAG2 *)(App_par->APP_FLAG2);
     User=(USER *)(App_par->APP_USER);
     Calls=App_par->APP_CALLS;
     Tmax=App_par->APP_TMAX;
     Login_time=App_par->APP_LOGINTIME;
     new_rsiorec = (RSIOREC *)Iorec(0);
     Convert_iarray=App_par->APP_ICNVRT;
     Convert_oarray=App_par->APP_OCNVRT;
     Screensize=App_par->APP_SCREENSIZE;          

/* Diese Stelle wird angesprungen bei Verlust des Carriers, Timeout
   oder Ueberschreiten der maximalen Benutzerzeit                        */
   
     if(setjmp(Terminate_env))
     {
          prepare();
          exit(1);
     }
          
     CRLF;          /* Leerzeilen nach Programmstart, Break_env braucht */
     CRLF;          /* noch nicht gesetzt zu werden. da CTRL_X nicht    */
                    /* moeglich ist */
                    /* bei Mbprintf fuer Zeilenvorschub immer \r\n ver  */
                    /* wenden !!                                        */

     Mbprintf(NBRK,"         TESTAPPLIKATION\r\n");
     Mbprintf(NBRK,"         ===============\r\n\r\n\r\n");      
     Mbprintf(NBRK,"Moechtest Du eine Anleitung (J/N)?>");
     Mbgets(inputbuffer,20); /* Antwort mit maximal 20 Zeichen holen */
     
     Empty_rsbuf(); /* sicherheitshalber Inputbuffer loeschen           */
     
     if(!setjmp(Break_env)) /* es folgen Ausgaben, die mit CTRL_X abge- */
     {                      /* brochen werden koennen, deswegen muss    */
                            /* Break_env gesetzt werden                 */
                            
          if(*inputbuffer=='J' || *inputbuffer=='j')
          {
               Mbprintf(BRK,"\r\nDas ist ein Beispiel fuer eine Gebrauchsanweisung, die natuerlich\r\n");
               Mbprintf(BRK,"hier nur einen totalen Unsinnstext bringt. Es wird aber gezeigt,\r\n");
               Mbprintf(BRK,"dass hier ein Text ausgegeben wird, der sich abbrechen laesst.\r\n");
          }
     }
     
     *inputbuffer='\0';
     
     while(strcmp(inputbuffer,"ENDE"))
     {     
          Mbprintf(NBRK,"\r\nWas nun %s (Spiel,Ende)?>",User->NAME);
          Mbgets(inputbuffer,20);
          Change(inputbuffer);       /* Antwort in Grossbuchstaben umsetzen */
          
          CRLF;
          
          if(!strcmp(inputbuffer,"SPIEL"))
               Mbprintf(NBRK,"Das waere das Spiel...\r\n");
               
          else
          {
               if(strcmp(inputbuffer,"ENDE"))
                    Mbprintf(NBRK,"Eingabefehler!!!\r\n");
          }
     }
     
     /* Spieler hat Ende gewaehlt, es kommt nun noch etwas Bla-bla, um zu */
     /* zu zeigen, dass vor jeder abbrechbaren Ausgabe Break_env gesetzt  */
     /* werden muss                                                       */
     
     if(!setjmp(Break_env))
     {
          Mbprintf(BRK,"Ich hoffe, Dir hat das Spiel gefallen %s und Du startest es bald mal\r\nwieder.\r\n\r\n",User->NAME);
          Mbprintf(BRK,"Statistik\r\n");
          Mbprintf(BRK,"=========\r\n\r\n");
          Mbprintf(BRK,"Zeit im System %d min.\r\n",Elapsed_time());
          Mbprintf(BRK,"Anrufer insgesamt %ld\r\n",Calls);
          Mbprintf(BRK,"Deine Anrufe bisher %ld\r\n\r\n",atol(User->CALLS));
     }

     prepare();                        
}
                             
