#include <b_nach_c.h>


#define DEBUG /* Notwendig, falls mit Debuggern gearbeitet werden soll */

/***************** B_init und B_exit ************/

static int B_open_workstation(void);
static void speicher(void);

/* Intern verwendete Variablen */

extern char *TEMP, *TEMPA, *TEMPM;

extern MFDB *D_mfdb,*S_mfdb,*FORM;

extern OBJECT *TREE;

#ifdef __TURBOC__
/* Da einzelne Implementationen der C Funktion 'signal()' nicht
   den korrekten Exceptionvektor zurÅckliefern, wird hier eine
   Ersatzkonstruktion verwendet. Solange die Turbo C - Fehler
   bei der Privilegverletzung und der Tastaturabfrage nicht be-
   hoben sind, mÅssen leider die entsprechenden signal-Abfragen
   herausgenommen werden: dies erledigt vq_tt() durch das
   Cookie-Prinzip.
*/
#ifdef ERROR
  static sigfunc_t SIGNAL(int _a, sigfunc_t _b)
    {
    sigfunc_t old, new;
    long ssp;

    ssp = Super(0L);
    switch (_a) 
      {
      case SIGILL:   old = *((sigfunc_t *)0x00000010); break;
      case SIGTRACE: old = *((sigfunc_t *)0x00000024); break;
      case SIGSEGV:  old = *((sigfunc_t *)0x00000008); break;
      case SIGADR:   old = *((sigfunc_t *)0x0000000c); break;
      case SIGDIV0:  old = *((sigfunc_t *)0x00000014); break;
      case SIGCHK:   old = *((sigfunc_t *)0x00000018); break;
      case SIGTRAPV: old = *((sigfunc_t *)0x0000001c); break;
      case SIGPRIV:  old = *((sigfunc_t *)0x00000020); break;
      }
    Super((void *) ssp);
    new = signal(_a, _b);
    return ((new != NULL) ? new : old);
  }
#else
  #define SIGNAL(_a, _b)  signal(_a, _b)
#endif /* __TURBOC__ */

  static sigfunc_t bus_err,adr_err,div_err,chk_err,trapv_err, priv_err;
  #ifndef DEBUG
  static sigfunc_t ill_err,trace_err;
  #endif
#endif
static int GRAF;  /* 1: VDI, AES wurden initialisiert, sonst 0 */
static int tt;    /* 1: TT vorhanden, sonst 0 */

