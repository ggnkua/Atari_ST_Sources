/******    *****   ******
 **   **  **   **  **   **      unRAR utility version 1.00e
 ******   *******  ******       ~~~~~~~~~~~~~~~~~~~~~~~~~~~
 **   **  **   **  **   **         FREE portable version
 **   **  **   **  **   **         ~~~~~~~~~~~~~~~~~~~~~

         Main code

   YOU CAN CHANGE FOLLOWING CODE IN ORDER TO ACHIEVE
   COMPATIBILITY WITH YOUR OPERATING MEDIA.

   PLEASE SEND ALL NOTES, PATCHES TO ANY RAR SITE (SEE RAR_SITE.TXT IN RAR)
   OR DIRECTLY TO THE AUTHOR CONTACT SITE: andrey@vybor.chel.su
                                  FIDOnet: Andrey Spasibozhko, 2:5010/23
   VOICE REPORTS: +7-3512-130-231

*/

#include "unrar.h"          /* definitions */
#include "unpack.c"         /* unpacking procedures */

void   SplitCommandLine();  /* parses command string */
int    CmpName();           /* checks name for mask */
char*  PointToName();       /* returns pathname */
void   NextVolumeName();    /* gets next volume name */
void   SplitName();         /* splits pathname */
void   ExecuteCommand();    /* executes extr. command */
void   ListArchive();       /* lists archive contents */
int    ExtrFile();          /* extracts single file */
void   Help();              /* prints usage help */
void   ShutDown();          /* stops working */
void   ErrExit();           /* exits with error code */
void   CreatePath();        /* creates path */
int    tread();             /* reads with checking */
void   tclose();            /* closes with checking */
void   MergeArc();          /* to next volume */
void   UnstoreFile();       /* unpacks non-compressed file */
int    IsArchive();         /* checks for RAR archive signature */
void   CheckArc();          /* similar but with exit */
int    strnicomp();         /* compares strings */
char*  strtolwr();          /* convert string to lowercase
int    ToPercent();         /* calculates percentage */
int    ReadBlock();         /* reads archive block */
int    IsProcessFile();     /* should file be processed */
int    UnpRead();           /* reading while unpacking */
int    UnpWrite();          /* writing while unpacking */
void   InitCRC();           /* initializes CRC table */
UDWORD CRC();               /* calculates CRC */
#ifdef TOS
void   wait_key();
#endif

struct MarkHeader MarkHead;
struct ArchiveHeader Mhd;
struct FileHeader Lhd;

UDWORD CRC32_Table[256],UnpFileCRC;
HPBYTE TmpMemory;

int ArgCount=0;
char ArgNames[16][80],MainCommand;
char CurExtrFile[80]={0},ArcName[80],ArcFileName[80],ExtrPath[80];
int SolidType,UnpVolume,TestMode,ExitCode=0;
#ifndef TOS
  FILE *ArcFPtr=NULL,*FileFPtr=NULL,*RdUnpFPtr,*WrUnpFPtr;
#else
  int ArcHandler, FileHandler, RdUnpHandler, WrUnpHandler;
#endif
long NextBlockPos,UnpPackedSize;


main(Argc,Argv)
int Argc;
char *Argv[];
{
  printf("\n UNRAR 1.00e freeware portable version      (C) 1994 Eugene Roshal\n");
#ifdef TOS
  Cconws("\n\r");
  Cconws(" -----------------------------------------------------------------\n\r");
  Cconws(" Adapted for Atari¿ computers by:        Luis Manuel Asensio Royo.\n\r");
  Cconws(" February 1995, Barcelona (Spain).     >>>>> Motorola inside <<<<<\n\r");
  Cconws(" -----------------------------------------------------------------\n\r");
#endif
  if ((TmpMemory=(HPBYTE)MEMALLOC(UNP_MEMORY))==NULL)
    ErrExit(EMEMORY,MEMORY_ERROR);
  MakeTbl();
  SplitCommandLine(Argc,Argv);
  ExecuteCommand();
  ShutDown(SD_MEMORY);
  exit(ExitCode);
}


