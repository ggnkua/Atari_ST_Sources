#include <stdio.h>
#include <osbind.h>
#include <ctype.h>
#include <strings.h>

#define TRUE    1
#define FALSE   0
#define F_SUBDIR 0x10
#define LMAX    256
#define M_OFF	256
#define M_ON	257

char errbuf[LMAX];      /* error message buffer */
int cmdterm;            /* command terminator */
char line[LMAX];        /* input line buffer */
char *lptr;             /* input line pointer */
int tmp;                /* temporary file number */

char cmd[LMAX], cmd1[LMAX];         /* command name */
char arglist[LMAX];     /* argument list */
char infile[LMAX];      /* input file name */
char outfile[LMAX];     /* output file name */
char buf[8192], secbuf[512];

int inpresent;          /* input file present */
int outpresent;         /* output file present */
int tmpinfile;          /* input file is a temporary */
int tmpoutfile;         /* output file is a temporary */

short inhandle;         /* input file handle */
short outhandle;        /* output file handle */
short inmemory;         /* original input handle */
short outmemory;        /* original output handle */

int	work_in[11], work_out[57], contrl[12], intin[128],
	ptsin[128], intout[128], ptsout[128], handle, dum,
	i, drive, wide, print, attr, fspec, quit, tdrive,
	doble, track;

long result;

char *Path = ",\\bin";
char *Extensions = ".prg,.tos,.ttp,.app";

int _stack = 4096;
int _mneed = 4096;

char str[160], path[80], tpath[80], tpath1[80];

char *next();

main(argc,argv)
  int argc; char *argv[];
{


	initialize();	

	v_hide_c(handle);
	v_clrwk(handle);
	v_hide_c(handle);
	Cursconf(1,0);
	v_curhome(handle);
	v_dspcur(handle);

    inmemory = Fdup(0);
    outmemory = Fdup(1);

	while(quit == FALSE)
	{

		/* Write the command line prompt ala MS DOS */
		get_path(str);
		Dgetpath(tpath, 0);
        Cconws(str);
		Cconws(tpath);
		Cconws(">");

        /* get the command line */
        if ((lptr = fgets(line,LMAX,stdin)) == NULL)
            break;

        /* initialize */
        inpresent = outpresent = tmpinfile = tmpoutfile = FALSE;
        tmp = 0;

        /* parse and execute each command on the line */
        while (parse() && (cmdterm == ';' || cmdterm == '|'))
            ++lptr;
    }
	Cursconf(0,0);
	v_show_c(handle);
	v_clsvwk(handle);
	appl_exit();
}

