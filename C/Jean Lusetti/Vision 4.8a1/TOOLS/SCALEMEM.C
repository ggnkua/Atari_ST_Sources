#define OFFSET_SHIFT 16

void smemcpy8(void *dst, void *src, unsigned long nb_elems_dst, unsigned long nb_elems_src)
{
  char           *pt_src, *pt_dst ;
  unsigned long  add_src, offset_src ;

  add_src    = nb_elems_src << OFFSET_SHIFT ;
  add_src   /= nb_elems_dst ;
  offset_src = 0 ;

  for ( pt_dst = (char*) dst; pt_dst < (char*) dst + nb_elems_dst; offset_src += add_src )
  {
    pt_src = (char*) src + ( offset_src >> OFFSET_SHIFT ) ;
    *pt_dst++ = *pt_src ;
  }
}

/*
*  void smemcpy8(void *dst, void *src, long nb_elems_dst, long nb_elems_src)
*                    A0          A1              D0               D1
smemcpy8:
    MOVEM.L D2-D4/A2-A3,-(SP)
    MOVE.L  A1,A2
    MOVE.L  D1,D3   ; D3 = add_src
    SWAP    D3
    DIVU    D3,D0
    MOVEQ   #0,D4   ; D4 = offset_src
    MOVE.L  A0,A3   ; A3 = end of dest
    ADD.L   D0,A3
smemcpy8_loop:
    SWAP    D4
    ADD.L   A1,D4
    MOVE.B  (A1),(A0)+
    SWAP    D4
    ADD.L   D4,D3
    CMP.L   A0,A3
    BMI     smemcpy8_loop
    MOVEM.L (SP)+,D2-D4/A2-A3
    RTS
*/

void smemcpy16(void *dst, void *src, unsigned long nb_elems_dst, unsigned long nb_elems_src)
{
  short          *pt_src, *pt_dst ;
  unsigned long  add_src, offset_src ;

  add_src    = nb_elems_src << OFFSET_SHIFT ;
  add_src   /= nb_elems_dst ;
  offset_src = 0 ;

  for ( pt_dst = (short *) dst; pt_dst < (short *) dst + nb_elems_dst; offset_src += add_src )
  {
    pt_src = (short *) src + ( offset_src >> OFFSET_SHIFT ) ;
    *pt_dst++ = *pt_src ;
  }
}

void smemcpy32(void *dst, void *src, unsigned long nb_elems_dst, unsigned long nb_elems_src)
{
  long     *pt_src, *pt_dst ;
  unsigned long add_src, offset_src ;

  add_src    = nb_elems_src << OFFSET_SHIFT ;
  add_src   /= nb_elems_dst ;
  offset_src = 0 ;

  for ( pt_dst = (long *) dst; pt_dst < (long *) dst + nb_elems_dst; offset_src += add_src )
  {
    pt_src = (long *) src + ( offset_src >> OFFSET_SHIFT ) ;
    *pt_dst++ = *pt_src ;
  }
}
