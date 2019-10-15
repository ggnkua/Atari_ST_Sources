/* PS-Control
 * Definitionen & Prototypen
 * September 1992 by Richard Kurz
 */

#define TRUE 1
#define FALSE 0

#define EXTERN          extern
#define BYTE            char

#define VISENTRYS       17
#define MAX_PROZ        20
#define MAX_WINDOW      10

typedef struct
{
    long    regs[15];       
    long    usp;
    int sr;
    long    pc;
    long    ssp;
    long    term_vec;
    char    fstate[216];
    char    fregs[12*8];
    long    fctrl[3];
    int sfmt;
    long    iar;
    int internal[4];
} CONTEXT;

typedef struct
{
    long    magic;
    char    *base;
    int pid, ppid, pgrp;
    int ruid, rgid;
    int euid, egid;
    int memflags;
    int pri;
    int wait_q;
    long    wait_cond;

    unsigned long   systime;
    unsigned long   usrtime;
    unsigned long   chldstime;
    unsigned long   chldutime;

    unsigned long   maxmem;
    unsigned long   maxdata;
    unsigned long   maxcore;
    unsigned long   maxcpu;

    int domain;
    int curpri;
} PINFO;

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

int     load_inf(char *fn);
void    save_inf(void);
int     check_pri(char *n,int id,long p,int flag);
void    add_entry(char *name,int pri);
void    del_entry(char *name);

