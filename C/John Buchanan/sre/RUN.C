#include <stdio.h>

char GulamHome[128] = "e:\\gulam";
char FileName[128];
main (Arg_Count,Arg_Pointer)
int Arg_Count;
char *Arg_Pointer[];

	{
	FILE *fp,*fopen();
	int i = 1;
	if (Arg_Pointer[1][0] == '-')
		{
		strcpy(GulamHome,&(Arg_Pointer[1][1]));
		i =2;
		}
	sprintf(FileName,"%s\\t.g",GulamHome);
	if((fp=fopen(FileName,"w"))==NULL)
		{
		printf("Could not open '%s'\n",FileName);
		exit(1);
		}
	for (;i<Arg_Count;i++)
		fprintf(fp,"%s\n",Arg_Pointer[i]);
	fclose(fp);
	}
