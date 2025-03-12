#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>
#include <FreeImage.h>


typedef unsigned int u32;

u32 g_texture_height = 0;
u32 g_texture_width = 0;

// -----------------------------------------------------------------------------------------

u32 ConvertPixel ( float r, float g, float b )
{
    float u =  1 - g ;
    float v =  r ;

    if ( b < 0.999 )
    {
        u = 0;
        v = 0;
    }

    if ( u < 0.0 ) u = 0;
    if ( v < 0.0 ) v = 0;

    if ( u > 1 ) u = 1;
    if ( v > 1 ) v = 1;

    unsigned int pixel1 =   ((int)(  u * ( g_texture_height -1 ) + 0.5 ) * g_texture_width )   ;
    unsigned int pixel2 =   v * g_texture_width ;
    unsigned int pixel = pixel1 + pixel2;

    if ( g_texture_height*g_texture_width < pixel )
    {
      //  pixel = 0;
    }

    if ( pixel > 0xffff )
    {
        printf ("Texture dimensions too large for this offset size.");
        exit(0);
    }

    return pixel;
}

// -----------------------------------------------------------------------------------------

void StoreMotorola( unsigned short val, unsigned short* pDest )
{
    unsigned char *pTemp = (unsigned char*) pDest;
    pTemp[0] = ( val >> 8 ) & 0xff ;
    pTemp[1] = ( val ) & 0xff ;
}

// -----------------------------------------------------------------------------------------

int main(int argc, char **argv)
{
    const char* pInputFile = NULL;
    const char* pOutputFile = NULL;

    float texture_width = 0, texture_height =0;

    if ( argc < 5)
    {
        printf("Not enough arguments...");
        return 0;
    }
    
    pInputFile = argv[1];
    pOutputFile = argv[2];
    g_texture_width = texture_width = atof ( argv[3] );
    g_texture_height = texture_height = atof ( argv[4] );

    // -------------------------------------------------------------------
    // Load exr file

	//image format
	FREE_IMAGE_FORMAT fif = FIF_UNKNOWN;
	//pointer to the image, once loaded
	FIBITMAP *dib(0);
	//pointer to the image data
	BYTE* bits(0);
	//image width and height
	unsigned int width(0), height(0);

	//check the file signature and deduce its format
	fif = FreeImage_GetFileType(pInputFile, 0);
	//if still unknown, try to guess the file format from the file extension
	if(fif == FIF_UNKNOWN) 
		fif = FreeImage_GetFIFFromFilename(pInputFile);
	//if still unkown, return failure
	if(fif == FIF_UNKNOWN)
		return false;

	//check that the plugin has reading capabilities and load the file
	if(FreeImage_FIFSupportsReading(fif))
		dib = FreeImage_Load(fif, pInputFile);
	//if the image failed to load, return failure
	if(!dib)
		return false;

    FreeImage_FlipVertical( dib );

	bits = FreeImage_GetBits(dib);
	//get the image width and height
	width = FreeImage_GetWidth(dib);
	height = FreeImage_GetHeight(dib);

    int bpp = FreeImage_GetBPP( dib );
    int pixelsize = bpp / 32;
    // -------------------------------------------------------------------
    // process

    unsigned short* pDest;
    unsigned short* pDestCopy;
    pDestCopy = pDest = (unsigned short *) malloc ( width*height*2 );
    float* pSrc = (float*) bits;


    bool store = pSrc[2] < 0.9999 ? false : true;
    bool prev_store = false;
    unsigned short* pLastBlockInfo = pDest;             // store block info ptr
    pLastBlockInfo[0] = 0;
    pDest+=2;                                           // reserve space for offset and length information

    printf ( "store: %d,", (int)store );

    int numPixels = 0;

    if ( store )
    {
        StoreMotorola( 0 * width, &pLastBlockInfo[0] );
    }

    for ( int i = 0; i < height; i++ )
    {
        for ( int j = 0; j < ( width >> 4 ); ++j )
        {
            bool active_pixels = false;

            for ( int p = 0 ; p < 16 ; p++ )
            {
                if ( pSrc[p*pixelsize+2] > 0.99999 )
                {
                    active_pixels|=true;
                }
            }

            if ( store )
            {
                if ( !active_pixels )
                {
                    store = false;
                    StoreMotorola( numPixels, &pLastBlockInfo[1] );
                    printf("numpix: %d\n", numPixels );
                    pLastBlockInfo = pDest;
                    pLastBlockInfo[0] = 0;
                    pDest+=2;
                    numPixels = 0;
                }
            }
            else
            {
                if ( active_pixels )
                {
                    store = true;
                    StoreMotorola(i * width + ( (j << 4)  )  , &pLastBlockInfo[0]);
                }
            }

            for ( int p = 0 ; p < 16 ; p++ )
            {

                if ( store )
                {
                    StoreMotorola( ConvertPixel ( pSrc[0], pSrc[1], pSrc[2]), pDest );
                    pDest++;
                    numPixels ++;
                }

                pSrc+=pixelsize;
            }
        }

        printf ( "len: %d\n", numPixels );
    }
    
    *pDest++ = 0;

    printf("Total size: %d\n", pDest - pDestCopy );

    // -------------------------------------------------------------------
    // save raw file

    FILE* file = fopen ( pOutputFile, "wb" );
    fwrite ( pDestCopy, (int)pDest - (int)pDestCopy,1,file);
    fclose ( file );

    printf ( "Conversion done." );
        
	return 0;
}