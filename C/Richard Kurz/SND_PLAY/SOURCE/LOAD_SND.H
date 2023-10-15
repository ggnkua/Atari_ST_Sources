/* LOAD_SND.H
 *
 * Definitionen & Prototypen
 *
 * Erstellt mit Pure C
 *
 * (c)Mai 1993 by Richard Kurz, Vogelherdbogen 62, 88069 Tettnang
 *
 * Fido 2:241/7232.5
 * Maus @ UN
 * Compuserve 100025,2263
 *
 * Vertrieb/Weitergabe nur durch das TOS-Magazin
 */

#define TRUE            1
#define FALSE           0

/* Header des HSN-Formats Version 1.1 */
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
} HSN_NEW;

/* Header des HSN-Formats Version 1.0 */
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
} HSN_ALT;

/* In dieser Struktur werden die Daten der Samples abgelegt */
typedef struct
{
    char    name[20];
    long    laenge;
    int     frequenz;
    int     stereo;
    int     bitsps;
    char    *anfang;
} SOUNDINFO;


void change_vorz(SOUNDINFO *si);
void get_pfad(char *p);
int fselect(char *pfad,char *fname, char *ext, char *text);
int load_sound(SOUNDINFO *sin, char *path);

