/************************************************************************
  Directory walk routine.
  
  Applies a function to each file in a directory.
  
  Note;
  To make sure when listing all files on a drive that the working directory
  is not listed instead, add a '.' to the entered path, e.g. "E:\." instead
  of "E:\" or "E:".
  
  By Peter Strath.
 ************************************************************************/


void DirWalk(char *, void (*)(char *, struct FILEINFO *));


void DirWalk
	(
	char * path,
	void   (*FunctionToApply)(char *, struct FILEINFO *)
	)
	{
	
	struct FILEINFO file;
	
	chdir(path);
	
	if (dfind(&file, "*.*", FA_READONLY|FA_HIDDEN|FA_SUBDIR|FA_ARCHIVE) == -1)
		return;
	
	do
		{
		if (strcmp(file.name, ".") == 0 || strcmp(file.name, "..") == 0)
			continue;
		else
			(*FunctionToApply)(path, &file);
		} while (!dnext(&file));
	
	}
