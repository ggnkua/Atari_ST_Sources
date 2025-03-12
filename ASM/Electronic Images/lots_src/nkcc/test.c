/*TAB=3***CHAR={ATARI}**********************************************************
*
*  Project name : NORMALIZED KEY CODE CONVERTER (NKCC)
*  Module name  : Test utility
*  Symbol prefix: -
*
*  Author       : Harald Siegmund (HS)
*  Co-Authors   : -
*  Write access : HS
*
*  Notes        : -
*-------------------------------------------------------------------------------
*  Things to do : -
*
*-------------------------------------------------------------------------------
*  History:
*
*  1990:
*     May 26: creation of file
*     Oct 03: minor changes
*     Nov 13: NK_LEFT and NK_RIGHT were exchanged
*  1991:
*     Jun 08: bug fixed (hitting space lead to a crash)
*     Aug 22: deadkey flags changed
*     Aug 26: NK_INVALID
*     Sep 14: use NKF_IGNUM
*     Nov 05: use Esc instead of 'C'
*     Nov 16: Control key emulation
*     Dec 29: NK_RVD...
*  1992:
*     Jan 12: don't install 200 Hz timer interrupt
*             reorganizing source
*  1993:
*     Dec 11: new file header
*             nkc_init: parameter added
*             cosmetic changes
*  1994:
*     Jun 27: detect macro keys and display them a different way
*
*******************************************************************************/
/*KEY _NAME="NKCC test utility" */
/*END*/


/**************************************************************************/
/*                                                                        */
/*                            INCLUDE FILES                               */
/*                                                                        */
/**************************************************************************/

/*START*/
#include <stdio.h>
#include <tos.h>
#include "nkcc.h"
/*END*/

/*KEY _END */


/**************************************************************************/
/*                                                                        */
/*                               MACROS                                   */
/*                                                                        */
/**************************************************************************/

                                    /* ignore numeric key pad flag and */
                                    /*  CapsLock when comparing key codes */
#define F_IGNORE (NKF_IGNUM | NKF_CAPS)


#define UNUSED(x) x = x             /* macro for unused formal parameters */


#define TRUE      1                 /* status codes */
#define FALSE     0
#define NIL       (-1)



/**************************************************************************/
/*                                                                        */
/*                         INITIALIZED STATICS                            */
/*                                                                        */
/**************************************************************************/

static char *skeys[] =              /* special function keys */
   {                                /* (index = NK_... defined in NKCC.H) */
   "INVALID",
   "UP",
   "DOWN",
   "RIGHT",
   "LEFT",
   "RESERVED (code 05)",
   "RESERVED (code 06)",
   "RESERVED (code 07)",
   "Backspace",
   "Tab",
   "Enter",
   "Insert",
   "ClrHome",
   "Return",
   "Help",
   "Undo",
   "F1",
   "F2",
   "F3",
   "F4",
   "F5",
   "F6",
   "F7",
   "F8",
   "F9",
   "F10",
   "RESERVED (code 1A)",
   "Esc",
   "RESERVED (code 1C)",
   "RESERVED (code 1D)",
   "RESERVED (code 1E)",
   "Delete"
   };

static char *sasc[] =               /* special ASCII characters plus Space */
   {                                /* (cannot be output via GEMDOS) */
   "[ASCII null]",
   "[up arrow]",
   "[down arrow]",
   "[right arrow]",
   "[left arrow]",
   "[window closer]",
   "[window sizer]",
   "[window fuller]",
   "[check mark]",
   "[clock]",
   "[bell]",
   "[note]",
   "[form feed]",
   "[carriage return]",
   "[Atari logo, left part]",
   "[Atari logo, right part]",
   "[decimal 0]",
   "[decimal 1]",
   "[decimal 2]",
   "[decimal 3]",
   "[decimal 4]",
   "[decimal 5]",
   "[decimal 6]",
   "[decimal 7]",
   "[decimal 8]",
   "[decimal 9]",
   "[\"a\"-like character]",
   "[escape]",
   "[face, upper left part]",
   "[face, upper right part]",
   "[face, lower left part]",
   "[face, lower right part]",
   "Space"
   };

static unsigned char *dead_tab =    /* deadkey table */
   "^~\'`¹\"ø,/";

static char *o_on  = "on",          /* option status */
            *o_off = "off";



