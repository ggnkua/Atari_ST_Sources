#include <stdlib.h>
#include <stdio.h>
#include <tos.h>

#define SRCSIZE 150000L
#define DESTSIZE 32640L

typedef	unsigned	char	uchar;
typedef	unsigned	int		uint;

char GIFHEAD[]="GIF87a";
uchar *Raster;     /* Source */
int *Raster2;   /* Destination*/
uchar *RasterPtr,*RastP2;
long ByteOffset; /* Computed byte position in RASTER array  */
long BitOffset;  /* Bit offset of next code in RASTER array */
int Width, Height, LeftOfs, TopOfs, RWidth, RHeight, ClearCode;
int EOFCode, OutCount, MaxCode, Code, CurCode, OldCode, InCode;
int FirstFree, FreeCode, GIFPtr, XC, YC, Pindex;
int ReadMask, I, i, handle;
int Interlace, ColorMap, shrink;
int bw=0,xs=0,ys=0,xe=-1,ye=-1,multicolor=0;
int a, Resolution, BitsPerPixel, Background, ColorSize, CodeSize;
int InitCodeSize, FinChar, Pass, BitMask, R, G, B;
    /* The hash table used by the decompressor */
uint Prefix[4096];
char Suffix[4096];
    /* An output array used by the decompressor */
char OutCode[1025];
    /* The color map, read from the GIF header */
uchar Red[256],Green[256],Blue[256];
    /* The st palette, derived from the color map */
int Palette[256],OldPalette[16];
    /* Strings to hold the filenames */
char FileString[80];
int MaxCods[10]={4,8,16,32,64,128,256,512,1024,2048};
int CodeMask[9]= {0,1,3,7,15,31,63,127,255};
int PowersOf2[12]={1,2,4,8,16,32,64,128,256,512,1024,2048};
int Masks[10]={7,15,31,63,127,255,511,1023,2047,4095};
/* This procedure checks to be sure we've got enough heap for the array
we're trying to allocate, then allocates same. If there isn't enough
heap available, we exit with an error */

char *AllocM (long RasterSize)
{
  char *P;

  if ((P=malloc(RasterSize))==NULL)
  {
    printf("Insufficient memory available!");
    exit(0);
  }
  return P;
}

/* Mimics a file read of a single byte, reading from the input buffer */

char Getbyte(void)
{	return *RastP2++;	} 

/* Reads two bytes, to get a word value */

uint Getword(void)
{
  uchar A,B;
  uint c,d;

  A=Getbyte();
  B=Getbyte();
  c=(uint)A;
  d=(uint)B;
  printf("#%d %d#\n",c,d);
  return (c+(d<<8));
}

/* Mimic reading in the raster data. Unblock it into a single large array
to save having to do this as we go, which makes life a lot simpler for
the rest of the program. */

void ReadRaster(void)
{
  uchar ch;
  int BlockLength;
  int I;

  ch=Getbyte();
  BlockLength=(int)ch;
  while (BlockLength>0)
  {
    for (I=0; I<BlockLength; I++)
      *RasterPtr++=Getbyte();
    ch=Getbyte();
    BlockLength=(int)ch;
  }
}

/* Fetch the next code from the raster data stream. The codes can be any
length from 3 to 12 bits, packed into 8-bit bytes, so we have to maintain
our location in the Raster array as a BIT offset. We compute the byte offset
into the raster array by dividing this by 8, pick up three bytes, compute
the bit offset into our 24-bit chunk, shift to bring the desired code to
the bottom, then mask it off and return it. If the unblocked raster data
overflows the original RASTER array, we switch to the second one */

void ReadCode(void)
{
  register long RawCode;
  register uint A;

  ByteOffset=BitOffset>>3;
/* Pick up our 24-bit chunk */
  A=(uint)(Raster[ByteOffset])+((uint)(Raster[ByteOffset+1]<<8));
  RawCode=A+((long)(Raster[ByteOffset+2])<<16);
  RawCode=RawCode>>(BitOffset&7);
  Code=RawCode & ReadMask;
  BitOffset=BitOffset+CodeSize;
}

