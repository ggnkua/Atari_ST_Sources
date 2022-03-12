/*
   NOTE: This file will not be in later versions of GEM-DEU, as all
   menus will be handled with the standard GEM library calls. 

   Menu utilities by Rapha‰l Quinet <quinet@montefiore.ulg.ac.be>
   Drop-down menus by Dewi Morgan <d.morgan@bradford.ac.uk>

   You are allowed to use any parts of this code in another program, as
   long as you give credits to the authors in the documentation and in
   the program itself.  Read the file README.1ST for more information.

   This program comes with absolutely no warranty.

   MENUS.C - Simple menus for DEU (or other programs).
*/

/* the includes */
#include "deu.h"


/*
   draws a line of text in a menu
*/

void DisplayMenuText( short x0, short y0, short line, char *text, short highlightnum, Bool shownumbers)
{
   char h[ 2];

   if (UseMouse)
      HideMousePointer();
   if (shownumbers)
   {
      DrawScreenText( x0 + 26, y0 + 8 + line * 10, "- %s", text);
      SetColor( WHITE);
      if (line < 9)
	 DrawScreenText( x0 + 10, y0 + 8 + line * 10, "%d", line + 1, text);
      else
	 DrawScreenText( x0 + 10, y0 + 8 + line * 10, "%c", line + 56, text);
   }
   else
   {
      if (highlightnum > 0)
      {
	 DrawScreenText( x0 + 10, y0 + 8 + line * 10, text);
	 SetColor( WHITE);
	 h[ 0] = text[ highlightnum - 1];
	 h[ 1] = '\0';
	 DrawScreenText( x0 + 2 + highlightnum * 8, y0 + 8 + line * 10, h);
      }
      else
      {
	 SetColor(8);
	 DrawScreenText( x0 + 10, y0 + 8 + line * 10, text);
      }
   }
   if (UseMouse)
      ShowMousePointer();
}



/*
   display and execute a menu
*/

