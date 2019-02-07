IMPLEMENTATION MODULE blk;
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
(* 04-Dez-95, Holger Kleinschmidt                                            *)
(*****************************************************************************)

INLINE_CODE_IMPORT
VAL_INTRINSIC

FROM SYSTEM IMPORT
(* TYPE *) ADDRESS;

FROM PORTAB IMPORT
(* TYPE *) UNSIGNEDLONG;

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
  move.l  D2,-(SP)
  movea.l 8(SP),A0
  movea.l 12(SP),A1
  move.l  16(SP),D0
*)
 CODE(2F02H,206FH,0008H,226FH,000CH,202FH,0010H);
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
; A0: Adresse1
; A1: Adresse2
; D0: Anzahl

  beq     ende           ; B: len = 0, nix zu tun
  move.w  A0,D1
  move.w  A1,D2
  eor.b   D2,D1          ; genau eine der Adressen ungerade ?
  btst    #0,D1          ;
  beq.s   fastswap       ; B: nein, es kann schnell getauscht werden

  move.w  D0,D1          ; die Anzahl Bytes im unvollstaendigen 4-er-
  neg.w   D1             ; Block und entsprechenden Index in die
  andi.w  #3,D1          ; Kopieranweisungen berechnen
  add.w   D1,D1          ; * 6
  move.w  D1,D2          ;
  add.w   D1,D1          ;
  add.w   D2,D1          ;
  addq.l  #3,D0          ; + 1 Block, falls unvollst. Block (d0 MOD 4 # 0)
  lsr.l   #2,D0          ; Anzahl kompletter 4-er Bloecke [+ unvollst. Block]
  jmp     sloop4(PC,D1.w) ; ersten vollst. oder unvollst. Block tauschen
sloop4:                  ; jeweils 4 Bytes tauschen
  move.b  (A0),D1
  move.b  (A1),(A0)+
  move.b  D1,(A1)+
  move.b  (A0),D1
  move.b  (A1),(A0)+
  move.b  D1,(A1)+
  move.b  (A0),D1
  move.b  (A1),(A0)+
  move.b  D1,(A1)+
  move.b  (A0),D1
  move.b  (A1),(A0)+
  move.b  D1,(A1)+
  subq.l  #1,D0
  bne.s   sloop4
  bra.s   ende           ; fertig

fastswap:
  btst    #0,D2          ; beide Adr. ungerade oder beide gerade ?
  beq.s   tst16          ; B: beide gerade
  move.b  (A0),D1        ; sonst ein Byte vorneweg tauschen
  move.b  (A1),(A0)+     ; -> gerade Adresse
  move.b  D1,(A1)+
  subq.l  #1,D0          ; eins weniger zu tauschen
tst16:
  move.w  D0,D2          ; fuer spaeteren Ueberhangtest
  lsr.l   #2,D0          ; Anzahl auszutauschender Langworte
  beq.s   tst2           ; B: weniger als 4 Bytes
  swap    D2             ; D2 retten
  move.w  D0,D1          ; die Anzahl Bytes im unvollstaendigen 16-er-
  neg.w   D1             ; Block und entsprechenden Index in die
  andi.w  #3,D1          ; Kopieranweisungen berechnen
  add.w   D1,D1          ; * 6
  move.w  D1,D2          ;
  add.w   D1,D1          ;
  add.w   D2,D1          ;
  swap    D2
  addq.l  #3,D0          ; + 1 Block, falls unvollst. Block (d0 MOD 4 # 0)
  lsr.l   #2,D0          ; Anzahl kompletter 16-er Bloecke [+ unvollst. Block]
  jmp     floop16(PC,D1.w) ; ersten vollst. oder unvollst. Block tauschen

* Hier laesst sich durch den Einsatz von MOVEM-Befehlen
* nichts beschleunigen
floop16:                 ; jeweils 16 Bytes tauschen
  move.l  (A0),D1
  move.l  (A1),(A0)+
  move.l  D1,(A1)+
  move.l  (A0),D1
  move.l  (A1),(A0)+
  move.l  D1,(A1)+
  move.l  (A0),D1
  move.l  (A1),(A0)+
  move.l  D1,(A1)+
  move.l  (A0),D1
  move.l  (A1),(A0)+
  move.l  D1,(A1)+
  subq.l  #1,D0
  bne.s   floop16

