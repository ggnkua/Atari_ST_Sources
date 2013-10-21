
        .include "xa_nkcc.sh"			; NKCC definitions

               .bss


*              key code handler

pkey_unshift:  .ds.l    1                    ; ^unshifted key table
pkey_shift:    .ds.l    1                    ; ^shift key table
pkey_caps:     .ds.l    1                    ; ^CapsLock table



               .data

*  exception scan code table for cursor block keys
*
*  first entry.B:  NKCC key code
*  second entry.B: scan code returned by TOS
*
*  the table is terminated with both entries -1

xscantab:      .dc.b    NK_UP       ,  $48   ; cursor up
               .dc.b    NK_DOWN     ,  $50   ; cursor down
               .dc.b    NK_LEFT     ,  $4b   ; cursor left
               .dc.b    NK_LEFT     ,  $73   ; Control cursor left
               .dc.b    NK_RIGHT    ,  $4d   ; cursor right
               .dc.b    NK_RIGHT    ,  $74   ; Control cursor right
               .dc.b    NK_INS      ,  $52   ; Insert
               .dc.b    NK_CLRHOME  ,  $47   ; ClrHome
               .dc.b    NK_CLRHOME  ,  $77   ; Control ClrHome
               .dc.b    NK_HELP     ,  $62   ; Help
               .dc.b    NK_UNDO     ,  $61   ; Undo
               .dc.w    -1


		.text
		.globl nkc_init

nkc_init: 
*------------- fetch addresses of TOS' key scan code translation tables

               moveq.l  #-1,d0               ; the function is also used to
               move.l   d0,-(sp)             ;  change the addresses; values
               move.l   d0,-(sp)             ;  of -1 as new addresses tell
               move.l   d0,-(sp)             ;  XBIOS not to change them
               move     #$10,-(sp)           ; Keytbl
               trap     #14                  ; XBIOS
               lea      $e(sp),sp            ; clean stack

               move.l   d0,a0                ; ^key table structure
               move.l   (a0),pkey_unshift   ; get ^unshifted table
               move.l   4(a0),pkey_shift     ; get ^shift table
               move.l   8(a0),pkey_caps       ; get ^CapsLock table

               rts                           ; bye




		.globl nkc_exit
*-----------------------------------------------------------
nkc_exit:      rts                           ; bye



		.globl nkc_tconv
*-----------------------------------------------------------
nkc_tconv:     movem.l  d3/d4,-(sp)          ; save registers


*------------- separate TOS key code

               move.l   d0,d1                ; TOS key code
               swap     d1                   ; .W = scan code and flags
               move     d1,d2                ; copy
               move     #$ff,d3              ; and-mask
               and      d3,d0                ; .B = ASCII code
               and      d3,d1                ; .B = scan code
               beq      .tos306              ; scancode=zero (key code created
                                             ;  by ASCII input of TOS 3.06)? ->
               and      #$1f00,d2            ; .W = key flags (in high byte)


*------------- decide which translation table to use

               move     d2,d3                ; key flags
               and      #NKFf_SHIFT,d3       ; isolate bits for shift keys
               beq.s    .ktab1               ; shift key pressed? no->

               move.l   pkey_shift,a0        ; yes: use shift table
               bra.s    .ktab3               ; ->

.ktab1:        btst.l   #NKFb_CAPS,d2        ; CapsLock?
               beq.s    .ktab2               ; no->

               move.l   pkey_caps,a0         ; yes: use CapsLock table
               bra.s    .ktab3               ; ->

.ktab2:        move.l   pkey_unshift,a0      ; use unshifted table


*------------- check if Alternate + number: they have simulated scan codes

.ktab3:        cmp.b    #$78,d1              ; scan code of Alt + number?
               blo.s    .scan1               ; no->

               sub.b    #$76,d1              ; yes: calculate REAL scan code
               move.b   (a0,d1),d0           ; fetch ASCII code
               or       #NKFf_ALT,d2         ; set Alternate flag
               bra      .cat_codes           ; -> add flag byte and exit


*------------- check if exception scan code from cursor keypad

.scan1:        lea      xscantab,a1          ; ^exception scan code table

.search_scan:  move     (a1)+,d3             ; NKC and scan code
               bmi.s    .tabend              ; <0? end of table reached ->

               cmp.b    d1,d3                ; scan code found?
               bne.s    .search_scan         ; no: continue search ->

               lsr      #8,d3                ; .B = NKC
               moveq.l  #0,d0                ; mark: key code found
               bra.s    .scan2               ; ->

.tabend:       moveq.l  #0,d3                ; no NKC found yet


*------------- check if rubbish ASCII code and erase it, if so

