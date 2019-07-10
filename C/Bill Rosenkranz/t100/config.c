/*
 *	config.c
 */

#ifndef lint
static char *rcsid_config_c = "$Id: config.c,v 1.0 1991/09/12 20:32:56 rosenkra Exp $";
#endif

/*
 * $Log: config.c,v $
 * Revision 1.0  1991/09/12  20:32:56  rosenkra
 * Initial revision
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <osbind.h>
#include "t100.h"

extern int	vt100_mode;
extern int	curskey;
extern int	keypad;


/*------------------------------*/
/*	itoa			*/
/*------------------------------*/
char *itoa (int num, char *str, int radix)
{
	char    format[] = "%d";

	switch (radix)
	{
	case 8: 
		format[1] = 'o';
		break;
	case 10: 
		format[1] = 'd';
		break;
	case 16: 
		format[1] = 'x';
		break;
	}

	sprintf (str, format, num);
	return (str);
}





/*------------------------------*/
/*	config_bps		*/
/*------------------------------*/
void config_bps ()
{
	char		key;
	static int	rates[16] =
	{
		19200, 9600, 4800, 3600, 2400, 2000, 1800, 1200,
		600, 300, 200, 150, 130, 110, 75, 50
	};
	char		keys[] = "0123456789abcdef";
	int		i;
	char		temp[6];

	Cconws ("\n\r");
	for (i = 0; i < 16; i++)
	{
		Cconws (itoa (i, temp, 16));
		Cconws (":  ");
		Cconws (itoa (rates[i], temp, 10));
		Cconws ("\n\r");
	}
	Cconws ("\n\r");
	Cconws ("Choose:  ");
	key = (char) (Cconin () & KEYMASK);

	for (i = 0; i < 16; i++)
	{
		if (keys[i] == key)
		{
			(void) Rsconf (i, -1, -1, -1, -1, -1);
			Cconws ("\n\rSpeed set to ");
			Cconws (itoa (rates[i], temp, 10));
			Cconws (" bps.");
		}
	}
	Cconws ("\n\r");
}



/*------------------------------*/
/*	config_ucr		*/
/*------------------------------*/
void config_ucr ()
{
	Cconws ("Not implemented.\n\r");
}



/*------------------------------*/
/*	config			*/
/*------------------------------*/
void config ()
{
	char    key;

	Cconws ("\n\r\n\r\n\r");

if (vt100_mode)
{
  fnt_reverse ();
  Cconws ("                                Configure T100                                  \n\r");
  fnt_roman ();
}
else
{
  Cconws ("                                Configure T100\n\r");
}


	do
	{
		Cconws ("\n\r");
		Cconws ("0:  exit to terminal emulator\n\r");
		Cconws ("1:  set bps rate\n\r");
		Cconws ("2:  set ucr bits (parity etc.)\n\r");
		if (vt100_mode)
		{
			if (curskey)
				Cconws ("3:  toggle application cursor key mode (now ON)\n\r");
			else
				Cconws ("3:  toggle application cursor key mode (now OFF)\n\r");

			if (keypad)
				Cconws ("4:  toggle application keypad mode (now ON)\n\r");
			else
				Cconws ("4:  toggle application keypad mode (now OFF)\n\r");
		}
		Cconws ("\n\r");
		Cconws ("Choose:  ");

		key = (char) (Cconin () & KEYMASK);
		Cconws ("\n\r");

		switch (key)
		{
		case '1': 
			config_bps ();
			break;
		case '2': 
			config_ucr ();
			break;
		case '3':
			if (vt100_mode)
			{
				if (curskey)
				{
					curskey = 0;
					Cconws ("\n\rcursor key mode OFF\n\r");
				}
				else
				{
					curskey = 1;
					Cconws ("\n\rcursor key mode ON\n\r");
				}
			}
			break;
		case '4':
			if (vt100_mode)
			{
				if (keypad)
				{
					keypad = 0;
					Cconws ("\n\rkeypad mode OFF\n\r");
				}
				else
				{
					keypad = 1;
					Cconws ("\n\rkeypad mode ON\n\r");
				}
			}
			break;
		}

	} while (key != '0');
}




/*------------------------------*/
/*	long_break		*/
/*------------------------------*/
void long_break ()
{

/*
 *	send a long break to modem...
 */

	Cconws ("Not implemented.\n\r");
}



/*------------------------------*/
/*	help			*/
/*------------------------------*/
void help ()
{
Cconws ("\n\r\n\r\n\r");

if (vt100_mode)
{
  fnt_reverse ();
  Cconws ("                                   T100 Help                                    \n\r");
  fnt_roman ();
}
else
{
  Cconws ("                                   T100 Help\n\r");
}

Cconws ("\n\r");

Cconws ("        This is a terminal program.   What you type goes  directly to the\n\r");
Cconws ("        modem (AUX port, actually).  After the program starts,  a typical\n\r");
Cconws ("        thing to do would be to dial a number,  let's say ATDT12225551212\n\r");
Cconws ("        (this number does not exist so don't go trying to dial it).\n\r");
Cconws ("\n\r");
Cconws ("        In addition, t100 will recognize a few special key codes from the\n\r");
Cconws ("        the console:\n\r");
Cconws ("\n\r");
if (vt100_mode)
{
  Cconws ("                    ");
  fnt_bold ();  Cconws ("HELP    ");  fnt_roman ();
  Cconws ("         this info\n\r");
  Cconws ("                    ");
  fnt_bold ();  Cconws ("ALT-q   ");  fnt_roman ();
  Cconws ("         quit\n\r");
  Cconws ("                    ");
  fnt_bold ();  Cconws ("ALT-c   ");  fnt_roman ();
  Cconws ("         configure\n\r");
  Cconws ("                    ");
  fnt_bold ();  Cconws ("ALT-l   ");  fnt_roman ();
  Cconws ("         long break\n\r");
  Cconws ("                    ");
  fnt_bold ();  Cconws ("ALT-s   ");  fnt_roman ();
  Cconws ("         shell command\n\r");
}
else
{
  Cconws ("                    HELP             this info\n\r");
  Cconws ("                    ALT-q            quit\n\r");
  Cconws ("                    ALT-c            configure\n\r");
  Cconws ("                    ALT-l            long break\n\r");
  Cconws ("                    ALT-s            shell command\n\r");
}
Cconws ("\n\r");
Cconws ("        For shell commands, t100 searches the PATH for the command.\n\r");
Cconws ("\n\r\n\r");
}