tst2:
  btst    #1,D2          ; noch ein zusaetzl. Wort auszutauschen ?
  beq.s   tst1           ; B: nein
  move.w  (A0),D1
  move.w  (A1),(A0)+
  move.w  D1,(A1)+
tst1:
  btst    #0,D2          ; noch ein Byte ?
  beq.s   ende           ; B: nein, fertig
  move.b  (A0),D1
  move.b  (A1),(A0)
  move.b  D1,(A1)
ende:
*)
 CODE(6700H,00A8H,3208H,3409H,0B501H,0801H,0000H,6736H);
 CODE(3200H,4441H,0241H,0003H,0D241H,3401H,0D241H,0D242H);
 CODE(5680H,0E488H,4EFBH,1002H,1210H,10D1H,12C1H,1210H);
 CODE(10D1H,12C1H,1210H,10D1H,12C1H,1210H,10D1H,12C1H);
 CODE(5380H,66E4H,6064H,0802H,0000H,6708H,1210H,10D1H);
 CODE(12C1H,5380H,3400H,0E488H,6738H,4842H,3200H,4441H);
 CODE(0241H,0003H,0D241H,3401H,0D241H,0D242H,4842H,5680H);
 CODE(0E488H,4EFBH,1002H,2210H,20D1H,22C1H,2210H,20D1H);
 CODE(22C1H,2210H,20D1H,22C1H,2210H,20D1H,22C1H,5380H);
 CODE(66E4H,0802H,0001H,6706H,3210H,30D1H,32C1H,0802H);
 CODE(0000H,6706H,1210H,1091H,1281H);
#if (defined HM2)
(*
  move.l  (SP)+,D2
  movea.l (SP)+,A0
  lea     12(SP),SP
  jmp     (A0)
*)
 CODE(241FH,205FH,4FEFH,000CH,4ED0H);
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
  move.l  D2,-(SP)
  movea.l 12(SP),A0
  movea.l 8(SP),A1
  move.l  16(SP),D0
*)
 CODE(2F02H,206FH,000CH,226FH,0008H,202FH,0010H);
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
; A0: Quelladresse
; A1: Zieladresse
; D0: Laenge

  beq     ende           ; B: len = 0, nix zu tun
  cmpa.l  A0,A1          ; Zieladresse groesser als Quelladresse ?
  bhi     special        ; B: ja, muss von hinten nach vorne kopiert werden,
; falls sich die Bereiche ueberschneiden
  move.w  A0,D1          ; genau eine Adresse ungerade ?
  move.w  A1,D2          ;
  eor.b   D2,D1          ;
  btst    #0,D1          ;
  beq.s   nfastcpy       ; B: nein, beide gerade/ungerade -> schnell kopieren

* Es muss langsam byteweise kopiert werden.
* Der Trick mit dem Sprung in die Kopieranweisungen stammt aus
* dem "bcopy()" der GnuLib/MiNTLib

  move.w  D0,D1          ; die Anzahl Bytes im unvollstaendigen 8-er-
  neg.w   D1             ; Block und entsprechenden Index in die
  andi.w  #7,D1          ; Kopieranweisungen berechnen
  add.w   D1,D1          ; * 2
  addq.l  #7,D0          ; + 1 Block, falls unvollst. Block (d0 MOD 8 # 0)
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
  beq.s   ntst256        ; B: nein
  move.b  (A0)+,(A1)+    ; ein Byte vorneweg -> gerade Adressen
  subq.l  #1,D0          ; ein Byte weniger zu kopieren
ntst256:
  move.b  D0,D1          ; Anzahl der Bytes < 256 merken
  lsr.l   #8,D0          ; Anzahl zu kopierender 256-Bytes-Bloecke
  beq.s   ntst32         ; B: weniger als 256 Bytes
  movem.l D3-D7/A2-A6,-(SP)