int CmpName(Mask,Name)
char *Mask;
char *Name;
{
  while (1)
  {
    if (*Mask=='*')
    {
      while (*Mask!='.' && *Mask!=0)
        Mask++;
      while (*Name!='.' && *Name!=0)
        Name++;
    }
    if (*Mask==0)
      return(*Name==0);
    if (*Name==0 && *Mask=='.')
    {
      Mask++;
      continue;
    }
    if (toupper(*Mask)==toupper(*Name) || *Mask=='?' && *Name!=0)
    {
      Mask++;
      Name++;
    }
    else
      return(0);
  }
}


void ErrExit(ErrCode,Code)
int ErrCode;
int Code;
{
  char ErrMsg[80];
  switch(ErrCode)
  {
    case EEMPTY:
      strcpy(ErrMsg,"");
      break;
    case EWRITE:
      strcpy(ErrMsg,"Write error. Disk full ?");
      break;
    case EREAD:
      strcpy(ErrMsg,"Read error");
      break;
    case EOPEN:
      strcpy(ErrMsg,"File open error");
      break;
    case ECLOSE:
      strcpy(ErrMsg,"File close error");
      break;
    case EMEMORY:
      strcpy(ErrMsg,"Not enough memory");
      break;
    case EARCH:
      strcpy(ErrMsg,"Broken archive");
      break;
  }
  if (ErrCode!=EEMPTY)
    printf("\n Program aborted\n %s",ErrMsg);
  ShutDown(SD_FILES | SD_MEMORY);
  exit(Code);
}


void CreatePath(fpath)
char *fpath;
{
  char *ChPtr;
  ChPtr=fpath;
  while(*ChPtr!=0 && (ChPtr=strchr(ChPtr,PATHDIV))!=NULL)
  {
    *ChPtr=0;
    if (MAKEDIR(fpath)==0)
      printf("\n Creating    %-55s",fpath);
    *ChPtr=PATHDIV;
    ChPtr++;
  }
}


void NextVolumeName()
{
  char *ChPtr;
  ChPtr=strrchr(ArcName,'.');
  if (!isdigit(*(ChPtr+2)) || !isdigit(*(ChPtr+3)))
    strcpy(ChPtr+2,"00");
  else
  {
    ChPtr+=3;
    while ((++(*ChPtr))=='9'+1)
    {
      if (*(ChPtr-1)=='.')
      {
        *ChPtr='A';
        break;
      }
      else
      {
        *ChPtr='0';
        ChPtr--;
      }
    }
  }
}


void MergeArc(ShowFileName)
int ShowFileName;
{
  int Ch;
#ifndef TOS
  tclose(ArcFPtr);
#else
  tclose(ArcHandler);
#endif
  NextVolumeName();
#ifndef TOS
  while ((ArcFPtr=fopen(ArcName,"r"))==NULL)
#else
  while ((ArcHandler=Fopen(ArcName, FO_READ))<6)
#endif
  {
    printf("\n Disk with %s required. Continue ? ",ArcName);
    Ch=getchar();
    if (toupper(Ch)=='N')
      ErrExit(EEMPTY,USER_BREAK);
  }
  if (MainCommand=='T')
    printf("\n\n Testing archive %s",ArcName);
  else
    if (MainCommand!='P')
      printf("\n\n Extracting from %s",ArcName);
  CheckArc();
  ReadBlock(FILE_HEAD);
  if (ShowFileName)
    printf("\n     ...     %-55s",ArcFileName);
  UnpVolume=(Lhd.Flags & LHD_SPLIT_AFTER);
#ifndef TOS
  fseek(ArcFPtr,NextBlockPos-Lhd.PackSize,SEEK_SET);
#else
  Fseek(NextBlockPos-Lhd.PackSize, ArcHandler, FSEEK_SET);
#endif
  UnpPackedSize=Lhd.PackSize;
#ifndef TOS
  RdUnpFPtr=ArcFPtr;
#else
  RdUnpHandler=ArcHandler;
#endif
}


