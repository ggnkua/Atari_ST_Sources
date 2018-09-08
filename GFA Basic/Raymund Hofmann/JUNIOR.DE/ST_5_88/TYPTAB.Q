; Typentabelle zu JUNIOR.Q
; Typen 2716 bis 27011

; Typ 2716, Index 0

  dc.b "2716  EPROM  2Kb 25V          " ; Beschreibung
  dc.l 2048     ; Kapazit„t in Bytes
  dc.l 0        ; Gr”že einer Seite
  dc.w 0        ; Programmieralgoritmus
  dc.w 500      ; i_zeit
  dc.w 00       ; m_zeit
  dc.w 2        ; trials
;       AAAAAAAA  BBBBBBBB
;       76543210  76543210

  dc.b %00001000,%01000011      ; Standby
  dc.b %00001010,%01000000      ; Read
  dc.b %00001010,%01000010      ; Odis
  dc.b %10001010,%01000011      ; Program
  dc.b %10001010,%01000000      ; Pr_ver
  dc.b %10001010,%01000010      ; Pr_inh
  dc.b %00000000,%00000000      ; Page_wr
  dc.b 0                        ; Manufacturer Code
  dc.b 0                        ; Device Code
  dc.b %00000000                ; Tsmask
  dc.b 0                        ; Frei 3
  dc.b %00000000,%00000000      ; Frei 1
  dc.b %00000000,%00000000      ; Frei 2

  dc.b %00000000,%00001000      ; Tabelle A10
  dc.b %00000000,%00000000      ; A11
  dc.b %00000000,%00000000      ; A12
  dc.b %00000000,%00000000      ; A13
  dc.b %00000000,%00000000      ; A14
  dc.b %00000000,%00000000      ; A15
  dc.b %00000000,%00000000      ; A16

; Typ 2732, Index 1

  dc.b "2732  EPROM  4Kb 25V          " ; Beschreibung
  dc.l 4096     ; Kapazit„t in Bytes
  dc.l 0        ; Gr”že einer Seite
  dc.w 0        ; Programmieralgoritmus
  dc.w 500      ; i_zeit
  dc.w 0        ; m_zeit
  dc.w 2        ; trials
;       AAAAAAAA  BBBBBBBB
;       76543210  76543210

  dc.b %00000000,%01000011      ; Standby
  dc.b %00000010,%01000000      ; Read
  dc.b %00000010,%01000010      ; Odis
  dc.b %10000010,%01000110      ; Program
  dc.b %10000010,%01000000      ; Pr_ver
  dc.b %10000010,%01000010      ; Pr_inh
  dc.b %00000000,%00000000      ; Page_wr
  dc.b 0                        ; Manufacturer Code
  dc.b 0                        ; Device Code
  dc.b %00000000                ; Tsmask
  dc.b 0                        ; Frei 3
  dc.b %00000000,%00000000      ; Frei 1
  dc.b %00000000,%00000000      ; Frei 2

  dc.b %00000000,%00001000      ; Tabelle A10
  dc.b %00000000,%00010000      ; A11
  dc.b %00000000,%00000000      ; A12
  dc.b %00000000,%00000000      ; A13
  dc.b %00000000,%00000000      ; A14
  dc.b %00000000,%00000000      ; A15
  dc.b %00000000,%00000000      ; A16

; Typ 2732 A, Index 2

  dc.b "2732A EPROM  4Kb 21V          " ; Beschreibung
  dc.l 4096     ; Kapazit„t in Bytes
  dc.l 0        ; Gr”že einer Seite
  dc.w 0        ; Programmieralgoritmus
  dc.w 500      ; i_zeit
  dc.w 0        ; m_zeit
  dc.w 2        ; trials
;       AAAAAAAA  BBBBBBBB
;       76543210  76543210

  dc.b %00000000,%01000011      ; Standby
  dc.b %00000010,%01000000      ; Read
  dc.b %00000010,%01000010      ; Odis
  dc.b %01000010,%01000110      ; Program
  dc.b %01000010,%01000000      ; Pr_ver
  dc.b %01000010,%01000010      ; Pr_inh
  dc.b %00000000,%00000000      ; Page_wr
  dc.b 0                        ; Manufacturer Code
  dc.b 0                        ; Device Code
  dc.b %00000000                ; Tsmask
  dc.b 0                        ; Frei 3
  dc.b %00000000,%00000000      ; Frei 1
  dc.b %00000000,%00000000      ; Frei 2

  dc.b %00000000,%00001000      ; Tabelle A10
  dc.b %00000000,%00010000      ; A11
  dc.b %00000000,%00000000      ; A12
  dc.b %00000000,%00000000      ; A13
  dc.b %00000000,%00000000      ; A14
  dc.b %00000000,%00000000      ; A15
  dc.b %00000000,%00000000      ; A16

