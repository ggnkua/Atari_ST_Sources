/* DVSM Headerfile zur DVSM Konvertierung    */
/* Modulname:  DVSM.H                        */
/* (c) MAXON Computer 1994                   */
/* Autoren:    H. Schînfeld, B. Spellenberg  */

/* DVSM Header                               */
typedef struct
{
   char magic[6];          /* Filekennung    */
   unsigned int headlen;   /* Header LÑnge   */
   unsigned int freq;      /* Frequenz       */
   char pack;              /* Packformat     */
   char mode;              /* 8/16 Bit,      */
                           /* Stereo/Mono    */
   long blocklen;          /* Pack-BlocklÑnge*/
} DVSMHEAD;

/* Cookie-Struktur                           */
typedef struct
{
   long Name;              /* Cookie-Name    */
   unsigned int Len;       /* Cookie-LÑnge   */
} DVSMCOOKIE;

/* Falcon Sample-Frequenzen                  */
# ifndef ACT_CLK50K
# define ACT_CLK50K  49170
# define ACT_CLK33K  32778
# define ACT_CLK25K  24585
# define ACT_CLK20K  19668
# define ACT_CLK16K  16390
# define ACT_CLK12K  12292
# define ACT_CLK10K  9834
# define ACT_CLK8K   8195
/* Vorteiler fÅr Falcon DMA-Matrix           */
# define CLK50K      1
# define CLK33K      2
# define CLK25K      3
# define CLK20K      4
# define CLK16K      5
# define CLK12K      7
# define CLK10K      9
# define CLK8K       11
# endif
