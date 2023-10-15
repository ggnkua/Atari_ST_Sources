/********************************************\
|** LOAD_INF.C is (c) Klaus Pedersen. 7/90 **|
|** Written in Borland Turbo C v2.0        **|
\********************************************/

#include <aes.h>
#include <tos.h>
#include <string.h>

#define _vTOS 				(_GemParBlk.global[0])

int MaxShell = 4192;
char Buffer[4192];




/************************************************\
|*				FILE SELECT ROUTINE 						*|
\************************************************/
char *strRchr(char *path, char look)
{char *cptr;
	cptr = 0l;
	while (*path)
		if (*path++ == look) cptr = path-1;
	if (cptr)
		return cptr;
	else
		return path;
}


void BuildFName(char *path, char *fname, char look)
{char *p;
	if (*(p = strRchr(path, look)) != 0) p++;
	strcpy(p, fname);
}


int ForceExt(char *path, char *ext)
{char *ph;
	ph = strRchr(strRchr(path, '\\'), '.');
	strcpy(ph, ext);
	return 0;
}


int FileSelect(char *Path, char *Mask, char *DefFile, char *Label)
/*	File select : 
 * 	if Path[0] == '.' then on default path,
 *			else on path in 'Path'...
 *		if  DefFile[0] == '*' then take Default file name from Path...
 * if TOS is higher than 1.2 then the Label can be used...  
 * Returns : - Full file path in Path.
 *           - 0 if no file has been selected...
 * NOTE : 'Mask' must have a leading back-slash!
 *        'DefFile' must be at least 13 bytes!
 */
{int  ok_bottn;
 char *p;

	if (*DefFile == '*')
	{	if (*(p = strRchr(Path, '\\')) != 0) p++;
		strcpy(DefFile, p);
	}
	
 	if (*Path == '.')
	{	Dgetpath(Path, 0);
		strcat(Path, Mask);
	}
	else
	 	BuildFName(Path, Mask+1, '\\');
	 	
	if (_vTOS < 0x130 || *Label == '\0')
	 	fsel_input(Path, DefFile, &ok_bottn);
	else
		fsel_exinput(Path, DefFile, &ok_bottn, Label);
		
	if (ok_bottn)
		BuildFName(Path, DefFile, '\\');
	return ok_bottn;
}


main(int argc, const char *argv[])
{char Path[128], *p;
 const char *loadPath;
 static char M[7] = "\\*.INF", F[13] = "DESKTOP.INF";
 int f;
 long l;
 
	appl_init();

	if (_vTOS < 0x130) MaxShell = 1024;
		
	if (argc <= 1)
	{	*Path = '.'; /* Start the fileselect from default dir */
		if ( !FileSelect(Path, M, F, "Select New Desk Config.") ) goto No_Load;
		loadPath = Path; /* use name from file selector */
	}
	else /* use name from the command line */
		loadPath = argv[1];
		
	
	if ( (f = Fopen(loadPath, 0)) > 0 )
	{	l = Fseek(0, f, 2); /* get length of file */
		Fseek(0, f, 0);
		if (l < MaxShell) /* will the file fit in the Shell buffer?*/
		{	Fread(f, l, Buffer);
			p = &Buffer[l]; /* insert a ^Z after the file */
			*p++ = '\32';
			l = MaxShell;
			do 
				*p++ = 0;
			while (--l);
			shel_put(Buffer, MaxShell);
		}
		Fclose(f);
	}

No_Load:
	appl_exit();
	return 0;
}
