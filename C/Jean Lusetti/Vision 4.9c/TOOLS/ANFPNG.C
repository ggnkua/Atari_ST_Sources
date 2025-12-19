/******************************************************/
/* PNG Format Handling (Aranym Natife Feature)        */
/* (Currently there is no Aranym PNG native support)  */
/******************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include     "..\tools\xgem.h"
#include "..\tools\rasterop.h"
#include "..\tools\image_io.h"

#pragma warn -par
int anf_png_identify(char *name, INFO_IMAGE *inf)
{

  return -1 ;
}

int anf_png_load(INFO_IMAGE* inf)
{

  return EIMG_OPTIONNOTSUPPORTED ;
}

int anf_png_sauve(char *name, MFDB *img, INFO_IMAGE *info, GEM_WINDOW* wprog)
{

  return EIMG_OPTIONNOTSUPPORTED ;
}
#pragma warn +par