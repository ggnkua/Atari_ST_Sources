/****************************************************/
/*                                                  */
/*                  R E C O G                       */
/*                                                  */
/*          Wir schaben ASCII-Zeichen               */
/*          vom Bildschirm.                         */
/*          erstellt mit PURE C 1.0                 */
/*          lauff„hig auf ST, STE und TT            */
/*                                                  */
/*          (c) 1992 by Richard Kurz                */
/*          Vogelherdbogen 62                       */
/*          7992 Tettnang                           */
/*                                                  */
/*          TOS Magazin, ICP Verlag                 */
/*                                                  */
/****************************************************/
/* In diesem Modul GLOBAL.H sind diverse            */
/* Definitionen und die Prototypen enthalten.       */
/****************************************************/

#define TRUE 1
#define FALSE 0

#define SCREENSIZE 0x8020L 

#define MAXZBP 2000

typedef struct
{
    char hoehe;
    char breite_r[16];
    char breite_l[16];
    unsigned int bitr[16];
    unsigned int bitl[16];
} BMAP;

typedef struct
{
    unsigned char c;
    int x;
    int y;
} ZBUFFER;

typedef struct
{
    int n;
    int k;
    int style;
    int w;
    int h;
    int cw;
    int ch;
} AFONT;

void event_loop( void );
int buffer_init(void);  
void handle_buffer(int f); 
void init_prog(void); 
void main( void );
int point(int x, int y);
void plot(int x, int y);
int do_submenu(OBJECT *o, int w);
void fly_form_do(OBJECT *tree);
void check_fs(void);
void font_info(void);
char *get_pfad(char *ext, char *text);
void show_text(void);
int bild_laden(void);
int push_button(OBJECT *o,int e,int x,int y,int w,int h);
void g_main(void);

void init_font(void);
int is_char(int x,int y, int *ch);
void ch_gefunden(int x, int y, int ch);
void lerne_char(int x,int y, BMAP *c);
void lerne_satz(int ox, int oy);
void scan_screen(int fx,int fy,int lx,int ly);
int v_dif(int i);
int qx_verg(ZBUFFER *e1, ZBUFFER *e2);
int qy_verg(ZBUFFER *e1, ZBUFFER *e2);
int wandle_ascii(void);

int rk_rsc_init(void);
void rk_rsrc_gaddr(int b,OBJECT **o);
