/* Basic checks for vmsg.txt language consistencies */
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

typedef struct __CHKMSG_DATA
{
  char  Language[16] ;
  char  Buffer[15*1024] ;
  int   nlines;
  char* lines[512];
  int   ids[512];
}
CHKMSG_DATA, *PCHKMSG_DATA ;

void removecrn(char* buf)
{
  while (*buf)
  {
    if ((*buf == '\r') || (*buf == '\n')) *buf = 0;
    buf++;
  }
}

int LoadMsg(char* filename, CHKMSG_DATA* pMsgData)
{
  FILE* stream = fopen(filename, "rb") ;
  char  name[256];
  char  *p, buf[500];
  size_t boffset ;

  if ( !stream ) return -1 ;

  memset(pMsgData, 0, sizeof(CHKMSG_DATA));
  strcpy(name, filename);
  p = strrchr(name, '\\');
  if (p)
  {
    *p = 0;
    p = strrchr(name, '\\');
    if (p) strcpy(pMsgData->Language, 1 + p);
    else   strcpy(pMsgData->Language, filename);
  }
  pMsgData->nlines = 0 ;
  boffset = 0;
  while (fgets(buf, (int)sizeof(buf), stream))
  {
    removecrn(buf);
    p = strchr(buf,':');
    if (p)
    {
      *p = 0;
      pMsgData->ids[pMsgData->nlines] = atoi(buf);
      strcpy(&pMsgData->Buffer[boffset], 1+p);
      pMsgData->lines[pMsgData->nlines] = &pMsgData->Buffer[boffset];
      boffset += 1 + strlen(1 + p);
      pMsgData->nlines++;
    }
  }
  fclose(stream);

  return 0;
}

int CheckBrackets(char* str)
{
  int no, nc;

  no = nc = 0;
  while (*str)
  {
    if (*str == '[') no++;
    if (*str == ']') nc++;
    str++;
  }

  return ((nc==2) && (no==2)) ? 0:1;
}

void report_err(CHKMSG_DATA* MsgData, char* merr, int id)
{
  printf("%s:%s for ID %d\r\n", MsgData->Language, merr, id);
}

int find_index4id(int id, CHKMSG_DATA* MsgData)
{
  int index = -1;
  int i;

  for (i = 0; (index==-1) && (i < MsgData->nlines); i++)
    if (MsgData->ids[i] == id) index = i;

  return index;
}

int CheckMsg(CHKMSG_DATA* MsgData, int n)
{
  int nerr = 0;
  int i, j, k,l;

  /* Check [][] syntax for GEM dialog boxes */
  for (i = 0; i < n; i++)
  {
    for (j = 0; j < MsgData[i].nlines; j++)
    {
      if (MsgData[i].lines[j][0] == '[')
      {
        if (CheckBrackets(MsgData[i].lines[j])) { report_err(&MsgData[i], "[][] GEM dialog box syntax error", MsgData[i].ids[j]); nerr++; }
      }
    }
  }

  /* Check free messages locations */
  for (i = 0; i < n; i++)
  {
    for (j = 0; j < MsgData[i].nlines; j++)
    {
      if (strlen(MsgData[i].lines[j]) == 0)
      {
        /* This message is empty, let's make sure all other are empty too */
        for (k = 0; k < n; k++)
        {
          if (k != i)
          {
            l = find_index4id(MsgData[i].ids[j], &MsgData[k]);
            if (l < 0) { report_err(&MsgData[k], "id not present", MsgData[i].ids[j]); nerr++; }
            else if (strlen(MsgData[k].lines[l]) != 0)
            { report_err(&MsgData[k], "empty/non empty mismatch", MsgData[i].ids[j]); nerr++; }
          }
        }
      }
    }
  }

  /* Check all IDs are present */
  for (i = 0; i < n; i++)
  {
    for (j = 0; j < MsgData[i].nlines; j++)
    {
      for (k = 0; k < n; k++)
      {
        if (k != i)
        {
          if (find_index4id(MsgData[i].ids[j], &MsgData[k]) < 0)
          { report_err(&MsgData[k], "id not present", MsgData[i].ids[j]); nerr++; }
        }
      }
    }
  }

  return nerr;
}

int main(int argc, char** argv)
{
  static CHKMSG_DATA MsgData[10];
  int n = 0;
  int status = 0 ;
  int nerr ;

  if ( argc == 1 )
  {
    LoadMsg("ENGLISH\\vmsg.txt", &MsgData[n++]);
    LoadMsg("DEUTSCH\\vmsg.txt", &MsgData[n++]);
    LoadMsg("FRANCAIS\\vmsg.txt", &MsgData[n++]);
    LoadMsg("ITALIAN\\vmsg.txt", &MsgData[n++]);
    LoadMsg("SVENSKA\\vmsg.txt", &MsgData[n++]);
  }
  else
  {
    int narg = 1 ;
    char buf[256] ;

    while ( narg < argc )
    {
      sprintf( buf, "%s\\vmsg.txt", argv[narg] ) ;
      if ( LoadMsg( buf, &MsgData[n] ) == 0 ) n++ ;
      else printf("WARNING:Can't load %s\n", buf);
      narg++ ;
    }
  }
 
  nerr = CheckMsg(MsgData, n) ;
  if ( nerr == 0 ) printf("All %d languages look OK.\n", n) ;
  else             printf("%d errors have been reported, please check\n") ;

  return status;
}
