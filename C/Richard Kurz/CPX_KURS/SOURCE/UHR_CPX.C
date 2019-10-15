/*  UHR_CPX.C
 *
 *  aus: Wir basteln uns ein CPX
 *       CPX-Kurs Teil 3
 *       TOS Magazin
 *
 *  (c)1992 by Richard Kurz
 *  Vogelherdbogen 62
 *  7992 Tettnang
 *  Fido 2:241/7232.5
 *
 *  Erstellt mit Pure C
 */
 
#include <aes.h>
#include <tos.h>
#include <ext.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>
#include <stddef.h>
#include <portab.h>
#include "cpx.h"
#include "uhr_cpx.h"
#pragma warn -rpt 
#include "uhr_cpx.rsh"
#pragma warn +rpt 

#define TRUE    1
#define FALSE   0

#define ZEIT    1000L

/* Eine handvoll Prototypen */
CPXINFO * cdecl cpx_init(XCPB *Xcpb);
WORD cdecl cpx_call(GRECT *re); 
void cdecl cpx_draw(GRECT *clip);
void cdecl cpx_wmove(GRECT *work);
void cdecl cpx_timer(WORD *quit);
void cdecl cpx_key(WORD kstate, WORD key, WORD *quit);
void cdecl cpx_button(MRETS *mrets, WORD nclicks,WORD *quit);
void cdecl cpx_m1(MRETS *mrets, WORD *quit);
void cdecl cpx_m2(MRETS *mrets, WORD *quit);
WORD cdecl cpx_hook(WORD event, WORD *msg,MRETS *mrets, WORD *key, WORD *nclicks);
void cdecl cpx_close(WORD flag);

int do_cpx_alert(OBJECT *o,int e);
void draw_time(void);
void draw_ziffer(OBJECT *d,int z1,int i);
int  do_menu(int obj);

/* Globale Variablen */
GRECT   *w_rect;        /* Die Koordinaten des Fensters.        */
XCPB    *xcpb;          /* Zeiger auf die XControl-Funktionen.  */
CPXINFO cpxinfo;        /* Zeiger auf unsere Funktionen fÅr     */
                        /* XControl.                            */
MFORM   mzeiger;        /* Parkplatz fÅr den Mauszeiger.        */
MFORM   maus1=          /* Neuer Mauszeiger.                    */
        {8,8,1,0,1,
        { 0x3FF8, 0x3FF8, 0x3FF8, 0xFFFE, 
          0x7FFC, 0xFFFE, 0xFFFE, 0xFFFE, 
          0xFFFE, 0xFFFE, 0xFFFE, 0xFFFE, 
          0x7FFC, 0x7FFC, 0x3FF8, 0x0FE0
        },
        { 0x3FF8, 0x3FF8, 0x2AA8, 0xFFFE, 
          0x4004, 0xC006, 0x9D72, 0x8922, 
          0x8102, 0x8102, 0x8822, 0xC446, 
          0x4384, 0x600C, 0x3838, 0x0FE0
        }};

MFORM   maus2=          /* Neuer Mauszeiger.                    */
        {8,8,1,0,1,
        { 0x3FF8, 0x3FF8, 0x3FF8, 0xFFFE, 
          0x7FFC, 0xFFFE, 0xFFFE, 0xFFFE, 
          0xFFFE, 0xFFFE, 0xFFFE, 0xFFFE, 
          0x7FFC, 0x7FFC, 0x3FF8, 0x0FE0
        },
        { 0x3FF8, 0x3FF8, 0x2AA8, 0xFFFE, 
          0x4004, 0xC006, 0x9D72, 0x8102, 
          0x8102, 0x8102, 0x8822, 0xC446, 
          0x4384, 0x600C, 0x3838, 0x0FE0
        }};
