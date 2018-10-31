/*  config.c
 * v. .04 Nov 2000
 *
 * Creating files
 * Saving files
 * Reading files
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "global.h"

/* read_cfg_file()
 *
 * reads a config file from the location
 * specified
 *
 * this needs to be modified with every program
 * GemPanic has two values 
 * timer and snd_flag
 */

long
read_cfg_file(char *file_to_read)
{
	FILE *fp;	
	char tempstr[14];

	fp = fopen(file_to_read, "r");

	if (fp != (FILE *)NULL) 
	{
		fgets(tempstr, 10,  fp);
		timer = atoi(tempstr);

		fgets(tempstr, 10,  fp);
		snd_flag = atoi(tempstr);
		
		fclose(fp);
	} else
		return -1;

	return 1;
}

/* write_cfg_file()
 *
 * writes a config file to the location specified
 *
 * This needs to be modified with every program
 * GemPanic uses two values timer and snd_flag
 */
 
long
write_cfg_file(char *file_to_write)
{
	FILE *fd;
	char tempstr[16];

	fd = fopen(file_to_write,"w");

	if (fd == NULL)
		return 0;

	sprintf(tempstr,"%d\n\0",timer);		
	fwrite(tempstr, sizeof(char), strlen(tempstr), fd);

	sprintf(tempstr,"%d\n\0",snd_flag);		
	fwrite(tempstr, sizeof(char), strlen(tempstr), fd);

	fclose(fd);

	return 1;
}
