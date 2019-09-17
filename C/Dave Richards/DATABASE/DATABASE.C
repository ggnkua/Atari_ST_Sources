#include "stdio.h"             /* Declare header files */
#include "conio.h"
#include "ctype.h"
#include "string.h"
#define MAX 99                 /* Sets MAX to equal 99 */ 

struct database                /* Declare array structure to hold addressses */
{
  char name[60];
  char add_one[60];
  char add_two[60];
  char add_three[60];
  char town[60];
  char post[10];
  } address[MAX];
  

void sort_mode(int top);             /* Declare functions */
void name_find(int top);             /* The variable top holds the current top of file value */
void add_find(int top);
void town_find(int top);
void post_find(int top);
int load(void);
void save(int top);
int create(void);
void search(int top);
void display(int top);
void disp(int index);
int add_record(int top);




void main()                     /* Start of main function */
{
    int choice;
    int top;
    
    do
    {
    printf("\nMAIN   MENU");                 /* Main menu selections */
    printf("\n\n");
    printf("\n1---CREATE Database");
    printf("\n");
    printf("\n2---SEARCH Database");
    printf("\n");
    printf("\n3---DISPLAY Database");
    printf("\n");
    printf("\n4---ADD to Database");
    printf("\n");
    printf("\n5---SORT Database");
    printf("\n");
    printf("\n6---LOAD Database");
    printf("\n");
    printf("\n7---SAVE Database");
    printf("\n");
    printf("\n8---QUIT Database");
    printf("\n\n\n\n\n\n\n");
        
 
    scanf("%d",&choice);               /* variable choice stores main menu selection */
    fflush(stdin);                     /* Flush input buffer */     
    
     switch(choice)                    /* Switch selection to call up respective function */
     {                                 /* using the variable choice */
       case 1: top=create();
            break;
       case 2: search(top);
            break;
       case 3: display(top);
            break;
       case 4: top=add_record(top);
            break;
       case 5: sort_mode(top);
            break;     
       case 6: top=load();
            break;
       case 7: save(top);
            break;
       case 8: exit(1);
            break;
       default: printf("\nINVALID DATA");
      }                                    
    }while(choice); 
}                                       /* End of main function*/    



int create(void)                /* Function to create a new database */
{                               /* The value of the variable top which holds */
  char ch,*p;                   /* the number of new records is returned to the main */
  int index;                    /* function to be used by further program functions */
  int top;
                       
  for(index=0; ;index++)
    {     
      printf("\n");
      printf("\nTHIS IS RECORD NUMBER No %d",index);
      printf("\n");
      printf("\nENTER NAME");
      gets(address[index].name);
      p=address[index].name;
      while(*p){
        *p=toupper(*p);
        p++;}
      printf("\nENTER ADDRESS LINE ONE");
      gets(address[index].add_one);
      p=address[index].add_one;
      while(*p){
        *p=toupper(*p);
        p++;}
      printf("\nENTER ADDRESS LINE TWO");
      gets(address[index].add_two);
      p=address[index].add_two;
      while(*p){
        *p=toupper(*p);
        p++;}
      printf("\nENTER ADDRESS LINE THREE");
      gets(address[index].add_three);
      p=address[index].add_three;
      while(*p){
        *p=toupper(*p);
        p++;}
      printf("\nENTER TOWN NAME");
      gets(address[index].town);
      p=address[index].town;
      while(*p){
        *p=toupper(*p);
        p++;}
      printf("\nENTER POSTCODE");
      gets(address[index].post);
      p=address[index].post;
      while(*p){
        *p=toupper(*p);
        p++;}
      printf("\nANOTHER ENTRY Y/N");
      printf("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");
      ch=toupper(getche());
      if(ch=='N'){ top=index;return(top);}
     }
}



void search(int top)              /* Function to search database on any one */
{                                 /* of four fields from the menu presented */
  int choice;                     /* a switch selection calls the relevant funtion */
  do
  {
  printf("\nCHOOSE SEARCH FIELD");
  printf("\n\n");
  printf("\nNAME-------------1");
  printf("\n");
  printf("\nADDRESS ONE------2");
  printf("\n");
  printf("\nTOWN-------------3");
  printf("\n");
  printf("\nPOST CODE--------4");
  printf("\n");
  printf("\nMAIN MENU--------5");
  printf("\n\n\n\n\n\n\n\n\n\n\n\n");
  
  scanf("%d",&choice);                /* The variable choice stores the input selection */
  fflush(stdin);                      /* Flush the input buffer */
  
   switch(choice)                     /* Calling relevant function */
   {
    case 1: name_find(top);
          break;
    case 2: add_find(top);
          break;
    case 3: town_find(top);
          break;
    case 4: post_find(top);
          break;
    case 5: return;
    default: printf("\nINVALID DATA");
   }
  }while(choice);                                 
}  



void name_find(int top)             /* Function to search for name string */
{
  char str[60],*p;
  int index;
  
  printf("\nENTER SEARCH STRING");
  gets(str);
  p=str;
  while(*p){
    *p=toupper(*p);
    p++;}
  for(index=0;index<=top;index++)                    
    {
      if(strcmp(str,address[index].name)==0) disp(index); /* Call disp function if name found */
    }                                    
}
                



void add_find(int top)            /* Function to search for address string */
{
  char str[60],*p;
  int index;
  
  printf("\nENTER SEARCH STRING");
  gets(str);
  p=str;
  while(*p){
    *p=toupper(*p);
    p++;}
  for(index=0;index<=top;index++)
    {
      if(strcmp(str,address[index].add_one)==0) disp(index);  /* Call disp function if address found */
    }
  
}