MFORM   maus3=          /* Neuer Mauszeiger.                    */
        {8,8,1,0,1,
        { 0x3FF8, 0x3FF8, 0x3FF8, 0xFFFE, 
          0x7FFC, 0xFFFE, 0xFFFE, 0xFFFE, 
          0xFFFE, 0xFFFE, 0xFFFE, 0xFFFE, 
          0x7FFC, 0x7FFC, 0x3FF8, 0x0FE0
        },
        { 0x3FF8, 0x3FF8, 0x2AA8, 0xFFFE, 
          0x4004, 0xC826, 0x9D72, 0x8922, 
          0x8102, 0x8102, 0x8002, 0xC7C6, 
          0x4444, 0x638C, 0x3838, 0x0FE0
        }};
    
OBJECT  *dialog;        /* Zeiger auf unsere Dialoge            */
OBJECT  *info;
OBJECT  *countdown;

MOBLK   m1;             /* Puffer fÅr die Mausparameter.        */ 
int XCW_handle=-1;      /* Das Handle vom XControl-Fenster.     */
int alt_datum;          /* Ablage fÅr's Datum.                  */
int aus_count;          /* ZÑhler fÅr die Auto-Abschaltung.     */
int auto_aus;           /* Flag fÅr die Auto-Abschaltung.       */
int m_flag;             /* Flag fÅr die Maus-Umschaltung.       */
int draw_flag;          /* Zeichnen oder nicht Zeichen....      */
char *w_name;           /* Zeiger auf den neuen Fensternamen.   */

/* Externe Variable aus dem Assemblerteil.                      */
extern int cdown;       /* Vorgabe fÅr die Auto-Abschaltung.    */

CPXINFO * cdecl cpx_init(XCPB *Xcpb)
/* Diese Funktion wird wÑrend der XControl-Initialisierung und  */
/* bei jeder Aktivierung unseres CPX-Moduls als erstes          */
/* gestartet. Sie erhÑlt einen Zeiger auf die CPX-Funktionen    */
/* und muû einen Zeiger auf die eigenen Funktionen oder NULL    */
/* bzw. 1 zurÅckgeben.                                          */
{
    xcpb=Xcpb;

    if(xcpb->booting)
    /* Dieses Flag zeigt an, ob es der erste Aufruf (wÑrend der */
    /* XControl-Initialisierung) ist.                           */
    {
        /* WÑrend der Initialisierung muû eine 1 zurÅckgegeben  */
        /* werden, wenn das CPX-Modul nicht set_only sein soll. */
        return ((CPXINFO *)TRUE);
    }

    if(!xcpb->SkipRshFix)
    /* In diesem Flag wird festgehalten, ob der OBJECT-Baum     */
    /* schon angepaût wurde.                                    */
    {
        /* Wir passen den OBJECT-Baum an.                       */
        (*xcpb->rsh_fix)(NUM_OBS,NUM_FRSTR,NUM_FRIMG,NUM_TREE,
                         rs_object,rs_tedinfo,rs_strings,rs_iconblk,
                         rs_bitblk,rs_frstr,rs_frimg,rs_trindex,
                         rs_imdope);
    }
    dialog=(OBJECT *)rs_trindex[DIALOG];
    info=(OBJECT *)rs_trindex[PINFO];
    countdown=(OBJECT *)rs_trindex[COUNTDOW];

    /* Sicherheitshalber legen wir den neuen Fensternamen im    */
    /* garantiert residenten Teil des Speichers ab.             */
    w_name=(char *)(*xcpb->Get_Buffer)();
    strcpy(w_name," TOS Magazin ");
    
    /* In die CPXINFO-Struktur mÅssen unsere Funktionen ein-    */
    /* getragen werden.                                         */
    cpxinfo.cpx_call  =cpx_call;

    cpxinfo.cpx_draw  =cpx_draw;
    cpxinfo.cpx_wmove =cpx_wmove;
       
    cpxinfo.cpx_timer =cpx_timer;
       
    cpxinfo.cpx_key   =cpx_key;
    cpxinfo.cpx_button=cpx_button;
       
    cpxinfo.cpx_m1    =cpx_m1;
    cpxinfo.cpx_m2    =cpx_m2;
    cpxinfo.cpx_hook  =cpx_hook;
              
    cpxinfo.cpx_close =cpx_close;

    /* Mit der RÅckgabe unserer Funktionen melden wir uns beim  */
    /* XControl an.                                             */
    return(&cpxinfo);

} /* cpx_init */

