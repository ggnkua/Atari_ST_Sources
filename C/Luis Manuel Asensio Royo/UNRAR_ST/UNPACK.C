/******    *****   ******
 **   **  **   **  **   **      unRAR utility version 1.00e
 ******   *******  ******       ~~~~~~~~~~~~~~~~~~~~~~~~~~~
 **   **  **   **  **   **         FREE portable version
 **   **  **   **  **   **         ~~~~~~~~~~~~~~~~~~~~~

     Unpacking algorithm procedures

   YOU DO NOT NEED CHANGING THERE ANYTHING.
*/

void MakeTbl();               /* Makes Huffman table */
void AddBit();                /* Shift buffer pointer to NBits */
void CopyString();            /* string copy */
void ShortLZ();               /* unpacks short, near and special LZ codes */
void LongLZ();                /* unpacks long and far LZ codes */
void HuffDecode();            /* Huffman decoding */
int  UnpWriteBuf();           /* writes output buffer */
int  UnpReadBuf();            /* reads output buffer */
void GetFlagsBuf();           /* gets flag byte */
void UnpInitData();           /* reset initial data */
void InitHuff();              /* initializing Huffman tables */
void CorrHuff();              /* Huffman table correction in case of overflow */
void CreateEncTbl();          /* create decoding tables */
void CreateOneTbl();          /* subfunction of previous */
int  unpack();                /* unpacking procedure itself */

#define     SUSPEND     1
#define     SIZE_PBUF   0x2000
#define     FIRST       1
#define     NEXT        2
#define     UNP_MEMORY  0x10010L+sizeof(struct UnpData)+ \
                        sizeof(struct DecodeTables)+SIZE_PBUF


UWORD hcdsh1[]={ 0x0001,0xa003,0xd004,0xe004,0xf005,0xf806,0xfc07,0xfe08,
                 0xff08,0xc004,0x8004,0x9005,0x9806,0x9c06,0 };

UWORD hcdsh2[]={ 0x0002,0x4003,0x6003,0xa003,0xd004,0xe004,0xf005,0xf806,
                 0xfc06,0xc004,0x8004,0x9005,0x9806,0x9c06,0 };

UWORD hcdsh3[]={ 0x0001,0xa004,0xd004,0xe004,0xf005,0xf806,0xfc07,0xfe08,
                 0xff08,0xc004,0x8004,0x9005,0x9806,0x9c06,0xb004,0 };

UWORD hcdsh4[]={ 0x0002,0x4003,0x6003,0xa004,0xd004,0xe004,0xf005,0xf806,
                 0xfc06,0xc004,0x8004,0x9005,0x9806,0x9c06,0xb004,0 };

UWORD hcdln0[]={ 0x8001,0x4002,0x2003,0x1004,0x0805,0x0406,0x0207,0x0108,
                 0x0008,0 };

UWORD hcdln1[258],hcdln2[258];
UWORD hcode0[258],hcode1[258],hcode2[258],hcode3[258],hcode4[258];

struct MakeHuffTabs
{
  UWORD *Table;
  UBYTE HuffCodeCount[12];
} MakeTab[]={
 {hcdln1,{0  ,2  ,1  ,2  ,2  ,4   ,5   ,4   ,4   ,8   ,0   ,224}},
 {hcdln2,{0  ,0  ,5  ,2  ,2  ,4   ,5   ,4   ,4   ,8   ,2   ,220}},
 {hcode0,{0  ,0  ,0  ,8  ,8  ,8   ,9   ,0   ,0   ,0   ,0   ,224}},
 {hcode1,{0  ,0  ,0  ,0  ,4  ,40  ,16  ,16  ,4   ,0   ,47  ,130}},
 {hcode2,{0  ,0  ,0  ,0  ,2  ,5   ,46  ,64  ,116 ,24  ,0   ,0  }},
 {hcode3,{0  ,0  ,0  ,0  ,0  ,2   ,14  ,202 ,33  ,6   ,0   ,0  }},
 {hcode4,{0  ,0  ,0  ,0  ,0  ,0   ,0   ,255 ,2   ,0   ,0   ,0  }}};


SDWORD DestUnpSize=0;
UBYTE  FlagBuf;
UWORD  InAdr,OutAdr;

