/*  SOUNDS.H
 *
 *  aus: GEM Sound
 *       TOS Magazin
 *
 *  (c)1992 by Richard Kurz
 *  Vogelherdbogen 62
 *  7992 Tettnang
 *  Fido 2:241/7232
 *
 *  Erstellt mit Pure C
 */

#define TRUE 1
#define FALSE 0

#define MAX_SAMP 20

typedef struct
{
    char name[15];
    long laenge;
    long *anfang;
} SINF;

typedef struct
{
    int fix;
    int r_flag;
    int ruhe;
    int max_sound;
    void (*play)(SINF *sound, int super);
    long (*set_vec)(void);
    struct
    {
        int nr;
        int sound;
        int an;
    } gem_inf[MAX_SAMP];
    SINF sounds[MAX_SAMP];
} C_SOUNDS;
