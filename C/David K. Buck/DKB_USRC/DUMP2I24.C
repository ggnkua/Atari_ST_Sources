/********************************************************************/
/*																																	*/
/* DumpToIFF24: Convert DKB/QRT Dump file to IFF 24 bit format. 		*/
/*																																	*/
/* This can be used when converting output from the DKB raytracer to*/
/* HAM-E format.																										*/
/*																																	*/
/* Usage: 																													*/
/*	 dump2i24 <dump-file> <iff-file>																*/
/*																																	*/
/* History: 																												*/
/*	17-Oct-90: First version. 																			*/
/*						 Helge E. Rasmussen (her@compel.dk) 									*/
/*																																	*/
/*	25-Apr-91: 2nd version - somewhat ANSI-ized 										*/
/*						 David K. Buck and Aaron A. Collins 									*/
/*																																	*/
/********************************************************************/

#include <stdio.h>
#include <stdlib.h>

unsigned char *PutDump(unsigned char *, long);
unsigned char *PutRun(unsigned char *, long, long);
long PackRow(unsigned char *, unsigned char **, long);
void Plot_Pixel(unsigned char **, long, long);
void Write_String(FILE *, char *, long);
void Write_Byte(FILE *, long);
void Write_Word(FILE *, long);
void Write_Long(FILE *, long);
void Convert_Dump_To_Iff24(FILE *, FILE *);

#define USAGE "Usage: dump2i24 <dump_file> <iff_file>"
#define DEPTH 	  24						/* Depth of Amiga rgb24 image 	*/
#define BMHDsize	20L		 			 /* Size of BMHD chunk					 */

int  Compress 			= 1;	 			 /* compress image? 						 */

/************************ run length encoding from Amiga RKM *****************/
unsigned char *Dst_Ptr, Dst_Buf[BUFSIZ];
char Rle_Buf[256];
long Dst_Size;

#define DUMP						  0 	/* list of different bytes							*/
#define RUN		 					  1   /* single run of bytes 								 */
#define MinRun						3 	/* shortest allowed run 								*/
#define MaxRun						128 /* longest run (length is signed char)	*/
#define	MaxDat						128 /* longest block of unencoded data			*/
#define PutByte(dst,c,size)	{ *dst++ = (char)(c); ++size; }
#define OutDump(dst,nn)	dst = PutDump(dst,nn);
#define OutRun(dst,nn,cc)	dst = PutRun(dst,nn,cc);

unsigned char  *PutDump(unsigned char *Dst_Ptr, long nn)
/************************************************************************/
/*																																			*/
/*																																			*/
/************************************************************************/
{
 long i;

 PutByte(Dst_Ptr, nn - 1, Dst_Size);
 for(i = 0; i < nn; i++) PutByte(Dst_Ptr, Rle_Buf[i], Dst_Size);
  return (Dst_Ptr);
} /* PutDump */

unsigned char  *PutRun(unsigned char *Dst_Ptr, long nn, long cc)
/************************************************************************/
/*																																			*/
/*																																			*/
/************************************************************************/
{
 PutByte(Dst_Ptr, -(nn - 1), Dst_Size);
 PutByte(Dst_Ptr, cc, Dst_Size);
 return (Dst_Ptr);
} /* PutRun */

long	PackRow(unsigned char *Source, unsigned char *pDst, long RowSize)
/************************************************************************/
/*																																			*/
/* PackRow - pack a row of data using Amiga IFF RLE 										*/
/*																																			*/
/************************************************************************/
{
 unsigned char	 *Dst_Ptr;
 char c; 
 char lastc;
 long	mode 	= DUMP; 
 long rstart = 0;	/* Buf index current run starts */
 long nBuf;			/* number of chars in Buf */

 Dst_Ptr 	= *pDst;

 Dst_Size = 0;
 Rle_Buf[0] = lastc = c = *Source++;
 nBuf = 1;
 RowSize--;
 for(; RowSize > 0; --RowSize)
  {
 	 Rle_Buf[nBuf++] = c = *Source++;
	 switch((int)mode)
	  {
	 	 case DUMP:
		  if(nBuf > MaxDat)
	     {
		 	  OutDump(Dst_Ptr, nBuf - 1);
		 	  Rle_Buf[0] = c;
			  nBuf 	= 1;
			  rstart = 0;
			  break;
		   }
	  	if(c == lastc)
	  	 {
				if(nBuf - rstart >= MinRun)
				 {
					if(rstart > 0) OutDump(Dst_Ptr, rstart);
					 mode = RUN;
				 }
				else
				 if(rstart == 0)
					mode = RUN;
			 	}
			 else
				rstart = nBuf - 1;
		 break;
	 	 case RUN:
			if((c != lastc) || (nBuf - rstart > MaxRun))
			 {
				OutRun(Dst_Ptr, (nBuf - 1) - rstart, lastc);
				Rle_Buf[0] = c;
				nBuf 	= 1;
				rstart = 0;
				mode 	= DUMP;
			 }
		 break;
		} /* switch */
	 lastc = c;
  } /* for */
 switch((int)mode)
  {
	 case DUMP:
	  OutDump(Dst_Ptr, nBuf);
	 break;
	 case RUN:
		OutRun(Dst_Ptr, nBuf - rstart, lastc);
	 break;
	} /* switch */
 *pDst 	= Dst_Ptr;
 return(Dst_Size);
} /* PackRow */