/* parse - parse and execute a command */
int parse()
{
    char path[LMAX],ext[LMAX],*pp,*ep,*ap;
    int pathlen,arglen,ch;
    short int sts;

    /* parse the command name */
    if (!token(cmd))
        return (FALSE);

    /* parse the argument list */
    for (ap = &arglist[1],arglen = 0; (ch = cmgetc()) != EOF; )
        switch (ch) {
        case '<':
            getfile(infile);
            inpresent = TRUE;
            break;
        case '>':
            getfile(outfile);
            outpresent = TRUE;
            break;
        default:
            if (arglen >= 255)
                return (error("argument list too long"));
		    *ap++ = ch;
            ++arglen;
        }
    arglist[0] = arglen;

    /* setup a temporary output file for pipes */
    if (cmdterm == '|') {
        sprintf(outfile,"pipe%d.tmp",++tmp);
        outpresent = TRUE;
        tmpoutfile = TRUE;
    }

    /* handle input redirection */
    if (inpresent) {
        if ((inhandle = Fopen(infile,0)) < 0) {
            sprintf(errbuf,"can't open: %s",infile);
            return (error(errbuf));
        }
        Fforce(0,inhandle);
    }

    /* handle output redirection */
    if (outpresent) {
        if ((outhandle = Fcreate(outfile,0)) < 0) {
            if (inpresent) {
                Fclose(inhandle);
                Fforce(0,inmemory);
            }
            sprintf(errbuf,"can't create: %s",outfile);
            return (error(errbuf));
        }
        Fforce(1,outhandle);
    }

    /* check each element of the path */
    for (pp = Path; pp = next(pp,path); )
	{

        /* insert the path separator */
        if (path[0] != '\0')
            strcat(path,"\\");

        /* combine the path with the command name */
        strcat(path,cmd);
        /* determine the length of the path so far */
        pathlen = strlen(path);

        /* check each extension */
        for (ep = Extensions; ep = next(ep,ext); ) {

            /* add the extension to the path */
            strcpy(&path[pathlen],ext);

            /* try to execute the command */
			v_show_c(handle);
            if ((sts = Pexec(0,path,arglist,"")) != -33)
			{
				v_hide_c(handle);
                closeup();
                if (sts)
				{
                    if (tmpinfile)
                        unlink(infile);
                    if (tmpoutfile)
                        unlink(outfile);
                    sprintf(errbuf,"bad status: %d",sts);
                    return (error(errbuf));
                }
                return (TRUE);
            }
        }
    }
    closeup();


	for(i=0; i<strlen(cmd); i++)
	{
		if(isalpha(cmd[i]))
			cmd[i] = cmd[i] - 'a' + 'A';
	}

	if(strlen(cmd)<2)
	{
		drive = cmd[0] - 'A';
		Dsetdrv(drive);
	}

	if(strlen(cmd)>=2)
	{
		for(i=0; i<3; i++)
		{
			cmd1[i] = cmd[i];
		}
		for(i=3; i<=strlen(cmd); i++)
		{
			cmd[i-3] = cmd[i];
		}
		if(!strcmp(cmd1, "DIR"))
		{
			wide = FALSE; print = FALSE; fspec = FALSE;
		if(cmd[0] == '/')
			{			
			switch(cmd[1])
			{
				case 'W':
					wide = TRUE;
					if(cmd[2] == 'P')
						print = TRUE;
					break;

				case 'P':
					print = TRUE;
					if(cmd[2] == 'W')
						wide = TRUE;
					break;
		
				case 'F':
					fspec = TRUE;
					if(cmd[2] == 'W')
					{	
						wide = TRUE;
						if(cmd[3] == 'P')
							print = TRUE;
					}
					if(cmd[2] == 'P')
					{	
						print = TRUE;
						if(cmd[3] == 'W')
							wide = TRUE;
					}
					break;
				
				default:
					print = FALSE;
					wide = FALSE;
					fspec = FALSE;
					break;
			}
		}
		get_dir();

		/* clear out the /w for future dir requests */

			strcpy(cmd, "                        ");
			strcpy(cmd, "");
		}

		if(!strcmp(cmd1, "CD\\"))
		{
			strcat(cmd, "\\");
			Dsetpath(cmd); 
		}

		if(!strcmp(cmd1, "CLR"))
		{
			graf_mouse(M_OFF, 0x0L);
			v_clrwk(handle);
			graf_mouse(M_OFF, 0x0L);
			v_curhome(handle);
		}

		if(!strcmp(cmd1, "QUI"))
		{
			quit = TRUE;
		}

		if(!strcmp(cmd1, "COP"))
		{
			Cconws("Copy Files\n\r");
		}

		if(!strcmp(cmd1, "DEL"))
		{
			Cconws("Delete Files\n\r");
			Cconws("What file to delete:");
			fgets(tpath, 13, stdin);
			Fdelete(tpath);
		}

		if(!strcmp(cmd1, "FOR"))
		{
			Cconws("Format what Drive:");
			fgets(tpath,5,stdin);
			tdrive = drive; /* save current drive just in case */
			if(isalpha(tpath[0]))
			{ 	tpath[0] = tpath[0] - 'a' + 'A';
				drive = tpath[0] - 'A';
				Cconws("Format Double Sided?");
				fgets(tpath,5,stdin);
				if(isalpha(tpath[0]))
				{	tpath[0] = tpath[0] - 'a' + 'A';
					if(tpath[0] == 'Y')
						doble = TRUE;
					else doble = FALSE;
				}
				else doble = FALSE;
				Cconws("Formatting ");
				if(doble)
					Cconws("Double Sided\n\r");
				else
					Cconws("Single Sided\n\r");
				for(i=0; i<=79; i++)
				{	result = Flopfmt(buf, 0L, drive, 9, i, 0, 1, 0x87654321L, 0xE5E5);
					if(doble)
						result = Flopfmt(buf, 0L, drive, 9, i, 1, 1, 0x87654321L, 0xE5E5);
				}
				for (i=0;  i < 512;  secbuf[i++] = 0);
				for (track = 0;  track <=2;  track++)
				{
					for (i = 1;  i <= 9;  i++)
					{
						result = Flopwr(secbuf, 0L, drive, i, track, 0, 1);
					}
				}
				Protobt(secbuf, 0x10000000L, (doble+2), 0);
				Cconws("Writting Boot Sector\n\r");
				Flopwr(secbuf, 0L, drive, 1, 0, 0, 1);

				drive = tdrive;
			}
		}

		if(!strcmp(cmd1, "REN"))
		{
			Cconws("Rename Files\n\r");
			Cconws("Old Filename:");
			fgets(str, 13, stdin);
			Cconws("New Filename:");
			fgets(tpath, 13, stdin);
			Frename(0, str, tpath);
		}

	}
}