unsigned int Suspend=0;
unsigned int NumBit;
unsigned int LCount;
int FlagsCnt;

struct UnpData
{
  UWORD ChSet[256];
  UBYTE Place[256];
  UBYTE NToPl[256];

  UBYTE ChSetA[256];
  UBYTE PlaceA[256];

  UWORD ChSetB[256];
  UBYTE PlaceB[256];
  UBYTE NToPlB[256];

  UWORD ChSetC[256];
  UBYTE PlaceC[256];
  UBYTE NToPlC[256];

  UWORD AvrPlc;
  UWORD AvrPlcB;
  UWORD AvrLn1;
  UWORD AvrLn2;
  UWORD AvrLn3;

  UBYTE NumHuf;
  UBYTE StMode;

  UWORD Nhfb;
  UWORD Nlzb;

  UWORD MaxDist3;
  UBYTE Buf60;
  UWORD WrAddr;
  UWORD SomeRd;
  UWORD UnpAllBuf;

  UWORD LastDist;
  UWORD LastLen;
  UWORD OldDist[4];
  UWORD OldDistNum;
} *D;


struct DecodeTables
{
  UBYTE ECDSH1[256];
  UBYTE ECDSH2[256];
  UBYTE ECDSH3[256];
  UBYTE ECDSH4[256];

  UBYTE ECDLN0[256];
  UBYTE ECDLN1[4096];
  UBYTE ECDLN2[4096];
  UBYTE ECODE0[4096];
  UBYTE ECODE1[4096];
  UBYTE ECODE2[1024];
  UBYTE ECODE3[1024];
  UBYTE ECODE4[1024];
  UBYTE NCDSH1[16];
  UBYTE NCDSH2[16];
  UBYTE NCDSH3[16];
  UBYTE NCDSH4[16];
  UBYTE NCDLN0[256];
  UBYTE NCDLN1[256];
  UBYTE NCDLN2[256];
  UBYTE NCODE0[257];
  UBYTE NCODE1[257];
  UBYTE NCODE2[257];
  UBYTE NCODE3[257];
  UBYTE NCODE4[257];
} *T;

UBYTE *PackBuf;
HPBYTE UnpBuf;

int (* UnpReadFn)();
int (* UnpWriteFn)();


#define GetField() ((UWORD)((((UDWORD)PackBuf[InAdr] << 16) |         \
                   ((UWORD)PackBuf[InAdr+1] << 8) | PackBuf[InAdr+2]) \
                    >> (8-NumBit)))

void AddBit(NBits)
unsigned int NBits;
{
  InAdr += (NumBit+NBits) >> 3;
  NumBit = (NumBit+NBits) & 7;
}

void CopyString(Distance,Length)
UWORD Distance;
unsigned int Length;
{
  DestUnpSize-=Length;
  while (Length--)
  {
    UnpBuf[OutAdr]=UnpBuf[(UWORD)(OutAdr-Distance)];
    OutAdr++;
  }
}

