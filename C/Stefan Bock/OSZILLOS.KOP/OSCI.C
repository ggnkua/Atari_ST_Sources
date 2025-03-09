/***********************************************/
/* Falcon-Sound-Oszilloskop        Version 1.0 */
/* Autor: Stefan Bock       fÅr MAXON Computer */
/* erstellt mit Pure-C Version Feb 26 1992     */
/* OSCI.C : C-Teil                             */
/***********************************************/

#include <stdio.h>
#include <stdlib.h>
#include <tos.h>
#include <time.h>
#include <vdi.h>
#include <aes.h>

/* Die Bindings fÅr die verwendeten Funktionen */
/* Falls Sie bereits eine Datei "sndbind.h"    */
/* eingetippt haben (siehe Text), kînnen Sie   */
/* diese mit #include einbinden und die folgen-*/
/* den defines auslassen                       */
#define	locksnd()             xbios(0x80)
#define unlocksnd()           xbios(0x81)
#define	soundcmd(a,b)         xbios(0x82,a,b)
#define	setbuffer(a,b,c)      xbios(0x83,a,b,c)
#define	setsndmode(a)         xbios(0x84,a)
#define	settrack(a,b)         xbios(0x85,a,b)
#define	setmontrack(a)        xbios(0x86,a)
#define	buffoper(a)           xbios(0x88,a)
#define	devconnect(a,b,c,d,e) \
                            xbios(0x8B,a,b,c,d,e)
#define	sndstatus(a)          xbios(0x8C,a)
#define	buffptr(a)            xbios(0x8D,a)

/* weitere defines */
#define	LTATTEN		0
#define	RTATTEN		1
#define	LTGAIN		2
#define	RTGAIN		3
#define	ADDERIN		4
#define	ADCINPUT	5
#define	SETPRESCALE	6
#define ADC         3
#define DMAREC      0x01
#define FENSTER_WORD      19
#define FENSTER_BREITE   FENSTER_WORD * 16
#define FENSTER_HOEHE    176
#define NULL_LINKS        47
#define NULL_RECHTS      127
#define BILDER_PRO_SEK    25
#define SAMPLEFREQUENZ 49170L
#define VORTEILER          1
#define AUDIOGROESSE   16000L
#define BILDGROESSE     6688L

#define min(a, b)  ((a) < (b) ? (a) : (b))
#define max(a, b)  ((a) > (b) ? (a) : (b))

/* Prototyp fÅr die Assemblerroutine */
extern void cdecl zeichne_bild (long *zeilen,
                             long *hintergrund,
                             long *samplepuffer);

/* Typvereinbarungen */
typedef struct         /* siehe Xbios-Funktion */
{                      /* buffptr () im Text   */
  long playbufptr;
  long recbufptr;
  long resv1;
  long resv2;
} buffptrtype;

typedef enum           /* Definition eines */
{                      /* Boolean-Typs     */
  FALSE,
  TRUE
} boolean;

extern int _app;     /* _app = 0 : Accessory   */
                     /* _app = 1 : Applikation */

/* die Variablen fÅr die GEM-Initialisierung */
int    work_in[103], work_out[57];
int    workstation;
int    gl_apid;
int    gl_hchar, gl_wchar, gl_hbox, gl_wbox;

/* Position der Maus, Zustand der Maustasten */
int    mx, my, mbutton, mstate, keycode, mclicks;

/* Grîûe des Desktop, maximale Fenstergrîûe */
GRECT  desktop, maxfenster;

/* Fensterparameter */
int    fensterhandle   = -1;
int    fensterart      = NAME|CLOSER|MOVER;
char   fenstername[14] = " Oszilloskop ";
char   accname[20]     = "  Falcon-Oszi V1.0";
GRECT  aussen, innen;

/* Bitmaps und Pufferzeiger */
MFDB   hintergrund, bildschirm,
       gesamt_abh, gesamt_unabh;
long   *samplepuffer, audiopuffer[2];
int    index = 0;

