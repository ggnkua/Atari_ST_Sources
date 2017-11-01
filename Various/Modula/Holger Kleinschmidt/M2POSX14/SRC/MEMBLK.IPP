IMPLEMENTATION MODULE MEMBLK;
__IMP_SWITCHES__
__RANGECHECK_OFF__
__STACKCHECK_OFF__
__DEBUG_OFF__
#ifdef HM2
#ifdef __LONG_WHOLE__
(*$!i+: Modul muss mit $i- uebersetzt werden! *)
(*$!w+: Modul muss mit $w- uebersetzt werden! *)
#else
(*$!i-: Modul muss mit $i+ uebersetzt werden! *)
(*$!w-: Modul muss mit $w+ uebersetzt werden! *)
#endif
#endif
(*****************************************************************************)
(* 15-Mai-94, Holger Kleinschmidt                                            *)
(*****************************************************************************)

INLINE_CODE_IMPORT

FROM SYSTEM IMPORT
(* TYPE *) ADDRESS;

FROM types IMPORT
(* TYPE *) int, sizeT;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

__PROCFRAME_OFF__
PROCEDURE memswap ((* EIN/ -- *) blk1 : ADDRESS;
                   (* EIN/ -- *) blk2 : ADDRESS;
                   (* EIN/ -- *) len  : sizeT   );

BEGIN
#if (defined HM2)
(*
  move.w  D2,-(SP)
  movea.l 6(SP),A0
  movea.l 10(SP),A1
  move.l  14(SP),D0
*)
 CODE(3F02H,206FH,0006H,226FH,000AH,202FH,000EH);
#elif (defined MM2)
(*
  move.l  -(A3),D0
  movea.l -(A3),A1
  movea.l -(A3),A0
  tst.l   D0
*)
 CODE(2023H,2263H,2063H,4A80H);
#elif (defined TDIM2)
(*
  movea.l 12(SP),A0
  movea.l 8(SP),A1
  move.l  4(SP),D0
*)
 CODE(206FH,000CH,226FH,0008H,202FH,0004H);
#elif (defined LPRM2) || (defined SPCM2)
(*
  movea.l 20(A6),A0
  movea.l 16(A6),A1
  move.l  12(A6),D0
*)
 CODE(206EH,0014H,226EH,0010H,202EH,000CH);
#endif

(*
  beq.s   ende           ; B: len = 0, nix zu tun
  move.w  A0,D1
  move.w  A1,D2
  eor.b   D2,D1          ; genau eine der Adressen ungerade ?
  btst    #0,D1          ;
  beq.s   fastswap       ; B: nein
slowswap:                ; Bloecke byteweise vertauschen
  move.b  (A0),D1
  move.b  (A1),(A0)+
  move.b  D1,(A1)+
  subq.l  #1,D0
  bne.s   slowswap
  bra.s   ende           ; fertig

fastswap:
  btst    #0,D2          ; beide Adr. ungerade oder beide gerade ?
  beq.s   longcnt        ; B: beide gerade
  move.b  (A0),D1        ; sonst ein Byte vorneweg tauschen
  move.b  (A1),(A0)+     ; -> gerade Adresse
  move.b  D1,(A1)+
  subq.l  #1,D0          ; eins weniger zu tauschen
longcnt:
  move.b  D0,D2          ; fuer spaeteren Ueberhangtest
  lsr.l   #2,D0          ; Anzahl auszutauschender Langworte
  beq.s   tstwswap       ; B: weniger als 4 Byte
swaplp:                  ; Bloecke langwortweise vertauschen
  move.l  (A0),D1
  move.l  (A1),(A0)+
  move.l  D1,(A1)+
  subq.l  #1,D0
  bne.s   swaplp
tstwswap:
  btst    #1,D2          ; noch ein zusaetzl. Wort auszutauschen ?
  beq.s   tstbswap       ; B: nein
  move.w  (A0),D1
  move.w  (A1),(A0)+
  move.w  D1,(A1)+
tstbswap:
  btst    #0,D2          ; noch ein Byte ?
  beq.s   ende           ; B: nein, fertig
  move.b  (A0),D1
  move.b  (A1),(A0)
  move.b  D1,(A1)
ende:

*)
 CODE(674EH,3208H,3409H,0B501H,0801H,0000H);
 CODE(670CH,1210H,10D1H,12C1H,5380H,66F6H,6036H,0802H);
 CODE(0000H,6708H,1210H,10D1H,12C1H,5380H,1400H,0E488H);
 CODE(670AH,2210H,20D1H,22C1H,5380H,66F6H,0802H,0001H);
 CODE(6706H,3210H,30D1H,32C1H,0802H,0000H,6706H,1210H);
 CODE(1091H,1281H);