void UnstoreFile()
{
  int Code;
  while ( 1 )
  {
    if ((Code=UnpRead((UBYTE *)TmpMemory,0x7f00))==-1)
      ErrExit(EWRITE,WRITE_ERROR);
    if (Code==0)
      break;
    if (UnpWrite((UBYTE *)TmpMemory,(UWORD)Code)==-1)
      ErrExit(EWRITE,WRITE_ERROR);
  }
}


int IsArchive()
{
  UBYTE Mark[7],Header[13];
  SolidType=0;
#ifndef TOS
  if (tread(ArcFPtr,Mark,7)!=7)
#else
  if (tread(ArcHandler, Mark, 7)!=7)
#endif
    return(0);
  if (Mark[0]!=0x52 || Mark[1]!=0x61 || Mark[2]!=0x72 || Mark[3]!=0x21 ||
      Mark[4]!=0x1a || Mark[5]!=0x07 || Mark[6]!=0x00)
    return(0);
#ifndef TOS
  if (tread(ArcFPtr, Header,13) != 13)
#else
  if (tread(ArcHandler, Header, 13)!=13)
#endif
    return(0);
  Mhd.HeadCRC  = Header[0]+(UWORD)Header[1]*0x100;
  Mhd.HeadType = Header[2];
  Mhd.Flags    = Header[3]+(UWORD)Header[4]*0x100;
  Mhd.HeadSize = Header[5]+(UWORD)Header[6]*0x100;
  if (!(Mhd.HeadCRC==(UWORD)~CRC(0xFFFFFFFFL,&Header[2],11)))
    printf("\n Archive header broken");
  SolidType=(Mhd.Flags & MHD_SOLID);
#ifndef TOS
  fseek(ArcFPtr, Mhd.HeadSize-13, SEEK_CUR);
#else
  Fseek(Mhd.HeadSize-13, ArcHandler, FSEEK_CUR);
#endif
  return(1);
}


void CheckArc()
{
  if (!IsArchive())
  {
    printf("\nBad archive %s",ArcName);
    ErrExit(EEMPTY,FATAL_ERROR);
  }
}


#ifndef TOS
int tread(FPtr,buf,len)
FILE *FPtr;
void *buf;
unsigned len;
#else
int tread(int Handler, void *buf, unsigned len)
#endif
{
  int Code;
#ifndef TOS
  Code=fread(buf, 1, len, FPtr);
#else
  Code=Fread(Handler, len, buf);
#endif
  if (Code==-1)
    ErrExit(EREAD,FATAL_ERROR);
  return(Code);
}


#ifndef TOS
void tclose(FPtr)
FILE *FPtr;
#else
void tclose(int Handler)
#endif
{
#ifndef TOS
  if (fclose(FPtr)==EOF)
#else
  if (Fclose(Handler)!=0)
#endif
    ErrExit(ECLOSE,FATAL_ERROR);
}


char* PointToName(Path)
char *Path;
{
  char *ChPtr;
  if ((ChPtr=strrchr(Path,PATHDIV))!=NULL)
    return(ChPtr+1);
  else
    if ((ChPtr=strrchr(Path,':'))!=NULL)
      return(ChPtr+1);
    else
      return(Path);
}


int strnicomp(Str1,Str2,MaxLen)
char *Str1;
char *Str2;
int MaxLen;
{
  if (MaxLen==0)
    return(0);
  while (MaxLen-- > 0)
  {
    if (toupper(*Str1)!=toupper(*Str2))
      return(1);
    if (*Str1==0)
      return(0);
    Str1++;
    Str2++;
  }
  return(0);
}


char* strtolwr(Str)
char *Str;
{
  char *ChPtr;
  for (ChPtr=Str;*ChPtr!=0;ChPtr++)
    *ChPtr=tolower(*ChPtr);
  return(Str);
}


