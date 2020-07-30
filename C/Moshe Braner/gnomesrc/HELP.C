/*
 * This file supplies the help facilities.
 * By Moshe braner, 8803.
 */
#include	<stdio.h>
#include	"ed.h"

#if HELP

#if AtST

char *help_menu[] = {
" ",
"\t\tGNOME version 2.1",
" ",
"\tCursor control\t\t\tInsert and delete",
"\tMoving and copying\t\tSearching",
"\tTransposition, caps\t\tUnprintable characters",
"\tBuffers\t\t\t\tDisk Files",
"\tWindow control\t\t\tEntering strings",
"\tAlternate character set\t\tOther stuff",
"\tFormatting\t\t\tQuitting GNOME",
""
};

char *curs_ctrl[] = {
" ",
"\tKeypad arrows: move cursor by characters",
"\tShift horizontal arrows: move by words",
#if EXTRA
"\tShift vertical arrows: scroll window",
"\tEsc vertical arrows: move by paragraph",
#endif
"\tEsc horizontal arrows: beginning & end of line",
"\tF8:  scroll up     F9:  scroll down",
"\tF10:  set MARK at current cursor position",
"\tAlt-F10  (or Alt-X):  exchange mark and cursor",
"\tEsc-Home: begining of file   Control-Home: end of file",
""
};

char *insdel[] = {
" ",
"\tBackspace: Delete previous char,  Delete: Delete current char.",
"\t  With Shift or Control: Delete to beginning or end of line.",
#if EXTRA
"\t  Preceded by esc: Kill word by word.",
#endif
"\tInsert:  Insert blank line.",
#if EXTRA
"\t  With Shift or control: Kill blank lines around cursor.",
#endif
"\tAlt-F4  (or ^W):  Cut (kill, wipe) region between mark and cursor.",
"\tReturn:  Insert a newline.",
"\tControl Return:  Insert a newline and indent.",
"\tTab: Insert a tab character (with argument: set tab size).",
"\t^X Delete: make Delete work like Backspace",
""
};

char *search_cmds[] = {
" ",
"\tF7  Search forward. Type in a string to be searched for, end it with",
"\t    <Return>.  A '.' matches any one character, ^W matches any amount",
"\t    of white space (including none).  A '!' means NOT the next char.",
"\tF6  As above, but Reverse search from cursor position back.",
"\tAlt-C  Toggle case-sensitivity in searches.",
" ",
"\tAlt-G  or Esc-G  Goto line by number (precede with argument)",
"\tAlt-F7 or Alt-)  Search forward for complementing brace",
"\tAlt-F6 or Alt-(  Same - backwards    ('brace': (), [], {})",
""
};

char *transp_cap[] = {
" ",
"\t^T      Transpose characters    Alt-T   Transpose lines",
#if EXTRA
" ",
"\tEsc U   UPPERCASE word          Esc L    lowercase word",
"\tEsc C   Capitalize word",
"\t^X^U  Convert region into Uppercase",
"\t^X^L  Convert region into Lowercase",
#endif
" ",
"\t^Q or Esc Q   Quote next char as-is (to enter ctrl chars)",
"\tAlt-A         Enter next char with MSB set (graphics chars)",
""
};

char *move_cmds[] = {
" ",
"\tF4      (or ^K)     Kill to end of line (& save in Kill Buffer)",
"\tAlt-F4  (or ^W)     Cut (kill) region, save in Kill Buffer",
"\tAlt-F5  (or Alt-W)  Copy region to Kill Buffer",
"\tF5      (or ^Y)     Paste contents of Kill Buffer back, at cursor",
"\tUndo      Undo the Kill (or Paste) just done",
"\tAlt-Undo  Flush Kill Buffer into a buffer called '[]'",
""
};

char *wind_cmds[] = {
" ",
"Many WINDOWS may be active at once on the screen.  Windows may show",
"different parts of one buffer, or different buffers.",
" ",
"Alt-2  Split current window in two   Alt-1  Remove all but current window",
"Alt-N  Cursor to next window         Alt-P  Cursor to previous window",
#if EXTRA
"Alt-^   Enlarge current window",
"Shift vertical arrows: Scroll window one line",
#endif
"Alt-F9  Scroll down, other window    Alt-F8  Scroll up, other window",
"Home  Scroll current line to top (shft: bot) (or <argument>) position",
""
};

