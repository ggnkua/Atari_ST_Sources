#define NO_VID_STREAM -1
#define UNDERFLOW -2
#define OK 1
#define EXT_BUF_SIZE 1024
extern unsigned long bitMask[];
extern unsigned long nBitMask[];
extern unsigned long rBitMask[];
extern unsigned long bitTest[];
extern unsigned long curBits;
extern int bitOffset;
extern long bufLength;
extern unsigned long *bitBuffer;

#define get_bits1(result)                                                 \
{                                                                         \
  result = ((ld_bfr & 0x80000000) != 0);                              \
  ld_bfr <<= 1;                                                          \
  ld_incnt++;                                                            \
                                                                          \
  if (ld_incnt & 0x20) {                                                 \
    ld_incnt = 0;                                                        \
    ld_rdptr++;                                                          \
    ld_bfr = *ld_rdptr;                                                 \
    bufLength--;                                                          \
  }                                                                       \
}

#define get_bits2(result)                                                 \
{                                                                         \
  ld_incnt += 2;                                                         \
                                                                          \
  if (ld_incnt & 0x20) {                                                 \
    ld_incnt -= 32;                                                      \
    ld_rdptr++;                                                          \
    bufLength--;                                                          \
    if (ld_incnt) {                                                      \
      ld_bfr |= (*ld_rdptr >> (2 - ld_incnt));                         \
    }                                                                     \
    result = ((ld_bfr & 0xc0000000) >> 30);                           \
    ld_bfr = *ld_rdptr << ld_incnt;                                    \
  }                                                                       \
                                                                          \
  result = ((ld_bfr & 0xc0000000) >> 30);                             \
  ld_bfr <<= 2;                                                          \
}

#define get_bitsX(num, mask, shift,  result)                              \
{                                                                         \
  ld_incnt += num;                                                       \
                                                                          \
  if (ld_incnt & 0x20) {                                                 \
    ld_incnt -= 32;                                                      \
    ld_rdptr++;                                                          \
    bufLength--;                                                          \
    if (ld_incnt) {                                                      \
      ld_bfr |= (*ld_rdptr >> (num - ld_incnt));                       \
    }                                                                     \
    result = ((ld_bfr & mask) >> shift);                              \
    ld_bfr = *ld_rdptr << ld_incnt;                                    \
  }                                                                       \
  else {                                                                  \
    result = ((ld_bfr & mask) >> shift);                              \
    ld_bfr <<= num;                                                      \
  }                                                                       \
}

#define get_bits3(result) get_bitsX(3,   0xe0000000, 29, result)
#define get_bits4(result) get_bitsX(4,   0xf0000000, 28, result)
#define get_bits5(result) get_bitsX(5,   0xf8000000, 27, result)
#define get_bits6(result) get_bitsX(6,   0xfc000000, 26, result)
#define get_bits7(result) get_bitsX(7,   0xfe000000, 25, result)
#define get_bits8(result) get_bitsX(8,   0xff000000, 24, result)
#define get_bits9(result) get_bitsX(9,   0xff800000, 23, result)
#define get_bits10(result) get_bitsX(10, 0xffc00000, 22, result)
#define get_bits11(result) get_bitsX(11, 0xffe00000, 21, result)
#define get_bits12(result) get_bitsX(12, 0xfff00000, 20, result)
#define get_bits14(result) get_bitsX(14, 0xfffc0000, 18, result)
#define get_bits16(result) get_bitsX(16, 0xffff0000, 16, result)
#define get_bits18(result) get_bitsX(18, 0xffffc000, 14, result)
#define get_bits32(result) get_bitsX(32, 0xffffffff,  0, result)

#define get_bitsn(num, result) get_bitsX((num), nBitMask[num], (32-(num)), result)

#define show_bits32(result)                              		\
{                                                                       \
  if (ld_incnt) {							\
    result = ld_bfr | (*(ld_rdptr+1) >> (32 - ld_incnt));		\
  }                                                                     \
  else {                                                                \
    result = ld_bfr;							\
  }                                                                     \
}

