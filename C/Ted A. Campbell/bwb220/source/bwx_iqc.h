/***************************************************************

        bwx_iqc.h       Header File for IBM PC and Compatible
			Implementation of bwBASIC
			Using Microsoft QuickC (tm) Compiler

                        Copyright (c) 1993, Ted A. Campbell
			Bywater Software

                        email: tcamp@delphi.com

        Copyright and Permissions Information:

        All U.S. and international rights are claimed by the author,
        Ted A. Campbell.

	This software is released under the terms of the GNU General
	Public License (GPL), which is distributed with this software
	in the file "COPYING".  The GPL specifies the terms under
	which users may copy and use the software in this distribution.

	A separate license is available for commercial distribution,
	for information on which you should contact the author.

***************************************************************/

#define IMP_IDSTRING    "IQC"           /* unique ID string for this implementation */

/* Definitions indicating which commands and functions are implemented */

#define IMP_FNCINKEY    1               /* 0 if INKEY$ is not implemented, 1 if it is */
#define IMP_CMDCLS	1		/* 0 if CLS is not implemented, 1 if it is */
#define IMP_CMDLOC	1		/* 0 if LOCATE is not implemented, 1 if it is */
#define IMP_CMDCOLOR    1               /* 0 if COLOR is not implemented, 1 if it is */

#define UNIX_CMDS       TRUE
#define MKDIR_ONE_ARG	TRUE		/* TRUE if your mkdir has but one argument;
					   FALSE if it has two */
#define PERMISSIONS	493		/* permissions to set in Unix-type system */