/**************************************************************************/
/*                                                                        */
/*                          LOCAL PROTOTYPES                              */
/*                                                                        */
/**************************************************************************/

   /* display key code */
static void display_key(int key);

   /* enter option to enable/disable */
static unsigned long enter_option(unsigned long sflags);

   /* handle command: enable option */
static int enable_opt(unsigned long *sflags);

   /* handle command: disable option */
static int disable_opt(unsigned long *sflags);

   /* handle command: show help text */
static int show_help(unsigned long *sflags);

   /* handle command: quit program */
static int quit_program(unsigned long *sflags);

   /* handle command: show option status */
static int show_options(unsigned long *sflags);

   /* handle command: leave command mode */
static int leave_cmd(unsigned long *sflags);

   /* command mode handler */
static int command_mode(unsigned long *sflags);



/**************************************************************************/
/*                                                                        */
/*                          LOCAL FUNCTIONS                               */
/*                                                                        */
/**************************************************************************/

/***************************************************************************
*
*  display_key: display key code
*
*  A literal description of the given normalized key code is displayed on
*  the screen.
*
*  Out:
*        -
*
***************************************************************************/

static void display_key(key)

int         key;                    /* normalized key code */
{     /* display_key() */

   int      ascii;                  /* ASCII part of key code */


   ascii = key & 0xff;              /* isolate ASCII part */

   printf("NKC=$%04x:",key);        /* print complete key code as 4-digit */
                                    /*  hex number */

   if (key & NKF_ALT)               /* print Alternate and Control key flags */
      printf(" Alternate");

   if (key & NKF_CTRL)
      printf(" Control");

   switch (key & NKF_SHIFT)         /* print Shift key flags */
      {
      case NKF_LSH:                 /* only left Shift key pressed */
         printf(" left Shift");
         break;

      case NKF_RSH:                 /* only right Shift key pressed */
         printf(" right Shift");
         break;

      case NKF_SHIFT:               /* both */
         printf(" left & right Shift");
         break;
      }

   if (key & NKF_NUM)               /* print numeric keypad flag */
      printf(" numeric");

                                    /* macro key? */
   if ((key & (NKF_FUNC | NKF_ALT | NKF_CTRL)) == NKF_FUNC && ascii >= 32)
      printf(" macro key $%02x (%c)",ascii,ascii);
   else if (ascii > 32)             /* printable character except space? */
      printf(" %c",ascii);          /* show it */
   else if (key < 0 && ascii != 32) /* "function key", not space? */
      printf(" %s",skeys[ascii]);   /* display function key name */
   else                             /* else: printable character with ASCII */
      printf(" %s",sasc[ascii]);    /*  code less than or equal 32: display */
                                    /*  its name */

   if (key & NKF_CAPS)              /* print CapsLock flag */
      printf(" (CapsLock)");

   printf("\n");                    /* EOL */

}     /* display_key() */




/***************************************************************************
*
*  enter_option: enter option to enable/disable
*
*  Out:
*        option mask (NKS_...; 0 = aborted)
*
***************************************************************************/

static unsigned long enter_option(sflags)

unsigned long sflags;               /* special key flags (NKS_...) */
{     /* enter_option() */

   static struct                    /* table of options' key codes and */
      {                             /*  flag masks */
      int   key;                    /* normalized key code */
      unsigned long mask;           /* key flag mask */
      char  *s;                     /* text to print */
      } keytab[] =
      {
         {NKF_FUNC | NK_BS,0,"\033D \033D"}, /* Backspace (abort): cursor */
                                             /*  left, Space, cursor left */
         {F_IGNORE | 'A',NKS_ALTNUM,"A\n"},  /* direct ASCII input */
         {F_IGNORE | 'C',NKS_CTRL,"C\n"},    /* control key emulation */
         {F_IGNORE | 'D',NKS_DEADKEY,"D\n"}, /* all deadkeys */
         {NK_TERM,0}                         /* terminator */
      };

   int      key,                    /* normalized key code */
            i,
            a1;
   unsigned long mask;              /* key flag mask */


   nkc_set(sflags & ~NKS_DEADKEY);  /* disable deadkeys temporary */

   do {
      key = nkc_conin();            /* get key code */

                                    /* find mask in table */
      for (i = a1 = 0; keytab[i].key != NK_TERM; i++)
         if (a1 = nkc_cmp(keytab[i].key,key))
            {
            mask = keytab[i].mask;  /* found: get flag mask */
            printf(keytab[i].s);    /* print text */
            break;                  /* exit loop */
            }

                                    /* not found: search deadkey table */
      if (!a1) for (i = 0; dead_tab[i]; i++)
         if (a1 = nkc_cmp(F_IGNORE | dead_tab[i],key))
            {
            mask = 0x10000UL << i;  /* found: compute mask and print character*/
            printf("%c\n",dead_tab[i]);
            break;                  /* exit loop */
            }

      if (!a1) Cconout(BEL);        /* still not found? bing! */

      } while (!a1);                /* while not aborted */


   nkc_set(sflags);                 /* restore NKCC configuration */

   return mask;                     /* return flag mask */

}     /* enter_option() */




