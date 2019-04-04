#include <stdio.h>
#include <string.h>

typedef struct {
	int count;
	int index;
	int type;
	char name[8];
} DFN;

typedef struct {
	int count;
	int filler;
	int index;
	int type;
	char name[8];
} RSD;

int intel(unsigned i)
{
	return (i>>8)+((i&0xff)<<8);
}

int main(int argc,char *argv[])
{
DFN d;
RSD r;
FILE *infile,*outfile;

	if (argc != 3) {
		printf("usage: DFNTORSD dfnfile rsdfile\n");
		return -1;
	}
	if ((infile=fopen(argv[1],"rb"))==NULL) {
		printf("can't open %s\n",argv[1]);
		return -33;
	}
	if ((outfile=fopen(argv[2],"wb"))==NULL) {
		printf("can't create %s\n",argv[2]);
		return -37;
	}
	if(fread(&d,sizeof(DFN),1,infile)!=1) {
		printf("can't read from %s\n",argv[1]);
		return -1;
	}
	do {
		r.count=intel((unsigned) d.count);
		r.index=intel((unsigned) d.index);
		r.type=intel((unsigned) d.type);
		strcpy(r.name,d.name);
		fwrite(&r,sizeof(RSD),1,outfile);
	} while (fread(&d,sizeof(DFN),1,infile)==1);
	fclose(infile);
	fclose(outfile);
	return 0;
}
