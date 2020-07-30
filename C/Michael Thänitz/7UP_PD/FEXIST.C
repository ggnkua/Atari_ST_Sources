/*****************************************************************************
*
*											  7UP
*										Modul: FEXIST.C
*									 (c) by TheoSoft '94
*
*****************************************************************************/
#include <stdio.h>
#include <ext.h>

int fexist(char *pathname)
{
	struct ffblk fileRec;
	return(!findfirst(pathname,&fileRec,0));
}
