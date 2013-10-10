#include <stdio.h>
#include <ext.h>
#include <tos.h>
#include <string.h>
#include <magic.h>
#define  FAIL      -1
#define  NOLL      0


void magic(void);

int main(void)
{
  printf("\33p");
  printf(" -+*        FireSTorm Key fixer        *+- \n");
  printf("     Programmed by Christian Andersson     \n");
  printf("      This Program Fixes the Keys for      \n");
  printf("       Swedish users of Magic V4.00        \n");
  printf("\33q");
  magic();
  return(NOLL);
}

void magic(void)
{
  KeyMap map;

printf("SetConfig\n");
  SetConfigflag(cfWinDials,TRUE);
  SetConfigflag(cfWinAlerts,TRUE);
  SetConfigflag(cfAllSize,TRUE);

printf("InitKeymap\n");
  InitKeymap(map);

printf("map[...]\n");
  map[Sh3]='#';
  map[CharSS]='+';
  map[Quote]='Ç';
  map[ShQuote]='ê';
  map[CharZ]='y';
  map[ShZ]='Y';
  map[CharY]='z';
  map[ShY]='Z';
  map[CharUE]='Ü';
  map[ShUE]='è';
  map[CtrlUE]='[';
  map[ShCtrlUE]='{';
  map[Plus]='Å';
  map[ShPlus]='ö';
  map[CtrlPlus]=']';
  map[ShCtrlPlus]='}';
  map[CtrlOE]='\0';
  map[ShCtrlOE]='\0';
  map[CtrlAE]='`';
  map[ShCtrlAE]='~';
  map[Tilde]='\\';
  map[ShTilde]='|';
  map[CtrlTilde]='^';
  map[ShCtrlTilde]='@';
  map[Number]='\'';
  map[ShNumber]='*';

printf("SetKeymap\n");
  SetKeymap(map);

printf("Finished\n");
}
