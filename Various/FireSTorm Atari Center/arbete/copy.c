#include <osbind.h>
#include <stdio.h>
#include <stdlib.h>

int disk_read(char **memory,int start_track,int end_track,int start_sector,int end_sector,int start_side,int end_side);
int disk_write(char **memory,int start_track,int end_track,int start_sector,int end_sector,int start_side,int end_side);

int main(void)
{
  char *memory=0;
  printf("S„tt in k„ll-disketten, och tryck p† *\n");
  while(getch()!='*');

  if(disk_read(&memory,0,79,1,9,0,1))
  {
    printf("S„tt in destinations-disketten och tryck p† *\n\n");
    while(getch()!='*');
    disk_write(&memory,0,79,1,9,0,1);
    return 0;
  } 
  return -1;
}

int disk_read(char **memory,int start_track,int end_track,int start_sector,int end_sector,int start_side,int end_side)
{
  int track,sector,side;
  void *pointer;
  long fel;
  char val;
  
  printf("Reserverar %ld bytes\n",(end_track-start_track+1)*(end_sector-start_sector+1)*(end_side-start_side+1)*512);
  *memory=(char *)malloc((end_track-start_track+1)*(end_sector-start_sector+1)*(end_side-start_side+1)*512);
  if(!memory)
  {
    printf("Kunde inte reservera tillr„ckligt med minne :(\n");
    getch();
    return 0;
  }
  pointer=*memory;
  printf("Reading disc\n");
  for(track=start_track ;track<=end_track;track++)
  {
    for(side=start_side ;side<=end_side;side++)
    {
      for(sector=start_sector ;sector<=end_sector;sector++)
      {
        printf("reading track= %02d sector= %02d side= %d pointer=%ld                             \r",track,sector,side,pointer);
        fel=Floprd(pointer,0,0,sector,track,side,1);
        if(fel<0)
        {
          printf("\nfel vid l„sning (%d), (A)vbryt, (N)ytt f”rs”k eller (F)orts„tt\n",fel);
          val=getch();
          if((val=='a')||(val=='A'))
          {
          }
        }
        pointer=(char *)(((long)pointer)+512);
      }
    }
  }
  printf("\n");
  return 1;
}

int disk_write(char **memory,int start_track,int end_track,int start_sector,int end_sector,int start_side,int end_side)
{
  int track,sector,side;
  void *pointer,*buffert;
  long fel;
  char val;
  
  buffert=(void *)malloc(10000);
  if(!buffert)
  {
    printf("kunde inte reservera tillr„ckligt med minne f”r bufferten\n");
    getch();
    return 0;
  }
  pointer=*memory;
  printf("Writing disc\n");
  for(track=start_track ;track<=end_track;track++)
  {
    for(side=start_side ;side<=end_side;side++)
    {
//      printf("formaterar track=%2d side=%d                \r",track,side);
//
//      fel=Flopfmt(buffert,0,0,end_sector,track,side,1,0x87654321,0xe5e5);
//      if(fel<0)
//      {
//        printf("fel vid Formatering (%d), (A)vbryt, (N)ytt f”rs”k eller (F)orts„tt\n",fel);
//        val=getch();
//      }
//      else
//      {
        for(sector=start_sector ;sector<=end_sector;sector++)
        {
          printf("skriver track= %02d sector= %02d side= %d pointer=%ld                             \r",track,sector,side,pointer);
          fel=Flopwr(pointer,0,0,sector,track,side,1);
          if(fel<0)
          {
            printf("fel vid Skrivning (%d), (A)vbryt, (N)ytt f”rs”k eller (F)orts„tt\n",fel);
            val=getch();
            if((val=='a')||(val=='A'))
            {
            }
          }
          pointer=(char *)(((long)pointer)+512);
//        }
      }
    }
  }
  free(*memory);
  *memory=0;
  printf("\n");
  return 1;
}