nloop256:                ; jeweils 256 Bytes kopieren
  movem.l (A0)+,D2-D7/A2-A6
  movem.l D2-D7/A2-A6,(A1)
  movem.l (A0)+,D2-D7/A2-A6
  movem.l D2-D7/A2-A6,44(A1)
  movem.l (A0)+,D2-D7/A2-A6
  movem.l D2-D7/A2-A6,88(A1)
  movem.l (A0)+,D2-D7/A2-A6
  movem.l D2-D7/A2-A6,132(A1)
  movem.l (A0)+,D2-D7/A2-A6
  movem.l D2-D7/A2-A6,176(A1)
  movem.l (A0)+,D2-D7/A2-A4
  movem.l D2-D7/A2-A4,220(A1)
  lea     256(A1),A1
  subq.l  #1,D0
  bne.s   nloop256
  movem.l (SP)+,D3-D7/A2-A6

ntst32:
  move.b  D1,D0          ; D0 ist Null, deswegen automatisch Wortgroesse
  lsr.w   #2,D0          ; Anzahl zu kopierender Langworte
  beq.s   ntst2          ; B: weniger als 4 Byte
  move.w  D0,D2          ; die Anzahl Bytes im unvollstaendigen 32-er-
  neg.w   D2             ; Block und entsprechenden Index in die
  andi.w  #7,D2          ; Kopieranweisungen berechnen
  add.w   D2,D2          ; * 2
  subq.l  #1,D0          ; - 1 Block, falls kein unvollst. Block (d0 MOD 8 = 0)
  lsr.w   #3,D0          ; Anzahl von 32-er-Bloecken [- unvollst Block]
  jmp     nloop32(PC,D2.w) ; ersten vollst. oder unvollst. Block kopieren
nloop32:                 ; jeweils 32 Byte kopieren
  move.l  (A0)+,(A1)+
  move.l  (A0)+,(A1)+
  move.l  (A0)+,(A1)+
  move.l  (A0)+,(A1)+
  move.l  (A0)+,(A1)+
  move.l  (A0)+,(A1)+
  move.l  (A0)+,(A1)+
  move.l  (A0)+,(A1)+
  dbra    D0,nloop32
ntst2:
  btst    #1,D1          ; ein zusaetzliches Wort ?
  beq.s   ntst1          ; B: nein
  move.w  (A0)+,(A1)+
ntst1:
  btst    #0,D1          ; ein zusaetzliches Byte ?
  beq     ende           ; B: nein, fertig
  move.b  (A0)+,(A1)+
  bra     ende

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
  bra     ende

sfastcpy:
  btst    #0,D2
  beq.s   stst256
  move.b  -(A0),-(A1)
  subq.l  #1,D0
stst256:
  move.b  D0,D1
  lsr.l   #8,D0
  beq.s   stst32
  movem.l D3-D7/A2-A6,-(SP)
sloop256:
  movem.l -44(A0),D2-D7/A2-A6
  movem.l D2-D7/A2-A6,-(A1)
  movem.l -88(A0),D2-D7/A2-A6
  movem.l D2-D7/A2-A6,-(A1)
  movem.l -132(A0),D2-D7/A2-A6
  movem.l D2-D7/A2-A6,-(A1)
  movem.l -176(A0),D2-D7/A2-A6
  movem.l D2-D7/A2-A6,-(A1)
  movem.l -220(A0),D2-D7/A2-A6
  movem.l D2-D7/A2-A6,-(A1)
  movem.l -256(A0),D2-D7/A2-A4
  movem.l D2-D7/A2-A4,-(A1)
  lea     -256(A0),A0
  subq.l  #1,D0
  bne.s   sloop256
  movem.l (SP)+,D3-D7/A2-A6

stst32:
  move.b  D1,D0
  lsr.w   #2,D0
  beq.s   stst2
  move.w  D0,D2
  neg.w   D2
  andi.w  #7,D2
  add.w   D2,D2
  subq.l  #1,D0
  lsr.w   #3,D0
  jmp     sloop32(PC,D2.w)
