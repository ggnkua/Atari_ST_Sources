/* ABCDABDABCD */
/* 2009/01/25
For each control byte in packed file:
  * 0: end
  * 1...MaxNbNoMatch: byte is NbNoMatch followed by NbNoMatch non packed bytes
  * MaxNbNoMatch+1...255: byte is NbMatch-MinNbMatch+MaxNbNoMatch+1 followed by a byte containing offset-1
Usually MaxNbNoMatch=127 so that we check for signs of control bytes */


/*
MaxNbNoMatch indicated inside parenthesis
               size   lz77c  lz77c2     dij127  dijkstra
kick2.exe:    12608    4292             4258    4246 (48)
AngieSux.c64:  5887    3387  3333 (89)  3347
atari.prg:     4721    3336             3331    3327 (73)
skull.tos:     4010    3277             3258
paranoid.arm:  1095     883              881
11to10.txt       11                       11
*/



#include <stdio.h>  /* file functions, etc... */
#include <stdlib.h> /* exit(), malloc() */

#define MinNbMatch 3
#define MinOffset 1

struct ByteInfo {
  unsigned int BestSize;
  unsigned char Action; /* 1..MaxNbNoMatch for no match, MaxNbNoMatch+1...255 for match */
  unsigned char Value;  /* byte if no match, offset-1 if match */
};

/* Global variables */
int BestMaxNbNoMatch,MaxNbNoMatch,MaxNbMatch;
FILE *filep;
int FileLength,PackedFileLength;
unsigned char *File,*PackedFile;
struct ByteInfo *PackInfos;

/* Requires MaxNbNoMatch & MaxNbMatch to be set */
/* Returns the length of the file with best compression */
unsigned int Dijkstra() {
  int c,d;
  int BestSize,Offset,NbMatch,Size;
  unsigned char Action,Value;
  /* first action is always a NoMatch */
  /*!!! AND SINCE IS LENGTH IS >=1 WE COULD EVEN EXCLUDE FIRST BYTE OF COMPRESSION */
  PackInfos[0].BestSize=2;
  PackInfos[0].Action=1;
  PackInfos[0].Value=File[0];
/*  printf("%c Action=%d Value=%d BestSize=%d\n",File[0],PackInfos[0].Action,PackInfos[0].Value,PackInfos[0].BestSize);*/
  /* for every byte */
  for(c=1;c<FileLength;c++) {
    /* initialise action as being NoMatch*/
    BestSize=PackInfos[c-1].BestSize+1;
    Value=File[c];
    /* previous action was NoMatch or match with MaxNbMatch bytes? */
    if(PackInfos[c-1].Action>=MaxNbNoMatch) {
      BestSize++; /* a new control byte is required */
      Action=1; /* NbNoMatch=1 */
    } else {
      Action=PackInfos[c-1].Action+1; /* NbNoMatch=previous NbNoMatch+1 */
    }
    /* Search backward for all possible match. We start by looking for */
    /* occurences of this particular byte, when we have found one we check */
    /* that we have >=MinNbMatch bytes to match, then for all possible */
    /* length of matched strings we compare the resulting size with */
    /* BestSize and we keep the best action. */
    Offset=MinOffset;
    while((Offset<=MinOffset+255) && (Offset<=c)) {
      /* Count how many matching bytes we can have */
      NbMatch=0;
      while(   (File[c-Offset-NbMatch]==File[c-NbMatch])
            && (NbMatch<MaxNbMatch)
            && (c-Offset-NbMatch>=0)) {
        NbMatch++;      
      }
      /* for every possible number of matching bytes check if size with */
      /* this matching action would be smaller. */
      d=MinNbMatch;
      while(d<=NbMatch) {
        Size=2+PackInfos[c-d].BestSize;
        if(Size<BestSize) {
          BestSize=Size;
          Action=d-MinNbMatch+MaxNbNoMatch+1;
          Value=Offset-MinOffset;
        }
        d++;
      }
      Offset++; /* next offset */
    }
    /* set bestsize+action+value for this byte */
    PackInfos[c].BestSize=BestSize;
    PackInfos[c].Action=Action;
    PackInfos[c].Value=Value;
/*    printf("%c Action=%d Value=%d BestSize=%d\n",File[c],PackInfos[c].Action,PackInfos[c].Value,PackInfos[c].BestSize);*/
  }
  return(PackInfos[FileLength-1].BestSize);
}

/***************************************************************************/
int main(argc,argv) int argc; char *argv[]; {
  
  int Best;
  int c,d,NbNoMatch;
  
  if(argc!=3) { printf("usage: dijkstra infile outfile\n"); exit(1); }
  /* load infile */
  filep=fopen(argv[1],"rb");
  if(filep==0) { printf("error: %s not found\n",argv[1]); exit(1); }
  fseek(filep,0,2); /* 2 for EOF */
  FileLength=(int) ftell(filep);
  fseek(filep,0,0); /* 0 for SOF */
  File=(unsigned char *) malloc((unsigned int) FileLength);
  fread(File,1,FileLength,filep);
  fclose(filep);
  
  /* allocate memory for PackInfos */
  PackInfos=(struct ByteInfo *) malloc((unsigned int) ((1+FileLength)*sizeof(struct ByteInfo)));
 
  printf("in:  %d bytes\n",FileLength);
  
  Best=FileLength;
  BestMaxNbNoMatch=2;
/*  
  for(MaxNbNoMatch=2;MaxNbNoMatch<254;MaxNbNoMatch++) {
    MaxNbMatch=255-(MaxNbNoMatch+1)+MinNbMatch;
    Size=Dijkstra()+1;
    if(Size<Best) {
      printf("MaxNbNoMatch=%d -> out: %d bytes\n",MaxNbNoMatch,Size);
      Best=Size;
      BestMaxNbNoMatch=MaxNbNoMatch;
    }
    if(MaxNbNoMatch==127) {
      printf("MaxNbNoMatch=%d -> out: %d bytes\n",MaxNbNoMatch,Size);
    }
  }
 */
  
  /* effective compression using PackInfos */
  MaxNbNoMatch=127; /* BestMaxNbNoMatch; */
  MaxNbMatch=255-(MaxNbNoMatch+1)+MinNbMatch;
  PackedFileLength=Dijkstra()+1;
  printf("out: %d bytes\n",PackedFileLength);
  PackedFile=(unsigned char *) malloc((unsigned int) PackedFileLength);
  d=PackedFileLength-1;
  PackedFile[d]=0; /* packed file terminator */
  d--;
  NbNoMatch=0;
  c=FileLength-1;
  while(c>=0) {
    PackedFile[d]=PackInfos[c].Value; /* offset or non matched byte byte */
    d--;
    if(PackInfos[c].Action<=MaxNbNoMatch) {
      if(NbNoMatch==0) {
        NbNoMatch=PackInfos[c].Action;
      }
      if(PackInfos[c].Action==1) {
        PackedFile[d]=NbNoMatch;
        d--;
        NbNoMatch=0;
      }
      c--;
    } else {
      PackedFile[d]=PackInfos[c].Action; /* MaxNbNoMatch+1...255 for match */\
      d--;
      c=c-(PackInfos[c].Action+MinNbMatch-MaxNbNoMatch-1);
    }
  }
  
  /* save resulting file */
  filep=fopen(argv[2],"wb");
  fwrite(PackedFile,1,PackedFileLength,filep);
  fclose(filep);

  exit(0);
}