int unpack(UnpMem,UnpRead,UnpWrite,Solid)
HPBYTE UnpMem;
int (* UnpRead)();
int (* UnpWrite)();
int Solid;
{
  UnpReadFn=UnpRead;
  UnpWriteFn=UnpWrite;
  UnpBuf=(UBYTE *)UnpMem;
  PackBuf=(UBYTE *)(UnpMem+0x10000L+sizeof(struct UnpData)+sizeof(struct DecodeTables));
  D=(struct UnpData *)(UnpMem+0x10000L);

  if (Suspend)
    OutAdr=D->WrAddr;
  else
  {
    UnpInitData(Solid);
    if (!Solid)
    {
      InitHuff();
      memset(UnpBuf,0,0x8000);
      memset(UnpBuf+0x8000,0,0x8000);
      OutAdr=0;
    }
    else
      OutAdr=D->WrAddr;
    if (--DestUnpSize < 0)
      return(0);

    if (UnpReadBuf(FIRST)==-1)
      return(-1);

    GetFlagsBuf();
    FlagsCnt=8;
  }

  while (DestUnpSize>=0)
  {
    if (InAdr >= SIZE_PBUF-12)
      if (UnpReadBuf(NEXT)==-1)
        return(-1);
    if ((UWORD)(D->WrAddr - OutAdr) < 0x110 && D->WrAddr!=OutAdr)
    {
      if (UnpWriteBuf()==-1)
        return(-1);
      if (Suspend)
        return(0);
    }

    if (D->StMode)
    {
      HuffDecode();
      continue;
    }

    if (--FlagsCnt < 0)
    {
      GetFlagsBuf();
      FlagsCnt=7;
    }

    if (FlagBuf >= 0x80)
    {
      FlagBuf<<=1;
      if (D->Nlzb > D->Nhfb)
        LongLZ();
      else
        HuffDecode();
    }
    else
    {
      FlagBuf<<=1;
      if (--FlagsCnt < 0)
      {
        GetFlagsBuf();
        FlagsCnt=7;
      }
      if (FlagBuf >= 0x80)
      {
        FlagBuf<<=1;
        if (D->Nlzb > D->Nhfb)
          HuffDecode();
        else
          LongLZ();
      }
      else
      {
        FlagBuf<<=1;
        ShortLZ();
      }
    }
  }
  if (UnpWriteBuf()==-1)
    return(-1);
  return(0);
}


void ShortLZ()
{
  UWORD LengthCode,SaveLength;
  UBYTE LastDistance;
  UWORD Distance,DistancePlace,Length;
  D->NumHuf=0;
  LengthCode=GetField();
  if (LCount==2)
  {
    AddBit(1);
    if (LengthCode >= 0x8000)
    {
      CopyString(D->LastDist,D->LastLen);
      return;
    }
    LengthCode <<= 1;
    LCount=0;
  }
  LengthCode >>= 8;
  if (D->Buf60==0)
    if (D->AvrLn1<37)
    {
      Length=T->ECDSH1[LengthCode];
      AddBit(T->NCDSH1[Length]);
    }
    else
    {
      Length=T->ECDSH2[LengthCode];
      AddBit(T->NCDSH2[Length]);
    }
  else
    if (D->AvrLn1<37)
    {
      Length=T->ECDSH3[LengthCode];
      AddBit(T->NCDSH3[Length]);
    }
    else
    {
      Length=T->ECDSH4[LengthCode];
      AddBit(T->NCDSH4[Length]);
    }

  if (Length >= 9)
  {
    if (Length == 9)
    {
      LCount++;
      CopyString(D->LastDist,D->LastLen);
      return;
    }
    if (Length == 14)
    {
      LCount=0;
      Length=T->ECDLN2[GetField() >> 4];
      AddBit(T->NCDLN2[Length]);
      Length+=5;
      Distance=(GetField() >> 1) | 0x8000;
      AddBit(15);
      D->LastLen=Length;
      D->LastDist=Distance;
      CopyString(Distance,Length);
      return;
    }

    LCount=0;
    SaveLength=Length;
    Distance=D->OldDist[(D->OldDistNum-(Length-9)) & 3];
    Length=T->ECDLN1[GetField() >> 4];
    AddBit(T->NCDLN1[Length]);
    Length+=2;
    if (Length==0x101 && SaveLength==10)
    {
      D->Buf60 ^= 1;
      return;
    }
    if (Distance > 256)
      Length++;
    if (Distance > D->MaxDist3)
      Length++;

    D->OldDist[D->OldDistNum++]=Distance;
    D->OldDistNum = D->OldDistNum & 3;
    D->LastLen=Length;
    D->LastDist=Distance;
    CopyString(Distance,Length);
    return;
  }

  LCount=0;
  D->AvrLn1 += Length;
  D->AvrLn1 -= D->AvrLn1 >> 4;

  DistancePlace=T->ECODE2[GetField() >> 6];
  AddBit(T->NCODE2[DistancePlace]);
  Distance=D->ChSetA[DistancePlace];
  if (--DistancePlace != 0xFFFF)
  {
    D->PlaceA[Distance]--;
    LastDistance=D->ChSetA[DistancePlace];
    D->PlaceA[LastDistance]++;
    D->ChSetA[DistancePlace+1]=LastDistance;
    D->ChSetA[DistancePlace]=(UBYTE)Distance;
  }
  Length+=2;
  D->OldDist[D->OldDistNum++] = ++Distance;
  D->OldDistNum = D->OldDistNum & 3;
  D->LastLen=Length;
  D->LastDist=Distance;
  CopyString(Distance,Length);
  return;
}


