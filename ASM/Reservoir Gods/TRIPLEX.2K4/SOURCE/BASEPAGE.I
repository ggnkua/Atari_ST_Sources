;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                RSRESET                 ;DTA
d_reserved:     RS.B 1
d_attrib:       RS.B 1
d_time:         RS.W 1
d_date:         RS.W 1
d_length:       RS.L 1
d_fname:        RS.B 14
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                RSRESET                 ;BASEPAGE definition
p_lowtpa:       RS.L 1                  ;TPA startadresse
p_hipta:        RS.L 1                  ;TPA endadresse+1
p_tbase:        RS.L 1                  ;TEXT startadresse
p_tlen:         RS.L 1                  ;TEXT length
p_dbase:        RS.L 1                  ;DATA startadresse
p_dlen:         RS.L 1                  ;DATA length
p_bbase:        RS.L 1                  ;BSS startadresse
p_blen:         RS.L 1                  ;BSS length
p_dta:          RS.L 1                  ;pointer to default DTA
p_parent:       RS.L 1                  ;pointer to BASEPAGE of calling process
p_env:          RS.L 1                  ;pointer to ENVIRONMENT strings
p_devx:         RS.B 6                  ;real handles of the 6 standart channels
p_defdrv:       RS.B 1                  ;default DRIVENR
p_cmdlin:       RS.B 128                ;COMMANDLINE
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                move.l  SP,old_sp
                bsr.s   path_n_cmdlin_init
                tst.b   cmdline_flag
                bra     cmdline_exit
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
old_sp:         DS.L 1
basepage:       DS.L 1
cmdline_flag:   DS.B 1
                EVEN
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
path_n_cmdlin_init:
                sf      cmdline_flag       ;assume there is no cmdline passed

                movea.l old_sp(PC),A0
                movea.l 4(A0),A0           ;get Basepage Adress
                move.l  A0,basepage

                move.w  #$19,-(SP)         ;Dgetdrv() get default drive
                trap    #1
                addq.w  #2,SP
                move.w  D0,driveno

                clr.w   -(SP)              ;get path of default drive
                pea     cmdpath(PC)
                move.w  #$47,-(SP)         ;Dgetpath()
                trap    #1
                addq.w  #8,SP

                movea.l basepage(PC),A0    ;examine commandline
                lea     $81(A0),A0
                lea     fname(PC),A1
                bsr     ctxt               ;copy string

                cmpa.l  #fname+1,A1
                beq.s   .no_cmdline
                st      cmdline_flag
                bsr     mk_realfname
.no_cmdline:
                pea     dta(PC)            ;set dta
                move.w  #$1A,-(SP)         ;Fsetdta()
                trap    #1
                addq.w  #6,SP
                rts
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
dta:            DS.B 44
driveno:        DS.W 1
cmdpath:           DS.B $0100
fname:          DS.B 15
realfname:      DS.B $010F
                EVEN
;-------------------------------------------------------------------------------
mk_realfname:   lea     realfname(PC),A1
                move.w  driveno(PC),D0
                add.b   #'A',D0
                move.b  D0,(A1)+
                move.b  #':',(A1)+
                lea     cmdpath(PC),A0
                bsr.s   ctxt_noterm
                move.b  #'\',(A1)+
                lea     fname(PC),A0
                bsr.s   ctxt
                rts
;-------------------------------------------------------------------------------
ctxt:           move.b  (A0)+,(A1)+
                bne.s   ctxt
                rts
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
ctxt_noterm0:   move.b  (A0)+,(A1)+
ctxt_noterm:    tst.b   (A0)
                bne.s   ctxt_noterm0
                rts
;-------------------------------------------------------------------------------
cmdline_exit:	;put your code here