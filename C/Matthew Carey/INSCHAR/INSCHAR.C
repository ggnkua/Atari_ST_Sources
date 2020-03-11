


/*  
**  Accessory to write character to the main program
**  running at the time the DA is called as if it had been
**  typed in at the keyboard.
**
**  This software is placed in the Public Domain and is
**  made freely available to anyone to use or alter in
**  any way they see fit, I accept no liability for its
**  use or abuse.  Matthew Carey 1st November 1991.
*/



/*  
**  Accessory to write a date string to the main program
**  running at the time the DA is called as if it had been
**  typed in at the keyboard.
**
**  This software is placed in the Public Domain and is
**  made freely available to anyone to use or alter in
**  any way they see fit, I accept no liability for its
**  use or abuse.  Matthew Carey 19th April 1995
*/


/*
** 
**   Author:             Matthew Carey
**   Language:           Lattice C version 5.6 (from Hisoft) 
**   Compiler options:   -w -cuf -ta -v -Lg
**                       ie. (short integers, unsigned characters, 
**                       compulsory prototypes, no stack checking, 
**                       desk accesory startup code and graphic library.)
*/

/*
**   Tested with:
**   Machine:            Mega 4 with 4 Meg RAM
**   TOS Vers:           1.4
**   Nationality:        UK
*/

/*
**   
**   Compatabilities:    First Word Plus, Timeworks DTP,
**                       MS Write, Calligrapher, Calamus, 
**                       Neodesk CLI, CixRead, 
**                       Tempus version 1, Everest,
**                       and the Hisoft C Editor.
** 
**   Incompatabilities:  Doesn't work well within
**                       Codehead's Multidesk utility, as
**                       Multidesk curtails communication with 
**                       slow programs like First Word Plus.
**                       Also some programs like Tempus 2 use 
**                       a different method to poll the 
**                       keyboard. And some like CixComm are not
**                       happy to get characters without a scancode
**                       which is the whole point of this program.
**                       Programs that only accept text
**                       from a dialogue box such as Outline Art
**                       and Touch Up or suspend menus when
**                       entering text, eg. Easydraw2 & Degas Elite.
**                       Non GEM programs obviously.
**
*/
                      
#include <osbind.h>
#include <gemlib.h>
#include <string.h>
#include <time.h>
#include <dos.h>
#ifdef DEBUG
#include <stdio.h>
#endif


#include "inscrsc.h"

/* Function prototypes */

void send_ch(char x);
#ifdef DEBUG
int main(void);
#else
void main(void);
#endif
int getboxchar(struct object *ob, short ind);
short dialogue(struct object *box_tree, int field);
int form_under_mouse(OBJECT *box_tree,short *x,short *y,short *w,short *h);
int form_at(short nx, short ny, OBJECT *box_tree,short *x,short *y,short *w,short *h);
short get_scancode(char ch);
void init_keys(void);
void fix_dec_str(char *str,int n);
short get_dec(char *str);


/* void pause(time_t how_long); */

/* the decompiled resource 
*/

#include "inscrsc.c"


#define TRUE  1
#define FALSE 0

/* Structures used in this program */

/* Circular OS input buffer */
#ifndef _DOS_H
struct iorec {
    char *ibuf;     /* Buffer */
    short ibufsiz;  /* Size */
    short ibufhd;   /* Head index */
    short ibuftl;   /* Tail index */
    short ibuflow;  /* low water mark */
    short ibufhi;   /* high water mark */
};
#endif

/* AES tools */
 
int gl_apid;

int  menu_id, event;
int  msgbuff[8];
/* this is to allow easy patching */
unsigned long p1 = 0x3E3E3E3E;
short scan_dummy = 0x3E00;
unsigned long p2 = 0x3C3C3C3C;
/* The value to be patched is surrounded with >>>>> and <<<< */
/* Functions */
#ifdef DEBUG
int main(void)
#else
void main(void)
#endif
{
     short ret;
     unsigned char x;

     gl_apid = appl_init();
     
     init_keys();
     rsrc_init();

#ifndef DEBUG
/* insert menu text */
     menu_id = menu_register (gl_apid,"  Insert Char");
     scan_dummy &= 127;
/* Never ending loop */ 
     for (;;)
     {

/* wait for AES */
          evnt_mesag (msgbuff); 
/* If called wake up */        
          if( msgbuff[0] == AC_OPEN
               && msgbuff[4] == menu_id )
#endif
          {
               do
               {
                    ret = dialogue(CH_TABLE,0);
                    CH_TABLE[ret].ob_state &= ~SELECTED;
                    if ((ret != CANCEL) && (CH_TABLE[ret].ob_type == G_BOXCHAR)) 
                    {
                         x = getboxchar(CH_TABLE,ret);
                         send_ch(x);
                    }
                    else if(ret==QUESTION)
                    {
                         fix_dec_str(((TEDINFO *)SETTINGS[SCAN_DUMMY].ob_spec)->te_ptext,scan_dummy);
                         SETTINGS[dialogue(SETTINGS,SCAN_DUMMY)].ob_state &= ~SELECTED;
                         scan_dummy=get_dec(((TEDINFO *)SETTINGS[SCAN_DUMMY].ob_spec)->te_ptext) & 127;
                    }
               }while(ret==QUESTION);
          }
#ifndef DEBUG

/* go to sleep */
     }
#else
     return(0);
#endif
/* we never get here */
}


