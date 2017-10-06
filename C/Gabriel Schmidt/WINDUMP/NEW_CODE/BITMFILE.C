/****************************\
* Bitmap mit Farbtabelle als *
* Graphik-Datei speichern		 *
* Autor: Gabriel Schmidt		 *
* (c) 1992 by MAXON-Computer *
* Modifiziert von Sebastian	 *
* Bieber, Dez. 1994					 *
* -> Programmcode						 *
\****************************/

#include <errno.h>
#include <stdlib.h>
#include <stdio.h>

#include "bitmfile.h"

/* --- (X) IMG-Implementation ----------------- */

#define IMG_COMPRESSED

typedef struct
	{
	UWORD img_version;
	UWORD img_headlen;
	UWORD img_nplanes;
	UWORD img_patlen;
	UWORD img_pixw;
	UWORD img_pixh;
	UWORD img_w;
	UWORD img_h;
	} IMG_HEADER;

typedef enum {NONE, SOLID0, SOLID1, PATRUN, BITSTR} IMG_MODE;

typedef UBYTE IMG_SOLID;

typedef enum { RGB=0, CMY=1, Pantone=2 } XIMG_COLMODEL;

typedef struct
	{
	ULONG img_ximg;
	XIMG_COLMODEL img_colmodel;
	} XIMG_HEADER;

typedef struct RGB XIMG_RGB;


