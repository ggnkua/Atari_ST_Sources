/* Include von POWERTEXT */

/* Diese flexible Struktur erm”glicht das problemlose einfgen 
										weitere Zeilen */
#define LAST_ZEILE	32767

struct ZEILE
{
char *string; 		/* Nullterminiert !   */
struct ZEILE *next_zeile;   /* bei NULL -> Ende !  */
struct ZEILE *prev_zeile;	/* bei NULL -> Anfang! */
};

typedef struct  
{
struct ZEILE *start;	/* Zeiger auf 1. Zeile 	  */
struct ZEILE *ende;		/* Zeiger auf letzt Zeile */	
int zeilen;				/* Kennt jemand einen Text mit mehr */
int max_spalten;		/* als 32000 Zeilen ( ungef„hr 1.2 MByte)? */	
}TEXT;

TEXT *text_read(char *textname,int tab);
void text_draw(struct WINDOW *text_win,TEXT *asciitext);
void text_free(TEXT *asciitext);

