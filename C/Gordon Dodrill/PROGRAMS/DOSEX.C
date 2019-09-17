/******************************************************************/
/* This is an example program to illustrate how to;               */
/*  1. Get the time and date from DOS                             */
/*  2. Set the cursor to any position on the screen               */
/*  3. Read characters from the keyboard and display their codes  */
/*  4. How to scroll a window up on the monitor                   */
/*  5. Format a program for ease of reading and understanding     */
/******************************************************************/

#include "stdio.h"
#include "dos.h"

main()
{
int hour, minute, sec, old_sec;
int character;

   draw_box();              /* draw the boxes around the fields */
   old_sec = 0;             /* this variable stores the old time
                               so we can look for a change      */

   do {
      if (kbhit()) {                     /* has a key been hit? */
         character = getch();            /* read it in          */
         disp_char(character);           /* display it          */
      }

      get_time(&hour,&minute,&sec);      /* get the time of day */ 
      if (sec != old_sec) {              /* if it has changed,  */
         disp_time_date();               /* update the display  */
         old_sec = sec;                  /* save new time       */
      }

   } while (character != 'Q');        /* Quit when a Q is found */

   pos_cursor(0,0);              /* put cursor at top of screen */
}


/* **************************************************** drawbox */
/* This routine draws a box on the screen. The keys hit, and    */
/* the time and date are displayed in these boxes. There is     */
/* nothing special about these boxes, they are simply output    */
/* using the printf function.                                   */
/* ************************************************************ */
draw_box()
{
int index;
char line[81];

   for (index = 0;index < 80;index++)       /* three blank rows */
      line[index] = ' ';
   line[80] = NULL;                            /* end of string */
   for (index = 0;index < 3;index++)
      printf("%s",line);

   line[8] = 201;                       /* draw top line of box */
   for (index = 9;index < 70;index++)
      line[index] = 205;
   line[70] = 187;
   printf("%s",line);

   line[8] = 186;                    /* draw sides of large box */
   for (index = 9;index < 70;index++)
      line[index] = ' ';
   line[70] = 186;
   for (index = 0;index < 15;index++)
      printf("%s",line);

   line[8] = 204;                    /* draw line between boxes */
   for (index = 9;index < 70;index++)
      line[index] = 205;
   line[70] = 185;
   printf("%s",line);

   line[8] = 186;                    /* sides for time/date box */
   for (index = 9;index < 70;index++)
      line[index] = ' ';
   line[70] = 186;
   printf("%s",line);

   line[8] = 200;                     /* bottom line of the box */
   for (index = 9;index < 70;index++)
      line[index] = 205;
   line[70] = 188;
   printf("%s",line);

   for (index = 0;index < 80;index++)       /* three blank rows */
      line[index] = ' ';
   for (index = 0;index < 3;index++)
      printf("%s",line);

}


/* ************************************************** disp_char */
/* This routine displays the characters hit on the monitor. If  */
/* the first character is a zero, a special character has been  */
/* hit, and the zero is displayed. The next character is read,  */
/* and it is displayed on the monitor.                          */
/* ************************************************************ */
disp_char(inchar)
int inchar;
{
   scroll_window();
   pos_cursor(17,15);          /* position of message on screen */

   if(inchar == 0) {
      printf(" 00 ");            /* a special character was hit */
      inchar = getch();          /* get the next part of it     */
      switch (inchar) {
         case 59  :
         case 60  :
         case 61  :
         case 62  :
         case 63  :              /* these are the function keys */
         case 64  :
         case 65  :
         case 66  :
         case 67  :
         case 68  : printf("%4d Function key F%d\n",inchar,inchar-58);
                    break;

         case 94  :
         case 95  :
         case 96  :
         case 97  :
         case 98  :         /* these are the ctrl-function keys */
         case 99  :
         case 100 :
         case 101 :
         case 102 :
         case 103 : printf("%4d Function key Ctrl-F%d\n",inchar,
                       inchar-93);
                    break;

         case 84  :
         case 85  :
         case 86  :
         case 87  :        /* these are the upper-function keys */
         case 88  :
         case 89  :
         case 90  :
         case 91  :
         case 92  :
         case 93  : printf("%4d Function key Upper-F%d\n",inchar,
                       inchar-83);
                    break;

         case 104 :
         case 105 :
         case 106 :
         case 107 :
         case 108 :          /* these are the alt-function keys */
         case 109 :
         case 110 :
         case 111 :
         case 112 :
         case 113 : printf("%4d Function key Alt-F%d\n",inchar,
                       inchar-103);
                    break;

         default  : printf("%4d Special key hit\n",inchar);
      }

   } else                        /* a regular character was hit */ 
      printf("    %4d (%c) Character Hit.\n",inchar,inchar);

   pos_cursor(25,1);        /* hide the cursor on the 26th line */
}