/* Da wir nicht immer alle Åbergebenen Parameter auch           */
/* tatsÑchlich verwenden, wird die entsprechende Warnmeldung    */
/* Auf Eis gelegt (Schlotter).                                  */
#pragma warn -par 

WORD cdecl cpx_call(GRECT *rect)
/* Hier steht der Hauptteil, er wird von XControl bei der       */
/* Aktivierung unseres Moduls nach cpx_init aufgerufen.         */
/* In *rect stehen die Koordinaten des XControl-Fensters.       */
/* Bei einem Event-CPX (wie in unserem Fall), muû immer TRUE    */
/* (1) zurÅckgegeben werden.                                    */
{
    /* Unser Dialog muû angepaût werden.                        */
    w_rect=rect;        /* Die Koordinaten mÅssen global        */
                        /* gesichert werden!                    */
    dialog[ROOT].ob_x=w_rect->g_x;
    dialog[ROOT].ob_y=w_rect->g_y;
    
    /* Initialisieren.                                          */

    /* Hier wird der Objektbaum auf die aktuelle Uhrzeit        */
    /* gebracht, allerdings ohne ihn zu zeichen.                */
    draw_flag=TRUE;
    draw_time();
    draw_flag=FALSE;

    /* Die Variablen erhalten bei jedem Aufruf einen            */
    /* definierten Inhalt. WICHTIG wenn das Modul resident ist. */
	auto_aus=FALSE;
    aus_count=cdown*10;
    alt_datum=0;
    XCW_handle=-1;
    m_flag=FALSE;

    /* Der Bereich in dem sich der Mauszeiger verÑndert wird    */
    /* berechnet.                                               */
    objc_offset(dialog,SENSITIV,&m1.m_x,&m1.m_y);
    m1.m_w=dialog[SENSITIV].ob_width;
    m1.m_h=dialog[SENSITIV].ob_height;
    m1.m_out=FALSE;

    /* XControl muû wissen, welche Events wir brauchen.         */
    (*xcpb->Set_Evnt_Mask)(MU_MESAG,NULL,NULL,-1L);

    /* Um das Handle des XControll-Fensters zu erhalten, muû    */
    /* eine REDRAW Messag erzeugt werden.                       */
    form_dial(FMD_FINISH,0,0,0,0,w_rect->g_x,w_rect->g_y,
                w_rect->g_w,w_rect->g_h);
    
    /* Mit der RÅckgabe von TRUE (1) zeigen wir XControll an,   */
    /* daû es sich um ein Event-Modul handelt.                  */
    return(TRUE);
} /* cpx_call */

void cdecl cpx_draw(GRECT *clip)
/* Diese Funktion wird von XControl aufgerufen, wenn der Inhalt */
/* des Fensters neu gezeichnet werden muû (REDRAW).             */
/* Der Parameter clip ist ein Zeiger auf eine GRECT-Struktur,   */
/* nn welcher der zu zeichnende Bereich enthalten ist.          */
{
   GRECT *xrect,rect; /* Puffer fÅr die Rechteckliste.          */
   
   xrect=(*xcpb->GetFirstRect)(clip); /* Das erste Rechteck.    */
   while(xrect) /* Solange noch Rechtecke da sind.              */
   {
        rect=*xrect; /* *xrect muû in einer eigenen Variablen   */
                     /* gesichert werden!!!                     */
        /* Der Dialog wird gezeichnet.                          */
        objc_draw(dialog,ROOT,MAX_DEPTH,rect.g_x,rect.g_y,
                    rect.g_w,rect.g_h);
        xrect=(*xcpb->GetNextRect)(); /* Das nÑchste Rechteck.  */
   };   
} /* cpx_draw */

