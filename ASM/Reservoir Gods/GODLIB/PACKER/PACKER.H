#ifndef	INCLUDED_PACKER_H
#define	INCLUDED_PACKER_H

/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	<GODLIB\BASE\BASE.H>


/* ###################################################################################
#  ENUMS
################################################################################### */

typedef enum ePACKER
{
	PACKER_NONE,
	PACKER_ATOMIC,
	PACKER_ICE
} ePACKER;


/* ###################################################################################
#  STRUCTS
################################################################################### */

typedef struct
{
	U32	l0;
	U32	l1;
	U32	l2;
} sPACKER_HEADER;


/* ###################################################################################
#  PROTOTYPES
################################################################################### */

U8		Packer_IsPacked( sPACKER_HEADER * apHeader );
ePACKER	Packer_GetType( sPACKER_HEADER * apHeader );
U32		Packer_GetDepackSize( sPACKER_HEADER * apHeader );
void	Packer_Depack( void * apData );

extern void	Packer_DepackIce( void * apData );
extern void	Packer_DepackAtomic( void * apData );


/* ################################################################################ */

#endif	/* INCLUDED_PACKER_H */