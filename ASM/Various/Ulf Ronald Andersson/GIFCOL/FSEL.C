char	fs_path[128];
char	fs_name[16];
int		fs_retv, fs_exbt, fs_drive;
char	*tempsp;
	{	fs_drive = Dgetdrv();
		strcpy(fs_path,"a:\\");
		*fs_path += (char) fs_drive;
		Dgetpath(fs_path+3, fs_drive+1);
		tempsp = "\\*.*";
		if	(fs_path[3] == 0)
			tempsp++;
		strcat(fs_path, tempsp);
		*fs_name=0;
		fs_retv = fsel_input(fs_path, fs_name, &fs_exbt);
		if	(fs_retv < 0  ||  fs_exbt == 0  ||  *fs_name == 0)
			my_exit(1,NULL);
		tempsp = strrchr(fs_path,'\\');
		if	(tempsp != NULL)
			tempsp[1] = 0;
		strcpy(FileString,fs_path);
		strcat(FileString,fs_name);
	}
