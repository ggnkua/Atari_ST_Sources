
#if !defined (__EASYGEM)
#define __EASYGEM

#include <aes.h>

typedef enum {FALSE,TRUE} boolean;
typedef struct
{
   int x;
   int y;
}Koordinaten;

boolean open_vwork(void);
void  close_vwork(void);

int min( int a, int b);
int max( int a, int b);
int random(int von,int bis);
char *add_prefix(char *name,char *fix);
long Lof(char *filename);
int fileselect(char *name,char *ext,char *title);
int file_in(char *pfad,char *title,int save);
   /* in der globalen Variablen 'char *_fname' steht der
      ausgew„hlte Filename */
   /* save != 0 -> Hintergrund puffern */
#define CANCEL 0
#define OK 1
void sget(char *buffer);
void sput(char *buffer);
void maus_aus(void);
void maus_an(void);
int  maus_get(int *mx,int *my);
int  mausxy(int *mx,int *my);
void set_maus(int mx,int my);
void set_point(int x,int y);
void clr_point(int x,int y);
int  tst_point(int x,int y);

void ende_dia(void);
void deffill(int farbe,int art,int muster);
void deftext(int color,int attribut,int rotation,int size);
void text_size(int size);
void defline(int thick,int art,int start,int ende);
void color(int color);
void defmarker(int color,int typ,int size);
void user_fill(int *muster);
void text(int x,int y,char *txt);
void box(int x1,int y1,int x2,int y2);
void rbox(int x1,int y1,int x2,int y2);
void pbox(int x1,int y1,int x2,int y2);
void prect(int x1,int y1,int x2,int y2);
void prbox(int x1,int y1,int x2,int y2);
void line(int x1,int y1,int x2,int y2);
void setstart(int x,int y);
void drawto(int x,int y);
void polymarker(int anz,int *array);
void clip(int x1,int y1,int x2,int y2);
void clip_off(void);
void form_to_screen(int x,int y,int w,int h,int mode,void *daten);
void screen_to_form(int x,int y,int w,int h,void *daten);
int *alloc_mem(int w,int h);        /* liefert Zeiger auf Speicherbereich */
int pop_up(int x,int y,int taste,char *text);
void put_buffer(int x,int y,int mode,void *adr);

void rsc_init(char *rsc_file,void (*funktion)());
void draw_tree(OBJECT *tree,int **adr);
void undraw_tree(OBJECT *tree,int *adr);
void drawTree(OBJECT *tree);
void undrawTree(OBJECT *tree);
void objc_select(OBJECT *tree,int index,int state);
void button_zahl(OBJECT *tree,int index,int zahl,int draw);
int  form_verwaltung(OBJECT *tree,int start_ob);
int  rc_intersect(GRECT *r1,GRECT *r2);


void wind_redraw( int win, GRECT *rect, wdrawF drawfunc);
void wind_sredraw( int win, GRECT *rect, wdrawF drawfunc);
void wind_rscroll( int win, GRECT *rscroll, int scrollx,
                   int scrolly, wdrawF drawfunc);
int wind_rubberbox( int win, GRECT *rmouse, GRECT *rsel);
#endif
