#include <stdio.h>  /* file functions, etc... */
#include <stdlib.h> /* exit(), malloc() */

#define FALSE           0
#define TRUE            1

FILE *filep;
char *In; /* data */
int InLength,OutLength;

/**** SearchNext routine, brute force version ******************************/
/* To speed up this routine, copy beforehand the string to search at the   */
/* end of the text (you must allocate a bit more memory) and remove the    */
/* TextPos+StringLength<=TextLength condition in main loop. The routine    */
/* will always find a string, once this is done, compare Pos+Length and    */
/* return -1 if it is the one we added!                                    */
int SearchNext(char *String,int StringLength,
               char *Text,int TextLength,int TextPos) {
  int NbMatch=0;
  while((NbMatch<StringLength) && (TextPos+StringLength<=TextLength)) {
    if(Text[TextPos+NbMatch]==String[NbMatch]) {
      NbMatch++;
    } else {
      NbMatch=0;
      TextPos++;
    }
  }
  if(NbMatch==StringLength) {
    return(TextPos);
  } else {
    return(-1);
  }
}


/**** Main *****************************************************************/
int main(argc,argv) int argc; char *argv[]; {
  int Start,End;

  if(argc!=3) { printf("usage: extract InFile OutFile\n"); exit(1); }

  /**** load InFile ****/
  filep=fopen(argv[1],"rb");
  if(filep==0) { printf("error: %s not found\n",argv[1]); exit(1); }
  fseek(filep,0,2); /* 2 for EOF */
  InLength=(int) ftell(filep);
  fseek(filep,0,0); /* 0 for SOF */
  In=(char *) malloc((unsigned int) InLength);
  fread(In,1,InLength,filep);
  fclose(filep);
  
  Start=SearchNext("boot",4,In,InLength,0)+4;
  End=SearchNext("boot",4,In,InLength,Start+4);

  /**** save resulting file ****/
  filep=fopen(argv[2],"wb");
  fwrite(In+Start,1,End-Start,filep);
  fclose(filep);
  
  exit(0);
}
