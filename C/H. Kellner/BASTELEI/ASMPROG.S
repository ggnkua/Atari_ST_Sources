********************************************************
*                                                      *
*  Source code fr ASMPROG.MOD                         *
*  Projekt :  16-Bit-I/O-Interface                     *
*  Source von: J”rg Bliesener, DB9FD                   *
*                                                      *
********************************************************


        dc.l    $4AFCDB9F               ; Illegal Instruction for
*                                          debugging & Magic LW
        bra     INIT
        bra     DEINIT
        bra     READ
        bra     WRITE
        bra     READR
        bra     WRITER

* Write Data in D0 to 6520 Reg (D1)
WRITER  move.w  d0,d4                   ; Save D0
        move.w  d1,d5                   ; Save D1
        bsr     supon                   ; Enter Superuser Mode
        move.w  d4,d0                   ; Restore D0
        move.w  d5,d1                   ; Restore D1
        bsr     WR6520                  ; Write Data
        bsr     supoff                  ; Exit Superuser Mode
        rts

* Read 6520 Reg (D0), Data returned in D0
READR   move.w  d0,d4                   ; Save D0
        bsr     supon                   ; Enter Superuser Mode
        move.w  d4,d0                   ; Restore D0
        bsr     RD6520                  ; Read Data
        bsr     supoff                  ; Exit Superuser Mode
        rts

* Writes Byte in D0 to Register (D1) in 6520
* Centronics Strobe strobes Address
* Centronics Busy strobes Data
WR6520  move.b  #$F,(a0)                ; Select I/O Port B
        move.b  d1,2(a0)                ; D1 -> I/O Port B
        move.b  #$E,(a0)                ; Select I/O Port A
        move.b  (a0),d1                 ; Read I/O Port A
        ori.w   #$20,d1                 ; Set Strobe Bit
        move.b  d1,2(a0)                ; Write I/O Port A
        andi.w  #$DF,d1                 ; Clear Strobe Bit
        move.b  d1,2(a0)                ; Write I/O Port A
        move.b  #$F,(a0)                ; Select I/O Port B
        move.b  d0,2(a0)                ; D0 -> I/O Port B
        bset.b  #0,CS6520               ; Toggle Busy Line
        bclr.b  #0,CS6520                     
        rts 

* Reads 6520 Register (D0), Data is returned in D0
RD6520  move.b  #$F,(a0)                ; Select Data Register B
        ori.w   #4,d0                   ; or in Read Bit
        move.b  d0,2(a0)                ; Write Data (6520 Address)
        move.b  #$E,(a0)                ; Select Data Register A
        move.b  (a0),d0                 ; Load Value
        ori.w   #$20,d0                 ; Set strobe Bit
        move.b  d0,2(a0)                ; Output Value
        andi.w  #$DF,d0                 ; Clear strobe Bit
        move.b  d0,2(a0)                ; Output Value
        move.b  #7,(a0)                 ; Select Data Direction Register
        move.b  (a0),d1                 ; Get Value
        andi.w  #$7F,d1                 ; Port B = Input
        move.b  d1,2(a0)                ; Write Value
        move.b  #$F,(a0)                ; Select Data Register B
        bset.b  #0,CS6520               ; Set Strobe
        move.b  (a0),d0                 ; Read Value
        bclr.b  #0,CS6520               ; Clear Strobe
        move.b  #7,(a0)                 ; Select Data Direction Register
        ori.w   #$80,d1                 ; Port B = Output
        move.b  d1,2(a0)                ; Write Value
        rts                             ; Done, Data in D0

* Init 6520, Data Direction for Port A and B in D0

INIT    lea     SAVED(pc),a0            ; Load Address of Save Area
        move.w  d0,(a0)                 ; Save Data Direction
        bsr     supon                   ; Enter Superuser Mode
        lea     SOUND,a0                ; Load Base Address of Soundchip
        move    sr,-(a7)                ; Push SR
        move    #$2700,sr               ; Disable Ints
        bset.b  #0,GPIBDIR              ; Busy line now acts as Output
        bclr.b  #0,CS6520               ; Clear CS
        move.b  #$F,(a0)                ; Select Data Register
        move.b  #8,2(a0)                ; Reset 6520
        move.b  #$E,(a0)              
        move.b  (a0),d0 
        andi.w  #$DF,d0                 ; Clear Strobe
        move.b  d0,2(a0)      
        ori.w   #$20,d0                 ; Set Strobe
        move.b  d0,2(a0)
        andi.w  #$DF,d0                 ; Clear Strobe
        move.b  d0,2(a0)
        moveq   #0,d0 
        moveq   #1,d1 
        bsr     WR6520                  ; Select DDIRA
        move.b  SAVED+1(pc),d0          ; Get Direction of Port A
        moveq   #0,d1                   ;  -> 6520 Reg 00
        bsr     WR6520                  ; Set DDIR A
        moveq   #4,d0 
        moveq   #1,d1 
        bsr     WR6520                  ; Select DATAA
        moveq   #0,d0 
        moveq   #3,d1 
        bsr     WR6520                  ; Select DDIRB
        move.b  SAVED(pc),d0            ; Get Direction of Port B
        moveq   #2,d1         
        bsr     WR6520                  ; -> 6520 Reg 02
        moveq   #4,d0 
        moveq   #3,d1 
        bsr     WR6520                  ; Select DATAB
        move    (a7)+,sr                ; Pop SR, Enable Ints
        bsr     supoff                  ; Exit Superuser Mode
        rts 