int bitmap_to_img(FILE_TYP typ,	int ww, int wh,
									unsigned int pixw, unsigned int pixh,
									unsigned int planes, unsigned int colors,
									const char *filename,
									void(*get_color)(unsigned int colind, struct RGB *rgb),
									void(*get_pixel)(int x, int y, unsigned int *colind) )
	{
	int file, error, cnt;
	IMG_HEADER header;
	XIMG_HEADER xheader;
	XIMG_RGB xrgb;
	IMG_MODE mode;
	UBYTE *line_buf, *write_buf;
	register UBYTE *startpnt, *bufpnt;
	unsigned int colind, line_len, line, bit;
	register unsigned int byte;
	register UBYTE count;

	/* (X) IMG-Header ausfÅllen */

	header.img_version = 1;
	header.img_headlen = (UWORD) sizeof(header) /2;
	if (typ == XIMG)
		header.img_headlen += (UWORD)(sizeof(xheader)+colors*sizeof(xrgb))/2;

	header.img_nplanes	= planes;
	header.img_patlen		= 2;
	header.img_pixw			= pixw;
	header.img_pixh			= pixh;
	header.img_w				= ww;
	header.img_h				= wh;

	xheader.img_ximg		= 'XIMG';
	xheader.img_colmodel= RGB;

	/* ZeilenlÑnge best., Puffer allozieren */

	line_len 	= (ww+7)/8;

	line_buf 	= malloc((size_t)planes*line_len);
	if (line_buf == NULL)
		return(ENOMEM);

	/* Worst case: Die gepufferte Zeile kann max. die 3fache Laenge der */
	/* Original-Zeile bekommen!																					*/

	write_buf = malloc((size_t)3*line_len);
	if (write_buf == NULL)
		{
		free(line_buf);
		return(ENOMEM);
		};

	/* Datei îffnen */

	file = open(filename, O_WRONLY | O_CREAT | O_TRUNC);
	if (file<0)
		{
		error = errno;
		free(line_buf);
		free(write_buf);
		return(error);
		};

	/* Header schreiben */

	if (write (file, &header, sizeof(header)) != sizeof(header) ||
	 	  (typ == XIMG &&	write (file, &xheader, sizeof(xheader) ) != sizeof(xheader)))
			{
			error = errno;
			close(file);
			free(line_buf);
			free(write_buf);
			return(error);
			};

	/* evtl.Farbtabelle speichern */

	if ( typ == XIMG )
	for (cnt=0; cnt<colors; cnt++)
		{
		get_color(cnt,&xrgb);
		if (write(file,&xrgb,sizeof(xrgb)) != sizeof(xrgb))
			{
			error = errno;
			close(file);
			free(line_buf);
			free(write_buf);
			return(error);
			};
		};

	/*Und nun Zeile fÅr Zeile... */

	for (line=0; line<wh; line++)
		{
		/* Pixel abfragen, aufspalten und */
		/*als Planes im Puffer ablegen    */

		for (byte=0; byte<line_len; byte++)
			{
			for (cnt=0; cnt<planes; cnt++)
				line_buf[cnt*line_len+byte] = 0x00;

			for (bit=0; bit<8; bit++)
				{
				if (8*byte+bit < ww)
					get_pixel(8*byte+bit, line, &colind);

				for (cnt=0; cnt<planes; cnt++)
					{
					line_buf[cnt*line_len+byte] <<= 1;
					line_buf[cnt*line_len+byte]  |= colind & 0x01;
					colind >>= 1;
					};
				};
			};

		/* Bitstrings im Puffer komprimieren */
		/* und in die Datei schreiben        */

		for (cnt=0; cnt<planes; cnt++)
			{
			/* Bitstringzeiger auf Anfang der Plane */

			startpnt = &line_buf[cnt*line_len];
			bufpnt = write_buf;

			while (startpnt < &line_buf[(cnt+1)*line_len])
				{
				/********************************************/
				/* Welcher _neue_ Komprimiermodus "passt"   */
				/* zum aktuellen Byte?                      */
				/* Anmerkung: Es werden die komprimierenden */
				/* Modi "positiv" selektiert. Der unkompri- */
				/* mierende BITSTR-Modus wird nur dann 			*/
				/* gewÑhlt, wenn sonst nichts "passt...			*/
				/********************************************/

				switch (*startpnt)
					{
					case 0x00:
						mode = SOLID0;
						break;
					case 0xFF:
						mode = SOLID1;
						break;
					default:
						if ( startpnt	<  &line_buf[(cnt+1)*line_len-3] &&
								*(startpnt)   == *(startpnt+2)						 &&
								*(startpnt+1) == *(startpnt+3)						 )
							mode = PATRUN;
						else
							mode = BITSTR;
					};

				/******************************************************/
				/* Der Modus ist gewÑhlt, jetzt wird er abgearbeitet. */
				/* FÅr alle komprimierenden Modi wird der aktuelle		*/
				/* Modus solange wie mîglich beibehalten. 						*/
				/******************************************************/

				count = 0;

				switch (mode)
					{
					case SOLID0:
						while (	(startpnt < &line_buf[(cnt+1)*line_len])	&&
									 	(*(startpnt)=='\x00')											&&
									 	(count < 0x7F) 				 										)
									{
									startpnt++;
									count++;
									};
						*(bufpnt++) = count;
						break;

					case SOLID1:
						while (	(startpnt < &line_buf[(cnt+1)*line_len])	&&
									 	(*(startpnt)=='\xFF')											&&
									 	(count < 0x7F) 				 										)
									{
									startpnt++;
									count++;
									};
						*(bufpnt++) = 0x80 | count;
						break;

					case PATRUN:
						*(bufpnt++) = 0x00;
						startpnt += 2;
						count = 1;
						while (	startpnt < &line_buf[(cnt+1)*line_len-1]	&&
										*(startpnt)		== *(startpnt-2)						&&
										*(startpnt+1)	== *(startpnt-1)						&&
										(count < 0xFF)														)
									{
									count++;
									startpnt += 2;
									};
						*(bufpnt++) = count;
						*(bufpnt++) = *(startpnt-2);
						*(bufpnt++) = *(startpnt-1);
						break;

					/************************************************/
					/* Die while Bedingung ist so zu verstehen:			*/
					/*																							*/
					/* while ( NOT(2-Byte-Solidrun mîglich)		&&		*/
					/*				 NOT(6-Byte-Patternrun mîglich)	&&		*/
					/*				 count < 0xFF										&&		*/
					/*				 Noch Bytes Åbrig								)			*/
					/*																							*/
					/* Sobald es eine _komprimierende_ Alternative	*/
					/* gibt, wird der BITSTR abgebrochen!						*/
					/************************************************/

					case BITSTR:
						*(bufpnt++) = 0x80;
						while ( !(((startpnt+count)<&line_buf[(cnt+1)*line_len-1])&&
											(((*(startpnt+count)=='\xFF') && (*(startpnt+count+1)=='\xFF'))||
											 ((*(startpnt+count)=='\x00') && (*(startpnt+count+1)=='\x00'))))		&&
										!(((startpnt+count)<&line_buf[(cnt+1)*line_len-5])&&
											(*(startpnt+count)   == *(startpnt+count+2))&&
											(*(startpnt+count+1) == *(startpnt+count+3))&&
											(*(startpnt+count)   == *(startpnt+count+4))&&
											(*(startpnt+count+1) == *(startpnt+count+5)))												&&
										(count < 0xFF)																												&&
										((startpnt+count) < &line_buf[(cnt+1)*line_len]) 											)
										count++;
						*(bufpnt++) = count;
						for(; count>0; count--)
							*(bufpnt++) = *(startpnt++);
						break;
					};
				};

			if (write(file,write_buf,bufpnt-write_buf) != (bufpnt-write_buf))
				{
				error = errno;
				close(file);
				free(line_buf);
				free(write_buf);
				return(error);
				};

			};
		};

	/*Datei schlieûen, Puffer freigeben */

	close(file);
	free(line_buf);
	free(write_buf);
	return(0);

}

/*---Filetyp-Dispatcher--------------------*/

const char *get_file_ext(FILE_TYP typ)
	{
	switch (typ)
		{
		case IMG:
		case XIMG:
			return("IMG");
		default:
			return("");
		};
}


int bitmap_to_file(FILE_TYP typ, int ww, int wh,
									 unsigned int pwx, unsigned int pwy,
									 unsigned int planes, unsigned int colors,
									 const char *filename,
									 void (*get_color)(unsigned int colind, struct RGB *rgb),
									 void (*get_pixel)(int x, int y, unsigned int *colind))
	{

	switch (typ)
		{
		case IMG:
		case XIMG:
			return(bitmap_to_img(typ,ww,wh,pwx,pwy,planes,colors,filename,get_color,get_pixel));
		default:
			return(-1);
		};
}

