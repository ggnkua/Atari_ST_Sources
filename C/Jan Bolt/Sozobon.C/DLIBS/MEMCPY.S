*    char *memcpy(dest, source, len)
*         register char *dest;
*         register char *source;
*         register unsigned int len;
* 06.05.90 Jan Bolt

* return lmemcpy(dest,source,(unsigned long)len);
.text
.globl _memcpy
_memcpy:
     clr.l     d0
     move.w    12(sp),d0      ; len
     move.l    d0,-(sp)
     move.l    12(sp),-(sp)   ; source
     move.l    12(sp),-(sp)   ; dest
     jsr       _lmemcpy
     lea       12(sp),sp
     rts

