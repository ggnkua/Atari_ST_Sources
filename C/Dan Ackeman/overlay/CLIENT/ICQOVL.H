/* icqovl.h
* 
* This will be the programming API for the icqovl.
*
* version 0.1
* Dan Ackerman
* aka baldrick@netset.com
*
*/

#ifndef __ICQ_API__H__
#define __ICQ_API__H__

/*--- Macro for prototyping ---*/
#ifdef __PUREC__
#  define ___CDECL cdecl
#else
#  define ___CDECL
#endif

/* Overlay Module name, no path */
#define ICQ_MOD		"ICQ.OVL"

/* unique header identification */
/* Use which ever version you feel more comfortable with,
   or more appropriately which ever version your compiler is 
   more comfortable with
*/
/*#define OVL_MAGIC		0x49635120L  */
#define OVL_MAGIC		"IcQ "

/* header identification length */
#define OVL_HDR_LEN		4

/*--- Module functions used by the client ---*/
typedef struct icq_methods_t
{
  long ___CDECL (*ovl_init)(void);
  char *___CDECL (*ovl_version)(void);
  long ___CDECL (*ovl_free)(void);
} ICQ_METH;


/* ----------------------------------------------------------------- *
 *  ovl_init() called by client to initialize ovl					 *
 * ----------------------------------------------------------------- */

#define ovl_init()             (*icq_methods->ovl_init)()

/* ----------------------------------------------------------------- *
 * ovl_version - Returns infos about module                          *
 * return format is the following strings comma delimited with a NULL*
 * terminator to the list                                            *
 *	ovl-version - just an integer version number first 2 digits      *
 *       major version, 2nd 2 digits minor version                   *
 *  ovl-date - Month,Day,Year (2 digits for each)                    *
 *  ovl-author - The authors name (up to 25 chars)                   *
 *  tcp/ip-stack ovl was written for - Just a text string (up to 10) * *                                                                   *
 * ex. 0001,031900,John Wayne,None\0                                 *                                                                  *
 * ----------------------------------------------------------------- */

#define ovl_version()          (*icq_methods->ovl_version)()		

/* ----------------------------------------------------------------- *
 * ovl_free - De-initialization of ovl                               *
 *                  (freeing memory, closing files, etc...)          *
 *  returns 0 on success, <0 if an error has occured                 *
 * ----------------------------------------------------------------- */

#define ovl_free()             (*icq_methods->ovl_free)()

#endif /* !__ICQ_API__H__ */
