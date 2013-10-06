#include <stdio.h>
#include "defs.h"
#include "targa.h"
#include "biq.h"
#include "codec.h"


void transform(struct targa * src, struct biqstruct * dst, uint numlevels, float q) {
	
	uint i;

	/* Variables for color rematching */
	uint x,y;	
	uint diff;
	uchar * tmp;
	uchar match;	
	struct rgb pixel;
	
	switch(src->type) {
		
		/* 8bpp greyscale */
		case 0x03:
			for (i=1;i<=numlevels;i++) 
				DWT(src->pels,dst->coeff,src->width,src->height,i, q/((i==1)? 1:((i-1)*2)));
			break;
			
		/* 24bpp RGB */
		case 0x02:
			for (i=1;i<=numlevels;i++) {
				DWT(src->pels,dst->coeff,src->width,src->height,i, q/((i==1)? 1:((i-1)*2)));
				DWT(src->pels+src->width*src->height,dst->coeff+src->width*src->height,src->width,src->height,i, q/((i==1)? 1:((i-1)*2)));
				DWT(src->pels+2*src->width*src->height,dst->coeff+2*src->width*src->height,src->width,src->height,i, q/((i==1)? 1:((i-1)*2)));
			}
			break;
			
		/* 8bpp color mapped, complex method using color-rematching and a lossless
		   coder after DWT+quant+iDWT */
		case 0x01:
			for (i=1;i<=numlevels;i++) {
				DWT(src->pels,dst->coeff,src->width,src->height,i, q/((i==1)? 1:((i-1)*2)));
				DWT(src->pels+src->width*src->height,dst->coeff+src->width*src->height,src->width,src->height,i, q/((i==1)? 1:((i-1)*2)));
				DWT(src->pels+2*src->width*src->height,dst->coeff+2*src->width*src->height,src->width,src->height,i, q/((i==1)? 1:((i-1)*2)));
			}
			
			i = numlevels;
			do {
				iDWT(dst->coeff,src->pels,src->width,src->height,i);
				iDWT(dst->coeff+src->width*src->height,src->pels+src->width*src->height,src->width,src->height,i);
				iDWT(dst->coeff+2*src->width*src->height,src->pels+2*src->width*src->height,src->width,src->height,i);
			} while (--i);


			/* Rematch colors by finding the closest color ramp matches */
			
#ifdef COLOR_CASHING
			/* Initialize hashing table */
			for (i=0;i<=RGB_COLORS;i++) rgb_cash[i] = -1;
#endif
			
			tmp = src->pels;
			for (i=0;i<src->width*src->height;i++) {

				/* Read one pixel from the reconstructed image */
				pixel.b = tmp[2*src->width*src->height];
				pixel.g = tmp[src->width*src->height];				
				pixel.r = *tmp;
				
				
#ifdef COLOR_CASHING
				/* Pick entry from 5-6-5 RGB hashing table */
				if (rgb_cash[(((ushort)pixel.r>>(8-R_BITS))<<R_SHIFT)|
							 (((ushort)pixel.g>>(8-G_BITS))<<G_SHIFT)|
							 (pixel.b>>(8-B_BITS)/*<<B_SHIFT*/)] != -1)
					match = rgb_cash[(((ushort)pixel.r>>(8-R_BITS))<<R_SHIFT)|
							 (((ushort)pixel.g>>(8-G_BITS))<<G_SHIFT)|
							 (pixel.b>>(8-B_BITS)/*<<B_SHIFT*/)];
				else
#endif
				{
					match = 0;
					diff  = 0x7fff;
				
					/* Search CLUT for closest match*/
					for(x=0;x<256;x++) {
						if ((abs(src->clut[x].r-pixel.r)+
						     abs(src->clut[x].g-pixel.g)+
						     abs(src->clut[x].b-pixel.b)) <= diff) {
								
						diff = abs(src->clut[x].r-pixel.r)+
						       abs(src->clut[x].g-pixel.g)+
					    	   abs(src->clut[x].b-pixel.b);
						match = x;
						}
					}
#ifdef COLOR_CASHING
					/* Save match in table */
					rgb_cash[(((ushort)pixel.r>>(8-R_BITS))<<R_SHIFT)|
							 (((ushort)pixel.g>>(8-G_BITS))<<G_SHIFT)|
							 (pixel.b>>(8-B_BITS)/*<<B_SHIFT*/)] =
					match;
#endif
				}
				
				*tmp++ = match;
				
			}
	
			/* Losslessly encode image now */
			for (i=1;i<=numlevels;i++)
				DWTl(src->pels,dst->coeff,src->width,src->height,i);
			
		default:			
			break;
	}
	
}


