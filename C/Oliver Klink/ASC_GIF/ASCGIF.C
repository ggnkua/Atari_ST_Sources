/* Ascii Gif Viewer Version 1.6 May (c) 1992 John Ferrell jwf10@juts.ccc.amdahl.com*/
/* 5 changes for pc to mainframe portability. (search on 'mainframes') */

#include <string.h>
#include <stdlib.h>     /* libc.h for mainframes, stdlib.h for pc */
#include <stdio.h>

#define UBYTE unsigned char  /* 8Bit */
#define UWORD unsigned short /* 16Bit */
#define ULONG unsigned int   /* 32Bit  int for mainframes, long for pc */
#define BOOL unsigned short

#define TRUE  1
#define FALSE 0


struct GIFdescriptor {
   UWORD gd_Width;
   UWORD gd_Height;
   UBYTE gd_ColInfo;
   UBYTE gd_BackGround;
   UBYTE gd_PixelAspect;
};

struct ImageDesc {
   UWORD id_Left;
   UWORD id_Top;
   UWORD id_Width;
   UWORD id_Height;
   UBYTE id_Info;
};

struct RGB {
   UBYTE rgb_Red;
   UBYTE rgb_Green;
   UBYTE rgb_Blue;
};


#define GIF_IMAGE       0x2C
#define GIF_EXTENSION   0x21
#define GIF_TERMINATOR  0x3B
#define GIF_COMMENT_EXT 0xFE

/* void *screen; */  /* uncomment for pc, comment out for mainframes */

int gx=79;
int gy=23;

struct GIFdescriptor gdesc;

UBYTE **BitPlane;
struct RGB GlobalColourTable[256];

UBYTE Map[256];

ULONG ImageNumber;

FILE *GIFfh = NULL;
FILE *CAPT = NULL;

void ERROR(str)
   char *str;
   {
   printf(str);
   exit(1);
   }

void FlipWord(word)
   UWORD *word;
   {
   UBYTE swap1;
   UBYTE swap2;
   swap1 = *word & 0xFF;                /*comment out for pc, needed for mainframes */
   swap2 = (*word & 0xFF00) >> 8;       /*       "                "                 */
   *word = swap1 << 8 | swap2;          /*       "                "                 */
   }

static struct ImageDesc idesc;
static struct RGB LocalColourTable[256];

static UWORD Xpos, Ypos;
static BOOL interleave;

static UBYTE LeaveStep[5]  = {1, 8, 8, 4, 2};
static UBYTE LeaveFirst[5] = {0, 0, 4, 2, 1};

static int ReadError;
static UBYTE CodeSize;
static int EOFCode;
static UBYTE ReadMask;
static int CompDataPointer;
static int CompDataCount;
static UBYTE CompData[256];

static UWORD Prefix[4096];
static UBYTE Suffix[4096];
static UBYTE OutCode[1025];

static UBYTE ByteBuf;

int ReadCode(fh)
   FILE *fh;
   {
   register int temp;
   register int DstMasked;
   register int DstMask;
   long size;
   temp = 0;                             
   DstMasked = 1L << CodeSize;           
   for (DstMask = 1; DstMask != DstMasked; DstMask <<= 1)
      {                                  
      if (!ReadMask)                     
         {                               
         if (CompDataPointer == CompDataCount)
            {
            if ((size = fgetc(fh)) == -1)
               {                         
               printf("\nI/O Error during decompression.\n");
               ReadError = 1;            
               return EOFCode;           
               }                         
            if (fread((char *)CompData,1,size,fh) != size)
               {                         
               printf("\nI/O Error during decompression.\n");
               ReadError = 1;            
               return EOFCode;           
               }                         
            CompDataCount = size;        
            CompDataPointer = 0;         
            }                            
         ReadMask = 1;                   
         ByteBuf = CompData[CompDataPointer++];
         }                               
      if (ByteBuf & ReadMask) temp |= DstMask;
      ReadMask <<= 1;                    
      }                                  
   return temp;                          
   }                                     
                                         
void AddPixel(index)                     
   UBYTE index;                          
   {                                     
   register UWORD XStore;
   register UWORD YStore;
   XStore = Xpos + idesc.id_Left;        
   YStore = Ypos + idesc.id_Top;         
   BitPlane[YStore][XStore] = index;
   if (++Xpos == idesc.id_Width)         
      {                                  
      Xpos = 0;                          
      Ypos += LeaveStep[interleave];
      if (Ypos >= idesc.id_Height) Ypos = LeaveFirst[++interleave];
      }                                  
   }                                     
                                         
