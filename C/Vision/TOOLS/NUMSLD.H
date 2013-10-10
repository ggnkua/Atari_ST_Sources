#ifndef __NUMSLD
#define __NUMSLD

#ifndef __GWINDOWS
#include "..\tools\gwindows.h"
#endif

typedef struct
{
  OBJECT *Obj ;

  int    HAlign ;

  int IdBLess ;
  int IdBox ;
  int IdSlider ;
  int IdBPlus ;
  int IdTitle ;
  int IdValMin ;
  int IdValMax ;
  int IdCurrentVal ;

  int Val ;
  int ValMin ;
  int ValMax ;
}
NUM_SLD ;

void CreateNumSld(NUM_SLD *num_sld) ;
int  SldNumGetVal(NUM_SLD *num_sld) ;
void SldNumSetVal(NUM_SLD *num_sld, int val) ;
void SldNumMoveSlider(NUM_SLD *num_sld) ;
void SldNumClickBox(NUM_SLD *num_sld, int mx, int my) ;
void SldNumShowControl(NUM_SLD *num_sld, int visible) ;

#endif
