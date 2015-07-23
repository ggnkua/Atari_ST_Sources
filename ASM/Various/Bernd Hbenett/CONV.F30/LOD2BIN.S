; ----------------------------------------
; ------------ L O D 2 B I N -------------
; ----------------------------------------
; RxT 30.04.1994 18:50
; This programm converts a LOD-File into
; a BIN-File. This BIN-File may be
; included into your Programs. On the
; Falcon030 you can use XBIOS(109) or
; XBIOS(110) to transmit and start
; the DSP-Program. This converter uses
; XBIOS-Function 111. The first Longword
; of the BIN-File consists the lenght of
; binary-data in DSP-Words.
; The Truecolor->Hicolor Converter
; demonstrates how to use this feature.
; I am interested in contacts to other
; Falcon030 users.
; My adress:
;             Bernd Huebenett
;             Albert-Einstein-Str. 6
;             63179 Obertshausen
;             Germany
;
; Internet: huebenet@stud.uni-frankfurt.de
; IRC: RxT on #atari
;
; This Program is PUBLIC DOMAIN
; ---------------------------------------

                pea     space
                pea     lodname
                move.w  #111,-(SP)
                trap    #14
                lea     10(SP),SP
                move.l  D0,bin_length
                mulu    #3,D0           ; DSP-Words -> Bytes
                addq.l  #4,D0           ; Bin_lenght
                move.l  D0,count

                move.w  #%0,-(SP)
                pea     biname
                move.w  #$3C,-(SP)
                trap    #1
                addq.l  #8,SP
                move.w  D0,handle

                pea     bin_length
                move.l  count,-(SP)
                move.w  handle,-(SP)
                move.w  #$40,-(SP)
                trap    #1
                lea     $0C(SP),SP

                move.w  handle,-(SP)
                move.w  #$3E,-(SP)
                trap    #1
                addq.l  #4,SP

                clr.w   -(SP)
                trap    #1


                DATA
lodname:        DC.B '24bit.lod',0
                EVEN
biname:         DC.B '24bit.bin',0
                EVEN

                BSS

handle:         DS.W 1
count:          DS.L 1
                EVEN
bin_length:     DS.L 1
space:          DS.L 60000      ; for example
                END
