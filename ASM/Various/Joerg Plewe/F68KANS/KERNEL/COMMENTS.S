*************************************************************************
*                                                                       *
*                                                                       *
*                               F68KANS                                 *
*                       a portable ANS-FORTHsystem                      *
*                                                                       *
*                            Version 1.0                                *
*                                                                       *
*                                by                                     *
*                             Joerg Plewe                               *
*                          Haarzopfer Str. 32                           *
*                        4330 Muelheim a.d. Ruhr                        *
*                                                                       *
*                       started 7jan1993 at 11.11pm                     *
*                                                                       *
*                       assembled with TurboAss                         *
*                                                                       *
*                                                                       *
* last changed:                                                         *
*************************************************************************

*****************************************************************
*                >PART 'comments'
*************************************************************************
*       usage of registers:                                             *
*                                                                       *
* us       equr     d5      ;userarea                                   *
* seg      equr     a2      ;pointer to actual segment                  *
* DT       equr     a3      ;pointer to data segment                    *
* fs       equr     a4      ;Floatingpointstack                         *
* SB       equr     a5      ;pointer to start of system                 *
* ds       equr     a6      ;data-stackpointer                          *
* rp       equr     a7      ;returnstackpointer                         *
*       d6,d7 are used for DO...LOOP                                    *
*                                                                       *
*       a0-a2,d0-d4 are for common use                                  *
*       BE CAREFULL!    not all words save theire registers!!!          *
*************************************************************************
*                                                                       *
*       HEADER                                                          *
*                                                                       *
*       $0      controlword, see below                                  *
*       $4      CFA, the CodeFieldAddress, points to code               *
*       $8      linkfield, words of ONE vocabulary                      *
*       $C      countWORD, gives length of the name                     *
*       $10...  the name                                                *
*                                                                       *
*************************************************************************
*                                                                       *
*       CODE                                                            *
*                                                                       *
*       -$4     VIEW, contains a number of a block                      *
*       $0      the code itself, see CFA above                          *
*                                                                       *
*************************************************************************
*                                                                       *
*       Bitusage in the controlword:                                    *
*                                                                       *
*       Bit0    smudge, word cannot be found                            *
*       Bit1    immediate, word will execute during compilation         *
*       Bit2    restrict, word may only be used in compiletime          *
*       Bit3    macro, word is a macro                                  *
*                                                                       *
*************************************************************************
*                ENDPART
