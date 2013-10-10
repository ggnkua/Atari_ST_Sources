#include <stdio.h>
#include <ext.h>
#include <tos.h>
#include <string.h>
#include <magic.h>
#define  FAIL      -1
#define  NOLL      0
#define  TEST      1
#define  SVENSKA   6

char countrynames[][8]={"0","1","2","3","4","5","svenska"};

KEYTAB *key_table;

int save_keytable(int country);
int load_keytable(int country);
void test(void);
void magic(void);

int main(void)
{
  printf("\33p");
  printf(" -+*        FireSTorm Key fixer        *+- \n");
  printf("     Programmed by Christian Andersson     \n");
  printf("\33q");
/*
  key_table=Keytbl("","","");
  Bioskeys();
*/
  magic();
  return(NOLL);
}

int save_keytable(int country)
{
  FILE *save_file;
/*  int counter; */
  char filename[12];
  strcpy(filename,countrynames[country]);
  strcat(filename,".key");
  
  save_file=fopen(filename,"wb");
  if(save_file==NULL)
  {
    printf("Could not open file: %s",filename);
    getch();
    return(FALSE);
  }
  if(fwrite(key_table->unshift,1,128,save_file)!=128)
  {
    printf("Could not write to file: %s",filename);
    fclose(save_file);
    getch();
    return(FALSE);
  }
  if(fwrite(key_table->shift,1,128,save_file)!=128)
  {
    printf("Could not write to file: %s",filename);
    fclose(save_file);
    getch();
    return(FALSE);
  }
  if(fwrite(key_table->capslock,1,128,save_file)!=128)
  {
    printf("Could not write to file: %s",filename);
    fclose(save_file);
    getch();
    return(FALSE);
  }
  if(fwrite(key_table->spec1,1,9,save_file)!=9)
  {
    printf("Could not write to file: %s",filename);
    fclose(save_file);
    getch();
    return(FALSE);
  }
 if(fwrite(key_table->spec2,1,9,save_file)!=9)
  {
    printf("Could not write to file: %s",filename);
    fclose(save_file);
    getch();
    return(FALSE);
  }
  fclose(save_file);
  return(TRUE);

}

int load_keytable(int country)
{
  FILE *load_file;
  char unshift[128],shift[128],capslock[128] /*,spec1[9],spec2[9]*/ ;  
  char filename[12];
  strcpy(filename,countrynames[country]);
  strcat(filename,".key");

  load_file=fopen(filename,"rb");
  if(load_file==NULL)
  {
    printf("Could not open file: %s",filename);
    getch();
    return(FALSE);
  }
  if(fread(unshift,1,128,load_file)!=128)
  {
    printf("Could not read from file(1): %s",filename);
    fclose(load_file);
    getch();
    return(FALSE);
  }
  if(fread(shift,1,128,load_file)!=128)
  {
    printf("Could not read from file(2): %s",filename);
    fclose(load_file);
    getch();
    return(FALSE);
  }
  if(fread(capslock,1,128,load_file)!=128)
  {
    printf("Could not read from file(3): %s",filename);
    fclose(load_file);
    getch();
    return(FALSE);
  }
/*
  if(fread(spec1,1,9,load_file)!=9)
  {
    printf("Could not read from file(3): %s",filename);
    fclose(load_file);
    getch();
    return(FALSE);
  }
    if(fread(spec2,1,9,load_file)!=9)
  {
    printf("Could not read from file(3): %s",filename);
    fclose(load_file);
    getch();
    return(FALSE);
  }

*/
  memcpy(key_table->unshift,unshift,128);
  memcpy(key_table->shift,shift,128);
  memcpy(key_table->capslock,capslock,128);
/*
  memcpy(key_table->spec1,spec1,9);
  memcpy(key_table->spec2,spec2,9);
*/
  fclose(load_file);
  return(TRUE);
}

void test(void)
{
  int counter ;
  
  printf("unshift   : %ld\n",key_table->unshift);
  printf("shift     : %ld\n",key_table->shift);
  printf("capslock  : %ld\n",key_table->capslock);
  printf("alt       : %ld\n",key_table->spec1);
  printf("shift/alt : %ld\n",key_table->spec2);
  for(counter=NOLL;counter<128;counter++)
  {
     printf("(%ld)(%d)(%d)(%c)\n",key_table->spec1+counter,counter,key_table->spec1[counter],key_table->spec1[counter]);
     getch();
  }
  key_table->spec1[8]='{';
}

void magic(void)
{
  KeyMap k;
    
  k[Sh3]='#';
  k[CharSS]='+';
  k[Quote]='Ç';
  k[ShQuote]='ê';
  k[CharZ]='y';
  k[ShZ]='Y';
  k[CharY]='z';
  k[ShY]='Z';
  k[CharUE]='Ü';
  k[ShUE]='è';
  k[CtrlUE]='[';
  k[ShCtrlUE]='{';
  k[Plus]='Å';
  k[ShPlus]='ö';
  k[CtrlPlus]=']';
  k[ShCtrlPlus]='}';
  k[CtrlOE]='\0';
  k[ShCtrlOE]='\0';
  k[CtrlAE]='`';
  k[ShCtrlAE]='~';
  k[Tilde]='\\';
  k[ShTilde]='|';
  k[CtrlTilde]='^';
  k[ShCtrlTilde]='@';
  k[Number]='\'';
  k[ShNumber]='*';
}
