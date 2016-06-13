/* *** Prototyp fÅr <loadimg.c> *** */

#include <vdi.h>

int LoadImg(char *Filename, MFDB *raster);
int getximgpal(char *filename, int pal[][3]);
int transform_truecolor( MFDB *image, long size, int planes, int img_handle);
