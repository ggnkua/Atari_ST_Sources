/************************************************************************
  Test program for DirWalk and ListFile.
  
  By Peter Strath.
 ************************************************************************/


#include <dos.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "dirwalk.c"
#include "listfile.c"


void GetOutputFileName(void);
void OutputToScreen(char *);
void OutputToPrinter(char *);
void OutputToFile(char *);
void OutputToAll(char *);

char output_file[FMSIZE];


int main
	(
	void
	)
	{
	
	int  menu_choice;
	char path[FMSIZE];
	char output_string[FMSIZE+5];
	
	printf("List files to;\n"
	       "  1. printer\n"
	       "  2. screen\n"
	       "  3. file\n"
	       "  4. all of the above\n"
	       ">");
	scanf("%d", &menu_choice);
	
	switch (menu_choice)
		{
		case 1:
			OutputRoutine = OutputToPrinter;
			break;
		case 2:
			OutputRoutine = OutputToScreen;
			break;
		case 3:
			OutputRoutine = OutputToFile;
			GetOutputFileName();
			break;
		case 4:
			OutputRoutine = OutputToAll;
			GetOutputFileName();
			break;
		default:
			exit(0);
		}
	
	printf("\nEnter path to start from;\n"
	       ">");
	scanf("%s", path);
	
	sprintf(output_string, "\n\n%s\\", path);
	(*OutputRoutine)(output_string);
	
	DirWalk(path, ListFile);
	
	sprintf(output_string, "\nFiles:   %d", num_files);
	OutputRoutine(output_string);
	sprintf(output_string, "Folders: %d", num_folders);
	OutputRoutine(output_string);
	
	printf("\nPress any key to exit.\n");
	getch();
	
	return(0);
	
	}


void GetOutputFileName
	(
	void
	)
	{
	
	char not_used[FMSIZE];
	
	do
		{
		printf("\nEnter filename with path to output to;\n"
		       ">");
		scanf("%s", output_file);
		} while(stcgfp(not_used, output_file) == 0);  /* Only except a filename with path. */
	
	}


void OutputToScreen
	(
	char * string
	)
	{
	
	printf("%s\n", string);
	
	}


void OutputToPrinter
	(
	char * string
	)
	{
	
	short x = 0;
	
	if (Cprnos() != 0)
		{
		while(string[x] != '\0')
			{
			Cprnout(string[x]);
			x++;
			}
		Cprnout('\r');
		Cprnout('\n');
		}
	
	}


void OutputToFile
	(
	char * string
	)
	{
	
	FILE * fp;
	
	if ((fp = fopen(output_file, "a")) != NULL)
		{
		fprintf(fp, "%s\n", string);
		fclose(fp);
		}
	
	}


void OutputToAll
	(
	char * string
	)
	{
	
	OutputToScreen(string);
	OutputToPrinter(string);
	OutputToFile(string);
	
	}
