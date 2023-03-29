/*****************************************************************************
 *
 * Module : ACCOUNT.H
 * Author : Dieter Geiž
 *
 * Creation date    : 20.10.96
 * Last modification: 24.02.97
 *
 *
 * Description: This module defines the account process.
 *
 * History:
 * 24.02.97: AccountNameExec added
 * 26.11.96: CLASS_ACCOUNT removed
 * 20.10.96: Creation of body
 *****************************************************************************/

#ifndef __ACCOUNT__
#define __ACCOUNT__

/****** DEFINES **************************************************************/

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

GLOBAL BOOL AccountInit     (VOID);
GLOBAL BOOL AccountTerm     (VOID);

GLOBAL VOID AccountExec     (ACCOUNT *pAccount, DB *db, SHORT table, SHORT inx, SHORT dir, SHORT device, BOOL minimize, LONG copies);
GLOBAL VOID AccountNameExec (CHAR *pAccountName, DB *db, SHORT table, SHORT inx, SHORT dir, SHORT device, BOOL minimize, LONG copies);

#endif /* __ACCOUNT__ */