#if (defined HM2)
(*
  move.w  (SP)+,D2
  movea.l (SP)+,A0
  lea     12(SP),SP
  jmp     (A0)
*)
 CODE(341FH,205FH,4FEFH,000CH,4ED0H);
#elif (defined TDIM2)
(*
  rts
*)
 CODE(4E75H);
#endif
END memswap;
__PROCFRAME_ON__

(*---------------------------------------------------------------------------*)

__PROCFRAME_OFF__
PROCEDURE memmove ((* EIN/ -- *) dst : ADDRESS;
                   (* EIN/ -- *) src : ADDRESS;
                   (* EIN/ -- *) len : sizeT   );

BEGIN
#if (defined HM2)
(*
  move.w  D2,-(SP)
  movea.l 10(SP),A0
  movea.l 6(SP),A1
  move.l  14(SP),D0
*)
 CODE(3F02H,206FH,000AH,226FH,0006H,202FH,000EH);
#elif (defined MM2)
(*
  move.l  -(A3),D0
  movea.l -(A3),A0
  movea.l -(A3),A1
  tst.l   D0
*)
 CODE(2023H,2063H,2263H,4A80H);
#elif (defined TDIM2)
(*
  movea.l 8(SP),A0
  movea.l 12(SP),A1
  move.l  4(SP),D0
*)
 CODE(206FH,0008H,226FH,000CH,202FH,0004H);
#elif (defined LPRM2) || (defined SPCM2)
(*
  movea.l 16(A6),A0
  movea.l 20(A6),A1
  move.l  12(A6),D0
*)
 CODE(206EH,0010H,226EH,0014H,202EH,000CH);
#endif

