/* icq.c
*
* version 0.1
* Dan Ackerman
* aka baldrick@netset.com
*
*  Purely for testing the ICQ.OVL
*
*/
#include <aes.h>
#include <stdio.h>
#include <string.h>
#include <tos.h>

#include "icqovl.h"

#define CON 2

/* structs in use to hold OVL values*/

ICQ_METH *icq_methods;

BASPAG *ovl_basepage;

/* ----------------------------------------------------------------- *
 *  Load OVL - does the Pexecs and scans the OVL for the functions   *
 * ----------------------------------------------------------------- */
int
load_ovl(char *ovl_name)
{
	long i;

	ovl_basepage = (BASPAG *)Pexec(3,ovl_name,NULL,NULL);
	
	Pexec(4,NULL,ovl_basepage,NULL);

	for (i = 0; i < ovl_basepage->p_dlen; i++)
	{
		/* Search for OVL Magic in DATA area */
		if(strncmp((char *)ovl_basepage->p_dbase + i,OVL_MAGIC,OVL_HDR_LEN)==0)
		{
			/* set function pointer structure */
			icq_methods = ((char *)ovl_basepage->p_dbase + i + OVL_HDR_LEN);
			
			return 1;
		}
	 }
 
	return 0;
}

/* ----------------------------------------------------------------- *
 * ovl_infos - just grabbing and displaying the return from the      *
 *             ovl_version() call.                                   *
 * ----------------------------------------------------------------- */
int
display_ovl_infos(void)
{
	char *ovl_version;

	ovl_version = ovl_version();

	/* I haven't formatted it, but thats trivial */
	Cconws(ovl_version);
	
	return(1);
}

/* ----------------------------------------------------------------- *
 * main - Show that we are running and do some work.                 *
 * ----------------------------------------------------------------- */
int main()
{
	Cconws("ICQ.OVL Test Client V. 01\r\n");
	
	if(load_ovl("ICQ.OVL") == 0)
	{
		Cconws("ICQ.OVL MAGIC not found\r\n");
	}
	else
	{
		/* If we are here we found the OVL_MAGIC hidden in array[] */

		/* let OVL do any init work it needs to do */
		ovl_init();
		
		/* Grab and show OVL version data */
		display_ovl_infos();

		/* Close the OVL */
		ovl_free();
	}

	/* Since this is a TOS client we will wait so that we can see
	 * our results
	 */
	 	
	Cconws("\r\nPress a key to exit\r\n");
	Bconin(CON);
   
  return (1);
}
