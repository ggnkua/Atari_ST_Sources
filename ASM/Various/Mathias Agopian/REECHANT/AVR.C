#include <tos.h>
#include <stdio.h>
#include <string.h>
#include <ext.h>

#include "avr.h"

int CalcNumBytes(int bits);

int open_sample(char *name,FALCON_SPL *interne,unsigned long position)
{
	int fh;		
	AVR_HEADER avr;
	
	if (Fsfirst(name,0)==0)
	{
		fh=(int)Fopen(name,FO_READ);
		if (fh)
		{
			Fseek(position,fh,0);
			Fread(fh,sizeof(avr),&avr);
			if (avr.avrID=='2BIT')
			{
				interne->numBits	=	avr.numBits;
				interne->numBytes	=	CalcNumBytes(interne->numBits);
				interne->numVoices	=	((avr.numVoices==0) ? (1) : (2));				
				interne->Length		=	(avr.Length*(interne->numVoices))*(interne->numBytes);
				interne->Frequence	=	(long double)(avr.FreqType.Frequence & 0xFFFFFFL);
				if (interne->Frequence==0)
				{
					interne->Frequence=AVR_Freq_list[avr.FreqType.FreqReplay];
				}
				interne->numFrames	=	avr.Length;
				interne->intel		=	0;
				interne->start_offset = 0;
				return fh;
			}
		}
	}
	return 0;
}


int CalcNumBytes(int bits)
{
	if (bits<=8)		return	1;
	else if (bits<=16)	return 	2;
	else if (bits<=24)	return	3;
	return 4;
}