(*
  beq     ende           ; B: len = 0, nix zu tun
  cmpa.l  A0,A1          ; Zieladresse groesser als Quelladresse ?
  bhi     special        ; B: ja, muss von hinten nach vorne kopiert werden
                         ; falls sich die Bereiche ueberschneiden
  move.w  A0,D1          ; genau eine Adresse ungerade ?
  move.w  A1,D2          ;
  eor.b   D2,D1          ;
  btst    #0,D1          ;
  beq.s   nfastcpy       ; B: nein, beide gerade/ungerade -> schnell kopieren

* Es muss langsam byteweise kopiert werden.
* Der Trick mit dem Sprung in die Kopieranweisungen stammt aus
* dem "bcopy()" der GnuLib/MiNTLib

  move.w  D0,D1          ; die Anzahl Bytes im letzten unvollstaendigen 8-er-
  neg.w   D1             ; Block und entsprechenden Index in die
  andi.w  #7,D1          ; Kopieranweisungen berechnen
  add.w   D1,D1          ;
  addq.l  #7,D0          ; plus 1 Block, falls unvollst. Block
  lsr.l   #3,D0          ; Anzahl kompletter 8-er Bloecke [+ unvollst. Block]
  jmp     nloop8(PC,D1.w) ; ersten vollst. oder unvollst. Block kopieren
nloop8:                  ; jeweils 8 Byte kopieren
  move.b  (A0)+,(A1)+
  move.b  (A0)+,(A1)+
  move.b  (A0)+,(A1)+
  move.b  (A0)+,(A1)+
  move.b  (A0)+,(A1)+
  move.b  (A0)+,(A1)+
  move.b  (A0)+,(A1)+
  move.b  (A0)+,(A1)+
  subq.l  #1,D0
  bne.s   nloop8
  bra     ende

nfastcpy:
  btst    #0,D2          ; beide Adressen ungerade ?
  beq.s   neven          ; B: nein
  move.b  (A0)+,(A1)+    ; ein Byte vorneweg -> gerade Adressen
  subq.l  #1,D0          ; ein Byte weniger zu kopieren
neven:
  move.b  D0,D2          ; fuer spaeteren Ueberhangtest
  lsr.l   #2,D0          ; Anzahl zu kopierender Langworte
  beq.s   ntstw          ; B: weniger als 4 Byte
  move.w  D0,D1          ; die Anzahl Bytes im letzten unvollstaendigen 32-er-
  neg.w   D1             ; Block und entsprechenden Index in die
  andi.w  #7,D1          ; Kopieranweisungen berechnen
  add.w   D1,D1          ;
  addq.l  #7,D0          ; plus 1 Block, falls unvollst. Block
  lsr.l   #3,D0          ; Anzahl von 32-er-Bloecken [+ unvollst Block]
  jmp     nloop32(PC,D1.w) ; ersten vollst. oder unvollst. Block kopieren
nloop32:                 ; jeweils 32 Byte kopieren
  move.l  (A0)+,(A1)+
  move.l  (A0)+,(A1)+
  move.l  (A0)+,(A1)+
  move.l  (A0)+,(A1)+
  move.l  (A0)+,(A1)+
  move.l  (A0)+,(A1)+
  move.l  (A0)+,(A1)+
  move.l  (A0)+,(A1)+
  subq.l  #1,D0
  bne.s   nloop32
ntstw:
  btst    #1,D2          ; ein zusaetzliches Wort ?
  beq.s   ntstb          ; B: nein
  move.w  (A0)+,(A1)+
ntstb:
  btst    #0,D2          ; ein zusaetzliches Byte ?
  beq     ende           ; B: nein, fertig
  move.b  (A0)+,(A1)+
  bra.s   ende

* wie oben, nur alles von hinten nach vorne kopieren

special:
  adda.l  D0,A0
  adda.l  D0,A1

  move.w  A0,D1
  move.w  A1,D2
  eor.b   D2,D1
  btst    #0,D1
  beq.s   sfastcpy

  move.w  D0,D1
  neg.w   D1
  andi.w  #7,D1
  add.w   D1,D1
  addq.l  #7,D0
  lsr.l   #3,D0
  jmp     sloop8(PC,D1.w)
sloop8:
  move.b  -(A0),-(A1)
  move.b  -(A0),-(A1)
  move.b  -(A0),-(A1)
  move.b  -(A0),-(A1)
  move.b  -(A0),-(A1)
  move.b  -(A0),-(A1)
  move.b  -(A0),-(A1)
  move.b  -(A0),-(A1)
  subq.l  #1,D0
  bne.s   sloop8
  bra.s   ende

sfastcpy:
  btst    #0,D2
  beq.s   seven
  move.b  -(A0),-(A1)
  subq.l  #1,D0
seven:
  move.b  D0,D2
  lsr.l   #2,D0
  beq.s   ststw
  move.w  D0,D1
  neg.w   D1
  andi7.w  #7,D1
  add.w   D1,D1
  addq.l  #7,D0
  lsr.l   #3,D0
  jmp     sloop32(PC,D1.w)
sloop32:
  move.l  -(A0),-(A1)
  move.l  -(A0),-(A1)
  move.l  -(A0),-(A1)
  move.l  -(A0),-(A1)
  move.l  -(A0),-(A1)
  move.l  -(A0),-(A1)
  move.l  -(A0),-(A1)
  move.l  -(A0),-(A1)
  subq.l  #1,D0
  bne.s   sloop32
ststw:
  btst    #1,D2
  beq.s   ststb
  move.w  -(A0),-(A1)
ststb:
  btst    #0,D2
  beq.s   ende
  move.b  -(A0),-(A1)

ende:
*)
 CODE(6700H,0106H,0B3C8H,6200H,0082H,3208H);
 CODE(3409H,0B501H,0801H,0000H,672AH,3200H,4441H,0241H);
 CODE(0007H,0D241H,5E80H,0E688H,4EFBH,1002H,12D8H,12D8H);
 CODE(12D8H,12D8H,12D8H,12D8H,12D8H,12D8H,5380H,66ECH);
 CODE(6000H,00CAH,0802H,0000H,6704H,12D8H,5380H,1400H);
 CODE(0E488H,6726H,3200H,4441H,0241H,0007H,0D241H,5E80H);
 CODE(0E688H,4EFBH,1002H,22D8H,22D8H,22D8H,22D8H,22D8H);
 CODE(22D8H,22D8H,22D8H,5380H,66ECH,0802H,0001H,6702H);
 CODE(32D8H,0802H,0000H,6700H,0084H,12D8H,607EH,0D1C0H);
 CODE(0D3C0H,3208H,3409H,0B501H,0801H,0000H,6728H,3200H);
 CODE(4441H,0241H,0007H,0D241H,5E80H,0E688H,4EFBH,1002H);
 CODE(1320H,1320H,1320H,1320H,1320H,1320H,1320H,1320H);
 CODE(5380H,66ECH,6046H,0802H,0000H,6704H,1320H,5380H);
 CODE(1400H,0E488H,6726H,3200H,4441H,0241H,0007H,0D241H);
 CODE(5E80H,0E688H,4EFBH,1002H,2320H,2320H,2320H,2320H);
 CODE(2320H,2320H,2320H,2320H,5380H,66ECH,0802H,0001H);
 CODE(6702H,3320H,0802H,0000H,6702H,1320H);

