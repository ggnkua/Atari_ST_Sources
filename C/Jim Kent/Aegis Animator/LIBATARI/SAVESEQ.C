
overlay "reader"

#include <osbind.h>
#include <neo.h>
#include "..\\include\\lists.h"
#include "..\\include\\raster.h"
#include "..\\include\\color.h"
#include "..\\include\\format.h"
#include "..\\include\\poly.h"

struct seq_tab
	{
	char name[14];
	long offset;
	long time;
	};
struct seq_tab tab[1024];

wopen(name)
char *name;
{
int f;

if ((f = Fopen(name, 1))< 1)
	f = Fcreate(name, 0);
return(f);
}

save_seq(dest, count, sources)
char *dest;
int count;
char *sources[];
{
int df, sf;
int i;
long time;
long offset;
long length;
char buf[16000];
struct neo_head head;

offset = count * sizeof(struct seq_tab);
if ((df = wopen(dest))<0)
	{
	couldnt_open(dest);
	return(NULL);
	}
for (i=0; i<count; i++)
	{
	if ((sf = Fopen(sources[i], 0))<0)
		{
		couldnt_open(sources[i]);
		return(NULL);
		}
	tab[i].offset = offset;
	tab[i].time = time;
	strcpy(tab[i].name, sources[i]);
	time += 10;
	offset += 128;		
	if (Fread(sf, (long)sizeof(head), &head) != sizeof(head) )
		{
		file_truncated(sources[i]);
		Fclose(sf);
		return(NULL);
		}
	offset += ((head.width+15)/16)*8*head.height;
	Fclose(sf);
	}
Fwrite(df, (long)sizeof(count), &count);
Fwrite(df, (long)count*sizeof(struct seq_tab), &tab);

for (i=0; i<count; i++)
	{
	if ((sf = Fopen(sources[i], 0))<0)
		{
		couldnt_open(sources[i]);
		return(NULL);
		}
	if (Fread(sf, (long)sizeof(head), &head) != sizeof(head) )
		{
		file_truncated(sources[i]);
		Fclose(df);
		Fclose(sf);
		return(NULL);
		}
	if (Fwrite(df, (long)sizeof(head), &head) != sizeof(head) )
		{
		file_truncated(dest);
		Fclose(df);
		Fclose(sf);
		return(NULL);
		}

	length= ((head.width+15)/16)*8*head.height;
	if (Fread(sf, length, buf) != length )
		{
		file_truncated(sources[i]);
		Fclose(df);
		Fclose(sf);
		return(NULL);
		}
	if (Fwrite(df, length, buf) != length )
		{
		file_truncated(dest);
		Fclose(df);
		Fclose(sf);
		return(NULL);
		}
	Fclose(sf);
	}
Fclose(df);
}

couldnt_open(file)
char *file;
{
printf("couldn't open %s\n", file);
}

file_truncated(file)
char *file;
{
printf("%s truncated\n", file);
}


main(argc, argv)
int argc;
char *argv[];
{
save_seq(argv[1], argc-2, argv+2);
}