short DisplayMenuArray( short x0, short y0, char *menutitle, short numitems, short *okkeys, char *menustr[ 30], short highlight[ 30])
{
 short maxlen, line, oldline;
 Bool ok;
 short key, buttons, oldbuttons;

 /* compute maxlen */
 if (menutitle)
     maxlen = strlen( menutitle) - 2;
   else
     maxlen = 1;
 for (line = 0; line < numitems; line++)
      if (strlen( menustr[ line]) > maxlen)
          maxlen = strlen( menustr[ line]);

 /* display the menu */
 if (UseMouse) HideMousePointer();
 if (x0 < 0) x0 = (ScrMaxX - maxlen * 8 - (okkeys ? 19 : 53)) / 2;
 if (y0 < 0) y0 = (ScrMaxY - numitems * 10 - (menutitle ? 28 : 12)) / 2;
 if (x0 > ScrMaxX - maxlen * 8 - (okkeys ? 19 : 53))
     x0 = ScrMaxX - maxlen * 8 - (okkeys ? 19 : 53);

 DrawScreenBox3D( x0, y0, x0 + maxlen * 8 + (okkeys ? 19 : 53), y0 + numitems * 10 + (menutitle ? 28 : 12));
 SetColor( YELLOW);
 if (menutitle) DrawScreenText( x0 + 10, y0 + 8, menutitle);
 if (UseMouse) ShowMousePointer();

 for (line = 0; line < numitems; line++)
     {
      SetColor( BLACK);
      DisplayMenuText( x0, y0 + (menutitle ? 16 : 0), line, menustr[ line], highlight[ line], !okkeys);
     }
 oldline = -1;
 line = 0;
 oldbuttons = 0x0000;
 ok = FALSE;

 while (! ok)
   {
    if (UseMouse)
       {
        GetMouseCoords( &PointerX, &PointerY, &buttons);
        /* right button = cancel */
        if ((buttons & 0x0002) == 0x0002)
           {
            line = -1;
            ok = TRUE;
           }      /* left button = select */
         else if (buttons == 0x0001 && PointerX >= x0 && PointerX <= x0 + maxlen * 8 + 53)
                  line = (PointerY - y0 - (menutitle ? 24 : 8)) / 10;
                  /* release left button = accept selection */
         else if (buttons == 0x0000 && oldbuttons == 0x0001)
                  ok = TRUE;
        oldbuttons = buttons;
       }
    if (bioskey( 1))
       {
        key = bioskey( 0);

        /* enter key = accept selection */
        if ((key & 0x00FF) == 0x000D) ok = TRUE;
           /* escape key = cancel */
        else if ((key & 0x00FF) == 0x001B)
                {
                 line = -1;
                 ok = TRUE;
                }
           /* up arrow = select previous line */
        else if ((key & 0xFF00) == 0x4800)
                {
                 if (line > 0) line--;
                     else line = numitems - 1;
                }
           /* down arrow = select next line */
        else if ((key & 0xFF00) == 0x5000)
                {
                 if (line < numitems - 1) line++;
                     else line = 0;
                }
           /* home = select first line */
        else if ((key & 0xFF00) == 0x4700) line = 0;
           /* end = select last line */
        else if ((key & 0xFF00) == 0x4F00) line = numitems - 1;
           /* pgup = select line - 5 */
        else if ((key & 0xFF00) == 0x4900)
                {
                 if (line >= 5) line -= 5;
                     else line = 0;
                }
           /* pgdn = select line + 5 */
        else if ((key & 0xFF00) == 0x5100)
                {
                 if (line < numitems - 5) line += 5;
                     else line = numitems - 1;
                }
           /* number or alphabetic key = enter selection */
        else if ((key & 0x00FF) >= '1' && (key & 0x00FF) <= '9' && ((key & 0x00FF) - '1') < numitems)
                {
                 line = (key & 0x00FF) - '1';
                 ok = TRUE;
                }
        else if ((key & 0x00FF) >= 'A' && (key & 0x00FF) <= 'Z' && ((key & 0x00FF) - 'A' + 9) < numitems)
                {
                 line = (key & 0x00FF) - 'A' + 9;
                 ok = TRUE;
                }
        else if ((key & 0x00FF) >= 'a' && (key & 0x00FF) <= 'z' && ((key & 0x00FF) - 'a' + 9) < numitems)
                {
                 line = (key & 0x00FF) - 'a' + 9;
                 ok = TRUE;
                }
           /* check the list of "hot keys" */
        else if (okkeys)
                {
                 for (line = 0; line < numitems; line++)
                      if (toupper( key) == okkeys[ line]) break;
                 if (line < numitems) ok = TRUE;
                     else
                       {
                        line = oldline;
                        Beep();
                       }
                }
           /* other key */
        else Beep();
       }
    if (line != oldline)
       {
        if (oldline >= 0 && oldline < numitems)
           {
            SetColor( BLACK);
            DisplayMenuText( x0, y0 + (menutitle ? 16 : 0), oldline, menustr[ oldline], highlight[ oldline], !okkeys);
           }
        if (line >= 0 && line < numitems)
           {
            SetColor( WHITE);
            DisplayMenuText( x0, y0 + (menutitle ? 16 : 0), line, menustr[ line], highlight[ line], !okkeys);
           }
        oldline = line;
       }
   }
 if (line >= 0 && line < numitems) return (line + 1);
     else return 0;
}



/*
   display and execute a menu defined with variable arguments
*/

short DisplayMenu( short x0, short y0, char *menutitle, ...)
{
   va_list args;
   short     num;
   char   *menustr[ 30];
   short     dummy[ 30];

   /* put the va_args in the menustr table */
   num = 0;
   va_start( args, menutitle);
   while ((num < 30) && ((menustr[ num] = va_arg( args, char *)) != NULL))
      num++;
   va_end( args);

   /* display the menu */
   return DisplayMenuArray( x0, y0, menutitle, num, NULL, menustr, dummy);
}



/*
   display and execute a dropdown menu (returns a key code)
*/

short PullDownMenu( short x0, short y0, ...)
{
   va_list args;
   short     num;
   char   *menustr[ 30];
   short     retnkeys[ 30];
   short     permkeys[ 30];
   short     highlight[ 30];

printf("in pulldown\n");

   /* put the va_args in the menustr table and the two strings */
   num = 0;
   va_start( args, y0);
   while ((num < 30) && ((menustr[ num] = va_arg( args, char *)) != NULL))
   {/*
      if ((retnkeys[ num] = va_arg( args, short)) == NULL)
	 ProgError( "BUG: PullDownMenu() called with invalid arguments");
      if ((permkeys[ num] = va_arg( args, short)) == NULL)
	 ProgError( "BUG: PullDownMenu() called with invalid arguments");
      if ((highlight[ num] = va_arg( args, short)) == NULL)
	 ProgError( "BUG: PullDownMenu() called with invalid arguments");*/
      num++;
printf("while %d\n",num);
   }
   va_end( args);

   /* display the menu */
   num = DisplayMenuArray( x0, y0, NULL, num, permkeys, menustr, highlight);

printf("End of pull-down\n");

   if (num >= 1)
      return retnkeys[ num - 1]; /* return a valid key */
   else
      return 0; /* return an invalid key */
}



