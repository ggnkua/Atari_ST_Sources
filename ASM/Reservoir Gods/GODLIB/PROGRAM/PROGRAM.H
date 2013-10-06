#ifndef	INCLUDED_PROGRAM_H
#define	INCLUDED_PROGRAM_H

/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	<GODLIB\BASE\BASE.H>


/* ###################################################################################
#  DEFINES
################################################################################### */

#define	dPROGRAM_SYMBOL_DEFINED		0x8000
#define	dPROGRAM_SYMBOL_EQUATED		0x4000
#define	dPROGRAM_SYMBOL_GLOBAL		0x2000
#define	dPROGRAM_SYMBOL_REGISTER	0x1000
#define	dPROGRAM_SYMBOL_EXTERN		0x0800
#define	dPROGRAM_SYMBOL_DATA		0x0400
#define	dPROGRAM_SYMBOL_TEXT		0x0200
#define	dPROGRAM_SYMBOL_BSS			0x0100

#define	dPROGRAM_MAGIC				0x601A


/* ###################################################################################
#  STRUCTS
################################################################################### */

typedef	struct
{
	U16	Magic;
	U32	TextSize;
	U32	DataSize;
	U32	BSSSize;
	U32	SymbolTableSize;
	U16	Reserved[ 5 ];
} sProgramHeader;

typedef	struct
{
	char	Name[ 8 ];
	U16		Type;
	U32		Value;
} sProgramSymbol;



/* ###################################################################################
#  PROTOTYPES
################################################################################### */

void				Program_Relocate(   const sProgramHeader * apHeader );

U8					Program_IsValid( const sProgramHeader * apHeader );


/* ################################################################################ */

#endif	/*	INCLUDED_PROGRAM_H */