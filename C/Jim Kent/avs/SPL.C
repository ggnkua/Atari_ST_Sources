/* Audio-Video Sequencer           */
/* Copyright 1988 Antic Publishing */
/* by Jim Kent                     */


#include <osbind.h>
#include "flicker.h"


struct dta_buf
	{
	char reserved[21];
	char attributes;
	WORD time;
	WORD date;
	long size;
	char name[14];
	};


long
file_size(name)
char *name;
{
struct dta_buf *dta;

dta = (struct dta_buf *)Fgetdta();
if (Fsfirst(name, 0) != 0)
	{
	couldnt_find(name);
	return(0);
	}
return(dta->size);
}

ld_spl(name,t)
char *name;
struct tlib *t;
{
long size;
char *pt;
int fd;

if ((size = file_size(name))==0)
	return(0);
t->samples = size;
t->default_speed = 3;
t->bytes = size;
if ((pt = lbegmem(size)) == NULL)
	return(0);
if ((fd = Fopen(name, 0)) < 0)
	{
	couldnt_find(name);
	freemem(pt);
	return(0);
	}
if (Fread(fd, size, pt) < size)
	{
	file_truncated(name);
	}
sign8(pt, size);
t->image = pt;
Fclose(fd);
return(1);
}