#define show_bitsX(num, mask, shift,  result)                           \
{                                                                       \
  long bO;                                                              \
  bO = ld_incnt + num;                                                 \
  if (bO > 32) {                                                        \
    bO -= 32;                                                           \
    result = ((ld_bfr & mask) >> shift) |                              \
                (*(ld_rdptr+1) >> (shift + (num - bO)));               \
  }                                                                     \
  else {                                                                \
    result = ((ld_bfr & mask) >> shift);                               \
  }                                                                     \
}

#define show_bits1(result)  show_bitsX(1,  0x80000000, 31, result)
#define show_bits2(result)  show_bitsX(2,  0xc0000000, 30, result)
#define show_bits3(result)  show_bitsX(3,  0xe0000000, 29, result)
#define show_bits4(result)  show_bitsX(4,  0xf0000000, 28, result)
#define show_bits5(result)  show_bitsX(5,  0xf8000000, 27, result)
#define show_bits6(result)  show_bitsX(6,  0xfc000000, 26, result)
#define show_bits7(result)  show_bitsX(7,  0xfe000000, 25, result)
#define show_bits8(result)  show_bitsX(8,  0xff000000, 24, result)
#define show_bits9(result)  show_bitsX(9,  0xff800000, 23, result)
#define show_bits10(result) show_bitsX(10, 0xffc00000, 22, result)
#define show_bits11(result) show_bitsX(11, 0xffe00000, 21, result)
#define show_bits12(result) show_bitsX(12, 0xfff00000, 20, result)
#define show_bits13(result) show_bitsX(13, 0xfff80000, 19, result)
#define show_bits14(result) show_bitsX(14, 0xfffc0000, 18, result)
#define show_bits15(result) show_bitsX(15, 0xfffe0000, 17, result)
#define show_bits16(result) show_bitsX(16, 0xffff0000, 16, result)
#define show_bits17(result) show_bitsX(17, 0xffff8000, 15, result)
#define show_bits18(result) show_bitsX(18, 0xffffc000, 14, result)
#define show_bits19(result) show_bitsX(19, 0xffffe000, 13, result)
#define show_bits20(result) show_bitsX(20, 0xfffff000, 12, result)
#define show_bits21(result) show_bitsX(21, 0xfffff800, 11, result)
#define show_bits22(result) show_bitsX(22, 0xfffffc00, 10, result)
#define show_bits23(result) show_bitsX(23, 0xfffffe00,  9, result)
#define show_bits24(result) show_bitsX(24, 0xffffff00,  8, result)
#define show_bits25(result) show_bitsX(25, 0xffffff80,  7, result)
#define show_bits26(result) show_bitsX(26, 0xffffffc0,  6, result)
#define show_bits27(result) show_bitsX(27, 0xffffffe0,  5, result)
#define show_bits28(result) show_bitsX(28, 0xfffffff0,  4, result)
#define show_bits29(result) show_bitsX(29, 0xfffffff8,  3, result)
#define show_bits30(result) show_bitsX(30, 0xfffffffc,  2, result)
#define show_bits31(result) show_bitsX(31, 0xfffffffe,  1, result)

#define show_bitsn(num,result) show_bitsX((num), (0xffffffff << (32-(num))), (32-(num)), result)

#define flush_bits32                                                  \
{                                                                     \
                                                                      \
  ld_rdptr++;                                                        \
  bufLength--;                                                        \
  ld_bfr = *ld_rdptr  << ld_incnt;                                 \
}

#define flush_bits(num)                                               \
{                                                                     \
  ld_incnt += num;                                                   \
                                                                      \
  if (ld_incnt & 0x20) {                                             \
    ld_incnt -= 32;                                                  \
    ld_rdptr++;                                                      \
    bufLength--;                                                      \
    ld_bfr = *ld_rdptr  << ld_incnt;                               \
  }                                                                   \
  else {                                                              \
    ld_bfr <<= num;                                                  \
  }                                                                   \
}