; Typ 2764, Index 3 

  dc.b "2764  EPROM  8Kb 21V          " ; Beschreibung
  dc.l 8192     ; Kapazit„t in Bytes
  dc.l 0        ; Gr”že einer Seite
  dc.w 0        ; Programmieralgoritmus
  dc.w 10       ; i_zeit
  dc.w 40       ; m_zeit
  dc.w 15       ; trials
;       AAAAAAAA  BBBBBBBB
;       76543210  76543210

  dc.b %00010010,%10000011      ; Standby
  dc.b %00010010,%10000000      ; Read
  dc.b %00010010,%10000001      ; Odis
  dc.b %01010010,%00000010      ; Program
  dc.b %01010010,%10000000      ; Pr_ver
  dc.b %01010010,%10000010      ; Pr_inh
  dc.b %00000000,%00000000      ; Page_wr
  dc.b 0                        ; Manufacturer Code
  dc.b 0                        ; Device Code
  dc.b %00000000                ; Tsmask
  dc.b 0                        ; Frei 3
  dc.b %00000000,%00000000      ; Frei 1
  dc.b %00000000,%00000000      ; Frei 2

  dc.b %00000000,%00001000      ; Tabelle A10
  dc.b %00000000,%00010000      ; A11
  dc.b %00000000,%00100000      ; A12
  dc.b %00000000,%00000000      ; A13
  dc.b %00000000,%00000000      ; A14
  dc.b %00000000,%00000000      ; A15
  dc.b %00000000,%00000000      ; A16

; Typ 2764A, Index 4

  dc.b "2764A EPROM  8Kb 12.5V        " ; Beschreibung
  dc.l 8192     ; Kapazit„t in Bytes
  dc.l 0        ; Gr”že einer Seite
  dc.w 0        ; Programmieralgoritmus
  dc.w 10       ; i_zeit
  dc.w 40       ; m_zeit
  dc.w 15       ; trials
;       AAAAAAAA  BBBBBBBB
;       76543210  76543210

  dc.b %00010010,%10000011      ; Standby
  dc.b %00010010,%10000000      ; Read
  dc.b %00010010,%10000001      ; Odis
  dc.b %00110010,%00000010      ; Program
  dc.b %00110010,%10000000      ; Pr_ver
  dc.b %00110010,%10000010      ; Pr_inh
  dc.b %00000000,%00000000      ; Page_wr
  dc.b 0                        ; Manufacturer Code
  dc.b 0                        ; Device Code
  dc.b %00000000                ; Tsmask
  dc.b 0                        ; Frei 3
  dc.b %00000000,%00000000      ; Frei 1
  dc.b %00000000,%00000000      ; Frei 2

  dc.b %00000000,%00001000      ; Tabelle A10
  dc.b %00000000,%00010000      ; A11
  dc.b %00000000,%00100000      ; A12
  dc.b %00000000,%00000000      ; A13
  dc.b %00000000,%00000000      ; A14
  dc.b %00000000,%00000000      ; A15
  dc.b %00000000,%00000000      ; A16

; Typ 27128, Index 5

  dc.b "27128 EPROM 16Kb 21V          " ; Beschreibung
  dc.l 16384    ; Kapazit„t in Bytes
  dc.l 0        ; Gr”že einer Seite
  dc.w 0        ; Programmieralgoritmus
  dc.w 10       ; i_zeit
  dc.w 40       ; m_zeit
  dc.w 15       ; trials
;       AAAAAAAA  BBBBBBBB
;       76543210  76543210

  dc.b %00010000,%10000011      ; Standby
  dc.b %00010010,%10000000      ; Read
  dc.b %00010010,%10000010      ; Odis
  dc.b %01010010,%00000010      ; Program
  dc.b %01010010,%10000000      ; Pr_ver
  dc.b %01010010,%10000010      ; Pr_inh
  dc.b %00000000,%00000000      ; Page_wr
  dc.b 0                        ; Manufacturer Code
  dc.b 0                        ; Device Code
  dc.b %00000000                ; Tsmask
  dc.b 0                        ; Frei 3
  dc.b %00000000,%00000000      ; Frei 1
  dc.b %00000000,%00000000      ; Frei 2

  dc.b %00000000,%00001000      ; Tabelle A10
  dc.b %00000000,%00010000      ; A11
  dc.b %00000000,%00100000      ; A12
  dc.b %00000000,%01000000      ; A13
  dc.b %00000000,%00000000      ; A14
  dc.b %00000000,%00000000      ; A15
  dc.b %00000000,%00000000      ; A16

