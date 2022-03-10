#include <stdio.h>



typedef struct nlist{
   int type;
   int zone;
   int net;
   int node;
   int rnet;
   int rnode;
   int baud;
   int cost;
   int route;
   char bbsname[50];
   char bbsloc[30];
   char bbsnumber[20];
   char password[10];
   int flags;
   char res[4];
}NLIST;

typedef struct dex{
   int type;
   int zone;
   int net;
   long position;
   char realloc[30];
   char location[50];
} DEX;

typedef struct starlist  {
   int type;
   int zone;
   int net;
   int node;
   int rnet;
   int rnode;
   int baud;
   int cost;
   int route;
   char bbsname[50];
   char bbsloc[30];
   char bbsnumber[20];
   char password[10];
   int flags;
   char res1;
   char res2;
   char res3;
   char res4;
}STARLIST;

typedef struct sdex  {
   int type;
   int zone;
   int net;
   long position;
   char realloc[30];
   char location[50];
}SDEX;



main()
{
int d;
   d = sizeof(NLIST);
   
   printf("\n\rnlist = %d",
          d);
   getch();
}