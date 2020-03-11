
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
**   Compiler options:   -w -csuf -ta -v -Lg
**                       ie. (short integers, single copy of strings,
**                       unsigned characters, compulsory prototypes,
**                       no stack checking, desk accesory startup code
**                       and graphic library.)
*/

/*
**   Tested with:
**   Machine:            Mega 4 with 4 Meg RAM
**   TOS Vers:           1.4
**   Nationality:        UK
*/

/*
**   Requirements:       The internal machine clock date must
**                       be right.
**   
**   Compatabilities:    First Word Plus, Timeworks DTP,
**                       MS Write, Calligrapher, Calamus, 
**                       Neodesk CLI, CixRead, CixComm, 
**                       Tempus version 1.
**                       and the Hisoft C Editor.
** 
**   Incompatabilities:  Doesn't work well within
**                       Codehead's Multidesk utility, as
**                       Multidesk curtails communication with 
**                       slow programs like First Word Plus.
**                       Also some programs like Tempus 2 use 
**                       a different method to poll the 
**                       keyboard. For some reason the date comes out
**                       in lower case in Tempus 2
**
**                       Programs that only accept text
**                       from a dialogue box such as Outline Art
**                       and Touch Up or suspend menus when
**                       entering text, eg. Easydraw2 & Degas Elite.
**                       Non GEM programs obviously.
**
**   Wish list:          Implement this program as a TSR vector stealer
**                       that is activated by a special key combination 
**                       as opposed to wasting a DA slot.
*/

                      
#include <osbind.h>
#include <gemlib.h>
#include <string.h>
#include <dos.h>

/* Function prototypes */

void dec_str(char **str,int n);
int insert_date(char *str);
void send_text(void);
void main (void);
short get_scancode(char ch);
void init_keys(void);


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

/* Gemdos date package */

struct pkdate {
unsigned year   :7;
unsigned month  :4;
unsigned day    :5;
};

union udate {
     short num;
     struct pkdate d;
};


/* Global Variables */

/* text buffer */

char message[35];

/* Months in English */

char *month[]={
     "January","February",
     "March","April",
     "May","June",
     "July","August",
     "September","October",
     "November","December"
};

/* Month number tails 1st, 2nd .. etc */
 
char *tail[]= {"th","st","nd","rd"};

/* AES tools */
 
int gl_apid;

int  menu_id, event;
int  msgbuff[8];

/* Functions */

void main(void)
{
     gl_apid = appl_init();

/* insert menu text */
     menu_id = menu_register (gl_apid,"  Insert Date");

     init_keys();

/* Never ending loop */ 
     for (;;)
     {

/* wait for AES */
          evnt_mesag (msgbuff); 
 
/* If called wake up */        
          if( msgbuff[0] == AC_OPEN
               && msgbuff[4] == menu_id )
          {
               send_text();
          }

/* go to sleep */
     }
/* we never get here */
}


/* 
   Abacus 'Atari Internals' got this entirely
   the wrong way round as per usual 
*/

void send_text(void)
{
     long len;
     register short c,index;
     struct iorec *io;

/* go and get date string */    
     len=insert_date(message);

/* get address of OS buffer */
     io=Iorec(1);
     index=io->ibuftl;

/* copy date string to OS buffer*/
     for (c=0;c<len;c++)
     {
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
          io->ibuf[index+3]=message[c];
          io->ibuf[index+2]=0;
          io->ibuf[index+1]=get_scancode(message[c]);
          io->ibuf[index]=0;
     }
/*
   Set the read position to the begining
   of our string and the write position 
   to the end of it
*/
     io->ibufhd = io->ibuftl;
     io->ibuftl = index;
} /* done */


   
int insert_date(char *str)
{
     union udate date;
     int day, year, mon, ttype;
     char *ptr,*ptr1;

/* get GEMDOS date */
     date.num = Tgetdate();
     day=(int)date.d.day;          /* Day */
     mon=(int)date.d.month-1;      /* Month to 0 index ie Jan = 0 */
     year=(int)date.d.year+1980;   /* Year to AD format */

/* 
   Lattice C 5 sprintf doesn't seem to work 
   very well in a desk accesory well + its big 
   and I only want a few functions 
*/

     ptr=str;

/* get day string */
     dec_str(&ptr,day);

/* glue on the right tail */

     ttype = (day % 10);
     if (ttype > 3) ttype=0; 
     if (day / 10 == 1) ttype =0; 

     for (ptr1=tail[ttype];*ptr1;*ptr++=*ptr1++);
     *ptr++=' ';

/* glue on correct month name */
     for (ptr1=month[mon];*ptr1;*ptr++=*ptr1++);
     *ptr++=' ';

/* get year string */
     dec_str(&ptr,year);
     *ptr=0;

/* return string length */
     return (int)( ptr-str);
}

/* 
   This recursivley fills a string with a 
   positive decimal number slightly altered 
   from an example in Kernigan & Ritchie.

   Section 4.10.
   'The C Programming Language 2nd Edition',
   Prentice Hall, Eaglewood Cliffs, NJ 07632,
   USA. 1988.
*/

void dec_str(char **str,int n)
{
     if(n / 10)
          dec_str(str,n / 10);
     **str =(n % 10) + '0';
     (*str)++;
}
struct keytab *keys;

void init_keys(void)
{
     keys = (struct keytab *)Keytbl((char *)-1,(char *)-1,(char *)-1);
}

short get_scancode(char ch)
{
     register short c;
     short ret = 0;
     for (c = 0; c < 128 && !ret; c++)
          if ( keys->unshift[c] == ch) ret = c;
          else if ( keys->shift[c] == ch) ret = c;
               else if ( keys->capslock[c] == ch) ret = c;
     return (ret);
}

