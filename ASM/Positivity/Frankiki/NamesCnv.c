#include <stdio.h>
#include <stdlib.h>

#define SprX 20
#define SprW 50
#define SpaceW 3

FILE *filep;
unsigned char *In, Letter[100], c;
int InLength,InPos;
int NbLetters,NameLength,d,w2,NbSpaces;
int CharLengths[28] = { SpaceW,5,5,5,5,5,5,5,5,4,5,5,4,6,6,5,5,6,5,5,6,5,6,6,6,6,6,2 };

int main(argc,argv) int argc; char *argv[]; {
  
  /**** load InFile ****/
  if(argc!=2) { printf("Usage: ConvertNames InFile\n"); return(-1); }
  filep=fopen(argv[1],"rb");
  if(filep==0) { printf("error: %s not found\n",argv[1]); exit(1); }
  fseek(filep,0,2); /* 2 for EOF */
  InLength=(int) ftell(filep);
  fseek(filep,0,0); /* 0 for SOF */
  In=(unsigned char *) malloc((unsigned int) InLength+1);
  fread(In,1,InLength,filep);
  fclose(filep);

  In[InLength]=10; /* add a LF at the end */
  InLength++;
  
  NbLetters=0;
  NameLength=0;
  InPos=0;
  while(InPos<InLength) {
    c=In[InPos];
    // LF, then Name is finished, process it.
    if(c==10) {
      // NameLength must not exceed width of sprites
      if(NameLength>SprW) {
        printf("**** Error: %d",NbLetters);
        for(d=0;d<NbLetters;d++) {  
          if(Letter[d]==0) {
            printf(" ");
          } else {
            printf("%c",'A'+Letter[d]-1);
          }
          printf(" is too long!");
          exit(1);
        }
      }
      // Give letters' code in reverse order
      printf(" dc.b ");
//      for(d=NbLetters-1;d>=0;d--) {
      for(d=0;d<NbLetters;d++) {  
        printf("%d,",Letter[d]*6);
      }
      // Compute the number of spaces to put at the start of the name
      // so that it is centered on SprX if possible  
      w2=NameLength/2;
      if(SprX+w2>=SprW) {
        NbSpaces=(SprW-NameLength)/SpaceW;
      } else {
        NbSpaces=(SprX-w2)/SpaceW;
      }
      d=0;
      while(d<NbSpaces) {
        printf("0,");
        d++;
      }
      // Terminate this Name
      printf("255 ;");
      for(d=0;d<NbLetters;d++) {
        if(Letter[d]==0) {
          printf(" ");
        } else {
          printf("%c",'A'+Letter[d]-1);
        }
      }
      printf("\n");
      NbLetters=0;
      NameLength=0;
    // Insert letter in array and actualise length
    } else if(('A'<=c) && (c<='Z')) {
      Letter[NbLetters]=(c-'A'+1);
      NameLength+=CharLengths[c-'A'+1];
      NbLetters++;
    } else if(('a'<=c) && (c<='z')) { 
      Letter[NbLetters]=(c-'a'+1);
      NameLength+=CharLengths[c-'a'+1];
      NbLetters++;
    } else if(c==' ') { 
      Letter[NbLetters]=0;
      NameLength+=CharLengths[0];
      NbLetters++;
    } else if(c=='.') { 
      Letter[NbLetters]=27;
      NameLength+=CharLengths[0];
      NbLetters++;
    } else if(c>' ') {
      printf("**** Error: char %c not supported!\n",c);
      exit(1);
    }
    InPos++;
  }
  
  exit(0);
}
