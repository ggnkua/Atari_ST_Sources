/*************************************************************************/
/*                                                                       */
/* ½ Seaton Shareware Coop - All Rights Reserved		                   */
/*                                                                       */
/* Module : SU04.C                                                       */
/*                                                                       */
/* Purpose: Handle sample sounds; read, play and free memory.            */
/*                                                                       */
/* Author : Pete Walker & Geoff Smith                                    */
/*                                                                       */
/*************************************************************************/

/*************************************************************************/
/*                                                                       */
/* 001	26/10/94		PAW	Initial Release                               */
/*                                                                       */
/*************************************************************************/

#include <sound.h>
#include <string.h>
#include <stdlib.h>
#include <dos.h>
#include <fcntl.h>

/* This structure is for internal use only - read_sound */
typedef struct AVR_HEADERstr
{
	char  AVR_code[4];
	char  name[8];
	short mono;
	short resolution;
	short sign;
	char  not_used_1[4];
	long  frequency;
	long  length;
	char  not_used_2[14];
	char  extended_name[20];
	char  not_used_3[64];
}AVR_HEADER;

/* play_sam is an assembler module and is only used by play_sound */
extern void play_sam(SOUNDSTUFF *sample);  

void read_sound
	(
	char *path,
	char *file,
	SOUNDSTUFF *sample
	)
{
	int fh;
	AVR_HEADER hdr;
	char full_path[80];

	strcpy(full_path, path);
	strcat(full_path, file);
	fh=_dopen(full_path,O_RDONLY);

	/* If failed to open file set up a dummy sample */
	if (fh < 0)
		{
		sample->data = NULL;
		sample->length = 0;
		sample->freq = 0;
		return;
		}

	/* read an AVR format header */
   _dread( fh, (char *)&hdr, sizeof(AVR_HEADER) );

	/* Mask off top byte of frequency */
	sample->freq = hdr.frequency & 0xFFFFFF;
	/* Convert to KHz */
	sample->freq = (sample->freq+500) / 1000;

	/* Get sample length in bytes */
	sample->length = hdr.length;

	sample->data = (char *)malloc(sample->length);
	_dread( fh, sample->data, sample->length );

	_dclose(fh);
}

void free_sound
	(
	SOUNDSTUFF *sample
	)
{
	if (sample->length!=0)
		free(sample->data);
}

void play_sound
	(
	SOUNDSTUFF *sample
	)
{
	if (sample->length!=0) 
		play_sam(sample);
}