void cdecl cpx_wmove(GRECT *work)
/* Diese Funktion wird von XControl aufgerufen, wenn das        */
/* Fenster vom User bewegt wurde. Die Koordinaten der Objekt-   */
/* BÑume usw. mÅssen auf den neuesten Stand gebracht werden.    */
/* Im Parameter work sind die neuen Koordinaten enthalten.      */
{
    dialog[ROOT].ob_x=work->g_x; /* Der Objektbaum wird         */
    dialog[ROOT].ob_y=work->g_y; /* angepaût.                   */

    /* Der Bereich in dem sich der Mauszeiger verÑndert wird    */
    /* berechnet.                                               */
    objc_offset(dialog,SENSITIV,&m1.m_x,&m1.m_y);
    m1.m_w=dialog[SENSITIV].ob_width;
    m1.m_h=dialog[SENSITIV].ob_height;
    m1.m_out=FALSE;
    /* Die geÑnderten Werte mÅssen XControl mitgeteilt werden.  */
    (*xcpb->Set_Evnt_Mask)(MU_M1|MU_TIMER|MU_MESAG|MU_BUTTON|MU_KEYBD,
                        &m1,NULL,ZEIT);
}/* cpx_wmove */

void cdecl cpx_timer(int *quit)
/* Diese Funktion wird von XControl aufgerufen, wenn ein        */
/* timer event aufgetreten ist.                                 */
/* öber den Parameter quit kann XControl mitgeteilt werden, ob  */
/* das Modul beendet werden soll. Zum Beenden muû *quit auf     */
/* TRUE gesetzt werden, annsonsten einfach ignorieren.          */                      
{
    int xid;            /* FÅr die AES-ID vom XControl.         */
    static int msg[16]; /* Nachrichtenpuffer.                   */
    
    draw_time();        /* Tick, Tack.                          */

    if(m_flag)          /* Wenn der Mauszeiger verÑndert ist,   */
    {                   /* kann man auch noch ein wenig spielen.*/
        if(++m_flag ==2)
        {
            if(auto_aus)graf_mouse(USER_DEF,&maus3);
            else graf_mouse(USER_DEF,&maus2);
        }           
        else
        {
            graf_mouse(USER_DEF,&maus1);
            m_flag=1;
        }
    }

    if(auto_aus)    /* Der Countdown wird abgezÑhlt.            */
    {
        if(--aus_count < 0) /* Es ist soweit! -> BUUUUMMMM      */
        {
            xid=appl_find("XCONTROL"); /* Die ID muû gefunden   */
            if(xid<0)                  /* werden.               */
            {
                cpx_close(WM_CLOSED);  /* Ansonsten kommt die   */
                *quit=TRUE;            /* Notlîsung.            */  
            }
            else /* Jetzt geht's los! XControl wird vorgespielt,*/
            {    /* daû der User den CLOSE Button angewÑhlt hat.*/
                msg[0]=WM_CLOSED;
                msg[1]=0;
                msg[2]=0;
                msg[3]=XCW_handle;
                appl_write(xid,32,msg);
            }
        }
    }
}/* cpx_timer */

void cdecl cpx_key(int kstate,int key,int *quit)
/* Diese Funktion wird von XControl aufgerufen, wenn ein        */
/* keyboard event aufgetreten ist.                              */
/* In kstate sind Control, Alternate und die Shifttasten        */
/* enthalten. Der Scan- und ASCII-Code versteckt sich in key.   */
/* öber den Parameter quit kann XControl mitgeteilt werden, ob  */
/* das Modul beendet werden soll. Zum Beenden muû *quit auf     */
/* TRUE gesetzt werden, annsonsten einfach ignorieren.          */                      
{
    switch(key)
    {
        case 0x6200:    /* Help */
            do_cpx_alert(info,0);
            break;
        case 0x6100:    /* Undo */
            cpx_close(WM_CLOSED);
            *quit=TRUE;
            break;
        default:
            break;
    }
} /* cpx_key */

