/* LouZy77 packer, dijkstra version, Alain Brobecker
   2009/01/25: 8 bits (byte) version
   2010/02/10: 16 bits (word) version for Motorola 68k
For each control byte in packed file:
  * 0: end
  * 1...MaxNbNoMatch: word is NbNoMatch followed by NbNoMatch non packed words
  * MaxNbNoMatch+1...32767: word is NbMatch-MinNbMatch+MaxNbNoMatch+1 followed
    by a word containing offset
For the word version we'll use MaxNbNoMatch=16383, and we'll multiply all control
words and offsets by 2 so that we only have to check for signs of control words */

//;LouZy77 depacker, 68000 WORD version, Alain Brobecker
//;2010/02/23: 32 bytes for word version (+8 bytes for LEAs)
//Min EQU 3 ;3 words
//Depacker
//  lea       PackedData(pc),a0   ;This is in the first bytes
//  lea       Where2Depack(pc),a1
//DpkControlByte  
//  move.w    (a0)+,d0    ;d0=ControlByte
//  beq.s     DpkEnd
//  bmi.s     DpkMatch
//DpkNoMatch
//  move.l    a0,a2       ;a2=@CopyFrom=@PackedData
//  add.w     d0,a0       ;a0+=NbNoMatch
//  bra.s     DpkCopyOne
//DpkMatch
//  move.w    (a0)+,d1    ;d1=Offset
//  move.l    a1,a2       ;a2=@Where2Depack
//  sub.w     d1,a2       ;a2=@CopyFrom=@Where2Depack-Offset
//  sub.w     #32768-2*(Min-1),d0 ;d0=NbMatch=Control-32768+2*(Min-1)
//DpkCopyOne
//  move.w    (a2)+,(a1)+
//  subq.w    #2,d0
//  bne.s     DpkCopyOne
//  bra.s     DpkControlByte
//DpkEnd
//  jmp       (a0)
//PackedData
//  incbin "quad.pk"
//Where2Depack

#include <stdio.h>  /* file functions, etc... */
#include <stdlib.h> /* exit(), malloc() */
#define MinNbMatch 3
#define MinOffset 1

struct WordInfo {
  unsigned int BestSize;
  unsigned short int Action; /* 1..MaxNbNoMatch for no match, MaxNbNoMatch+1...32767 for match */
  unsigned short int Value;  /* word if no match, offset if match */
};

/* Global variables */
int BestMaxNbNoMatch,MaxNbNoMatch,MaxNbMatch;
FILE *filep;
int ByteFileLength,FileLength,PackedFileLength;
unsigned short int *File,*PackedFile;
unsigned char *ByteFile;
struct WordInfo *PackInfos;

/* Requires MaxNbNoMatch & MaxNbMatch to be set */
/* Returns the length of the file with best compression */
unsigned int Dijkstra() {
  int c;
  int BestSize,Offset,NbMatch,Size;
  int MaxOffset;
  unsigned short int Action,Value;
  /* first action is always a NoMatch */
  /*!!! AND SINCE IS LENGTH IS >=1 WE COULD EVEN EXCLUDE FIRST BYTE OF COMPRESSION */
  PackInfos[0].BestSize=2;
  PackInfos[0].Action=1;
  PackInfos[0].Value=File[0];
//!!!  printf("%4x Action=%d Value=%4x BestSize=%d\n",File[0],PackInfos[0].Action,PackInfos[0].Value,PackInfos[0].BestSize);
  /* for every word */
  for(c=1;c<FileLength;c++) {
    if((c & 1023)==0) { printf("%d\n",c); }
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
    MaxOffset=c; if(c>32767) { MaxOffset=32767; }
    while(Offset<=MaxOffset) {
      /* Count how many matching words we can have */
      NbMatch=0;
      while(   (File[c-Offset-NbMatch]==File[c-NbMatch])
            && (NbMatch<MaxNbMatch)
            && (c-Offset-NbMatch>=0)) {
        NbMatch++;
        /* check if size with this matching action would be smaller.*/
        Size=2+PackInfos[c-NbMatch].BestSize;
        if(Size<BestSize) {
          BestSize=Size;
          Action=NbMatch+(MaxNbNoMatch+2-MinNbMatch);
          Value=Offset;
        }
      }
      Offset++; /* next offset */
    }
    /* set bestsize+action+value for this byte */
    PackInfos[c].BestSize=BestSize;
    PackInfos[c].Action=Action;
    PackInfos[c].Value=Value;
//!!!    printf("%4x Action=%d Value=%4x BestSize=%d\n",File[c],PackInfos[c].Action,PackInfos[c].Value,PackInfos[c].BestSize);
  }
  return(PackInfos[FileLength-1].BestSize);
}

