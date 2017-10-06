/* icqovl.c
*
* version 0.1
* Dan Ackerman
* aka baldrick@netset.com
*
* This will eventually be an OVL file for an ICQ application,
* it will handle the lowlevel communications with the server.
* Somewhat similar in idea to the icqlib for unix.
*
*/
#include <aes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <tos.h>

#include "icqovl.h"


/*--- Prototypes ---*/
long ___CDECL ovl_init(void);
char *___CDECL ovl_version(void);
long ___CDECL ovl_free(void);

/* structs in use to hold OVL values*/
/*struct icq_methods_t icq_methods {	ovl_init, ovl_version, ovl_free };*/

char filemagic[4] = OVL_MAGIC;
ICQ_METH icq_methods = {ovl_init,ovl_version,ovl_free};
struct ovl_info_t icq_ovl_data;

int ovl_id;
int parent_id;

/* ----------------------------------------------------------------- *
 *  ovl_init() called by client to initialize ovl					 *
 * ----------------------------------------------------------------- */
long ___CDECL ovl_init(void)
{
	/* Do any initialization that the OVL may need to do,
	 * getting access to external functions etc here
	 */

	/* First fill out the OVL information structure 
	 * You could do this like icq_methods above, I personally
	 * prefer doing something like this so that it's easier to
	 * edit later.
	 */
	 
	icq_ovl_data.version = "0001";
	icq_ovl_data.date = "031900";
	icq_ovl_data.author="Dan Ackerman";
	icq_ovl_data.stack="STiK API";
	
	return(0);
}

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
char *___CDECL ovl_version(void)
{
	char ret_str[45];
	
	sprintf(ret_str,"%s,%s,%s,%s\0",icq_ovl_data.version,
			icq_ovl_data.date,icq_ovl_data.author,icq_ovl_data.stack);
	
	return(ret_str);
}


/* ----------------------------------------------------------------- *
 * ovl_free - De-initialization of ovl                               *
 *                  (freeing memory, closing files, etc...)          *
 *  returns 0 on success, <0 if an error has occured                 *
 * ----------------------------------------------------------------- */
long ___CDECL ovl_free(void)
{
	appl_exit();
	
	return(0);
}


/* ----------------------------------------------------------------- *
 * main - Appl_init OVL and Ptermres                                 *
 * ----------------------------------------------------------------- */
int main(void)
{
  static void *array[] = {
  	(void *)OVL_MAGIC,
  	(ICQ_METH *)&icq_methods
  	};
  	
  ovl_id = appl_init();

  /* Don't actually write anything, just keep array from being swallowed */
  write(1, array[0], 0);
  
  Ptermres(_PgmSize,0);		/* sit into memory */
  
  return (1);
}
