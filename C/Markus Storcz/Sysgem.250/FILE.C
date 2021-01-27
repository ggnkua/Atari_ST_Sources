/* ------------------------------------------------------------------- *
 * Module Version       : 2.50                                         *
 * Author               : Gerhard Stoll                                *
 * Programming Language : Pure-C                                       *
 * Copyright            : (c) 2000, Gerhard Stoll, 		                 *
 * ------------------------------------------------------------------- */

#include        "kernel.h"

#include 				<ctype.h>
#include        <stdio.h>
#include        <string.h>
#include        <tos.h>
#include        <ext.h>

#define NO_CASE	0																		/* TOS-FS 		*/
#define HALF_CASE	1																	/* VFAT/Mac 	*/
#define FULL_CASE	2																	/* Minix 			*/

#define S_IFMT			0170000
#define S_IFDIR			0040000
#define S_ISDIR(m)	((m & S_IFMT) == S_IFDIR)

/* ------------------------------------------------------------------- */

EXTERN  SYSGEM  sysgem;

/* ------------------------------------------------------------------- */

LOCAL int fs_case_sens ( char *filename );


/* ------------------------------------------------------------------- */

WORD FileExists ( BYTE *filename )

{
	struct stat	s;
	
	if (filename[0] == EOS) return FALSE;
	return (stat(filename, &s) == 0);
}

/* ------------------------------------------------------------------- */

WORD PathExists ( BYTE *pathname )

{
	struct stat	s;
	BYTE	 p[80];
	WORD   len;
	WORD	 r = FALSE;
	
	if (pathname[0] != EOS)
		{
			if ((stat(pathname, &s) == 0) && S_ISDIR(s.st_mode))
				r = TRUE;

			/* Work-around fÅr MagiCPC, wo der stat(<Laufwerk>) nicht funkt! */
			if (sysgem.magicpc_version && !r)
				{
					len = (int)strlen(pathname);

					if (pathname[1] == ':' && len <= 3)	/* nur Laufwerk 'X:' oder 'X:\' */
						{

			/* Laufwerk existiert, wenn man das akt. Verzeichnis ermitteln kann */			
							if (Dgetpath(p, toupper(pathname[0]) - 64) == 0)
								r = TRUE;
						}
				}
		}
	return r;
}

/* ------------------------------------------------------------------- */

WORD GetPath ( BYTE *path, BYTE drive )

{
	WORD 	ret, drive_nr;

	if (drive == 0)
		{
			drive = 'A' + Dgetdrv();					/* Aktuelles Laufwerk */
			if (drive > 'Z')
				drive = drive - 'Z' + '0';
		}
	else
		{
			drive = toupper(drive);
		}
	if (drive >= '1' && drive <= '6')			/* Laufwerk nach Z mit Big-DOS oder MetaDOS > 2.60 */
		{
			drive_nr = drive - '1' + 26;
		}
	else
		{
			drive_nr = drive - 'A';
		}
	path[0] = drive;
	path[1] = ':';
	ret = (WORD) Dgetpath (path + 2, drive_nr + 1);
	strcat (path, "\\");
	
	if (fs_case_sens(path) == NO_CASE)
		StrToupper(path);

	return (ret == 0);
}

/* ------------------------------------------------------------------- */

WORD SetPath ( BYTE *path )

{
	WORD	drive, ret;

	if (path[0] == EOS)
		return FALSE;

	path[0] = toupper(path[0]);
	if (path[0] >= '1' && path[0] <= '6')
		{
			drive = path[0] - '1' + 26;
		}
	else
		{
			drive = path[0] - 'A';
		}
	Dsetdrv(drive);
	ret = (WORD) Dsetpath(path + 2);
	return (ret == 0);
}

/* ------------------------------------------------------------------- */

VOID SplitFilename(BYTE *fullname, BYTE *path, BYTE *name)
{
	BYTE	*str;
	WORD  len;

	str = strrchr (fullname, '\\');

	if (path != NULL)	path[0] = EOS;		/* schadet nix */
	if (name != NULL)	name[0] = EOS;		/* ditto       */

	if (str != NULL)
	{
		/* Dateinamen holen */
		if (name != NULL)	strcpy(name, str+1);

		/* Pfad mit Laufwerk bestimmen */
		if (path != NULL)
		{
			len =  (short)( str - (char *)fullname + 1);
			
			strncpy(path, fullname, len);
			path[len] = EOS;
		}
	}
}

/* ------------------------------------------------------------------- */

VOID SplitExtension(BYTE *filename, BYTE *name, BYTE *extension)
{
	BYTE *ptr = strrchr(filename, '.');
	BYTE *slash = strrchr(filename, '\\');
	BYTE *colon = strrchr(filename, ':');
	
	if (ptr == NULL || ptr == filename || 
		 ptr < slash || ptr - slash == 1 || ptr - colon == 1)
	{
		if (name) strcpy(name, filename);

		if (extension) extension[0] = EOS;

		return;
	}
	
	if (name)
	{
		strncpy(name, filename, ptr-filename);
		*( name + (ptr-filename)) = EOS;
	}

	if (extension)
		strcpy(extension, ptr+1);
}