* Restore Centronics Mode

DEINIT  bsr     supon                   ; Enter Superuser Mode
        lea     SOUND,a0                ; Load Base Address of Sound Chip
        move    sr,d1                   ; Save SR
        move    #$2700,sr               ; Disable Ints
        bclr.b  #0,GPIBDIR              ; Busy Line = Output
        move.b  #$E,(a0)                ; Select I/O Reg A
        move.b  (a0),d0                 ; Read Data
        ori.w   #$20,d0                 ; Set Strobe
        move.b  d0,2(a0)                ; Write Data
        move    d1,sr                   ; Enable Ints
        bsr     supoff                  ; Exit Superuser mode
        rts 

* Read Data, Result for Port A and B in D0

READ    bsr     supon                   ; Enter Superuser Mode
        lea     SOUND,a0                ; Load Base Address of Sound Chip
        move    sr,-(a7)                ; Save SR
        move    #$2700,sr               ; Disable Ints
        moveq   #0,d0                 
        bsr     RD6520                  ; Read DATA A
        lea     GETD(pc),a1             ; Get Address of Save Area 
        move.b  d0,1(a1)                ; Save Port A Data
        moveq   #2,d0                 
        bsr     RD6520                  ; Read DATA B
        move.b  d0,(a1)                 ; Save It
        move    (a7)+,sr                ; Restore SR, Enable Ints
        bsr     supoff                  ; Exit Superuser Mode
        move.w  GETD(pc),d0             ; Get saved Data
        rts 

* Write Data, DATA for Port A and B in D0

WRITE   lea     SAVED(pc),a0            ; Load Address of Save Area
        move.w  d0,(a0)                 ; Save Data
        bsr     supon                   ; Enter Superuser Mode
        lea     SOUND,a0                ; Load Base Address of Sound Chip
        move    sr,-(a7)                ; Push SR
        move    #$2700,sr               ; Disable Ints
        move.b  SAVED+1(pc),d0          ; Load DATA for Port A
        moveq   #0,d1                   ; -> 6520 Reg 0
        bsr     WR6520                  ; Write Data
        move.b  SAVED(pc),d0            ; Get DATA for Port B 
        moveq   #2,d1                   ; -> 6520 Reg 1
        bsr     WR6520                  ; Write Data
        move    (a7)+,sr                ; Pop SR, enable Ints
        bsr     supoff                  ; Exit Superuser Mode
        rts 

supon   move.l  #1,-(sp)                ; Get Processor Mode
        move.w  #$20,-(sp)              ; Super
        trap    #1                      ; Gemdos
        addq.l  #6,sp                   ; Correct Stack
        lea     supstack(pc),a4         ; Get Address of Save Area
        move.b  d0,4(a4)                ; Save Value
        bne.s   supon1                  ; Skip if already Supervisor
        clr.l   -(sp)                   ; USP -> SSP
        move.w  #$20,-(sp)              ; Super
        trap    #1                      ; Gemdos
        addq.l  #6,sp                   ; Correct Stack
        move.l  d0,(a4)                 ; Save old SSP
supon1  rts

supoff  lea     supstack(pc),a4         ; Load Address of Save Area
        tst.b   4(a4)                   ; was in supervisor mode ?
        bne.s   supoff1                 ; Yes, skip
        move.l  (a4),-(sp)              ; Push Address of old SSP
        move.w  #$20,-(sp)              ; Super
        trap    #1                      ; Gemdos
        addq.l  #6,sp                   ; Correct Stack
supoff1 rts             

SAVED   dc.w    0                       ; Saved Data for Output
GETD    dc.w    0                       ; Saved Data from Input
supstack dc.l    0                       ; Saved SSP
supmode dc.b    0                       ; Flag for Supervisor mode

SOUND   equ     $FF8800                 ; Soundchip
CS6520  equ     $FFFA01                 ; MFP-Lines, Busy strobes 6520
GPIBDIR equ     $FFFA05                 ; 68901 Data Direction Register

********************************************************
