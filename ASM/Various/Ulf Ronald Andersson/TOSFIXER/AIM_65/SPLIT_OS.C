/*******************************************************************
* File name:	SPLIT_OS.C				Revision date:	1992.03.07
* Revised by:	Ulf Ronald Andersson	Starting from:	1992.03.07
* Revised to:	Split image into RODOS-compatible 16K files
********************************************************************/


#include <tos.h>
#include <stddef.h>
#include <string.h>


void split_os(char file[]);
void cerrws	(char *string);
char *get_name(char *path);


char ibuf[32768L],
     ebuf[16388L],
     obuf[16388L];


char fext_tb[16][5] =
{	".U4L",".U7L",".U4H",".U7H",
	".U3L",".U6L",".U3H",".U6H",
	".U2L",".U5L",".U2H",".U5H",
	".UXL",".UYL",".UXH",".UYH"
};


void main(int argc, char *argv[])
{
	if	(argc != 2)		  /* if argument is missing */
		{
		cerrws("Syntax: SPLIT_OS filename\r\n");
		Pterm(1);
		}

	split_os(argv[1]);
	Pterm0();
}


void split_os(char filename[])
{    int  	i, x, ihdl, ohdl, ehdl;
	char	name[20];
	char	*ext;
	register	long 	ii, ei, oi, ilen;

	strcpy(name, get_name(filename));
	ext = strchr(name, '.');
	if	(ext == NULL)
		ext = name+strlen(name);

	if	(0 > (ihdl = (int) Fopen(filename, 0)))
		Pterm(ihdl);

	ebuf[0] = obuf[0] = 0x00;
	ebuf[1] = obuf[1] = 0x10;

	for	(i = 0;
		 (i < 16  &&  0 != (ilen= Fread(ihdl, 32768L, ibuf)));
		 i+=2
		)
	{	for	(ei=0,oi=0,ii=0; ii<ilen;)
		{	(ebuf+4)[ei++] = ibuf[ii++];
			if (ii<ilen) (obuf+4)[oi++] = ibuf[ii++];
		}

		x = 0xFFF + (int) ei;
		ebuf[2] = (char) (x & 255);
		ebuf[3] = (char) (x >> 8);
		x = 0xFFF + (int) oi;
		obuf[2] = (char) (x & 255);
		obuf[3] = (char) (x >> 8);

		strcpy(ext, fext_tb[i]);
		if (0 > (ehdl = (int) Fcreate(name,0)))
			Pterm(ehdl);
		strcpy(ext, fext_tb[i+1]);
		if (0 > (ohdl = (int) Fcreate(name,0)))
			Pterm(ohdl);

		if	(0 > Fwrite(ehdl,ei+4,ebuf) ||
			 0 > Fwrite(ohdl,oi+4,obuf))
			Pterm((int) -10L);

		Fclose(ehdl);
		Fclose(ohdl);
	}	/* next i */
	if (0 > ilen)  Pterm((int) ilen);

}	/* Endfun split_os(char filename[]) */


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