#if (defined HM2)
(*
  move.w  (SP)+,D2
  movea.l (SP)+,A0
  lea     12(SP),SP
  jmp     (A0)
*)
 CODE(341FH,205FH,4FEFH,000CH,4ED0H);
#elif (defined TDIM2)
(*
  rts
*)
 CODE(4E75H);
#endif
END memmove;
__PROCFRAME_ON__

(*---------------------------------------------------------------------------*)

__PROCFRAME_OFF__
PROCEDURE memset ((* EIN/ -- *) dst : ADDRESS;
                  (* EIN/ -- *) val : int;
                  (* EIN/ -- *) len : sizeT    );

BEGIN
#if (defined HM2)
(*
  move.w  D2,-(SP)
  movea.l 6(SP),A0
#if (defined __LONG_WHOLE__)
  move.w  10+2(SP),D1
  move.l  14(SP),D0
#else
  move.w  10(SP),D1
  move.l  12(SP),D0
#endif
*)
 CODE(3F02H,206FH,0006H);
#if (defined __LONG_WHOLE__)
 CODE(322FH,000CH,202FH,000EH);
#else
 CODE(322FH,000AH,202FH,000CH);
#endif
#elif (defined MM2)
(*
  move.l  -(A3),D0
#if (defined __LONG_WHOLE__)
  move.l  -(A3),D1
#else
  move.w  -(A3),D1
#endif
  movea.l -(A3),A0
  tst.l   D0
*)
 CODE(2023H);
#if (defined __LONG_WHOLE__)
 CODE(2223H);
#else
 CODE(3223H);
#endif
 CODE(2063H,4A80H);
#elif (defined TDIM2)
(*
  movea.l 10(SP),A0
  move.w  8(SP),D1
  move.l  4(SP),D0
*)
 CODE(206FH,000AH,322FH,0008H,202FH,0004H);
#elif (defined LPRM2) || (defined SPCM2)
(*
  movea.l 18(A6),A0
  move.w  16(A6),D1
  move.l  12(A6),D0
*)
 CODE(206EH,0012H,322EH,0010H,202EH,000CH);
#endif

(*
  beq.s   ende           ; B: len = 0, nix zu tun

  move.b  D1,D2
  lsl.w   #8,D2
  move.b  D1,D2
  move.w  D2,D1
  swap    D1
  move.w  D2,D1

  move.w  A0,D2          ; Anfangsadresse ungerade ?
  btst    #0,D2          ;
  beq.s   even           ; B: nein
  move.b  D1,(A0)+       ; sonst ein Byte vorneweg kopieren
  subq.l  #1,D0
even:
  movea.w D0,A1          ; Anzahl der Bytes fuer spaeteren Ueberhangtest merken
  lsr.l   #2,D0          ; Anzahl von Langworten
  beq.s   tstw           ; B: weniger als 4 Byte zu kopieren
  move.w  D0,D2          ; die Anzahl Bytes im letzten unvollstaendigen 32-er-
  neg.w   D2             ; Block und entsprechenden Index in die
  andi.w  #7,D2          ; Kopieranweisungen berechnen
  add.w   D2,D2
  addq.l  #7,D0          ; plus 1 Block, falls unvollst. Block (< 32 Byte)
  lsr.l   #3,D0          ; Anzahl kompletter 32-Byte-Bloecke [+ unvollst. Block]
  jmp     loop32(PC,D2.w) ; ersten kompletten oder unvollst. Block loeschen
loop32:                  ; jeweils 32 Byte loeschen
  move.l  D1,(A0)+
  move.l  D1,(A0)+
  move.l  D1,(A0)+
  move.l  D1,(A0)+
  move.l  D1,(A0)+
  move.l  D1,(A0)+
  move.l  D1,(A0)+
  move.l  D1,(A0)+
  subq.l  #1,D0
  bne.s   loop32         ; naechsten kompletten Block loeschen
tstw:
  move.w  A1,D2
  btst    #1,D2          ; ein zusaetzliches Wort ?
  beq.s   tstb           ; B: nein
  move.w  D1,(A0)+
tstb:
  btst    #0,D2          ; ein zusaetzliches Byte ?
  beq.s   ende           ; B: nein
  move.b  D1,(A0)+
ende:
*)
 CODE(6756H,1401H,0E14AH,1401H,3202H,4841H,3202H,3408H,0802H);
 CODE(0000H,6704H,10C1H,5380H,3240H,0E488H,6726H,3400H);
 CODE(4442H,0242H,0007H,0D442H,5E80H,0E688H,4EFBH,2002H);
 CODE(20C1H,20C1H,20C1H,20C1H,20C1H,20C1H,20C1H,20C1H);
 CODE(5380H,66ECH,3409H,0802H,0001H,6702H,30C1H,0802H);
 CODE(0000H,6702H,10C1H);

