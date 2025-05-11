/////////////////////////////////////////////////////////////////////////////
//
//  This file is Copyright 1992,1993 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#include "img.h"

#include <stdio.h>
#include <builtin.h>

#define SEEK_CUR 1

inline int Bpad(int x) { return (x+7)>>3; }


static void readIMG(unsigned char*,int patlen,int bW,int H,FILE*);

struct IMGfileheader
{
	short version;
	short length;
	short planes;
	short patternlen;
	short uW,uH;
	short W,H;
};
 
IMG::IMG(int w,int h,int d) :
	W(w), H(h), D(d),
	bW(Bpad(w)), uW(85), uH(85),
	data(new unsigned char[H*bW]),
	Cursor(0),
	bit(TOPBIT),
	External(FALSE)
{ }

IMG::IMG(unsigned char* At,int w,int h,int d) :
	W(w), H(h), D(d),
	bW(Bpad(w)), uW(85), uH(85),
	data(At),
	Cursor(0),
	bit(TOPBIT),
	External(TRUE)
{ }

IMG::IMG(const char *fn) :
	Cursor(0),
	data(0),
	bit(TOPBIT),
	External(FALSE)
{
	FILE *f=fopen(fn,"rb");

	if (!f) return;

	IMGfileheader header;
	fread(&header,sizeof(header),1,f);

	if (header.length*sizeof(short)!=sizeof(header))
		fseek(f,header.length*sizeof(short)-sizeof(header),SEEK_CUR);

	W=header.W;
	H=header.H;
	D=header.planes;
	bW=Bpad(W);
	uW=header.uW;
	uH=header.uH;
	data=new unsigned char[H*bW];

	readIMG(data,header.patternlen,bW,uH,f);

	fclose(f);
}

IMG::~IMG()
{
	if (!External) delete data;
}


static
void readIMG(unsigned char* bitmap,int patlen,int bW,int H,FILE* f)
{
	int c;
	int linerep=0;
	int thisln=bW;

	while (EOF!=(c=fgetc(f))) {
		switch (c) {
			case 0:
				int n;
				if (EOF!=(n=fgetc(f))) {
					if (n) { // Repeating pattern
						fread(bitmap,patlen,1,f);
						bitmap+=patlen;
						thisln-=patlen;
						while (--n) {
							unsigned char *from=bitmap-patlen;
							for (int pn=patlen; pn; pn--) *bitmap++=*from++;
							thisln-=patlen;
						}
					} else { // Next scanline repeats
						n=fgetc(f); // Should be 0xff
						n=fgetc(f);
						linerep+=n-1; // REPEATs, not total number
					}
				}
		break;	case 0x80: // Literal
				int nl;
				if (EOF!=(nl=fgetc(f))) {
					fread(bitmap,nl,1,f);
					bitmap+=nl;
					thisln-=nl;
				}
		break;	default: // Solid run
				unsigned char pat=((c&0x80) ? 0xff : 0);
				int nsol=c&0x7f;
				thisln-=nsol;
				while (nsol--) *bitmap++=pat;
		}
		while (thisln<=0) {
			thisln+=bW;
			H--;
			while (linerep) {
				unsigned char *from=bitmap-bW;
				for (int lineb=0; lineb<bW; lineb++) *bitmap++ = *from++;
				H--;
				linerep--;
			}
		}
	}
}


int IMG::Save(const char *fn,int PatLen=2)
{
#define REPEATLINE(n) fputc(0,f); fputc(0,f); fputc(0xFF,f); fputc(n,f); //printf("%d repeated lines\n",n);
#define BLACK(n) fputc(n|0x80,f); //printf("%d bytes all black\n",n);
#define WHITE(n) fputc(n,f); //printf("%d bytes all white\n",n);
#define LITERAL(n) fputc(0x80,f); fputc(n,f); for (int l=n; l; l--) fputc(From[lineb++],f); //printf("%d literal bytes\n",n);
#define PATTERN(n) fputc(0,f); fputc(n,f); for (int p=0; p<PatLen; p++) fputc(From[lineb+p],f); //printf("%d byte pattern x %d\n",PatLen,n);

	FILE *f=fopen(fn,"wb");

	if (!f) return 0;

	IMGfileheader header;

	header.version=1;
	header.length=8;
	header.planes=1;
	header.patternlen=PatLen;
	header.uW=uW;
	header.uH=uH;
	header.W=W;
	header.H=H;
	fwrite(&header,sizeof(header),1,f);

	unsigned char *From=data;

	for (int h=0; h<H; h++) {
		//printf("byte %d\n",From-data);

		unsigned char *Next;
		int i=0;

		//Check for repeats of this line.
		Next=From+bW;
		int rep=0;
		while (h+rep<H && From[i]==Next[i]) {
			i=bW-1;
			while (i && From[i]==Next[i]) i--;
			if (From[i]==Next[i]) {
				rep++;
				Next=Next+bW;
			}
		}

		if (rep) {
			h+=rep;
			REPEATLINE(rep+1);
		}

		int lineb=0;
		while (lineb<bW) {
			if (From[lineb]) {
				if (From[lineb]==0xFF) {
					for (i=0; lineb<bW && i<127 && From[lineb]==0xFF; i++) lineb++;
					BLACK(i);
				} else {
					unsigned char *NextPat=From;
					int pat=0;
					int nlineb=lineb;
					while (pat<127 && nlineb+PatLen<=bW && From[lineb]==NextPat[nlineb]) {
						//printf("Pattern? (nlineb=%d lineb=%d)\n",nlineb,lineb);
						NextPat=NextPat+PatLen;
						i=PatLen-1;
						while (i && From[i+lineb]==NextPat[i+nlineb]) i--;
						if (From[i+lineb]==NextPat[i]+nlineb) {
							pat++;
							nlineb+=PatLen;
						}
					}
					if (pat) {
						PATTERN(pat);
						lineb=nlineb;
					} else {
						for (int nlit=0;

							nlit<=255 &&
							lineb+nlit<bW &&
							(From[lineb+nlit] || lineb+nlit+1==bW || From[lineb+nlit+1]) &&
							(From[lineb+nlit]!=0xFF || lineb+nlit+1==bW || From[lineb+nlit+1]!=0xFF);

							nlit++);
						LITERAL(nlit);
					}
				}
			} else {
				for (i=0; lineb<bW && i<127 && !From[lineb]; i++) lineb++;
				WHITE(i);
			}
		}
		From=Next;
	}

	return 1;
}

void IMG::operator|= (const IMG& other)
// Assumes same size
{
	int size=bW*H;
	while (size--) data[size]|=other.data[size];
}

void IMG::Clear(int colour=0)
{
	int b=colour ? 0xFF : 0;
	int size=bW*H;
	while (size--) data[size]=b;
}