void town_find(int top)              /* Function to search for town string */
{
  char str[60],*p;
  int index;
  
  printf("\nENTER SEARCH STRING");
  gets(str);
  p=str;
  while(*p){
    *p=toupper(*p);
    p++;}
  for(index=0;index<=top;index++)
    {
      if(strcmp(str,address[index].town)==0) disp(index);  /* Call disp function if town found */
    }
}


void post_find(int top)       /* Function to search for post code string */
{
 char str[60],*p;
 int index;
  
  printf("\nENTER SEARCH STRING");
  gets(str);
  p=str;
  while(*p){
    *p=toupper(*p);
    p++;}
  for(index=0;index<=top;index++)
    {
      if(strcmp(str,address[index].post)==0) disp(index); /* Call disp function if post code found */
    }
}


void sort_mode(int top)      /* Function to sort database into alphabetical order */ 
{
  int index;
  int a,b;
  char str[60];
  
  for(index=0;index<=top;index++)
  {
   for(a=0,b=1;b<=top;a++,b++)
   {
    if(strcmp(address[a].name,address[b].name)>0)
      {
      strcpy(str,address[a].name);
      strcpy(address[a].name,address[b].name);
      strcpy(address[b].name,str);
       
      strcpy(str,address[a].add_one);
      strcpy(address[a].add_one,address[b].add_one);
      strcpy(address[b].add_one,str);
      
      strcpy(str,address[a].add_two);
      strcpy(address[a].add_two,address[b].add_two);
      strcpy(address[b].add_two,str);
         
      strcpy(str,address[a].add_three);
      strcpy(address[a].add_three,address[b].add_three);
      strcpy(address[b].add_three,str);
      
      strcpy(str,address[a].town);
      strcpy(address[a].town,address[b].town);
      strcpy(address[b].town,str);
      
      strcpy(str,address[a].post);
      strcpy(address[a].post,address[b].post);
      strcpy(address[b].post,str);
      }
    }  
  }     
}




void disp(int index)           /* Function to display record resulting from */
{                              /* a call from one of the search functions */
  char ch;
  
  printf("\nTHIS IS RECORD No %d",index);
  printf("\n\n");
  printf("\n%s",address[index].name);
  printf("\n%s",address[index].add_one);
  printf("\n%s",address[index].add_two);
  printf("\n%s",address[index].add_three);
  printf("\n%s",address[index].town);
  printf("\n%s",address[index].post);
  printf("\n\n\n");
  printf("\nANY KEY TO CONTINUE");
  printf("\n\n\n\n\n\n\n\n\n");
  ch=getche();
}    




int add_record(int top)          /* Function to add record to existing database */
{
  char ch,*p;
  int index;
  
  for(index=top+1;index<MAX;index++)
  {
    printf("\nENTER NAME");
    gets(address[index].name);
    p=address[index].name;
      while(*p){
        *p=toupper(*p);
        p++;}
    printf("\nENTER ADDRESS LINE ONE");
    gets(address[index].add_one);
    p=address[index].add_one;
      while(*p){
        *p=toupper(*p);
        p++;}
    printf("\nENTER ADDRESS LINE TWO");
    gets(address[index].add_two);
    p=address[index].add_two;
      while(*p){
        *p=toupper(*p);
        p++;}
    printf("\nENTER ADDRESS LINE THREE");
    gets(address[index].add_three);
    p=address[index].add_three;
      while(*p){
        *p=toupper(*p);
        p++;}
    printf("\nENTER TOWN NAME");
    gets(address[index].town);
    p=address[index].town;
      while(*p){
        *p=toupper(*p);
        p++;}
    printf("\nENTER POST CODE");
    gets(address[index].post);
    p=address[index].post;
      while(*p){
        *p=toupper(*p);
        p++;}
    printf("\n\nANOTHER RECORD Y/N");
    printf("\n\n\n\n\n\n\n\n\n\n");
    ch=toupper(getche());
    if(ch=='N')
    { top=index;return(top);}          /* Returns new value of variable top */
   }
}
    

 

void display(int top)        /* Function to display all records in database */
{
  char ch;
  int index;
   
  for(index=0;index<=top;index++)
  {
    printf("\n%s",address[index].name);
    printf("\n%s",address[index].add_one);
    printf("\n%s",address[index].add_two);
    printf("\n%s",address[index].add_three);
    printf("\n%s",address[index].town);
    printf("\n%s",address[index].post);
    printf("\n\n\n");
    printf("\nSPACE BAR FOR NEXT RECORD");
    printf("\n\nANY OTHER KEY FOR MAIN MENU");
    printf("\n\n\n\n\n\n\n\n\n\n\n\n");
    ch=getche();
    if(ch!=32) break;  
  }
}


int load(void)      /* Function to load existing database from disk */
{   
  FILE *fp;
  int top;
  int index;
  
  if((fp=fopen("database","r"))==NULL)
  {
    printf("File not on disk");
    exit(1);
   }
  fread(&top,sizeof top,1,fp);
  for(index=0;index<=top;index++)
  {
    fread(&address[index],sizeof (struct database),1,fp);
   }
  fclose(fp);
  return(top);        /* Returns top variable which holds number of records loaded */ 
}



void save(int top)     /* Function to save database file */
{
  FILE *fp;
  int index;
  
  if((fp=fopen("database","w"))==NULL)
  {
    printf("cannot open database file\n");
    exit(1);
   }
  fwrite(&top,sizeof top,1,fp);
  for(index=0;index<=top;index++)
  {
    fwrite(&address[index],sizeof (struct database),1,fp);
   }
  fclose(fp);
}


                                  