void SplitName(Path,Dir,Name)
char *Path;
char *Dir;
char *Name;
{
  char *ChPtr,*ChPtr1;
  if ((ChPtr=strrchr(Path,':'))!=NULL)
    ChPtr++;
  else
    ChPtr=Path;
  if ((ChPtr1=strrchr(ChPtr,PATHDIV))!=NULL)
  {
    *ChPtr1=0;
    strcpy(Dir,ChPtr);
    *ChPtr1=PATHDIV;
    ChPtr=ChPtr1+1;
  }
  else
    *Dir=0;
  strcpy(Name,ChPtr);
}


int ToPercent(N1,N2)
long N1;
long N2;
{
  if (N1 > 10000)
  {
    N1/=100;
    N2/=100;
  }
  if (N2==0)
    return(0);
  if (N2<N1)
    return(100);
  return((int)(N1*100/N2));
}


void SplitCommandLine(Argc,Argv)
int Argc;
char *Argv[];
{
  int I,Len;

  ArgCount = MainCommand = *ArcName = *ExtrPath = 0;

  if (Argc==2)
  {
    MainCommand='X';
    strcpy(ArcName,Argv[1]);
  }
  else
    for (I=1;I<Argc;I++)
    {
      if (MainCommand==0)
        MainCommand=toupper(Argv[I][0]);
      else
      {
        if (*ArcName==0)
          strncpy(ArcName,Argv[I],80);
        else
        {
          Len=strlen(Argv[I]);
          if (Len>0 && (Argv[I][Len-1]==':' || (Argv[I][Len-1]=='\\' || Argv[I][Len-1]=='/')))
          {
            strcpy(ExtrPath,Argv[I]);
            ExtrPath[Len-1]=PATHDIV;
          }
          else
            strncpy(ArgNames[(ArgCount++) & 0x0f],Argv[I],80);
        }
      }
    }

  if (ArgCount==0 && *ArcName!=0)
    strcpy(ArgNames[(ArgCount++) & 0x0f],"*.*");
  if (strrchr(PointToName(ArcName),'.')==NULL)
    strcat(ArcName,isupper(*ArcName) ? ".RAR":".rar");
  ArgCount &= 0xF;
}


void ExecuteCommand()
{
  switch(MainCommand)
  {
    case 'E':
    case 'X':
    case 'T':
      ExtrFile();
      break;
    case 'V':
    case 'L':
      ListArchive();
      break;
    case 0:
      Help();
      exit(0);
    default:
      Help();
      exit(USER_ERROR);
  }
}

void ShutDown(Mode)
int Mode;
{
  if (Mode & SD_FILES)
  {
#ifndef TOS
    if (ArcFPtr!=NULL)
      fclose(ArcFPtr);
    if (FileFPtr!=NULL)
      fclose(FileFPtr);
#else
    if (ArcHandler>5) Fclose(ArcHandler);
    if (FileHandler>5) Fclose(FileHandler);
#endif
  }
  if (Mode & SD_MEMORY)
  {
    if (TmpMemory!=NULL)
      MEMFREE(TmpMemory);
    printf("\n");
  }
}


void Help()
{
  printf("\n Usage:     UNRAR <command> <archive> <files...>\n");
  printf("\n <Commands>\n");
  printf("\n x       Extract files with full path");
  printf("\n e       Extract files to current directory");
  printf("\n t       Test archive files");
  printf("\n v       Verbosely list contents of archive");
  printf("\n l       List contents of archive");
  printf("\n");
#ifdef TOS
  wait_key();
#endif
}