void cdecl cpx_button(MRETS *mrets,int nclicks,int *quit)
/* Diese Funktion wird von XControl aufgerufen, wenn eine       */
/* Maustaste gedrÅckt wurde.                                    */
/* mrets ist ein Zeiger auf eine MRETS-Struktur, in der die     */
/* Informationen Åber den aktuellen Zustand der Maus enthalten  */
/* sind. In nclicks, steht die Anzahl der Mausclicks.           */
/* öber den Parameter quit kann XControl mitgeteilt werden, ob  */
/* das Modul beendet werden soll. Zum Beenden muû *quit auf     */
/* TRUE gesetzt werden, annsonsten einfach ignorieren.          */                      
{
    int    obj;

    /* Das angewÑhlte Objekt muû gefunden werden.               */
    obj=objc_find(dialog,ROOT,MAX_DEPTH,mrets->x,mrets->y);
    switch(obj)
    {
        case MINFO:
        case MDATEI:
        case MCDOWN:
            if(!do_menu(obj)) *quit=TRUE;
            break;
       default:
            break;       
    }
} /* cpx_button */

void cdecl cpx_m1(MRETS *mrets,int *quit)
/* Diese Funktion wird von XControl aufgerufen, wenn der        */
/* mouse event m1 aufgetreten ist.                              */
/* mrets ist ein Zeiger auf eine MRETS-Struktur, in der die     */
/* Informationen Åber den aktuellen Zustand der Maus enthalten  */
/* sind.                                                        */
/* öber den Parameter quit kann XControl mitgeteilt werden, ob  */
/* das Modul beendet werden soll. Zum Beenden muû *quit auf     */
/* TRUE gesetzt werden, annsonsten einfach ignorieren.          */                      
{
    int wtop;
    
    /* Wir suchen das oberste Fenster.                          */
    wind_get(XCW_handle,WF_TOP,&wtop);

    if(wtop!=XCW_handle)
    /* Wenn es nicht unseres ist, halten wir uns in Zukunft     */
    /* zurÅck.                                                  */
    {
        if(m_flag) (*xcpb->MFsave)(MFRESTORE, &mzeiger);
        m_flag=m1.m_out=FALSE;
        (*xcpb->Set_Evnt_Mask)(MU_TIMER|MU_MESAG,NULL,NULL,ZEIT);
    }
    else
    /* Ist unser Fenster oben, verÑndern wir den Mauszeiger.    */
    {
        if(m_flag)
        {
            (*xcpb->MFsave)(MFRESTORE, &mzeiger);
            m_flag=m1.m_out=FALSE;
        }
        else
        {    
            (*xcpb->MFsave)(MFSAVE, &mzeiger);
            graf_mouse(USER_DEF,&maus1);
            m_flag=m1.m_out=TRUE;
        }

        /* XControl muû ncoh informiert werden.                 */
        (*xcpb->Set_Evnt_Mask)(MU_M1|MU_TIMER|MU_MESAG|MU_BUTTON|MU_KEYBD,
                               &m1,NULL,ZEIT);
    }
} /* cpx_m1 */

void cdecl cpx_m2(MRETS *mrets,int *quit)
/* Diese Funktion wird von XControl aufgerufen, wenn der        */
/* mouse event m2 aufgetreten ist.                              */
/* mrets ist ein Zeiger auf eine MRETS-Struktur, in der die     */
/* Informationen Åber den aktuellen Zustand der Maus enthalten  */
/* sind.                                                        */
/* öber den Parameter quit kann XControl mitgeteilt werden, ob  */
/* das Modul beendet werden soll. Zum Beenden muû *quit auf     */
/* TRUE gesetzt werden, annsonsten einfach ignorieren.          */                      
{
} /* cpx_m2 */