/* weitere globale Variablen */
int     farben[2] = {0, 1};/* Vorder- und      */
                           /* Hintergrundfarbe */
long    zeilen[FENSTER_HOEHE];
long    alter_zustand[7];
boolean speicher_da = FALSE;

/* Anmeldung beim GEM */
boolean open_vwork (void)
{
  int i, phys;

  if ((gl_apid = appl_init()) != -1)
  {
    for (i = 1; i < 103; work_in[i++] = 1);
    work_in[10] = 2;
    phys = graf_handle (&gl_wchar, &gl_hchar,
                        &gl_wbox , &gl_hbox);
    work_in[0] = workstation = phys;
    v_opnvwk (work_in, &workstation, work_out);
    return (TRUE);
  }
  else
    return (FALSE);
}

/* Abmeldung beim GEM */
void close_vwork (void)
{
  v_clsvwk (workstation);
  appl_exit ();
}

/* Gibt einen Speicherblock nur frei, wenn    */
/* dieser vorher erfolgreich alloziert wurde  */
void testfree (long *speicher)
{
  if (speicher != NULL)
    free (speicher);
}

/* Gibt allen allozierten Speicher frei */
void free_alles (void)
{
  testfree (hintergrund.fd_addr);
  testfree (gesamt_unabh.fd_addr);
  testfree (samplepuffer);
  speicher_da = FALSE;
}

/* Zeichnet das Bild, welches im Hintergrund   */
/* des Fensters liegt (Raum zur kÅnstlerischen */
/* Entfaltung !)                               */
void zeichne_hintergrund (void)
{
  int z, s, *zeile, distanz;

  zeile = (int *) hintergrund.fd_addr;
  for (z = 0; z < FENSTER_HOEHE; z++)
  {
    distanz = min(abs(z-NULL_LINKS),
                  abs(z-NULL_RECHTS));
    if (z==0 || z==FENSTER_HOEHE - 1 ||
        distanz==0)
    {
      for (s = 0; s < FENSTER_WORD; s++)
        *(zeile+s) = 0xFFFF;
    }
    else if (distanz == 3 || distanz == 4 ||
             (((z+1)%16==0) && (distanz!=0)))
    {
      *(zeile) = 0x8001;
      for (s = 1; s < FENSTER_WORD; s++)
        *(zeile+s) = 0x0001;
    }
    else if (distanz == 1 || distanz == 2)
    {
      *(zeile) = 0x8101;
      for (s = 1; s < FENSTER_WORD; s++)
        *(zeile+s) = 0x0101;
    }
    else
    {
      *(zeile) = 0x8000;
      *(zeile + FENSTER_WORD - 1) = 0x0001;
      for (s = 1; s < FENSTER_WORD - 1; s++)
        *(zeile+s) = 0x0000;
    }
    zeile += FENSTER_WORD;
  }
}

/* Ermitteln der öberschneidungsflÑche zweier */
/* Rechtecke, wird beim Redraw gebraucht      */
int rc_intersect (GRECT *r1, GRECT *r2)
{
  int x, y, w, h;

  x = max(r2->g_x, r1->g_x);
  y = max(r2->g_y, r1->g_y);
  w = min(r2->g_x + r2->g_w, r1->g_x + r1->g_w);
  h = min(r2->g_y + r2->g_h, r1->g_y + r1->g_h);
  r2->g_x = x;
  r2->g_y = y;
  r2->g_w = w - x;
  r2->g_h = h - y;
  return ((w > x) && (h > y));
}

