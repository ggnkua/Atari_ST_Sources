#include <stdio.h>
#include <stdlib.h>

#include "numsld.h"

#define MINSLDDIM   16 /* En Pixels */

void CreateNumSld(NUM_SLD *num_sld)
{
  long nb_steps ;
  int  offset = 1 + num_sld->Obj[num_sld->IdSlider].ob_spec.obspec.framesize ;

  nb_steps = 1L + (long)num_sld->ValMax - (long)num_sld->ValMin ;
  if ( num_sld->HAlign )
  {
    num_sld->Obj[num_sld->IdSlider].ob_width = num_sld->Obj[num_sld->IdBox].ob_width / (int)nb_steps ;
    if ( num_sld->Obj[num_sld->IdSlider].ob_width < MINSLDDIM )
      num_sld->Obj[num_sld->IdSlider].ob_width = MINSLDDIM ;
    if ( num_sld->Obj[num_sld->IdBox].ob_spec.obspec.framesize < 0 )
    {
      offset -= num_sld->Obj[num_sld->IdBox].ob_spec.obspec.framesize ;
      num_sld->Obj[num_sld->IdSlider].ob_height  = num_sld->Obj[num_sld->IdBox].ob_height + num_sld->Obj[num_sld->IdBox].ob_spec.obspec.framesize - 1 ;
    }
    num_sld->Obj[num_sld->IdSlider].ob_y      += offset ;
    num_sld->Obj[num_sld->IdSlider].ob_height -= 1 + offset ;
  }
  else
  {
    num_sld->Obj[num_sld->IdSlider].ob_height = num_sld->Obj[num_sld->IdBox].ob_height / (int)nb_steps ;
    if ( num_sld->Obj[num_sld->IdSlider].ob_height < MINSLDDIM )
      num_sld->Obj[num_sld->IdSlider].ob_height = MINSLDDIM ;
    if ( num_sld->Obj[num_sld->IdBox].ob_spec.obspec.framesize < 0 )
    {
      offset -= num_sld->Obj[num_sld->IdBox].ob_spec.obspec.framesize ;
      num_sld->Obj[num_sld->IdSlider].ob_width  = num_sld->Obj[num_sld->IdBox].ob_width + num_sld->Obj[num_sld->IdBox].ob_spec.obspec.framesize - 1 ;
    }
    num_sld->Obj[num_sld->IdSlider].ob_x     += offset ;
    num_sld->Obj[num_sld->IdSlider].ob_width -= 1 + offset ;
  }
}

void UpdateValLabel(NUM_SLD *num_sld)
{
  char buf[20] ;

  sprintf( buf, "%d", num_sld->Val ) ;
  write_text( num_sld->Obj, num_sld->IdCurrentVal, buf ) ;
}

int Val2Pos(NUM_SLD *num_sld)
{
  long w, v, ww, pos ;
  long val = (long)num_sld->Val ;

  if ( num_sld->HAlign ) w = (long) (num_sld->Obj[num_sld->IdBox].ob_width - num_sld->Obj[num_sld->IdSlider].ob_width) ;
  else                   w = (long) (num_sld->Obj[num_sld->IdBox].ob_height - num_sld->Obj[num_sld->IdSlider].ob_height) ;
  ww  = (long) (num_sld->ValMax) ;
  ww -= (long) (num_sld->ValMin) ;
  v   = (long) (val - num_sld->ValMin) ;
  pos = (v * w) / ww ;

  return( (int)pos ) ;
}

int Pos2Val(NUM_SLD *num_sld)
{
  long w, ww, val ;
  long pos = num_sld->HAlign ? (long)num_sld->Obj[num_sld->IdSlider].ob_x : (long)num_sld->Obj[num_sld->IdSlider].ob_y ;

  if ( num_sld->HAlign ) w = (long) (num_sld->Obj[num_sld->IdBox].ob_width - num_sld->Obj[num_sld->IdSlider].ob_width) ;
  else                   w = (long) (num_sld->Obj[num_sld->IdBox].ob_height - num_sld->Obj[num_sld->IdSlider].ob_height) ;
  ww  = (long) (num_sld->ValMax) ;
  ww -= (long) (num_sld->ValMin) ;
  val = num_sld->ValMin + (int) ((ww * pos) / w) ;

  if ( val < num_sld->ValMin ) val = num_sld->ValMin ;
  else
  if ( val > num_sld->ValMax ) val = num_sld->ValMax ;

  return( (int)val ) ;
}

void SldNumSetVal(NUM_SLD *num_sld, int val)
{
  if ( val < num_sld->ValMin ) val = num_sld->ValMin ;
  if ( val > num_sld->ValMax ) val = num_sld->ValMax ;
  num_sld->Val = val ;

  if ( num_sld->HAlign ) num_sld->Obj[num_sld->IdSlider].ob_x = Val2Pos( num_sld ) ;
  else                   num_sld->Obj[num_sld->IdSlider].ob_y = Val2Pos( num_sld ) ;
  UpdateValLabel( num_sld ) ;
}

