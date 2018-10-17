****************
* Floppy/FDC bindings
****************

.globl    _seek
.globl    _restore
.globl    _read_sector
.globl    _read_address
.globl    _read_track
.globl    _get_status
.globl    _write_sector
.globl    _write_track
.globl    _set_drive

.text

dmamode   = $ff8606
dmascnt   = $ff8604
dmalow    = $ff860d
dmamid    = $ff860b
dmahigh   = $ff8609
giselect  = $ff8800
giwrite   = $ff8802
mfp       = $fffa01

srcmd     = $80
srtrk     = $82
srsec     = $84
srdat     = $86
srcnt     = $90

swcmd     = $180
swtrk     = $182
swsec     = $184
swdat     = $186
swcnt     = $190

see       = $11     ; Seek command
rest	  = $01     ; Restore command
rsec      = $80     ; Read one sector
wsec      = $a0     ; Write one sector
radr      = $c0     ; Read Address
rtrk      = $e0     ; Read track
wtrk      = $f0     ; Write track
forc      = $d0

*    most give back timeout/dma status/fdc status

setup:
     movem.l   d1-d7/a0-a6,savreg
     move.w    #1,$43e
     clr.w     timeout
     clr.w     dma
     clr.w     vblflag
     rts
getout:
     tst.w     vblflag
     beq       letoff
     clr.w     $43e
letoff:
     movem.l   savreg,d1-d7/a0-a6
     rts

_restore:                           *; restore( )
     jsr       setup
     move.w    #rest,d7
     bra       doseek

_seek:                              *; seek( (int) track)
     jsr       setup
     move.w    #srdat,dmamode
     move.w    4(sp),d7
     bsr       wrt1772
     move.w    #see,d7
doseek:				        *; d7 has command
     move.w    #srcmd,dmamode
     bsr       wrt1772
     bsr       fdcwait
     jsr       getout
     rts

_read_sector:          *;read_sector( (i)sector, (i)bytes, (l)add)
     jsr       setup
     move.w    6(sp),_bytes
     move.l    8(sp),d7
     bsr       setdma
     move.w    #1,dma
     move.w    #srcnt,dmamode
     move.w    #swcnt,dmamode
     move.w    #srcnt,dmamode
     move.w    #$0c,d7
     bsr       wrt1772
     move.w    #srsec,dmamode
     move.w    4(sp),d7
     bsr       wrt1772
     move.w    #srcmd,dmamode
     move.w    #rsec,d7
     bsr       wrt1772
     bsr       fdcwait
     bsr       readstat
     jsr       getout
     rts

