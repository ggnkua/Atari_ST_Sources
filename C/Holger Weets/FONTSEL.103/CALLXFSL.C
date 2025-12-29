/*
    Datei:      CALLXFSL.C

    Funktion:   Beispiel-Aufruf des xFSL-Font-Selektors

    Compiler:   Pure C Version 1.1

    Bemerkung:  wegen Benutzung von "cdecl" muž die Option
                "ANSI keywords only" abgeschaltet werden

    Autor:      Christoph Zwersche

    Datum:      29.4.1995
*/

#include <stdio.h>
#include <aes.h>
#include <tos.h>

#define NULL ((void *)0)

/* Rckgabewerte bei xFSL */

#define xFS_LOADERROR    -8  /* Fehler beim Overlay-Laden   */
#define xFS_RES_ERROR    -7  /* Aufl”sung ist zu niedrig    */
#define xFS_NO_HANDLE    -6  /* Kein Handle mehr frei       */
#define xFS_NO_WINDOW    -5  /* Kein Fenster mehr frei      */
#define xFS_NO_FONTS     -4  /* keine Fonts geladen         */
#define xFS_NO_FONTSIZE  -3  /* Gr”že nicht identifizierbar */
#define xFS_ACTIVE       -2  /* Font-Selektor bereits aktiv */
#define xFS_ERROR        -1  /* Speichermangel o.„. Problem */
#define xFS_STOP          0  /* Auswahl ungltig, Abbruch   */
#define xFS_OK            1  /* Auswahl gltig, Ok          */
#define xFS_HELP          2  /* Hilfe-Knopf wurde angew„hlt */
#define xFS_EVENT         3  /* AES-Event ist aufgetreten   */
#define xFS_POPUP         4  /* User-Popup wurde angew„hlt  */

/* Fontflags */

#define FF_SYSTEM       0x01  /* Systemfont (zus„tzlich) zeigen */
#define FF_MONOSPACED   0x02  /* monospaced Fonts anzeigen      */
#define FF_PROPORTIONAL 0x04  /* prop. Fonts anzeigen           */
#define FF_VEKTOR       0x08  /* Vektorfonts anzeigen           */
#define FF_BITMAP       0x10  /* alle Bitmapfonts anzeigen      */
#define FF_ALL          0x1e  /* alle Fonts anzeigen            */
#define FF_CHANGED    0x8000  /* Žnderung erfolgt (im Popup)    */

/* vereinfachter Aufruf */

typedef int cdecl (*xFSL_INPUT)
(
    int vdihandle,          /* Handle der virtuellen Workstation    */
    unsigned int fontflags, /* Flags fr das Font-Angebot           */
    const char *headline,   /* šberschrift oder 0L (Default-Text)   */
    int *id,                /* Rckgabe: ID des gew„hlten Fonts     */
    int *size               /* Rckgabe: Gr”že des gew„hlten Fonts  */
);

/* Der xFSL-Cookie zeigt auf die folgende Struktur */

typedef struct
{
    unsigned long xfsl;     /* Magic 'xFSL'         */
    unsigned int revision;  /* xFSL-Revisionsnummer */
    unsigned long product;  /* Fontselektor-Kennung */
    unsigned int version;   /* Fontselektor-Version */
    xFSL_INPUT xfsl_input;  /* einfacher Aufruf     */
}   xFSL;

/* Standard-Funktion zur Cookie-Abfrage */

int get_cookie(long cookie,long *value)
{
    long oldstack,*cookiejar;

    oldstack=Super(NULL);
    cookiejar=*(long **)0x5a0;
    Super((void *)oldstack);
    if (cookiejar==NULL) return 0;
    do
    {
        if (cookiejar[0]==cookie)
        {
            if (value) *value=cookiejar[1];
            return 1;
        }
        else
            cookiejar+=2;
    }   while (cookiejar[-2]);
    return 0;
}

/* Beispiel-Aufruf des universellen Font-Selektors */

int main(void)
{
    xFSL *xfsl;

	appl_init();
    if (get_cookie('xFSL',(long *)&xfsl))
    {
        int id=1,size=10,ok;
        do
        {
            char s[80],t[80]; ok=0;
            switch (xfsl->xfsl_input(0,FF_ALL,
                "Ein kleiner Test:",&id,&size))
            {
                case xFS_OK:
                    sprintf(t,"Sie haben den|Font Nummer %d|"
                        "Gr”že %d Punkt|ausgew„hlt!",id,size);
                    ok=1;
                    break;
                case xFS_STOP:
                    sprintf(t,"Sie haben|Abbruch gew„hlt!");
                    break;
                default:
                    sprintf(t,"Es ist ein|Fehler aufgetreten!");
            }
            sprintf(s,"[1][%s][ OK ]",t); form_alert(1,s);
        }   while (ok);
    }
    else
    	form_alert(1,"[1][Kein xFSL|installiert!][Abbruch]");
    appl_exit();
    return 0;
}