/******************* end of RKM RL encoding routines **********************/

void Plot_Pixel(unsigned char *Planes[], long Column, long Color)
/************************************************************************/
/*																																			*/
/* Plot 'Color' in the bitplanes at the position given by 'Column'			*/
/*																																			*/
/************************************************************************/
{
 register long Bit;
 register unsigned char Shifted_Bit = (unsigned char)(1 << (7 - (Column % 8)));
 register long Array_Offset = Column / 8;
 register long Plane;

 for(Plane = 0; Color && (Plane < DEPTH); Plane++)
  {
 	 Bit = Color & 1;
	 Color >>= 1;
 	 if(Bit)
 	  *(Planes[Plane] + Array_Offset) |= Shifted_Bit;
	} /* for */
} /* Plot_Pixel */

void Write_String(FILE *Stream, char *String, long Length)
/************************************************************************/
/*																																			*/
/*																																			*/
/************************************************************************/
{
 fwrite(String, 1, (unsigned int)Length, Stream);
} /* Write_String */

void Write_Byte(FILE *Stream, long Value)
/************************************************************************/
/*																																			*/
/*																																			*/
/************************************************************************/
{
 putc ((int) (Value & 0xFF), Stream); 
} /* Write_Byte */

void Write_Word(FILE *Stream, long Value)
/************************************************************************/
/*																																			*/
/*																																			*/
/************************************************************************/
{
 putc ((int) ((Value>>8) & 0xFF), Stream); 
 putc ((int) (Value & 0xFF), Stream); 
} /* Write_Word */

void Write_Long(FILE *Stream, long Value)
/************************************************************************/
/*																																			*/
/*																																			*/
/************************************************************************/
{
 putc ((int) ((Value>>24) & 0xFF), Stream); 
 putc ((int) ((Value>>16) & 0xFF), Stream); 
 putc ((int) ((Value>>8) & 0xFF), Stream); 
 putc ((int) (Value & 0xFF), Stream); 
} /* Write_Long */