/* Neuzeichnen der FensterflÑche (Redraw) */
void zeichne_fenster (GRECT *flaeche)
{
  GRECT   ausschnitt;
  int     pxy[8];
  boolean maus_aus = FALSE;

  wind_update (BEG_UPDATE);
  wind_get (fensterhandle, WF_FIRSTXYWH,
            &ausschnitt.g_x, &ausschnitt.g_y,
            &ausschnitt.g_w, &ausschnitt.g_h);
  while (ausschnitt.g_w && ausschnitt.g_h)
  {
    if (rc_intersect (&desktop, &ausschnitt))
    {
      if (rc_intersect (flaeche, &ausschnitt))
      {
        pxy[0] = ausschnitt.g_x - innen.g_x;
        pxy[1] = ausschnitt.g_y - innen.g_y;
        pxy[2] = pxy[0] + ausschnitt.g_w - 1;
        pxy[3] = pxy[1] + ausschnitt.g_h - 1;
        pxy[4] = ausschnitt.g_x;
        pxy[5] = ausschnitt.g_y;
        pxy[6] = pxy[4] + ausschnitt.g_w - 1;
        pxy[7] = pxy[5] + ausschnitt.g_h - 1;
        if ((maus_aus == FALSE) &&
            (mx+10 >= ausschnitt.g_x) &&
            (my+16 >= ausschnitt.g_y) &&
            (mx<ausschnitt.g_x+ausschnitt.g_w) &&
            (my<ausschnitt.g_y+ausschnitt.g_h))
        {
          maus_aus = TRUE;
          graf_mouse (M_OFF, NULL);
        }
        vrt_cpyfm (workstation, MD_REPLACE, pxy,
                   &gesamt_abh, &bildschirm,
                   farben);
      }
    }
    wind_get (fensterhandle, WF_NEXTXYWH,
              &ausschnitt.g_x, &ausschnitt.g_y,
              &ausschnitt.g_w, &ausschnitt.g_h);
  }
  if (maus_aus == TRUE)
    graf_mouse (M_ON, NULL);
  wind_update (END_UPDATE);
}

/* Initialisierung des Audiosystems, Starten   */
/* des Samplens und Oeffnen des Fensters, gibt */
/* TRUE zurÅck, wenn Darstellung unmîglich ist */
boolean darstellung_an (void)
{
  int  i, *hilfspointer;

  if ((FENSTER_BREITE > maxfenster.g_w) ||
      (FENSTER_HOEHE  > maxfenster.g_h))
  {
    form_alert (1,
          "[3][Auflîsung zu gering][ Abbruch ]");
    return (TRUE);
  }
  if (locksnd () < 0L)
  {
    form_alert (1,
     "[3][Soundsystem ist gesperrt][ Abbruch ]");
    return (TRUE);
  }
  if (speicher_da == FALSE)
  {
    hintergrund.fd_addr =
                   (long *)malloc (BILDGROESSE);
    gesamt_unabh.fd_addr =
                   (long *)malloc (BILDGROESSE);
    samplepuffer = (long *)malloc (AUDIOGROESSE);
  }
  if ((hintergrund.fd_addr   == NULL) ||
      (gesamt_unabh.fd_addr  == NULL) ||
      (samplepuffer          == NULL))
  {
    form_alert (1,
         "[3][Nicht genug Speicher][ Abbruch ]");
    free_alles ();
    unlocksnd ();
    return (TRUE);
  }
  else
    speicher_da = TRUE;
  hilfspointer = (int *) gesamt_unabh.fd_addr;
  for (i=0; i<FENSTER_HOEHE; i++)
  {
    zeilen[i] = (long) hilfspointer;
    hilfspointer += FENSTER_WORD;
  }
  gesamt_abh.fd_addr = gesamt_unabh.fd_addr;
  gesamt_abh.fd_w =
            (gesamt_unabh.fd_w = FENSTER_BREITE);
  gesamt_abh.fd_h =
            (gesamt_unabh.fd_h = FENSTER_HOEHE );
  gesamt_abh.fd_wdwidth =
        (gesamt_unabh.fd_wdwidth = FENSTER_WORD);
  gesamt_abh.fd_nplanes =
            (gesamt_unabh.fd_nplanes = 1);
  gesamt_abh.fd_stand = 0;
  gesamt_unabh.fd_stand = 1;
  bildschirm.fd_addr = NULL;
  audiopuffer[0] = (long) samplepuffer;
  audiopuffer[1] = (long) (samplepuffer +
                           (AUDIOGROESSE/8L));
  zeichne_hintergrund ();
  fensterhandle = wind_create (fensterart,
                  desktop.g_x,    desktop.g_y,
                  FENSTER_BREITE, FENSTER_HOEHE);
  if (fensterhandle < 0)
  {
    form_alert (1,
       "[3][Kein Fenster verfÅgbar][ Abbruch ]");
    free_alles ();
    unlocksnd ();
    return (TRUE);
  }
  wind_set (fensterhandle, WF_NAME, fenstername);
  wind_open (fensterhandle,
    aussen.g_x,aussen.g_y,aussen.g_w,aussen.g_h);
  for (i = 0; i < 7; i++)
    alter_zustand[i] = soundcmd (i, -1);
  sndstatus (1);  /* Reset des Audiosystems */
  soundcmd (LTATTEN, 0x00); /*AbschwÑchung und */
  soundcmd (RTATTEN, 0x00); /*Eingangsverstrk. */
  soundcmd (LTGAIN , 0xF0); /*evtl. anpassen ! */
  soundcmd (RTGAIN , 0xF0);
  soundcmd (ADDERIN, 0x01); /*nur Daten vom ADC*/
  soundcmd (ADCINPUT, 0x00); /*Mikrofoneingang */
  setbuffer (1, (long) samplepuffer,
             (long) samplepuffer + AUDIOGROESSE);
  setsndmode (1);  /* 16-Bit-Stereo */
  settrack (0, 0); /* 1 Kanal fÅr Aufnahme */
  setmontrack (0);
  devconnect (ADC, DMAREC, 0, VORTEILER, 1);
  buffoper(12); /* Aufn. im Loop-Modus starten */
  return (FALSE);
}