sloop32:
  move.l  -(A0),-(A1)
  move.l  -(A0),-(A1)
  move.l  -(A0),-(A1)
  move.l  -(A0),-(A1)
  move.l  -(A0),-(A1)
  move.l  -(A0),-(A1)
  move.l  -(A0),-(A1)
  move.l  -(A0),-(A1)
  dbra    D0,sloop32
stst2:
  btst    #1,D1
  beq.s   stst1
  move.w  -(A0),-(A1)
stst1:
  btst    #0,D1
  beq.s   ende
  move.b  -(A0),-(A1)

ende:
*)
 CODE(6700H,01ACH,0B3C8H,6200H,00D4H,3208H,3409H,0B501H);
 CODE(0801H,0000H,672AH,3200H,4441H,0241H,0007H,0D241H);
 CODE(5E80H,0E688H,4EFBH,1002H,12D8H,12D8H,12D8H,12D8H);
 CODE(12D8H,12D8H,12D8H,12D8H,5380H,66ECH,6000H,0170H);
 CODE(0802H,0000H,6704H,12D8H,5380H,1200H,0E088H,674AH);
 CODE(48E7H,1F3EH,4CD8H,7CFCH,48D1H,7CFCH,4CD8H,7CFCH);
 CODE(48E9H,7CFCH,002CH,4CD8H,7CFCH,48E9H,7CFCH,0058H);
 CODE(4CD8H,7CFCH,48E9H,7CFCH,0084H,4CD8H,7CFCH,48E9H);
 CODE(7CFCH,00B0H,4CD8H,1CFCH,48E9H,1CFCH,00DCH,43E9H);
 CODE(0100H,5380H,66BEH,4CDFH,7CF8H,1001H,0E448H,6726H);
 CODE(3400H,4442H,0242H,0007H,0D442H,5380H,0E648H,4EFBH);
 CODE(2002H,22D8H,22D8H,22D8H,22D8H,22D8H,22D8H,22D8H);
 CODE(22D8H,51C8H,0FFEEH,0801H,0001H,6702H,32D8H,0801H);
 CODE(0000H,6700H,00DAH,12D8H,6000H,00D4H,0D1C0H,0D3C0H);
 CODE(3208H,3409H,0B501H,0801H,0000H,672AH,3200H,4441H);
 CODE(0241H,0007H,0D241H,5E80H,0E688H,4EFBH,1002H,1320H);
 CODE(1320H,1320H,1320H,1320H,1320H,1320H,1320H,5380H);
 CODE(66ECH,6000H,009AH,0802H,0000H,6704H,1320H,5380H);
 CODE(1200H,0E088H,674CH,48E7H,1F3EH,4CE8H,7CFCH,0FFD4H);
 CODE(48E1H,3F3EH,4CE8H,7CFCH,0FFA8H,48E1H,3F3EH,4CE8H);
 CODE(7CFCH,0FF7CH,48E1H,3F3EH,4CE8H,7CFCH,0FF50H,48E1H);
 CODE(3F3EH,4CE8H,7CFCH,0FF24H,48E1H,3F3EH,4CE8H,1CFCH);
 CODE(0FF00H,48E1H,3F38H,41E8H,0FF00H,5380H,66BCH,4CDFH);
 CODE(7CF8H,1001H,0E448H,6726H,3400H,4442H,0242H,0007H);
 CODE(0D442H,5380H,0E648H,4EFBH,2002H,2320H,2320H,2320H);
 CODE(2320H,2320H,2320H,2320H,2320H,51C8H,0FFEEH,0801H);
 CODE(0001H,6702H,3320H,0801H,0000H,6702H,1320H);
#if (defined HM2)
(*
  move.l  (SP)+,D2
  movea.l (SP)+,A0
  lea     12(SP),SP
  jmp     (A0)
*)
 CODE(241FH,205FH,4FEFH,000CH,4ED0H);
#elif (defined TDIM2)
(*
  rts
*)
 CODE(4E75H);
#endif
END memmove;
__PROCFRAME_ON__

(*---------------------------------------------------------------------------*)

PROCEDURE bcopy ((* EIN/ -- *) src : ADDRESS;
                 (* EIN/ -- *) dst : ADDRESS;
                 (* EIN/ -- *) len : sizeT   );