void LongLZ()
{
  UWORD LengthCode,Length;
  UWORD Distance,DistancePlace,NewDistancePlace;
  UWORD oldav2,oldav3;

  D->NumHuf=0;
  D->Nlzb+=16;
  if (D->Nlzb > 0xff)
  {
    D->Nlzb=0x90;
    D->Nhfb >>= 1;
  }
  oldav2=D->AvrLn2;
  if (D->AvrLn2 >= 122)
  {
    Length=T->ECDLN2[GetField() >> 4];
    AddBit(T->NCDLN2[Length]);
  }
  else
    if (D->AvrLn2 >= 64)
    {
      Length=T->ECDLN1[GetField() >> 4];
      AddBit(T->NCDLN1[Length]);
    }
    else
    {
      LengthCode=GetField();
      if (LengthCode < 0x100)
      {
        Length=LengthCode;
        AddBit(16);
      }
      else
      {
        Length=T->ECDLN0[LengthCode >> 8];
        AddBit(T->NCDLN0[Length]);
      }
    }

  D->AvrLn2 += Length;
  D->AvrLn2 -= D->AvrLn2 >> 5;
  if (D->AvrPlcB > 0x28ff)
  {
    DistancePlace=T->ECODE2[GetField() >> 6];
    AddBit(T->NCODE2[DistancePlace]);
  }
  else
    if (D->AvrPlcB > 0x6ff)
    {
      DistancePlace=T->ECODE1[GetField() >> 4];
      AddBit(T->NCODE1[DistancePlace]);
    }
    else
    {
      DistancePlace=T->ECODE0[GetField() >> 4];
      AddBit(T->NCODE0[DistancePlace]);
    }

  D->AvrPlcB += DistancePlace;
  D->AvrPlcB -= D->AvrPlcB >> 8;
  while (1)
  {
    Distance = D->ChSetB[DistancePlace];
    NewDistancePlace = D->NToPlB[Distance++ & 0xff]++;
    if (!(Distance & 0xff))
    {
      Distance-=0x100;
      CorrHuff(D->ChSetB,D->NToPlB);
    }
    else
      break;
  }

  D->ChSetB[DistancePlace]=D->ChSetB[NewDistancePlace];
  D->ChSetB[NewDistancePlace]=Distance;

  Distance=((UWORD)((Distance & ~0xff) | (GetField() >> 8))) >> 1;
  AddBit(7);

  oldav3=D->AvrLn3;
  if (Length!=1 && Length!=4)
    if (Length==0 && Distance <= D->MaxDist3)
    {
      D->AvrLn3++;
      D->AvrLn3 -= D->AvrLn3 >> 8;
    }
    else
      if (D->AvrLn3 > 0)
        D->AvrLn3--;
  Length+=3;
  if (Distance >= D->MaxDist3)
    Length++;
  if (Distance <= 256)
    Length+=8;
  if (oldav3 > 0xb0 || D->AvrPlc >= 0x2a00 && oldav2 < 0x40)
    D->MaxDist3=0x7f00;
  else
    D->MaxDist3=0x2001;
  D->OldDist[D->OldDistNum++]=Distance;
  D->OldDistNum = D->OldDistNum & 3;
  D->LastLen=Length;
  D->LastDist=Distance;
  CopyString(Distance,Length);
}