; Typ 27128A, Index 6

  dc.b "27128A EPROM 16Kb 12.5V       " ; Beschreibung
  dc.l 16384    ; Kapazit„t in Bytes
  dc.l 0        ; Gr”že einer Seite
  dc.w 0        ; Programmieralgoritmus
  dc.w 10       ; i_zeit
  dc.w 40       ; m_zeit
  dc.w 15       ; trials
;       AAAAAAAA  BBBBBBBB
;       76543210  76543210

  dc.b %00010010,%10000011      ; Standby
  dc.b %00010010,%10000000      ; Read
  dc.b %00010010,%10000001      ; Odis
  dc.b %00110010,%00000010      ; Program
  dc.b %00110010,%10000000      ; Pr_ver
  dc.b %00110010,%10000010      ; Pr_inh
  dc.b %00000000,%00000000      ; Page_wr
  dc.b 0                        ; Manufacturer Code
  dc.b 0                        ; Device Code
  dc.b %00000000                ; Tsmask
  dc.b 0                        ; Frei 3
  dc.b %00000000,%00000000      ; Frei 1
  dc.b %00000000,%00000000      ; Frei 2

  dc.b %00000000,%00001000      ; Tabelle A10
  dc.b %00000000,%00010000      ; A11
  dc.b %00000000,%00100000      ; A12
  dc.b %00000000,%01000000      ; A13
  dc.b %00000000,%00000000      ; A14
  dc.b %00000000,%00000000      ; A15
  dc.b %00000000,%00000000      ; A16

; Typ 27256I, Index 7

  dc.b "27256I EPROM 16Kb 12.5V       " ; Beschreibung
  dc.l 32768    ; Kapazit„t in Bytes
  dc.l 0        ; Gr”že einer Seite
  dc.w 0        ; Programmieralgoritmus
  dc.w 10       ; i_zeit
  dc.w 30       ; m_zeit
  dc.w 25       ; trials
;       AAAAAAAA  BBBBBBBB
;       76543210  76543210

  dc.b %00010000,%00000011      ; Standby
  dc.b %00010010,%00000000      ; Read
  dc.b %00010010,%00000010      ; Odis
  dc.b %00110010,%00000010      ; Program
  dc.b %00110010,%00000001      ; Pr_ver
  dc.b %00110010,%00000011      ; Pr_inh
  dc.b %00000000,%00000000      ; Page_wr
  dc.b 0                        ; Manufacturer Code
  dc.b 0                        ; Device Code
  dc.b %00000000                ; Tsmask
  dc.b 0                        ; Frei 3
  dc.b %00000000,%00000000      ; Frei 1
  dc.b %00000000,%00000000      ; Frei 2

  dc.b %00000000,%00001000      ; Tabelle A10
  dc.b %00000000,%00010000      ; A11
  dc.b %00000000,%00100000      ; A12
  dc.b %00000000,%01000000      ; A13
  dc.b %00000000,%10000000      ; A14
  dc.b %00000000,%00000000      ; A15
  dc.b %00000000,%00000000      ; A16

; Typ 27256, Index 8

  dc.b "27256 EPROM 32Kb 21V          " ; Beschreibung
  dc.l 32768    ; Kapazit„t in Bytes
  dc.l 0        ; Gr”že einer Seite
  dc.w 0        ; Programmieralgoritmus
  dc.w 10       ; i_zeit
  dc.w 30       ; m_zeit
  dc.w 25       ; trials
;       AAAAAAAA  BBBBBBBB
;       76543210  76543210

  dc.b %00010000,%00000011      ; Standby
  dc.b %00010010,%00000000      ; Read
  dc.b %00010010,%00000010      ; Odis
  dc.b %01010010,%00000010      ; Program
  dc.b %01010010,%00000000      ; Pr_ver
  dc.b %01010010,%00000011      ; Pr_inh
  dc.b %00000000,%00000000      ; Page_wr
  dc.b 0                        ; Manufacturer Code
  dc.b 0                        ; Device Code
  dc.b %00000000                ; Tsmask
  dc.b 0                        ; Frei 3
  dc.b %00000000,%00000000      ; Frei 1
  dc.b %00000000,%00000000      ; Frei 2

  dc.b %00000000,%00001000      ; Tabelle A10
  dc.b %00000000,%00010000      ; A11
  dc.b %00000000,%00100000      ; A12
  dc.b %00000000,%01000000      ; A13
  dc.b %00000000,%10000000      ; A14
  dc.b %00000000,%00000000      ; A15
  dc.b %00000000,%00000000      ; A16