void retransform(struct biqstruct * src, struct targa * dst, uint numlevels) {
	
	switch(dst->type) {
		
		/* 8bpp greyscale */
		case 0x03:
			do {
				iDWT(src->coeff,dst->pels,src->width,src->height,numlevels);
			} while (--numlevels);
			break;
			
		/* 24bpp RGB */
		case 0x02:
			do {
				iDWT(src->coeff,dst->pels,src->width,src->height,numlevels);
				iDWT(src->coeff+src->width*src->height,dst->pels+src->width*src->height,src->width,src->height,numlevels);
				iDWT(src->coeff+2*src->width*src->height,dst->pels+2*src->width*src->height,src->width,src->height,numlevels);
			} while (--numlevels);
			break;
			
		/* 8bpp color mapped */
		case 0x01:
			do {
				iDWTl(src->coeff,dst->pels,src->width,src->height,numlevels);
			} while (--numlevels);

		default:
			break;
	}
	
}



void DWT(uchar src[], char dst[], uint width, uint height, uint scale, float quant) {

	uchar * src2 = src;
	char * dst2 = dst;
	
	uint x;
	uint y;
	
	/* Compute dimensions of the subbands */
	uint w=width>>scale;
	uint h=height>>scale;
	
	short x0,x1,x2,x3;		/* Input vector */
	short y0,y1,y2,y3;		/* Transformed vector */
	
	short peak[3]= { 0,0,0 };

	for (y=0;y<h;y++) {
		for (x=0;x<w;x++) {

			/* Source signal */
			x2 = src[width];
			x0 = *src++;					
			x3 = src[width];
			x1 = *src++;

			/* 'Hardcoded' 2x2 Tap Haar DWT */
			y0 = (2 + x0 + x1 + x2 + x3) >> 2;
			y1 = (2 + x0 - x1 + x2 - x3) >> 2;
			y2 = (2 + x0 + x1 - x2 - x3) >> 2;
			y3 = (2 + x0 - x1 - x2 + x3) >> 2;

			dst[0]			= USAT8(y0);
			dst[w]			= SAT8(y1);
			dst[width*h]	= SAT8(y2);
			dst[width*h+w]	= SAT8(y3);
			dst++;

			/* Find peak values for quantization (high frequency bands) */
			if (labs(y1)>peak[0]) peak[0]=labs(y1);
			if (labs(y2)>peak[1]) peak[1]=labs(y2);
			if (labs(y3)>peak[2]) peak[2]=labs(y3);

		}
		dst+=(width-w);
		src+=((width<<1)-(w<<1));
	}

	/* Quantize peaks values */
	peak[0] = (ushort)(0.5f+peak[0]*quant);
	peak[1] = (ushort)(0.5f+peak[1]*quant);
	peak[2] = (ushort)(0.5f+2*peak[2]*quant);
	
	/* Quantize subbands */
	quantize(dst2,w<<1,h<<1,width,peak);	/**** MERGE THESE TWO!! */
	copyRect(dst2,src2,w<<1,h<<1,width);	/************************/
}


