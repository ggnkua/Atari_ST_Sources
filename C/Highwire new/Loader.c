#include <dos.h>
#include <mintbind.h>
#include <string.h>

#include "HighWire.h"

long
search_for_named_location(char *name, struct named_location *current_location)
{
	while(current_location!=0 && strcmp(name,current_location->link->address)!=0)
	{
		current_location=current_location->next_location;
	}
	if(current_location==0)
		return(0);
	else
		return(current_location->position);
}

char *
load_file(char *filename)
{
	long file_handle;
	char *file;
	struct xattr file_info;
	
	if(Fxattr(0,filename,&file_info)==0)
	{
		file_handle=Fopen(filename,0);
		file=(char *)malloc(file_info.size);
		Fread(file_handle,file_info.size,file);
		Fclose(file_handle);
	}
	else
	{
		file=strdup("<html><head><title>Page not found</title></head><body><h1>Page not found</h1></body></html>");
	}
	return(file);
}


char *
translate_address(char *address)
{
	char * temp;
	temp=strchr(address,'#');
	if(temp!=0)
	{	
		*(temp)='\0';
		return(temp+1);
	}
	else
		return(0);
}

