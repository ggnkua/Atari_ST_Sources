/* AESD.H
 *
 * Definitionen & Prototypen 
 *
 * Oktober 1992 by Richard Kurz, Vogelherdbogen 62, 7992 Tettnang
 * Fido 2:241/7232.5
 * FÅr's TOS-Magazin
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
int     handle_menu(int *buf);
