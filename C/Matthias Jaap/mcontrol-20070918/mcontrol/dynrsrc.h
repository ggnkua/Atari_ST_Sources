/*----------------------------------------------------------------------------------------*
 * MControl                                                                               *
 *----------------------------------------------------------------------------------------*
 * Copyright (c) 2000 - 2002 Joachim Fornallaz                                            *
 *----------------------------------------------------------------------------------------*
 * This source file is subject to the BSD license.                                        *
 *----------------------------------------------------------------------------------------*
 * Authors: Joachim Fornallaz <jf@omnis.ch>                                               *
 *----------------------------------------------------------------------------------------*/

#ifndef _dynrsrc_h_
#define _dynrsrc_h_

#include	<types2b.h>
#include	<cflib.h>

#include	"config.h"

/*----------------------------------------------------------------------------------------*/
/* struct definitions																							*/
/*----------------------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------------------*/
/* defines																											*/
/*----------------------------------------------------------------------------------------*/

typedef int16 (* SEARCHTREE_CB )(void *addr1, void *addr2, int16 data1, int16 data2);

/*----------------------------------------------------------------------------------------*/
/* function prototypes																							*/
/*----------------------------------------------------------------------------------------*/

int16	searchtree( NODE *node, void *addr2, int16 data1, int16 data2, SEARCHTREE_CB callback );
int16	mscroll( WDIALOG *wd, int16 kind, int16 val );
int16	click_node( NODE *nd, WDIALOG	*wd, int16 obj );
int16	dyn_event( WDIALOG *wd, int16 obj );
int16	dyn_fnode( WDIALOG *wd, int16 obj );

int16	get_nexty( NODE *node );
void	rscadd_hr( NODE *node );
void	rscadd_item( NODE *node );
void	rscadd_folder( NODE *node );
void	build_subtree( NODE *np );
void	build_obtree( NODE *np );

#endif