void AddToPixel (int Index)
{
  register uint XY,x,y,realind;

  if (bw&&(!multicolor)) {
    x=(int)Red[Index]+(int)Green[Index]+(int)Blue[Index];
    Index=x/48;
  } 
  if (!multicolor) {
    if (!shrink || ((XC&shrink)&&((YC+1)&shrink))) {
      x=(XC-xs)>>shrink;
      y=(YC-ys)>>shrink;
      if ((x>=0)&&(x<320)&&(y>=0)&&(y<200)) {
        XY=((y<<4)+(y<<6)+(x>>2))&0xfffc;
        Raster2[XY++]=Raster2[XY]|((Index&1)<<(15-(x&0xf)));
        Raster2[XY++]=Raster2[XY]|(((Index>>1)&1)<<(15-(x&0xf)));
        Raster2[XY++]=Raster2[XY]|(((Index>>2)&1)<<(15-(x&0xf)));
        Raster2[XY]=Raster2[XY]|((Index>>3)<<(15-(x&0xf)));
      }
    }
  } else {
    x=XC-xs; y=YC-ys;
    if ((x>=0)&&(x<160)&&(y>=0)&&(y<100)) {
      XY=((y*160)+x/2)&0xfffc;
      realind=Red[Index]*6/256;
      Raster2[XY++]=Raster2[XY]|((realind&1)<<(15-(x&0x7)*2));
      Raster2[XY++]=Raster2[XY]|(((realind>>1)&1)<<(15-(x&0x7)*2));
      Raster2[XY++]=Raster2[XY]|((realind>>2)<<(15-(x&0x7)*2));
      if((realind=Green[Index]*6/256)!=0) realind+=5;
      Raster2[XY--]=Raster2[XY]|((realind>>3)<<(14-(x&0x7)*2));
      Raster2[XY--]=Raster2[XY]|(((realind>>2)&1)<<(14-(x&0x7)*2));
      Raster2[XY--]=Raster2[XY]|(((realind>>1)&1)<<(14-(x&0x7)*2));
      Raster2[XY]=Raster2[XY]|((realind&1)<<(14-(x&0x7)*2));
      if((realind=Blue[Index]*6/256)!=0) realind+=10;
      XY+=80;
      Raster2[XY++]=Raster2[XY]|((realind&1)<<(14-(x&0x7)*2));
      Raster2[XY++]=Raster2[XY]|(((realind>>1)&1)<<(14-(x&0x7)*2));
      Raster2[XY++]=Raster2[XY]|(((realind>>2)&1)<<(14-(x&0x7)*2));
      Raster2[XY]=Raster2[XY]|((realind>>3)<<(14-(x&0x7)*2));
    }
  }
/* Update the X-coordinate, and if it overflows, update the Y-coordinate */
  if (++XC==Width) {
/* If a non-interlaced picture, just increment YC to the next scan line. If
it's interlaced, deal with the interlace as described in the GIF spec. Put
the decoded scan line out to the screen if we haven't gone past the bottom
of it */
    XC=0;
    if (!Interlace) { YC++; } else {
      if(Pass==0) {
        YC+=8;
        if (YC>=Height) {
          Pass++;
          YC=4;
        }
      } else {
        if (Pass==1) {
          YC+=8;
          if (YC>=Height) {
            Pass++;
            YC=2;
          }
        } else {
          if (Pass==2) {
            YC+=4;
            if (YC>=Height) {
              Pass++;
              YC=1;
            }
          } else {
            YC+=2;
            if (YC>=Height) {
              YC=0;
              printf("\007");
            }
          }
        }
      } 
    }
  }
}

/* Determine the palette value corresponding to the GIF colormap intensity
value. */

int	DetColor (uchar MapValue)
{
  return ((uint)(MapValue)>>5);
}

/* Set the key variables to
their necessary initial values. */