#if (defined HM2)
(*
  move.w  (SP)+,D2
  movea.l (SP)+,A0
#if (defined __LONG_WHOLE__)
  lea     12(SP),SP
#else
  lea     10(SP),SP
#endif
  jmp     (A0)
*)
 CODE(341FH,205FH);
#if (defined __LONG_WHOLE__)
 CODE(4FEFH,000CH);
#else
 CODE(4FEFH,000AH);
#endif
 CODE(4ED0H);
#elif (defined TDIM2)
(*
  rts
*)
 CODE(4E75H);
#endif
END memset;
__PROCFRAME_ON__

(*---------------------------------------------------------------------------*)

__PROCFRAME_OFF__
PROCEDURE memchr ((* EIN/ -- *) src : ADDRESS;
                  (* EIN/ -- *) val : int;
                  (* EIN/ -- *) len : sizeT    ): ADDRESS;

BEGIN
#if (defined HM2)
(*
  move.l  D2,-(SP)
  movea.l 8(SP),A0
#if (defined __LONG_WHOLE__)
  move.w  12+2(SP),D1
  move.l  16(SP),D0
#else
  move.w  12(SP),D1
  move.l  14(SP),D0
#endif
*)
 CODE(2F02H,206FH,0008H);
#if (defined __LONG_WHOLE__)
 CODE(322FH,000EH,202FH,0010H);
#else
 CODE(322FH,000CH,202FH,000EH);
#endif
#elif (defined MM2)
(*
  move.l  -(A3),D0
#if (defined __LONG_WHOLE__)
  move.l  -(A3),D1
#else
  move.w  -(A3),D1
#endif
  movea.l -(A3),A0
  tst.l   D0
*)
 CODE(2023H);
#if (defined __LONG_WHOLE__)
 CODE(2223H);
#else
 CODE(3223H);
#endif
 CODE(2063H,4A80H);
#elif (defined TDIM2)
(*
  movea.l 10(SP),A0
  move.w  8(SP),D1
  move.l  4(SP),D0
*)
 CODE(206FH,000AH,322FH,0008H,202FH,0004H);
#elif (defined LPRM2) || (defined SPCM2)
(*
  movea.l 18(A6),A0
  move.w  16(A6),D1
  move.l  12(A6),D0
*)
 CODE(206EH,0012H,322EH,0010H,202EH,000CH);
#endif

(*
  beq.s   ende

  subq.l  #1,D0
  move.l  D0,D2
  swap    D2
lp:
  cmp.b   (A0)+,D1
start:
  dbeq    D0,lp
  dbeq    D2,lp
  beq.s   found
  moveq   #0,D0
  bra.s   ende
found:
  move.l  A0,D0
  subq.l  #1,D0
ende:
*)
 CODE(671AH,5380H,2400H,4842H,0B218H,57C8H,0FFFCH,57CAH);
 CODE(0FFF8H,6704H,7000H,6004H,2008H,5380H);

#if (defined HM2)
 CODE(241FH);       (* move.l  (SP)+,D2 *)
 CODE(205FH);       (* move.l  (SP)+,A0 *)
#if (defined __LONG_WHOLE__)
 CODE(4FEFH,000CH); (* lea     12(SP),SP *)
#else
 CODE(4FEFH,000AH); (* lea     10(SP),SP *)
#endif
 CODE(4ED0H);       (* jmp     (A0) *)