BOOL DoImage(fh)                         
   FILE *fh;                             
   {                                     
   register int index;
   register int colours;
   int Code;
   printf("Image #%ld encountered.\n", ImageNumber++);
   if (fread((char *)&idesc,1,9,fh) != 9)
      ERROR("Error reading image descriptor.\n");
   FlipWord(&idesc.id_Left);             
   FlipWord(&idesc.id_Top);              
   FlipWord(&idesc.id_Width);            
   FlipWord(&idesc.id_Height);           
   interleave = idesc.id_Info & 1L << 6;
   if (interleave) interleave = 1;       
   printf("Xpos from %d to %d, Ypos from %d to %d, %sinterlaced.\n",
      idesc.id_Left, idesc.id_Left + idesc.id_Width - 1,
      idesc.id_Top, idesc.id_Top + idesc.id_Height - 1,
      interleave ? "" : "not ");         
   if (idesc.id_Info & 1L << 7)          
      {                                  
      colours = 1L << ((idesc.id_Info & 7) + 1);
      printf("Local colour map contains %d entries.\n", colours);
      for (index = 0; index < colours; index++)
        if (fread(&LocalColourTable[index],1,3,fh) != 3)
            ERROR("......Error reading local colour\n");
      }                                  
   else                                  
      {                                  
      colours = 1L << ((gdesc.gd_ColInfo & 7) + 1);
      for (index=0; index<colours; index++)
        LocalColourTable[index]=GlobalColourTable[index];
      }                                  
   Xpos = Ypos = 0;                      
                                         
   {                                     
      int MaxCode, ClearCode, CurCode,   
          OldCode, InCode, FreeCode;     
      int OutCount;                      
      int FirstFree;                     
      UBYTE InitCodeSize, FinChar, BitMask;
      if ((CodeSize = fgetc(fh)) == -1)
         ERROR("\n......I/O Error during decompression.\n");
      ClearCode = 1L << CodeSize;        
      EOFCode = ClearCode + 1;           
      FreeCode = FirstFree = ClearCode + 2;
      CodeSize++;                        
      InitCodeSize = CodeSize;           
      MaxCode = 1L << CodeSize;          
      ReadError = ReadMask = OutCount = 0;
      CompDataPointer = CompDataCount = 0;
      BitMask = colours - 1;             
      Code = ReadCode(fh);               
      while (Code != EOFCode)            
         {                               
         if (ReadError) return TRUE;     
         if (Code == ClearCode)          
            {                            
            CodeSize = InitCodeSize;     
            MaxCode = 1L << CodeSize;    
            FreeCode = FirstFree;        
            FinChar = CurCode = OldCode = Code = ReadCode(fh);
            AddPixel(FinChar);           
            }                            
         else                            
            {                            
            CurCode = InCode = Code;     
            if (CurCode >= FreeCode)     
               {                         
               CurCode = OldCode;        
               OutCode[OutCount++] = FinChar;
               }                         
            while (CurCode > BitMask)    
               {                         
               if (OutCount > 1024)      
                  {                      
                  printf("\nCorrupt GIF file (OutCount)\n");
                  return TRUE;           
                  }                      
                  OutCode[OutCount++] = Suffix[CurCode];
                  CurCode = Prefix[CurCode];
               }                         
            FinChar = CurCode;           
            AddPixel(FinChar);           
            for (index = OutCount - 1; index >= 0; index--)
              AddPixel(OutCode[index]);
            OutCount = 0;                
            Prefix[FreeCode] = OldCode;
            Suffix[FreeCode] = FinChar;
            OldCode = InCode;            
            if (++FreeCode >= MaxCode)   
               {                         
               if (CodeSize < 12)        
                  {                      
                  CodeSize++;            
                  MaxCode <<= 1;         
                  }                      
               }                         
            }                            
         Code = ReadCode(fh);            
      }                                  
   }                                     
   if ((Code = fgetc(fh)) == -1) return TRUE;
   if (Code != 0) printf("Warning:  Unaligned packet.\n");
   return FALSE;                         
   }                                     
                                         
/* #define gx 79 */
/* #define gy 23 */
#define base 5                           
#define colors 16

char *colortab[colors] =
   {".",",",":",";","+","=","i",")","I","T","L","H","O","X","8","#"};
                                         