void	ReInitialize(void)
{
  XC=0;          /* X and Y screen coords back to home */
  YC=0;
  Pass=0;        /* Interlace pass counter back to 0 */
  BitOffset=0;   /* Point to the start of the raster data stream */
  GIFPtr=0;      /* Mock file read pointer back to 0 */
}

/* React to GIF clear code, or reset GIF decompression values back to their
initial state when restarting. */

void	DoClear(void)
{
  CodeSize=InitCodeSize;
  MaxCode=MaxCods [CodeSize-2];
  FreeCode=FirstFree;
  ReadMask=Masks [CodeSize-3];
}

void	usage_error(void)
{
  printf("Usage: gifcol [-X lower_limit upper_limit]\n");
  printf("              [-Y lower_limit upper_limit]\n");
  printf("              [-G] (Greyscale)\n");
  printf("              [-H] (Wait for keypress before reading pic)\n");
  printf("              [-M] (Multicolor)\n");
  printf("              [-S] save_file (neochrome save)\n");
  printf("              filename\n");
  exit(0);
}

void	main(argc,argv)
int argc;
char *argv[];
{
  long int size,rez;
  void	*scr;
  char ch,SaveFile[80];
  int Save=0,hold=0;

  ReInitialize();  /* Initialize common vars */

/* Get memory for the raster data array, and the input file data array */

  Raster=(uchar*)AllocM (SRCSIZE);
  Raster2=(int*)AllocM (DESTSIZE);
  Raster2=(int*)(((long)Raster2+639L)&0xffffff00);
  for(I=0;I<16000;I++) Raster2[I]=0;
  for(I=0;I<2048;I++) { Prefix[I]=0; Suffix[I]=0;}
  for(I=1; I<argc; ++I) {
    if ((argv[I])[0]=='-') {
      ch=(argv[I])[1];
      printf("%c ",ch);
      switch(ch) {
      case 'G' : /* Greyscale */
        bw=1;
        break;
      case 'H' : /* Hold */
        hold=1;
        break;
      case 'M' : /* Multicolor */
        multicolor=1;
        break;
      case 'S' : /* Savefile */
        if (I+1 >= argc) usage_error();
        Save=1;
        sprintf(SaveFile,"%s",argv[++I]);
        break;
      case 'X' : /* Start,end of show along X-axis */
        if (I+2 >= argc) usage_error();
        xs=atoi(argv[++I]);
        xe=atoi(argv[++I]);
        break;
      case 'Y' : /* Start,end of show along Y-axis */
        if (I+2 >= argc) usage_error();
        ys=atoi(argv[++I]);
        ye=atoi(argv[++I]);
        break;
      default:
        usage_error();
      }
    } else sprintf(FileString,"%s",argv[I]);
  }

/* Open the file */
  if (hold) getchar();
  if ((size=Fopen(FileString,0))<0) {
    printf("file error opening %s\n",FileString);
    exit(0);
  } else {
    printf("%s %ld\n",FileString,size);
  }
  handle=(int)size;
  size=Fseek(0L,handle,2);
  printf("EOF %ld, handle %d\n",size,handle);
  Fseek(0L,handle,0);
  printf("SOF \n");
/*  Raster=(*uchar)AllocM (size);*/
  RasterPtr=Raster;
  RastP2=Raster;
  if (0L>(Fread(handle,size,Raster))) {
    printf("Read error\n");
    Fclose(handle);
    exit(0);
  }
  printf("file read\n");
  Fclose(handle);
  printf("file closed\n");

/* Deal with the GIF header. Start by checking the GIF tag to make sure this
is a GIF file */

  for (i=0;i<6;i++) {
    if (GIFHEAD[i]!=Getbyte()) {
      printf("Not a GIF file, or header read error.\n");
      exit(0);
    }
  }

/* Get variables from the GIF screen descriptor */

  RWidth=Getword();	/* The raster width and height */
  RHeight=Getword();
  /* Get the packed byte immediately following and decode it */
  B=Getbyte();
  if ((B & 128)==128) ColorMap=1; else ColorMap=0;
  Resolution=((B & 0x70) >>5) +1;
  BitsPerPixel=(B & 7) +1;
  if (BitsPerPixel==1) I=2; else I=1 << BitsPerPixel;
  printf ("Colors:%d ",I);
  BitMask=CodeMask [BitsPerPixel];
  Background=Getbyte();
  B=Getbyte();		/* Skip byte of 0's */
  for (I=0;I<16;I++) {
    OldPalette[I]=(int)Setcolor(I,-1);
  }

/* Compute size of colormap, and read in the global one if there. Compute
values to be used when we set up the EGA palette */

  ColorSize=1 << BitsPerPixel;
  if (ColorMap) {
    for (I=0;I<ColorSize;I++) {
      Red [I]=Getbyte();
      Green [I]=Getbyte();
      Blue [I]=Getbyte();
      Palette[I]=((Blue[I])>>5)&0x7;
      Palette[I]=Palette[I] | ((((uint)Green[I])>>1)&0x70);
      Palette[I]=Palette[I] | ((((uint)  Red[I])<<3)&0x700);
    }
  }
  if ((ColorSize>16)||(!ColorMap)||bw) {
    bw=1;
    Palette[0]=0x000;
    Palette[1]=0x110;
    Palette[2]=0x111;
    Palette[3]=0x221;
    Palette[4]=0x222;
    Palette[5]=0x332;
    Palette[6]=0x333;
    Palette[7]=0x443;
    Palette[8]=0x444;
    Palette[9]=0x554;
    Palette[10]=0x555;
    Palette[11]=0x665;
    Palette[12]=0x666;
    Palette[13]=0x766;
    Palette[14]=0x776;
    Palette[15]=0x777;
  }
  if(multicolor) {
    Palette[0]=0x000;
    Palette[1]=0x100;
    Palette[2]=0x300;
    Palette[3]=0x400;
    Palette[4]=0x600;
    Palette[5]=0x700;
    Palette[6]=0x010;
    Palette[7]=0x030;
    Palette[8]=0x040;
    Palette[9]=0x060;
    Palette[10]=0x070;
    Palette[11]=0x001;
    Palette[12]=0x003;
    Palette[13]=0x004;
    Palette[14]=0x006;
    Palette[15]=0x007;
  }

/* Now read in values from the image descriptor */

  if ((B=Getbyte())!=',') { /* Image separator had better be ',' */
    printf("Corrupted data");
    exit(-98);
  }
  LeftOfs=Getword();
  TopOfs=Getword();
  Width=Getword();
  printf("Width: %d",Width);
  Height=Getword();
  printf("Height: %d\n",Height);
  if (xe<0) xe=Width;
  if (ye<0) ye=Height;
  G=Getbyte();
  if ((G & 64)==64) Interlace=1; else Interlace=0;

/* Note that we ignore the possible existence of a local color map. I've yet
to encounter an image that had one, and the spec says it's defined for
future use. This could lead to an error reading some files */

/* Start reading the raster data. First we get the intial code size */

  CodeSize=Getbyte();

/* Compute decompressor constant values, based on the code size */

  ClearCode=PowersOf2 [CodeSize];
  EOFCode=ClearCode+1;
  FirstFree=ClearCode+2;
  FreeCode=FirstFree;

/* The GIF spec has it that the code size is the code size used to compute the
above values is the code size given in the file, but the code size used in
compression/decompression is the code size given in the file plus one. */

  CodeSize++;
  InitCodeSize=CodeSize;
  MaxCode=MaxCods [CodeSize-2];
  ReadMask=Masks [CodeSize-3];

/* Read the raster data. Here we just transpose it from the GIF array to the
Raster array, turning it from a series of blocks into one long data stream,
which makes life much easier for ReadCode */

  printf("Unblocking\n");
  ReadRaster();

/* Get ready to do the actual read/display. Free up the heap used by the
GIF array since we don't need it any more, and if the user wants to save,
reclaim it for the Picture array */

  rez=Getrez();
  if(rez==2L) {
    printf("Color only\n");
    exit(0);
  }
  if((xe-xs)>1280 || (ye-ys)>800) {
    printf("Picture too big\n");
    exit(0);
  }
  scr = Physbase();
  shrink=0;
  if((xe-xs)>320 || (ye-ys)>200) shrink=1;
  if((xe-xs)>640 || (ye-ys)>400) shrink=2;
  printf("shrink=%d",shrink);
  OutCount=0;
  printf("/n/n Hit Any Key To Continue!\n");
  getchar();
  Setscreen((void *) -1L,Raster2,0);
  Setpalette(&Palette[0]);

/* Decompress the file, continuing until you see the GIF EOF code. One
obvious enhancement is to add checking for corrupt files here. */

  do { /* Get the next code from the raster array */
    ReadCode();
    if (Code!= EOFCode) {
     /* Clear code sets everything back to its initial value, then reads
      the immediately subsequent code as uncompressed data. */
      printf("!EOF");
      if (Code == ClearCode) {
        DoClear();
        ReadCode();
        CurCode=Code;
        OldCode=Code;
        FinChar=Code & BitMask;
        AddToPixel (FinChar);
      } else {
  /* If not a clear code, then must be data: save same as CurCode and InCode */
        CurCode=Code;
        InCode=Code;
     /* If greater or equal to FreeCode, not in the hash table yet; repeat
      the last character decoded */
        if (Code>=FreeCode) {
          CurCode=OldCode;
          OutCode [OutCount++]=FinChar;
        }
     /* Unless this code is raw data, pursue the chain pointed to by CurCode
     through the hash table to its end; each code in the chain puts its
     associated output code on the output queue. */
        if (CurCode>BitMask) {
          do {
            OutCode [OutCount++]=Suffix [CurCode];
            CurCode=Prefix [CurCode];
          }
          while(CurCode>BitMask);
        }
      /* The last code in the chain is treated as raw data. */
        FinChar=CurCode & BitMask;
        OutCode [OutCount++]=FinChar;
     /* Now we put the data out to the using routine. It's been stacked
      LIFO, so deal with it that way */
        for (I=OutCount-1;I>-1;I--) AddToPixel ((int)(OutCode [I])&0xff);
      /* Make darned sure OutCount gets set back to start */
        OutCount=0;
      /* Build the hash table on-the-fly. No table is stored in the file. */
        Prefix [FreeCode]=OldCode;
        Suffix [FreeCode]=FinChar;
        OldCode=InCode;
     /* Point to the next slot in the table. If we exceed the current MaxCode
      value, increment the code size unless it's already 12. If it is, do
      nothing: the next code decompressed better be CLEAR */
        FreeCode++;
        if (FreeCode>=MaxCode) {
          if (CodeSize < 12) {
            CodeSize++;
            MaxCode*=2;
            ReadMask=Masks[CodeSize-3];
            printf("cs%dmc%d",CodeSize,MaxCode);
          }
        }
      }
    }
  }
  while (Code!=EOFCode);
  printf("\007"); /* signals whole picture decoded */
  /* Read one key, then pack it in */
  getchar();
  Setscreen((void *) -1L,scr,(int)rez);
  Setpalette(OldPalette);
  if(Save) { /* NeoChrome format */
    Raster2-=128L;
    Raster2[0]=0;
    Raster2[1]=0; /* rez */
    for(I=0;I<16;I++) {
      Raster2[I+2]=Palette[I];
    }
    sprintf((char*)(&Raster2[18]),"         .  ");
    for(I=24;I<64;I++) {
      Raster2[I]=0;
    }
    printf("Saving as %s\n",SaveFile);
    if ((handle=(int)Fcreate(SaveFile,0))<0) {
      printf("Creation error!\n");
      exit(0);
    }
    if ((size=Fwrite(handle,32128L,Raster2))<0) {
      printf("Write error!\n");
      Fclose(handle);
      exit(0);
    }
    printf("Saved.\n");
    Fclose(handle);
  }
  exit(0);
}