/*
   display the integer input box
*/

short InputInteger( short x0, short y0, short *valp, short minv, short maxv)
{
   short  key, val;
   Bool neg, ok, firstkey;

   DrawScreenBoxHollow( x0, y0, x0 + 61, y0 + 13);
   neg = (*valp < 0);
   val = neg ? -(*valp) : *valp;
   firstkey = TRUE;
   for (;;)
   {
      ok = (neg ? -val : val) >= minv && (neg ? -val : val) <= maxv;
      SetColor( BLACK);
      DrawScreenBox( x0 + 1, y0 + 1, x0 + 60, y0 + 12);
      if (ok)
	 SetColor( WHITE);
      else
	 SetColor(7);
      if (neg)
	 DrawScreenText( x0 + 3, y0 + 3, "-%d", val);
      else
	 DrawScreenText( x0 + 3, y0 + 3, "%d", val);
      key = bioskey( 0);
      if (firstkey && (key & 0x00FF) > ' ')
      {
	 val = 0;
	 neg = FALSE;
      }
      firstkey = FALSE;
      if (val < 3275 && (key & 0x00FF) >= '0' && (key & 0x00FF) <= '9')
	 val = val * 10 + (key & 0x00FF) - '0';
      else if (val > 0 && (key & 0x00FF) == 0x0008)
	 val = val / 10;
      else if (neg && (key & 0x00FF) == 0x0008)
	 neg = FALSE;
      else if ((key & 0x00FF) == '-')
	 neg = !neg;
      else if (ok && (key & 0x00FF) == 0x000D)
	 break; /* return "val" */
      else if ((key & 0xFF00) == 0x4800 || (key & 0xFF00) == 0x5000 ||
	       (key & 0xFF00) == 0x4B00 || (key & 0xFF00) == 0x4D00 ||
	       (key & 0x00FF) == 0x0009 || (key & 0xFF00) == 0x0F00)
	 break; /* return "val", even if not valid */
      else if ((key & 0x00FF) == 0x001B)
      {
         neg = FALSE;
	 val = -32767; /* return a value out of range */
	 break;
      }
      else
	 Beep();
   }
   if (neg)
      *valp = -val;
   else
      *valp = val;
   return key;
}



/*
   ask for an integer value and check for minimum and maximum
*/

short InputIntegerValue( short x0, short y0, short minv, short maxv, short defv)
{
   short  val, key;
   char prompt[ 80];

   if (UseMouse)
      HideMousePointer();
   sprintf( prompt, "Enter a decimal number between %d and %d:", minv, maxv);
   if (x0 < 0)
      x0 = (ScrMaxX - 25 - 8 * strlen( prompt)) / 2;
   if (y0 < 0)
      y0 = (ScrMaxY - 55) / 2;
   DrawScreenBox3D( x0, y0, x0 + 25 + 8 * strlen( prompt), y0 + 55);
   SetColor( WHITE);
   DrawScreenText( x0 + 10, y0 + 8, prompt);
   val = defv;
   while (((key = InputInteger( x0 + 10, y0 + 28, &val, minv, maxv)) & 0x00FF) != 0x000D && (key & 0x00FF) != 0x001B)
      Beep();
   if (UseMouse)
      ShowMousePointer();
   return val;
}



/*
   ask for a name in a given list and call a function (for displaying objects, etc.)

   Arguments:
      x0, y0  : where to draw the box.
      prompt  : text to be displayed.
      listsize: number of elements in the list.
      list    : list of names (picture names, level names, etc.).
      listdisp: number of lines that should be displayed.
      name    : what we are editing...
      width   : \ width and height of an optional window where a picture
      height  : / can be displayed (used to display textures, sprites, etc.).
      hookfunc: function that should be called to display a picture.
		(x1, y1, x2, y2 = coordinates of the window in which the
		 picture must be drawn, name = name of the picture).
*/

