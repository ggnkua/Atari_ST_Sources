/* MagicSLM - Globaler Header                  */
/* by Bernd Spellenberg & Harald Schînfeld     */
/* (c) Maxon 1995                              */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <aes.h>
#include "magicslm.h"   /* Resourcefile Header */

#define MODEMINPUT   1  /* Eingabe Åber AUX    */
#define FILEINPUT    2  /* Eingabe Åber File   */

#define SLMOUTPUT    10 /* Ausgabe auf Drucker */
#define PCXOUTPUT    11 /* Ausgabe als PCXfile */

#define MAXHEIGHT    3384L /* Max. Seitenhîhe- */
#define MAXWIDTH     2336L /* -breite in Pixel */


/* Typdefinitionen fÅr die Lese-, Schreib- und */
/* Synchronisations-funktionen                 */

typedef int (READ_FUNC)
               (void);

typedef void (STOP_FUNC)
               (int);

typedef void (WRITE_FUNC)
               (unsigned char *Data,
                long XDim, long YDim);

/* Globale Prototypen                          */

void InitDlg(OBJECT *);
void CloseDlg(void);
void UpdateDlg(OBJECT *Dlg, int Obj);
void SelectButton(OBJECT *Dlg, int Obj, int Mode);
int CheckButton(void);

void InitPcl(void);
void InitFile(void);
void InitPage(void);

void StartScan(void);
void StopScan(void);
void StartConversion(void);

void SInit (void);
void SClose (void);
int SRec(void);

void ExCmd (int CmdNo, char *CmdArg,
            char *CmdTerm,
            READ_FUNC *GetNextByte,
            STOP_FUNC *Stop,
            WRITE_FUNC *WritePage);
int ParseNextCmd (char *arg, char *terminator,
                  READ_FUNC *GetNextByte);

READ_FUNC GetNextByte;
WRITE_FUNC PcxWrite,SlmWrite;
READ_FUNC SGet;
STOP_FUNC XOnOff;

/* Globale Variablen                           */
extern int FileEndFlag;
extern long CurrPageNo;
extern int ScaleFact;
extern int PageUsed;
extern unsigned char *LJPage;
extern unsigned char *CurrRaster;

extern char InPath[256], OutPath[256];
extern int Input, Output;
extern int TimerMode;

extern FILE *InputFH;

extern OBJECT *Print;
