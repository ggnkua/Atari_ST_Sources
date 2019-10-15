/* FIDOBAN.H
 * Definitonen & Prototypen fÅr FIDOBAN
 * 1992 by Richard Kurz
 * Vogelherdbogen 62
 * 7992 Tettnang
 * Fido: 2:241/7232.5
 *
 * fÅr's TOS Magazin
 * ICP Verlag
 */

#define RAUF 1
#define RUNTER 2
#define LINKS 3
#define RECHTS 4

#define OKAY 1
#define BOING 2
#define FERTIG 3

#define TRUE 1
#define FALSE 0

typedef struct
{
    char name[70];
    int level;
    long step;
} HSCORE;

void setze_stein(int x, int y,int farbe);

void fini(int f);

void out_string(char *s);
void out_char(int c);
void gotoxy(int x, int y);
void invers(int flag);
void cls(void);
int carrier_detect(void);
int hole_tast(void);

void sort_score(void);
int load_score(void);
int save_score(void);
void show_score(void);

int load_feld(int l);
int spieler_zug(int flag);