#elif (defined MM2) && (defined __RES_ON_STACK__)
 CODE(26C0H);       (* move.l  D0,(A3)+ *)
#elif (defined LPRM2) || (defined SPCM2)
 CODE(2D40H,0016H); (* move.l  D0,22(A6) *)
 CODE(4E5EH);       (* unlk    A6 *)
 CODE(285FH);       (* movea.l (SP)+,A4 *)
 CODE(205FH);       (* movea.l (SP)+,A0 *)
 CODE(4FEFH,000AH); (* lea     10(SP),SP *)
 CODE(4ED0H);       (* jmp     (A0) *)
#elif (defined TDIM2)
 CODE(2F40H,000EH); (* move.l  D0,14(SP) *)
 CODE(4E75H);       (* rts *)
#endif
END memchr;
__PROCFRAME_ON__

(*---------------------------------------------------------------------------*)

__PROCFRAME_OFF__
PROCEDURE memcmp ((* EIN/ -- *) blk1 : ADDRESS;
                  (* EIN/ -- *) blk2 : ADDRESS;
                  (* EIN/ -- *) len  : sizeT   ): int;

BEGIN
#if (defined HM2)
(*
  move.w  D2,-(SP)
  movea.l 6(SP),A0
  movea.l 10(SP),A1
  move.l  14(SP),D0
*)
 CODE(3F02H,206FH,0006H,226FH,000AH,202FH,000EH);
#elif (defined MM2)
(*
  move.l  -(A3),D0
  movea.l -(A3),A1
  movea.l -(A3),A0
  tst.l   D0
*)
 CODE(2023H,2263H,2063H,4A80H);
#elif (defined TDIM2)
(*
  movea.l 12(SP),A0
  movea.l 8(SP),A1
  move.l  4(SP),D0
*)
 CODE(206FH,000CH,226FH,0008H,202FH,0004H);
#elif (defined LPRM2) || (defined SPCM2)
(*
  movea.l 20(A6),A0
  movea.l 16(A6),A1
  move.l  12(A6),D0
*)
 CODE(206EH,0014H,226EH,0010H,202EH,000CH);
#endif

(*
  beq.s   equal
  move.w  A0,D1
  move.w  A1,D2
  eor.b   D2,D1          ; genau eine der Adressen ungerade ?
  btst    #0,D1          ;
  beq.s   fastcmp        ; B: nein
slowcmp:
  cmpm.b  (A0)+,(A1)+
  bne.s   notequal
  subq.l  #1,D0
  bne.s   slowcmp
  bra.s   equal

fastcmp:
  btst    #0,D2           ; beide Adressen ungerade ?
  beq.s   longcnt         ; B: nein, beide gerade
  cmpm.b  (A0)+,(A1)+     ; sonst ein Byte vergl. -> gerade Adr.
  bne.s   notequal        ; B: schon das erste Byte unterschiedlich
  subq.l  #1, D0          ; sonst ein Byte weniger zu vergleichen
longcnt:
  move.b  D0,D2           ; fuer Ueberhangtest
  lsr.l   #2,D0           ; Anzahl zu vergleichender Langworte
  beq.s   tstwcmp         ; B: weniger als 4 Bytes zu vergleichen
cmplp:
  cmpm.l  (A0)+,(A1)+
  bne.s   notequal
  subq.l  #1,D0
  bne.s   cmplp
tstwcmp:
  btst    #1,D2           ; noch mindestens ein abschliessendes Wort vergl. ?
  beq.s   tstbcmp         ; B: nein
  cmpm.w  (A0)+,(A1)+     ; letztes Wort auch gleich ?
  bne.s   notequal        ; B: nein
tstbcmp:
  btst    #0,D2           ; noch ein abschliessendes Byte vergl. ?
  beq.s   equal           ; B: nein, Bloecke sind gleich
  cmpm.b  (A0)+,(A1)+     ; letztes Byte auch gleich ?
  bne.s   notequal        ; B: nein
equal:
  moveq   #0,D0
  bra.s   ende
notequal:
  bhi.s   less            ; B: blk1 < blk2
  moveq   #1,D0           ; sonst blk1 > blk2
  bra.s   ende
less:
  moveq   #-1,D0
ende:
*)
 CODE(6744H,3208H,3409H,0B501H,0801H,0000H,670AH,0B308H);
 CODE(6638H,5380H,66F8H,602EH,0802H,0000H,6706H,0B308H);
 CODE(6628H,5380H,1400H,0E488H,6708H,0B388H,661CH,5380H);
 CODE(66F8H,0802H,0001H,6704H,0B348H,660EH,0802H,0000H);
 CODE(6704H,0B308H,6604H,7000H,6008H,6204H,7001H,6002H);
 CODE(70FFH);

