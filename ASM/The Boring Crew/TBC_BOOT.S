;
; TTTTTT     BBBBB              CCCCC
;   TT       BB  BB            CC
;   TT       BBBBB             CC
;   TT       BB  BB            CC
;   TT H E   BBBBB O R I N G    CCCCC R E W
;
; BBBBB   OOOO   OOOO TTTTTT SSSSS EEEE  CCCC TTTTTT  OOOO  RRRRR
; BB  BB OO  OO OO  OO  TT  SS     EE   CC      TT   OO  OO RR  RR
; BBBBB  OO  OO OO  OO  TT   SSSS  EEE  CC      TT   OO  OO RRRRR
; BB  BB OO  OO OO  OO  TT      SS EE   CC      TT   OO  OO RR  RR
; BBBBB   OOOO   OOOO   TT  SSSSS  EEEE  CCCC   TT    OOOO  RR  RR
;
; T.B.C. Ruling da Scene in 2006

                RSRESET
colptr:         RS.L 1
cols:           RS.L 200

; Yet again we spent months to research how to display characters on screen.
; Finally Alone1 came up with this most 1337 way to put some funky message onto
; everybody's screens. We are thinking to get a patent on this method since it
; seems to be really efficient if you consider the size of the code.

                pea     welcome(PC)        ; load the megamighty message address
                move.w  #9,-(SP)           ; and print it due to magical works
                trap    #1                 ; This command reflects our state of
;                                            mind, trapped in our own world...
                addq.l  #6,SP              ; i don't know what this is for but
;                                            someone told me i'd better use it

; The Gigamighty TOS supplies us with a perfect address to put our stuff, it is
; a System Variable called _membot and I have just discovered it when i found a
; copy of Readers Disgust in a Car Boot Sale a week ago...

                movea.l $0432.w,A6         ; this is where i can put stuff

                lea     cols(A6),A0        ; startadress of colours
                move.l  A0,colptr(A6)      ; remember raster start adress for
;                                            the colour write routine

                move.w  #$0717,D0          ; start colour
                move.w  #198,D1            ; calculate colours for screen height
do_cols:
                add.w   #$01,D0            ; add one onto colour
                move.w  D0,D2              ; copy for output format
                and.w   #$0777,D2          ; mask non used bits so we stay ST
                move.w  D2,(A0)+           ; write colour into raster table
                dbra    D1,do_cols         ; repeat everything for scr-height-1
                clr.w   (A0)               ; last colour is black

; Well the next part took us 5 years to figure out, actually we have no idea
; what it does, since we just copied it from a spanish Atari Magazine, anyway
; it works and that's what counts, no?

                bclr    #5,$FFFFFA09.w     ; hmmm

                move.l  $0120.w,-(SP)      ; save TiB vector
                lea     tib(PC),A0         ; set gigamighty raster routine
                move.l  A0,$0120.w

                clr.b   $FFFFFA1B.w        ; stop TiB
                bset    #0,$FFFFFA07.w     ; activate TiB
                bset    #0,$FFFFFA13.w
                move.b  #1,$FFFFFA21.w     ; Run TiB each line (TiB data)
                move.b  #8,$FFFFFA1B.w     ; Start TiB in event count mode

; Again the next part was really hard work, when we 1st tried stuff all rasters
; where whizzing around the screen and it looked like a terrible mess. Although
; xBore said it would reflect the erratic way of our code quite well, i wasn't
; really convinced. So i started to dig into this topic a bit and found an
; astonishing solution to synchronize with the vertical blank, i guess all these
; PC suckers can still learn a lot from the megamighty Boring Crew...

vbl:
                clr.l   $0466.w            ; Clear vbl counter
wvbl:           tst.l   $0466.w            ; Check if vbl counter was increased
                beq.s   wvbl               ; no? then wait till it was increased
                lea     cols(A6),A0        ; Reset Start Address for Rasters
                move.l  A0,colptr(A6)

                cmpi.b  #$39,$FFFFFC02.w   ; Did someone press Space?
                bne.s   vbl                ; If not Repeat

; Again the next part was ripped from a spanish ST Magazine, so don't expect many
; explanations here

                move    #$2700,SR          ; disallow any IRQs
                bclr    #0,$FFFFFA07.w     ; Disable TiB (rasters off)
                move.l  (SP)+,$0120.w      ; Restore old TiB vector
                move    #$2300,SR          ; allow IRQs
                bset    #5,$FFFFFA09.w     ; restart TiC
                rts                        ; Return from Bootsector
tib:
                move.l  A0,-(SP)           ; Store Registers
                move.l  A1,-(SP)

                movea.l $0432.w,A0         ; start of free memory (_membot)

                movea.l colptr(A0),A1      ; Get pointer to current colour
                move.w  (A1)+,$FFFF8240.w  ; write colour to Hardware
                move.l  A1,colptr(A0)      ; write back colour Pointer
                movea.l (SP)+,A1           ; Restore Registers
                movea.l (SP)+,A0
                bclr    #0,$FFFFFA0F.w     ; Clear IRQ in Service Bit
                rte                        ; Return from Interrupt

; this was the part we had finished 1st, its sitting on my harddisk since the
; last EIL but when i wrote the text to the bootsector it wasn't shown on screen
; so we had to delay the intro a bit.

welcome:        DC.B 27,"E"
;                DC.B 10,10,"Greetings to all EIL 3 visitors",10,10,13
                DC.B 10,10,"Greetings to all OUTLINE 2006 visitors",10,10,13
                DC.B "from the Creme of the Atari-Scene",10,10,13
                DC.B "TTTTTT BBBBBB   CCCCC",10,13
                DC.B "  TT   BB   BB CC",10,13
                DC.B "  TT   BBBBBB  CC",10,13
                DC.B "  TT   BB   BB CC",10,13
                DC.B "  TT   BBBBBB   CCCCC",10,10,13
                DC.B "We rule! Even in Bootsector Coding...",10,10,13
                DC.B "Code:        Alone1",10,13
                DC.B "Gay Colours: xBore",10,13
                DC.B "Silence:     DaFool"
                DC.B 0
                EVEN
                END
