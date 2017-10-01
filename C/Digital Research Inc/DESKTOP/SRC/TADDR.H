/*	TADDR.H		04/11/84 - 02/09/85	Gregg Morris		*/
/*	merge source	5/26/87			mdf			*/
/*
*       Copyright 1999, Caldera Thin Clients, Inc.                      
*       This software is licenced under the GNU Public License.         
*       Please see LICENSE.TXT for further information.                 
*                                                                       
*                  Historical Copyright                                 
*	-------------------------------------------------------------
*	GEM Desktop					  Version 2.3
*	Serial No.  XXXX-0000-654321		  All Rights Reserved
*	Copyright (C) 1985, 1986		Digital Research Inc.
*	-------------------------------------------------------------
*/

#define OB_NEXT(x) obaddr(tree, x, 0)
#define OB_HEAD(x) obaddr(tree, x, 2)
#define OB_TAIL(x) obaddr(tree, x, 4)
#define OB_TYPE(x) obaddr(tree, x, 6)
#define OB_FLAGS(x) obaddr(tree, x, 8)
#define OB_STATE(x) obaddr(tree, x, 10)
#define OB_SPEC(x) obaddr(tree, x, 12)
#define OB_X(x) obaddr(tree, x, 16)
#define OB_Y(x) obaddr(tree, x, 18)
#define OB_WIDTH(x) obaddr(tree, x, 20)
#define OB_HEIGHT(x) obaddr(tree, x, 22)