#if (defined HM2)
 CODE(341FH);       (* move.w  (SP)+,D2 *)
 CODE(205FH);       (* move.l  (SP)+,A0 *)
 CODE(4FEFH,000CH); (* lea     12(SP),SP *)
 CODE(4ED0H);       (* jmp     (A0) *)
#elif (defined MM2)
#ifdef __RES_ON_STACK__
#ifdef __LONG_WHOLE__
 CODE(26C0H);       (* move.l  D0,(A3)+ *)
#else
 CODE(36C0H);       (* move.w  D0,(A3)+ *)
#endif
#endif
#elif (defined LPRM2) || (defined SPCM2)
 CODE(3D40H,0018H); (* move.w  D0,24(A6) *)
 CODE(4E5EH);       (* unlk    A6 *)
 CODE(285FH);       (* movea.l (SP)+,A4 *)
 CODE(205FH);       (* movea.l (SP)+,A0 *)
 CODE(4FEFH,000CH); (* lea     12(SP),SP *)
 CODE(4ED0H);       (* jmp     (A0) *)
#elif (defined TDIM2)
 CODE(3F40H,0010H); (* move.w  D0,16(SP) *)
 CODE(4E75H);       (* rts *)
#endif
END memcmp;
__PROCFRAME_ON__

(*---------------------------------------------------------------------------*)

#if (defined LPRM2) || (defined SPCM2)
PROCEDURE memalloc ((* EIN/ -- *)     size : sizeT;
                    (* -- /AUS *) VAR old  : ADDRESS;
                    (* -- /AUS *) VAR adr  : ADDRESS );

BEGIN
(*
  movea.l (SP)+,A6      ; A6 -> lokale Variablen des Aufrufers
  movea.l (SP)+,A4      ; A4 -> globale Variablen des Aufrufers
  movea.l (SP)+,A1      ; A1 := RTN-Adresse
  movea.l (SP)+,A2      ; A2 -> <adr>
  movea.l (SP)+,A0      ; A0 -> <old>
  move.l  (SP)+,D0      ; D0 := <size>
  move.l  SP,(A0)       ; <old> := Stackpointer vor Aufruf der Funktion
  addq.l  #1,D0         ; <size> auf gerade Anzahl aufrunden
  bclr    #0,D0         ;
  suba.l  D0,SP         ; Neuer Stackpointer
  move.l  SP,(A2)       ; <adr> := Neuer Stackpointer
  jmp     (A1)          ; RETURN
*)
 CODE(2C5FH,285FH,225FH,245FH,205FH,201FH,208FH,5280H);
 CODE(0880H,0000H,9FC0H,248FH,4ED1H);
END memalloc;

(*---------------------------------------------------------------------------*)

PROCEDURE memdealloc ((* EIN/ -- *) old : ADDRESS );
BEGIN
(*
  movea.l (SP)+,A6      ; A6 -> lokale Variablen des Aufrufers
  movea.l (SP)+,A4      ; A4 -> globale Variablen des Aufrufers
  movea.l (SP)+,A1      ; A1 := RTN-Adresse
  movea.l (SP),SP       ; Stack setzen
  jmp     (A1)          ; RETURN
*)
 CODE(2C5FH,285FH,225FH,2E57H,4ED1H);
END memdealloc;

#elif (defined TDIM2)

__PROCFRAME_OFF__
PROCEDURE memalloc ((* EIN/ -- *)     size : sizeT;
                    (* -- /AUS *) VAR old  : ADDRESS;
                    (* -- /AUS *) VAR adr  : ADDRESS );