/* ------------------------------------------------------------------- */

VOID SetExtension(BYTE *filename, BYTE *new_ext)
{
	BYTE	myext[5];
	BYTE *ptr = strrchr(filename, '.');
	BYTE *slash = strrchr(filename, '\\');
	BYTE *colon = strrchr(filename, ':');
	
	if (ptr == NULL || ptr == filename ||
		 ptr < slash || ptr - slash == 1 ||  ptr - colon == 1)
	{
		ptr = filename + strlen(filename);
		*ptr = '.';
	}

	if (fs_case_sens(filename) == NO_CASE)
	{

		strcpy(myext, new_ext);
		StrToupper(myext);
		strcpy(ptr+1, myext);
	}
	else
		strcpy(ptr + 1, new_ext);
}

/* ------------------------------------------------------------------- */

WORD MakeNormalPath(BYTE *path)
{
	WORD	i;
	BYTE	p[256];
	BYTE	*f, drv;
	WORD	ret;

	if (path[0] == EOS)
		return FALSE;

#ifdef __MINT__
	if (path[0] == '/')					/* UNIX-Pfad 					*/
	{
		unx2dos(path, p);
		strcpy(path, p);
	}
#endif

	/* Laufwerk bestimmen */
	if (path[1] != ':') 				/* Kein Laufwerk 			*/
	{
		drv = 'A' + Dgetdrv();		/* aktuelles Laufwerk */
		if (drv > 'Z')
			drv = drv - 'Z' + '0';	/* A..Z 1..6 */
		f = path;
	}
	else
	{
		path[0] = toupper(path[0]);
 		drv = path[0];
		if (drv > 'Z')
			drv = drv - 'Z' + '0';	/* A..Z 1..6 */
 		f = path + 2;
	}
	/* Pfad mit Laufwerk bestimmen */
	if (f[0]=='.' && (f[1]=='\\' || f[1]==EOS))
	{
		GetPath(p, drv); 			/* aktuellen Pfad nehmen */
		if (f[1]=='\\') 
			strcat(p,f+2);
	}
	else if (f[0]!='\\') 			/* Keine Root */
	{
		GetPath(p, drv);
		strcat (p, f);
	}
	else
	{
		p[0] = drv;
		p[1] = ':';
		p[2] = EOS;
		strcat (p, f);
	}

	i = (int)strlen(p);
	if (p[i-1] != '\\')
	{
		p[i] = '\\';
		p[i+1] = EOS;
	}

	ret = PathExists(p);
	if (!ret)
		p[i] = EOS;

	strcpy(path,p);
	return ret;
}

/* ------------------------------------------------------------------- */

VOID MakeShortPath(BYTE *path, BYTE *shortpath, WORD maxlen)
{
	BYTE	help[256];
	WORD	path_len;
	BYTE	*p1, *p2;

	strcpy(help, path);
	path_len = (int)strlen(help);
	if (maxlen < 18)
		SplitFilename(path, NULL, help);
	else if (path_len > maxlen)
	{
		p1 = strchr(help, '\\');
		p2 = p1;
		path_len += 2; 				/* zwei Punkte neu */
		while(*p2 != EOS && path_len > maxlen)
		{
			p2++;
			while(*p2 != '\\' && *p2 != EOS)
			{
				p2++;
				path_len--;
			}
		}
		if (*p2 != EOS)
		{
			memmove(p1 + 3, p2, strlen(p2) + 1);
			p1[1] = '.';
			p1[2] = '.';
		}
		else
		{
			p2 = strrchr(help, '\\');
			memmove(help, p2, strlen(p2) + 1);
		}
	}
	strcpy(shortpath, help);
}

/* ------------------------------------------------------------------- */

int fs_long_name(char *filename)
{
	char	path[256];
	long	ret;

	/* eigentlichen Dateinamen abschneiden und durch '.' ersetzen -
		muû sein, da Datei evtl. noch nicht existiert... */
	SplitFilename(filename, path, NULL);
	strcat(path, ".");
	ret = Dpathconf(path, 3);
	if ((ret < 0) || (ret == 12))
		ret = 0;
	return (int) ret;
}

/* ------------------------------------------------------------------- */

int fs_case_sens(char *filename)
{
	char	path[256];
	int	ret;

	/* Eigentlichen Dateinamen abschneiden und durch '.' ersetzen -
		muû sein, da Datei evtl. noch nicht existiert... */
	SplitFilename(filename, path, NULL) ;
	strcat(path, ".") ;
	ret = (int)Dpathconf(path, 6);

	/* MagiCPC 6.0 meldet 0, das ist aber falsch!! */
	if (sysgem.magicpc_version && ret == 0)
		ret = 2;

	switch (ret)
	{
		case 0 :				/* echter Unterschied, MinixFS */
			ret = FULL_CASE;
			break;
		case 2 :				/* kein echter Unterschied, VFAT, MacFS */
			ret = HALF_CASE;
			break;
		default:
			ret = NO_CASE;		/* Dpathconf() nicht verfÅgbar, oder kein Unterschied */
	}
	return ret;
}