int ExtrFile()
{
  char DestFileName[80];
  long FileCount=0,TotalFileCount=0,DirCount=0,ErrCount=0;
  int ExtrFile=0,Size,SkipSolid=0,UnpSolid;

#ifndef TOS
  if ((ArcFPtr=fopen(ArcName,"r"))==NULL)
#else
  if ((ArcHandler=Fopen(ArcName, FO_READ))<6)
#endif
    ErrExit(EOPEN,FATAL_ERROR);

  CheckArc();
  CreateEncTbl(TmpMemory);
  UnpVolume=UnpSolid=0;
  if (MainCommand=='T')
    printf("\n Testing archive %s\n",ArcName);
  else
    printf("\n Extracting from %s\n",ArcName);

  while (1)
  {
    Size=ReadBlock(FILE_HEAD);

    if (Size<=0 && UnpVolume==0)
      break;
    if ((Lhd.Flags & LHD_SPLIT_BEFORE) && SolidType)
    {
      printf("\nSolid archive: first volume required");
      ErrExit(EEMPTY,FATAL_ERROR);
    }
    if (UnpVolume && Size==0)
      MergeArc(0);
    UnpVolume=(Lhd.Flags & LHD_SPLIT_AFTER);
#ifndef TOS
    fseek(ArcFPtr,NextBlockPos-Lhd.PackSize,SEEK_SET);
#else
    Fseek(NextBlockPos-Lhd.PackSize, ArcHandler, FSEEK_SET);
#endif

    TestMode=0;
    ExtrFile=0;
    SkipSolid=0;

    if (IsProcessFile(COMPARE_PATH) && (Lhd.Flags & LHD_SPLIT_BEFORE)==0
        || (SkipSolid=SolidType)!=0)
    {

      strcpy(DestFileName,ExtrPath);
      strcat(DestFileName,(MainCommand!='E') ? ArcFileName : PointToName(ArcFileName));

      ExtrFile=!SkipSolid;

      if (Lhd.UnpVer<15 || Lhd.UnpVer>UNP_VER)
      {
        printf("\n %s: unknown method",ArcFileName);
        ExtrFile=0;
        ErrCount++;
        ExitCode=WARNING;
      }

      if (Lhd.Flags & LHD_PASSWORD)
      {
        printf("\n %s: cannot process encrypted file",ArcFileName);
        if (SolidType)
          ErrExit(EEMPTY,FATAL_ERROR);
        ExtrFile=0;
        ErrCount++;
        ExitCode=WARNING;
      }

      if (Lhd.HostOS==MS_DOS && (Lhd.FileAttr & DOSFA_DIREC))
      {
        if (MainCommand=='E')
          continue;
        if (SkipSolid)
        {
          printf("\n Skipping    %-55s Ok",ArcFileName);
          continue;
        }
        if (MainCommand=='T')
        {
          printf("\n Testing     %-55s Ok",ArcFileName);
          continue;
        }
        CreatePath(DestFileName);
        if (MAKEDIR(DestFileName)==0)
          printf("\n Creating    %-55s",ArcFileName);
        continue;
      }
      else
      {
        if (MainCommand=='T' && ExtrFile)
          TestMode=1;
        if ((MainCommand=='E' || MainCommand=='X') && ExtrFile)
        {
          CreatePath(DestFileName);
#ifndef TOS
	  if ((FileFPtr=fopen(DestFileName,"w"))==NULL)
#else
      if ((FileHandler=Fcreate(DestFileName, 0))<5)
#endif
          {
            printf("\n Cannot create %s",DestFileName);
            ExitCode=WARNING;
            ExtrFile=0;
          }
        }
      }

      if (!ExtrFile && SolidType)
        SkipSolid=TestMode=ExtrFile=1;
      if (ExtrFile)
      {
        TotalFileCount++;
        if (SkipSolid)
          printf("\n Skipping    %-55s",ArcFileName);
        else
        {
          FileCount++;
          switch(MainCommand)
          {
            case 'T':
              printf("\n Testing     %-55s",ArcFileName);
              break;
            case 'X':
            case 'E':
              printf("\n Extracting  %-55s",DestFileName);
              break;
          }
        }
        strcpy(CurExtrFile,DestFileName);
        UnpFileCRC=0xFFFFFFFFL;
        UnpPackedSize=Lhd.PackSize;
        DestUnpSize=Lhd.UnpSize;
#ifndef TOS
        RdUnpFPtr=ArcFPtr;
        WrUnpFPtr=FileFPtr;
#else
        RdUnpHandler=ArcHandler;
        WrUnpHandler=FileHandler;
#endif
        if (Lhd.Method==0x30)
          UnstoreFile();
        else
          if (unpack(TmpMemory,UnpRead,UnpWrite,UnpSolid)==-1)
            ErrExit(EWRITE,WRITE_ERROR);
        if (TotalFileCount>0 && SolidType)
          UnpSolid=1;
        if (UnpFileCRC==~Lhd.FileCRC)
        {
          if (MainCommand!='P')
            printf(" Ok");
        }
        else
        {
#ifndef TOS
	  fseek(ArcFPtr,NextBlockPos,SEEK_SET);
#else
      Fseek(NextBlockPos, ArcHandler, FSEEK_SET);
#endif
          printf("\n %-15s : CRC failed",ArcFileName);
          ExitCode=CRC_ERROR;
          ErrCount++;
        }
        if (!TestMode)
        {
          SETFILETIME(FileFPtr,(void *)&Lhd.FileTime);
#ifndef TOS
	      tclose(FileFPtr);
#else
          tclose(FileHandler);
#endif
        }
        TestMode=0;
        *CurExtrFile=0;
      }
    }
    if (!ExtrFile && !SolidType)
#ifndef TOS
      fseek(ArcFPtr,NextBlockPos,SEEK_SET);
#else
      Fseek(NextBlockPos, ArcHandler, FSEEK_SET);
#endif
  }
#ifndef TOS
  tclose(ArcFPtr);
#else
  tclose(ArcHandler);
#endif
  if ((FileCount+DirCount)==0)
  {
    printf("\n No files");
    ExitCode=WARNING;
  }
  else
    if (ErrCount==0)
      printf("\n  All OK");
    else
      printf("\n  Total errors: %ld",ErrCount);
  return(0);
}


