int	f_handle;
int     cur_drive;
char    cur_dir[68];
char	tbuf[108];	/* Strings for handling string input	*/
char	path_buf[108];	/* stuff...				*/
char	wild_buf[108];

/*********************************************
 *
 * DO_FILE_STUFF
 *	Handles the fsel_input end of the program, getting
 * the lesson number...
 *
 */

do_file_stuff()
{
	int	fs_ireturn, fs_iexbutton;
	int	i, j;
	char	new_dir[108];

	new_dir[0] = 0;

	for(i = 0; i <= 107; i++)
	{
		wild_buf[i] = 0;
		tbuf[i] = 0;
	}
			
	cur_drive = Dgetdrv();
	Dgetpath(cur_dir, 0);
	wild_buf[0] = cur_drive + 'A';
	wild_buf[1] = ':';
	strcat(wild_buf, cur_dir);
	strcat(wild_buf, "\\");
	strcat(wild_buf, "*.PGM");

	wind_update(TRUE);	
	fs_ireturn = fsel_input(wild_buf, tbuf, &fs_iexbutton);
	wind_update(FALSE);

	if(fs_ireturn == 0)
	{
		set_error();
		redraw();
	}
	else
	{
		for (i = 0; i <= 107; i++)
		{
			if(wild_buf[i] == 0x2A)	/* asterisk... */
			{
				j = i;
				break;
			}
		}
		for (i = 0; i <= (107 - j); i++)
		{
			wild_buf[i + j] = tbuf[i];
			if(tbuf[i] == 0)
				break;
		}
		for (i = 0; i <= 107; i++)
		{
			tbuf[i] = wild_buf[i];
		}
	}
	return(fs_iexbutton);	
}
/********************
 *
 * LOAD_FILE()
 *
 */
 
load_file()
{
    int i;

    i = do_file_stuff();
    if (i == F_OK)
    {
	f_handle = Fopen(&tbuf[0], 0);
	if (f_handle < 0)
	{
	   set_error();
	   redraw();
	}
	else
	{
	    i = Fread(f_handle, 1000L, program);
	    if (i != 1000)
	    {
	    	set_error();
	    	redraw();
	    }
	    Fclose(f_handle);
	}
    }
}
/********************
 *
 * SAVE_FILE()
 *
 */
 
save_file()
{
    int i;

    i = do_file_stuff();
    if (i == F_OK)
    {
	f_handle = Fcreate(&tbuf[0], 0);
	if (f_handle < 0)
	{
	   set_error();
	   redraw();
	}
	else
	{
	    i = Fwrite(f_handle, 1000L, program);
	    if (i != 1000)
	    {
	    	set_error();
	    	redraw();
	    }
	    Fclose(f_handle);
	}
    }
}