/* Stoppen des Audiosystems und Wiederher-    */
/* stellung des alten Zustands                */
void darstellung_aus (void)
{
  int i;

  buffoper (0);   /* Aufnahme stoppen */
  sndstatus (1);  /* Reset des Audiosystems */
  for (i = 0; i < 7; i++)
    soundcmd (i, alter_zustand[i]);
  unlocksnd ();   /* Audiosystem freigeben  */
}

/* Bringt das Fenster an die OberflÑche       */
void toppe_fenster (void)
{
  wind_set (fensterhandle, WF_TOP);
}

/* Verschiebt das Fenster auf dem Desktop     */
void verschiebe_fenster (GRECT *position)
{
  aussen.g_x = position->g_x;
  aussen.g_y = position->g_y;
  aussen.g_w = position->g_w;
  aussen.g_h = position->g_h;
  wind_set (fensterhandle, WF_CURRXYWH,
    aussen.g_x,aussen.g_y,aussen.g_w,aussen.g_h);
  wind_calc (WC_WORK, fensterart,
             aussen.g_x, aussen.g_y,
             aussen.g_w, aussen.g_h,
             &innen.g_x, &innen.g_y,
             &innen.g_w, &innen.g_h);
}

/* Schliesst das Fenster */
void schliesse_fenster (void)
{
  wind_close  (fensterhandle);
  wind_delete (fensterhandle);
  fensterhandle = -1;
}

/* Wartet darauf, daû sich der DMA-Aufnahme-  */
/* Zeiger nicht in der PufferhÑlfte befindet, */
/* auf die audiopuffer[index] zeigt.          */
void warte_dma (void)
{
  buffptrtype aktuell;
  
  if (index == 0)
  {
    do
    {
      buffptr (&aktuell);
    } while (aktuell.recbufptr<audiopuffer[1]);
  }
  else
  {
    do
    {
      buffptr (&aktuell);
    } while (aktuell.recbufptr>audiopuffer[1]);
  }
}

