/*******************************************************************
*
*			TIFFANY.C
*
*			Programm zur Analyse von TIFF-Dateien
*
*			Programmiert 1990 von Michael Bernards
*
*			mit Turbo C 2.0
*
********************************************************************/
#define VERSION "1.1"

#include <stdio.h>
#include <stdlib.h>

FILE *infile;
int itl=0;
char *names[]=
			{	"TiffClass"			,
				"SubfileType"		,
				"OldSubfileType"	,
				"ImageWidth"		,
				"ImageLength"		,
				"BitsPerSample"		,
				"Compression"		,
				""					,
				""					,
				"PhotometricInterp.",
				"Thresholding"		,
				"FillWidth"			,
				"FillLength"		,
				"FillOrder"			,
				""					,
				""					,
				"DocumentName"		,
				"ImageDescription"	,
				"Make"				,
				"Model"				,
				"StripOffsets"		,
				"Orientation"		,
				""					,
				""					,
				"SamplesPerPixel"	,
				"RowsPerStrip"		,
				"StripByteCounts"	,
				"MinSampleValue"	,
				"MaxSampleValue"	,
				"XResolution"		,
				"YResolution"		,
				"PlanarConfiguration",
				"PageName"			,
				"XPosition"			,
				"YPosition"			,
				"FreeOffsets"		,
				"FreeByteCount"		,
				"GreyResponseUnit"	,
				"GreyResponseCurve"	,
				"Group3Options"		,
				"Group4Options"		,
				""					,
				""					,
				"ResolutionUnit"	,
				"PageNumber"		,
				""					,
				""					,
				""					,
				""					,
				""					,
				""					,
				""					,
				""					,
				""					,
				""					,
				""					,
				""					,
				""					,
				""					,
				""					,
				""					,
				""					,
				""					,
				""					,
				""					,
				""					,
				""					,
				""					,
				""					,
				""					,
				""					,
			};
				
				
typedef struct{
	int tag;
	int typ;
	long len;
	long val;
} DIR;

extern long lintel(long l);
extern int intel(int i);
extern int add_hilo(long l);

main(int argc,char **argv)
{
long len,*lbuf,dirstart;
char *cbuf;
int *ibuf;

	if (argc < 2) {
		printf("usage: tiffany picture[.tif]\n");
		return-1;
	}
	if ((infile=fopen(argv[1],"rb"))==NULL) {
		printf("file not found\n");
		return -33;
	}
	fseek(infile,0,SEEK_END);
	len=ftell(infile);
	fseek(infile,0,SEEK_SET);
	if ((cbuf=(char *)malloc(len))==NULL) {
		printf("not enough memory\n");
		fclose(infile);
		return -1;
	}
	if (fread(cbuf,1,len,infile)!=len) {
		printf("unexpected end of file\n");
		fclose(infile);
		return -1;
	}
	fclose(infile);
	printf("Datei: %s, Gr”že: %ld\n",argv[1],len);
	lbuf=(long *)cbuf;
	ibuf=(int *)cbuf;
	if (*ibuf==0x4949) {
		printf("Daten im Intelformat\n");
		itl=1;
	}
	else {
		printf("Daten im Motoralaformat\n");
		itl=0;
	}
	printf("TIFF-Version: %1d.%1d\n",intel(ibuf[1])/10,intel(ibuf[1])%10);
	lbuf++;
	dirstart = lintel(*lbuf);
	while ((dirstart > 0) && (dirstart < len)) {
		DIR *xxx;
		int entries,i,idum;
		long dum;
		ibuf=(int *)(cbuf+dirstart);
		xxx=(DIR *)(ibuf+1);
		entries=intel(*ibuf);
		printf("IFD at byte %ld, entry count %d\n",dirstart,entries);
		for (i=0;i<entries;i++) {
			printf("Tag:%3d=%-20s Type: %1d, Count: %ld, Value: ",
					intel(xxx[i].tag),names[intel(xxx[i].tag)-253],
					intel(xxx[i].typ),lintel(xxx[i].len));
			dum=lintel(xxx[i].val);
			idum=add_hilo(dum);
			if (intel(xxx[i].typ)==3)
				printf("%u\n",idum);
			else
				printf("%lu\n",dum);
		}
		lbuf=(long *)(xxx+entries);
		dirstart = lintel(*lbuf);
	}
	printf("press return");
	getchar();
	return 0;
}
