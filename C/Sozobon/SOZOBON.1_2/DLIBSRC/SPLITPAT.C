#include <stddef.h>
#include <string.h>

#define	SPLIT_EXT	1
#define	SPLIT_FILE	2
#define	SPLIT_PATH	3

char *_splitpath(src, drive, path, file, ext)
	char *src, *drive, *path, *file, *ext;
	{
	register int state = SPLIT_EXT;
	register char *q;
	char buf[128];

	if(drive)
		*drive = '\0';
	if(path)
		*path = '\0';
	if(file)
		*file = '\0';
	if(ext)
		*ext = '\0';
	if(src == NULL)
		return(NULL);
	strcpy(buf, src);
	q = strrchr(buf, '\0');
	while((q--) > buf)
		{
		if(*q == '.')
			{
			if(state < SPLIT_FILE)
				{
				state = SPLIT_FILE;
				if(ext)
					strcpy(ext, q+1);
				*q = '\0';
				}
			}
		else if(*q == '\\')
			{
			if(state < SPLIT_PATH)
				{
				state = SPLIT_PATH;
				if(file)
					strcpy(file, q+1);
				if((q == buf) || (*(q-1) == ':'))
					*(q+1) = '\0';
				else
					*q = '\0';
				}
			}
		else if(*q == ':')
			break;
		}
	if(state < SPLIT_PATH)
		{
		if(file)
			strcpy(file, q+1);
		}
	else
		{
		if(path)
			strcpy(path, q+1);
		}
	*(q+1) = '\0';
	if(drive)
		strcpy(drive, buf);
	return(src);
	}

char *_makepath(dst, drive, path, file, ext)
	register char *dst;
	char *drive, *path, *file, *ext;
	{
	register char *p;

	if(dst)
		{
		*dst = '\0';
		if(drive && *drive)
			strcat(dst, drive);
		if(path && *path)
			{
			strcat(dst, path);
			p = strrchr(dst, '\0');
			if(*(p - 1) != '\\')
				strcat(dst, "\\");
			}
		if(file && *file)
			strcat(dst, file);
		if(ext && *ext)
			{
			strcat(dst, ".");
			strcat(dst, ext);
			}
		}
	return(dst);
	}