BEGIN
 memmove(dst, src, len);
END bcopy;

(*---------------------------------------------------------------------------*)

__PROCFRAME_OFF__
PROCEDURE memset ((* EIN/ -- *) dst : ADDRESS;
                  (* EIN/ -- *) val : int;
                  (* EIN/ -- *) len : sizeT    );

BEGIN
#if (defined HM2)
(*
  move.l  D2,-(SP)       ; benutztes Register retten
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
; A0: Startadresse
; D0: Anzahl
; D1: Muster

  beq     ende           ; B: len = 0, nix zu tun

  move.b  D1,D2          ; Muster auf alle vier Bytes in D1 verteilen
  lsl.w   #8,D2          ;
  move.b  D1,D2          ;
  move.w  D2,D1          ;
  swap    D1             ;
  move.w  D2,D1          ;

  move.w  A0,D2          ; Anfangsadresse ungerade ?
  btst    #0,D2          ;
  beq.s   tst256         ; B: nein
  move.b  D1,(A0)+       ; sonst ein Byte vorneweg kopieren
  subq.l  #1,D0

tst256:
  move.b  D0,D2          ; Anzahl der Bytes < 256 merken
  lsr.l   #8,D0          ; Anzahl der 256-Bytes-Bloecke
  beq.s   tst32          ; B: weniger als 256 Bytes

  movem.l D2-D7/A2-A6,-(SP)
  move.l  D1,D2
  move.l  D1,D3
  move.l  D1,D4
  move.l  D1,D5
  move.l  D1,D6
  move.l  D1,D7
  movea.l D1,A1
  movea.l D1,A2
  movea.l D1,A3
  movea.l D1,A4
  movea.l D1,A5
  movea.l D1,A6

loop256:
  movem.l D1-D7/A1-A6,(A0)
  movem.l D1-D7/A1-A6,52(A0)
  movem.l D1-D7/A1-A6,104(A0)
  movem.l D1-D7/A1-A6,156(A0)
  movem.l D1-D7/A1-A5,208(A0)
  lea     256(A0),A0
  subq.l  #1,D0
  bne.s   loop256

  movem.l (SP)+,D2-D7/A2-A6

tst32:
  move.b  D2,D0          ; D0 ist Null, deswegen automatisch Wortgroesse
  movea.w D0,A1          ; Anzahl der Bytes fuer spaeteren Ueberhangtest merken
  lsr.w   #2,D0          ; Anzahl von Langworten
  beq.s   tst2           ; B: weniger als 4 Bytes zu kopieren
  move.w  D0,D2          ; die Anzahl Bytes im unvollstaendigen 32-er-
  neg.w   D2             ; Block und entsprechenden Index in die
  andi.w  #7,D2          ; Kopieranweisungen berechnen
  add.w   D2,D2          ; * 2
  subq.w  #1,D0          ; - 1 Block, falls kein unvollst. Block (d0 MOD 8 = 0)
  lsr.w   #3,D0          ; Anzahl kompletter 32-Byte-Bloecke [+ unvollst. Block]
  jmp     loop32(PC,D2.w) ; ersten kompletten oder unvollst. Block fuellen
loop32:                  ; jeweils 32 Byte fuellen
  move.l  D1,(A0)+
  move.l  D1,(A0)+
  move.l  D1,(A0)+
  move.l  D1,(A0)+
  move.l  D1,(A0)+
  move.l  D1,(A0)+
  move.l  D1,(A0)+
  move.l  D1,(A0)+
  dbra    D0,loop32      ; naechsten kompletten Block fuellen
tst2:
  move.w  A1,D2
  btst    #1,D2          ; ein zusaetzliches Wort ?
  beq.s   tst1           ; B: nein
  move.w  D1,(A0)+
tst1:
  btst    #0,D2          ; ein zusaetzliches Byte ?
  beq.s   ende           ; B: nein
  move.b  D1,(A0)+
ende:
*)
 CODE(6700H,00A4H,1401H,0E14AH,1401H,3202H,4841H,3202H);
 CODE(3408H,0802H,0000H,6704H,10C1H,5380H,1400H,0E088H);
 CODE(6744H,48E7H,3F3EH,2401H,2601H,2801H,2A01H,2C01H);
 CODE(2E01H,2241H,2441H,2641H,2841H,2A41H,2C41H,48D0H);
 CODE(7EFEH,48E8H,7EFEH,0034H,48E8H,7EFEH,0068H,48E8H);
 CODE(7EFEH,009CH,48E8H,3EFEH,00D0H,41E8H,0100H,5380H);
 CODE(66DCH,4CDFH,7CFCH,1002H,3240H,0E448H,6726H,3400H);
 CODE(4442H,0242H,0007H,0D442H,5340H,0E648H,4EFBH,2002H);
 CODE(20C1H,20C1H,20C1H,20C1H,20C1H,20C1H,20C1H,20C1H);
 CODE(51C8H,0FFEEH,3409H,0802H,0001H,6702H,30C1H,0802H);
 CODE(0000H,6702H,10C1H);
