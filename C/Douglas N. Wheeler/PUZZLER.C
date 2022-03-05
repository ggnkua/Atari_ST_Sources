/***********************************************/
/*   PUZZLER                                   */
/*   by Douglas N. Wheeler                     */
/*   for use with DEGAS or NEOchrome pictures  */                    
/*                                             */
/*   COMPUTE!'s Atari ST Disk And Magazine     */
/*   February 1987 - Vol. 2, No. 1             */
/*   @ 1987 COMPUTE! Publications/ABC          */
/*                                             */ 
/***********************************************/

#include <stdio.h>
#include <fcntl.h>
#include <osbind.h>

int currez, inprez;
int handle, junk[46], savepal[16], palette[16], fhandle, mx, my, wx, wy, level, count;
int xl, yl;
int dummy;
long *buffer;
int intin[100],intout[100],ptsin[100],ptsout[100],contrl[12];

main()
{
  int l_intin[20], l_out[100];
  int i, j, ret, notmatch = 1;
  int s_hour, s_minute, s_second, f_hour, f_minute, f_second;
  int t_hour, t_minute, t_second;
  int oldx = 159, oldy = 99, newx, newy, a, b;
  int len, typflag, button, status, key;
  static char insel[256], inpath[256], path[] = ":\\*.***";
  static char congrats[] = "[1][| |Your time was:| 00:00:00.][Again|Exit]";
  long screen, time;

/*  Open workstation */

        buffer = (long *) Malloc(32000L);
        screen = Physbase(); /* Memory location of screen */
        for(i=0;i<16;i++) savepal[i] = Setcolor(i,-1); /* store old palette */
        currez = Getrez(); /* Current screen resolution */
        if(currez != 0)    /* Medium or high resolution */
          {
          path[4] = 'P';
          path[5] = 'I';
          path[6] = currez + 49;   /* Set pathname for DEGAS */
          }
        else
          {
          path[5] = 0;            /* NEO or DEGAS pathname for lo-res */
          }

        mx = 320 * (2 - (currez == 0)); /* Pixel width of screen */
        my = 200 * (1 + (currez == 2)); /* Pixel height of screen */
        wx = mx / 10;                   /* Pixel width of puzzle piece */
        wy = my / 10;                   /* Pixel height of puzzle piece */
        xl = 4 - 2 * (currez == 2);     /* Word width of puzzle piece */
        yl = 800 / wy;                  /* Word width of screen line */

        appl_init(); /* Initialize application */
        handle = graf_handle(&a, &a, &a, &a);  /* Get our handle */
    
        l_intin[0] = 1;  /* Parameters for workstation */
        l_intin[1] = 1;
        l_intin[2] = 1;
        l_intin[3] = 1;
        l_intin[4] = 1;
        l_intin[5] = 1;
        l_intin[6] = 1;
        l_intin[7] = 1;
        l_intin[8] = 1;
        l_intin[9] = 1;
        l_intin[10] = 2;

        v_opnvwk(l_intin, &handle, l_out);  /* Open our workstation */
        
        form_alert(1, "[0][     Picture Puzzler        |   by Douglas Wheeler|     Copyright 1987|       COMPUTE!'s|Atari ST Disk & Magazine ][OK]");

getfile:  /* Get filename */
        inpath[0] = (Dgetdrv() + 'A');
        inpath[1] = '\0';
        strcat(inpath,path);
        strcpy(insel, "");

        ret = fsel_input(inpath, insel, &button); /* Call file selector */

        if ( ( (insel[0] == 0) || (button == 0) ) )
          { /* Cancel if you choose Cancel or don't enter a filename */
          Mfree(buffer);
          getout();
          return(0);
          }

        /* concatenate path & name, starting with last slash in path */
        for(i=0;i<255 && inpath[i] != 0;i++) /* look ahead for zero */
          ;
        for(i=i;inpath[i] != '\\';i--) /* look backwards for slash */
          ;
        i++;
        for(j=0;insel[j] != 0;) inpath[i++] = insel[j++];

        typflag = 0;
        len = strlen(inpath) - 3; /* Check for 'N' in extension */
        if(inpath[len] == 'N') typflag = 1; /* Flag NEO file */
        fhandle = open(inpath, O_RDONLY | O_BINARY ); /* Open picture file for input */

        if(typflag == 1) read(fhandle, junk, 2); /* Junk word for NEO */

        read(fhandle, &inprez, 2);  /* Read picture resolution */

        if (inprez != currez)       /* Does it match screen? */
          {
                form_alert(1, "[1][| |That picture is a|different resolution.][OK]");
                goto getfile;
          }

        graf_mouse(256,&dummy); /* Turn mouse off */
        read(fhandle, palette, 32); /* Read color palette */
        Setpalette(palette); /* Set colors for picture */

        if(typflag == 1) read(fhandle, junk, 92);

        read(fhandle, buffer, 32000); /* Read picture into buffer */
        close(fhandle); /* Close picture file */
        
        copy(buffer, screen, 8000); /* Copy picture to screen */

        graf_mouse(257,&dummy);  /* Turn mouse on */
        level = form_alert(2, "[2][| |What level of|difficulty?][E|M|H]");
        level -= 1; /* Level: 0 - 2 */
        graf_mouse(256,&dummy); /* Turn mouse off */
        /* Scramble picture */
        for (b = 0; b < 10; ++b)   /* 10 columns of pieces */
          for (a = 0; a < 10; ++a) /* 10 rows of pieces */
                {
                  swap(a, b, rnd(10), rnd(10), screen); /* Swap with random piece */
                  if ((level != 0) && (rnd(4 / level) == 1)) flip(a, b, screen);
                }   /* Flip piece on levels 1 & 2 */

        graf_mouse(257,&dummy); /* Turn mouse on */

        time = Gettime(); /* Get start time */
        s_hour = (time & 0x0f800) / 2048;   /* Hours */
        s_minute = (time & 0x007e0) / 32;   /* Minutes */
        s_second = time & 0x0001f; /* Seconds */

        count = 0;  notmatch = 1;

        wind_update(3); /* Take control of mouse */

        /* Loop until puzzle is done or both buttons are pressed */

        while((notmatch != 0) && (status != 3) ) /* Picture not correct and... */
          {                              /* both buttons not pressed */
                status = 0;
                evnt_mouse(0, 0, 0, mx, my, &a, &a, &status, &key);

                switch (status)        /* 1-left, 2-right, 3-both */
                {
                  case 1:
                        graf_mkstate(&oldx, &oldy, &a, &a);  /* Get current mouse pos */
                        oldx /= wx; oldy /= wy; /* Convert to piece column & row */

                        graf_dragbox(wx, wy, oldx*wx, oldy*wy, 0, 0, mx, my, &newx, &newy);
                        /* Call dragbox routine */
                        newx = (newx + (wx / 2)) / wx; newy = (newy + (wy / 2)) / wy;
                        /* Column & row of new position */

                        swap(oldx, oldy, newx, newy, screen); /* Exchange pieces */

                        if ((level != 0) && (key != 0)) flip(newx, newy, screen);
                          /* If diff = 1 or 2 and Shift... */
                          /* Ctrl, or Alt--flip piece */

                        notmatch = compare(screen, buffer, 8000); /* Pic correct? */

                  break;

                  case 2:
                        /* Display correct picture until right button released */

                        if (count < 3) /* Looked at correct picture... */
                          {            /* less than 3 times? */
                                graf_mouse(256,&dummy); /* Mouse off */
                                exchange(screen, buffer, 8000); /* Swap buffer with screen */

                                evnt_button(1, 2, 0, &a, &a, &a, &a); /* Wait for button... */
                                                                      /* to be released */
                                exchange(screen, buffer, 8000);
                                /* Swap screen back */
                                graf_mouse(257,&dummy); /* Mouse on */

                                ++count; /* # of times looked at correct pic */
                          }
                        break;

                        case 3:
                          wind_update(2); /* Return mouse control */
                          a = form_alert(2,"[1][| |Do you really|want to quit?][Yes|No]");
                            /* Be sure user wants to give up */
                          wind_update(3); /* Take control of mouse */
                          if (a == 2) status = 1; /* If not continue 'while' loop */
                          break;
                }
          }

        wind_update(2); /* Return mouse control */
        a = 0;

        if (!notmatch) /* Picture correct? or both buttons */
          {
                time = Gettime(); /* Get finish time */
                f_hour = (time & 0x0f800) / 2048; /* Hours */
                f_minute = (time & 0x007e0) / 32; /* Minutes */
                f_second = time & 0x0001f; /* Seconds */
                t_second = f_second - s_second; /* Total seconds */
                if (t_second < 0)
                  {
                  t_second += 30; --f_minute;
                  }
                t_minute = f_minute - s_minute;  /* Total minutes */
                if (t_minute < 0)
                  {
                  t_minute += 60; --f_hour;
                  }
                t_hour = f_hour - s_hour;       /* Total hours */
                if (t_hour < 0) t_hour += 24;

                congrats[23] = (t_hour / 10) + 48; /* Put time in string for... */
                congrats[24] = (t_hour % 10) + 48; /* alert box */
                congrats[26] = (t_minute / 10) + 48;
                congrats[27] = (t_minute % 10) + 48;
                congrats[29] = (t_second / 5) + 48;
                congrats[30] = (t_second % 5) * 2 + 48;

                a = form_alert(2, congrats); /* Alert box for finish */

                if (a == 1) goto getfile; /* Selected Again? */
          }
          
         Mfree(buffer); /* Deallocate memory */
         getout(); /* Go close up shop */
         
} /* main ends here */

