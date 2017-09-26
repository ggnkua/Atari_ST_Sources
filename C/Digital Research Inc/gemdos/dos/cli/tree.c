/*****************************************************************************
**
**	tree.c - report on directory tree for specified drive
**
** CREATED
** 31 oct 85 scc
**
** NAMES
**	scc	Steven C. Cavender
**
******************************************************************************
*/

#include <mini.h>

char	root[4] = "\0\0";

scan(dir)
char	*dir;
{
	char	*buffer;
	char	*dta;
	long	no_more;

	if (((buffer = M_Alloc(80L)) < 0) || ((dta = M_Alloc(44L)) < 0))
	{
		C_ConWS("Error:  Out of memory.");
		P_Term(1);
	}

	F_SetDTA(dta);

	no_more = F_SFirst(strcat(strcpy(buffer,dir),"*.*"), 0x10, dta);
	if (!no_more)
	{
		C_ConWS(dir);
		C_ConWS("\r\n");
	}
	else
	{
		C_ConWS("Error:  Unable to find this device or directory.");
		P_Term(2);
	}

	while (!no_more)
	{
		if ((dta[21] & 0x10) && (dta[30] != '.'))
			scan(strcat(strcat(strcpy(buffer,dir),dta+30),"\\"));
		F_SetDTA(dta);
		no_more = F_SNext();
	}
	M_Free(dta);
	M_Free(buffer);
}

main(bp)
char	*bp;
{
	char c;

	C_ConWS("GEM DOS Directory Tree Utility\r\n");
	C_ConWS("Version 1.3     6/3/86     SCC\r\n\n");

	bp += 0x80;
	while (c = *bp++)
	{
		if ( ((c >= 'A') && (c <= 'Z')) || ((c >= 'a') && (c <= 'z')) )
		{
			root[0] = c;
			root[1] = ':';
			break;
		}
	}

	scan(strcat(root,"\\"));
}
