/*
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define IS_COMMENT(c) ((c == ';') || (c == '!') || (c =='#'))
#define VERSION "0.1"
#define INPUT_ARCHITECTURE "68030"
#define OUTPUT_ARCHITECTURE "80386"
#define DELIMITERS " \t\n"

char input_filename[256];
char output_filename[256];
char input_buffer[256];
char output_buffer[256];

typedef enum { INST = 0 , SOURCE =1 , DEST =2 ,REST =3 } CONTEXT;
 
void convert_line(void)
{	char *current_token;
	char working_copy[256];
	output_buffer[0] = 0;
	CONTEXT current;
	strcpy(working_copy,input_buffer);
	if ((current_token = (char *) strtok(working_copy,DELIMITERS)) != NULL)
	{	do
		{	if (IS_COMMENT(current_token[0]))
			{	strcat(output_buffer,input_buffer+ (int) (current_token-working_copy));
				break;
			} else
			{ 	if ((int) (current_token - working_copy) == 0)
				{	strcpy(output_buffer,current_token);
					if (current_token[strlen(current_token)-1] != ':') 
						strcat(output_buffer,":");
					strcat(output_buffer,"\t");
				} else
				{	switch (current_context)
					{	case INST:
							break;
						case SOURCE:
							break;
						case DEST:	
							break;
						case REST:
							break;

					}
				}
				fprintf(stdout,"%s\n",current_token);
			}
		} 	while ((current_token = strtok(NULL,DELIMITERS)) != NULL);
	} else {	/* empty line */
		strcpy(output_buffer,input_buffer);
	}
}

void do_convert(void)
{	FILE *input_stream;
	FILE *output_stream;
	if ((input_stream = fopen(input_filename,"r")) == NULL)
	{	fprintf(stderr,"Fatal : Failed to open Input file.\n");
		exit(1);
	}
	if ((output_stream = fopen(output_filename,"w")) == NULL)
	{	fprintf(stderr,"Fatal : Failed to open Output file.\n");
		exit(1);
	}

	while (fgets(input_buffer,256,input_stream) != NULL)
	{
		convert_line();
		fprintf(output_stream,"%s",output_buffer);
	} 
		

	fclose(input_stream);
	fclose(output_stream);	
}

void usage(void)
{	fprintf(stderr,"Usage : %s <filename>\n",PROGRAM_NAME);	
}

int main (int argc,char **argv)
{	switch (argc)
	{	case 2:	
		{	char *tmp;
			strcpy(input_filename,argv[1]);
			if ( (tmp = (char *) strchr(input_filename,(int) '.')) == NULL)
			{	strcat(input_filename,".s");
			}
			strcpy(output_filename,input_filename);
			strcpy(strchr(output_filename,'.'),".asm");
			fprintf(stdout,"\n%s to %s Convertor V%s, ",INPUT_ARCHITECTURE,OUTPUT_ARCHITECTURE,VERSION);
			fprintf(stdout,"by Martin Griffiths.\n\n");
			fprintf(stdout,"Input %s Source Filename : %s\n",INPUT_ARCHITECTURE,input_filename);
			fprintf(stdout,"Output %s Source Filename : %s\n",OUTPUT_ARCHITECTURE,output_filename);
			do_convert();
			break;
		}
		default:
			usage();
	}
	return 0;
}
