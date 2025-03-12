#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>
#include <FreeImage.h>


typedef unsigned int u32;

u32 g_texture_height = 0;
u32 g_texture_width = 0;


// -----------------------------------------------------------------------------------------

int main(int argc, char **argv)
{
    const char* pInputFile = NULL;
    const char* pOutputFile = NULL;
    const char* pOutputFilePal = NULL;

    float texture_width = 0, texture_height =0;

    if ( argc < 3)
    {
        printf("Not enough arguments...");
        return 0;
    }
    
    pInputFile = argv[1];
    pOutputFile = argv[2];

    if ( argc >= 4 )
    {
        pOutputFilePal = argv[3];
    }
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

    FreeImage_FlipVertical(dib);

	bits = FreeImage_GetBits(dib);
	//get the image width and height
	width = FreeImage_GetWidth(dib);
	height = FreeImage_GetHeight(dib);

    int bpp = FreeImage_GetBPP( dib );

    RGBQUAD *pal = FreeImage_GetPalette(dib);

    // -------------------------------------------------------------------
    
    if ( pOutputFilePal != NULL )
    {
        int numColors = 1<<bpp;

        for ( int i = 0; i < numColors; i++) 
        {
            int temp = pal[i].rgbBlue;
            pal[i].rgbBlue = pal[i].rgbRed;
            pal[i].rgbRed = temp;
        }

        FILE* file = fopen ( pOutputFilePal, "wb" );
        fwrite ( pal, numColors*4,1,file);
        fclose ( file );
    }


    // -------------------------------------------------------------------
    // save raw file

    FILE* file = fopen ( pOutputFile, "wb" );
    fwrite ( bits, width*height ,1,file);
    fclose ( file );

    // -------------------------------------------------------------------


    printf ( "Conversion done." );
        
	return 0;
}