/***************************************************************************/
int main(argc,argv) int argc; char *argv[]; {
  int c,d,NbNoMatch;
  
  if(argc!=3) { printf("usage: lz77word infile outfile\n"); exit(1); }
  /* load infile */
  filep=fopen(argv[1],"rb");
  if(filep==0) { printf("error: %s not found\n",argv[1]); exit(1); }
  fseek(filep,0,2); /* 2 for EOF */
  ByteFileLength=((int) ftell(filep));
  fseek(filep,0,0); /* 0 for SOF */
  ByteFile=(unsigned char *) malloc((unsigned int) ByteFileLength);
  fread(ByteFile,1,ByteFileLength,filep);
  fclose(filep);
  
  printf("in:  %d bytes\n",ByteFileLength);
  if((ByteFileLength & 1)==1) { printf("error: file length must be a multiple of 2\n"); exit(1); }
  FileLength=ByteFileLength/2;
    
  /* convert file from bytes to words */
  File=(unsigned short int *) malloc((unsigned int) FileLength*sizeof(unsigned short int));
  for(c=0;c<FileLength;c++) {
    File[c]=(unsigned short) ByteFile[c*2]*256+ByteFile[c*2+1];
  }

  /* search best compression using Dijkstra's algorithm */
  MaxNbNoMatch=16383; /* BestMaxNbNoMatch; */
  MaxNbMatch=32767-(MaxNbNoMatch+2-MinNbMatch);
  printf("MaxNbMatch=%d\n",MaxNbMatch);
  PackInfos=(struct WordInfo *) malloc((unsigned int) ((1+FileLength)*sizeof(struct WordInfo)));
  PackedFileLength=Dijkstra()+1;
  printf("out: %d bytes\n",PackedFileLength*2);
  if(PackedFileLength>FileLength) { printf("Couldn't pack\n"); exit (0); }
  
  /* effective compression using PackInfos */
  PackedFile=(unsigned short int *) malloc((unsigned int) PackedFileLength*sizeof(unsigned short int));
  d=PackedFileLength-1;
  PackedFile[d]=0; /* packed file terminator */
//!!!  printf("\n\nvalue/offset=%4x\n",PackedFile[d]);
  d--;
  NbNoMatch=0;
  c=FileLength-1;
  while(c>=0) {
    PackedFile[d]=PackInfos[c].Value; /* offset or non matched word */
//!!!    printf("value/offset=%4x\n",PackedFile[d]);
    d--;
    if(PackInfos[c].Action<=MaxNbNoMatch) {
      if(NbNoMatch==0) {
        NbNoMatch=PackInfos[c].Action;
      }
      if(PackInfos[c].Action==1) {
        PackedFile[d]=NbNoMatch*2;
//!!!        printf("nomatch=%4x\n",PackedFile[d]);
        d--;
        NbNoMatch=0;
      }
      c--;
    } else {
      PackedFile[d]=PackInfos[c].Action*2; /* MaxNbNoMatch+1...65535 for match */
      PackedFile[d+1]=PackedFile[d+1]*2; /* multiply offset by 2 */
//!!!      printf("match=%4x (%4x)\n",PackedFile[d],PackedFile[d+1]);
      d--;
      c=c-(PackInfos[c].Action-(MaxNbNoMatch+2-MinNbMatch));
    }
  }
  
  /* convert file from words to bytes and save */
  ByteFileLength=PackedFileLength*2;
  for(c=0;c<PackedFileLength;c++) {
    ByteFile[c*2]=PackedFile[c]>>8;
    ByteFile[c*2+1]=PackedFile[c] & 255;
  }
  filep=fopen(argv[2],"wb");
  fwrite(ByteFile,1,ByteFileLength,filep);
  fclose(filep);
  exit(0);
}
