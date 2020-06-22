#if !defined( __COOKIE__ )

#define __COOKIE__

/*******************************************************************
*   Module:     COOKIE.H, C-Binding for COOKIE.S
*
*   Abstract:   Everything you need for accessing the 
*               cookie jar on Atari ST/TT computers.
*
*   Author:     Arnd Beissner, SciLab GmbH - Germany
*               Parts of the code are derived from Atari's 
*               TOS 1.06 Release Notes.
*
*   Compatibility:
*               Any ST/TT-compatible machine, any TOS version.
*
*   Version:    1.00
*
*   Date:       03.12.1990
*   
*   History:    no history
*
********************************************************************
*   Comments:
*
*   Most functions in this module must be called in supervisor mode.
*******************************************************************/

/*******************************************************************
* CK_JarInstalled
*
* See if the cookie jar is installed.
*
* Return value:
*   = pointer to the cookie jar (0 = not installed)
*******************************************************************/

long *CK_JarInstalled(void);

/*******************************************************************
* CK_UsedEntries
*
* Inquire the number of used cookie jar entries. The number includes
* the null cookie, so a return value of 0 means that there is no
* cookie jar at all.
*
* Return value:
*   = number of used cookie jar entries
*******************************************************************/

int CK_UsedEntries(void);
        
/*******************************************************************
* CK_JarSize
*
* Inquire the total number of cookie jar entries.
*
* Return value:
*   = total number of cookie jar entries
*******************************************************************/

int CK_JarSize(void);

/*******************************************************************
* CK_ResizeJar
*
* Resize the cookie jar to the desired size.
*
* Input arguments:
*   size = desired cookie jar size, number of entries
*
* Return value:
*   = state (0=FALSE, 1=TRUE)
*******************************************************************/

int CK_ResizeJar(int size);

/*******************************************************************
* CK_ReadJar
*
* Read the value of the specified cookie.
*
* Input arguments:
*   cookie = cookie name
*   value  = pointer to cookie value
*
* Return value:
*   = state (0=FALSE, 1=TRUE)
*******************************************************************/

int CK_ReadJar(long cookie, long *value);

/*******************************************************************
* CK_WriteJar
*
* Insert a new entry into the cookie jar. If no cookie jar exists
* or the current cookie jar is full, a new, bigger cookie jar is
* installed. The increment in size can be set using CK_SetOptions.
*
* Input arguments:
*   cookie = cookie name
*   value  = cookie value
*
* Return value:
*   = state (0=FALSE, 1=TRUE)
*******************************************************************/

int CK_WriteJar(long cookie, long value);

/*******************************************************************
* CK_SetOptions
*
* Set cookie jar options.
*
* Input arguments:
*   increment = cookie jar increment when allocating a new buffer
*   xbraID    = xbra id for reset handler
*******************************************************************/

void CK_SetOptions(int increment, long xbraID);

#define COOKIE_PTR  0x5A0L

typedef struct {
    long    magic;
    long    value;
} COOKIE_ENTRY;

void create_cookie(COOKIE_ENTRY *cookie,long magic,long value);
long get_cookie(long magic);
boolean new_cookie(COOKIE_ENTRY *cookie);

#endif
