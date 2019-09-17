
     In Ictari 24 you got my  PICPAC  library  for picture file packing and
     unpacking (IMG, IFF ILBM,  GIF,  TIFF,  Degas  and Neochrome - packing
     only for the first two formats)  for  use  in  assembly or GFA Basic 3
     programs (or with  other  languages  too).  Unfortunately  the routine
     IMGPAC for packing files in IMG  format  had  a stupid bug in it, that
     made it always exit, returning an error, as though there wasn't enough
     memory.

     Together with this text  you  should  find  corrected  versions of the
     following files:

     PICPAC1.S       Various unpacking and other  routines. The only change
                     I have made to this is safer blitter handling by GETFM
                     and PUTFM.
     PICPAC2.S       Packing of IFF ILBM and IMG (here was the bug!)

     PICPAC.INL      Inline file - with complete PICPAC - for use with GFA
                     Basic 3
     PICPAC1.INL     Ditto but only including unpacking of IMG, IFF, Neo,
                     Degas.
     PICPAC12.INL    Ditto with both packing and unpacking but excluding
                     GIF/TIFF


     GFA BASIC USERS NOTE: Remember  to  change  the  number of bytes given
     with the INLINE command to make room for the changed PICPAC.INL !

     Also, the comment in  the  file  PICPAC.S  erroneously states that the
     program file header is 18  bytes.  The  true  PRG  header length is 28
     bytes of course, which you must  remove  should you ever reassemble an
     INL file using Devpac.

     ~~~~~~~~
      M†rten