/***************************************************************************
*
*  enable_opt: handle command: enable option
*
*  Out:
*        exit status:
*        TRUE        leave command mode
*        FALSE       continue
*        NIL         leave command mode AND program
*
*        updated special key flags in *sflags
*
***************************************************************************/

static int enable_opt(sflags)

unsigned long *sflags;              /* ^ to special key flags (NKS_...) */
{     /* enable_opt() */

   printf("+");                        /* enable */

   *sflags |= enter_option(*sflags);   /* get option and set its flag */
   nkc_set(*sflags);                   /* reconfigure NKCC */

   return FALSE;

}     /* enable_opt() */




/***************************************************************************
*
*  disable_opt: handle command: disable option
*
*  Out:
*        exit status:
*        TRUE        leave command mode
*        FALSE       continue
*        NIL         leave command mode AND program
*
*        updated special key flags in *sflags
*
***************************************************************************/

static int disable_opt(sflags)

unsigned long *sflags;              /* ^ to special key flags (NKS_...) */
{     /* disable_opt() */

   printf("-");                        /* disable */

   *sflags &= ~enter_option(*sflags);  /* get option and clear its flag */
   nkc_set(*sflags);                   /* reconfigure NKCC */

   return FALSE;

}     /* disable_opt() */




/***************************************************************************
*
*  show_help: handle command: show help text
*
*  Out:
*        exit status:
*        TRUE        leave command mode
*        FALSE       continue
*        NIL         leave command mode AND program
*
*        updated special key flags in *sflags
*
***************************************************************************/

static int show_help(sflags)

unsigned long *sflags;              /* ^ to special key flags (NKS_...) */
{     /* show_help() */

   int      i;


   UNUSED(sflags);

   printf("H\n\n"                   /* just show text */
          "Commands:\n"
          "   Esc   leave command mode\n"
          "   +x    enable option x\n"
          "   -x    disable option x\n"
          "   s     show option status\n"
          "   q     quit program\n"
          "   h     show this help text!\n"
          "\n"
          "Options:\n"
          "   A     direct ASCII input\n"
          "   C     Control key emulation\n"
          "   D     ALL deadkeys\n"
          "   %c     one specific deadkey\n",dead_tab[0]);

   for (i = 1; dead_tab[i]; printf("   %c\n",dead_tab[i++]));

   printf("\n");                    /* EOL */

   return FALSE;

}     /* show_help() */




/***************************************************************************
*
*  quit_program: handle command: quit program
*
*  Out:
*        exit status:
*        TRUE        leave command mode
*        FALSE       continue
*        NIL         leave command mode AND program
*
*        updated special key flags in *sflags
*
***************************************************************************/

static int quit_program(sflags)

unsigned long *sflags;              /* ^ to special key flags (NKS_...) */
{     /* quit_program() */

   UNUSED(sflags);

   printf("Q\n\nBye\n");

   return NIL;

}     /* quit_program() */




/***************************************************************************
*
*  show_options: handle command: show option status
*
*  Out:
*        exit status:
*        TRUE        leave command mode
*        FALSE       continue
*        NIL         leave command mode AND program
*
*        updated special key flags in *sflags
*
***************************************************************************/

static int show_options(sflags)

