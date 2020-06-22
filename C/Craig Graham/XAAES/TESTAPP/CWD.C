#include <MINTBIND.H>
#include <OSBIND.H>
#include <stdlib.h>

void main(void)
{
	char *path=getenv("PATH");
	char cwd[200];
	short f=0,l,n;

	printf("PATH=%s\n",path);

	sprintf(cwd,"%s",path);

	l=strlen(cwd);
	while(f<l)
	{
		for(n=f; (cwd[n])&&(cwd[n]!=':'); n++);
		
		cwd[n]='\0';
		
		printf("====%s\n",cwd+f);
		f=n+1;
	}
	
}