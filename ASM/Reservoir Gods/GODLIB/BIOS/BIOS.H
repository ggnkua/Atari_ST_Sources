#ifndef	INCLUDED_BIOS_H
#define	INCLUDED_BIOS_H

/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	<GODLIB\BASE\BASE.H>


/* ###################################################################################
#  DEFINES
################################################################################### */

#define	dBIOS_DEV_PRINTER	0
#define	dBIOS_DEV_AUX		1
#define	dBIOS_DEV_CONSOLE	2
#define	dBIOS_DEV_MIDI		3
#define	dBIOS_DEV_IKBD		4
#define	dBIOS_DEV_RAW		5


/* ###################################################################################
#  STRUCTS
################################################################################### */

typedef	struct
{
	U16	SectorSize;
	U16	SectorsPerCluster;
	U16	ClusterSize;
	U16	RootDirectorySize;
	U16	SectorsPerFAT;
	U16	StartSecondFAT;
	U16	StartDataFAT;
	U16	ClusterCount;
	U16	Flags;
} sBiosBPB;

typedef	struct
{
	void *	pStartTPA;
	void *	pEndTPA;
	void *	pText;
	U32		TextLength;
	void *	pData;
	U32		DataLength;
	void *	pBSS;
	U32		BSSLength;
	void *	pDTA;
	void *	pParent;
	U32		Reserved0;
	char *	pEnv;
	char	Reserved1[ 80 ];
	char	CmdLine[ 128 ];
} sBiosBasePage;

typedef	struct sBiosMD
{
	struct	sBiosMD *	pNext;
	void *				pStart;
	S32					Length;
	sBiosBasePage *		pBasePage;
} sBiosMD;

typedef	struct
{
	sBiosMD *	pFreeList;
	sBiosMD *	pAllocatedList;
	sBiosMD *	pRoving;
} sBiosMPB;


/* ###################################################################################
#  PROTOTYPES
################################################################################### */

S32				Bios_Bconin( const S16 aDev );
S32				Bios_Bconout( const S16 aDev, const U16 aChar );
S32				Bios_Bconstat( const S16 aDev );
S32				Bios_Bcostat( const S16 aDev );

U32				Bios_Drvmap( void );

sBiosBPB *		Bios_Getbpb( const S16 aDev );
void			Bios_Getmpb( sBiosMPB * apMPB );

S32				Bios_Kbshift( const S16 aMode );

S32				Bios_Mediach( const S16 aDev );

S32				Bios_Rwabs( const S16 aMode, void * apBuffer, const S16 aCount, const S16 aRecNo, const S16 aDv, const U32 aLongRecNo );

void			(*Bios_Setexec( const U16 aNum, void (* apNewVec)(void) ))(void);

S32				Bios_Tickcal( void );


/* ################################################################################ */

#endif	/*	INCLUDED_BIOS_H */