char *buf_cmds[] = {
" ",
"A BUFFER is a named area containing a document being edited.  Many buffers",
"may be activated at once.  Each buffer has a name, which is typically the",
"lowercased disk filename of the document it contains",
"F2 (or Alt-B)  Switch to another buffer, by name (default: previous one)",
"Alt-K  Kill a non-displayed buffer",
"^X^B   Enter a new name for current buffer",
"^X^F   Enter a new default File name for buffer",
"^X^H   Print buffer to parallel or serial port",
"Shift-Help: List current buffers",
""
};

char *disk_cmds[] = {
"F3      Read file into current buffer, erasing its previous contents.",
"         No new buffer will be created. Flag as editable.",
"Alt-F2  (Also Alt-V.)  Visit a file.  Read it into a new buffer.",
"         Flag as view-only (Alt-E to edit).",
"Alt-F3  Write current buffer to disk.  Type a filename at the",
"         prompt, or hit Return for the default.",
"         Existing disk file of that name will be overwritten.",
"Alt-S   Save current buffer to disk, using the buffer's filename.",
"Alt-D   Directory listing.",
"^X !    Change default path prefix.",
""
};

char *formatting[] = {
" ",
"\tAlt-R    Set right margin (fill column)",
"\tAlt-L    Set left margin",
"\tAlt-F    (Re)Format paragraph so that text lies between margins",
"\t         (with argument: double spaced)",
" ",
"\tEsc#-<tab> Set tab spacing to # characters between tabs stops",
""
};

char *quitting[] = {
" ",
"Invoking GNOME:  gnome [options][-h for help] [file(s)]",
" ",
"\t^C     Exit GNOME",
"\t^Z     Save this buffer if changed, then Exit GNOME",
" ",
"\tAlt-7  Play back log file (stop logging, replay it now)",
""
};

char *other_cmds[] = {
" ",
"\tUndo   Cancel current command and return to top level of processing.",
"\t       (Also undoes a kill, cut or paste.)",
"\tEsc #  (or ^U #, with default of 4) - Enter numerical argument.",
"\t       ('-' = -1) (Repeats the next command that many times.)",
"\tAlt-F1 (or Alt-M)  Begin/End a macro definition: store keystrokes",
"\tF1     Execute the defined macro",
"\tAlt-=  Position report -- displays line number, column, ASCII code",
"\tAlt-E  Toggle between edit & view-only modes",
"\tAlt-I  Toggle between insert & overstrike modes",
"\tAlt-Q  Toggle visibility of tabs, spaces & newlines",
""
};

char *alt_chars[] = {
"\t ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_    (Alt-A Control-)",
"\t ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_",	/* these should be control chars */
" ",
"\t !\"#$%&'()*+,-./0123456789:;<=>?    (Alt-A)",
"\t !\"#$%&'()*+,-./0123456789:;<=>?",	/* these should have the MSB set */
" ",
"\t@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_",
"\t@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_",
" ",
"\t`abcdefghijklmnopqrstuvwxyz{|}~",
"\t`abcdefghijklmnopqrstuvwxyz{|}~",
""
};

char *enter_str[] = {
" ",
" When entering filenames, buffer names, or search strings:",
" ",
" Up and down arrows scroll through defaults,",
" Screen editing of string is possible with the usual keys,",
" <Return> enters the string as displayed,",
" <Undo> aborts the operation,",
" \'\\\' or <Esc> enters the next character verbatim",
" (in search strings, for \'.\', \'!\', and control chars).",
""
};

#endif AtST

#if MSDOS

char *help_menu[] = {
" ",
"\t\tGNOME version 2.1",
" ",
"\tCursor control\t\t\tInsert and delete",
"\tMoving and copying\t\tSearching",
"\tTransposition, caps\t\tUnprintable characters",
"\tBuffers\t\t\t\tDisk Files",
"\tWindow control\t\t\tEntering strings",
"\tAlternate character set\t\tOther stuff",
"\tFormatting\t\t\tQuitting GNOME",
""
};