#if (defined HM2)
(*
  move.l  (SP)+,D2
  movea.l (SP)+,A0
#if (defined __LONG_WHOLE__)
  lea     12(SP),SP
#else
  lea     10(SP),SP
#endif
  jmp     (A0)
*)
 CODE(241FH,205FH);
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
PROCEDURE memfill ((* EIN/ -- *) dst : ADDRESS;
                   (* EIN/ -- *) val : UNSIGNEDLONG;
                   (* EIN/ -- *) len : sizeT        );

BEGIN
#if (defined HM2)
(*
  move.l  D2,-(SP)       ; benutztes Register retten
  movea.l 8(SP),A0
  move.l  12(SP),D1
  move.l  16(SP),D0
*)
 CODE(2F02H,206FH,0008H,222FH,000CH,202FH,0010H);
#elif (defined MM2)
(*
  move.l  -(A3),D0
  move.l  -(A3),D1
  movea.l -(A3),A0
  tst.l   D0
*)
 CODE(2023H,2223H,2063H,4A80H);
#elif (defined TDIM2)
(*
  movea.l 12(SP),A0
  move.l  8(SP),D1
  move.l  4(SP),D0
*)
 CODE(206FH,000CH,222FH,0008H,202FH,0004H);
#elif (defined LPRM2) || (defined SPCM2)
(*
  movea.l 20(A6),A0
  move.l  16(A6),D1
  move.l  12(A6),D0
*)
 CODE(206EH,0014H,222EH,0010H,202EH,000CH);
#endif

