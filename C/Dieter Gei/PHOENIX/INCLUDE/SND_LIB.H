/* SND_LIB.H
 *
 * (c)1995 by Richard Kurz, Vogelherdbogen 62, 88069 Tettnang
 *
 * Maus @ LI
 * Compuserve 100025,2263
 *
 * ASH ONLY!!!!
 */

/* Fehlermeldungen */
#define E_WRONGHARD -4  /* Falsche Hardware          */
#define E_TOFAST  -5  /* Zu hohe Samplefrequenz      */
#define E_LOCKED  -6  /* Soundsystem ist gesperrt      */

/* Maschinen */
#define M_NO_SOUND  0
#define M_ST    1
#define M_STE_TT  2
#define M_FALCON  3

/* In dieser Struktur werden die Daten der Samples Åbergeben */
typedef struct
{
    char    name[20];
    long    laenge;
    int     frequenz;
    int     stereo;
    int     res1;
    int     bitsps;
    int     res2;
    int     dm_laut;
    int     dm_links;
    int     dm_rechts;
    int     dm_hoehen;
    int     dm_tiefen;
    long    res3;
    char    info[41];
    char  *anfang;
} SOUNDINFO;

/* Initialisiert die SOUND-Lib und gibt den Typ der Sound-Hardware  */
/* zurÅck -> M_NO_SOUND,M_ST, M_STE_TT, M_FALCON          */
int SND_init(void);

/* Beendet einen Sound                        */
void SND_stop(void);

/* Setz Volume usw...                       */
void SND_set_vol(SOUNDINFO *si);

/* Spielt einen Sound ab. RÅckagebwert = 0, wenn alles geklappt   */
/* hat, sonst eine negative Nummer                  */
int SND_play(SOUNDINFO *si);
