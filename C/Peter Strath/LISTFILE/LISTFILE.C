/************************************************************************
  List file routine, to be called from DirWalk.
  
  Constructs a string to output as a list entry.
  
  By Peter Strath.
 ************************************************************************/


void ListFile(char *, struct FILEINFO *);

void (*OutputRoutine)(char *);
long num_folders = 0, num_files = 0;
short indent_level = 0;


void ListFile
	(
	char *            path,
	struct FILEINFO * file
	)
	{
	
	char  output_string[200];
	short i;
	
	strcpy(output_string, "  ");
	for (i=0; i<indent_level; i++)
		strcat(output_string, "  ");
	
	strcat(output_string, file->name);
	
	if (file->attr & FA_SUBDIR)
		{
		char new_path[FMSIZE];
		
		strcat(output_string, "\\");
		(*OutputRoutine)(output_string);
		
		indent_level++;
		sprintf(new_path, "%s\\%s", path, file->name);
		DirWalk(new_path, ListFile);
		indent_level--;
		
		num_folders++;
		}
	else
		{
		(*OutputRoutine)(output_string);
		num_files++;
		}
	
	}