void InputNameFromListWithFunc( short x0, short y0, char *prompt, short listsize, char **list, short listdisp, char *name, short width, short height, void (*hookfunc)(short px1, short py1, short px2, short py2, char *name))
{
   short  key, n, l;
   short  x1, y1, x2, y2;
   short  maxlen;
   Bool ok, firstkey;

   /* compute maxlen */
   maxlen = 1;
   for (n = 0; n < listsize; n++)
      if (strlen( list[ n]) > maxlen)
	 maxlen = strlen( list[ n]);
   for (n = strlen(name) + 1; n <= maxlen; n++)
      name[ n] = '\0';
   /* compute the minimum width of the dialog box */
   l = maxlen;
   if (strlen( prompt) > l + 12)
      l = strlen( prompt) - 12;
   l = l * 8 + 110;
   x1 = l + 3;
   y1 = 10 + 1;
   if (width > 0)
      l += 10 + width;
   if (height > 65)
      n = height + 20;
   else
      n = 85;
   if (x0 < 0)
      x0 = (ScrMaxX - l) / 2;
   if (y0 < 0)
      y0 = (ScrMaxY - n) / 2;
   x1 += x0;
   y1 += y0;
   if (x1 + width - 1 < ScrMaxX)
      x2 = x1 + width - 1;
   else
      x2 = ScrMaxX;
   if (y1 + height - 1 < ScrMaxY)
      y2 = y1 + height - 1;
   else
      y2 = ScrMaxY;
   /* draw the dialog box */
   DrawScreenBox3D( x0, y0, x0 + l, y0 + n);
   DrawScreenBoxHollow( x0 + 10, y0 + 28, x0 + 101, y0 + 41);
   DrawScreenText( x0 + 10, y0 + 8, prompt);
   if (width > 0)
   {
      DrawScreenBox( x1, y1, x2 + 1, y2 + 1);
      SetColor(8);
      DrawScreenBox( x1 - 1, y1 - 1, x2, y2);
   }
   firstkey = TRUE;
   for (;;)
   {
      /* test if "name" is in the list */
      for (n = 0; n < listsize; n++)
	 if (strcmp( name, list[ n]) <= 0)
	    break;
      ok = n < listsize ? !strcmp( name, list[ n]) : FALSE;
      if (n > listsize - 1)
	 n = listsize - 1;
      /* display the "listdisp" next items in the list */
      SetColor(7);
      DrawScreenBox( x0 + 110, y0 + 30, x0 + 110 + 8 * maxlen, y0 + 30 + 10 * listdisp);
      SetColor( BLACK);
      for (l = 0; l < listdisp && n + l < listsize; l++)
		{
		 DrawScreenText( x0 + 110, y0 + 30 + l * 10, list[ n + l]);
		}
      l = strlen( name);
      DrawScreenBox( x0 + 11, y0 + 29, x0 + 100, y0 + 40);
      if (ok)
		 SetColor( WHITE);
      else
		 SetColor(7);
      DrawScreenText( x0 + 13, y0 + 31, name);
      /* call the function to display the picture, if any */
      if (hookfunc)
      {
	 /* clear the window */
	 SetColor( BLACK);
	 DrawScreenBox( x1, y1, x2, y2);
	 /* display the picture "name" */
	 hookfunc( x1, y1, x2, y2, name);
      }
      /* process user input */
      key = bioskey( 0);
      if (firstkey && (key & 0x00FF) > ' ')
      {
	 for (l = 0; l <= maxlen; l++)
	    name[ l] = '\0';
	 l = 0;
      }
      firstkey = FALSE;
      if (l < maxlen && (key & 0x00FF) >= 'a' && (key & 0x00FF) <= 'z')
      {
	 name[ l] = key & 0x00FF + 'A' - 'a';
	 name[ l + 1] = '\0';
      }
      else if (l < maxlen && (key & 0x00FF) > ' ')
      {
	 name[ l] = key & 0x00FF;
	 name[ l + 1] = '\0';
      }
      else if (l > 0 && (key & 0x00FF) == 0x0008)
	 name[ l - 1] = '\0';
      else if (n < listsize - 1 && (key & 0xFF00) == 0x5000)
	 strcpy(name, list[ n + 1]);
      else if (n > 0 && (key & 0xFF00) == 0x4800)
	 strcpy(name, list[ n - 1]);
      else if (n < listsize - listdisp && (key & 0xFF00) == 0x5100)
	 strcpy(name, list[ n + listdisp]);
      else if (n > 0 && (key & 0xFF00) == 0x4900)
      {
	 if (n > listdisp)
	    strcpy(name, list[ n - listdisp]);
	 else
	    strcpy(name, list[ 0]);
      }
      else if ((key & 0xFF00) == 0x4F00)
	 strcpy(name, list[ listsize - 1]);
      else if ((key & 0xFF00) == 0x4700)
	 strcpy(name, list[ 0]);
      else if ((key & 0x00FF) == 0x0009)
	 strcpy(name, list[ n]);
      else if (ok && (key & 0x00FF) == 0x000D)
	 break; /* return "name" */
      else if ((key & 0x00FF) == 0x001B)
      {
	 name[ 0] = '\0'; /* return an empty string */
	 break;
      }
      else
	 Beep();
   }
}



/*
   ask for a name in a given list
*/