WORD cdecl cpx_hook(int event, int *msg,MRETS *mrets,int *key,int *nclicks)
/* Diese Funktion wird von XControl bei jedem Event aufgerufen, */
/* noch vor!! der Bearbeitung der Events.                       */
/* In event ist der aufgetretene Event enthalten. In msg steht  */
/* ein Zeiger auf den Beginn des Nachrichtenbuffers.            */
/* mrets ist ein Zeiger auf eine MRETS-Struktur, in der die     */
/* Informationen Åber den aktuellen Zustand der Maus enthalten  */
/* sind. Der Scan- und ASCII-Code einer eventuell gedrÅckten    */
/* Taste versteckt sich in key. In nclicks, steht die Anzahl    */
/* der Mausclicks.                                              */
/* Im Normalfall sollte FALSE zurÅckgegeben werden, damit       */
/* XControl den Event weiterverarbeitet. Wird TRUE              */
/* zurÅckgegeben stopt XControl die Bearbeitung des Events.     */
{
    if(event==MU_MESAG)
    { 
        switch(msg[0])
        {
            case WM_REDRAW: /* Beim ersten mal holen wir uns    */
                            /* das Fensterhandle und spielen    */
                            /* ein wenig mit dem Fenstername.   */
                if(XCW_handle==-1);
                {
                    XCW_handle=msg[3];
                    (*xcpb->Set_Evnt_Mask)(MU_M1|MU_TIMER|MU_MESAG|MU_BUTTON|MU_KEYBD,&m1,NULL,ZEIT);
                    wind_set(XCW_handle,WF_NAME,w_name,w_name);
                }
                break;
            case WM_TOPPED: /* Wir sind wieder oben!            */
                (*xcpb->Set_Evnt_Mask)(MU_M1|MU_TIMER|MU_MESAG|MU_BUTTON|MU_KEYBD,&m1,NULL,ZEIT);
                break;
            default:
                break;
        }
    }
    return(FALSE);
}/* cpx_hook */

void cdecl cpx_close(int flag)
/* Das Ende vom Lied! Diese Funktion wird von XControl          */
/* aufgerufen wenn eine ACC_CLOSE oder WM_CLOSED Nachricht      */
/* eingeht. In diesem Fall muû eventuell verwendeter Speicher   */
/* sofort freigegeben werden.                                   */
/* Wenn flag == TRUE ist es eine WM_CLOSED Nachricht.           */
/* Diese Nachricht sollte (wenn Mîglich) als "OKAY" gewertet    */
/* werden.                                                      */
/* Wenn flag == FALSE ist es eine ACC_CLOSE Nachricht.          */
/* Diese Nachricht sollte (wenn Mîglich) als "Abbruch" gewertet */
/* werden.                                                      */
{
    /* Wenn wir den Mauszeiger verunstaltet haben, sollte       */
    /* dieser auch wieder restauriert werden.                   */
    if(m_flag) (*xcpb->MFsave)(MFRESTORE, &mzeiger);
} /* cpx_close */

/* Wir tauen das PlaudertÑschchen wieder auf.                   */
#pragma warn +par 

/* Die folgenden Funktionen haben nichts direkt mit einem       */
/* Event-CPX zu tun, sie fÅlllen unsere Demonstrationsobjekt    */
/* ein wenig mit Leben.                                         */

