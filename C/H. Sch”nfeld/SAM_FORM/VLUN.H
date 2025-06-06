/* VLUN Globales Headerfile                  */
/* Filename:   VLUN.H                        */
/* (c) MAXON Computer 1994                   */
/* Autoren:    H. Sch�nfeld, B. Spellenberg  */

# include <stdio.h>
# include <stdlib.h>
# include <string.h>
# include <math.h>

/* Formatflags                               */
# define BIT16       1
# define SIGNED      2
# define BIGENDIAN   4
# define STEREO      8
# define DELTAPACK   16
# define MULAW       32

/* Unterst�tzte Soundformate                 */
# define AVRHEADER   0
# define SNDHEADER   1
# define DVSMHEADER  2
# define WAVHEADER   3
# define RAWDATA     4

/* minimale Buffergr��e                      */
# define BUFSIZE     64000L

/* R�ckgabewerte der Formattestfunktionen    */
# define SUPPORTED      1
# define NOT_SUPPORTED  2
# define UNKNOWN        0

# define abs(x) (((x)<0)?(-(x)):(x))

/* interne Beschreibung des Input-Formates   */
typedef struct
{
   int   Typ;     /* Filetyp (DVSM,AVR,...)  */
   int   Format;  /* siehe Formatflags       */
   long  Freq;    /* Samplefrequenz          */
   long  BufLen;  /* n�tige mind. Buffergr��e*/
   long  DataLen; /* Samplel�nge oder noch zu*/
                  /* lesenden Samples        */
   int   SizeFac; /* Gr��enverh. zwischen    */
                  /* Input- und Stdformat    */
   int   Div;     /* reserviert              */
} SAMPLE_SPEC;

/* interne Beschreibung des Export-Formates  */
typedef struct
{
   int Typ;       /* Filetyp (DVSM,AVR,...)  */
   int Format;    /* siehe Formatflags       */
} OUT_FORMAT;

/* Typdefinitionen der Wandelfunktionen      */

/* Headertestfunktionen                      */
/* Parameter:                                */
/*  InFH:      Pointer auf Inputfilehandle   */
/*  Smp:       Input-Formatbeschreibung      */
/*             (wird von Funktion gesetzt)   */
/* R�ckgabe:                                 */
/*  UNKNOWN:   nicht das jeweilige Format    */
/*  NOT_SUPP.: unbekanntes Unterformat       */
/*  SUPPORTED: Unterst�tztes Format          */
typedef int  (HEAD_FUNC)
               (FILE *InFH, SAMPLE_SPEC *Smp);

/* Lesefunktionen                            */
/* Parameter:                                */
/*  InFH:      Pointer auf Inputfilehandle   */
/*  Smp:       Input-Formatbeschreibung      */
/*  StdBuf:    Pointer auf Wandelbuffer      */
/*  StdBufLen: L�nge des Buffer in Bytes     */
/* R�ckgabe:                                 */
/*  gewandelte Soundl�nge im Standardformat  */
typedef long (READ_FUNC)
               (FILE *InFH, SAMPLE_SPEC *Smp,
                char *StdBuf, long StdBufLen);

/* Schreibfunktionen                         */
/* Parameter:                                */
/*  OutFH:     Pointer auf Exportfilehandle  */
/*  OutSmp:    Export-Formatbeschreibung     */
/*  DataLen:   L�nge des Soundblocks         */
/*  StdBuf:    Pointer auf Wandelbuffer      */
/* R�ckgabe:                                 */
/*  geschriebene Bytes                       */
typedef long (WRITE_FUNC)
               (FILE *OutFH, OUT_FORMAT *OutSmp,
                long DataLen, char *StdBuf);

/* Headerschreibfunktionen                   */
/* Parameter:                                */
/*  OutFH:     Pointer auf Exportfilehandle  */
/*  InSmp:     Input-Formatbeschreibung      */
/*  OutSmp:    Export-Formatbeschreibung     */
/* R�ckgabe:                                 */
/*  1:         Header wurde geschrieben      */
/*  0:         Fehler beim Schreiben         */
typedef int (WRT_HEAD_FUNC)
               (FILE *OutFH, SAMPLE_SPEC *InSmp,
               OUT_FORMAT *OutSmp);

/* Fileabschlu�funktionen                    */
/* Parameter:                                */
/*  OutFH:     Pointer auf Exportfilehandle  */
/*  OutSmp:    Export-Formatbeschreibung     */
/* R�ckgabe:                                 */
/*  1:         Daten wurden geschrieben      */
/*  0:         Fehler beim Schreiben         */
typedef int (FINISH_FUNC)
               (FILE *OutFH, OUT_FORMAT *OutSmp);

/* Prototypen der Wandelfunktionen           */
HEAD_FUNC      AvrTstHead, RawSetHead,
               SndTstHead, DvsTstHead,
               WavTstHead;
READ_FUNC      AllToStd, DvsToStd,
               WavToStd;
WRITE_FUNC     AllFromStd, AvrFromStd,
               RawFromStd, SndFromStd,
               WavFromStd,DvsFromStd;
WRT_HEAD_FUNC  AvrWrtHead, SndWrtHead,
               DvsWrtHead,WavWrtHead;
FINISH_FUNC    AvrFinish, SndFinish,
               WavFinish;

/* Prototypen der untergeordneten Block-     */
/* konvertierfunktionen                      */
void Conv8_16(char *,char *,long);
void ConvM_S(char *,char *,long);
void ConvU_S(char *,long);
void ConvS_U(char *,long);
void ConvS_M(char *,long);
void Conv16_8(char *,long);
void ConvIntel(char *,long);
void ConvMu_16(char *,char *,long);
void Conv16_Mu(char *,long);
void ConvD_Std(char *,char *,long);
void ConvStd_D(char *,long);

/* Hilfsfunktionen f�r Deltapack und Mu-law  */
void SetInvMu(void);
void SetMu(void);
void SetInvDelta(void);
void SetDelta(void);
