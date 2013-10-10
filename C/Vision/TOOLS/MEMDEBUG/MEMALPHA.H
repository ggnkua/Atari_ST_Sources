
/********************************************************************************/
/* REMARK: set tab width to 4 spaces for best format							*/
/********************************************************************************/
/********************************************************************************/
/* 																				*/
/* Copyright (C) 1992	All Rights Reserved										*/
/* Centre de Recherche Public Henri Tudor (CRP-HT)								*/
/* 6, rue Coudenhove-Kalergi													*/
/* L1359 Luxembourg-Kirchberg													*/
/* 																				*/
/* Author			: Schmit Rene												*/
/* Internet			: Rene.Schmit@crpht.lu										*/
/* Creation Date	: Friday, October 02 1992 									*/
/* File name		: AVL_TREE.h												*/
/* Project			: Library													*/
/* 																				*/
/* This software may be copied, distributed, ported and modified in source or	*/
/* object format as long as :													*/
/* 																				*/
/* 	1) No distribution for commercial purposes is made.							*/
/* 	2) No third-party copyrights (such as runtime licenses) are involved		*/
/* 	3) This copyright notice is not removed or changed.							*/
/* 																				*/
/* No responsibility is assumed for any damages that may result 				*/
/* from any defect in this software.											*/
/* 																				*/
/********************************************************************************/
/********************************************************************************/

/*
	Header file of the memalpha library
	This file is included only once in a compilation
*/

#ifndef __AlphaBlock_TREE__
#define __AlphaBlock_TREE__

#include "memtypes.i"

/********************************************************************************/
/******************************* Constants **************************************/
/********************************************************************************/

#ifndef NULL
#define NULL 0
#endif

#ifndef FALSE
#define FALSE 0
#endif

#ifndef TRUE
#define TRUE 1
#endif

#ifndef EXIT_SUCCESS
#define EXIT_SUCCESS 0
#endif

/********************************************************************************/
/*************************** Function prototypes ********************************/
/********************************************************************************/

#ifdef __cplusplus
extern "C" {
#endif

void	create_AlphaBlockTree		  ( void );
void	insert_AlphaBlock_into_Tree	  (	t_BlockDescriptor*			p_data	);
int		search_AlphaBlock_in_Tree	  (	t_BlockDescriptor*		  *	p_data	);
void	remove_AlphaBlock_from_Tree   ( t_BlockDescriptor*			p_data	);
											  
void	delete_AlphaBlockTree		  ( void );

int 	check_AlphaBlockFull		  ( void );


int 	get_Height_of_AlphaBlockTree  ( void );
int 	get_Card_of_AlphaBlockTree	  ( void );


void	free_AlphaBlockTree	( void );
		void	delete_Descriptor	(t_BlockDescriptor*	  	p_data);

void	print_AlphaBlockTree	( void );
		void	print_AlphaBlock	(t_BlockDescriptor*	  	p_data);



#ifdef __cplusplus
}	// close the extern "C" declaration
#endif

/********************************************************************************/

#endif