void ListArchive()
{
  unsigned long TotalPackSize,TotalUnpSize,FileCount;
  int I;
  TotalPackSize=TotalUnpSize=FileCount=0;
#ifndef TOS
  if ((ArcFPtr=fopen(ArcName,"r"))==NULL)
#else
  if ((ArcHandler=Fopen(ArcName, FO_READ))<6)
#endif
    ErrExit(EOPEN,FATAL_ERROR);
  CheckArc();
  printf("\n ");
  if (SolidType)
    printf("Solid ");
  if (Mhd.Flags & MHD_MULT_VOL)
    printf("%colume ",(SolidType) ? 'v':'V');
  else
    printf("%crchive ",(SolidType) ? 'a':'A');
  printf("%s\n",ArcName);
  if (MainCommand=='V')
    printf("\n Pathname/Comment\n%12.12s","");
  else
    printf("\n Name       ");
  printf("      Size   Packed  Ratio   Date   Time  Attr   CRC-32  Meth Ver\n");
  for (I=0;I<77;I++)
    printf("-");
  while(ReadBlock(FILE_HEAD) > 0)
  {
    if (IsProcessFile(NOT_COMPARE_PATH))
    {
      printf("\n%c",(Lhd.Flags & LHD_PASSWORD) ? '*' : ' ');
      if (MainCommand=='V')
      {
        printf("%-s",ArcFileName);
        printf("\n%12s ","");
      }
      else
        printf("%-12s",PointToName(ArcFileName));

      printf(" %8ld %8ld ",Lhd.UnpSize,Lhd.PackSize);
      if (Lhd.Flags & (LHD_SPLIT_AFTER | LHD_SPLIT_BEFORE))
        printf(" Split");
      else
        printf(" %3d%% ",ToPercent(Lhd.PackSize,Lhd.UnpSize));

      printf(" %02d-%02d-%02d %02d:%02d ",Lhd.FileTime.ft_day,
             Lhd.FileTime.ft_month,(Lhd.FileTime.ft_year+1980)%100,
             Lhd.FileTime.ft_hour,Lhd.FileTime.ft_min);

      if (Lhd.HostOS==MS_DOS)
        printf("%c%c%c%c%c",
          (Lhd.FileAttr & DOSFA_DIREC ) ? 'D' : '.',
          (Lhd.FileAttr & DOSFA_RDONLY) ? 'R' : '.',
          (Lhd.FileAttr & DOSFA_HIDDEN) ? 'H' : '.',
          (Lhd.FileAttr & DOSFA_SYSTEM) ? 'S' : '.',
          (Lhd.FileAttr & DOSFA_ARCH  ) ? 'A' : '.');
      else
        printf("     ");
      printf(" %8.8lX  m%d  %d.%d",Lhd.FileCRC,Lhd.Method-0x30,Lhd.UnpVer/10,Lhd.UnpVer%10);
      if (!(Lhd.Flags & LHD_SPLIT_BEFORE))
      {
        TotalUnpSize+=Lhd.UnpSize;
        FileCount++;
      }
      TotalPackSize+=Lhd.PackSize;
    }
#ifndef TOS
    fseek(ArcFPtr,NextBlockPos,SEEK_SET);
#else
	Fseek(NextBlockPos, ArcHandler, FSEEK_SET);
#endif
  }
  printf("\n");
  for (I=0;I<77;I++)
    printf("-");
  printf("\n%5ld %16ld %8ld %4d%%\n",FileCount,TotalUnpSize,TotalPackSize,ToPercent(TotalPackSize,TotalUnpSize));
#ifndef TOS
  tclose(ArcFPtr);
#else
  Fclose(ArcHandler);
#endif
}