void Convert_Dump_To_Iff24(FILE *Dump_Stream, FILE *Iff_Stream)
/************************************************************************/
/*																																			*/
/* Write an DKB/QRT Dumpimage from 'Dump_Stream' and write the image in */
/* IFF 24-bit format on 'Iff_Stream'. 																	*/
/*																																			*/
/************************************************************************/
{
 long	Row, Col;
 long Plane;
 long	i;
 unsigned char 	*Red, *Green, *Blue;
 long	RgbVal;
 long	Row_Size;	/* number of bytes in IFF row of data */
 long	Length;
 long	Body_Size;
 long	Form_Size;
 long	Pos_Form_Size;  
 long	Pos_Body_Size;
 unsigned char *Planes[DEPTH];
 long	Nbr_Cols, Nbr_Rows;
 long	Dump_Buffer_Length;
 unsigned char *Dump_Buffer;	
 long	Dump_Row;

 printf("Reading DKB/QRT Dump file.\n");
 Nbr_Cols	= getc(Dump_Stream);
 Nbr_Cols |= (getc(Dump_Stream)<<8);
 Nbr_Rows	= getc(Dump_Stream);
 Nbr_Rows |= (getc(Dump_Stream)<<8);
 Row_Size = ((Nbr_Cols + 15) / 16) * 2;
 printf("Width = %d, Height = %d.\n", Nbr_Cols, Nbr_Rows);
 Dump_Buffer_Length = Nbr_Cols * 3;
 Dump_Buffer = (unsigned char *) malloc((unsigned int)Dump_Buffer_Length);
 if(Dump_Buffer == NULL)
  {
 	 fprintf(stderr, "Couldn't allocate space for Dump file buffer\n");
	 fflush(stderr);
	 exit(1);
	}
 /* Allocate memory for bit planes for one scanline. */
 for(Plane = 0; Plane < DEPTH ; Plane++)
  {
 	 Planes[Plane] = (unsigned char *)malloc((unsigned int)Row_Size);
 	 if(Planes[Plane] == NULL)
 	  {
	 	 fprintf(stderr, "Couldn't allocate memory for planes.\n");
		 exit(1);
		}
 	} /* for */
 Write_String(Iff_Stream, "FORM", 4);
 Pos_Form_Size = ftell(Iff_Stream);
 Write_Long(Iff_Stream, 0L); 		 /* This value is filled out later */
 Write_String(Iff_Stream, "ILBM", 4);
 Write_String(Iff_Stream, "BMHD", 4);
 Write_Long(Iff_Stream, BMHDsize);
 Write_Word(Iff_Stream, Nbr_Cols); 					/* Width				*/
 Write_Word(Iff_Stream, Nbr_Rows); 					/* Height 			*/
 Write_Word(Iff_Stream, 0);									/* Top					*/
 Write_Word(Iff_Stream, 0);									/* Left 				*/
 Write_Byte(Iff_Stream, DEPTH);							/* Depth				*/
 Write_Byte(Iff_Stream, 0);									/* Mask 				*/
 Write_Byte(Iff_Stream, Compress); 					/* Compress 		*/
 Write_Byte(Iff_Stream, 0);									/* Pad					*/
 Write_Word(Iff_Stream, 0);									/* Transparency */
 Write_Byte(Iff_Stream, 10); 								/* Aspect x 		*/
 Write_Byte(Iff_Stream, 11); 								/* Aspect y 		*/
 Write_Word(Iff_Stream, Nbr_Cols); 					/* Page Width 	*/
 Write_Word(Iff_Stream, Nbr_Rows); 					/* Page Height	*/
 Write_String(Iff_Stream, "BODY", 4);
 Pos_Body_Size = ftell(Iff_Stream);
 Write_Long(Iff_Stream, 0L); 		 /* This value is filled out later */
 Body_Size= 0;
 for(Row = 0; Row < Nbr_Rows; Row++)
  {
 	 if(Row % 50 == 0)
 	  {
 	   printf("%d", Row);
 	   fflush(stdout);
 	  } 
	 else
	  {
	   if(Row % 10 == 0)
	    {
	     printf(".");
	     fflush(stdout);
	    } 
	  }
 	 for(Plane = 0; Plane < DEPTH ; Plane++)
 	  {
		 for(i = 0; i < Row_Size; i++)
		  Planes[Plane][i] = 0;
	  } /* for */
   Dump_Row = getc(Dump_Stream);
   Dump_Row |= (getc(Dump_Stream)<<8);
   if(!fread(Dump_Buffer, (unsigned int)Dump_Buffer_Length, 1, Dump_Stream))
    { 
	   fprintf(stderr, "Premature end of file at line %d (%d).\n", Row, Dump_Row);
		  break;
	  } /* if */
   Red = Dump_Buffer;
   Green = Red + Nbr_Cols;
   Blue	= Green + Nbr_Cols;
	 for(Col = 0; Col < Nbr_Cols; Col++)
	  {
	 	 RgbVal	= ((*Blue++)	<< 16) + ((*Green++) << 8) + ((*Red++));
	   Plot_Pixel(Planes, Col, RgbVal);
		} /* for */
	 for(Plane = 0; Plane < DEPTH ; Plane++)
	  {
	 	 if (Compress)
	 	  {
		 	 Dst_Ptr = Dst_Buf;
			 Length = PackRow(Planes[Plane], &Dst_Ptr, Row_Size);
			 Write_String(Iff_Stream, Dst_Buf, Length);
			 Body_Size += Length;
		  }
		 else
		  {
			 Write_String(Iff_Stream, Planes[Plane], Row_Size);
			 Body_Size += Row_Size;
		  }
		} /* for */
  } /* for */
 printf("\n");
 fseek(Iff_Stream, Pos_Body_Size, 0);
 Write_Long(Iff_Stream, Body_Size);
 Form_Size = Body_Size + BMHDsize + 28;
 fseek(Iff_Stream, Pos_Form_Size, 0);
 Write_Long(Iff_Stream, Form_Size);
 free(Dump_Buffer);
 for(Plane = 0; Plane < DEPTH ; Plane++)
  free(Planes[Plane]);
} /* Convert_Dump_To_Iff24 */


void main(int argc, char *argv[])
/************************************************************************/
/*																																			*/
/* Convert DKB/QRT Dump File to IFF 24 bit format.											*/
/*																																			*/
/************************************************************************/
{
 FILE *Dump_Stream;
 char *Dump_Filename;
 FILE *Iff_Stream;
 char *Iff_Filename;
 
 if(argc != 3)
  {
	 fprintf(stderr, "%s\n", USAGE);
	 exit(1);
 	 } /* if */
 Dump_Filename = argv[1];
 Iff_Filename = argv[2];
 Dump_Stream = fopen(Dump_Filename, "rb");
 if(Dump_Stream == NULL)
  {
 	 fprintf(stderr, "Error opening '%s' for reading.\n", Dump_Filename);
	 exit(1);
	} /* if */
 Iff_Stream = fopen(Iff_Filename, "wb");
 if(Iff_Stream == NULL)
  {
 	 fprintf(stderr, "Error opening '%s' for writing\n", Iff_Filename);
	 exit(1);
	} /* if */
 Convert_Dump_To_Iff24(Dump_Stream, Iff_Stream);
 fclose(Dump_Stream);
 fclose(Iff_Stream);
 exit(0);
} /* main */
