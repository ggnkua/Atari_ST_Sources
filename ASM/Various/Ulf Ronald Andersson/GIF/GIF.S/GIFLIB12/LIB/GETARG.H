/***************************************************************************
* Error	numbers	as returned by GAGetArg	routine:			   *
*									   *
*					 Gershon Elber		 Mar 88	   *
****************************************************************************
* History:								   *
* 11 Mar 88 - Version 1.0 by Gershon Elber.				   *
***************************************************************************/

#ifndef GET_ARG_H
#define GET_ARG_H

#define	CMD_ERR_NotAnOpt   1			       /* None Option found. */
#define	CMD_ERR_NoSuchOpt  2			  /* Undefined Option Found. */
#define	CMD_ERR_WildEmpty  3			 /* Empty input for !*? seq. */
#define	CMD_ERR_NumRead	   4			/* Failed on reading number. */
#define	CMD_ERR_AllSatis   5	       /* Fail to satisfy (must-'!') option. */

#ifdef USE_VARARGS
int GAGetArgs(int va_alist, ...);
#else
int GAGetArgs(int argc, char **argv, char *CtrlStr, ...);
#endif /* USE_VARARGS */

void GAPrintErrMsg(int Error);
void GAPrintHowTo(char *CtrlStr);

#endif /* GET_ARG_H */
