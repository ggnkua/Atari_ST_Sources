/*  LINK_GLO.H
 *
 *  aus: Wir basteln uns ein CPX
 *       CPX-Kurs Teil 2
 *       TOS Magazin
 *
 *  (c)1992 by Richard Kurz
 *  Vogelherdbogen 62
 *  7992 Tettnang
 *
 *  Erstellt mit Pure C
 */

#define TRUE 1
#define FALSE 0

/* Eine handvoll Prototypen */

int read_header(CPXHEAD *head, char *ext);
void write_header(CPXHEAD *h);
void write_to_cpx(CPXHEAD *h);
void link_cpx(CPXHEAD *h);

void upd_header(void);
void ch_ifarbe(void);
void ch_tfarbe(void);
void init_dialog(void); 
WORD handle_dialog(WORD button, WORD *msg);

int edit_icon(void);
UWORD *read_icon(void);
void write_icon(UWORD *icn);

