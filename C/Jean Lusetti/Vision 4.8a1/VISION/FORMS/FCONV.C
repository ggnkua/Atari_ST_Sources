#include <string.h>
#include <stdlib.h>
#include "..\tools\xgem.h"
#include "..\tools\msgtxt.h"

#include "defs.h"

#ifndef __VISION_H
#define __VISION_H
#include "langues\francais\vision.h"
#endif


#pragma warn -par
void traite_conversion(void* gwnd)
{
  form_exclamation( 1, MsgTxtGetMsg(hMsg, MSG_NOMORECONVERT) ) ;
}
#pragma warn +par