unsigned long *sflags;              /* ^ to special key flags (NKS_...) */
{     /* show_options() */

   int      i;

                                    /* status of ASCII input */
   printf("S\n\n   ASCII input:  %s\n",
      (*sflags & NKS_ALTNUM) ? o_on : o_off);

                                    /* status of control key emulation */
   printf("Ctrl emulation:  %s\n",
      (*sflags & NKS_CTRL) ? o_on : o_off);

                                    /* status of deadkeys */
   for (i = 0; dead_tab[i]; i++)
      printf("     %c deadkey:  %s\n",
         dead_tab[i],
         (*sflags & (0x10000UL << i)) ? o_on : o_off);

   printf("\n");                    /* EOL */

   return FALSE;

}     /* show_options() */




/***************************************************************************
*
*  leave_cmd: handle command: leave command mode
*
*  Out:
*        exit status:
*        TRUE        leave command mode
*        FALSE       continue
*        NIL         leave command mode AND program
*
*        updated special key flags in *sflags
*
***************************************************************************/

static int leave_cmd(sflags)

unsigned long *sflags;              /* ^ to special key flags (NKS_...) */
{     /* leave_cmd() */

   UNUSED(sflags);

   printf("Esc\n\n");

   return TRUE;

}     /* leave_cmd() */




/***************************************************************************
*
*  command_mode: command mode handler
*
*  The program enters the command mode. Hitting some specific keys will
*  perform special tasks. See table <keytab> defined below. Unknown
*  keys respectively key combinations are ignored.
*
*  Out:
*        exit status:
*        TRUE        leave program
*        FALSE       continue
*
***************************************************************************/

static int command_mode(sflags)

unsigned long *sflags;              /* ^ to special key flags (NKS_...) */
{     /* command_mode() */

   static struct                    /* table of supported key codes and */
      {                             /*  their handlers */
      int   key;                    /* normalized key code */
      int   (*pf)(                  /* ^ to handler for that key code */
             unsigned long *sflags);
      } keytab[] =
      {
         {F_IGNORE | '+',enable_opt},        /* enable option */
         {F_IGNORE | '-',disable_opt},       /* disable option */
         {F_IGNORE | 'H',show_help},         /* show help text */
         {F_IGNORE | 'Q',quit_program},      /* quit program */
         {F_IGNORE | 'S',show_options},      /* show option status */
         {NKF_FUNC | NK_ESC,leave_cmd},      /* leave command mode */
         {NK_TERM,NULL}                      /* terminator */
      };

   int      key,                    /* normalized key code */
            i,
            a1;


   printf("\n");                    /* blank line */

   do {                             /* receive and evaluate key codes */
      printf("\rEnter command (h=help): ");

      key = nkc_conin();            /* get key */

                                    /* find handler for that key */
      for (i = a1 = 0; keytab[i].key != NK_TERM; i++)
         if (a1 = nkc_cmp(keytab[i].key,key))
            break;                  /* found: exit loop */

      if (a1)                       /* found? */
         a1 = keytab[i].pf(sflags); /* then call handler */
      else                          /* unknown key code: */
         Cconout(BEL);              /* bing! */

      } while (!a1);                /* while not aborted */

   a1 = (a1 < 0);                   /* a1<0: quit program */

   return a1;

}     /* command_mode() */



/**************************************************************************/
/*                                                                        */
/*                          GLOBAL FUNCTIONS                              */
/*                                                                        */
/**************************************************************************/

/*START*/
/***************************************************************************
*
*  main: program entry point
*
*  Out:
*        -
*
***************************************************************************/

int main()
{     /* main() */
/*END*/

   int      key,                    /* normalized key code */
            a1;
   unsigned long sflags;            /* special key flags (NKS_...) */



   a1 = nkc_init(NKI_NO200HZ,0,NULL);  /* init NKCC */

                                    /* show header */
   printf("NKCC test utility   (c) 1989-1993 Harald Siegmund\n"
          "Using NKCC version %x.%02x\n"
          "Press Esc to enter command mode\n\n",a1 >> 8,a1 & 0xff);

   sflags = 0;                      /* init special flags */


   do {                             /* receive and evaluate key codes */
      key = nkc_conin();            /* get key */

      display_key(key);             /* display it on the screen */

                                    /* Escape key? then enter command mode */
      if (a1 = nkc_cmp(NKF_FUNC | NK_ESC,key))
         a1 = command_mode(&sflags);

      } while (!a1);                /* while not aborted */


   a1 = nkc_exit();                 /* exit */

   if (a1)                          /* exit error? (strange!) display it */
      printf("\nFATAL EXIT ERROR #%d\n",a1);

   return 0;

}     /* main() */


/* EOF */