int IsProcessFile(ComparePath)
int ComparePath;
{
  int NumName,WildCards;
  char ArgName[80],dir1[80],name1[15],dir2[80],name2[15];
  for (NumName=0;NumName<ArgCount;NumName++)
  {
    memcpy((void *)ArgName,(void *)ArgNames[NumName],sizeof(ArgName));
    WildCards=(strchr(ArgName,'?')!=NULL || strchr(ArgName,'*')!=NULL);
    SplitName(ArgName,dir1,name1);
    SplitName(ArcFileName,dir2,name2);
    if (CmpName(name1,name2) && ((ComparePath==NOT_COMPARE_PATH && *dir1==0) ||
          WildCards && strnicomp(dir1,dir2,strlen(dir1))==0 ||
          strnicomp(dir1,dir2,1000)==0))
      return(1);
  }
  return(0);
}

int ReadBlock(BlockType)
int BlockType;
{
  UDWORD HeadCRC;
  UBYTE Header[32];
  int Size,I;
  memset(&Lhd,0,sizeof(Lhd));
  memset(Header,0,sizeof(Header));
  while (1)
  {
#ifndef TOS
    Size=tread(ArcFPtr,Header,32);
#else
    Size=tread(ArcHandler, Header, 32);
#endif
    Lhd.HeadCRC  = Header[0] +(UWORD)Header[1]*0x100;
    Lhd.HeadType = Header[2];
    Lhd.Flags    = Header[3] +(UWORD)Header[4]*0x100;
    Lhd.HeadSize = Header[5] +(UWORD)Header[6]*0x100;;
    Lhd.PackSize = Header[7] +(UWORD)Header[8]*0x100+(UDWORD)Header[9]*0x10000L+(UDWORD)Header[10]*0x1000000L;
    Lhd.UnpSize  = Header[11]+(UWORD)Header[12]*0x100+(UDWORD)Header[13]*0x10000L+(UDWORD)Header[14]*0x1000000L;
    Lhd.HostOS   = Header[15];
    Lhd.FileCRC  = Header[16]+(UWORD)Header[17]*0x100+(UDWORD)Header[18]*0x10000L+(UDWORD)Header[19]*0x1000000L;
    *(UDWORD *)&Lhd.FileTime=Header[20]+(UWORD)Header[21]*0x100+(UDWORD)Header[22]*0x10000L+(UDWORD)Header[23]*0x1000000L;
    Lhd.UnpVer   = Header[24];
    Lhd.Method   = Header[25];
    Lhd.NameSize = Header[26]+(UWORD)Header[27]*0x100;
    Lhd.FileAttr = Header[28]+(UWORD)Header[29]*0x100+(UDWORD)Header[30]*0x10000L+(UDWORD)Header[31]*0x1000000L;
    if (Size != 0 && (Size<7 || Lhd.HeadSize<7))
      ErrExit(EARCH,FATAL_ERROR);
#ifndef TOS
    NextBlockPos=ftell(ArcFPtr)-Size+Lhd.HeadSize;
#else
    NextBlockPos=Fseek(0, ArcHandler, FSEEK_CUR)-Size+Lhd.HeadSize;
#endif
    if (Lhd.Flags & LONG_BLOCK)
      NextBlockPos+=Lhd.PackSize;
    if (Size==0 || BlockType==ALL_HEAD || Lhd.HeadType==BlockType)
      break;
#ifndef TOS
    fseek(ArcFPtr,NextBlockPos,SEEK_SET);
#else
    Fseek(NextBlockPos, ArcHandler, FSEEK_SET);
#endif
  }
  if (Size>0 && BlockType==FILE_HEAD)
  {
#ifndef TOS
    tread(ArcFPtr,ArcFileName,Lhd.NameSize);
#else
    tread(ArcHandler, ArcFileName, Lhd.NameSize);
#endif
    ArcFileName[Lhd.NameSize]=0;
    Size+=Lhd.NameSize;
    HeadCRC=CRC(0xFFFFFFFFL,&Header[2],30);
    if (!(Lhd.HeadCRC==(UWORD)~CRC(HeadCRC,&ArcFileName[0],Lhd.NameSize)))
      printf("\n %s: file header broken\n",ArcFileName);
    for (I=0;ArcFileName[I];I++)
      if (ArcFileName[I]=='\\' || ArcFileName[I]=='/')
        ArcFileName[I]=PATHDIV;
    if (Lhd.HostOS==MS_DOS)
      strtolwr(ArcFileName);
  }
  return(Size);
}