BEGIN
(*
  movea.l (SP)+,A1         ; A1 := RTN-Adresse
  movea.l (SP)+,A2         ; A2 -> <adr>
  movea.l (SP)+,A0         ; A0 -> <old>
  move.l  (SP)+,D0         ; D0 := <size>
  move.l  SP,(A0)          ; <old> := Stackpointer vor Aufruf der Funktion
  addq.l  #1,D0            ; <size> auf gerade Anzahl aufrunden
  bclr    #0,D0            ;
  suba.l  D0,SP            ; Neuer Stackpointer
  move.l  SP,(A2)          ; <adr> := Neuer Stackpointer
  lea     -12(SP),SP       ; fuer Parameterkorrektur vom Aufrufer
  jmp     (A1)             ; RETURN
*)
 CODE(225FH,245FH,205FH,201FH,208FH,5280H,0880H,0000H);
 CODE(9FC0H,248FH,4FEFH,0FFF4H,4ED1H);
END memalloc;
__PROCFRAME_ON__
(*---------------------------------------------------------------------------*)
__PROCFRAME_OFF__
PROCEDURE memdealloc ((* EIN/ -- *) old : ADDRESS );
BEGIN
(*
  movea.l (SP)+,A1         ; A1 := RTN-Adresse
  movea.l (SP),SP          ; Stackpointer setzen
  subq.l  #4,SP            ; fuer Parameterkorrektur vom Aufrufer
  jmp     (A1)             ; RETURN
*)
 CODE(225FH,2E57H,598FH,4ED1H);
END memdealloc;
__PROCFRAME_ON__

#elif (defined HM2)

__PROCFRAME_OFF__
PROCEDURE memalloc ((* EIN/ -- *)     size : sizeT;
                    (* -- /AUS *) VAR old  : ADDRESS;
                    (* -- /AUS *) VAR adr  : ADDRESS );

BEGIN
(*
  movea.l (SP)+,A1         ; A1 := RTN-Adresse
  move.l  (SP)+,D0         ; D0 := <size>
  movea.l (SP)+,A0         ; A0 -> <old>
  move.l  (SP)+,D1         ; D1 -> <adr>
  move.l  SP,(A0)          ; <old> := Stackpointer vor Aufruf der Funktion
  addq.l  #1,D0            ; <size> auf gerade Anzahl aufrunden
  bclr    #0,D0            ;
  suba.l  D0,SP            ; Neuer Stackpointer
  movea.l D1,A0            ; <adr> := Neuer Stackpointer
  move.l  SP,(A0)          ;
  jmp     (A1)             ; RETURN
*)
 CODE(225FH,201FH,205FH,221FH,208FH,5280H,0880H,0000H);
 CODE(9FC0H,2041H,208FH,4ED1H);
END memalloc;
__PROCFRAME_ON__
(*---------------------------------------------------------------------------*)
__PROCFRAME_OFF__
PROCEDURE memdealloc ((* EIN/ -- *) old : ADDRESS );
BEGIN
(*
  movea.l (SP)+,A1         ; A1 := RTN-Adresse
  movea.l (SP),SP          ; Stackpointer setzen
  jmp     (A1)             ; RETURN
*)
 CODE(225FH,2E57H,4ED1H);
END memdealloc;
__PROCFRAME_ON__

#elif (defined MM2)

__PROCFRAME_OFF__
PROCEDURE memalloc ((* EIN/ -- *)     size : sizeT;
                    (* -- /AUS *) VAR old  : ADDRESS;
                    (* -- /AUS *) VAR adr  : ADDRESS );

BEGIN
 ASSEMBLER
   MOVEA.L -(A3),A2        ; A2 -> <adr>
   MOVEA.L -(A3),A0        ; A0 -> <old>
   MOVE.L  -(A3),D0        ; D0 := <size>
   MOVEA.L (A7)+,A1        ; A1 := RTN-Adresse
   MOVE.L  A7,(A0)         ; <old> := Stackpointer vor Aufruf der Funktion
   ADDQ.L  #1,D0           ; <size> auf gerade Anzahl aufrunden
   BCLR    #0,D0           ;
   SUBA.L  D0,A7           ; Neuer Stackpointer
   MOVE.L  A7,(A2)         ; <adr> := Neuer Stackpointer
   JMP     (A1)            ; RETURN
 END;
END memalloc;
__PROCFRAME_ON__

(*---------------------------------------------------------------------------*)

__PROCFRAME_OFF__
PROCEDURE memdealloc ((* EIN/ -- *) old : ADDRESS );
BEGIN
 ASSEMBLER
   MOVEA.L (A7)+,A1        ; A1 := RTN-Adresse
   MOVEA.L -(A3),A7        ; Stackpointer setzen
   JMP     (A1)            ; RETURN
 END;
END memdealloc;
__PROCFRAME_ON__
#endif

END MEMBLK.
