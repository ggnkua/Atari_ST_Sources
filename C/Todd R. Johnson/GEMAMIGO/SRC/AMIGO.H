/*=========================================================================
===									===
=== FILE	amigo.h							===
===									===
=== CONTENTS	prototypes for the various AmiGo routines.		===
===		added by neilb						===
===									===
=========================================================================*/

#ifndef __amigo_h
#define __amigo_h

#include "go.h"

#ifdef __STDC__
#define PROTO(fp)	fp
#else
#define PROTO(fp)	()
#endif


/* From goplayer.c */


/* Procedures from amigo.c */

#ifdef __cplusplus
extern "C" {
#endif

short	Connect PROTO((enum bVal, short, short, short[4], short[4], short *, short * ));
short	Maxlibs PROTO((short, short));
void	FillPoints PROTO((short, short, short));
short	Suicide PROTO((enum bVal, short, short));
short	StoneLibs PROTO((short, short));
int	undoTo PROTO((short));
void	EraseMarks PROTO(());
short	GoPlaceStone PROTO((enum bVal, short, short));
void	GoRemoveStone PROTO((short, short));
void	MergeGroups PROTO((short, short));
void	DeleteGroup PROTO((short));
void	ReEvalGroups PROTO((enum bVal, short, short, short));
void	GroupCapture PROTO((short));
int	DeleteGroupFromStone PROTO((short, short));
void	FixLibs PROTO((enum bVal, short, short, short));
void	goRestart PROTO((int));
void	RelabelGroups PROTO(());
short	CountAndMarkLibs PROTO((short, short));
void	CountLiberties PROTO((short));
void	CheckForEye PROTO((short, short, short[4], short, short *));
void	CountEyes PROTO(());
void	printGroupReport PROTO((short, short));


/* killable.c */

int	tryPlay PROTO(( short, short, short ));
int	sSpanGroup PROTO(( short, short, sPointList * ));
int	listDiags PROTO(( short, short, sPointList * ));
int	spanGroup PROTO(( short, short, pointList *));
int	pause PROTO(());

int	genState PROTO(());
int	initGPUtils PROTO(());
int	genBord PROTO((enum bVal));

short	genMove PROTO(( enum bVal, short *, short * ));
short	checkPos PROTO(( short, short, short ));
short	takeCorner PROTO(( short *, short * ));
short	extend PROTO(( short *, short * ));
short	noNbrs PROTO(( short, short ));
short	extend2 PROTO(( short *, short * ));
short	lookForSave PROTO(( short *, short * ));
short	lookForSaveN PROTO(( short *, short * ));
short	lookForKill PROTO(( short *, short * ));
short	doubleAtari PROTO(( short *, short * ));
short	lookForAttack PROTO(( short *, short * ));
short	threaten PROTO(( short *, short * ));
short	connectCut PROTO(( short *, short * ));
short	heCanCut PROTO(( short, short ));
short	safeMove PROTO(( short, short ));
short	extendWall PROTO(( short *, short * ));
short	findAttack2 PROTO(( short *, short * ));
short	blockCut PROTO(( short *, short * ));
short	cutHim PROTO(( short *, short * ));
short	atariAnyway PROTO(( short *, short * ));
short	underCut PROTO(( short *, short * ));
short	dropToEdge PROTO(( short *, short * ));
short	pushWall PROTO(( short *, short * ));
short	reduceHisLiberties PROTO(( short *, short * ));
short	dropToEdge2 PROTO(( short *, short * ));

void	removestone PROTO((short, short));
void	placestone PROTO((enum bVal, short, short));
void	showresult PROTO((short,short,short,short));

/* goplayutils.c */

short	saveable PROTO((short, short, short *, short *));
short	killable PROTO((short, short, short *, short *));
int	initBoolBoard PROTO((boolBoard));
int	intersectPlist PROTO((pointList *, pointList *, pointList *));
int	initArray PROTO((intBoard));
int	initState PROTO(());
int	copyArray PROTO((intBoard, intBoard));
int	stake PROTO(());
int	spread PROTO(());
int	respreicen PROTO(());
int	tryPlay PROTO((short, short, short));
int	saveState PROTO(());
int	restoreState PROTO(());
short	tencen PROTO((short, short));
int	genConnects PROTO(());
int	sortLibs PROTO(());


/*-- from xinterface.c --*/

void	intrMoveReport PROTO((enum bVal,char *,char *));
void	intrPrisonerReport PROTO(( short, short ));

#ifdef __cplusplus
}
#endif

#endif