void DWTl(uchar src[], uchar dst[], uint width, uint height, uint scale) {

	uchar * src2 = src;
	uchar * dst2 = dst;
	
	uint x;
	uint y;
	
	uint w=width>>scale;
	uint h=height>>scale;
	
	uchar x0,x1,x2,x3;
	
	for (y=0;y<h;y++) {
		for (x=0;x<w;x++) {

			/* Source signal */
			x2 = src[width];
			x0 = *src++;					
			x3 = src[width];
			x1 = *src++;

			/* Lossless 2x2 delta decomposition */
			dst[0]			= x0;
			dst[w]			= x1 - x0;	/* horizontal delta */
			dst[width*h]	= x2 - x0;  /* vertical delta */
			dst[width*h+w]	= x3 - x0;  /* diagonal delta */
			dst++;

		}
		dst+=(width-w);
		src+=((width<<1)-(w<<1));
	}

	copyRect(dst2,src2,w<<1,h<<1,width);
}


void quantize(char src[], uint src_w, uint src_h, uint pelsperrow, short peaks[]) {

	int x;
	int y;


	/* Quantize bands by clamping samples below the given
	   minimum amplitudes */
	for (y=0;y<(src_h>>1);y++) {
		for (x=0;x<(src_w>>1);x++) {

			/* LH bank */
			if (abs(src[src_w>>1])<peaks[0])
				src[src_w>>1] = 0;
			
			/* HL bank */
			if (abs(src[pelsperrow*(src_h>>1)])<peaks[1])
				src[pelsperrow*(src_h>>1)] = 0;
			
			/* HL bank */
			if (abs(src[pelsperrow*(src_h>>1)+(src_w>>1)])<peaks[2])
				src[pelsperrow*(src_h>>1)+(src_w>>1)] = 0;

			/* Skip LL bank */				
			src++;
		}
		src += pelsperrow-(src_w>>1);
	}
}


void iDWT(char src[], uchar dst[], uint width, uint height, uint scale) {
             
	uint x;
	uint y;

	uchar * src2 = src;
	uchar * dst2 = dst;
	
	short x0,x1,x2,x3;
	short y0,y1,y2,y3;
	
	/* Compute dimensions of the source banks */
	uint w=(width>>scale);
	uint h=(height>>scale);
	
	/* Perform 2x2 iDWT */
	for (y=0;y<h;y++) {
		for (x=0;x<w;x++) {

			x1 = src[w];
			x2 = src[h*width];
			x3 = src[h*width+w];
			x0 = (uchar)(*src++);

			y0 = x0 + x1 + x2 + x3;
			y1 = x0 - x1 + x2 - x3;
			y2 = x0 + x1 - x2 - x3;
			y3 = x0 - x1 - x2 + x3;

			dst[width] = USAT8(y2);
			*dst++     = USAT8(y0);
			dst[width] = USAT8(y3);
			*dst++     = USAT8(y1);
						
		}
		
		/* Skip remaining pixels */
		src += width-w;
		dst += (width<<1)-(w<<1);
	}
	
	/* Copy back reconstructed LL bank into source image */
	copyRect(dst2,src2,w<<1,h<<1,width);	
}


void iDWTl(uchar src[], uchar dst[], uint width, uint height, uint scale) {
             
	uint x;
	uint y;

	uchar * src2 = src;
	uchar * dst2 = dst;
	
	uchar x0,x1,x2,x3;
	
	uint w=(width>>scale);
	uint h=(height>>scale);
	
	for (y=0;y<h;y++) {
		for (x=0;x<w;x++) {

			x1 = src[w];
			x2 = src[h*width];
			x3 = src[h*width+w];
			x0 = *src++;

			dst[width] = x2 + x0;
			*dst++     = x0;
			dst[width] = x3 + x0;
			*dst++     = x1 + x0;
						
		}
		
		src += width-w;
		dst += (width<<1)-(w<<1);
	}

	copyRect(dst2,src2,w<<1,h<<1,width);	
}


void copyRect(uchar src[], uchar dst[], uint width, uint height, uint pelsperrow) {
	
	uint x;
	uint y;
	for (y=0;y<height;y++) {
		for (x=0;x<width;x++) *(dst++) = *(src++);
		
		/* Skip the remaining source/destination pixels along the scanline */
		src+=pelsperrow-width;
		dst+=pelsperrow-width;
	}
}