void B_init(int a)
  {
  extern void setakwind(int,int,int,int);
    /* Konvertereigene Fehlerbehandlung */
  extern int B_on_error(struct exception *a);
  extern void _syst(void), syst(int sig);
  static int vq_tt(void);

  tt = vq_tt();

#ifdef ERROR
  #ifdef FLT
    setmatherr(B_on_error);       /* Fehlerroutine */
  #endif
  #ifndef DEBUG
    ill_err   = SIGNAL(SIGILL,(void (*)(int))syst);
    trace_err = SIGNAL(SIGTRACE,(void (*)(int))syst);
  #endif
    bus_err   = SIGNAL(SIGSEGV,(void (*)(int))syst);
    adr_err   = SIGNAL(SIGADR,(void (*)(int))syst);
    div_err   = SIGNAL(SIGDIV0,(void (*)(int))syst);
    chk_err   = SIGNAL(SIGCHK,(void (*)(int))syst);
    trapv_err = SIGNAL(SIGTRAPV,(void (*)(int))syst);
    if(!tt)                      /* wegen Fehler in Turbo C bei TT's */
      priv_err  = SIGNAL(SIGPRIV,(void (*)(int))syst);
  
    _syst();                      /* Setjmp vorbereiten */
#endif

  SP=0UL;                         /* Speicherindex initialisieren */
  speicher();                     /* Speicherallokation */

#ifdef GEM
  if(a)                           /* Bei Grafik */
    {
    GRAF = 1;
    AP_ID = appl_init();          /* Workstation initialisieren */
    linea_init();                 /* Linea initialisieren */
    HANDLE = B_open_workstation();/* und VDI */
    OLDHANDLE=HANDLE;
    }
#else                             /* von #ifdef GEM */
  switch(Getrez())
    {
    case 2:
      VF = 16;                    /* Zeichenhîhe */
      P_ARRAY[2] = 640;           /* Anzahl Pixel in der Breite */
      P_ARRAY[3] = 400;           /* Anzahl Pixel in der Hîhe */
      break;
    case 1:
      VF = 8;
      P_ARRAY[2] = 640;
      P_ARRAY[3] = 200;
      break;
    case 0:
      VF = 8;
      P_ARRAY[2] = 320;
      P_ARRAY[3] = 200;
      break;
    }
  HF = 8;                         /* Zeichenbreite */
  MS=P_ARRAY[2]/HF;               /* max. Anzahl Spalten */
  MZ=P_ARRAY[3]/VF;               /* max. Anzahl Zeilen */
#endif                            /* von #ifdef GEM */
/*    printf("\33E");                Kînnte zum Bildschirmlîschen ohne GEM
                                     verwendet werden - kann jedoch
                                     bei hîheren Auflîsungen wegen eines 
                                     Betriebssystemfehler schiefgehen! */

#ifdef GEM
  graf_mouse(M_OFF, NULL);        /* Maus aus */
  HFL=-1;                         /* Flag fÅr SHOWM,HIDEM */
                                  /* -1:an, 0:immer zeigen, 1:aus */
  wind_update(BEG_UPDATE);        /* Update anmelden, bzw. auf andere
                                     Applikationen warten */

  if(a)                           /* Wenn Grafik gewÅnscht (wird z.Z. nicht
                                     unterschieden: immer 1 */
    {
    vs_clip(HANDLE, 1, P_ARRAY);  /* Clipping und CLS */
    v_clrwk(HANDLE);              /* Falls CLS zu Beginn erwÅnscht */
    v_curhome(HANDLE);            /* Cursor unter GEM in Homeposition */
    }
  MF = 0;                         /* Maus als aus kennzeichnen */
#else
  Cconws("\33H");
#endif                            /* Einige Vorbesetzungen macht der GFA-
                                     Interpreter, der Compiler aber nicht */
  Cconws("\33v\33f");             /* Cursor nach HOME Wrapping an und Cursor aus
                                     - falls gewÅnscht */
  B_locate(1,1);                  /* Cursorposition: links oben */

  HVA = 0;                        /* Hilfsvariable fÅr z.B. INSERT */
  DAZ = 0L;                       /* DATA - Index */
  VT = 1;                         /* Vertikal-Tab (intern) */
  HT = 0;                         /* Horizontal-Tab (intern) */
  HTAB = VTAB = -1;               /* ebenso fÅr LOCATE */
  KEY_P = 46;                     /* Numerischer Tastenblock wie in BASIC */
  ZL = 0;                         /* Interner Zeilenpointer fÅr Stringverkettungen */
  setakwind(P_ARRAY[0], P_ARRAY[0], P_ARRAY[2], P_ARRAY[3]);
                                  /* Fensterkoordinaten merken */
  }

void B_exit(int a)
  {
  extern int exitfl;
  int i;
  if(exitfl)                      /* Bei Fehlern in B_exit(): 'raus' */
    exit(-1);
  exitfl=1;

#ifdef GEM
  if(GRAF)
    {
    if(!MF)
      {
      graf_mouse(M_ON, NULL);     /* Maus aus */
      wind_update(END_UPDATE);    /* wind_update() nicht vergessen */
      }
    v_clsvwk(HANDLE);             /* Lîschen der Workstation */
    appl_exit();                  /* Applikation abmelden */
    }
#endif
  while(SP)                       /* Speicher geordnet freigeben */
    if(SPEICHER[--SP] != NULL)
      free(SPEICHER[SP]);
#ifdef ERROR
  #ifndef DEBUG                   /* Fehlerverwaltung aushÑngen und alte */
    signal(SIGILL,ill_err);       /* Vektoren wieder einhÑngen */
    signal(SIGTRACE,trace_err);
  #endif
    signal(SIGSEGV,bus_err);
    signal(SIGADR,adr_err);
    signal(SIGDIV0,div_err);
    signal(SIGCHK,chk_err);
    signal(SIGTRAPV,trapv_err);
    if(!tt)                       /* wegen Fehler in Turbo C bei TT's */
      signal(SIGPRIV,priv_err);
#endif
  exit(a);                        /* und tschÅû */
  }

static int vq_tt(void)
  {
  long old = Super(0L),*cookiejar,cookie;
  cookiejar = *((long **) 0x5a0L);
  Super((void *)old);
  if(!cookiejar)                                /* Keine Cookies da */
    return(0);
  else
    {
    do
      {
      if(!strncmp((char *)cookiejar,"_CPU",4))  /* CPU suchen */
        {
        cookie=cookiejar[1];
        return(cookie>10 ? 1 : 0);
        }
      else
        cookiejar = &(cookiejar[2]);            /* nÑchste Cookie */
      }
      while(cookiejar[0]);
    }
  return(0);
  }

