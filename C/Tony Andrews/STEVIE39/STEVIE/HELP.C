/*
 * STevie - ST editor for VI enthusiasts.    ...Tim Thompson...twitch!tjt...
 */

#include <ctype.h>
#include "stevie.h"

static int helprow;

help()
{
	windclear();
	windgoto(helprow=0,0);
longline("\
\n\
   Cursor movement commands\n\
   ========================\n\
   control-l         Redraw screen\n\
   control-d         Cursor down 1/2 screen\n\
   control-u         Cursor up 1/2 screen\n\
   control-f         Cursor forward 1 screen\n");
longline("\
   control-b         Cursor back 1 screen\n\
   control-g         Give info on file\n\
\n\
      h              Cursor left 1 char\n\
      j              Cursor down 1 char\n\
      k              Cursor up 1 char\n");
longline("\
      l              Cursor right 1 char\n\
      $              Cursor to end of line\n\
      ^ -or- 0       Cursor to beginning of line\n\
      b              Cursor back 1 word\n");
longline("\
      w              Cursor forward 1 word\n\
      [#]G           Goto line # (or last line if no #)\n\
\n\
                                               <Press space bar to continue>\n\
                                               <Any other key will quit>");
	windrefresh();
	if ( vgetc() != ' ' )
		return;
	windclear();
	windgoto(helprow=0,0);
longline("\
\n\
    Modification commands\n\
    =====================\n\
    x           Delete 1 char\n\
    dw          Delete 1 word\n\
    D           Delete rest of line\n\
    [#]dd       Delete 1 (or #) lines\n\
    C           Change rest of line\n");
longline("\
    cw          Change word\n\
    cc          Change line\n\
    r           Replace single character\n\
    [#]yy       Yank 1 (or #) lines\n\
    p           Insert last yanked or deleted line(s)\n");
longline("\
    P              below (p) or above (P) current line\n\
    J           Join current and next line\n\
    [#]<<          Shift line left 1 (or #) tabs\n\
    [#]>>          Shift line right 1 (or #) tabs\n\
    i           Enter Insert mode (<ESC> to exit)\n");
longline("\
    a           Append (<ESC> to exit) \n\
    o           Open line (<ESC> to exit)\n\
\n\
                                               <Press space bar to continue>\n\
                                               <Any other key will quit>");
	windrefresh();
	if ( vgetc() != ' ' )
		return;
	windclear();
	windgoto(helprow=0,0);
longline("\
\n\
    Miscellaneous\n\
    =============\n\
    .           Repeat last insert or delete\n\
    u           Undo last insert or delete\n\
    /str/       Search for 'str'\n\
    ?str?       Search backward for 'str'\n");
longline("    n           Repeat previous search\n\
    :.=         Print current line number\n\
    :$=         Print number of lines in file\n\
    H		Help\n\
\n\
    File manipulation\n\
    =================\n");
longline("\
    :w          Write file\n\
    :wq         Write and quit\n\
    :e {file}   Edit a new file\n\
    :e!         Re-read current file\n\
    :f          Print file into (current line and total # of lines)\n");
longline("\
    :f {file}   Change current file name\n\
    :q          Quit\n\
    :q!         Quit (no save)\n\
\n\
                                                     <Press any key>");
	windrefresh();
	vgetc();
}

longline(p)
char *p;
{
	char *s;

	for ( s=p; *s; s++ ) {
		if ( *s == '\n' )
			windgoto(++helprow,0);
		else
			windputc(*s);
	}
}
