/////////////////////////////////////////////////////////////////////////////
//
//  This file is Copyright 1992,1993 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#include "img_decl.h"

 
int IMG::Write(const char *fn,int PatLen=2)
{
#define REPEATLINE(n) fputc(0,f); fputc(0,f); fputc(0xFF,f); fputc(n,f); //printf("%d repeated lines\n",n);
#define SOLIDRUN1(n) fputc(n|0x80,f); //printf("%d bytes all black\n",n);
#define SOLIDRUN0(n) fputc(n,f); //printf("%d bytes all white\n",n);
#define LITERAL(n) fputc(0x80,f); fputc(n,f); for (int l=n; l; l--) fputc(From[lineb++],f); //printf("%d literal bytes\n",n);
#define PATTERN(n) fputc(0,f); fputc(n,f); for (int p=0; p<PatLen; p++) fputc(From[lineb+p],f); //printf("%d byte pattern x %d\n",PatLen,n);

	FILE *f=fopen(fn,"wb");

	if (!f) return 0;

	IMGfileheader header;

	header.version=1;
	header.length=(sizeof(IMGfileheader)+(palette ? sizeof(XIMGextension)+sizeof(VDIRGB)*(1<<Depth()) : 0))/sizeof(short); // (in *words*)
	header.planes=Depth();
	header.patternlen=PatLen;
	header.uW=uW;
	header.uH=uH;
	header.W=Width();
	header.H=Height();
	fwrite(&header,sizeof(header),1,f);
	int bW=Bpad(Width());
	int unused_at_line_end=WordWidth()*2-bW;

	if (palette) {
		// XIMG
		XIMGextension ximg_ext;
		ximg_ext.magic[0]=XIMGmagic[0];
		ximg_ext.magic[1]=XIMGmagic[1];
		ximg_ext.magic[2]=XIMGmagic[2];
		ximg_ext.magic[3]=XIMGmagic[3];
		ximg_ext.col_format=XIMGrgb;
		fwrite(&ximg_ext,sizeof(ximg_ext),1,f);
		fwrite(palette->RawVDIRGBs(),sizeof(VDIRGB),1<<Depth(),f);
	}

	const int bW_scanline=bW*Depth();
	unsigned char scanline_buffer[bW_scanline];
	unsigned char *data_in=(unsigned char *)StdMFDB()->fd_addr;
	const int planesep=(bW+unused_at_line_end)*Height();

	for (int h=0; h<Height(); h++) {
		// Prepare a scanline.
		for (int b=0; b<bW; b++) {
			for (int plane=0; plane<Depth(); plane++) {
				scanline_buffer[b+plane*bW]=data_in[b+plane*planesep];
			}
		}
		unsigned char *From=scanline_buffer;

		//printf("byte %d\n",From-data);

		// Check for repeats of this line.
		bool same=true;
		int rep=0;
		while (same && h+rep+1<Height()) {
			for (int plane=0; plane<Depth() && same; plane++) {
				for (int i=bW; i-- && same; ) {
					if (data_in[plane*planesep+i] != data_in[plane*planesep+i+bW+unused_at_line_end]) {
						same=false;
					}
				}
			}
			if (same) {
				rep++;
				data_in+=bW+unused_at_line_end;
			}
		}

		if (rep) {
			h+=rep;
			REPEATLINE(rep+1);
		}

		int lineb=0;
		int bW_nextline=bW;
		while (lineb<bW_scanline) {
			if (From[lineb]) {
				if (From[lineb]==0xFF) {
				  int i;
					for (i=0; lineb<bW_nextline && i<127 && From[lineb]==0xFF; i++) lineb++;
					SOLIDRUN1(i);
				} else {
					unsigned char *NextPat=From;
					int pat=0;
					int nlineb=lineb;
					while (pat<127 && nlineb+PatLen<=bW_nextline && From[lineb]==NextPat[nlineb]) {
						//printf("Pattern? (nlineb=%d lineb=%d)\n",nlineb,lineb);
						NextPat=NextPat+PatLen;
						int i=PatLen-1;
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
					  int nlit;
					  
						for (nlit=0;

							nlit<255 &&
							lineb+nlit<bW_nextline &&
							(From[lineb+nlit] || lineb+nlit+1==bW_nextline || From[lineb+nlit+1]) &&
							(From[lineb+nlit]!=0xFF || lineb+nlit+1==bW_nextline || From[lineb+nlit+1]!=0xFF);

							nlit++);
						LITERAL(nlit);
					}
				}
			} else {
			  int i;
				for (i=0; lineb<bW_nextline && i<127 && !From[lineb]; i++) lineb++;
				SOLIDRUN0(i);
			}
			if (lineb >= bW_nextline) bW_nextline+=bW;
		}

		data_in+=bW+unused_at_line_end;
	}

	fclose(f);

	return 1;
}
