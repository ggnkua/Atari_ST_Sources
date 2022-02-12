/****************************************************************/
/*								*/
/*	ic_input.c						*/
/*								*/
/*		Character input routines for the		*/
/*		"Integer Calculator".				*/
/*								*/
/****************************************************************/
/*  origination          1988-Apr-7         Terrence W. Holm	*/
/*  added cmd line args  1988-May-13	    Terrence W. Holm	*/
/****************************************************************/
#include <stdio.h>
#include <ctype.h>
#include <termios.h>

#include "ic.h"

static struct termios saved_tty;

/****************************************************************/
/*								*/
/*	Save_Term()						*/
/*								*/
/*		Save the current terminal characteristics.	*/
/*								*/
/****************************************************************/
void Save_Term()
{
  tcgetattr(0, &saved_tty);
}

/****************************************************************/
/*								*/
/*	Set_Term()						*/
/*								*/
/*		Set up the terminal characteristics for ic.	*/
/*								*/
/****************************************************************/
void Set_Term()
{
  struct termios ic_mode;

  ic_mode = saved_tty;

  /* No tab expansion, no echo, cbreak mode, ignore ^S & ^Q	 */
#ifdef XTABS
  ic_mode.c_oflag &= ~XTABS;
#endif
  ic_mode.c_lflag &= ~(ECHO | ICANON);
  ic_mode.c_iflag &= ~(IXON | IXOFF);

  /* Change the interrupt character to ^C		 	 */
  ic_mode.c_cc[VINTR] = '\003';

  tcsetattr(0, TCSANOW, &ic_mode);
}

/****************************************************************/
/*								*/
/*	Reset_Term()						*/
/*								*/
/*		Restore the terminal characteristics.		*/
/*								*/
/****************************************************************/
void Reset_Term()
{
  tcsetattr(0, TCSANOW, &saved_tty);
}

/****************************************************************/
/*								*/
/*	Get_Char()						*/
/*								*/
/*		Return the next input character. Upper case	*/
/*		is mapped to lower case. Escape sequences	*/
/*		are mapped to special codes (msb set).		*/
/*								*/
/****************************************************************/
int Get_Char()
{
  int c;

  /* Fflush() used because Minix does not automatically	flush the output. */
  fflush(stdout);
  if ((c = Getc()) == EOF) return(EOF);
  c &= 0x7f;
  if (isupper(c)) return(tolower(c));

  if (c == ESCAPE)
	if ((c = Getc()) != '[') {
		ungetc(c, stdin);
		return(ESCAPE);
	} else {
		c = Getc() | 0x80;

		if (c == ESC_HOME || c == ESC_UP || c == ESC_PGUP ||
		    c == ESC_LEFT || c == ESC_5 || c == ESC_RIGHT ||
		    c == ESC_END || c == ESC_DOWN || c == ESC_PGDN ||
		    c == ESC_PLUS || c == ESC_MINUS)
			return(c);
		else
			return(ESCAPE);
	}

  return(c);
}

/****************************************************************/
/*								*/
/*	Init_Getc( argc, argv )					*/
/*								*/
/*		Give Getc() references to the command line	*/
/*		arguments.					*/
/*								*/
/****************************************************************/
static int args_remaining;
static char **args_pointer;
static int args_index;

void Init_Getc(argc, argv)
int argc;
char *argv[];
{
  args_remaining = argc - 1;
  args_pointer = &argv[1];
  args_index = 0;
}

/****************************************************************/
/*								*/
/*	Getc()							*/
/*								*/
/*		Get the next input character from the command	*/
/*		line if there is some more, else from stdin.	*/
/*								*/
/****************************************************************/
int Getc()
{
  int c;

  if (args_remaining > 0)
	if ((c = args_pointer[0][args_index++]) == '\0') {
		--args_remaining;
		++args_pointer;
		args_index = 0;

		if (args_remaining > 0) return('\n');
	} else
		return(c);

  return(getchar());
}

/****************************************************************/
/*								*/
/*	Get_Base( character )					*/
/*								*/
/*		Return an appropriate base number for the	*/
/*		given character code. Used by 'i' and 'o'.	*/
/*								*/
/****************************************************************/
int Get_Base(code)
char code;
{
  switch (code) {
      case 'h':
	return(HEXADECIMAL);

      case 'd':
	return(DECIMAL);

      case 'o':
	return(OCTAL);

      case 'b':
	return(BINARY);

      case 'a':
	return(ASCII);

      default:	return(ERROR);
  }
}