void HuffDecode()
{
  UWORD CurByte,BytePlace,NewBytePlace;
  UWORD Length,Distance,Code;

  Code=GetField();

  if (D->AvrPlc > 0x75ff)
  {
    BytePlace=T->ECODE4[Code>>6];
    if (D->StMode && BytePlace==0 && Code > 0xfff)
      BytePlace=0x100;
    AddBit(T->NCODE4[BytePlace]);
  }
  else
    if (D->AvrPlc > 0x5dff)
    {
      BytePlace=T->ECODE3[Code>>6];
      if (D->StMode && BytePlace==0 && Code > 0xfff)
        BytePlace=0x100;
      AddBit(T->NCODE3[BytePlace]);
    }
    else
      if (D->AvrPlc > 0x35ff)
      {
        BytePlace=T->ECODE2[Code>>6];
        if (D->StMode && BytePlace==0 && Code > 0xfff)
          BytePlace=0x100;
        AddBit(T->NCODE2[BytePlace]);
      }
      else
        if (D->AvrPlc > 0x0dff)
        {
          BytePlace=T->ECODE1[Code>>4];
          if (D->StMode && BytePlace==0 && Code > 0xfff)
            BytePlace=0x100;
          AddBit(T->NCODE1[BytePlace]);
        }
        else
        {
          BytePlace=T->ECODE0[Code>>4];
          if (D->StMode && BytePlace==0 && Code > 0xfff)
            BytePlace=0x100;
          AddBit(T->NCODE0[BytePlace]);
        }
  if (D->StMode)
  {
    if (--BytePlace==0xFFFF)
    {
      Code=GetField();
      AddBit(1);
      if (Code >= 0x8000)
      {
        D->NumHuf=D->StMode=0;
        return;
      }
      else
      {
        Length = (Code & 0x4000) ? 4 : 3;
        Distance= T->ECODE2[(Code >> 4) & 0x3ff];
        AddBit(T->NCODE2[Distance]+1);
        Distance = (Distance << 5) | (GetField() >> 11);
        AddBit(5);
        CopyString(Distance,Length);
        return;
      }
    }
  }
  else
    if (D->NumHuf++ >= 16 && FlagsCnt==0)
      D->StMode=1;
  D->AvrPlc += BytePlace;
  D->AvrPlc -= D->AvrPlc >> 8;
  D->Nhfb+=16;
  if (D->Nhfb > 0xff)
  {
    D->Nhfb=0x90;
    D->Nlzb >>= 1;
  }

  UnpBuf[OutAdr++]=(UBYTE)(D->ChSet[BytePlace]>>8);
  DestUnpSize--;

  while (1)
  {
    CurByte=D->ChSet[BytePlace];
    NewBytePlace=D->NToPl[CurByte++ & 0xff]++;
    if ((CurByte & 0xff) > 0xa1)
      CorrHuff(D->ChSet,D->NToPl);
    else
      break;
  }

  D->ChSet[BytePlace]=D->ChSet[NewBytePlace];
  D->ChSet[NewBytePlace]=CurByte;
}


int UnpWriteBuf()
{
  if (OutAdr<D->WrAddr)
  {
    if (UnpWriteFn((UBYTE *)(UnpBuf+D->WrAddr),(UWORD)-D->WrAddr)==-1 ||
        UnpWriteFn((UBYTE *)UnpBuf,(UWORD)OutAdr)==-1)
      return(-1);
  }
  else
    if (UnpWriteFn((UBYTE *)(UnpBuf+D->WrAddr),(UWORD)(OutAdr-D->WrAddr))==-1)
      return(-1);
  D->WrAddr=OutAdr;
  return(0);
}


int UnpReadBuf(NumBuf)
int NumBuf;
{
  int ReadCode;
  if (NumBuf==FIRST)
    ReadCode=UnpReadFn(PackBuf,SIZE_PBUF);
  else
  {
    memcpy(PackBuf,PackBuf+InAdr,(UWORD)(SIZE_PBUF-InAdr));
    ReadCode=UnpReadFn(PackBuf+SIZE_PBUF-InAdr,(UWORD)InAdr);
  }
  InAdr=0;
  if (ReadCode==-1)
    return(-1);
  return(0);
}

void GetFlagsBuf()
{
  UWORD Flags,FlagsPlace,NewFlagsPlace;

  FlagsPlace=T->ECODE2[GetField() >> 6];
  AddBit(T->NCODE2[FlagsPlace]);

  while (1)
  {
    Flags=D->ChSetC[FlagsPlace];
    FlagBuf=(UBYTE)(Flags >> 8);
    NewFlagsPlace=D->NToPlC[Flags++ & 0xff]++;
    if ((Flags & 0xff) == 0)
    {
      Flags-=0x100;
      CorrHuff(D->ChSetC,D->NToPlC);
    }
    else
      break;
  }

  D->ChSetC[FlagsPlace]=D->ChSetC[NewFlagsPlace];
  D->ChSetC[NewFlagsPlace]=Flags;
}


