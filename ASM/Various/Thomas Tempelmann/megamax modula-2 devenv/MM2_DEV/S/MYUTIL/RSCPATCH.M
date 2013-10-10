MODULE RSCPatch;

(*
 * Erstellt mit Megamax Modula-2 Version 2.2
 *
 *)

(*$M- No symbols (procedure names) *)
(*$L- No procedure entry code *)
(*$N+ No runtime module needed *)

FROM SYSTEM IMPORT ASSEMBLER, ADDRESS, BYTE, WORD;


CONST SFOfs = 2;  (* = 2, wenn CPU mit Stackframe verwendet wird! *)

      GemRscPtr = $7002;      (* aes' ptr to rsc buffer *)

TYPE  FileHeader = RECORD
        ident: ARRAY [0..15] OF CHAR; (* "MM2/RscPatch"+CR+LF+EOF *)
        version: BYTE;     (* = 1 *)
        revision: BYTE;    (* = 0 *)
        rscOffs: LONGCARD; (* = 36 *)
        reserved: ARRAY [1..3] OF LONGCARD;
        conf: WORD;
      END;


CONST (* GEMDOS functions *)
      PtermRes  = $31;
      PrintLine = $09;
      Fopen     = $3D;
      Fclose    = $3E;
      Fseek     = $42;
      Fread     = $3F;

      (* XBIOS functions *)
      Supexec   = $26;

      (* base page constants *)
      codestart = 8;
      codelen   = 12;
      datastart = 16;
      datalen   = 20;
      bssstart  = 24;
      bsslen    = 28;
      parent    = 36;

VAR   tosHeader: ARRAY [1..$18] OF WORD; (* Kopie des TOS-Headers *)
      bufAddr: ADDRESS;
      bufSize: LONGCARD;


PROCEDURE hdlGemdos;
  BEGIN
    ASSEMBLER
        ASC     "XBRA"
        ASC     "RscP"
prev:   DC.L    0

        ; Entry point
entry:  BTST    #5,(A7)         ; call from supervisor mode?
        BNE     y1

dos:    MOVE.L  prev(PC),A0
        JMP     (A0)            ; jump to original GEMDOS handler

y1:     CMPI.W  #$48,SFOfs+6(A7) ; Malloc() function call?
        BNE     dos
        MOVE.L  $4F2,A0
        ADDA.L  #$18000,A0
        CMPA.L  2(A7),A0        ; call from AES malloc handler?
        BCC     dos
        MOVE.L  2(A7),A0
        CMPA.L  SFOfs+12(A7),A0 ; call from AES RSC installation routine?
        BCC     dos

        ; this is the Malloc call we waited for!

        MOVE.L  bufAddr,GemRscPtr
        MOVE.L  SFOfs+12(A7),A0 ; load return address
     s: CMPI.W  #$508F,(A0)+    ; search for "ADDQ.L #8,A7"
        BNE     s
        MOVE.L  A0,SFOfs+12(A7) ; set new return address

        ; remove this GEMDOS handler
        MOVE.L  A2,-(A7)        ; just for safety
        LEA     entry(PC),A2
        LEA     $84,A0          ; TRAP #1 vector
     l: MOVE.L  (A0),A1
        CMPA.L  A2,A1           ; entry found?
        BEQ     f
        CMPI.L  #$58425241,-12(A1) ; is this an XBRA entry?
        BNE     n               ; no -> don't remove our entry
        LEA     -4(A1),A0       ; take previous vector
        BRA     l
     f: MOVE.L  -4(A1),(A0)     ; insert previous vector
        MOVE.L  (A7)+,A2
     n:
        RTE
    END
  END hdlGemdos;

PROCEDURE cpuTest;
  BEGIN
    ASSEMBLER
        MOVE.L  A7,D2
        LEA     $10,A1          ; illegal instruction exc-vector
        MOVE.L  (A1),D1
        LEA     b(PC),A0
        MOVE.L  A0,(A1)
        MOVE.L  #68000,D0
        DC.W    $51FC           ;TRAPF
        MOVE.L  D1,(A1)
        MOVE.L  #68020,D0
        DC.W    $4E7A,$1002     ;MOVEC   CACR,D1
        MOVE.L  D1,D2
        ORI.W   #100100000000%,D2 ; clear & enable data cache
        DC.W    $4E7B,$2002     ;MOVEC   D2,CACR
        DC.W    $4E7A,$2002     ;MOVEC   CACR,D2
        BTST    #8,D2           ; data cache enabled?
        BEQ     e
        MOVE.L  #68030,D0
      e DC.W    $4E7B,$1002     ;MOVEC   D1,CACR
        RTS
      b MOVE.L  D2,A7
        MOVE.L  D1,(A1)
    END
  END cpuTest;

BEGIN
  ASSEMBLER
        PEA     cpuTest
        MOVE    #Supexec,-(A7)
        TRAP    #14
        ADDQ.L  #6,A7
        CMPI.L  #68030,D0
        BNE.W   noInstall

        MOVE.L  4(A7),A5        ; starting address of workspace
        
        ; ** load RSC-File **
        ; open file
        CLR.W   -(A7)           ; read only
        PEA     fname(PC)
        MOVE.W  #Fopen,-(A7)
        TRAP    #1
        ADDQ.L  #8,A7
        TST.W   D0
        BMI.W   nofile          ; error on open -> abort installation
        MOVE    D0,D3           ; D3: file handle
        ; Fseek to end of file in order to get file size
        MOVE.W  #2,-(A7)
        MOVE.W  D3,-(A7)
        CLR.L   -(A7)
        MOVE.W  #Fseek,-(A7)
        TRAP    #1
        ADDA.W  #10,A7
        MOVE.L  D0,D4           ; D4: file size
        BMI.W   readerr
        ; back to begin of file
        MOVE.W  #0,-(A7)
        MOVE.W  D3,-(A7)
        CLR.L   -(A7)
        MOVE.W  #Fseek,-(A7)
        TRAP    #1
        ADDA.W  #10,A7
        ; load RSC to begin of heap (end of static prog space)
        MOVE.L  A5,A4           ; start of prg space
        ADDA.L  codelen(A5),A4
        ADDA.L  datalen(A5),A4
        ADDA.L  bsslen(A5),A4
        ADDA.W  #256,A4         ; add size of base page
        MOVE.L  A4,-(A7)        ; A4: begin of RSC buffer
        MOVE.L  D4,-(A7)
        MOVE.W  D3,-(A7)
        MOVE    #Fread,-(A7)
        TRAP    #1
        ADDA.W  #12,A7
        TST.L   D0
        BMI.W   readerr
        ; close file
        MOVE.W  D3,-(A7)
        MOVE.W  #Fclose,-(A7)
        TRAP    #1
        ADDQ.L  #4,A7
        
        ; verify data in file
        MOVE.L  A4,A0
        CMPI.L  #$4D4D322F,(A0)+
        BNE.W   wrongFile
        CMPI.L  #$52736350,(A0)+
        BNE.W   wrongFile
        CMPI.L  #$61746368,(A0)+
        BNE.W   wrongFile
        CMPI.B  #1,FileHeader.version(A4)
        BNE.W   wrongVersion
        
        ; copy TOS-header from ROM to RAM
        PEA     t(PC)
        MOVE    #Supexec,-(A7)
        TRAP    #14
        ADDQ.L  #6,A7
        BRA     c
     t: MOVE.L  $4F2,A0
        LEA     tosHeader,A1
        MOVE.L  A1,D0
        MOVEQ   #$17,D1
     l: MOVE.W  (A0)+,(A1)+
        DBRA    D1,l
        MOVE.L  D0,$4F2
        RTS
     c: MOVE.L  D0,A0           ; A0: ^TOS-header

        ; set config word in TOS-header
        MOVE.W  FileHeader.conf(A4),$1C(A0)
        
        ; install GEMDOS handler
        PEA     t2(PC)
        MOVE    #Supexec,-(A7)
        TRAP    #14
        ADDQ.L  #6,A7
        BRA     c2
    t2: LEA     hdlGemdos,A0
        ADDA.W  #12,A0
        LEA     $84,A1          ; TRAP #1 vector
        MOVE.L  (A1),-4(A0)
        MOVE.L  A0,(A1)
        RTS
    c2:
        ; store arguments for 'hdlGemdos'
        ADDA.L  FileHeader.rscOffs(A4),A4
        MOVE.L  A4,bufAddr
        MOVE.L  D4,bufSize

        ; print install msg
        PEA     msg_1(PC)
        MOVE.W  #PrintLine,-(A7)
        TRAP    #1
        ADDQ.L  #6,A7

        ; terminate program
        MOVE.L  codelen(A5),D0
        ADD.L   datalen(A5),D0
        ADD.L   bsslen(A5),D0
        ADDI.L  #256,D0         ; add length of base page
        ADD.L   D4,D0           ; add space for RSC buffer
        CLR.W   -(A7)           ; exitCode
        MOVE.L  D0,-(A7)        ; amount
        MOVE.W  #PtermRes,-(A7) ; terminate and stay resident
        TRAP    #1
        BREAK

readerr ; close file
        MOVE.W  D3,-(A7)
        MOVE.W  #Fclose,-(A7)
        TRAP    #1
        ADDQ.L  #4,A7
        ; print read error msg
        PEA     msg_3(PC)
        BRA     msgout

noInstall:
        BRA     exit

wrongFile:
        PEA     msg_4(PC)
        BRA     msgout

wrongVersion:
        PEA     msg_5(PC)
        BRA     msgout

nofile: ; print open error msg
        PEA     msg_2(PC)

msgout: MOVE.W  #PrintLine,-(A7)
        TRAP    #1
        ADDQ.L  #6,A7
exit:   CLR.W   -(A7)
        TRAP    #1              ; terminate


fname   ACZ     "\DESKTOP.DAT"

msg_1   DC.B    13,10
        ASC     "RSC-Patch installed"
        DC.B    13,10,0

msg_2   DC.B    13,10
        ASC     "RSC-Patch: resource file DESKTOP.DAT not found!"
        DC.B    13,10,0

msg_3   DC.B    13,10
        ASC     "RSC-Patch: read error on resource file!"
        DC.B    13,10,0

msg_4   DC.B    13,10
        ASC     "RSC-Patch: DESKTOP.DAT does not contain resource data!"
        DC.B    13,10,0

msg_5   DC.B    13,10
        ASC     "RSC-Patch: incompatible version of DESKTOP.DAT!"
        DC.B    13,10,0
        SYNC
  END
END RSCPatch.