int UnpRead(Addr,Count)
UBYTE *Addr;
UWORD Count;
{
  int RetCode;
  unsigned int ReadSize,TotalRead=0;
  UBYTE *ReadAddr;
  ReadAddr=Addr;
  while (Count > 0)
  {
    ReadSize=(unsigned int)((Count>UnpPackedSize) ? UnpPackedSize : Count);
#ifndef TOS
    if ((RetCode=fread(ReadAddr,1,ReadSize,RdUnpFPtr))!=ReadSize)
#else
    if ((RetCode=Fread(RdUnpHandler, ReadSize, ReadAddr))!=ReadSize)
#endif
      break;
    TotalRead+=RetCode;
    ReadAddr+=RetCode;
    Count-=RetCode;
    UnpPackedSize-=RetCode;
    if (UnpPackedSize == 0 && UnpVolume)
      MergeArc(1);
    else
      break;
  }
  if (RetCode!=-1)
    RetCode=(int)TotalRead;
  return(RetCode);
}


int UnpWrite(Addr,Count)
UBYTE *Addr;
UWORD Count;
{
  int RetCode;
  if (TestMode)
    RetCode=(int)Count;
  else
#ifndef TOS
    if ((RetCode=fwrite(Addr,1,Count,WrUnpFPtr))!=Count)
#else
    if ((RetCode=Fwrite(WrUnpHandler, Count, Addr))!=Count)
#endif
      RetCode = -1;
  if (RetCode!=-1)
    UnpFileCRC=CRC(UnpFileCRC,Addr,(UWORD)RetCode);
  return(RetCode);
}


UDWORD CRC(StartCRC,Addr,Size)
UDWORD StartCRC;
UBYTE *Addr;
UWORD Size;
{
  UWORD I;
  if (!CRC32_Table[1])
    InitCRC();
  for (I=0;I<Size;I++)
    StartCRC = CRC32_Table[(UBYTE)StartCRC ^ Addr[I]] ^ (StartCRC >> 8);
  return(StartCRC);
}

void InitCRC()
{
  int I, J;
  UDWORD C;
  for (I=0;I<256;I++)
  {
    for (C=I,J=0;J<8;J++)
      C=(C & 1) ? (C>>1)^0xEDB88320L : (C>>1);
    CRC32_Table[I]=C;
  }
}

#ifdef TOS
  void wait_key(void) {
    Cconws("\n\r Press any key to continue... ");
    Bconin(2);
  }
#endif