int do_cpx_alert(OBJECT *o,int e)
/* ALARM! ALARM!                                                */
/* Diese Funktion zeichnet und verwaltet eine Dialogbox im      */
/* XControl-Fenster                                             */
{
    int i,ox,oy,
        x,y,w,h;
    static MFORM mf;
    
    wind_update(BEG_MCTRL);
    wind_update(BEG_UPDATE);
    (*xcpb->MFsave)(MFSAVE, &mf);
    graf_mouse(ARROW,NULL);

    form_center(o,&x,&y,&w,&h); 
    ox=o[ROOT].ob_x-x;
    oy=o[ROOT].ob_y-y;
    x=w_rect->g_x+((w_rect->g_w-w)/2);
    y=w_rect->g_y+((w_rect->g_h-h)/2);
    o[ROOT].ob_x=x+ox;
    o[ROOT].ob_y=y+oy;

    form_dial(FMD_START,0,0,0,0,x,y,w,h);
    form_dial(FMD_GROW,0,0,0,0,x,y,w,h);
    objc_draw(o,ROOT,MAX_DEPTH,x,y,w,h);
    i=form_do(o,e) & 0x7fff;
    o[i].ob_state &= ~SELECTED;
    form_dial(FMD_SHRINK,0,0,0,0,x,y,w,h);
    form_dial(FMD_FINISH,0,0,0,0,x,y,w,h);

    (*xcpb->MFsave)(MFRESTORE, &mf);
    wind_update(END_UPDATE);
    wind_update(END_MCTRL);

    return(i);
} /* do_cpx_alert */

void draw_obj(OBJECT *d, int i)
/* Ein Objekt wird unter berÅcksichtigung der aktuellen Recht-  */
/* eckliste gezeichnet.                                         */
{
   GRECT *xrect;
   GRECT rect;
   GRECT clip;
   
   if(draw_flag) return;
   objc_offset(d,i,&clip.g_x,&clip.g_y);
   clip.g_w=d[i].ob_width;
   clip.g_h=d[i].ob_height;
   
   xrect=(*xcpb->GetFirstRect)(&clip);
   while(xrect)
   {
        rect=*xrect;
        objc_draw(dialog,i,MAX_DEPTH,rect.g_x,rect.g_y,rect.g_w,rect.g_h);
        xrect=(*xcpb->GetNextRect)();
   };   
} /* draw_obj */
 
void draw_ziffer(OBJECT *d,int z1,int i)
/* Hier wird die 7 Segment Anzeige simmuliert!                  */
{
    int j;
    static char ziff[10][8]=
    {"1110111","0010010","1011101","1011011","0111010",
     "1101011","1101111","1010010","1111111","1111011"};
    
    for(j=0;j<7;j++)
    {
        if(d[z1+j].ob_state & SELECTED)
        {
            if(ziff[i][j]=='1')
            {
                d[z1+j].ob_state &= ~SELECTED;
                draw_obj(d,z1+j);
            }
        }
        else
        {
            if(ziff[i][j]=='0')
            {
                d[z1+j].ob_state |= SELECTED;
                draw_obj(d,z1+j);
            }
        }
    }
}/* draw_ziffer */

void draw_time(void)
/* Die aktuelle Zeit wird dargestellt.                          */
{
    int t,s,m,h,j;
    struct tm *da;
    static char Tag[7][14]=
        {"Sonntag","Montag","Dienstag","Mittwoch","Donnerstag",
         "Freitag","Samstag"};
    static char Monat[12][14]=
        {"Januar","Februar","MÑrz","April","Mai","Juni",
         "Juli","August","September","Oktober","November","Dezember"};
    static char Datum[80];
    static struct ftime ft;
    
    t=Tgettime();
    s=(t & 31)*2;
    m=(t>>5) & 63;
    h=(t>>11) & 31;
    t=Tgetdate();
    if(auto_aus)
    {
        sprintf(Datum,"Countdown: %2i",aus_count);
        dialog[DATUM].ob_spec.tedinfo->te_ptext=Datum;
        draw_obj(dialog,DATUM);
    }   
    else if(t!=alt_datum)
    {
        alt_datum=t;
        
        ft.ft_tsec  =s;
        ft.ft_min   =m;
        ft.ft_hour  =h;
        ft.ft_year  =(t>>9) & 63;
        ft.ft_month=(t>>5) & 15;
        ft.ft_day   =t & 31;
        j=ft.ft_year+1980;
        da=ftimtotm(&ft);
        sprintf(Datum,"%s, %2i. %s %4i",Tag[da->tm_wday],da->tm_mday,Monat[da->tm_mon],j);
        dialog[DATUM].ob_spec.tedinfo->te_ptext=Datum;
        draw_obj(dialog,DATUM);
    }
    draw_ziffer(dialog,Z1,h/10);
    draw_ziffer(dialog,Z2,h%10);
    draw_ziffer(dialog,Z3,m/10);
    draw_ziffer(dialog,Z4,m%10);
    if(dialog[P1].ob_state & SELECTED)
    {
        dialog[P1].ob_state &= ~SELECTED;
        dialog[P2].ob_state &= ~SELECTED;
    }
    else
    {
        dialog[P1].ob_state |= SELECTED;
        dialog[P2].ob_state |= SELECTED;
    }
    dialog[P1].ob_spec.obspec.character=s/10+16;
    dialog[P2].ob_spec.obspec.character=s%10+16;
    draw_obj(dialog,P1);
    draw_obj(dialog,P2);
}/* draw_time */