void show(name)
   char *name;
   {
   register int i,j,x,y;
   register int ix,iy,ii,jj;
   struct RGB colour;
   char Cbuf [1];
   int flag, cc, zz, dx, dy, z, dcnt, g, gc;
   x=y=ix=iy=dx=dy=i=j=zz=z=dcnt=g=0;
   gc=20;
   cc=1;
   dx=(idesc.id_Width<<base)/gx;
   dy=(idesc.id_Height<<base)/gy;
   do                                    
   {                                     
   printf("\n(v)iew (z Z)oom (c)opy (l,r,u,d)=PAN (g)rey (+)(-) (s)wap (1-4)=MIX (h)elp: ");
   while ((flag=getchar())==(char)10);
   if (flag == 'v' || flag == 'z' || flag == 'Z' ||
       flag == 'l' || flag == 'h' || flag == 'c' ||
       flag == 'r' || flag == 'u' || flag == 'd' || flag == 's' ||
       flag == 'g' || flag == 'G' || flag == '1' || flag == '2' ||
       flag == '3' || flag == '4' || flag == '+' || flag == '-'); else return;
   if (flag=='v')cc=1;
   if (flag=='1'){cc=1; printf("\nDefault Mix\n");}
   if (flag=='2'){cc=2; printf("\nRed Mix Blocked\n");}
   if (flag=='3'){cc=3; printf("\nGreen Mix Blocked\n");}
   if (flag=='4'){cc=4; printf("\nBlue Mix Blocked\n");}
   if (flag=='g'){cc=5; printf("\nAssuming This Is A Grey Scale Gif\n");}
   if (flag=='+'){cc=5; gc+=5; printf("\nRaising Sensitivity To %d, Assuming This Is A Grey Scale Gif\n", gc);}
   if (flag=='-'){cc=5; gc-=5; printf("\nLowering Sensitivity To %d Assuming This Is A Grey Scale Gif\n", gc);}
   if (flag=='s'){cc=5;if (g==0)g=1; else g=0; printf("\nSwapping Background For Grey Scale Gif, Assuming This Is A Grey Scale Gif\n");}
   if (flag=='c'){
      printf("\nAppending copy of screen to file ascgifs\n");
      if (!(CAPT = fopen("ascgifs","ab"))) ERROR("Open error\n");
      Cbuf[0] = 10;
      if(fwrite(Cbuf,1,1,CAPT) != 1)
         ERROR("Unable to write to ascgifs.\n");
      if(fwrite(name,1,strlen(name),CAPT) != strlen(name))
          ERROR("Unable to write to ascgifs.\n");
      }
   if (flag=='u'){if(iy>=dy*gy/4) iy=iy-dy*gy/4;};
   if (flag=='d'){if(iy+dy*gy+2*dy<((idesc.id_Height)<<base)) iy=iy+dy*gy/4;};
   if (flag=='z'){
      dx>>=1;                            
      dy>>=1;
      ix=ix+dx*gx/2;
      iy=iy+dy*gy/2;
      };
   if (flag=='Z'){
      dx=(idesc.id_Width<<base)/gx;
      dy=(idesc.id_Height<<base)/gy;
      ix=0;
      iy=0;
      };
   if (flag=='r'){if(ix+dx*gx+2*dx<((idesc.id_Width)<<base)) ix=ix+dx*gx/4;};
   if (flag=='l'){if(ix>=dx*gx/4) ix=ix-dx*gx/4;};
   y=iy;
   if (zz == 0){
      colour=LocalColourTable[BitPlane[(y>>base)+idesc.id_Top]
                       [(x>>base)+idesc.id_Left]];
      zz=(colour.rgb_Red+colour.rgb_Green+colour.rgb_Blue)/3;
   }
   if (flag == 'h'){
   printf("\nv = View The Gif\n");
   printf("z = Zoom In On The Center\n");
   printf("Z = Zoom Out To Normal Size\n");
   printf("c = Capture screen\n");
   printf("l = Pan Left\n");
   printf("r = Pan Right\n");
   printf("u = Pan Up\n");
   printf("d = Pan Down\n");
   printf("g = Display A Grey Scale Gif, Use Only With A Grey Scale Gif\n");
   printf("+ = Raise Sensitivity For A Grey Scale Gif\n");
   printf("- = Lower Sensitivity For A Grey Scale Gif\n");
   printf("s = Swap Background For Grey Scale Gif From/To Black/White\n");
   printf("1 = Default Mix\n");
   printf("2 = Red Mix Blocked\n");
   printf("3 = Green Mix Blocked\n");
   printf("4 = Blue Mix Blocked\n");
   printf("Any other character will quit\n");
   }
   else {
   for (j=0; j<gy; j++)
      {
      if (flag== 'c'){
        Cbuf[0] = 10;
        if(fwrite(Cbuf,1,1,CAPT) != 1)
          ERROR("Unable to write to ascgifs.\n");
      }
      printf("\n");
      x=ix;
      for (i=0; i<gx; i++)
         {                               
         if (cc==5){
          dcnt=0;
           for (jj=y; jj-y<dy; jj+=4){
              for (ii=x; ii-x<dx; ii+=4){
                colour=LocalColourTable[BitPlane[(jj>>base)+idesc.id_Top]
                                             [(ii>>base)+idesc.id_Left]];
                z=(colour.rgb_Red+colour.rgb_Green+colour.rgb_Blue)/3;
                if (g == 1){
                  if (zz==z)dcnt++;}
                else if (zz!=z) dcnt++;
              }
           };
           z=dcnt/(dx/gc+dy/gc);
           if (z<1)z=1;
           if (z>256)z=256;
         }
         else {
          colour=LocalColourTable[BitPlane[(y>>base)+idesc.id_Top]
                                         [(x>>base)+idesc.id_Left]];
          if (cc==2){
            z=(colour.rgb_Green+colour.rgb_Blue)/2;}
          else if (cc==3){
                 z=(colour.rgb_Red+colour.rgb_Blue)/2;}
              else if (cc==4){
                      z=(colour.rgb_Red+colour.rgb_Green)/2;}
                   else {
                        z=(colour.rgb_Red+colour.rgb_Green+colour.rgb_Blue)/3;
                        };
         }
         if (flag=='c'){
           Cbuf[0] = *colortab[(z+gc-20)*colors/0x100];
           if(fwrite(Cbuf,1,1,CAPT) != 1)
             ERROR("Unable to write to ascgifs.\n");
         }
         printf(colortab[(z+gc-20)*colors/0x100]);
         x+=dx;
         if (x<0)return;
      }
      y+=dy;                             
      }
      }
   if (flag== 'c') fclose(CAPT);
   } while (TRUE);
   }                                     
                                         
