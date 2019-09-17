/* 
** New Folder function - run from File Manager. v0.09
*/

/* Function prototypes. */
void new_folder(void);
void do_down_fold(void);
void do_down_fold(void);
void edit_object(void);

int num_fold;   		/* The number of new folders to be created. */
char number_str[3];     /* The numbers, in a string. */
TEDINFO *fold_name_progress, *fold_num_progress;
int x, e=0;				/* x will contain any error codes from Dcreate
                           e is the number of folders created */
char path[41], buffer[64], progress_buf[10];    
TEDINFO *f_template, *fold_err;
num_fold = 1;			/* Starting value of number of folders. */
	
void new_folder(void)
{
	char temp[9];

	/* Getting the template name. */
    f_template = (TEDINFO *)((newfold+TEMPLATE)->ob_spec);
    strcpy (path, f_template->te_ptext);
    sprintf(temp, "%s", path);

    /* Check if task complete. */
   	if (e == num_fold)
   	{
   		fold_name_progress = (TEDINFO *) progress[PROGRES3].ob_spec;
       	fold_name_progress -> te_ptext = "Task completed";
       	fld_draw(form2handle, PROGRES3, 0);
       	progress[STOP].ob_state &= ~SELECTED;
        fld_draw(form2handle, STOP, 0);
       	task_in_progress = 0;
   		e=0;
   		printf("\a");	/* Sound bell to signify completion. */
		return;
   	}
   	/* Create a new folder. */
   	else
   	{
   		sprintf(path, "%s", temp);
   		sprintf (buffer,".%d", e+1);
        strcat (path, buffer);
		
       	x = Dcreate (path);
       	if (x == 0) 
       	{
       		sprintf(progress_buf, "Created: %s", path);
       		fold_num_progress = (TEDINFO *) progress[PROGRES2].ob_spec;
			fold_num_progress -> te_ptext = path;
			fld_draw (form2handle, PROGRES2, 0); 
			
			sprintf(progress_buf, "  %d of %d", e+1, num_fold);
			fold_name_progress = (TEDINFO *) progress[PROGRES1].ob_spec;
       		fold_name_progress -> te_ptext = progress_buf;
        	fld_draw (form2handle, PROGRES1, 0);
        }
       	if (x == -34)
       	{
       		fold_err = (TEDINFO *) progress[PROGRES3].ob_spec;
       		fold_err -> te_ptext = "Error: Path not found";
       		fld_draw(form2handle, PROGRES3, 0);
       	}
       	if (x == -36)
   		{
   			fold_err = (TEDINFO *) progress[PROGRES3].ob_spec;
       		fold_err -> te_ptext = "Error: Access denied";
       		fld_draw(form2handle, PROGRES3, 0);
       	}
       	e++;
    }
}

/*
** Manage the up and down arrows
*/


/* Increase number of folders to be created. */
void do_up_fold(void)
{
	num_fold++;
    if (num_fold > 999)
    {
      	num_fold = 0;
        strcpy (number_str, "000");
    }
    edit_object();
}

/* Decrease number of folders to be created. */
void do_down_fold(void)
{
	num_fold--;
    if (num_fold < 0) num_fold = 999;
    	edit_object();
}

void edit_object(void)
{
	TEDINFO *ob_tedinfo;

    fld_draw(form1handle, NUMFOLD, 0);
    /* Here we edit the string we're using for the text display
       in the object NUMFOLD so that it reflects the new value. */
    sprintf (number_str, "%d", num_fold);

    /* Then we find the object NUMFOLD's TEDINFO and find the
       te_ptext member to our updated string, after which we
       redraw the object NUMFOLD. */
    ob_tedinfo = (TEDINFO *) newfold[NUMFOLD].ob_spec;
    ob_tedinfo -> te_ptext = number_str;

    fld_draw(form1handle, NUMFOLD, 0);
}