/* Abfrage und Verwaltung der Fensterelemente */
void verwalte_fenster (void)
{
  int     event, msgbuf[0];
  int     ereignisse;
  boolean fertig = FALSE;
  clock_t zwischenzeit, wartezeit;

  if (_app)
  {
    fertig = darstellung_an ();
    if (fertig == FALSE)
      ereignisse = MU_MESAG | MU_TIMER;
  }
  else
    ereignisse = MU_MESAG;

  zwischenzeit = clock ();
  while ((fertig == FALSE) || (!_app))
  {
    wartezeit = (1000L / BILDER_PRO_SEK) -
                5L * (clock () - zwischenzeit);
    if (wartezeit < 20L)
      wartezeit = 20L;
    event = evnt_multi (ereignisse,
                        1, 1, 1,
                        0, 0, 0, 0, 0,
                        0, 0, 0, 0, 0,
                        msgbuf,
                        (int) wartezeit, 0,
                        &mx, &my,
                        &mbutton, &mstate,
                        &keycode, &mclicks);
    zwischenzeit = clock ();
    if (event & MU_MESAG)
    {
      switch (msgbuf[0])
      {
        case AC_OPEN:
        {
          if (fensterhandle < 0)
          {
            fertig = darstellung_an ();
            if (fertig == FALSE)
              ereignisse = MU_MESAG | MU_TIMER;
          }
          else
            toppe_fenster ();
          break;
        }
        case AC_CLOSE:
        {
          if (fensterhandle >= 0)
          {
            darstellung_aus ();
            free_alles ();
            ereignisse = MU_MESAG;
            fensterhandle = -1;
          }
          break;
        }
        case WM_CLOSED:
        {
          if (msgbuf[3] == fensterhandle)
          {
            darstellung_aus ();
            schliesse_fenster ();
            ereignisse = MU_MESAG;
            fertig = TRUE;
          }
          break;
        }
        case WM_MOVED:
        {
          if (msgbuf[3] == fensterhandle)
            verschiebe_fenster ((GRECT *)
                                 &msgbuf[4]);
          break;
        }
        case WM_REDRAW:
        {
          if (msgbuf[3] == fensterhandle)
            zeichne_fenster((GRECT *)&msgbuf[4]);
          break;
        }
        case WM_TOPPED:
        {
          if (msgbuf[3] == fensterhandle)
            toppe_fenster ();
          break;
        }
      }
    }
    if ((event & MU_TIMER) && (fensterhandle>=0))
    {
      warte_dma ();
      zeichne_bild (zeilen, hintergrund.fd_addr,
                    (long *) audiopuffer[index]);
      vr_trnfm (workstation,
                &gesamt_unabh, &gesamt_abh);
      zeichne_fenster (&innen);
      index = 1 - index; 
    }
  }
  free_alles ();
}

/* Es folgt das Hauptprogramm */
int main (void)
{
  if (open_vwork () == FALSE)
  {
    printf ("Fehler bei der Initialisierung.\n");
    exit (-1);
  }
  if (!_app)
    menu_register (gl_apid, accname);
  graf_mouse (ARROW, NULL);
  wind_get (0, WF_WORKXYWH,
               &desktop.g_x,    &desktop.g_y,
               &desktop.g_w,    &desktop.g_h);
  wind_calc (WC_WORK, fensterart,
                desktop.g_x,     desktop.g_y,
                desktop.g_w,     desktop.g_h,
               &maxfenster.g_x, &maxfenster.g_y,
               &maxfenster.g_w, &maxfenster.g_h);
  wind_calc (WC_BORDER, fensterart,
                maxfenster.g_x,  maxfenster.g_y,
                FENSTER_BREITE,  FENSTER_HOEHE,
               &aussen.g_x,     &aussen.g_y,
               &aussen.g_w,     &aussen.g_h);
  wind_calc (WC_WORK, fensterart,
                aussen.g_x,      aussen.g_y,
                aussen.g_w,      aussen.g_h,
               &innen.g_x,      &innen.g_y,
               &innen.g_w,      &innen.g_h);
  verwalte_fenster ();
  close_vwork ();
  return (0);
}