/* *************************************************** get_time */
/* This routine calls the DOS function call for time of day. It */
/* returns the time of day to the calling program in the three  */
/* pointers used in the call.                                   */
/* ************************************************************ */
get_time(hour,minute,second)
int *hour, *minute, *second;
{
union REGS inregs;
union REGS outregs;

   inregs.h.ah = 44;               /* Hex 2C - Get current time */
   int86(0x21,&inregs,&outregs);
   *hour = outregs.h.ch;
   *minute = outregs.h.cl;
   *second = outregs.h.dh;
}


/* ********************************************* disp_time_date */
/* This routine displays the time and date on the monitor in a  */
/* fixed position. It gets the time from the get_time function, */
/* and gets the date from its own built in DOS call. Good       */
/* programming practice would move the date to another function */
/* but this is an illustrative example to display methods of    */
/* doing things. This routine also calls the cursor positioning */
/* function to put the time and date where we want them.        */
/* ************************************************************ */
disp_time_date()
{
int hour, minute, second;
union REGS inregs;
union REGS outregs;

   pos_cursor(19,19);  /* position the cursor for date and time */

   inregs.h.ah = 42;              /* hex 2A - What is the date? */
   int86(0x21,&inregs,&outregs);  /* interrupt 21               */      
   printf("Date = %2d/%2d/%2d    ",
      outregs.h.dh,                 /* month - 1 to 12          */
      outregs.h.dl,                 /* day - 1 to 31            */
      outregs.x.cx);                /* year - 1980 to 2099      */

   get_time(&hour, &minute, &second);
   printf("Time = %2d:%2d:%2d\n",hour, minute, second);

   pos_cursor(25,1);        /* hide the cursor on the 26th line */
}

/* ************************************************* pos_cursor */
/* This routine positions the cursor at the requested row and   */
/* column. The upper left corner is row 0 and column 0          */
/* ************************************************************ */
pos_cursor(row,column)
char row, column;
{
union REGS inregs;
union REGS outregs;

   inregs.h.ah = 2;        /* service 2 - position the cursor   */
   inregs.h.dh = row;
   inregs.h.dl = column;
   inregs.h.bh = 0;
   int86(0x10,&inregs,&outregs);                /* interrupt 10 */
}


/* ********************************************** scroll_window */
/* This routine scrolls all of the material in the key hit      */
/* window up one space leaving room for another entry.          */
/* ************************************************************ */
scroll_window()
{
union REGS inregs;
union REGS outregs;

   inregs.h.ah = 6;      /* service 6 - scroll window           */
   inregs.h.al = 1;      /* number of lines to scroll           */
   inregs.h.ch = 3;      /* top row of window                   */
   inregs.h.cl = 9;      /* left column of window               */
   inregs.h.dh = 17;     /* bottom row of window                */
   inregs.h.dl = 69;     /* right column of window              */
   inregs.h.bh = 7;      /* attribute of blank line             */
   int86(0x10,&inregs,&outregs);                /* interrupt 10 */

}