void UnpInitData(Solid)
int Solid;
{
  if (!Solid)
  {
    memset(D,0,sizeof(struct UnpData));
    D->AvrPlc=0x3500;
    D->MaxDist3=0x2001;
    D->Nhfb=D->Nlzb=0x80;
  }
  FlagsCnt=0;
  FlagBuf=0;
  InAdr=0;
  NumBit=0;
  D->StMode=0;
  LCount=0;
}

void InitHuff()
{
  UWORD I;
  for (I=0;I<256;I++)
  {
    D->Place[I]=D->PlaceA[I]=D->PlaceB[I]=(UBYTE)I;
    D->PlaceC[I]=(UBYTE)(~I+1);
    D->ChSet[I]=D->ChSetB[I]=I<<8;
    D->ChSetA[I]=(UBYTE)I;
    D->ChSetC[I]=(~I+1)<<8;
  }
  memset(D->NToPl,0,sizeof(D->NToPl));
  memset(D->NToPlB,0,sizeof(D->NToPlB));
  memset(D->NToPlC,0,sizeof(D->NToPlC));
  CorrHuff(D->ChSetB,D->NToPlB);
}


void CorrHuff(CharSet,NumToPlace)
UWORD *CharSet;
UBYTE *NumToPlace;
{
  int I,J;
  for (I=7;I>=0;I--)
    for (J=0;J<32;J++,CharSet++)
      *CharSet=(*CharSet & ~0xff) | I;
  memset(NumToPlace,0,sizeof(D->NToPl));
  for (I=6;I>=0;I--)
    NumToPlace[I]=(7-I)*32;
}

void CreateEncTbl(UnpMem)
HPBYTE UnpMem;
{
  T=(struct DecodeTables *)(UnpMem+0x10000L+sizeof(struct UnpData));
  CreateOneTbl(hcdsh1,T->ECDSH1,T->NCDSH1,8);
  CreateOneTbl(hcdsh2,T->ECDSH2,T->NCDSH2,8);
  CreateOneTbl(hcdsh3,T->ECDSH3,T->NCDSH3,8);
  CreateOneTbl(hcdsh4,T->ECDSH4,T->NCDSH4,8);
  CreateOneTbl(hcdln0,T->ECDLN0,T->NCDLN0,8);
  CreateOneTbl(hcdln1,T->ECDLN1,T->NCDLN1,4);
  CreateOneTbl(hcdln2,T->ECDLN2,T->NCDLN2,4);
  CreateOneTbl(hcode0,T->ECODE0,T->NCODE0,4);
  CreateOneTbl(hcode1,T->ECODE1,T->NCODE1,4);
  CreateOneTbl(hcode2,T->ECODE2,T->NCODE2,6);
  CreateOneTbl(hcode3,T->ECODE3,T->NCODE3,6);
  CreateOneTbl(hcode4,T->ECODE4,T->NCODE4,6);
}


void CreateOneTbl(hcd,ecd,ncd,ShiftCount)
UWORD *hcd;
UBYTE *ecd;
UBYTE *ncd;
UBYTE ShiftCount;
{
  UWORD I,MaxCode,Code;
  for (I=0; hcd[I]; I++)
  {
    ncd[I]=(UBYTE)(hcd[I] & 0xf);
    Code=hcd[I] >> ShiftCount;
    MaxCode=1 << (16-ShiftCount-(UBYTE)(hcd[I] & 0xf));
    while (MaxCode--)
      ecd[Code++]=(UBYTE)I;
  }
}


void MakeTbl()
{
  UWORD I,J,K,Code;
  UWORD *OutTab;
  for (I=0;I<sizeof(MakeTab)/sizeof(MakeTab[0]);I++)
  {
    OutTab=MakeTab[I].Table;
    for (Code=J=0;J<12;J++)
      for (Code<<=1,K=0;K<MakeTab[I].HuffCodeCount[J];K++)
        *(OutTab++)=(Code++ << (4+11-J)) | (J + 1);
    *OutTab=0;
  }
}

