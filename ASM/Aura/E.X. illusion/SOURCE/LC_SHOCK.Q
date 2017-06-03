; This file contains an additional subrout which specially made for the demo
; and so not usable as generally subrouts.
; (C) Copyright 1995 by Jochen Knaus, AURA.

; "Der kleine Colourshock"...
; <colours.q> MUû mitassembliert werden !

; Ein eigenes Unterprogramm, da der Objektgenerator etwas unflexibel ausge-
; legt wurde...

ANZ_IRREALS   EQU     32

BLUE_RED      EQU     0                   ; BLAU
BLUE_YELLOW   EQU     1
BLUE_GREEN    EQU     2
BLUE_CYAN     EQU     3
BLUE_MAGENTA  EQU     4
BLUE_WHITE    EQU     5
RED_YELLOW    EQU     6                   ; ROT
RED_GREEN     EQU     7
RED_CYAN      EQU     8
RED_MAGENTA   EQU     9
RED_WHITE     EQU     10
GREEN_YELLOW  EQU     11                  ; GRöN
GREEN_CYAN    EQU     12
GREEN_MAGENTA EQU     13
GREEN_WHITE   EQU     14
YELLOW_CYAN   EQU     15                  ; GELB
YELLOW_MAGENTA EQU    16
YELLOW_WHITE  EQU     17
CYAN_MAGENTA  EQU     18                  ; CYAN
CYAN_WHITE    EQU     19

make_irreals: lea     cool_pal(pc),a0
              lea     irreal,a1
              moveq   #ANZ_IRREALS-1,d7
do_the_twist: movem.l (a0)+,a2-a3
              move.l  (a2)+,(a1)+         ; Startfarbe Åbertragen
              move.w  (a2),(a1)+
              move.l  (a3)+,(a1)+         ; Zielfarbe Åbertragen
              move.w  (a3),(a1)+
              dbra    d7,do_the_twist
              rts     

cool_pal:     DC.L    _BLUE,_RED          ; BLAU
              DC.L    _BLUE,_YELLOW
              DC.L    _BLUE,_GREEN
              DC.L    _BLUE,_CYAN
              DC.L    _BLUE,_MAGENTA
              DC.L    _BLUE,_WHITE

              DC.L    _RED,_YELLOW        ; ROT
              DC.L    _RED,_GREEN
              DC.L    _RED,_CYAN
              DC.L    _RED,_MAGENTA
              DC.L    _RED,_WHITE

              DC.L    _GREEN,_YELLOW
              DC.L    _GREEN,_CYAN
              DC.L    _GREEN,_MAGENTA
              DC.L    _GREEN,_WHITE

              DC.L    _YELLOW,_CYAN
              DC.L    _YELLOW,_MAGENTA
              DC.L    _YELLOW,_WHITE

              DC.L    _CYAN,_MAGENTA
              DC.L    _CYAN,_WHITE

ORANGE_LIGHTBLUE      EQU 20
ORANGE_BLUE           EQU 21
ORANGE_RED            EQU 22
ORANGE_YELLOW         EQU 23
ORANGE_GREEN          EQU 24
ORANGE_HUNTERSGREEN   EQU 25
ORANGE_CYAN           EQU 26
ORANGE_MAGENTA        EQU 27

              DC.L    _ORANGE,_LIGHTBLUE
              DC.L    _ORANGE,_BLUE
              DC.L    _ORANGE,_RED
              DC.L    _ORANGE,_YELLOW
              DC.L    _ORANGE,_GREEN
              DC.L    _ORANGE,_HUNTERSGREEN
              DC.L    _ORANGE,_CYAN
              DC.L    _ORANGE,_MAGENTA

SILVER_GOLD           EQU 28
FLESH_BAKERSCHOC      EQU 29

              DC.L    _SILVER,_GOLD
              DC.L    _FLESH,_BAKERSCHOC

MAGENTA_WHITE         EQU 30
BLACK_WHITE           EQU 31

              DC.L    _MAGENTA,_WHITE
              DC.L    _BLACK,_WHITE

              BSS                         ; Easy-Ass sei dank...
irreal:       DS.W    6*ANZ_IRREALS+6
              TEXT
