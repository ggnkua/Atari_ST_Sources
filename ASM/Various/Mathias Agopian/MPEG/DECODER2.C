
/************************/
/* D‚codeur MPEG audio	*/
/* Couche I st‚r‚o.		*/
/* -------------------- */
/* AGOPIAN Mathias		*/
/* Pour STMAG			*/
/************************/

#include <stdio.h>
#include <tos.h>
#include <math.h>

#include "defines.h"
#include "mpeg.h"
#include "decoder.h"


#define DEF_READ_SIZE	65536L

char *file="MPEG.LOD";

int DspParBlk[768*2];

int init_dsp(void)
{
	int ability,status;
	char *adr;
	
	adr=Malloc(16384L);
	if (adr)
	{
		dsptristate(1,1);
		ability=Dsp_RequestUniqueAbility();
		status=Dsp_LoadProg(file,ability,adr);
		if (status)
		{
			printf("\nFichier %s introuvable.\nAppuyez sur une touche.",file);
			Bconin(2);
			Mfree(adr);
			return 0;
		}			
		Mfree(adr);
		return 1;
	}
	return 0;
}

void init_mpeg_decoder(void)
{
	buffoper(0);
	soundcmd(4,2);
	soundcmd(5,0);
	setmode(1);
	settracks(0,0);
	devconnect(1,8,0,2,1);
}

void decode_mpeg_sequence(char *filename)
{
	long stack;
	long READ_SIZE;
	MPEG_AUDIO_HEADER *header;
	char *ptr_frame;
	int eof,source;
	int frame_length,header_length;
	int frame_length_base,header_length_base;
	long fpos;
	long read;
	long maxmem;
	long flen;

	/* Ouverture des fichiers */
	
	source=(int)Fopen(filename,FO_READ);
	
	if (source>0)
	{

		/* Memoire */
	
		flen=Fseek(0,source,2);
		maxmem=(long)Malloc(-1L);
		if (flen<=maxmem)	READ_SIZE=maxmem;
		else				READ_SIZE=DEF_READ_SIZE;
		ptr_frame=Malloc(READ_SIZE);


		/* lire les donn‚es de la 1ere trame */
		/* on considere que les autres trames sont */
		/* identiques (meme couche, meme d‚bit) */

		Fseek(0,source,0);
		read=Fread(source,READ_SIZE,ptr_frame);
		eof=0;
		header=(MPEG_AUDIO_HEADER *)ptr_frame;
		header_length_base=4;
		frame_length_base=(int)trunc((48.0*debit_tbl[header->debit])/frequence_tbl[header->frequence]);
		frame_length_base&=~0x3;
		fpos=0;
	}


	if (source>0)
	{
		stack=Super(0L);
		while(!eof)
		{
			/* Calcul de quelques variables utiles */
					
			frame_length=frame_length_base;
			header_length=header_length_base;

			if (header->padding)		frame_length+=4;
			if (!header->crc_check)		header_length+=2;
		
			/* Lecture & d‚codage de la trame */

			if ((read-(fpos+header_length))<frame_length)
			{
				Fseek(-(read-fpos),source,1);
				read=Fread(source,READ_SIZE,ptr_frame);
				eof=(read<=0);
				fpos=0;
			}
			
			if (!eof)
			{
				decode_mpeg((char *)((long)ptr_frame+fpos+header_length));
				fpos+=frame_length;			
				header=(MPEG_AUDIO_HEADER *)((long)ptr_frame+fpos);
			}
		}
		Super((void *)stack);

		Fclose(source);
		Mfree(ptr_frame);
	}
	soundcmd(4,1);
}


/****************************************************************************/
/*																			*/
/*	decode_mpeg()															*/
/*																			*/
/*	Fonction:	Routine principale de d‚codage d'une trame MPEG audio		*/
/*				en couche I.												*/
/*																			*/
/****************************************************************************/

void decode_mpeg(char *frame)
{
	static uchar ScaleFactors[32][2];
	static uchar numBitsAlowed[32][2];
	
	get_numBitsAlowed_I(numBitsAlowed,frame);
	get_ScaleFactors(ScaleFactors,numBitsAlowed,frame);
	get_samples(DspParBlk,numBitsAlowed,frame);
	while(!Dsp_Hf3());									/* Attendre le DSP */
	My_Dsp_BlkBytes(numBitsAlowed,64);					/* Envoie le nombre de bits allou‚s */
	My_Dsp_BlkBytes(ScaleFactors,64);					/* Envoie les index de facteurs d'‚chelles */
	My_Dsp_BlkWords(DspParBlk,768);						/* Envoie les ‚chantillons */
}
