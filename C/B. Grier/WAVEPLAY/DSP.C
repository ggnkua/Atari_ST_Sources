/*
   This function performs resampling of 8 bit monoral
   PCM samples. The result is placed into the destination
   pointer. The pointer is returned to allow it to be used to
   concatinate multiple segments of data from the same, and or
   different PCM samples. The routine assumes that the 8 bit source
   samples are in MicroSoft Corporation (MSC), unsigned char, 
   WAVE format. And the destination of in Atari, signed char,
   PCM format.

  Change History:

  11/25/92	Changed floating point to fixed point
*/

#include "riff.h"
#include "fixed.h"

void Resample8bitMono(PCM_Samples *Dest,
                      PCM_Samples *Src,
                      unsigned long Dest_Sample_Rate,
                      unsigned long Src_Sample_Rate)
{
Fixed         delta ;
Fixed         offset ;

  delta = fl_fp((double)Src_Sample_Rate/(double)Dest_Sample_Rate) ;
  offset = 0 ;
  while (Dest_Sample_Rate--)
  {
    *Dest->Mono8++ = (unsigned char)((char)Src->Mono8[fp_long(offset)] - 128 ) ;
    offset += delta ;
  }
  return ;
}

void Resample16bitMono(PCM_Samples *Dest,
                       PCM_Samples *Src,
                       unsigned long Dest_Sample_Rate,
                       unsigned long Src_Sample_Rate)
{
Fixed         delta ;
Fixed         offset ;

  offset = 0 ;
/* 
 *  adjust for bytes per sample 
 */
  Src_Sample_Rate = Src_Sample_Rate / 2l ;

  delta = (double)Src_Sample_Rate/(double)Dest_Sample_Rate ;
  while (Dest_Sample_Rate--)
  {
    *Dest->Mono8++ = Src->Mono16[fp_long(offset)].upper ;
    offset += delta ;
  }
  return ;
}

void Resample8bitStereo(PCM_Samples *Dest,
                        PCM_Samples *Src,
                        unsigned long Dest_Sample_Rate,
                        unsigned long Src_Sample_Rate)
{
Fixed         delta ;
Fixed         offset ;

  offset = 0 ;
  delta = (double)Src_Sample_Rate/(double)Dest_Sample_Rate ;
/* 
 *  adjust for stereo sample 
 */
  Dest_Sample_Rate = Dest_Sample_Rate / 2l ;
  while (Dest_Sample_Rate--)
  {
    (*Dest->Stereo8).left  = (unsigned char)((char)Src->Stereo8[fp_long(offset)].left - 128 ) ;
    (*Dest->Stereo8).right = (unsigned char)((char)Src->Stereo8[fp_long(offset)].right - 128 ) ;
    offset += delta ;
    Dest->Stereo8++ ;
  }
  return ;
}

void Resample16bitStereo(PCM_Samples *Dest,
                         PCM_Samples *Src,
                         unsigned long Dest_Sample_Rate,
                         unsigned long Src_Sample_Rate)
{
Fixed         delta ;
Fixed         offset ;

  offset = 0 ;
/* 
 *  adjust for bytes per sample 
 */
  Src_Sample_Rate = Src_Sample_Rate / 2l ;

  delta = (double)Src_Sample_Rate/(double)Dest_Sample_Rate ;
  while (Dest_Sample_Rate--)
  {
    (*Dest->Stereo8).left  = Src->Stereo16[fp_long(offset)].left.upper ;
    (*Dest->Stereo8).right = Src->Stereo16[fp_long(offset)].right.upper ;
    offset += delta ;
    Dest->Stereo8++ ;
  }
  return ;
}

