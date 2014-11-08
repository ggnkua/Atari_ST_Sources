/**************************************************************/
/*  					Disk.C v.05							  */
/*															  */
/*	  Simple Disk routines									  */
/**************************************************************/

#include <osbind.h>
#include <string.h>
#include <stdio.h>
#include "disk.i"

extern char city_tla[3];

/**************************************************************/
/*   my_Fwrite - avoids sending 0 length to Fwrite			  */
/*    			This avoids crashes on TOS 1.0 & 1.2		  */
/**************************************************************/
void 
my_Fwrite(int file_handle, int file_length, char *string)
{
	if (file_length > 0)
		{
			Fwrite(file_handle,(long)file_length,string);
		}
}

/***************************************************************/
/*															   */
/*					File IO section							   */
/*  														   */
/***************************************************************/

long
create_file(char *file_to_make)
{
	char message[64];
	long cr_ret;	

	cr_ret = Fcreate(file_to_make,0x0);

	if (cr_ret > 0)
	{
		Fclose((int)cr_ret);
	}
	else
	{
		strcpy(message, "[1][");
		strcat(message, "Can't create file.");
		strcat(message, " ][  OK  ]");
		
		form_alert(1, message);
	}		

	return cr_ret;
}

long
write_prefs_file(char *file_to_make)
{
	long cr_ret;	
	char file_buffer[128];
	char file_buffer2[128];
	
	cr_ret = Fopen(file_to_make,1);

	if (cr_ret > 0)
	{
		sprintf(file_buffer,"%s",city_tla);
		sprintf(file_buffer2,"%02d",(int)strlen(file_buffer));
		Fwrite((int)cr_ret,strlen(file_buffer2),file_buffer2);
		Fwrite((int)cr_ret,1,"\n");
		my_Fwrite((int)cr_ret,(int)strlen(file_buffer),file_buffer);
		Fwrite((int)cr_ret,1,"\n");

		Fclose((int)cr_ret);
	}

	return cr_ret;
}

long
read_prefs_file(char *file_to_make)
{
	long cr_ret;	
	int header_length;
	char file_buffer[300];
	char header_buffer[2];

	cr_ret = Fopen(file_to_make,0);

	if (cr_ret > 0)
	{
		Fread((int)cr_ret,2,&header_buffer);
		stcd_i(header_buffer,&header_length);
		Fread((int)cr_ret,1,&file_buffer);
		Fread((int)cr_ret,(long)header_length,&city_tla);
		Fread((int)cr_ret,1,&file_buffer);
	
		Fclose((int)cr_ret);
	}
	else
	{
		/* create it */
	
		create_file(file_to_make);
		write_prefs_file(file_to_make);
	}

	return cr_ret;
}

/*
 * construct_path - build a GEMDOS path name out of a stem, which
 * optionally has junk on the end which we must delete, and a filename
 * which we are interested in.
*/
 
void
construct_path(char *dest,const char *path,const char *name)
{
	char *s=NULL;		/* used to track the position after final \ or : */

	if (path[0] && path[1]==':')
		s=&dest[2];
	while (*dest++=*path)
		if (*path++=='\\')
			s=dest;
	if (!s)
		s=dest;
	strcpy(s,name);
}