closeup()
{
    /* close the redirected input file */
    if (inpresent) {
        Fclose(inhandle);
        Fforce(0,inmemory);
    }

    /* close the redirected output file */
    if (outpresent) {
        Fclose(outhandle);
        Fforce(1,outmemory);
    }

    /* delete the temporary input file */
    if (tmpinfile)
        unlink(infile);

    /* reset the redirection flags */
    inpresent = outpresent = tmpinfile = tmpoutfile = FALSE;

    /* handle pipes */
    if (cmdterm == '|') {
        strcpy(infile,outfile);
        inpresent = TRUE;
        tmpinfile = TRUE;
    }
}

/* getfile - get an input or output file name */
getfile(file)
  char *file;
{
    int ch;
    while ((ch = cmgetc()) != EOF && !isspace(ch))
        *file++ = ch;
    cmungetc(ch);
    *file = '\0';
}

/* next - get the next element of a comma delimited list */
char *next(list,elem)
  char *list,*elem;
{
    /* check for the end of the list */
    if (*list == '\0')
        return (NULL);

    /* get the next element from the list */
  while (*list != '\0' && *list != ',')
        *elem++ = *list++;
    *elem = '\0';

    /* skip past the comma */
    if (*list == ',')
        ++list;

    /* return the tail of the list */
    return (list);
}

/* token - find the next token */
int token(tkn)
  char *tkn;
{
    int ch;

    /* skip leading spaces */
    while ((ch = cmgetc()) != EOF && isspace(ch))
        ;
    cmungetc(ch);

    /* fail if there is no token */
    if (ch == EOF)
        return (FALSE);

    /* collect the next space delimited token */
    while ((ch = cmgetc()) != EOF && !isspace(ch))
        *tkn++ = ch;
    cmungetc(ch);
    *tkn = '\0';

    /* return successfully */
    return (TRUE);
}

/* cmgetc - get a character from the command line */
int cmgetc()
{
    switch (*lptr) {
    case ';':
    case '|':
    case '\0':
    case '\r':
    case '\n':
        cmdterm = *lptr;
        return (EOF);
    default:
        return ((int)*lptr++);
    }
}

/* cmungetc - unget a character from the command line */
cmungetc(ch)
  int ch;
{
    if (ch != EOF)
        *--lptr = ch;
}

initialize()
{
	appl_init();
	handle = graf_handle(&dum, &dum, &dum, &dum);
	for(i=0; i<10; work_in[i++] = 1);
	work_in[10] = 2;
	v_opnvwk(work_in, &handle, work_out);
}