main(argc,argv)                          
   int argc;
   char *argv[];
   {                                     
   register int index;
   char sig[7];
   int size;
   int error;                            
   int colours;                          
   long cmdcode;                         
   if (argc < 2) ERROR("ascgif(1.6) use: ascgif name.gif <output width> <output height>\n");
   if (!(GIFfh = fopen(argv[1],"rb"))) ERROR("Open error\n"); /*"rb" for pc, "r" for SOME mainframes */
   if (argc > 2){
     if (!(gx=atoi(argv[2]))) ERROR("3rd parameter not numeric, (width)\n");
     if (!(gy=atoi(argv[3]))) ERROR("4th parameter not numeric, (height)\n");
     }
   else { gx = 79;
          gy = 23;
        };
   sig[6] = '\0';
   if (fread(sig,1,6,GIFfh) != 6 || strcmp("GIF87a", sig))
      ERROR("Not an 87a GIF file...\n");
   if (fread((char *)&gdesc,1,7,GIFfh) != 7)
      ERROR("Error reading screen descriptor\n");
   FlipWord(&gdesc.gd_Width);
   FlipWord(&gdesc.gd_Height);           
   printf("Ascgif Ver 1.6\n");
   printf("Signature = \"%s\", Width = %u, Height = %u\n",
      sig, gdesc.gd_Width, gdesc.gd_Height);
   colours = 1L << ((gdesc.gd_ColInfo & 7) + 1);
   if (!(gdesc.gd_ColInfo & 1L << 7))    
      {                                  
      printf("No global colour map supplied, using internal.\n");
      for (index = 0; index < colours; index++)
         {                               
         GlobalColourTable[index].rgb_Red   =
         GlobalColourTable[index].rgb_Green =
         GlobalColourTable[index].rgb_Blue  = index;
         }                               
      }                                  
   else                                  
      {                                  
      printf("Global colour map contains %d entries.\n", colours);
      for (index = 0; index < colours; index++)
         if (fread(&GlobalColourTable[index],1,3,GIFfh) != 3)
            ERROR("Error reading global colour\n");
      }
   size = ((gdesc.gd_Width + 7) / 8) + 1;
   size += (size + 127) >> 7;
   if (!(BitPlane = (UBYTE **)malloc(gdesc.gd_Height * sizeof(UBYTE *))))
      ERROR("Not enough memory\n");
   size = (gdesc.gd_Width + 1) * sizeof(UBYTE);
   for (index = 0; index < gdesc.gd_Height; index++)
      if (!(BitPlane[index] = (UBYTE *)malloc(size)))
         ERROR("Not enough memory\n");
   ImageNumber = 1;
   for (error = FALSE; error == FALSE;)
      {
      if ((cmdcode = fgetc(GIFfh)) == -1) break;
      if (cmdcode ==
          GIF_IMAGE){
            error = DoImage(GIFfh);
            } else
      if (cmdcode ==
           GIF_EXTENSION){
            error = TRUE;                
           } else
      if (cmdcode ==
           GIF_TERMINATOR){
            show(argv[1]);
            break;
           }
           else {
            printf("Unknown directive encountered.\n");                         
            error = TRUE;                
           }
      }                                  
      printf("End of GIF session\n");    
      exit(0);                           
   } 

