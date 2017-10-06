/*  fileio.c
 * v. .04 Nov 2000
 *
 * Creating files
 * Saving files
 * Reading files
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "boink.h"

extern int objcolors[];

long
read_cfg_file(char *file_to_read)
{
	FILE *fp;	
	char tempstr[14];
	int i;

	fp = fopen(file_to_read, "r");

	if (fp != (FILE *)NULL) 
	{
		fgets(tempstr, 10,  fp);
		timer = atoi(tempstr);

		for (i = 0; i < 6; i++)
		{
			if(fgets(tempstr, 10,  fp)!=(char *)NULL)
				objcolors[i] = atoi(tempstr);
			else
				objcolors[i] = 1;
		}
		
		fclose(fp);
	} else
		return -1;

	return 1;
}

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

	sprintf(tempstr,"%d\n\0",objcolors[0]);
	fwrite(tempstr, sizeof(char), strlen(tempstr), fd);
			
	sprintf(tempstr,"%d\n\0",objcolors[1]);
	fwrite(tempstr, sizeof(char), strlen(tempstr), fd);

	sprintf(tempstr,"%d\n\0",objcolors[2]);
	fwrite(tempstr, sizeof(char), strlen(tempstr), fd);

	sprintf(tempstr,"%d\n\0",objcolors[3]);
	fwrite(tempstr, sizeof(char), strlen(tempstr), fd);

	sprintf(tempstr,"%d\n\0",objcolors[4]);
	fwrite(tempstr, sizeof(char), strlen(tempstr), fd);

	sprintf(tempstr,"%d\n\0",objcolors[5]);
	fwrite(tempstr, sizeof(char), strlen(tempstr), fd);

	fclose(fd);

	return 1;
}

/* This will write out the highscore file
	This routine could probably use some 
	error checking
*/

long
write_score(void)
{
	FILE *fd;
/*	char tempstr[24];*/
	int i;

	fd = fopen(score_file,"w");
	if (fd==NULL)  return 0;

	for (i = 0; i < 10; i++)
		{
			fprintf(fd,"%s\n",scores[i].name);
			fprintf(fd,"%d\n",scores[i].level);
			fprintf(fd,"%ld\n",scores[i].score);
		}

	fclose(fd);

	return 1;
}


long
read_highscore(void)
{
	int formdo_ret;
	long fileio_return;
	int i;
	FILE *fp;	
	char tempstr[30];

reopen_score:

	fp = fopen(score_file, "r");

	if (fp != (FILE *)NULL) 
	{
		for (i = 0; i < 10; i++)
			{
				/* This is just to clear out the name */
				strcpy(scores[i].name,"              \0\0");

				fgets(tempstr, 16,  fp);
				if(tempstr[strlen(tempstr)-1]=='\n')
				  tempstr[strlen(tempstr)-1]=0;
				if(tempstr[strlen(tempstr)-1]=='\r')
				  tempstr[strlen(tempstr)-1]=0;
				strcpy(scores[i].name,tempstr);

				fgets(tempstr, 10,  fp);
				scores[i].level = atoi(tempstr);

				fgets(tempstr, 10,  fp);
				scores[i].score = atol(tempstr);
			}

		fclose(fp);

		/* Init RSC form for High Score */

		for (i = 0; i < 10; i++)
		{
			sprintf(tempstr,"%2d %-14s %2d %6ld",i+1,scores[i].name,
				scores[i].level,scores[i].score);

			set_tedinfo(scorelist_dial,SCORE1 + i,tempstr);
		}

	}
	else
	{
		/*we need to tell them the file doesn't exist*/

		formdo_ret = form_alert(1,alert_noscore);

		if (formdo_ret == 1)
		{
			/* we will have to create one now*/

			if ( write_score() == 0 )
				form_alert(1,alert_cantcreate);
			else
				goto reopen_score;					
		}
		else
		{
		     form_alert(1,alert_cantfind);
		}
	}
	
	return 1;
}

long
read_level_file(char *file_to_read)
{
	FILE *fp;	
	char tempstr[200];
	char *temp;
	int i = 0;
	int ii = 0;
	
	extern char brickmask[99][63];

	fp = fopen(file_to_read, "r");

	if (fp != (FILE *)NULL) 
	{
		while(fgets(tempstr, 200,  fp)!=NULL)
		{
			if (strncmp(tempstr,"#",1)!=0)
			{
				temp = (strtok(tempstr,","));

				brickmask[ii][i] = atoi(temp);
				i++;
				
				if (i == 63)
				{
					ii++;
					i = 0;
				}
				
				while((temp = strtok(NULL,",")) != NULL)
					{
						if ((temp[0] == ' ')||
							(temp[0] == '\r')||
							(temp[0] == '\n'))
							;
						else
						{
							brickmask[ii][i] = atoi(temp);

							i++;
				
							if (i == 63)
							{
								ii++;
								i = 0;
							}
						}	
					}					
			}
			else
			{
				/* This line is a remark */
				/* maybe do something with them sometime */
				;			
			}			
		}		
		
		fclose(fp);
	} else
	{
		/* Can't read file */
		printf("Can't read file\n");
		return -1;
	}
		
	file_levels = ii;
	return 1;
}
