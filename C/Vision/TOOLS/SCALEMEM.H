#ifndef __SCALEMEM
#define __SCALEMEM

/* Slow 'C' routines, not used anymore */
void smemcpy8(void *dst, void *src, long nb_elems_dst, long nb_elems_src) ;
void smemcpy16(void *dst, void *src, long nb_elems_dst, long nb_elems_src) ;
void smemcpy32(void *dst, void *src, long nb_elems_dst, long nb_elems_src) ;

/* Internal, the 'real' routines */
void Sasm_smemcpy8(void *dst, void *src, long nb_elems_dst, long add_src32) ;
void Sasm_smemcpy16(void *dst, void *src, long nb_elems_dst, long add_src32) ;
void Sasm_smemcpy32(void *dst, void *src, long nb_elems_dst, long add_src32) ;

/* 68030 code has direct access */
void asm030_smemcpy8(void *dst, void *src, long nb_elems_dst, long nb_elems_src) ;
void asm030_smemcpy16(void *dst, void *src, long nb_elems_dst, long nb_elems_src) ;
void asm030_smemcpy32(void *dst, void *src, long nb_elems_dst, long nb_elems_src) ;

/* These defines are for 68000 code because we can't divide a 32 bits register (68020 only) */
#define asm_smemcpy8(dst, src, nb_elems_dst, nb_elems_src) { unsigned long add_src ; add_src  = nb_elems_src << 16 ; add_src /= nb_elems_dst ; Sasm_smemcpy8( dst, src, nb_elems_dst, add_src ) ; }
#define asm_smemcpy16(dst, src, nb_elems_dst, nb_elems_src) { unsigned long add_src ; add_src  = nb_elems_src << 16 ; add_src /= nb_elems_dst ; Sasm_smemcpy16( dst, src, nb_elems_dst, add_src ) ; }
#define asm_smemcpy32(dst, src, nb_elems_dst, nb_elems_src) { unsigned long add_src ; add_src  = nb_elems_src << 16 ; add_src /= nb_elems_dst ; Sasm_smemcpy32( dst, src, nb_elems_dst, add_src ) ; }

#endif