void InputNameFromList( short x0, short y0, char *prompt, short listsize, char **list, char *name)
{
   if (UseMouse)
      HideMousePointer();
   InputNameFromListWithFunc( x0, y0, prompt, listsize, list, 5, name, 0, 0, NULL);
   if (UseMouse)
      ShowMousePointer();
}



/*
   ask for a filename
*/

void InputFileName( short x0, short y0, char *prompt, short maxlen, char *filename)
{
 short ok, i;
 char path[128];

 if (strlen(filename)>13)
    {
     strcpy(path,filename);
     for (i=strlen(path); (path[i]!='\\' && i>0); i--);
     strcpy(&path[i+1],"*.*");
    }
  else strcpy(path,"E:\\BADMOOD\\*.*");
 fsel_input(path,filename,&ok);
 if (!ok)
    {
     filename[0]='\0';
     return;
    }
 for (i=0; path[i]!=0; i++);
 for (; (path[i]!='\\' && i>0); i--);
      path[i+1]='\0';
 strcat(path, filename); 
 strcpy(filename,path);
}



/*
   ask for confirmation (prompt2 may be NULL)
*/

Bool Confirm( short x0, short y0, char *prompt1, char *prompt2)
{
   short key;
   short maxlen = 46;

   if (UseMouse)
      HideMousePointer();
   if (strlen( prompt1) > maxlen)
      maxlen = strlen( prompt1);
   if (prompt2 != NULL && strlen( prompt2) > maxlen)
      maxlen = strlen( prompt2);
   if (x0 < 0)
      x0 = (ScrMaxX - 22 - 8 * maxlen) / 2;
   if (y0 < 0)
      y0 = (ScrMaxY - (prompt2 ? 53 : 43)) / 2;
   DrawScreenBox3D( x0, y0, x0 + 22 + 8 * maxlen, y0 + (prompt2 ? 53 : 43));
   SetColor( WHITE);
   DrawScreenText( x0 + 10, y0 + 8, prompt1);
   if (prompt2 != NULL)
      DrawScreenText( x0 + 10, y0 + 18, prompt2);
   SetColor( YELLOW);
   DrawScreenText( x0 + 10, y0 + (prompt2 ? 38 : 28), "Press Y to confirm, or any other key to cancel");
   key = bioskey( 0);
   if (UseMouse)
      ShowMousePointer();
   return ((key & 0x00FF) == 'Y' || (key & 0x00FF) == 'y');
}



/*
   display a notification and wait for a key (prompt2 may be NULL)
*/

void Notify( short x0, short y0, char *prompt1, char *prompt2)
{
   short maxlen = 30;

   if (UseMouse)
      HideMousePointer();
   if (strlen( prompt1) > maxlen)
      maxlen = strlen( prompt1);
   if (prompt2 != NULL && strlen( prompt2) > maxlen)
      maxlen = strlen( prompt2);
   if (x0 < 0)
      x0 = (ScrMaxX - 22 - 8 * maxlen) / 2;
   if (y0 < 0)
      y0 = (ScrMaxY - (prompt2 ? 53 : 43)) / 2;
   DrawScreenBox3D( x0, y0, x0 + 22 + 8 * maxlen, y0 + (prompt2 ? 53 : 43));
   SetColor( WHITE);
   DrawScreenText( x0 + 10, y0 + 8, prompt1);
   if (prompt2 != NULL)
      DrawScreenText( x0 + 10, y0 + 18, prompt2);
   SetColor( YELLOW);
   DrawScreenText( x0 + 10, y0 + (prompt2 ? 38 : 28), "Press any key to continue...");
   bioskey( 0);;
   if (UseMouse)
      ShowMousePointer();
}



/*
   clear the screen and display a message
*/

void DisplayMessage( short x0, short y0, char *msg, ...)
{
   char prompt[ 120];
   va_list args;

   va_start( args, msg);
   vsprintf( prompt, msg, args);
   va_end( args);

   if (UseMouse)
      HideMousePointer();
   ClearScreen();
   if (x0 < 0)
      x0 = (ScrMaxX - 40 - 8 * strlen( prompt)) / 2;
   if (y0 < 0)
      y0 = (ScrMaxY - 40) / 2;
   DrawScreenBox3D( x0, y0, x0 + 40 + 8 * strlen( prompt), y0 + 40);
   DrawScreenText( x0 + 20, y0 + 17, prompt);
   if (UseMouse)
      ShowMousePointer();
}



/*
   let's make the user angry...
*/

void NotImplemented()
{
 form_alert(1,"[1][This function is not implemented yet!][Sorry]");
}


/* end of file */
