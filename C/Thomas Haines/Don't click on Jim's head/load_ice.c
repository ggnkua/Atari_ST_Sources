#include <stdio.h>
#include <sys/stat.h>
#include "thomas.h"

byte *load_ice(char *fname,int *len)
{
  FILE *fp;
  byte far *buf;
  ice_head ice;
	if(!(fp=fopen(fname,"rb"))) return(NULL);
	fread(&ice,1,sizeof(ice),fp);
	fseek(fp,0,SEEK_SET);
	if(ice.ice==*(int *)"Ice!" || ice.ice==*(int *)"ICE!")
	{
    buf=(far byte *)malloc(ice.olen);
	  fread(buf,1,ice.len,fp);
	  deice(buf);
	  *len=ice.olen;
	}
	else
	{
	  struct stat sbuf;
	  stat(fname,&sbuf);
    buf=(far byte *)malloc(sbuf.st_size);
	  fread(buf,1,sbuf.st_size,fp);
    *len=sbuf.st_size;
	}
	fclose(fp);
	return(buf);
}