char *curs_ctrl[] = {
" ",
"\tKeypad arrows: move cursor by characters",
"\tControl horizontal arrows: move by words",
#if EXTRA
"\tEsc vertical arrows: move by paragraph",
#endif
"\tEsc horizontal arrows: beginning & end of line",
"\tPgUp:  scroll up     PgDn:  scroll down",
"\tF9:  set MARK at current cursor position",
"\tAlt-F9  (or Alt-X):  exchange mark and cursor",
"\tCtrl-Home: begining of file   Ctrl-End: end of file",
""
};

char *insdel[] = {
" ",
"\tBackspace: Delete previous char,  Del: Delete current char.",
#if EXTRA
"\t  Preceded by esc: Kill word by word.",
#endif
"\tInsert:  Insert blank line.",
#if EXTRA
"\t^X^O   Kill blank lines around cursor",
#endif
"\tAlt-F5  (or ^W):  Cut (kill, wipe) region between mark and cursor.",
"\tEnter:       Insert a newline.",
"\tCtrl-Enter:  Insert a newline and indent.",
"\tTab: Insert a tab character (with argument: set tab size).",
"\t^X Del: make Del work like Backspace",
""
};

char *search_cmds[] = {
" ",
"\tF8  Search forward. Type in a string to be searched for, end it with",
"\t    <Return>.  A '.' matches any one character, ^W matches any amount",
"\t    of white space (including none).  A '!' means NOT the next char.",
"\tF7  As above, but Reverse search from cursor position back.",
"\tAlt-C  Toggle case-sensitivity in searches.",
" ",
"\tAlt-G  or Esc-G  Goto line by number (precede with argument)",
"\tAlt-F8 or Alt-)  Search forward for complementing brace",
"\tAlt-F7 or Alt-(  Same - backwards    ('brace': (), [], {})",
""
};

char *transp_cap[] = {
" ",
"\t^T      Transpose characters    Alt-T   Transpose lines",
#if EXTRA
" ",
"\tEsc U   UPPERCASE word          Esc L    lowercase word",
"\tEsc C   Capitalize word",
"\t^X^U  Convert region into Uppercase",
"\t^X^L  Convert region into Lowercase",
#endif
" ",
"\t^Q or Esc Q   Quote next char as-is (to enter ctrl chars)",
"\tAlt-A         Enter next char with MSB set (graphics chars)",
""
};

char *move_cmds[] = {
" ",
"\tF5      (or ^K)     Kill to end of line (& save in Kill Buffer)",
"\tAlt-F5  (or ^W)     Cut (kill) region, save in Kill Buffer",
"\tAlt-F6  (or Alt-W)  Copy region to Kill Buffer",
"\tF6      (or ^Y)     Paste contents of Kill Buffer back, at cursor",
"\tF2      Undo the Kill (or Paste) just done",
"\tAlt-F2  Flush Kill Buffer into a buffer called '[]'",
""
};

char *wind_cmds[] = {
" ",
"Many WINDOWS may be active at once on the screen.  Windows may show",
"different parts of one buffer, or different buffers.",
" ",
"Alt-2  Split current window in two   Alt-1  Remove all but current window",
"Alt-N  Cursor to next window         Alt-P  Cursor to previous window",
#if EXTRA
"Alt-^   Enlarge current window",
#endif
"Ctrl-PgDn Scroll down, other window    Ctrl-PgUp  Scroll up, other window",
"Home: Scroll current line to top (End: bot) (or <argument>) position)",
""
};

char *buf_cmds[] = {
" ",
"A BUFFER is a named area containing a document being edited.  Many buffers",
"may be activated at once.  Each buffer has a name, which is typically the",
"lowercased disk filename of the document it contains",
"F3 (or Alt-B)  Switch to another buffer, by name (default: previous one)",
"Alt-K  Kill a non-displayed buffer",
"^X^B   Enter a new name for current buffer",
"^X^F   Enter a new default File name for buffer",
"^X^H   Print buffer to parallel or serial port",
"Alt-F1 List current buffers",
""
};