int SldNumGetVal(NUM_SLD *num_sld)
{
  int  val ;
  char buf[50] ;
 
  read_text( num_sld->Obj, num_sld->IdCurrentVal, buf ) ;
  val = atoi( buf ) ;
  if ( val < num_sld->ValMin ) val = num_sld->ValMin ;
  if ( val > num_sld->ValMax ) val = num_sld->ValMax ;
  num_sld->Val = val ;

  if ( num_sld->HAlign ) num_sld->Obj[num_sld->IdSlider].ob_x = Val2Pos( num_sld ) ;
  else                   num_sld->Obj[num_sld->IdSlider].ob_y = Val2Pos( num_sld ) ;
  UpdateValLabel( num_sld ) ;

  return( val ) ;
}

void SldNumMoveSlider(NUM_SLD *num_sld)
{
  long pc, w ;
  int  offset ;

  if ( num_sld->HAlign ) w = (long) (num_sld->Obj[num_sld->IdBox].ob_width - num_sld->Obj[num_sld->IdSlider].ob_width) ;
  else                   w = (long) (num_sld->Obj[num_sld->IdBox].ob_height - num_sld->Obj[num_sld->IdSlider].ob_height) ;
  pc    = graf_slidebox( num_sld->Obj, num_sld->IdBox, num_sld->IdSlider, 1 - num_sld->HAlign ) ;
  if ( !num_sld->HAlign ) pc = 1000 - pc ;
  offset = (int) ( ( pc * w ) / 1000L ) ;
  if ( num_sld->HAlign ) num_sld->Obj[num_sld->IdSlider].ob_x = offset ;
  else                   num_sld->Obj[num_sld->IdSlider].ob_y = offset ;

  num_sld->Val = Pos2Val( num_sld ) ;
  UpdateValLabel( num_sld ) ;
}

void SldNumClickBox(NUM_SLD *num_sld, int mx, int my)
{
  int off_x, off_y ;
  int pos, wlimit ;
  int *pval ;

  SldNumGetVal( num_sld ) ;
  objc_offset( num_sld->Obj, num_sld->IdSlider, &off_x, &off_y ) ;
  if ( num_sld->HAlign )
  {
    pos    = num_sld->Obj[num_sld->IdSlider].ob_x ;
    if ( mx > off_x ) pos   += num_sld->Obj[num_sld->IdSlider].ob_width ;
    else              pos   -= num_sld->Obj[num_sld->IdSlider].ob_width ;
    wlimit = 1 + num_sld->Obj[num_sld->IdBox].ob_width - num_sld->Obj[num_sld->IdSlider].ob_width ;
    pval   = &num_sld->Obj[num_sld->IdSlider].ob_x ;
  }
  else
  {
    pos    = num_sld->Obj[num_sld->IdSlider].ob_y ;
    if ( my > off_y ) pos   += num_sld->Obj[num_sld->IdSlider].ob_height ;
    else              pos   -= num_sld->Obj[num_sld->IdSlider].ob_height ;
    wlimit = 1 + num_sld->Obj[num_sld->IdBox].ob_height - num_sld->Obj[num_sld->IdSlider].ob_height ;
    pval   = &num_sld->Obj[num_sld->IdSlider].ob_y ;
  }
  if ( pos < 0 ) pos = 0 ;
  if ( pos > wlimit ) pos = wlimit ;
  *pval = pos ;

  num_sld->Val = Pos2Val( num_sld ) ;
  UpdateValLabel( num_sld ) ;
}

void SldNumShowControl(NUM_SLD *num_sld, int visible)
{
  if ( !visible )
  {
    num_sld->Obj[num_sld->IdBLess ].ob_flags     |= HIDETREE ;
    num_sld->Obj[num_sld->IdBox].ob_flags        |= HIDETREE ;
    num_sld->Obj[num_sld->IdSlider].ob_flags     |= HIDETREE ;
    num_sld->Obj[num_sld->IdBPlus].ob_flags      |= HIDETREE ;
    num_sld->Obj[num_sld->IdTitle].ob_flags      |= HIDETREE ;
    num_sld->Obj[num_sld->IdValMin].ob_flags     |= HIDETREE ;
    num_sld->Obj[num_sld->IdValMax].ob_flags     |= HIDETREE ;
    num_sld->Obj[num_sld->IdCurrentVal].ob_flags |= HIDETREE ;
  }
  else
  {
    num_sld->Obj[num_sld->IdBLess ].ob_flags     &= ~HIDETREE ;
    num_sld->Obj[num_sld->IdBox].ob_flags        &= ~HIDETREE ;
    num_sld->Obj[num_sld->IdSlider].ob_flags     &= ~HIDETREE ;
    num_sld->Obj[num_sld->IdBPlus].ob_flags      &= ~HIDETREE ;
    num_sld->Obj[num_sld->IdTitle].ob_flags      &= ~HIDETREE ;
    num_sld->Obj[num_sld->IdValMin].ob_flags     &= ~HIDETREE ;
    num_sld->Obj[num_sld->IdValMax].ob_flags     &= ~HIDETREE ;
    num_sld->Obj[num_sld->IdCurrentVal].ob_flags &= ~HIDETREE ;
  }
}
