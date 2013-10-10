#include <stdio.h>
#include <osbind.h>

#define FALSE     0
#define TRUE      1
#define NOLL      0
#define FAIL      -1
#define STOOPCFG  "\\AUTO\\STOOP\\STOOP.CFG"
#define DEFCFG  "\\AUTO\\STOOP\\USER\\STOOP.CFG"
#define USERCFG  "\\AUTO\\STOOP\\USER\\STOOP."
#define USERLIST  "\\AUTO\\STOOP\\USER\\USERLIST.DAT"
#define MAX_USER  32
#define U_N_SIZE  21

char  this_user, last_user, num_of_users=0;
char  u_name[MAX_USER][U_N_SIZE];
int   new;

void copy_from(int usernum);
void copy_to(int usernum);
/********************************************************************/
/********************************************************************/
void main(void)
{
  char username[U_N_SIZE];
  int exit=FALSE;
  
  load_list();
  if(last_user!=FAIL)
    copy_to(last_user);

printf("\n\33e*******************************************************");
printf("\n**** Multi user Extension for STOOP  (c)           ****");
printf("\n**** Created by: Christian Andersson               ****");
printf("\n****             Nicklas Larsson                   ****");
printf("\n*******************************************************");
  do
  {
    printf("\nUsername:",num_of_users);
    get_string(username,U_N_SIZE-1);
    this_user=check_user(username);

    if(this_user==num_of_users)
    {
      printf("\nUser not found in user list");
      {
        printf("\ndo you want to add this user?");
        if(toupper(putch(getch()))=='Y')
        {
          if(num_of_users<MAX_USER)
          {
            strcpy(u_name[num_of_users],username);
            num_of_users++;
            exit=TRUE;
            new=TRUE;
          }
          else
            printf("\nSorry to many users in user list!");
        }
      }
    }
    else
      exit=TRUE;
  }while(!exit);

  copy_from(this_user);
  save_list();

  printf("\33f");
}

/********************************************************************/
/********************************************************************/
void get_string(char *string, int max_char)
{
  int  counter=0;
  int  exit=FALSE;
  char tecken;
  
  do
  {
    tecken=getch();
    switch(tecken)
    {
      case '\0': 
        getch(); 
        break;
      case '\n':
      case '\r':
        exit=TRUE;
        break;
      case '\10':
        if(counter>0)
        {
          putch(tecken);
          putch(' ');
          putch(tecken);
          counter--;
        }
        break;
      default:
        if(counter<max_char) 
        {
          tecken=toupper(tecken);
          putch(tecken);
          string[counter]=tecken;
          counter++;
        }
    }
  }  while(!exit);
  string[counter]=NOLL;
}

/********************************************************************/
/********************************************************************/
int check_user(char *username)
{
  int counter=0;
  int exit=FALSE;
  
  do
  {
    if(counter==num_of_users)
      exit=TRUE;
    else if(!strcmp(u_name[counter],username))
      exit=TRUE;
    else
      counter++;
  }
  while(!exit);
  return(counter);

}

/********************************************************************/
/********************************************************************/
void load_list(void)
{
  FILE *fil;
  int temp;

  fil=fopen(USERLIST,"r");
  if(fil!=NULL)
  {
    last_user=fgetc(fil)-'@';
    num_of_users=fgetc(fil)-'@'
    fread(u_name,MAX_USER,U_N_SIZE,fil);
    fclose(fil);
  }
  else
  {
    last_user=FAIL;
    this_user=FAIL;
    num_of_users=NOLL;
    for(temp=NOLL; temp<MAX_USER*U_N_SIZE; temp++)
      u_name[0][temp]=' ';
  }
}

/********************************************************************/
/********************************************************************/
void save_list(void)
{
  FILE *fil;
  
  fil=fopen(USERLIST,"w");
  fputc(this_user+'@',fil);
  fputc(num_of_users+'@',fil);
  fwrite(u_name,MAX_USER,U_N_SIZE,fil);
  fclose(fil);
}

/********************************************************************/
/* Kopierar fr†n user till Stoop                                    */
/********************************************************************/
void copy_from(int usernum)
{
  FILE *source, *dest;
  char sourcename[255];
  int read;
  char data[256];
    
  dest=fopen(STOOPCFG,"w");

  if(!new)  
  {
    sprintf(sourcename,"%s%d",USERCFG,usernum);
    source=fopen(sourcename,"r");
  }
  
  if(new)
  {
    printf("\nNew user! Default setup is being used");
    source=fopen(DEFCFG,"r");
  }  
  else if(source==NULL)
  {
    printf("\nUserconfig does not exist, using default setup");
    source=fopen(DEFCFG,"r");
  }
  else
    printf("\nUsing user setup for %s",u_name[usernum]);
  if(source!=NULL);
  {
    do
    {
      read=fread(data,1,255,source);
      fwrite(data,1,read,dest);
    }while(read==255);
    fclose(source);
  }
  fclose(dest);

}

/********************************************************************/
/* Kopierar till user fr†n Stoop                                    */
/********************************************************************/
void copy_to(int usernum)
{
  FILE *source, *dest;
  char destname[255];
  int  read;
  char data[256];

    
  sprintf(destname,"%s%d",USERCFG,usernum);
  
  source=fopen(STOOPCFG,"r");
  dest=fopen(destname,"w");

  do
  {
    read=fread(data,1,255,source);
    fwrite(data,1,read,dest);
  }while(read==255);
  
  fclose(source);
  fclose(dest);

}