char *disk_cmds[] = {
"F4      Read file into current buffer, erasing its previous contents.",
"         No new buffer will be created. Flag as editable.",
"Alt-F3  (Also Alt-V.)  Visit a file.  Read it into a new buffer.",
"         Flag as view-only (Alt-E to edit).",
"Alt-F4  Write current buffer to disk.  Type a filename at the",
"         prompt, or hit Return for the default.",
"         Existing disk file of that name will be overwritten.",
"Alt-S   Save current buffer to disk, using the buffer's filename.",
"Alt-D   Exit temporarily to MS-DOS (spawn a COMMAND.COM shell)",
"Alt-Z   Issue an MS-DOS command (run COMMAND.COM on it)",
""
};

char *formatting[] = {
" ",
"\tAlt-R    Set right margin (fill column)",
"\tAlt-L    Set left margin",
"\tAlt-F    (Re)Format paragraph so that text lies between margins",
"\t         (with argument: double spaced)",
" ",
"\tEsc#-<tab> Set tab spacing to # characters between tabs stops",
""
};

char *quitting[] = {
" ",
"Invoking GNOME:  gnome [options][-h for help] [file(s)]",
" ",
"\t^C     Exit GNOME",
"\t^Z     Save this buffer if changed, then Exit GNOME",
" ",
"\tAlt-7  Play back log file (stop logging, replay it now)",
""
};

char *other_cmds[] = {
" ",
"\tF2     Cancel current command and return to top level of processing.",
"\t       (Also undoes a kill, cut or paste.)",
"\tEsc #  (or ^U #, with default of 4) - Enter numerical argument.",
"\t       ('-' = -1) (Repeats the next command that many times.)",
"\tAlt-M  (or Alt-F10)  Begin/End a macro definition: store keystrokes",
"\tF10    Execute the defined macro",
"\tAlt-=  Position report -- displays line number, column, ASCII code",
"\tAlt-E  Toggle between edit & view-only modes",
"\tAlt-I  Toggle between insert & overstrike modes",
"\tAlt-Q  Toggle visibility of tabs, spaces & newlines",
""
};

char *alt_chars[] = {
"\t ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_    (Alt-A Control-)",
"\t ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_    (Alt-A Control-)",
" ",
"\t !\"#$%&'()*+,-./0123456789:;<=>?    (Alt-A)",
"\t !\"#$%&'()*+,-./0123456789:;<=>?",
" ",
"\t@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_",
"\t@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_",
" ",
"\t`abcdefghijklmnopqrstuvwxyz{|}~",
"\t`abcdefghijklmnopqrstuvwxyz{|}~",
""
};

char *enter_str[] = {
" ",
" When entering filenames, buffer names, or search strings:",
" ",
" Up and down arrows scroll through defaults,",
" Screen editing of string is possible with the usual keys,",
" <Return> enters the string as displayed,",
" F2 aborts the operation,",
" \'\\\' or <Esc> enters the next character verbatim",
" (in search strings, for \'.\', \'!\', and control chars).",
""
};

#endif MSDOS

#if (V7 | VMS | CPM)

char *help_menu[] = {
" ",
"       GNOME version 2.1",
" ",
"Quitting GNOME",
"Cursor control        Insert and delete",
"Moving and copying    Searching",
"Transposition, caps   Unprintable characters",
"Buffers               Disk Files",
"Window control        Entering strings",
"Formatting            Other stuff",
""
};

char *curs_ctrl[] = {
" ",
#if VT100
"^F    Forward character    E-F (or PF2)  Forward word       Keypad arrows",
"^B    Backward character   E-B (or PF1)  Backward word       are active!",
#else
"^F    Forward character    E-F   Forward word",
"^B    Backward character   E-B   Backward word",
#endif
"^A    Front of line        ^E    End of line",
"^N    Next line            ^P    Previous line",
#if EXTRA
"E-N   Next paragraph       E-P   Previous paragraph",
#endif
"^V    Scroll down          E-V   Scroll up",
"E-<   Begining of file     E->   End of file",
#if VT100
"E-.   (or PF3)  Set MARK at current cursor position",
#else
"E-.   Set MARK at current cursor position",
#endif
"^X^X  eXchange mark and cursor",
""
};