_read_address:       *;read_address( (i)#fields, (l)idadd, (l)statadd)
     jsr       setup
     move.l    10(sp),a4
     move.l    6(sp),d7
     move.w    4(sp),d4
     and.l     #$7f,d4
     mulu      #6,d4
     move.w    d4,_bytes
     bsr       setdma
     move.w    #srcnt,dmamode
     move.w    #swcnt,dmamode
     move.w    #srcnt,dmamode
     move.w    #$01,d7
     bsr       wrt1772
     move.w    #srcmd,dmamode
     move.w    4(sp),d4
     and.l     #$7f,d4
idloop:
     move.w    #radr,d7
     bsr       wrt1772
     bsr       fdcwait
     move.b    d0,(a4)+
     tst.w     timeout
     dbne      d4,idloop
     bsr       readstat
     jsr       getout
     rts

_read_track:              *;read_track((i)bytes, (l)add)
     jsr       setup
     move.w    4(sp),_bytes
     move.l    6(sp),d7
     bsr       setdma
     move.w    #1,dma
     move.w    #srcnt,dmamode
     move.w    #swcnt,dmamode
     move.w    #srcnt,dmamode
     move.w    #$0e,d7
     bsr       wrt1772
     move.w    #srcmd,dmamode
     move.w    #rtrk,d7
     bsr       wrt1772
     bsr       fdcwait
     bsr       readstat
     jsr       getout
     rts

_write_sector:           *;write_sector((i)sector, (i)bytes, (l)add)
     jsr       setup
     move.w    6(sp),_bytes
     move.l    8(sp),d7
     move.w    4(sp),d4
     bsr       setdma
     move.w    #1,dma
     move.w    #swcnt,dmamode
     move.w    #srcnt,dmamode
     move.w    #swcnt,dmamode
     move.w    #$0c,d7
     bsr       wrt1772
     move.w    #swsec,dmamode
     move.w    d4,d7
     bsr       wrt1772
     move.w    #swcmd,dmamode
     move.w    #wsec,d7
     bsr       wrt1772
     bsr       fdcwait
     bsr       readstat
     jsr       getout
     rts
     
_write_track:             *;write_track( (i)bytes, (l)add)
     jsr       setup
     move.w    4(sp),_bytes
     move.l    6(sp),d7
     bsr       setdma
     move.w    #1,dma
     move.w    #swcnt,dmamode
     move.w    #srcnt,dmamode
     move.w    #swcnt,dmamode
     move.w    #$0e,d7
     bsr       wrt1772
     move.w    #swcmd,dmamode
     move.w    #wtrk,d7
     bsr       wrt1772
     bsr       fdcwait
     bsr       readstat
     jsr       getout
     rts

_get_status:              *;status = get_status()
     jsr       setup
     move.w    #srcmd,dmamode
     bsr       read1772
     and.w     #$ff,d0
     jsr       getout
     rts

force:
     move.w    #forc,d7
     bsr       wrt1772
     move.w    #$100,d7
wtfrc:
     dbra      d7,wtfrc
     rts

setdma:
     move.l    d7,startadd
     move.b    d7,dmalow      ;d7 gives address, d6 gives #bytes
     lsr.l     #8,d7
     move.b    d7,dmamid
     lsr.l     #8,d7
     move.b    d7,dmahigh
     move.l    startadd,d7
     clr.l     d6
     move.w    _bytes,d6
     add.l     d6,d7
     move.l    d7,endadd
     rts

readstat:
     move.w    dmamode,d1
     and.w     #$7,d1
     lsl.w     #8,d1
     or.w      d1,d0
     clr.l     d1
     move.b    dmahigh,d1
     lsl.l     #8,d1
     move.b    dmamid,d1
     lsl.l     #8,d1
     move.b    dmalow,d1
     move.l    d1,endadd
     sub.l     startadd,d1
     move.w    d1,_bytes
     rts

wrt1772:
     bsr       wait
     move.w    d7,dmascnt
     bsr       wait
     rts

read1772:
     bsr       wait
     move.w    dmascnt,d0
     bsr       wait
     rts

fdcwait:
     move.l    #$180,d5
litlwt:
     dbra      d5,litlwt
     move.l    #$40000,d5

readmfp:
     btst      #5,mfp
     beq       fdcready
     subq.l    #1,d5
     beq       ttimeout
     tst.w     dma
     beq       readmfp
     move.b    dmahigh,temp+1
     move.b    dmamid,temp+2
     move.b    dmalow,temp+3
     move.l    temp,d7
     cmp.l     endadd,d7     
     blt       readmfp
     bsr       force
     clr.w     dma
     bra       fdcready
ttimeout:
     move.w    dmascnt,d0
     and.w     #$ff,d0
     bsr       force
     bset      #11,d0
     move.w    #1,timeout
     rts
fdcready:
     move.w    dmascnt,d0
     and.w     #$ff,d0
     rts

motoroff:
     move.w    #srcmd,dmamode
test:
     bsr       read1772
     btst      #7,d0
     bne       test
     rts

wait:
     move.w    sr,-(a7)
     move.w    #$20,d5
wt2:
     dbf       d5,wt2
     move.w    (a7)+,sr
     rts

_set_drive:                    *; set_drive( (int) drive)
     jsr       setup
     clr.l     d7
     move.w    4(sp),d7
     bne       set
     bsr       motoroff
     move.w    #1,vblflag
set:
     eor.b     #7,d7
     and.b     #7,d7
     move.w    sr,-(a7)
     or.w      #$700,sr
     move.b    #$e,giselect
     move.b    giselect,d0
     and.b     #$f8,d0
     or.b      d0,d7
     move.b    d7,giwrite
     move.w    (a7)+,sr
     jsr       getout
     rts

.data

temp      dc.l 0
dma       dc.w 0
vblflag   dc.w 0
timeout   dc.w 0
startadd  dc.l 0
endadd    dc.l 0
savreg    ds.l 16,0
