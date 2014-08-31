/*******************************************************************
* File name:	SPLITFIL.C		Revision date:	1993.09.06
* Revised by:	Ulf Ronald Andersson	Starting from:	1992.03.07
* Revised to:	Split file into RODOS-compatible 16K files
********************************************************************/


#include <tos.h>
#include <stddef.h>
#include <string.h>


void split_file(char file[]);
void cerrws	(char *string);
char *get_name(char *path);
char out_ext[5]=".ROA";

char file_buf[16388L];

void main(int argc, char *argv[])
{
	if	(argc != 2)		  /* if argument is missing */
		{
		cerrws("Syntax: SPLITFIL filename\r\n");
		Pterm(1);
		}

	split_file(argv[1]);
	Pterm0();
}


void split_file(char filename[])
{    int  	i, x, file_hd, rom_hd;
	char	name[20];
	char	*ext;
	char	*ext_char=out_ext+3;
	register	long 	ilen;

	strcpy(name, get_name(filename));
	ext = strchr(name, '.');
	if	(ext == NULL)
		ext = name+strlen(name);

	if	(0 > (file_hd = (int) Fopen(filename, 0)))
		Pterm(file_hd);

	file_buf[0] = 0x00;
	file_buf[1] = 0x10;

	for	(i=0;0 != (ilen= Fread(file_hd, 16384L, file_buf+4));i++)
	{
		x = 0xFFF + (int) ilen;
		file_buf[2] = (char) (x & 255);
		file_buf[3] = (char) (x >> 8);

		strcpy(ext, out_ext);
		*ext_char += 1;
		if (0 > (rom_hd = (int) Fcreate(name,0)))
			Pterm(rom_hd);

		if	(0 > Fwrite(rom_hd,ilen+4,file_buf))
			Pterm((int) -10L);

		Fclose(rom_hd);
		if (ilen < 16384L) break;
	}	/* next i */
	if (0 > ilen)  Pterm((int) ilen);
	Fclose(file_hd);

}	/* Endfun split_file(char filename[]) */


/******************************************************************
*
* Sends <string> to handle 4 (stderr) if present, else to handle -1
* Gibt einen <string> nach stderr aus, d.h. nach Handle 4,
* falls vorhanden. Sonst nach Handle -1.
*
******************************************************************/

void cerrws(char *string)
{
	extern BASPAG *_BasPag;


	Fwrite( (_BasPag->p_stdfh[4]) ? 4 : -1,
		  strlen(string), string);
}


/*********************************************************************
*
* Returns the pure filename part of a full pathname
*
*********************************************************************/

char *get_name(char *path)
{
	register char *n;

	n = strrchr(path, '\\');
	if	(!n)
		{
		if	((*path) && (path[1] == ':'))
			path += 2;
		return(path);
		}
	return(n + 1);
}

/* End of file:	SPLITFIL.C */