.scan2:        move.b   (a0,d1),d4           ; ASCII code from translation table
               cmp.b    #32,d0               ; ASCII returned by TOS < 32?
               bhs.s    .scan3               ; no -> can't be rubbish

               cmp.b    d4,d0                ; yes: compare with table entry
               beq.s    .scan3               ; equal: that's ok ->

               moveq.l  #0,d0                ; not equal: rubbish! clear it


*------------- check if ASCII code could only be produced via Alternate key
*              combination

.scan3:        tst.b    d0                   ; ASCII code valid?
               beq.s    .scan4               ; no ->

               cmp.b    d4,d0                ; compare with table entry
               beq.s    .scan4               ; equal: normal key ->

               and      #!NKFf_ALT,d2        ; no: clear Alternate flag


*------------- check if ASCII code found yet, and set it, if not

.scan4:        tst.b    d0                   ; found?
               bne.s    .scan5               ; yes ->

               move.b   d3,d0                ; no: use code from exception table
               bne.s    .scan5               ; now valid? yes ->

               move.b   d4,d0                ; no: use code from transl. table


*------------- check special case: delete key

.scan5:        cmp.b    #127,d0              ; ASCII code of Delete?
               bne.s    .scan6               ; no ->

               move.b   #NK_DEL,d0           ; yes: set according NKC


*------------- check if key is on numeric keypad (via scan code)

.scan6:        cmp.b    #$4a,d1              ; numeric pad scan code range?
               beq.s    .numeric             ; yes ->

               cmp.b    #$4e,d1
               beq.s    .numeric             ; yes ->

               cmp.b    #$63,d1
               blo.s    .scan7               ; no ->

               cmp.b    #$72,d1
               bhi.s    .scan7               ; no ->

.numeric:      or       #NKFf_NUM,d2         ; yes: set numeric bit


*------------- check if "function key" and set bit accordingly

.scan7:        cmp.b    #32,d0               ; ASCII code less than 32?
               bhs.s    .scan8               ; no ->

               or       #NKFf_FUNC,d2        ; yes: set function bit


*------------- check special case: Return or Enter key

               cmp.b    #13,d0               ; Return or Enter key?
               bne.s    .scan8               ; no ->

               btst.l   #NKFb_NUM,d2         ; yes: from the numeric pad?
               beq.s    .scan8               ; no -> it's Return, keep code

               moveq.l  #NK_ENTER,d0         ; yes: it's Enter; new code


*------------- check if function key (F1-F10) via scan code

.scan8:        cmp.b    #$54,d1              ; shift + function key?
               blo.s    .scan9               ; no ->

               cmp.b    #$5d,d1
               bhi.s    .scan9               ; no ->

               sub.b    #$54-$3b,d1          ; yes: scan code for unshifted key
               move     d2,d3                ; shift flags
               and      #NKFf_SHIFT,d3       ; any shift key flag set?
               bne.s    .scan9               ; yes ->
               or       #NKFf_SHIFT,d2       ; no: set both flags

.scan9:        cmp.b    #$3b,d1              ; (unshifted) function key?
               blo.s    .cat_codes           ; no ->

               cmp.b    #$44,d1
               bhi.s    .cat_codes           ; no ->

               move.b   d1,d0                ; yes: calc NKC
               sub.b    #$2b,d0


*------------- final flag handling; mix key code (low byte) and flag byte

.cat_codes:    move.l   pkey_shift,a0        ; ^shifted table
               move.b   (a0,d1),d3           ; get shifted ASCII code
               or       d2,d0                ; mix flags with key code
               bmi.s    .scan10              ; result is "function key"? ->

               and      #NKFf_CTRL+NKFf_ALT,d2  ; Control or Alternate pressed?
               bne.s    .scan11              ; yes ->

.scan10:       move.l   pkey_unshift,a0      ; ^unshifted table
               cmp.b    (a0,d1),d3           ; shifted ASCII = unshifted ASCII?
               beq.s    .scan12              ; yes ->

               bra.s    .exit                ; no ->

.scan11:       or       #NKFf_FUNC,d0        ; Alt/Ctrl + char: set function bit
               move.l   pkey_caps,a0         ; ^CapsLock table
               cmp.b    (a0,d1),d3           ; shifted ASCII = CapsLocked ASCII?
               bne.s    .exit                ; no ->

               move.b   d3,d0                ; yes: use shifted ASCII code

.scan12:       or       #NKFf_RESVD,d0       ; yes: nkc_cmp() has to check
                                             ;  the Shift keys

*------------- restore registers and exit

.exit:         tst      d0                   ; set CCR
               movem.l  (sp)+,d3/d4          ; restore registers
               rts                           ; bye


*------------- special handling for key codes created by TOS' 3.06 ASCII input

.tos306:       and      #NKFf_CAPS,d2        ; isolate CapsLock flag
               or       d2,d0                ; merge with ASCII code
               movem.l  (sp)+,d3/d4          ; restore registers
               rts                           ; bye
