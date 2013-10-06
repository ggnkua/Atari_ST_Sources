#ifndef CODEC_H
#define CODEC_H


#define min(a,b) ((a)<(b))? (a):(b)
#define max(a,b) ((a)>(b))? (a):(b)

/* Saturate given value to 8bits (unsigned, signed) */
#define USAT8(v) (min( max(0,v) , 0xff))
#define SAT8(v) (USAT8(128+v)-128)


/* Number of resolution levels in the DWT */
#define L 6

/* Uncomment this line if you want significant faster color rematching */
#define COLOR_CASHING

#ifdef COLOR_CASHING
#define R_BITS 5
#define G_BITS 6
#define B_BITS 5
#define RGB_BITS (R_BITS+G_BITS+B_BITS)

#define R_SHIFT (RGB_BITS-R_BITS)
#define G_SHIFT (RGB_BITS-R_BITS-G_BITS)
#define B_SHIFT (RGB_BITS-R_BITS-G_BITS-B_BITS)

#define RGB_COLORS (1<<RGB_BITS)
int rgb_cash[RGB_COLORS];
#endif


/*!
	\brief Main BIQ encoding method.
	
*/
void transform(struct targa * src, struct biqstruct * dst, uint numlevels, float q);


/*!
	\brief Main BIQ decoding method.
	
	Reconstruct the source image by iteratively reconstructing the given banks
	storing the result back into the specified targa target. numlevels reflects
	the number of sub levels present in the set of source filter banks.
*/
void retransform(struct biqstruct * src, struct targa * dst, uint numlevels);


/*!
	\brief Wavelet subband coder and quantizer
	
	Decompose the given source signal into four subbands (particularly LL, LH,
	HL and HH banks) using a simple 2x2 haar wavelet. The result will be
	stored back into the source array, so the process can be recursively
	repeated, yielding to a quad-tree subdivision of the original signal into
	its frequency domain where unimportant contents can easily be removed.
	tmp needs to provide a temporary buffer that is of the same dimensions as
	the source image.
*/
void DWT(uchar src[], char tmp[], uint src_w, uint src_h, uint pelsperrow, float quant);


/*!
	\brief Wavelet subband coder, lossless
	
	Same as DWT() in a lossless version for colormapped images.
*/
void DWTl(uchar src[], uchar tmp[], uint src_w, uint src_h, uint pelsperrow);


/*!
	\brief Perform quantization on a set of filterbanks
	
	Quantize the given source signal by clamping all sample values below the
	given amplitude thresholds. This way redundant image information can easily
	be removed without destroying the image's context.
*/
void quantize(char src[], uint src_w, uint src_h, uint pelsperrow, short peaks[]);


/*!
	\brief Inverse wavelet transform
	
	Reconstruct a lower order LL bank by recombining the source's subbands
    and store the result into the destination array. width, height specify
	the destination signal's dimensions while scale determines log2 of the
	current rectangular sampling rate + 1 (i.e. resolution level).
*/
void iDWT(char src[], uchar dst[], uint width, uint height, uint scale);


/*!
	\brief Inverse wavelet transform, lossless

	Same as	iDWT() in a lossless version for colormapped images.
*/
void iDWTl(uchar src[], uchar dst[], uint width, uint height, uint scale);


/*!
	\brief Copy a rectangular area from one image into another
	
	width, height are supposed to specify the area's rect while pelsperrow
	gives the number of pixels per row. Note: both the source and destination
	image must be of the same size.
*/
void copyRect(uchar src[], uchar dst[], uint width, uint height, uint pelsperrow);

#endif
