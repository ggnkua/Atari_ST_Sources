/************************************************************************
 * Datei: Swap.h    	Zweck: 	Bildschirmumschaltung GEM-konform		*
 * Autor: RSB                                                           *
 * Datum 23.05.90       Grund: 	SwapScreen(), SwapScreenFast() und		*
 *								ChainOnNewScreen() fÅr TOS Magazin		*
 ************************************************************************/

extern int ChainOnNewScreen(int isGemDa, char *Head, char *Tail,OBJECT *MenuTree, OBJECT *DeskTree);
extern int SwapScreenFast(void);	/* mit Pufferspeicher */
extern int SwapScreen(void);		/* ohne Pufferspeicher */

extern int SoftCopy(int direction);	/* 1: to Mem, 0: to Screen */
extern char *GetActualPath(void);
extern int SetActualPath(char *NewPath);	/* z.B.: "E:\\SYS\\COMMAND.TOS" */

/* Parameter direction der Funktion SoftCopy */
#define toScr	0
#define toMem	1