getout()
{
  int i;
  for(i=0;i<16;i++) Setcolor(i,savepal[i]); /* Restore old palette */
  v_clsvwk(handle);
  appl_exit();       /* Exit Application */
}

swap(x1, y1, x2, y2, screen)  /* Swap puzzle piece routine */
  int x1, y1, x2, y2;         /* Column & row for both pieces */
  long *screen;               /* Memory location of screen */
  {
        long *loc1, *loc2;
        long temp;
        int x, y;

        graf_mouse(256,&dummy); /* Mouse off */

        loc1=screen + y1 * 800 + x1 * xl;   /* Start of first piece */
        loc2=screen + y2 * 800 + x2 * xl;   /* Start of second piece */
          for(y = 0; y < wy; ++y)           /* Word width */
                for(x = 0; x < xl; ++x)     /* Pixel height */
                  {
                        temp = *(loc1 + y * yl + x);  /* Swap a word */

                        *(loc1 + y * yl + x) = *(loc2 + y * yl + x);

                        *(loc2 + y * yl + x) = temp;
                  }
        graf_mouse(257,&dummy); /* Mouse on */
  }

rnd(n) /* Random number from... */
  int n; /* 0 to n-1 */
  {
        int rmnd = 0, mask = 0x000002;
        --n;
        do
          {
                while (mask <= n) mask <<= 1;
                mask -= 1;
                rmnd = Random() & mask; /* Mask off upper bits */
          } /* If still too large... */
        while (rmnd > n); /* try again */
        return(rmnd); /* Return results */
  }