static void speicher(void)        /* Speicherallocation */
  {
  /* SPEICHER-Liste - max. Grîûe: SMAX */
  if((SPEICHER = (char **)calloc(SMAX,sizeof(char *))) == NULL)
    B_fehler(NULL,0,8);
  else
    SPEICHER[SP++] = (char *)SPEICHER;

#ifdef GEM
  /* MFDB Destination-Speicher */
  if((D_mfdb = (MFDB *)calloc(1,sizeof(MFDB))) == 0L) 
    B_fehler(NULL,0,8);
  else
    SPEICHER[SP++] = (char *)D_mfdb;

  /* MFDB Source-Speicher */
  if((S_mfdb = (MFDB *)calloc(1,sizeof(MFDB))) == 0L) 
    B_fehler(NULL,0,8);
  else
    SPEICHER[SP++] = (char *)S_mfdb;

  /* OBJECT Speicher */
  if((TREE = (OBJECT *)calloc(1,sizeof(OBJECT))) == 0L) 
    B_fehler(NULL,0,8);
  else
    SPEICHER[SP++] = (char *)TREE;
#endif

  /* TemporÑrer Stringspeicher: regelbar durch M_AXS in B_NACH_C.H */
  if((TEMP = (char *)calloc(MAXS,(size_t)sizeof(char))) == 0L)
    B_fehler(NULL,0,8);
  else
    SPEICHER[SP++] = TEMP;
  TEMP += 8;                        /* Platz fÅr Deskriptoren */
  if((long)TEMP & 1)                /* Schutz vor Adresserror */
    TEMP++;
  TEMPA = TEMP;                     /* Anfang temp. Buffer merken */
  TEMPM = TEMP + MAXS-10;
  }

/************ Grafik Initialisierung ************/

#ifdef GEM
static int B_open_workstation(void)
  {
  register int x;
  int      handle,W_in[11];
  int      d;
      
  if((FORM = (MFDB *)calloc(1,sizeof(MFDB))) == 0L)
    B_fehler(NULL,0,8);
  else
    SPEICHER[SP++] = (char *)FORM;
  W_in[0] = 1;
  for(x=1; x<10; x++)
      W_in[x] = 1;
  W_in[10] = 2;

  handle = graf_handle(&d, &d, &d, &d);

  v_opnvwk(W_in, &handle, B_WORK_OUT);

  if (!handle)
    {
    Cconws("\033E Error: Cannot open Virtual Device");
    getch();
    exit(1);
    }
  P_ARRAY[0] = 0;   /* x - Nullpunkt */
  P_ARRAY[1] = 0;   /* y - Nullpunkt */

  FORM -> fd_addr = 0L;
  /*  Breite des Bildschirms in Pixeln */
  FORM->fd_w = P_ARRAY[2] = B_WORK_OUT[0];
  /*  Die Hîhe des Bildschirms in Pixeln */
  FORM->fd_h = P_ARRAY[3] = B_WORK_OUT[1];
  /*  Anzahl der WORD's eines Bildschirms */
  FORM->fd_wdwidth = (FORM->fd_w+1)>>4;
  /*  Arbeitssystem: Rasterkoordinaten */ 
  FORM -> fd_stand = 0;
  /*  Anzahl der Farbebenen */
  switch(B_WORK_OUT[13])
    {
    case 16:  FORM -> fd_nplanes = 4; break;
    case 8:   FORM -> fd_nplanes = 3; break;
    case 4:   FORM -> fd_nplanes = 2; break;
    default:  FORM -> fd_nplanes = 1; break;
    }
  GM = MD_REPLACE;              
  vswr_mode(handle, GM);
  vqt_attributes(handle, W_in);
  graf_mouse(0,NULL);
  HF = W_in[8];         /* Zeichenbreite */
  VF = W_in[9];         /* Zeichenhîhe */
  MS=B_WORK_OUT[0]/HF;  /* max. Anzahl Spalten */
  MZ=B_WORK_OUT[1]/VF;  /* max. Anzahl Zeilen */
      
  return(handle); /* RÅckgabe: Handle der Workstation */
  }
#endif
/***************** Window *****************/

void setakwind(int x,int y,int w,int h)
  {
  extern int TX,TY,TW,TH,SM,ZM;
  TX = x;       /* Aktuelles Fenster: x-Koordinate */
  TY = y;       /* Aktuelles Fenster: y-Koordinate */
  TW = w;       /* Aktuelles Fenster: Breite */
  TH = h;       /* Aktuelles Fenster: Hîhe */
  SM = TW/HF;   /* Maximale Spaltenzahl */
  ZM = TH/VF;   /* Maximale Zeilenzahl */
  }

/* ---------------------------------------------------------------------- */
/* -------------------------- End of file ------------------------------- */
/* ---------------------------------------------------------------------- */

