#include "extern.h"

/* -----------------
	 | Execute batch |
	 ----------------- */
void exec_batch(char *bat)
{
FILE *bat_file;
char buffer[250];

bat_file = fopen(bat, "r");
if (bat_file)
	{
	while(fgets(buffer, 254, bat_file))
		if (buffer[0] != '#')
			switch(((int)buffer[0] << 8) + buffer[1])
				{
				case 'FL':
				case 'fl':
					filter();
					break;

				case 'RM':
				case 'rm':
					unlink(&buffer[3]);
					break;

				case 'LD':
				case 'ld':
					strcpy(fname, &buffer[3]);
					load(0);
					break;

				case 'SV':
				case 'sv':
					save_file(&buffer[3], o_bytes, total);
					break;

				case 'OV':
				case 'ov':
					do_oversam();
					break;

				case 'PL':
				case 'pl':
					play(o_bytes, total);
					break;

				case 'PK':
				case 'pk':
					kompakt(0);
					break;
				}

	fclose(bat_file);
	}
}

/* ----------------
	 | Select batch |
	 ---------------- */
void do_batch(void)
{
int stat, but;
char path2[128], file2[14];

strcpy(path2, path);
if (strchr(path2, '.'))
	strcpy(strrchr(path2, '.'), ".BAT");
else
	strcat(path2, ".BAT");
file2[0] = 0;

stat = fsel_input(path2, file2, &but);
if (stat && but)
	{
	strcpy(strrchr(path2, '\\') + 1, file2);
	exec_batch(path2);
	}
}

