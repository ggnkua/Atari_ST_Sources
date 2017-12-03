/*
    The following definitions are those of the MicroSoft Corp
    WAVE files.

    The PCM Samples are strangely arranged to allow simple
    conversion fom the MicroSoft format for 8 bit samples
    to the format used by ATARI.
*/

typedef union {
  unsigned int  Atari ;
  unsigned char MSC[2] ;
} INTEGER ;

typedef union {
  unsigned long Atari ;
  unsigned char MSC[4] ;
} LONG ;

typedef struct {
    unsigned char  left ;
    unsigned char  right ;
} STEREO_8 ;

typedef struct {
    unsigned char lower ;
    unsigned char upper ;
} MONO_16 ;

typedef struct {
    MONO_16 left ;
    MONO_16 right ;
} STEREO_16 ;

typedef union
{
  unsigned char * Mono8 ;
  STEREO_8      * Stereo8 ;
  MONO_16       * Mono16 ;
  STEREO_16     * Stereo16 ;
} PCM_Samples ;

typedef struct
{
  char            riffStr[4];
  unsigned long   ckSize ;    /* Chunk Size */
  char            waveStr[4] ;
} WAVE_FILE ;

typedef struct
{
  char            ckStr[4] ;
  unsigned long   ckSize ;
} CHK_DEF ;

typedef struct
{
  unsigned int    formatTag ;
  unsigned int    nChannels ;
  unsigned long   nSamplesPerSec ;
  unsigned long   nAvgBytesPerSec ;
  unsigned int    nBlockAlign ;
  unsigned int    nBitsPerSample ;
} WAVE_HDR ;

typedef struct
{
  WAVE_HDR          hdr ;
  CHK_DEF           data ;
  unsigned long     Target_SpS ;
  unsigned long     required_memory ;
  PCM_Samples       PCM ; /* hex */
} WAVE_DEFINITION ;


/*
  This next section will define all of the WAVEPLAYER
  functions
*/
void Resample8bitMono(PCM_Samples *Dest,
                      PCM_Samples *Src,
                      unsigned long Dest_Sample_Rate,
                      unsigned long Src_Sample_Rate) ;

void Resample16bitMono(PCM_Samples *Dest,
                       PCM_Samples *Src,
                       unsigned long Dest_Sample_Rate,
                       unsigned long Src_Sample_Rate) ;

void Resample8bitStereo(PCM_Samples *Dest,
                        PCM_Samples *Src,
                        unsigned long Dest_Sample_Rate,
                        unsigned long Src_Sample_Rate) ;

void Resample16bitStereo(PCM_Samples *Dest,
                         PCM_Samples *Src,
                         unsigned long Dest_Sample_Rate,
                         unsigned long Src_Sample_Rate) ;

void FatalError (char *identifier) ;
