/*  EASYFSEL.C                                 */
/*  Routine zum leichten und AES-Versions      */
/*  abh„ngigen Aufruf der GEM-Fileselectorbox  */
/*  mit Auswertung des 'FSEL' - Cookies.       */
/*  Aužerdem sind einige Routinen zum Umgang   */
/*  mit Dateien enthalten, sowie zum Suchen    */
/*  eines Cookies.                             */

#include <easyfsel.h>

#include <stdlib.h>

boolean easy_fsel(char *pfad, char *dateiname, char *text)
{
	int button;
	int result;
	long c_wert = 0;
	extern GEMPARBLK _GemParBlk;

	if((_GemParBlk.global[0] < 0x0140) && (get_cookie("FSEL", &c_wert) == FALSE))
		result = fsel_input(pfad, dateiname, &button);
	else
		result = fsel_exinput(pfad, dateiname, &button, text);

	if(result == 0 || button == 0)
		return(FALSE);
	else
		return(TRUE);
}

void build_filename(char *dest, char *pfad, char *dateiname)
{
	char *xyz;
	strcpy(dest, pfad);
	xyz = strrchr(dest, (int)'\\');
	strcpy(++xyz, dateiname);
}

boolean exist(const char * dateiname)
{
	if(Fsfirst(dateiname, FA_READONLY | FA_HIDDEN | FA_ARCHIVE) == 0)
		return(TRUE);
	else
		return(FALSE);
}

char *get_akt_path(char *path)
{
	strcpy(path, " :");
	path[0] = 'A' + getdisk();
	getcurdir(0, path+2);
	return(path);
}

boolean get_cookie(char *cookie_name, long *cookie_value)
{
	long alter_stack;
	long *cookiejar;

	alter_stack = Super(0L);
	cookiejar = *((long **)0x5a0L);
	Super((void *)alter_stack);
	if(!cookiejar)
		return(FALSE);
	else
	{
		do
		{
			if(!strncmp((char *)cookiejar, cookie_name, 4))
			{
				if(cookie_value)
				{
					*cookie_value = cookiejar[1];
					return(TRUE);
				}
			}
			else
				cookiejar = &(cookiejar[2]);
		}
		while(cookiejar[0]);
		return(FALSE);
	}
}