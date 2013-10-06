#ifndef	INCLUDED_VECTOR_H
#define	INCLUDED_VECTOR_H

/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	<GODLIB\BASE\BASE.H>


/* ###################################################################################
#  ENUMS
################################################################################### */



/* ###################################################################################
#  STRUCTS
################################################################################### */



/* ###################################################################################
#  PROTOTYPES
################################################################################### */

void	Vector_Add( const sVector * apSrcVec0, const sVector * apSrcVec1, sVector * apDstVec );
void	Vector_Sub( const sVector * apSrcVec0, const sVector * apSrcVec1, sVector * apDstVec );
void	Vector_Mul( const sVector * apSrcVec, const S16 * aScaler, sVector * apDstVec );

void	Vector_Normal( const sVector * apSrcVec, sVector * apDstVec );
S32		Vector_Length( const sVector * apSrcVec );
S32		Vector_SquaredLength( const sVector * apSrcVec );

S32		Vector_Dot( const sVector * apSrcVec0, const sVector * apSrcVec1 );
void	Vector_Cross( const sVector * apSrcVec0, const sVector * apSrcVec1, sVector * apDstVec );



/* ################################################################################ */

#endif	/* INCLUDED_VECTOR_H */