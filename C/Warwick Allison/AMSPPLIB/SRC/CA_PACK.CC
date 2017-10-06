//////////////////////////////////////////////////////////////////////////////
//
//  This file is part of the Atari Machine Specific Library,
//  and is Copyright 1992 by Warwick W. Allison.
//
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.
//
//////////////////////////////////////////////////////////////////////////////

/**********************************************************\
 *                                                        *
 *  CrackArt file compressor.                             *
 *   by Warwick Allison, May 8th 1992.                    *
 *                                                        *
 *  Reverse engineered from compressor routine:           *
 *                                                        *
 * ; CRACK ART Kompressionsroutine fr Bilddaten (CA?)    *
 * ; Copyright ½ Detlef R”ttger 04.03.1990                *
 *                                                        *
 *  The full file format (in bytes) is:                   *
 *       'C', 'A', 1, Rez, Colours x 2, Data              *
 *                                                        *
 *  Compressions Codes:                                   *
 *   Esc Esc          = One Esc byte                      *
 *   Esc 2 0          = Delta to end                      *
 *   Esc 2 Hi Lo      = HiLo+1 repeated Deltas (HiLo>255) *
 *   Esc 1 Hi Lo byte = HiLo+1 repeated bytes (HiLo>255)  *
 *   Esc 0 Esc byte   = Esc+1 repeated byte               *
 *   Esc Count byte   = Count+1 repeated byte (Count>2)   *
 *   Byte             = Literal byte                      *
 *                                                        *
\**********************************************************/

#include "ca_pack.h"
#include <values.h>


const unsigned char Zero=0;
const unsigned char One=1;
const unsigned char Two=2;

int Compress(unsigned char Esc,unsigned char Delta,short Offset,unsigned char* From,int nel,FILE *f)
// f=0 implies dry run.  Returns size of output.
{
	int Size=0;

	int basei=0;
	int i=basei;
	int count=nel;
	while (count) {
		unsigned char b=From[i];
		int newi=i,newbasei=basei;
		for (int N=0; N<count && From[newi]==b; N++) {
			newi+=Offset;
			if (newi>=nel) {
				newbasei++;
				newi=newbasei;
			}
		}

		if (N==count && b==Delta) {
			// Dumb, hacky compression special-case in CrackArt
			if (f) {
				fwrite(&Esc,sizeof(unsigned char),1,f);
				fwrite(&Two,sizeof(unsigned char),1,f);
				fwrite(&Zero,sizeof(unsigned char),1,f);
			}
			Size+=3;
			count=0;
		} else {
			if (N>3) {
				i=newi;
				basei=newbasei;
				if (N<=256) {
					unsigned char n=N-1;
					if (f) fwrite(&Esc,sizeof(unsigned char),1,f);
					if (n==Esc) {
						Size++;
						if (f) fwrite(&Zero,sizeof(unsigned char),1,f);
					}
					if (f) {
						fwrite(&n,sizeof(unsigned char),1,f);
						fwrite(&b,sizeof(unsigned char),1,f);
					}
					Size+=3;
					count-=N;
				} else {
					if (N>65536) N=65536;
					unsigned short n=N-1;

					if (f) fwrite(&Esc,sizeof(unsigned char),1,f);
					if (b==Delta) {
						if (f) {
							fwrite(&Two,sizeof(unsigned char),1,f);
							fwrite(&n,sizeof(unsigned short),1,f);
						}
					} else {
						if (f) {
							fwrite(&One,sizeof(unsigned char),1,f);
							fwrite(&n,sizeof(unsigned short),1,f);
							fwrite(&b,sizeof(unsigned char),1,f);
						}
						Size++;
					}
					Size+=4;
					count-=N;
				}
			} else {
				if (b==Esc) {
					if (f) fwrite(&Esc,sizeof(unsigned char),1,f);
					Size++;
				}
				if (f) fwrite(&b,sizeof(unsigned char),1,f);
				Size++;
				i+=Offset;
				if (i>=nel) {
					basei++;
					i=basei;
				}
				count--;
			}
		}
	}

	return Size;
}

short GoodOffset[]={160,80,320,8,4,640,2,1,480,0}; // 0 terminated.

void SaveCrackArtData(unsigned char* From, int nel, FILE* f, int Compression)
{
	int Freq[256];
	unsigned char Esc;
	unsigned char Delta;
	int MinF=MAXINT;
	int MaxF=MININT;
	int i;

	for (i=0; i<256; i++) Freq[i]=0;

	for (i=0; i<nel; i++) Freq[From[i]]++;

	for (i=0; i<256; i++) {
		if (Freq[i]<=MinF) {  // "<=" rather than "<" to act like CrackArt
			MinF=Freq[i];
			Esc=i;
		}
		if (Freq[i]>MaxF) {
			MaxF=Freq[i];
			Delta=i;
		}
	}

	int MinSize=MAXINT;
	short Offset=GoodOffset[0];

	// Only testing one is pointless (might as well just use it).
	if (Compression) Compression++;

	for (i=0; i<Compression && GoodOffset[i]; i++) {
		int Size=Compress(Esc,Delta,GoodOffset[i],From,nel,0);
		if (Size<MinSize) {
			MinSize=Size;
			Offset=GoodOffset[i];
		}
	}

	fwrite(&Esc,sizeof(Esc),1,f);
	fwrite(&Delta,sizeof(Delta),1,f);
	fwrite(&Offset,sizeof(Offset),1,f);

	Compress(Esc,Delta,Offset,From,nel,f);
}