char *insdel[] = {
" ",
"^H (BS) Delete previous character   ^D (DEL) Delete current character",
#if EXTRA
"E-^H    Delete previous word        E-^D     Delete next word",
#endif
"^O     Open (insert) line",
#if EXTRA
"^X^O   Kill blank lines around cursor",
#endif
"^K     Kill (delete) to end of line (if at end: kill linebreak)",
"^W     Kill (Wipe) region between mark (set using E-.) and cursor",
"^J     Insert a newline and indent",
"^I or <TAB>  Insert a tab character (with argument: set tab size)",
"^X DEL: make DEL work like BS",
""
};

char *search_cmds[] = {
" ",
"E-S  Search forward. Type in a string to be searched for, end it with",
"     <Return>.  A '.' matches any one character, ^W matches any amount",
"     of white space (including none).  A '!' means NOT the next char.",
"E-R  As above, but Reverse search from cursor position back.",
"^X C Toggle case-sensitivity in searches.",
" ",
"E-G   Goto line by number (precede with argument: E-#-E-G)",
"E-)   (or E-}) Search forward for complementing brace",
"E-(   (or E-{) Same - backwards",
""
};

char *transp_cap[] = {
" ",
"^T     Transpose characters    ^X T   Transpose lines",
#if EXTRA
" ",
"E-U    UPPERCASE word          E-L    lowercase word",
"E-C    Capitalize word",
"^X^U   Convert region into Uppercase",
"^X^L   Convert region into Lowercase",
#endif
" ",
"E-Q    Quote next char (to enter ctrl chars into text)",
""
};

char *move_cmds[] = {
" ",
"E-W   Copy region to KILL buffer",
"^Y    Yank contents of KILL buffer back, at cursor",
"^X^Y  Undo the Yank just done",
"E-Y   Flush kill buffer into a buffer called '[]'",
" ",
"Generally, the procedure for copying or moving text is:",
"    1)  Mark a REGION using E-. at beginning and cursor at end.",
"    2)  Delete it (with ^W) or copy it (with E-W) into KILL buffer.",
"    3)  Move cursor to desired location and yank it back (with ^Y).",
""
};

char *wind_cmds[] = {
" ",
"Many WINDOWS may be active at once on the screen.  Windows may show",
"different parts of one buffer, or different buffers.",
" ",
"^X 2   Split current window in two   ^X 1  Remove all but current window",
"^X N   Cursor to next window         ^X P  Cursor to previous window",
#if EXTRA
"^X ^   Enlarge current window",
"^X^N   Scroll window one line down   ^X^P  Scroll one line up",
#endif
"^X V   Scroll down, other window     ^X Z  Scroll up, other window",
"E-!    Scroll current line to top (or <argument> window position)",
""
};

char *buf_cmds[] = {
" ",
"A BUFFER is a named area containing a document being edited.  Many buffers",
"may be activated at once.  Each buffer has a name, which is typically the",
"lowercased disk filename of the document it contains.",
"^X B   Switch to another buffer, by name (default: previous one)",
"^X ?   List current buffers",
"^X K   Kill a non-displayed buffer.",
"^X^B   Enter a new name for buffer",
"^X^F   Enter a new default File name for buffer",
""
};

char *disk_cmds[] = {
" ",
"^X^R  Read file into current buffer, erasing its previous contents.",
"      No new buffer will be created. Flag as editable.",
"^X^V  Visit file: read into a new buffer created from filename.",
"      Flag as view-only.",
"^X S  Save current buffer to disk, using the buffer's filename",
"      as the name of the disk file.  Any disk file of that name",
"      will be overwritten.",
"^X^W  Write current buffer to disk.  Type in a new filename at the",
"      prompt to write to; it will become the current buffer's filename.",
""
};

char *formatting[] = {
" ",
"^X R   Set right margin (fill column)",
"^X L   Set left margin",
"^X F   (Re)Format paragraph so that text lies between margins",
"       (with argument: double spaced)",
" ",
"E#-<tab> Set tab spacing to n characters between tabs stops",
""
};