get_path(path)
char *path;
{
	*path++ = ((drive = Dgetdrv())+'A');
	*path++ = ':';
	*path++ = '\\';
}

int error(msg)
  char *msg;
{
    printf("Error: %s\n",msg);
    return (FALSE);
}

get_dir()
{
	char str1[60];
	char dta[44];
	int end = 0;

	strcpy(tpath1, "");

	if(fspec)
	{
		Cconws("What Filespec to search for:");
		fgets(tpath,13,stdin);
		strcat(tpath1,tpath);
	}
	else
		strcat(tpath1, "*.*");
	Fsetdta(dta);


	end = Fsfirst(tpath1, F_SUBDIR);
	if(dta[21] & F_SUBDIR)
	{
		strcpy(str1, "*");
		if(print)
			Cprnout("*");
		for(i=30; i<44; i++)
		{
			str1[i-29] = dta[i];
			if(print)
				Cprnout(dta[i]);
		}
		strcat(str1, "");
		Cconws(str1);
		if(wide)
		{
			/* print 5 accross */
			wide++;
			if(wide > 6)
			{
				wide = TRUE;
				Cconws("\r\n");
				if(print)
				{Cprnout(13); Cprnout(11);}
			}
			else
			{
				Cconws("  ");
				if(print)
				{
					Cprnout(32);
					Cprnout(32);
				}
			}
		}
		else
		{
			Cconws("\r\n");
			if(print)
				{Cprnout(13); Cprnout(11);}
		}	 
	}

	while(end >-1)
	{
		end = Fsnext();
		if(dta[21] & F_SUBDIR)
		{
			strcpy(str1, "*");
			for(i=30; i<44; i++)
			{
				str1[i-29] = dta[i];
				if(print)
					Cprnout(dta[i]);
			}
			strcat(str1, "");
			Cconws(str1);
			if(wide)
			{
				/* print 5 accross */
				wide++;
				if(wide > 6)
				{
					wide = TRUE;
					Cconws("\r\n");
					if(print)
						{Cprnout(13); Cprnout(11);}
				}
				else
					Cconws("  ");
					if(print)
					{
						Cprnout(32);
						Cprnout(32);
					}
			}
			else
			{
				Cconws("\r\n");
				if(print)
					{Cprnout(13); Cprnout(11);}
			}
		}			
	}

	end = Fsfirst(tpath1, 2);

	for(i=30; i<44; i++)
	{
		str1[i-30] = dta[i];
		if(print)
			Cprnout(dta[i]);
	}
	strcat(str1, "");
	Cconws(str1);
	if(wide)
	{
		/* print 5 accross */
		wide++;
		if(wide > 6)
		{
			wide = TRUE;
			Cconws("\r\n");
			if(print)
				{Cprnout(13); Cprnout(11);}
		}
		else
		{
			Cconws("  ");
				if(print)
				{
					Cprnout(32);
					Cprnout(32);
				}
		}
	}
	else
	{
		Cconws("\r\n");				 
		if(print)
			{Cprnout(13); Cprnout(11);}
	}
	while(end > -1)
	{
		end = Fsnext();
		if(end >-1)
		{
		for(i=30; i<44; i++)
		{
			str1[i-30] = dta[i];
			if(print)
				Cprnout(dta[i]);
		}
		strcat(str1, "");
		Cconws(str1);
		if(wide)
		{
			/* print 5 accross */
			wide++;
			if(wide > 6)
			{
				wide = TRUE;
				Cconws("\r\n");
				if(print)
					{Cprnout(13); Cprnout(11);}
			}
			else
			{
				Cconws("  ");
				if(print)
				{
					Cprnout(32);
					Cprnout(32);
				}
			}
		}
		else
		{
			Cconws("\r\n");
			if(print)
				{Cprnout(13); Cprnout(11);}
			}
		}
	}
	Cconws("\r\n");
}
