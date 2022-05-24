/*
 *	Routines for loading AVR/WAV Sample files
 *	July 1994 Martin Griffiths
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "types.h"

#pragma pack(0);

DISK_STATUS read_sample(FILE *fp,
			UINT32 bits_per_sample,UINT32 size,UINT32 frequency,
			Generic_SampleInfo *sample_info)
{	INT32 tss = (bits_per_sample >> 3)*size;
	if ((sample_info->malloc_ptr = malloc(tss+16)) == NULL)
		return OUT_OF_MEMORY;
	sample_info->data_ptr = (void *) ( (UINT32) ((sample_info->malloc_ptr)+16) & 0xfffffff0);
    	if (fread(sample_info->data_ptr,tss,1,fp)!=1)
	{	free (sample_info->malloc_ptr);
	    	return READ_ERROR;
	}
	sample_info->samples   = size;
	sample_info->frequency = frequency;
	return SUCCESS;
}


/*
 *	.AVR loader
 */

/*
 *	.AVR File Header structure.
 */

typedef struct  {
    	char    magic[4];
	char	name[8];
	UINT16	mono;
	UINT16	rez;
	UINT16	sign;
	UINT16	loop;
	UINT16	midi;
	UINT32	rate;
	UINT32	size;
	UINT32	loop_begin;
	UINT32	loop_end;
	UINT16	res1;
	UINT16	res2;
	UINT16	res3;
	char	ext[20];
	char	user[64];
} AVR_HEADER;

DISK_STATUS read_avr(char *filename,Generic_SampleInfo *sample_info)
{	FILE *fp;
    	AVR_HEADER Avr;
	DISK_STATUS s;
    	fp = fopen(filename, "rb");
    	if (fp == NULL)
		return OPEN_FAILED;
    	if (fread(&Avr,sizeof(AVR_HEADER),1,fp)!=1)
		return READ_ERROR;
    	if (strncmp(Avr.magic,"2BIT",4) != 0)
		return WRONG_FORMAT;
	if ( (s=read_sample(fp,Avr.rez,Avr.size,Avr.rate,sample_info)) != SUCCESS)
		return s;
	switch	(Avr.rez)
	{	default:	/* assume 8bit */
	    		if (Avr.sign == 0)
				sample_info->format = BITS8_UNSIGNED;
			else
				sample_info->format = BITS8_SIGNED;
			break;
	    	case	16:
	    		if (Avr.sign == 0)
				sample_info->format = BITS16_UNSIGNED;
			else
				sample_info->format = BITS16_SIGNED;
			break;
	}
    	return SUCCESS;
}

/*
 *	.WAV file loader
 */

struct Fmt {
    char     fID[4];
    UINT32   fLen;
    UINT16   wFormatTag;
    UINT16   nChannels;
    UINT16   nSamplesPerSec;
    UINT16   nAvgBytesPerSec;
    UINT16   nBlockAlign;
    UINT16   FormatSpecific1;
    UINT16   FormatSpecific2;
    UINT16   SampleBits;
};


struct DataChk {
    char    dId[4];
    UINT32  dLen;
};


struct rData    {
    char    wID[4];
    struct  Fmt Format;
    struct  DataChk Data;
};

struct WavHdr {
    char    rID[4];
    UINT32  rLen;
    struct  rData Data;
};

DISK_STATUS read_wav(char *filename,Generic_SampleInfo *sample_info)
{	FILE *fp;
    	struct WavHdr   Wave;
	DISK_STATUS s;
    	fp = fopen(filename, "rb");
    	if(fp == NULL)
		return OPEN_FAILED;
    	if(fread(&Wave,sizeof(struct WavHdr),1,fp)!=1)
		return READ_ERROR;
    	if    (	(strncmp(Wave.rID,"RIFF",4) != 0)
    	   ||  	(strncmp(Wave.Data.wID,"WAVE",4) != 0)
    	   ||  	(strncmp(Wave.Data.Format.fID,"fmt ",4) != 0) 
    	   ||	(strncmp(Wave.Data.Data.dId, "data", 4) != 0) )
		return WRONG_FORMAT;
	if ( (s=read_sample(fp,	Wave.Data.Format.SampleBits,
				Wave.Data.Data.dLen,
				Wave.Data.Format.nSamplesPerSec,
				sample_info)) != SUCCESS)
		return s;
/*
    	Wave.Data.Format.wFormatTag
    	Wave.Data.Format.nChannels
   	Wave.Data.Format.nSamplesPerSec
    	Wave.Data.Format.nBlockAlign
   	Wave.Data.Data.dLen
*/
 	fclose(fp);
    	return SUCCESS;
}

/*
 *	Raw 8/16 bit signed and unsigned loaders.
 */

DISK_STATUS read_raw_8s(char *filename,Generic_SampleInfo *sample_info)
{	FILE *fp;
	DISK_STATUS s;
    	fp = fopen(filename, "rb");
    	if(fp == NULL)
		return OPEN_FAILED;
	if ( (s=read_sample(fp,	8,
				file_len(fp),
				DEFAULT_FREQUENCY,
				sample_info)) != SUCCESS)
		return s;
	sample_info->format = BITS8_SIGNED;
 	fclose(fp);
    	return SUCCESS;
}

DISK_STATUS read_raw_8u(char *filename,Generic_SampleInfo *sample_info)
{	FILE *fp;
	DISK_STATUS s;
    	fp = fopen(filename, "rb");
    	if(fp == NULL)
		return OPEN_FAILED;
	if ( (s=read_sample(fp,	8,
				file_len(fp),
				DEFAULT_FREQUENCY,
				sample_info)) != SUCCESS)
		return s;
	sample_info->format = BITS8_UNSIGNED;
 	fclose(fp);
    	return SUCCESS;
}

DISK_STATUS read_raw_16s(char *filename,Generic_SampleInfo *sample_info)
{	FILE *fp;
	DISK_STATUS s;
    	fp = fopen(filename, "rb");
    	if(fp == NULL)
		return OPEN_FAILED;
	if ( (s=read_sample(fp,	16,
				file_len(fp) >> 1,
				DEFAULT_FREQUENCY,
				sample_info)) != SUCCESS)
		return s;
	sample_info->format = BITS16_SIGNED;
 	fclose(fp);
    	return SUCCESS;
}

DISK_STATUS read_raw_16u(char *filename,Generic_SampleInfo *sample_info)
{	FILE *fp;
	DISK_STATUS s;
    	fp = fopen(filename, "rb");
    	if(fp == NULL)
		return OPEN_FAILED;
	if ( (s=read_sample(fp,	16,
				file_len(fp) >> 1,
				DEFAULT_FREQUENCY,
				sample_info)) != SUCCESS)
		return s;
	sample_info->format = BITS16_UNSIGNED;
 	fclose(fp);
    	return SUCCESS;
}
