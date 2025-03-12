    OPT O+,D-,X-

; Set black palette :)                      (2 bytes)
; Line-A Initialization + hide mouse cursor (8 bytes)
; Tunnel generate                          (62 bytes)
; Animation                                (40 bytes)
; Set palette procedure                    (14 bytes)
; ---------------------------------------------------
; Tunnel ST                               (126 bytes)

;----------------------------------------------------------
; Set black palette
;----------------------------------------------------------
    jsr setPalette
;----------------------------------------------------------
; Line-A Initialization
;----------------------------------------------------------
    dc.w    $A000
    movem.l (a0),a1-a4          ; A3=INTIN, A4=PTSIN
    dc.w    $A00A               ; Hide mouse cursor
;----------------------------------------------------------
; Tunnel generate
;----------------------------------------------------------
    move    #199,d7
yLoop:
    move    #319,d6
xLoop:
    move    d7,d5
    sub     #100,d5
    muls    d5,d5

    move    d6,d4
    sub     #160,d4
    muls    d4,d4

    add     d5,d4
    lsr     #6,d4

    clr     d2
    moveq   #40,d5
    cmp     d5,d4
    bmi     PutPixel

    lsl     #6,d5
    divu    d4,d5

    moveq   #7,d2
    and     d5,d2
    add     #1,d2

PutPixel:
    move    d2,(a3)             ; Color
    movem   d6-d7,(a4)          ; X, Y
    dc.w    $A001               ; $A001 Put Pixel

    dbf     d6,xLoop
    dbf     d7,yLoop
;----------------------------------------------------------
; Animation
;----------------------------------------------------------
    move    #$110,d5
    move    d5,d4
anim:
    lea     palette(pc),a5
    adda    #2,a5

    move    d4,d7
    moveq   #7,d6
    gen:
        move    d7,(a5)+
        add     d5,d7
        dbf     d6,gen

    add     d5,d4
    and     #$770,d4

    jsr setPalette

;---Wait
    moveq   #200,d0
    dbf     d0,*

    jmp     anim
;----------------------------------------------------------
; Set palette procedure
;----------------------------------------------------------
setPalette:
    pea     palette(pc)
    move    #6,-(sp)
    trap    #14
    addq    #6,sp
    rts
;----------------------------------------------------------
palette:
