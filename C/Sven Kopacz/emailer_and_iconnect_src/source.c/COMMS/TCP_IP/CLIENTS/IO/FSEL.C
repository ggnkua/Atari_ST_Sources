#include <ec_gem.h>

int	f_input(char *spruch, char *path, char *name)
{
	/* ™ffnet Fileselector und schreibt den Zugriffspfad
		 des Auswahlergebnisses in path */
		 
	char	*backslash;
	int		gb0, button, back;
	long	dum;
	
	gb0=_GemParBlk.global[0];
	wind_update(BEG_UPDATE);
	if ((gb0 >= 0x0140) || find_cookie('FSEL', &dum))
		back=fsel_exinput(path, name, &button, spruch);
	else
		back=fsel_input(path, name, &button);		
	wind_update(END_UPDATE);
	
	if (back)
	{
		if (button)
		{
			if (path[strlen(path)-1] != '\\')
			{
				backslash=strrchr(path, '\\');
				*(++backslash)=0;
			}
			
			strcat(path, name);
		}
		else
			back=0;
	}
	
	return(back);
}

int	f_sinput(char *spruch, char *path, char *name)
{
	/* ™ffnet Fileselector und schreibt den Ergebnispfad
	   in path und den name in name
	   ( bzw. die Fsel_Routine macht das )
	*/
	
	int		gb0, button, back;
	long	dum;
	
	gb0=_GemParBlk.global[0];
	wind_update(BEG_UPDATE);
	if ((gb0 >= 0x0140) || find_cookie('FSEL', &dum))
		back=fsel_exinput(path, name, &button, spruch);
	else
		back=fsel_input(path, name, &button);		
	wind_update(END_UPDATE);
	
	if (back && button) return(1);
	
	return(0);
}

void	make_path(char *com, char *path, char *name)
{
	/* Bastelt aus dem Pfad mit z.B. Dateimaske und dem
	   Name einen fertigen Zugriffspfad und schreibt ihn 
	   in com
	 */

	char	*backslash;

	strcpy(com, path);
	
	if (com[strlen(com)-1] != '\\')
	{
		backslash=strrchr(com, '\\');
		*(++backslash)=0;
	}
	
	strcat(com, name);
}


