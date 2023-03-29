/* LOAD_SND.H
 *
 * Definitionen & Prototypen
 *
 * (c)1995 by Richard Kurz, Vogelherdbogen 62, 88069 Tettnang
 *
 * Maus @ LI
 * Compuserve 100025,2263
 *
 */

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

#if 0
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
    char 	*anfang;
} SOUNDINFO;
#endif

void change_vorz(SOUNDINFO *si);
void get_pfad(char *p);
int fselect(char *pfad,char *fname, char *ext, char *text);
int load_sound(SOUNDINFO *sin, char *path);
void change_freq(SOUNDINFO *si, long new_freq, int nstereo, int nbitsps);

