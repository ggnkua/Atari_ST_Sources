/* SOUNDS.H
 *
 * Definitionen fÅr CrazySounds
 *
 * Demonstration zum HSnd-Cookie von CrazySounds
 * kein (c), sondern zur freien Verwendung!
 *
 * Richard Kurz
 * Vogelherdbogen 62
 * 88069 Tettnang
 * Maus @ LI
 * CompuServe 100025,2263
 */

#ifndef SOUNDS_H
#define SOUNDS_H

#ifndef TRUE
	#define TRUE 1
	#define FALSE 0
#endif

#define SOUND_VERSION 0x123

/* Der Header eines geladenen Samples */
typedef struct
{
    char    name[20];
    long    laenge;
    int     frequenz;
    int     stereo;
    int     gepackt;
    int     bitsps;
    int     dma;
    int     dm_laut;
    int     dm_links;
    int     dm_rechts;
    int     dm_hoehen;
    int     dm_tiefen;
    char    *anfang;
    char    info[41];
} SINF;

/* Auf diese Struktur zeigt das COOKIE HSnd */
typedef struct
{
    int (*play_sound)(int nr);
    int ruhe;
    int version;               
    void (*play_it)(SINF *sound,int reset,int super);
    int (*load_sound)(char *n);
    int res01;
    int res02;
    int res03;
    int res04;
    int res05;
    int res06;          
    char ipath[256];    /* Pfad zu CRAZYSND.INF     */
    char spath[256];    /* Pfad zum SAMPLE-Ordner   */
    long res07;
    long res08;
    long res09;
    SINF lbuf;          /* Der Header des nachgeladenend Samples    */
} C_SOUNDS;

/* Definitionen der Events  */

#define STARTSOUND -99
#define SYSBEEP -1
#define TASTKLICK -2
#define MAUSAMRAND -5
#define LMTASTE -6
#define RMTASTE -7
#define BOMBEN -80;
#define STUNDE -8
#define VIERTEL -9
#define HARLEKINALARM -100
#define ABOX -20
#define ABOXRUF -21
#define ABOXFRAG -22
#define ABOXSTOP -23
#define FORM_DIAL_START -30
#define FORM_DIAL_FINISH -33
#define FORM_DIAL_GROW -31
#define FORM_DIAL SHRINK -32
#define FORM_DO 50
#define FORM_ERROR 53
#define FORM_BUTTON 56
#define FSEL_INPUT 90
#define FSEL_EXINPUT 91
#define GRAF_GROW_BOX 73
#define GRAF_SHRINK_BOX 74
#define GRAF_DRAGBOX 71
#define GRAF_MBOX 72
#define GRAF_RUBBOX 70
#define GRAF_SLIDEBOX 76
#define GRAF_MOUSE 78
#define MENU_BAR 30
#define MENU_TNORMAL 33
#define WINDOW_OPEN 101
#define WINDOW_CLOSE 102


#endif