(*
; A0: Startadresse
; D0: Anzahl
; D1: Muster

  beq     ende           ; B: len = 0, nix zu tun

  move.w  A0,D2          ; Anfangsadresse ungerade ?
  btst    #0,D2          ;
  beq.s   tst256         ; B: nein
  rol.l   #8,D1          ; es soll ja mit dem hoechstwertigen Byte
; des Musters begonnen werden, damit gibt es
; auch ein kontinuierliches Muster beginnend
; mit einer ungeraden Adr. (die drei folgenden
; Bytes ruecken bei dem ROTATE-Befehl entsprechend
; auf, und das erste Byte folgt wieder dahinter)
  move.b  D1,(A0)+       ; sonst ein Byte vorneweg kopieren
  subq.l  #1,D0

tst256:
  move.b  D0,D2          ; Anzahl der Bytes < 256 merken
  lsr.l   #8,D0          ; Anzahl der 256-Bytes-Bloecke
  beq.s   tst32          ; B: weniger als 256 Bytes

  movem.l D2-D7/A2-A6,-(SP)
  move.l  D1,D2
  move.l  D1,D3
  move.l  D1,D4
  move.l  D1,D5
  move.l  D1,D6
  move.l  D1,D7
  movea.l D1,A1
  movea.l D1,A2
  movea.l D1,A3
  movea.l D1,A4
  movea.l D1,A5
  movea.l D1,A6

loop256:
  movem.l D1-D7/A1-A6,(A0)
  movem.l D1-D7/A1-A6,52(A0)
  movem.l D1-D7/A1-A6,104(A0)
  movem.l D1-D7/A1-A6,156(A0)
  movem.l D1-D7/A1-A5,208(A0)
  lea     256(A0),A0
  subq.l  #1,D0
  bne.s   loop256

  movem.l (SP)+,D2-D7/A2-A6

tst32:
  move.b  D2,D0          ; D0 ist Null, deswegen automatisch Wortgroesse
  movea.w D0,A1          ; Anzahl der Bytes fuer spaeteren Ueberhangtest merken
  lsr.w   #2,D0          ; Anzahl von Langworten
  beq.s   tst2           ; B: weniger als 4 Byte zu kopieren
  move.w  D0,D2          ; die Anzahl Bytes im unvollstaendigen 32-er-
  neg.w   D2             ; Block und entsprechenden Index in die
  andi.w  #7,D2          ; Kopieranweisungen berechnen
  add.w   D2,D2          ; * 2
  subq.w  #1,D0          ; - 1 Block, falls kein unvollst. Block (d0 MOD 8 = 0)
  lsr.w   #3,D0          ; Anzahl kompletter 32-Byte-Bloecke [+ unvollst. Block]
  jmp     loop32(PC,D2.w) ; ersten kompletten oder unvollst. Block fuellen
loop32:                  ; jeweils 32 Byte fuellen
  move.l  D1,(A0)+
  move.l  D1,(A0)+

  move.l  D1,(A0)+
  move.l  D1,(A0)+
  move.l  D1,(A0)+
  move.l  D1,(A0)+
  move.l  D1,(A0)+
  move.l  D1,(A0)+
  dbra    D0,loop32      ; naechsten kompletten Block fuellen
tst2:
  move.w  A1,D2
  btst    #1,D2          ; ein zusaetzliches Wort ?
  beq.s   tst1           ; B: nein
  swap    D1             ; die ersten zwei Byte des Musters schreiben
  move.w  D1,(A0)+       ;   und die naechsten zwei ins obere Wort
tst1:
  btst    #0,D2          ; ein zusaetzliches Byte ?
  beq.s   ende           ; B: nein
  rol.l   #8,D1          ; damit ist das auf das letzte bisher geschriebene
; Byte des Musters folgende im unteren Byte des
; Registers
  move.b  D1,(A0)
ende:
*)
 CODE(6700H,009EH,3408H,0802H,0000H,6706H,0E199H,10C1H);
 CODE(5380H,1400H,0E088H,6744H,48E7H,3F3EH,2401H,2601H);
 CODE(2801H,2A01H,2C01H,2E01H,2241H,2441H,2641H,2841H);
 CODE(2A41H,2C41H,48D0H,7EFEH,48E8H,7EFEH,0034H,48E8H);
 CODE(7EFEH,0068H,48E8H,7EFEH,009CH,48E8H,3EFEH,00D0H);
 CODE(41E8H,0100H,5380H,66DCH,4CDFH,7CFCH,1002H,3240H);
 CODE(0E448H,6726H,3400H,4442H,0242H,0007H,0D442H,5340H);
 CODE(0E648H,4EFBH,2002H,20C1H,20C1H,20C1H,20C1H,20C1H);
 CODE(20C1H,20C1H,20C1H,51C8H,0FFEEH,3409H,0802H,0001H);
 CODE(6704H,4841H,30C1H,0802H,0000H,6704H,0E199H,1081H);
#if (defined HM2)
(*
  move.l  (SP)+,D2
  movea.l (SP)+,A0
  lea     12(SP),SP
  jmp     (A0)
*)
 CODE(241FH,205FH,4FEFH,000CH,4ED0H);
#elif (defined TDIM2)
(*
  rts
*)
 CODE(4E75H);
#endif
END memfill;
__PROCFRAME_ON__

(*---------------------------------------------------------------------------*)

PROCEDURE bzero ((* EIN/ -- *) dst : ADDRESS;
                 (* EIN/ -- *) len : sizeT   );
BEGIN
 memfill(dst, VAL(UNSIGNEDLONG,0), len);
END bzero;

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
 CODE(205FH);       (* movea.l (SP)+,A0 *)
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
 CODE(205FH);       (* movea.l (SP)+,A0 *)
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

END blk.