copy(orig, new, words) /* Copy memory */
  long *orig, *new;
  int words;
  {
        int n;
        long *source,*dest;
        
        source = orig;
        dest = new;
        for (n = words; n ; --n) /* Loop for number of words */
          *(dest++) = *(source++); /* Copy word */
  }

compare(orig, new, words) /* Compare memory */
  long *orig, *new;
  int words;
  {
        int n;
        long *source,*dest;
        int flag = 0;

        graf_mouse(256,&dummy); /* Mouse off */

        source = orig;
        dest = new;
        for (n = words; n ; --n) /* Loop for number of words */
          if (*(dest++) != *(source++)) flag = 1;  /* Compare word */
                                                                                /* Flag = 1 if mismatch */
        graf_mouse(257,&dummy); /* Mouse on */

        return (flag); /* Return results */
  }

exchange(orig, new, words) /* Exchange memory */
  long *orig, *new;
  int words;
  {
        long temp;
        int n;
        long *source,*dest;
        source = orig;
        dest = new;

        for (n = words; n ; --n) /* Loop for number of words */
          {
                temp = *(source); /* Exchange word */
                *(source++) = *(dest);
                *(dest++) = temp;
          }
  }

flip(x1, y1, screen) /* Flip a puzzle piece */
  int x1, y1;
  long *screen;
  {
        long *loc1, temp[4][40];
        int x, y;

        graf_mouse(256,&dummy); /* Mouse off */

        loc1 = screen + y1 * 800 + x1 * xl;  /* Memory location of piece */

        for(y = 0; y < wy; ++y)   /* Loop for pixel height */
          for(x = 0; x < xl; ++x) /* Loop for word width */
                temp[x][y] = *(loc1 + y * yl + x);  /* Store piece */

        for(y = 0; y < wy; ++y) /* Loop for pixel height */
          for( x =0; x < xl; ++x) /* Loop for word width */
                *(loc1 + y * yl + x) = temp[x][wy - y - 1]; /* Restore piece... */
                  /* inverted */
        graf_mouse(257,&dummy); /* Mouse on */
  }