int do_menu(int obj) 
/* Hier wird unsere gefÑlschte (Kujau ?) Menuezeile verwaltet.  */
{
    GRECT r1;           /* Koordinaten-Feld.                    */
    WORD i,p;           /* Hilfsvariable.                       */
    char *items[4];     /* Zeiger-Feld fÅr die PopUp-MenÅs.     */

    dialog[obj].ob_state |= SELECTED;
    draw_obj(dialog,obj);
    
    switch(obj)
    {
        case MINFO:
            items[0]="  Info... ";
            
            objc_offset(dialog,DINFO,&r1.g_x,&r1.g_y);
            r1.g_w=dialog[DINFO].ob_width;
            r1.g_h=dialog[DINFO].ob_height;
            
            p=(*xcpb->Popup)(items,1,-1,3,&r1,w_rect);
            
            if(p==0)
                do_cpx_alert(info,0);
            break;

        case MDATEI:
            items[0]="  Sichern... ";
            items[1]="  Ende       ";
            objc_offset(dialog,DDATEI,&r1.g_x,&r1.g_y);
            r1.g_w=dialog[DDATEI].ob_width;
            r1.g_h=dialog[DDATEI].ob_height;
            
            p=(*xcpb->Popup)(items,2,-1,3,&r1,w_rect);
            
            if(p==0)
            {
                if((*xcpb->XGen_Alert)(0))
                {
                    if(!(*xcpb->CPX_Save)(&cdown,2))
                        (*xcpb->XGen_Alert)(FILE_ERR);
                }
            }
            else if(p==1)
            {
                dialog[obj].ob_state &= ~SELECTED;
                return(FALSE);
            }
            break;

        case MCDOWN:
            items[0]=    "  Vorgabe...  ";
            if(auto_aus)
                items[1]="  LÑuft       ";
            else
                items[1]="  Starten     ";
            objc_offset(dialog,DCDOWN,&r1.g_x,&r1.g_y);
            r1.g_w=dialog[DCDOWN].ob_width;
            r1.g_h=dialog[DCDOWN].ob_height;
            
            p=(*xcpb->Popup)(items,2,auto_aus ? 1:-1,3,&r1,w_rect);
            if(p==0)
            {
                for(i=SEK10;i<=SEK30;i++)
                    countdown[i].ob_flags &= ~DEFAULT;
                countdown[SEK10+cdown-1].ob_flags |= DEFAULT;
                cdown=do_cpx_alert(countdown,0)-SEK10+1;
                aus_count=cdown*10;
            }
            else if(p==1)
            {
                auto_aus=auto_aus ? FALSE:TRUE;
                aus_count=cdown*10;
                alt_datum=0;
            }
            break;
        default:
            break;
    }
    dialog[obj].ob_state &= ~SELECTED;
    draw_obj(dialog,obj);
    return(TRUE);
} /* do_menu */