void send_ch(char x)
{

#ifdef DEBUG
     char str[100];

     sprintf(str,"[1][Character %c %d selected][OK]",x,x);
     form_alert(1,str);
}
#else

     short index;
     struct iorec *io;
     
/* get address of OS buffer */
     io=Iorec(1);
     index=io->ibuftl;

/* 
   The OS places 32 bit integers for each key 
   in the buffer but the index position is 
   recorded for 8 bit characters
*/ 
     index+=4;

     if ( index >= io->ibufsiz) 
     {
          index=0;
     }
     io->ibuf[index+3]=x;
     io->ibuf[index+2]=0;
     io->ibuf[index+1]=get_scancode(x);
     io->ibuf[index]=0;
/*
   Set the read position to the begining
   of our string and the write position 
   to the end of it (this might not be right)
*/
     io->ibufhd = io->ibuftl;
     io->ibuftl = index;
} /* done */
#endif
int getboxchar(struct object *ob, short ind)
{
     return (int)((unsigned long)(ob[ind].ob_spec)>>24);
}

short dialogue(struct object *box_tree, int field)
{
     short x, y, w, h, littlex, littley, littlew, littleh;
     short ret;
     GRECT wr;

     wind_get(DESK,WF_WORKXYWH,&wr.g_x,&wr.g_y,&wr.g_w,&wr.g_h);


     if (field < 0) field = 0;


     evnt_timer(1000,0);

     form_under_mouse(box_tree,&x,&y,&w,&h); 
     littlew = littleh = 50;
     littlex = x + w / 2 - littlew;
     littley = y + h / 2 - littleh;
     form_dial(FMD_START,littlex,littley,littlew,littleh,x,y,w,h);
/*   form_dial(FMD_GROW,littlex,littley,littlew,littleh,x,y,w,h);  */
     objc_draw(box_tree,0,MAX_DEPTH,x,y,w,h);
     ret = form_do(box_tree,field) & 0x7fff;

/*   form_dial(FMD_SHRINK,littlex,littley,littlew,littleh,x,y,w,h); */
     form_dial(FMD_FINISH,littlex,littley,littlew,littleh,x,y,w,h);
     return (ret);
}

int form_under_mouse(OBJECT *box_tree,short *x,short *y,short *w,short *h)
{
     short mx,my,dummy;
     GRECT wr, or;

     wind_get(DESK,WF_WORKXYWH,&wr.g_x,&wr.g_y,&wr.g_w,&wr.g_h);

     graf_mkstate(&mx,&my,&dummy,&dummy);

/*
     or.g_x=box_tree[0].ob_x-10;
     or.g_y=box_tree[0].ob_y-10;
*/   
     or.g_w=box_tree[0].ob_width+20;     
     or.g_h=box_tree[0].ob_height+20;     

     or.g_x=mx-(or.g_w/2);
     or.g_y=my-(or.g_h/2);

     rc_constrain(&wr,&or);

     box_tree[0].ob_x=or.g_x+10;     
     box_tree[0].ob_y=or.g_y+10;     

     *x=or.g_x; *y=or.g_y; *w=or.g_w; *h=or.g_h;
     return 0;
}


struct keytab *keys;

void init_keys(void)
{
     keys = (struct keytab *)Keytbl((char *)-1,(char *)-1,(char *)-1);
}

short get_scancode(char ch)
{
     register short c;
     for (c = 0; c < 128; c++)
          if (( keys->unshift[c]  == ch) ||
              ( keys->shift[c]    == ch) ||
              ( keys->capslock[c] == ch)) return(c);
     return (scan_dummy);
}

void fix_dec_str(char *str,int n)
{

     str[2]='0'+(n % 10);
     n=n/10;
     str[1]='0'+(n % 10);
     n=n/10;
     str[0]='0'+(n % 10);
     str[3]=0;
}

short get_dec(char *str)
{
     short ret=0;

     if (str[0] && str[0]<='9' && str[0]>='0')
          ret += str[0]-'0';
     else if (!str[0]) return ret;
 
    if (str[1] && str[1]<='9' && str[1]>='0')
     {
          ret *= 10;
          ret += str[1]-'0';
     }
     else if (!str[1]) return ret;

     if (str[2] && str[2]<='9' && str[2]>='0')
     {
          ret *= 10;
          ret += str[2]-'0';
     }
     return ret;
}


 
      