; Typ 27512, Index 9

  dc.b "27512 EPROM 64Kb 12.5V        " ; Beschreibung
  dc.l 65536    ; Kapazit„t in Bytes
  dc.l 0        ; Gr”že einer Seite
  dc.w 0        ; Programmieralgoritmus
  dc.w 10       ; i_zeit
  dc.w 30       ; m_zeit
  dc.w 25       ; trials
;       AAAAAAAA  BBBBBBBB
;       76543210  76543210

  dc.b %00000000,%00000011      ; Standby
  dc.b %00000010,%00000000      ; Read
  dc.b %00000010,%00000010      ; Odis
  dc.b %00100010,%00000110      ; Program
  dc.b %00100010,%00000000      ; Pr_ver
  dc.b %00100010,%00000001      ; Pr_inh
  dc.b %00000000,%00000000      ; Page_wr
  dc.b 0                        ; Manufacturer Code
  dc.b 0                        ; Device Code
  dc.b %00000000                ; Tsmask
  dc.b 0                        ; Frei 3
  dc.b %00000000,%00000000      ; Frei 1
  dc.b %00000000,%00000000      ; Frei 2

  dc.b %00000000,%00001000      ; Tabelle A10
  dc.b %00000000,%00010000      ; A11
  dc.b %00000000,%00100000      ; A12
  dc.b %00000000,%01000000      ; A13
  dc.b %00000000,%10000000      ; A14
  dc.b %00000001,%00000000      ; A15
  dc.b %00000000,%00000000      ; A16

; Typ 27513, Index 10

  dc.b "27513 EPROM 4*16Kb*8 12.5V    " ; Beschreibung
  dc.l 65536    ; Kapazit„t in Bytes
  dc.l 16384    ; Gr”že einer Seite
  dc.w 0        ; Programmieralgoritmus
  dc.w 10       ; i_zeit
  dc.w 30       ; m_zeit
  dc.w 25       ; trials
;       AAAAAAAA  BBBBBBBB
;       76543210  76543210

  dc.b %00000001,%10000011      ; Standby
  dc.b %00000011,%10000000      ; Read
  dc.b %00000011,%10000010      ; Odis
  dc.b %00100011,%10000110      ; Program
  dc.b %00100011,%10000000      ; Pr_ver
  dc.b %00100011,%10000011      ; Pr_inh
  dc.b %00000000,%00000010      ; Page_wr
  dc.b 0                        ; Manufacturer Code
  dc.b 0                        ; Device Code
  dc.b %00000000                ; Tsmask
  dc.b 0                        ; Frei 3
  dc.b %00000000,%00000000      ; Frei 1
  dc.b %00000000,%00000000      ; Frei 2

  dc.b %00000000,%00001000      ; Tabelle A10
  dc.b %00000000,%00010000      ; A11
  dc.b %00000000,%00100000      ; A12
  dc.b %00000000,%01000000      ; A13
  dc.b %00000000,%00000000      ; A14
  dc.b %00000000,%00000000      ; A15
  dc.b %00000000,%00000000      ; A16

; Typ 27011, Index 11

  dc.b "27011 EPROM 8*16Kb*8 12.5V    " ; Beschreibung
  dc.l 131072   ; Kapazit„t in Bytes
  dc.l 16384    ; Gr”že einer Seite
  dc.w 0        ; Programmieralgoritmus
  dc.w 10       ; i_zeit
  dc.w 30       ; m_zeit
  dc.w 25       ; trials
;       AAAAAAAA  BBBBBBBB
;       76543210  76543210

  dc.b %00010001,%10000011      ; Standby
  dc.b %00010011,%10000000      ; Read
  dc.b %00010011,%10000010      ; Odis
  dc.b %00110011,%00000010      ; Program
  dc.b %00110011,%10000000      ; Pr_ver
  dc.b %00110011,%10000011      ; Pr_inh
  dc.b %00000000,%00000010      ; Page_wr
  dc.b 0                        ; Manufacturer Code
  dc.b 0                        ; Device Code
  dc.b %00000000                ; Tsmask
  dc.b 0                        ; Frei 3
  dc.b %00000000,%00000000      ; Frei 1
  dc.b %00000000,%00000000      ; Frei 2

  dc.b %00000000,%00001000      ; Tabelle A10
  dc.b %00000000,%00010000      ; A11
  dc.b %00000000,%00100000      ; A12
  dc.b %00000000,%01000000      ; A13
  dc.b %00000000,%00000000      ; A14
  dc.b %00000000,%00000000      ; A15
  dc.b %00000000,%00000000      ; A16

  end


