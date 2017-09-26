#ifndef __MANILIBS_DIVERSES_H__
#define __MANILIBS_DIVERSES_H__

#ifndef __PORTAB__
#include <portab.h>
#endif

#define UNKNOWN ((boolean)-1)		/* Alternative zu TRUE/FALSE */

typedef struct {
	int16 x,y,w,h;
} RECT;

typedef struct {
	int32 x,y,w,h;
} LRECT;

void beep(void);					/* System-Beep */

/*
char upper(char c);				/* Zeichen in Groûbuchstaben */
char lower(char c);				/* Zeichen in Kleinbuchstaben */
*/

extern char upper_tab[256];
extern char lower_tab[256];

void upper_init(void);
void lower_init(void);

#define upper(c) (upper_tab[(uint8)(c)])
#define lower(c) (lower_tab[(uint8)(c)])

void str_upper(char *string);	/* String in Groûbuchstaben */
void str_lower(char *string);	/* String in Kleinbuchstaben */

void kill_space(char *txt);	/* Leerzeichen am Anfang und Ende entfernen */
void insert_space(char *txt, int spaceanz);	/* Leerzeichen am Anfang einfÅgen */

/* Matching-Routinen: */

boolean match_exakt(char *pat, char *txt);		/* Matching! Groû != Klein */
boolean match_grossklein(char *pat, char *txt);	/* Matching! Groû = Klein */
boolean file_one_match(char *pat, char *file, boolean grossklein);	/* Sonderfall *.* */
boolean file_match(char *pat, char *file, boolean grossklein);			/* *.* und Trennung per Komma! */
boolean file_vorausmatch(char *pat, char *file, boolean grossklein);	/* "Vorausmatching", Trennung per Strichpunkt erzwingt Textende */
/* Achtung bei file_vorausmatch! Ein Zeichen hinter pat wird beschrieben! (pat muû also lÑnger allokiert sein!) */
boolean matching_includes_matching(char *pat, char *subpat, boolean grossklein);

/* maxlen ohne 0-Byte! */
void match_2_vorausmatch(char *in, char *out, int maxlen);	/* Match so wandeln, daû mit vorausmatch das gleiche gefunden wird */

int16 Zufall16(int16 bereich);

int16 relativ(int16 wert, int16 ist, int16 soll);	/* relative Werte berechnen */

extern char hexa[];
int16 hexwert(char c);	/* Liefert Hexwert, wenn 0 <= c <= F, sonst -1 */

void nullitoa(char *txt, int16 wert, int16 anz);	/* itoa mit fÅhrenden Nullen */
int32 my_atol(char *txt);		/* ignoriert fÅhrende Nullen und Underscores */

char *quick_search(char *big, int32 big_len, char *small, int32 small_len);

#endif
