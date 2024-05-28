#include "c:\work\headers\portab.h"
#include "c:\work\headers\osbind.h"
#include "c:\work\headers\string.h"

int kill_count;

void kill_it(path,dta)
char *path,*dta;
{
char file[128];
kill_count++;
strcpy(file,path);
/* check if path is root! */
if(strlen(file)>3)
        strcat(file,"\\");
strcat(file,dta+30);
printf("%s \n",file);
if(Fdelete(file)<0)
        {
        printf("Error deleting file: %s\nProcess will terminate on keypress...\n",file);
        getch();
        exit(-1);
        }
}

void main(argc,argv)
WORD argc;
char *argv[];
{
char path[128];
char *pointer;
kill_count=0;
if(argc==1)
        {
        path[0]=Dgetdrv()+'A';
        strcpy(&path[1],":\\*.bak");
        }
else if(argc==2)
        {
        if(strlen(argv[1])<=2)
                {
                path[0]=*(argv[1]);
                strcpy(&path[1],":\\*.bak");
                }
        else if(strlen(argv[1])>2)
                {
                strcpy(path,argv[1]);
                pointer=strrchr(path,'\\');
                if(pointer<(path+strlen(path)-1))
                        strcat(path,"\\*.bak");
                else
                        strcat(path,"*.bak");
                }
        }
else    
        return;
filefind(path,kill_it);
printf("%u .bak files deleted\n",kill_count);
}