char *quitting[] = {
" ",
"Invoking GNOME:  gnome [options][-h for help] [file(s)]",
" ",
"^C     Exit GNOME",
"^Z     Write out this buffer if changed, then Exit GNOME",
" ",
"^X!    Send one command to the operating system and return",
"^X^C   Start a new command processer, suspending GNOME",
" ",
"^X&    Play back log file (stop logging, replay it now)",
""
};

char *other_cmds[] = {
"^G    Cancel command/macro in progress or undo kill/yank.",
"Esc # (or ^U #, with default of 4) - Enter numerical argument.",
"      ('-' = -1) (Repeats the next command that many times.)",
"^X M  Begin or end a macro definition",
#if VT100
"^X E  (or PF4)  Execute the defined macro",
#else
"^X E  Execute the defined macro",
#endif
"^X =  Position report -- displays line number, column, ASCII code",
"^X^E  Toggle between edit & view-only modes",
"E-I   Toggle between insert & overstrike modes",
"^X Q  Toggle visibility of tabs, spaces & newlines",
"^L    Redraw screen",
""
};

char *enter_str[] = {
" ",
" When entering filenames, buffer names, or search strings:",
" ",
" Up and down arrows (^P,^N) scroll through defaults,",
" Screen editing of string is possible with the usual keys,",
" <Return> enters the string as displayed,",
" <Undo> or ^G aborts the operation,",
" \'\\\' or <Esc> enters the next character verbatim",
" (in search strings, for \'.\', \'!\', and control chars).",
""
};

#endif

/*
 * This routine rebuilds a help screen's text
 * in the special secret buffer. It is called
 * by help() via make_popup(). Returns TRUE if
 * everything works. Returns FALSE if there is
 * an error (if there is no memory).
 */
make_help(buffer, data)
	BUFFER	*buffer;
	char	*data[];	/* array of strings */
{
	register char	**dp;
	register int	s;

	bbclear(buffer);		/* Blow old text away */
	for(dp=data; **dp != '\0'; ++dp) {
		if (addline(*dp, buffer) == FALSE)
			return (FALSE);
	}
	return (TRUE); 		/* All done */
}

/*
 * Show help menu and then requested screens.
 * Bound to "E-?". By mb:
 */
help(f, n)
{
	register int  c = 'Y';
	register char **helpscrn;

	while (c != 'N') {

		switch (c) {

		case 'Y':
			helpscrn = help_menu;
			break;
		case 'C':
			helpscrn = curs_ctrl;
			break;
		case 'I':
			helpscrn = insdel;
			break;
		case 'S':
			helpscrn = search_cmds;
			break;
		case 'T':
		case 'U':
			helpscrn = transp_cap;
			break;
		case 'M':
			helpscrn = move_cmds;
			break;
		case 'W':
			helpscrn = wind_cmds;
			break;
		case 'B':
			helpscrn = buf_cmds;
			break;
		case 'D':
			helpscrn = disk_cmds;
			break;
		case 'F':
			helpscrn = formatting;
			break;
		case 'Q':
			helpscrn = quitting;
			break;
		case 'O':
			helpscrn = other_cmds;
			break;
#if (AtST | MSDOS)
		case 'A':
			helpscrn = alt_chars;
			break;
#endif
		case 'E':
			helpscrn = enter_str;
			break;
		default:
			helpscrn = NULL;

		} /* end of switch */

		if (helpscrn == NULL)
			break;
		if (make_popup(bhelpp, make_help, helpscrn)==TRUE) {
			update(FALSE);
			if (c == 'Y')
				mlwrite("enter first letter of choice: ");
			else
				mlwrite("more help? [y/n] ");
			c = getkey();
			if (c>='a' && c<='z')
				c -= 0x20;
		} else 
			return (FALSE);

	} /* end of while() */

 	if (helpscrn == NULL) {
		mlwrite("[aborted]");
		return (onlywind(f,n));
	}
#if (AtST | MSDOS)
	mlwrite("[Alt-1 returns to one window]");
#else
	mlwrite("[^X 1 returns to one window]");
#endif
	return (TRUE);
}

#endif HELP
