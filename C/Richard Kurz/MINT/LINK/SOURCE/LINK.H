/* Link
 * Definitionen & Prototypen
 * Oktober 1992 by Richard Kurz
 */

#if !defined( __AES__ )
#include <aes.h>
#endif

#define TRUE            1
#define FALSE           0

#define EXTERN          extern
#define BYTE            char

#define MAX_WINDOW      10

typedef struct
{
    int handle,wopen,end,nr;

    int x,y,w,h;
    int wx,wy,ww,wh;
    int kind;
    char *title;
    
    OBJECT *obj;
    int (*do_button)(int b,int w);
    int (*do_wtast)(int t, int w);

}HWINDOW;

int     open_window(HWINDOW *w);
void    close_window(int w);
void    loop(void);
void    draw_obj(OBJECT *obj,int o,int ti,int wi);

void    init_dialog(void);
void    do_timer(void);
void    gem_main(void);
void    do_meldung(char *t1,char *t2,char *t3,char *t4);

void    set_sym_link(void);
void    read_link(void);
void    del_link(void);
