
first:          rts

CHEAD forth_wordlist, 8
forth_wordlist: *		( -- wid )
				move.l #(last_forth-datas),-(A6)	;move wid to stack
xforth_wordlist: 	rts


*****************************************************************
*                >PART 'I/O-words'
*****************************************************************

CHEAD lcaccept, 0
lcaccept:       	moveq.l	#0,d3
                move.l  (A6)+,D2        ;get count
                move.l  (A6)+,D1        ;get address(offset)
                dbra    D2,acc_loop
acc_loop:		bsr     key

                addq.l  #1,d3   		;increase span
                cmpi.b  #CR,3(A6)       ;is character a cr?
                beq     abort_acc     ;then exit
                cmpi.b  #BKSP,3(A6)     ;maybe a backspace?
                bne.s   acc_emit      ;if not, then EMIT the character
                addq.l  #1,D2           ;increase counter
                clr.b   0(A3,D1.l)      ;clear character
*                subq.l  #1,0(A3,D0.l)   ;SPAN--
				subq.l	#1,d3
				bne.s	acc_bksp
				addq.l	#4,a6
				bra		acc_noemit
				
acc_bksp:   movem.l D1-D3,-(SP)     ;save registers
                move.l  D5,D0
                addi.l  #oecho,D0
                tst.l   0(A3,D0.l)
                beq.s   acc_noecho1
                move.l  #BKSP,-(A6)     ;we want to emit backspace
                bsr     emit            ;do the emit
                move.l  #$20,-(A6)      ;we want to emit space
                bsr     emit            ;do the emit
                bsr     emit            ;second BKSP
                bra.s   acc_goon1
acc_noecho1:  addq.l  #4,A6
acc_goon1:    movem.l (SP)+,D1-D3     ;restore registers

                subq.l  #1,D1           ;decrease pointer
                clr.b   0(A3,D1.l)      ;clear character
                subq.l  #1,d3  			;decrease span
                bra.s   acc_loop

acc_emit:     move.b  3(A6),0(A3,D1.l)
                addq.l  #1,D1
                movem.l D1-D3,-(SP)
                move.l  D5,D0
                addi.l  #oecho,D0
                tst.l   0(A3,D0.l)
                beq.s   acc_noecho2
                bsr     emit
                bra.s   acc_goon2
acc_noecho2:  addq.l  #4,A6
acc_goon2:    movem.l (SP)+,D1-D3
acc_noemit:   dbra    D2,acc_loop
				
				move.l	d3,-(a6)
acc_ignore:		bsr 	key
				addq.l	#4,a6
                cmpi.b  #CR,-1(A6)       ;is character a cr?
                beq     acc_end     ;then exit
				bra		acc_ignore
acc_end:      	rts

abort_acc:    	*subq.l  #1,D1           ;decrease pointer
                subq.l  #1,d3   ;decrease span
               	move.l  d3,(A6)           ;DROP
xlcaccept:		rts


*-------------------------------------------------------
CHEAD lctype, 0
lctype:         move.l  (A6)+,D2        ;count
                move.l  (A6)+,D1        ;address
                dbra    D2,lctype_loop
                bra.s   lctype_end
lctype_loop:    tst.b   0(A3,D1.l)
                beq.s   lctype_end
                clr.l   -(A6)
                move.b  0(A3,D1.l),3(A6)
                addq.l  #1,D1
                movem.l D1-D2,-(SP)
                bsr     emit
                movem.l (SP)+,D1-D2
                dbra    D2,lctype_loop
lctype_end:
xlctype:	     rts

*                ENDPART

*****************************************************************
*                >PART 'some system words'
*-------------------------------------------------------
CHEAD bye, 0
bye:            movea.l (saveret-datas)(A3),SP
                move.l  (bootsys-datas)(A3),-(SP)
xbye:           rts


*-------------------------------------------------------
CHEAD b_cold, 0
b_cold:         move.l  #(tcold-datas),-(A6)
xb_cold:        rts

*-------------------------------------------------------
CHEAD systop, 8
systop:         move.l  (tsystop-datas)(A3),-(A6)
xsystop:        rts


*-------------------------------------------------------
CHEAD sysbot, 8
sysbot:         move.l  (tsysbot-datas)(A3),-(A6)
xsysbot:        rts


*-------------------------------------------------------
CHEAD datatop, 8
datatop:        move.l  (tdatatop-datas)(A3),-(A6)
xdatatop:       rts


*-------------------------------------------------------
CHEAD databot, 8
databot:        move.l  (tdatabot-datas)(A3),-(A6)
xdatabot:       rts

*-------------------------------------------------------
CHEAD forthparas, 0
forthparas:     move.l  (tforthparas-datas)(A3),-(A6)
xforthparas:    rts

*-------------------------------------------------------
CHEAD b_front_opt, 0
b_front_opt:    move.l  #(tfront_opt-datas),-(A6)
xb_front_opt:   rts


*-------------------------------------------------------
CHEAD b_end_opt, 0
b_end_opt:      move.l  #(tend_opt-datas),-(A6)
xb_end_opt:     rts


*-------------------------------------------------------
CHEAD noop, 0
noop:           
xnoop:		rts

*-------------------------------------------------------

*
* some internal system constants
*

CHEAD ver, 0
ver:            move.l  #version,-(A6)
xver:           rts



CHEAD codeheadsize, 8
codeheadsize:	move.l	#cheadsize,-(a6)
xcodeheadsize:	rts


CHEAD blankbits, 8
blankbits:		move.l	#(whitespace-datas),-(a6)
xblankbits: 	rts


*                ENDPART

*****************************************************************
*                >PART 'USER variables'

CHEAD nextuser, 8
nextuser:       move.l  D5,-(A6)        ;2 Bytes
                addi.l  #onextuser,(A6)    ;6
xnextuser:      rts                     ;--------
;8 Bytes = 4 words


CHEAD r_null, 8
r_null:         move.l  D5,-(A6)
                addi.l  #ornull,(A6)
xr_null:        rts


CHEAD s_null, 8
s_null:         move.l  D5,-(A6)
                addi.l  #osnull,(A6)
xs_null:        rts


CHEAD f_null, 8
f_null:         move.l  D5,-(A6)
                addi.l  #ofnull,(A6)
xf_null:        rts


CHEAD state, 8
state:          move.l  D5,-(A6)
                addi.l  #ostate,(A6)
xstate:         rts


CHEAD b_number_quest, 8
b_number_quest: move.l  D5,-(A6)
                addi.l  #onumber_quest,(A6)
xb_number_quest: rts

 
CHEAD base, 8
base:           move.l  D5,-(A6)
                addi.l  #obase,(A6)
xbase:          rts



CHEAD cp, 8      
cp:             move.l  D5,-(A6)
                addi.l  #odp,(A6)
xcp:            rts

    
CHEAD dp, 8    
dp:             move.l  D5,-(A6)
				addi.l  #odata,(A6)
xdp:            rts

    
CHEAD totib, 8
totib:          move.l  D5,-(A6)
                addi.l  #ototib,(A6)
xtotib:          rts


CHEAD _tib, 8
_tib:           move.l  D5,-(A6)
                addi.l  #o_tib,(A6)
x_tib:          rts


CHEAD toin, 8
toin:           move.l  D5,-(A6)
                addi.l  #otoin,(A6)
xtoin:          rts



CHEAD toevaluateib, 8
toevaluateib:	move.l  D5,-(A6)
                addi.l  #otoevaluateib,(A6)
xtoevaluateib:	rts



CHEAD _evaluateib, 8
_evaluateib:	move.l  D5,-(A6)
                addi.l  #o_evaluateib,(A6)
x_evaluateib:	rts


      
CHEAD tofileib, 8
tofileib:		move.l  D5,-(A6)
                addi.l  #otofileib,(A6)
xtofileib:		rts
 
 
 
CHEAD _fileib, 8
_fileib:		move.l  D5,-(A6)
                addi.l  #o_fileib,(A6)
x_fileib:		rts
 
 
CHEAD p_blocksource, 8
p_blocksource:	move.l  D5,-(A6)
                addi.l  #op_blocksource,(A6)
xp_blocksource:	rts
       
    
      
CHEAD tosourceid, 8
tosourceid:		move.l  D5,-(A6)
                addi.l  #otosourceid,(A6)
xtosourceid:		rts
       
      
      
CHEAD current, 8
current:        move.l  D5,-(A6)
                addi.l  #ocurrent,(A6)
xcurrent:       rts

         
CHEAD vocpa, 8         
vocpa:          move.l  D5,-(A6)
                addi.l  #ovocpa,(A6)
xvocpa:         rts

        
CHEAD last, 8
last:           move.l  D5,-(A6)
                addi.l  #olast,(A6)
xlast:          rts


CHEAD abortqmess, 8
abortqmess:     move.l  D5,-(A6)
                addi.l  #oabortqmess,(A6)
xabortqmess:	rts

  
CHEAD abortqcnt, 8
abortqcnt:     	move.l  D5,-(A6)
                addi.l  #oabortqcnt,(A6)
xabortqcnt:		rts

  
CHEAD errorqmess, 8
errorqmess:     move.l  D5,-(A6)
                addi.l  #oerrorqmess,(A6)
xerrorqmess:	rts

  


CHEAD p_errorhandler, 8
p_errorhandler: move.l  D5,-(A6)
                addi.l  #op_errorhandler,(A6)
xp_errorhandler: rts

   
      
         
CHEAD b_key, 8         
b_key:          move.l  D5,-(A6)
                addi.l  #okey,(A6)
xb_key:         rts

       
CHEAD b_emit, 8       
b_emit:         move.l  D5,-(A6)
                addi.l  #oemit,(A6)
xb_emit:        rts

        
CHEAD b_key_quest, 8        
b_key_quest:    move.l  D5,-(A6)
                addi.l  #okey_quest,(A6)
xb_key_quest:   rts

             
CHEAD t_key, 8             
t_key:          move.l  D5,-(A6)
                addi.l  #olkey,(A6)
xt_key:         rts

       
CHEAD t_emit, 8
t_emit:         move.l  D5,-(A6)
                addi.l  #olemit,(A6)
xt_emit:        rts

         
CHEAD t_key_quest, 8         
t_key_quest:    move.l  D5,-(A6)
                addi.l  #olkey_quest,(A6)
xt_key_quest:   rts


CHEAD t_emit_quest, 8         
t_emit_quest:    move.l  D5,-(A6)
                addi.l  #olemit_quest,(A6)
xt_emit_quest:   rts


CHEAD b_accept, 8
b_accept:       move.l  D5,-(A6)
                addi.l  #oaccept,(A6)
xb_accept:      rts


CHEAD b_type, 8
b_type:         move.l  D5,-(A6)
                addi.l  #otype,(A6)
xb_type:        rts


CHEAD p_find, 8
p_find:         move.l  D5,-(A6)
                addi.l  #ofind,(A6)
xp_find:        rts


CHEAD p_parser, 8
p_parser:		move.l  D5,-(A6)
				addi.l  #oparser,(A6)
xp_parser:		rts


           
CHEAD b_fliteral, 8           
b_fliteral:     move.l  D5,-(A6)
                addi.l  #ofliteral,(A6)
xb_fliteral:    rts


CHEAD macro, 8
macro:          move.l  D5,-(A6)
                addi.l  #omacro,(A6)
xmacro:         rts


CHEAD is_macro, 8
is_macro:       move.l  D5,-(A6)
                addi.l  #ois_macro,(A6)
xis_macro:      rts


CHEAD warning, 8
warning:        move.l  D5,-(A6)
                addi.l  #owarning,(A6)
xwarning:       rts


CHEAD out, 8
out:            move.l  D5,-(A6)
                addi.l  #oout,(A6)
xout:           rts


CHEAD fwidth, 8
fwidth:         move.l  D5,-(A6)
                addi.l  #ofwidth,(A6)
xfwidth:        rts

        
CHEAD blk, 8
blk:            move.l  D5,-(A6)
                addi.l  #oblk,(A6)
xblk:           rts


CHEAD userbufs, 8
userbufs:       move.l  D5,-(A6)
                addi.l  #ouserbufs,(A6)
xuserbufs:      rts



CHEAD echo, 8
echo:           move.l  D5,-(A6)
                addi.l  #oecho,(A6)
xecho:          rts

      
CHEAD udp, 8
udp:            move.l  D5,-(A6)
                addi.l  #oudp,(A6)
xudp:           rts


*-----------------------------------------------------------

CHEAD pad, 0
pad:            move.l  D5,D0           ;2
                addi.l  #odata,D0       ;6
                move.l  0(A3,D0.l),D0   ;2
                move.l  D0,D1
                andi.l  #1,D0
                add.l   D1,D0
                addi.l  #$0100,D0
                move.l  D0,-(A6)        ;6
xpad:           rts


CHEAD here, 0
here:           move.l  D5,D0
                addi.l  #odata,D0
                move.l  0(A3,D0.l),-(A6)
xhere:          rts

*                ENDPART

*****************************************************************
*                >PART 'executing the words in vectors'
*-----------------------------------------------------------
CHEAD number_quest, 0
number_quest:   move.l  D5,D0           ;2
                addi.l  #onumber_quest,D0 ;6
                move.l  0(A3,D0.l),D0   ;2
                jsr     0(A5,D0.l)      ;2
xnumber_quest:  rts

*-----------------------------------------------------------
CHEAD loaderkey, 0
loaderkey:                              * jsr     (pause-sys-of)(A5)
                movem.l D1-A6,-(SP)
                move.l  (tforthparas-datas)(A3),D0
                pea     0(A3,D0.l)
                move.l  D5,D0
                addi.l  #olkey,D0
                movea.l 0(A3,D0.l),A0
                jsr     (A0)
                addq.l  #4,SP
                movem.l (SP)+,D1-A6
                move.l  D0,-(A6)
xloaderkey:     rts

*-----------------------------------------------------------
CHEAD loaderemit, 0
loaderemit:                             *jsr     (pause-sys-of)(A5)
                movem.l D1-A6,-(SP)
                move.l  (tforthparas-datas)(A3),D0
                pea     0(A3,D0.l)
                move.l  (A6),-(SP)
                move.l  D5,D0
                addi.l  #olemit,D0
                movea.l 0(A3,D0.l),A0
                jsr     (A0)
                addq.l  #8,SP
                movem.l (SP)+,D1-A6
                addq.l  #4,A6
                move.l  D5,D0
                addi.l  #oout,D0
                addq.l  #1,0(A3,D0.l)   ;increase OUT
xloaderemit:    rts

*-----------------------------------------------------------
CHEAD loaderkey_quest, 0
loaderkey_quest:                        *jsr     (pause-sys-of)(A5)
                movem.l D1-A6,-(SP)
                move.l  (tforthparas-datas)(A3),D0
                pea     0(A3,D0.l)
                move.l  D5,D0
                addi.l  #olkey_quest,D0
                movea.l 0(A3,D0.l),A0
                jsr     (A0)
                addq.l  #4,SP
                movem.l (SP)+,D1-A6
                move.l  D0,-(A6)
xloaderkey_quest: rts


*-----------------------------------------------------------
CHEAD key, 0
key:            
                move.l  D5,D0
                addi.l  #okey,D0
                move.l  0(A3,D0.l),D0
                jmp     0(A5,D0.l)
xkey:


CHEAD key_quest, 0
key_quest:      
                move.l  D5,D0
                addi.l  #okey_quest,D0
                move.l  0(A3,D0.l),D0
                jmp     0(A5,D0.l)
xkey_quest:

           
CHEAD emit, 0
emit:           
                move.l  D5,D0
                addi.l  #oemit,D0
                move.l  0(A3,D0.l),D0
                jmp     0(A5,D0.l)
xemit:


      
CHEAD accept, 0
accept:         
                move.l  D5,D0
                addi.l  #oaccept,D0
                move.l  0(A3,D0.l),D0
                jmp     0(A5,D0.l)
xaccept:

*-----------------------------------------------------------
CHEAD type, 0
type:           
                move.l  D5,D0
                addi.l  #otype,D0
                move.l  0(A3,D0.l),D0
                jmp     0(A5,D0.l)
xtype:

*---------------------------------------------------------------



*                ENDPART

*****************************************************************
*                >PART 'Compiler stuff'
*                                                               *
*****************************************************************
CHEAD komma, 0
komma:          move.l  D5,D0           ;( value -- )
                addi.l  #odata,D0
                move.l  0(A3,D0.l),D1
                move.l  D1,D2
                andi.l  #1,D2
                add.l   D2,D1           ;make DP even
                move.l  (A6)+,0(A3,D1.l) ;32b
                addq.l  #4,D1           ;increment
                move.l  D1,0(A3,D0.l)   ;new DP
xkomma:         rts


* this is not a Forth word:
get_segment:    movem.l D0-D2,-(SP)     ;( addr -- codeoff segtableoff )
                move.l  #-1,D0          ;init segment counter
                move.l  (A6)+,D1        ;get addr
                addi.l  #of,D1          ;make addr positiv
g_s_loop:       addq.l  #1,D0           ;increase segment counter
                move.l  D1,D2
                subi.l  #$010000,D1     ;decrease address by 64k
                andi.l  #$FFFF0000,D2   ;is it < 64k
                bne.s   g_s_loop        ;no? then try next segment
                addi.l  #($010000-of),D1 ;take back last decrement
                move.l  D1,-(A6)        ;push codeoffset
                move.l  #(table-datas),D1 ;table base
                lsl.l   #2,D0           ;*4, pointer to LONGs
                add.l   D1,D0           ;rel. tableaddress
                move.l  D0,-(A6)        ;push pointer to segment (in data)
                movem.l (SP)+,D0-D2
                rts

*                ENDPART

*****************************************************************
*                >PART 'JSR, creates code'
*                     of defined length (8 bytes)               *
*                                                               *
*       movea.l segoff(DT),seg          ( seg = A2 )            *
*       jsr     codeoff(seg)                                    *
*                                                               *
*****************************************************************
CHEAD jsr_komma, 0		* ( xt -- ) 
jsr_komma:      ;( addr -- )
				movem.l D1-D2,-(SP)
                move.l  D5,D0           
                addi.l  #odp,D0
                move.l  0(A3,D0.l),D1   ;fetch DP
                
                move.l  D1,D2
                andi.l  #1,D2
                add.l   D2,D1           ;make DP even
                
                lea     0(A5,D1.l),A0   ;calculate absolute address
                bsr.s   get_segment     ;calculate seg & off
                move.w  #move_seg_code,0(A5,D1.l) ;create opcode ...
                addq.l  #2,A6
                move.w  (A6)+,2(A5,D1.l) ;... with it's argument
                move.w  #jsr_code,4(A5,D1.l) ;create opcode ...
                addq.l  #2,A6
                move.w  (A6)+,6(A5,D1.l) ;... with it's argument
                addq.l  #8,D1
                move.l  D1,0(A3,D0.l)   ;new DP
                movem.l (SP)+,D1-D2
xjsr_komma:     rts

*                ENDPART

*****************************************************************
*                >PART 'THE COMPILER'
*                                                                       *
*************************************************************************
CHEAD com_komma, 0		* ( xt -- )						( CORE EXT )
com_komma:      movem.l D0-D2/A0-A1,-(SP) 
                move.l  (tfront_opt-datas)(A3),D0 ;front_OPT
                jsr     0(A5,D0.l)      ;execute

                move.l  D5,D0
                addi.l  #odp,D0
                move.l  0(A3,D0.l),D1   ;fetch DP

                move.l  D1,D2
                andi.l  #1,D2
                add.l   D2,D1           ;make DP even

                move.l  D5,D0
                addi.l  #omacro,D0
                tst.l   0(A3,D0.l)      ;compile as a macro?
                beq.s   com_no_macro    ;not? ok!


	* compilation of a macro
                move.l  (A6),D0         ;cfa to d0
			    btst    #3,-1(A5,D0.l)  ;macrobit set?
                beq.s   com_no_macro    ;wenn nicht, dann normal kompilieren
                addq.l  #4,A6           ;drop cfa
   	 			move.b  -2(A5,D0.l),D2  ;CodelÑnge holen (#Worte)
                and.l   #$FF,D2         ;maskieren
                movea.l A5,A0
				adda.l  D0,A0   	;> abs. address

                dbra    D2,com_macro_loop
                bra     com_kom_end
com_macro_loop: move.w  (A0)+,0(A5,D1.l) ;Code wortweise Åbertragen
                addq.l  #2,D1
                dbra    D2,com_macro_loop
                bra     com_kom_end

com_no_macro:   move.l  (A6),D0         ;cfa
                move.l  D5,D0
                addi.l  #ois_macro,D0
                tst.l   0(A3,D0.l)      ;soll es ein Macro werden?
                bne.s   com_no_bsr      ;dann darf kein BSR kompiliert werden
                move.l  D1,D0
                addq.l  #2,D0
                sub.l   (A6),D0         ;rel. Adressdistanz
                cmp.l   #$80,D0         ;>128 Byte
                bpl.s   no_bsr_word
                neg.b   D0
                addq.l  #4,A6
                move.b  #bsrb_code,0(A5,D1.l)
                move.b  D0,1(A5,D1.l)
                addq.l  #2,D1
                bra.s   com_kom_end
no_bsr_word:    cmp.l   #$8000,D0       ;>32k?
                bpl.s   com_no_bsr      ;dann kompiliere direkten Sprung
                neg.w   D0              ;Sprung soll zurÅck fÅhren
                addq.l  #4,A6           ;drop adr
                move.w  #bsr_code,0(A5,D1.l)
                move.w  D0,2(A5,D1.l)
                addq.l  #4,D1
                bra.s   com_kom_end

com_no_bsr:     bsr     get_segment
                move.l  (A6)+,D0        ;get pointer to segment
                cmpi.l  #(table-datas),D0 ;segment = rootsegment?
                beq.s   com_jsr_SB
                move.w  #move_seg_code,0(A5,D1.l) ;create opcode ...
                move.w  D0,2(A5,D1.l)   ;... with it's argument
                addq.l  #4,D1
com_jsr_seg:    move.w  #jsr_code,0(A5,D1.l) ;create opcode ...
                addq.l  #2,A6
                move.w  (A6)+,2(A5,D1.l) ;... with it's argument
                addq.l  #4,D1
                bra.s   com_kom_end
com_jsr_SB:     move.w  #jsrSB_code,0(A5,D1.l) ;create opcode ...
                addq.l  #2,A6
                move.w  (A6)+,2(A5,D1.l) ;... with it's argument
                addq.l  #4,D1

com_kom_end:    move.l  D5,D0
                addi.l  #odp,D0
                move.l  D1,0(A3,D0.l)
                move.l  (tend_opt-datas)(A3),D0 ;front_OPT
                jsr     0(A5,D0.l)      ;execute

                movem.l (SP)+,D0-D2/A0-A1
xcom_komma:     rts

*                ENDPART

*****************************************************************
*                >PART 'compiler utilities, used later'
*                                                               *
*****************************************************************
CHEAD code_komma, 0
code_komma:     move.l  D5,D0
                addi.l  #odp,D0
                move.l  0(A3,D0.l),D1
                move.l  (A6)+,0(A5,D1.l)
                addi.l  #4,0(A3,D0.l)
xcode_komma:    rts

CHEAD code_wkomma, 0
code_wkomma:    move.l  D5,D0
                addi.l  #odp,D0
                move.l  0(A3,D0.l),D1
                addq.l  #2,A6
                move.w  (A6)+,0(A5,D1.l)
                addq.l  #2,D1
                move.l  D1,0(A3,D0.l)
xcode_wkomma:   rts


CHEAD jsrSB_komma, 0
jsrSB_komma:    move.l  D5,D0           ;( codeaddr -- )
                addi.l  #odp,D0
                move.l  0(A3,D0.l),D1
                move.w  #jsrSB_code,0(A5,D1.l)
                addq.l  #2,A6
                move.w  (A6)+,2(A5,D1.l)
                addq.l  #4,D1
                move.l  D1,0(A3,D0.l)
xjsrSB_komma:   rts




CHEAD wkomma, 0
wkomma:         move.l  D5,D0           ;( value16 -- )
                addi.l  #odata,D0
                move.l  0(A3,D0.l),D1
                move.l  D1,D2
                andi.l  #1,D2
                add.l   D2,D1           ;make DP even
                addq.l  #2,A6           ;stack: long>word
                move.w  (A6)+,0(A3,D1.l) ;16b
                addq.l  #2,D1           ;increment
                move.l  D1,0(A3,D0.l)   ;new DP
xwkomma:        rts


CHEAD ckomma, 0
ckomma:         move.l  D5,D0           ;( value8 -- )
                addi.l  #odata,D0
                move.l  0(A3,D0.l),D1   ;fetch DP
                addq.l  #3,A6           ;
                move.b  (A6)+,0(A3,D1.l) ;8b
                addq.l  #1,D1           ;increment
                move.l  D1,0(A3,D0.l)   ;new DP
xckomma:        rts


CHEAD fkomma, 0
fkomma:         move.l  D5,D0
                addi.l  #odata,D0
                move.l  0(A3,D0.l),D1   ;fetch DP
                move.l  D1,D2
                andi.l  #1,D2
                add.l   D2,D1           ;make DP even
                move.l  D5,D0
                addi.l  #ofwidth,D0
                move.l  0(A3,D0.l),D0
                lsr.l   #2,D0
                subq.l  #1,D0
f_komma_loop:   move.l  (A4)+,0(A3,D1.l)
                addq.l  #4,D1
                dbra    D0,f_komma_loop
                move.l  D5,D0
                addi.l  #odata,D0
                move.l  D1,0(A3,D0.l)
xfkomma:        rts

*                ENDPART

*****************************************************************
*                >PART 'Arithmetic'
*****************************************************************
CHEAD plus_store, 0
plus_store:     move.l  (A6)+,D1
                move.l  0(A3,D1.l),D0
                add.l   (A6)+,D0
                move.l  D0,0(A3,D1.l)
xplus_store:    rts

            
CHEAD plus, 8
plus:           move.l  (A6)+,D0
                add.l   D0,(A6)
xplus:          rts


CHEAD m_plus, 8		* ( d1 n -- d2 )    ( DOUBLE EXT )
m_plus:			move.l	(a6)+,d0	; n
				move.l	(a6)+,d1	; d-high
				moveq	#0,d2
				add.l	d0,(a6)
				addx.l	d2,d1
				move.l	d1,-(a6)
xm_plus:		rts
				
      
CHEAD minus, 8
minus:          move.l  (A6)+,D0
                sub.l   D0,(A6)
xminus:         rts

        
CHEAD mult, 0
mult:           move.l  (A6)+,D0
                move.l  (A6),D1
                move.l  D0,D2
                move.l  D0,D3
                swap    D3
                move.l  D1,D4
                swap    D4
                mulu    D1,D0
                mulu    D3,D1
                mulu    D4,D2
                swap    D0
                add.w   D1,D0
                add.w   D2,D0
                swap    D0
                move.l  D0,(A6)
xmult:          rts


CHEAD um_mult, 0	* ( u1 u2 -- ud )
um_mult:		movem.w	(a6)+,d0-d3		;get the two operands wordwise
				move.w	d1,d4
				mulu	d3,d1
				mulu	d0,d3
				mulu	d2,d0
				mulu	d4,d2
				moveq	#0,d4
				swap	d0
				add.l	d3,d2
				addx.l	d4,d0
				swap	d0
				swap	d1
				add.w	d2,d1
				clr.w	d2
				swap	d2
				addx.l	d2,d0
				swap	d1
				move.l	d1,-(a6)	;lower word
				move.l	d0,-(a6)	;higher word
xum_mult:		rts



CHEAD m_mult, 0
m_mult:			moveq	#0,d0
				tst.l	(a6)
				bpl.s	mult_pos
				neg.l	(a6)
				not.l	d0
				
mult_pos:		tst.l	4(a6)
				bpl.s	mult_pos2
				neg.l	4(a6)					
				not.l	d0
				
mult_pos2:		move.l	d0,-(a7)
				bsr		um_mult
				move.l	(a7)+,d0
				
				tst.l	d0
				bpl.s	mult_notneg
				
				neg.l	4(a6)
				negx.l	(a6)	
mult_notneg:				
xm_mult:		rts


* 
* divisions
*


m_divmoderr:	tst.l	d0
				bne		mdm_overflow
				move.l	#-10,-(a6)		* division by zero
				bsr		throw
mdm_overflow:	move.l	#-11,-(a6)		* result out of range		
				bsr		throw




mdm_primi:		
				move.l	d0,d4
				bpl.s	d0notneg
				neg.l	d0
d0notneg:		move.l	d1,d3
				bpl.s	umdm_primi
				neg.l	d4
				neg.l	d2
				negx.l	d1

umdm_primi:		cmp.l	D0,D1           
				bcc.s	m_divmoderr        
				cmpi.l	#$FFFF,D0       
				bhi.s	umdm_notsimple         
				swap	d2              
				swap	d1              
				move.w	d2,d1           
				divu	d0,d1           
				move.w	D1,D2           
				swap	D2              
				move.w	D2,D1           
				divu	D0,D1           
				move.w	D1,D2           
				swap	D1              
				ext.l	D1              
				rts
				
umdm_notsimple: move.l	d4,-(a7)
				moveq.l	#31,D4         
umdm_loop:		add.l	d2,d2           
   				addx.l	d1,d1           
				bcs.s	umdm_sub       
				cmp.l	D0,D1           
				bcs.s	umdm_next         
umdm_sub:		sub.l	D0,D1           
				addq.l	#1,D2
umdm_next:		dbf		D4,umdm_loop
				move.l	(a7)+,d4
				rts



CHEAD um_divmod, 0		* ( ud un -- rem quot )
um_divmod:		movem.l	(a6)+,d0-d2
				bsr		umdm_primi
				move.l	d1,-(a6)
				move.l	d2,-(a6)
xum_divmod:		rts



CHEAD fm_divmod, 0		* ( d n -- rem quot )
fm_divmod:		movem.l	(a6)+,d0-d2
				bsr		mdm_primi

*				tst.l	d2
*				bmi		m_divmoderr
* removed this test, because it misleads in the case 
* $80000000 -1 1 FM/MOD
* JPS, 5jan94

	lsl.l	#1,d4
	bcc		fm_divmod2
	beq		fm_divmod2
				tst.l	d1
				beq.s	fm_divmod1
				addq.l	#1,d2
				sub.l	d0,d1
fm_divmod1:		neg.l	d2		
fm_divmod2:
	lsl.l	#1,d3
	bcc		fm_divmodok
	beq		fm_divmodok
				neg.l	d1
				
*				tst.l	d4
*				bpl.s	fm_divmod2
*				tst.l	d1
*				beq.s	fm_divmod1
*				addq.l	#1,d2
*				sub.l	d0,d1
*fm_divmod1:		neg.l	d2		
*fm_divmod2:		tst.l	d3
*				bpl.s	fm_divmodok
*				neg.l	d1
				
				
fm_divmodok:	move.l	d1,-(a6)
				move.l	d2,-(a6)
xfm_divmod:		rts



CHEAD sm_divrem, 0		* ( d n -- rem quot )
sm_divrem:		movem.l	(a6)+,d0-d2
				bsr		mdm_primi
*				tst.l	d2
*				bmi		m_divmoderr
* removed this test, because it misleads in the case 
* $80000000 -1 1 SM/REM
* JPS, 5jan94

	lsl.l	#1,d4
	bcc		sm_rem1
	beq		sm_rem1
	neg.l	d2
sm_rem1:
	lsl.l	#1,d3
	bcc		sm_remok
	beq		sm_remok
	neg.l	d1
sm_remok:	
	move.l	d1,-(a6)
	move.l	d2,-(a6)
xsm_divrem:
	rts

*				tst.l	d4
*				bpl.s	sm_divrem1
*				neg.l	d2
*sm_divrem1:		tst.l	d3
*				bpl.s	sm_divremok
*				neg.l	d1
*				
*sm_divremok:	move.l	d1,-(a6)
*				move.l	d2,-(a6)
*xsm_divrem:		rts




CHEAD udivmod, 0
udivmod:        move.l  (A6)+,D0        ;Divisor
                move.l  (A6),D1         ;Divident
                tst.l   D0
                bne.s   udi_noerr
                move.l  #$FFFFFFFF,-(A6)
                rts
udi_noerr:      cmp.l   D0,D1
                bhi.s   dent_gt_isor
                beq.s   dent_eq_isor
dent_ls_isor:   clr.l   -(A6)
                rts
dent_eq_isor:   clr.l   (A6)
                move.l  #1,-(A6)
                rts
dent_gt_isor:   moveq   #31,D2          ;BitzÑhler
                moveq   #0,D3           ;darin wird geschoben
                moveq   #0,D4           ;fÅr das Ergebnis
udivmod0:       add.l   D3,D3           ;2*
                add.l   D4,D4
                btst    D2,D1           ;Bit gesetzt?
                beq.s   udivmod1
                bset    #0,D3
udivmod1:       cmp.l   D3,D0           ;d3<d0?
                bgt.s   udivmod2        ;dann nichts machen
                sub.l   D0,D3           ;abziehen
                bset    #0,D4
udivmod2:       subq.l  #1,D2
                bpl.s   udivmod0
                move.l  D3,(A6)
                move.l  D4,-(A6)
xudivmod:       rts



        
CHEAD and, 8        
and:            move.l  (A6)+,D0
                and.l   D0,(A6)
xand:           rts


CHEAD or, 8
or:             move.l  (A6)+,D0
                or.l    D0,(A6)
xor:            rts


CHEAD exor, 8
exor:           move.l  (A6)+,D0
                eor.l   D0,(A6)
xexor:          rts


CHEAD invert, 8
invert:            not.l   (A6)
xinvert:           rts


CHEAD negate, 8
negate:         neg.l   (A6)
xnegate:        rts


CHEAD dnegate, 8		* DOUBLE wordset
dnegate:		neg.l	4(a6)
				negx.l	(a6)	
xdnegate:		rts

CHEAD abs, 8
abs:            tst.l   (A6)
                bpl.s   xabs
                neg.l   (A6)
xabs:			rts



CHEAD lshift, 8
lshift:			move.l	(a6)+,d0
				move.l	(a6)+,d1
				lsl.l	d0,d1
				move.l	d1,-(a6)
xlshift:		rts


CHEAD rshift, 8
rshift:			move.l	(a6)+,d0
				move.l	(a6)+,d1
				lsr.l	d0,d1
				move.l	d1,-(a6)
xrshift:		rts


*
*                ENDPART

*****************************************************************
*                >PART 'ALLOT, EXIT, EXECUTE'
*----------------------------------------------------------------------
CHEAD allot, 0
allot:          move.l  D5,D0
                addi.l  #odata,D0
                move.l  0(A3,D0.l),D1
                add.l   (A6)+,D1
                move.l  D1,0(A3,D0.l)
xallot:         rts


CHEAD exit, 6
exit:           move.l  D5,D0
                addi.l  #odp,D0
                move.l  0(A3,D0.l),D1
                move.w  #rts_code,0(A5,D1.l)
                addq.l  #2,D1
                move.l  D1,0(A3,D0.l)
xexit:          rts


CHEAD execute, 8 
execute:        move.l  (A6)+,D0
*                jmp     0(A5,D0.l)
				jsr		0(a5,d0.l)
xexecute:		rts

*                ENDPART

*****************************************************************
*                >PART 'basic stack manipulations'
*****************************************************************
CHEAD sp_fetch, 8                
sp_fetch:       move.l  A6,D0           ;get stackpointer
                sub.l   A3,D0           ;make it relativ in DT
                move.l  D0,-(A6)        ;push it on the stack
xsp_fetch:      rts


CHEAD sp_store, 8
sp_store:       move.l  (A6)+,D0
                add.l   A3,D0
                movea.l D0,A6
xsp_store:      rts


CHEAD rp_fetch, 0                
rp_fetch:       move.l  A7,D0           ;get returnstackpointer
				addq.l	#4,d0			;take away returnaddress
                sub.l   A3,D0           ;make it relativ in DT
                move.l  D0,-(A6)        ;push it on the stack
xrp_fetch:      rts


CHEAD rp_store, 0
rp_store:       move.l  (A6)+,D0
                add.l   A3,D0
 				move.l	(a7)+,a0
                movea.l D0,A7
                jmp		(a0)
xrp_store:      



CHEAD to_r, 4
to_r:           movea.l (SP),A0         ;RÅcksprung sichern
                move.l  (A6)+,D0
                add.l   A5,D0           ;calculate abs. address
                move.l  D0,(SP)
                jmp     (A0)            ;statt RTS
xto_r:


CHEAD r_from, 4
r_from:         movea.l (SP)+,A0        ;RÅcksprung sichern
                move.l  (SP)+,D0
                sub.l   A5,D0           ;make pointer relativ
                move.l  D0,-(A6)
                jmp     (A0)            ;statt RTS
xr_from:


CHEAD r_fetch, 4
r_fetch:        move.l  4(SP),D0
                sub.l   A5,D0
                move.l  D0,-(A6)
xr_fetch:       rts


* Convert an absolute into a datarelativ address
CHEAD b_abs, 8
b_abs:			move.l	a3,d0
				sub.l	d0,(a6)
xb_abs:			rts


* convert an datarelativ into an absolute address
CHEAD toabs, 8
toabs:			move.l	a3,d0
				add.l	d0,(a6)
xtoabs:			rts


CHEAD code2data, 8
code2data:		move.l 	(a6),d0
				add.l	a5,d0
				sub.l	a3,d0
				move.l	d0,(a6)	
xcode2data:		rts

CHEAD data2code, 8
data2code:		move.l	(a6),d0
				add.l	a3,d0
				sub.l	a5,d0
				move.l	d0,(a6)	
xdata2code:		rts


*                ENDPART

*****************************************************************
*                >PART 'I/O basics'
*****************************************************************
CHEAD cr, 0
cr:             move.l  #$0D,-(A6)
                bsr     emit
                move.l  #$0A,-(A6)
                bsr     emit
                move.l  D5,D0
                addi.l  #oout,D0
                clr.l   0(A3,D0.l)
xcr:            rts


CHEAD space, 0
space:          move.l  #$20,-(A6)
                bsr     emit
xspace:         rts

*                ENDPART

*****************************************************************
*                >PART 'compiling numbers'
*****************************************************************
CHEAD literal, 6
literal:        move.l  D5,D0           ;( number -- )
                addi.l  #odp,D0
                move.l  0(A3,D0.l),D1   ; CP @
                move.w  #moveimm_sp,0(A5,D1.l) ; codew,
                move.l  (A6)+,2(A5,D1.l) ; code,
                addq.l  #6,D1           ;increment CP
                move.l  D1,0(A3,D0.l)   ;write it back
xliteral:       rts


CHEAD twoliteral, 6
twoliteral:		move.l  D5,D0           ;( dnumber -- )
                addi.l  #odp,D0
                move.l  0(A3,D0.l),D1   ; CP @
                move.w  #moveimm_sp,0(A5,D1.l) ; codew,
                move.l  4(A6),2(A5,D1.l) ; code,
                move.w  #moveimm_sp,6(A5,D1.l) ; codew,
                move.l  (A6)+,8(A5,D1.l) ; code,
                addi.l  #12,D1           ;increment CP
                move.l  D1,0(A3,D0.l)   ;write it back
                addq.l	#4,a6
xtwoliteral:	rts



         
CHEAD fliteral, 2
* FLITERAL compiles a user-defined float literal function
fliteral:       move.l  D5,D0
                addi.l  #ofliteral,D0
                move.l  0(A3,D0.l),D0
                jmp     0(A5,D0.l)
xfliteral:

*                ENDPART

*****************************************************************
*                >PART 'runtimes for strings and error'
*****************************************************************
CHEAD count, 0
count:          move.l  (A6),D1
                moveq   #0,D0
                move.b  0(A3,D1.l),D0
                addq.l  #1,D1
                move.l  D1,(A6)
                move.l  D0,-(A6)
xcount:         rts




CHEAD b_str_quote, 4
b_str_quote:    movem.l D0/A0,-(A6)
                movea.l (SP)+,A0        ;get pointer to stringaddress
                move.l  (A0),D0         ;get string address
                adda.l  #4,A0           ;increace return pointer
                move.l  A0,-(SP)        ;push it back on the stack
                move.l  D0,-(SP)        ;save ptr to text there, too
                movem.l (A6)+,D0/A0     ;restore registers
                move.l  (SP)+,-(A6)     ;move result
				bsr		count
xb_str_quote:   rts


CHEAD b_string_emit, 4             
b_string_emit:  movem.l D0/A0,-(A6)
                movea.l (SP)+,A0        ;get pointer to stringaddress
                move.l  (A0),D0         ;get string address
                adda.l  #4,A0           ;increace return pointer
                move.l  A0,-(SP)        ;pd5h it back on the stack
                move.l  D0,-(A6)        ;push strings address
                addq.l  #1,(A6)         ;for countbyte
                clr.l   -(A6)           ;prepare stack for byte op.
                move.b  0(A3,D0.l),3(A6) ;push countbyte
                bsr     type            ;emit the string
                movem.l (A6)+,D0/A0     ;restore registers
xb_string_emit: rts


*
* CATCH and THROW
*
CHEAD catch, 0	* ( xt -- exception# | 0 )
catch:			* first save current input spec
				move.l	d5,d0
				addi.l	#otosourceid,d0
				move.l	0(a3,d0.l),-(a7)
				
				move.l	d5,d0
				addi.l	#ototib,d0
				move.l	0(a3,d0.l),-(a7)
				
				move.l	d5,d0
				addi.l	#o_tib,d0
				move.l	0(a3,d0.l),-(a7)
				
				move.l	d5,d0
				addi.l	#otoin,d0
				move.l	0(a3,d0.l),-(a7)
				
				move.l	d5,d0
				addi.l	#otoevaluateib,d0
				move.l	0(a3,d0.l),-(a7)
				
				move.l	d5,d0
				addi.l	#o_evaluateib,d0
				move.l	0(a3,d0.l),-(a7)
				
				move.l	d5,d0
				addi.l	#otofileib,d0
				move.l	0(a3,d0.l),-(a7)
				
				move.l	d5,d0
				addi.l	#o_fileib,d0
				move.l	0(a3,d0.l),-(a7)
				
				move.l	d5,d0
				addi.l	#oblk,d0
				move.l	0(a3,d0.l),-(a7)
				

				move.l	a6,-(a7)		;save stack pointer
				move.l	d5,d0
				addi.l	#ocatchhandler,d0
				move.l	0(a3,d0.l),-(a7) ;save previous catchhandler
				move.l	a7,0(a3,d0.l)	 ;set current catchhandler
				
				move.l	(a6)+,a0		;get xt
				adda.l	a5,a0			;make it absolute
				jsr		(a0)			; and try it ...
				
				move.l	d5,d0
				addi.l	#ocatchhandler,d0
				move.l	(a7)+,0(a3,d0.l) ;restore previous catchhandler
				addq.l	#4,a7			 ;drop datastackpointer 

		
				* restore input spec

				move.l	d5,d0
				addi.l	#oblk,d0
				move.l	(a7)+,0(a3,d0.l)

				move.l	d5,d0
				addi.l	#o_fileib,d0
				move.l	(a7)+,0(a3,d0.l)

				move.l	d5,d0
				addi.l	#otofileib,d0
				move.l	(a7)+,0(a3,d0.l)

				move.l	d5,d0
				addi.l	#o_evaluateib,d0
				move.l	(a7)+,0(a3,d0.l)

				move.l	d5,d0
				addi.l	#otoevaluateib,d0
				move.l	(a7)+,0(a3,d0.l)

				move.l	d5,d0
				addi.l	#otoin,d0
				move.l	(a7)+,0(a3,d0.l)

				move.l	d5,d0
				addi.l	#o_tib,d0
				move.l	(a7)+,0(a3,d0.l)

				move.l	d5,d0
				addi.l	#ototib,d0
				move.l	(a7)+,0(a3,d0.l)

				move.l	d5,d0
				addi.l	#otosourceid,d0
				move.l	(a7)+,0(a3,d0.l)

				move.l	#0,-(a6)		;the SUCCESS flag
xcatch:			rts


CHEAD throw, 0	* ( ??? exception# -- ??? excpetion# )
throw:			tst.l	(a6)+		; 0 THROW = DROP
				beq		xthrow

				move.l	d5,d0
				addi.l	#ocatchhandler,d0
				move.l	0(a3,d0.l),a7 	;restore returnstack

				move.l	(a7)+,0(a3,d0.l) ;restore previous catchhandler

				move.l	-4(a6),d0		;get exception#
				move.l	(a7)+,a6		;restore datastack
				move.l	d0,(a6)			;put exception# on stack				

		
				* restore input spec

				move.l	d5,d0
				addi.l	#oblk,d0
				move.l	(a7)+,0(a3,d0.l)

				move.l	d5,d0
				addi.l	#o_fileib,d0
				move.l	(a7)+,0(a3,d0.l)

				move.l	d5,d0
				addi.l	#otofileib,d0
				move.l	(a7)+,0(a3,d0.l)

				move.l	d5,d0
				addi.l	#o_evaluateib,d0
				move.l	(a7)+,0(a3,d0.l)

				move.l	d5,d0
				addi.l	#otoevaluateib,d0
				move.l	(a7)+,0(a3,d0.l)

				move.l	d5,d0
				addi.l	#otoin,d0
				move.l	(a7)+,0(a3,d0.l)

				move.l	d5,d0
				addi.l	#o_tib,d0
				move.l	(a7)+,0(a3,d0.l)

				move.l	d5,d0
				addi.l	#ototib,d0
				move.l	(a7)+,0(a3,d0.l)

				move.l	d5,d0
				addi.l	#otosourceid,d0
				move.l	(a7)+,0(a3,d0.l)

	
xthrow:			rts



CHEAD b_error_quote, 4
b_error_quote:  tst.l   (A6)           ;Flag testen
                beq.s   end_b_error_quote ;Fehlerbehandlung nicht ausfÅhren
			move.l	d5,d0
			addi.l	#oerrorqmess,d0
			move.l	4(a6),0(a3,d0.l)	;save errormessage

                movea.l (SP)+,A0        ;Stringadresse holen
                move.l  (A0),D1         ;fetch rel. pointer
                moveq   #0,D0
                move.b  0(A3,D1.l),D0   ;get length
                addq.l  #1,D1
                move.l  D1,-(A6)
                move.l  D0,-(A6)

			move.l	d5,d0
			addi.l	#oabortqcnt,d0
			move.l	(a6)+,0(a3,d0.l)
			move.l	d5,d0
			addi.l	#oabortqmess,d0
			move.l	(a6)+,0(a3,d0.l)

			move.l	(a6)+,(a6)
			bsr		throw

end_b_error_quote:
                addi.l  #8,(SP)
xb_error_quote: rts






CHEAD b_abort_quote, 4
b_abort_quote:  tst.l   (A6)+           ;Flag testen
                beq.s   end_b_abort_quote ;Fehlerbehandlung nicht ausfÅhren
                movea.l (SP)+,A0        ;Stringadresse holen
                move.l  (A0),D1         ;fetch rel. pointer
                moveq   #0,D0
                move.b  0(A3,D1.l),D0   ;get length
                addq.l  #1,D1
                move.l  D1,-(A6)
                move.l  D0,-(A6)
			move.l	d5,d0
			addi.l	#oabortqcnt,d0
			move.l	(a6)+,0(a3,d0.l)
			move.l	d5,d0
			addi.l	#oabortqmess,d0
			move.l	(a6)+,0(a3,d0.l)

			move.l	#-2,-(a6)
			bsr		throw

end_b_abort_quote:
                addi.l  #4,(SP)
xb_abort_quote: rts


*                ENDPART

*****************************************************************
*                >PART 'interpreter words'
*****************************************************************
CHEAD sourceid, 8		* ( -- 0 | -1 | fileid )		( CORE EXT )	
sourceid:       move.l  D5,D0
                addi.l  #otosourceid,D0
                move.l  0(A3,D0.l),-(A6)
xsourceid:		rts


CHEAD tib, 8		* ( -- c-addr )						( CORE EXT )
tib:            move.l  D5,D0
                addi.l  #ototib,D0
                move.l  0(A3,D0.l),-(A6)
xtib:           rts

            
CHEAD query, 0            
query:          move.l  D5,D0           ;( -- )
                addi.l  #ototib,D0
                move.l  0(A3,D0.l),-(A6)
                move.l  #255,-(A6)
				bsr		accept
                move.l  D5,D0
                addi.l  #otoin,D0
                clr.l   0(A3,D0.l)      ;>IN to 0
                move.l  D5,D0
                addi.l  #oblk,D0
                clr.l   0(A3,D0.l)      ;BLK to 0
                move.l  D5,D0
                addi.l  #o_tib,D0
				move.l	(a6)+,0(a3,d0.l)	
                bsr     space
xquery:         rts


*                DC.L 0
*skip:           movem.l D0-D2,-(SP)     ;( ad1 n1 char -- ad2 n2 )
*                move.l  (A6)+,D0        ;char
*                tst.l   (A6)
*                ble.s   no_skip         ;n1<=0?
*                move.l  (A6)+,D1        ;n1
*                move.l  (A6)+,D2        ;ad1
*skip_loop:      cmp.b   0(A3,D2.l),D0   ;Zeichen vergleichen und weiterzÑhlen
*                bne.s   skip_end        ;Zeichen ungleich dann raus
*                addq.l  #1,D2           ;increase pointer
*                subq.w  #1,D1           ;ZÑhler dekrementieren
*                bne.s   skip_loop       ;bis auf 0 runtergezÑhlt
*skip_end:       move.l  D2,-(A6)        ;ad2
*                move.l  D1,-(A6)        ;n2
*no_skip:        movem.l (SP)+,D0-D2
*                rts


CHEAD skip, 0
skip:           movem.l D0-D3/A0,-(SP)  ;( ad1 n1 char -- ad2 n2 )
*                                       ;or ( ad1 n1 bitvec -- ad2 n2 )
                move.l  (A6)+,D0        ;char
                tst.l   (A6)
                ble.s   no_skip         ;n1<=0?
                move.l  (A6)+,D1        ;n1
                move.l  (A6)+,D2        ;ad1

                cmpi.l  #255,D0         ;what is in D0: char or addr?
                ble.s   skip_loop       ;if char: do 'normal' skip

                movea.l D0,A0           ;D0 seems to be an address
                adda.l  A3,A0           ;convert to absolute address

                moveq   #0,D0
vskip_loop:                             ;if addr: do 'vector-skip'
                move.b  0(A3,D2.l),D0   ;get character from input
                move.l  D0,D3

                lsr.b   #3,D0           ;which byte in vector
                andi.b  #7,D3           ;which bit in that byte

                btst    D3,0(A0,D0.l)   ;test bit in vector
                beq.s   skip_end        ;character unequals delimiter
                addq.l  #1,D2           ;increase pointer
                subq.w  #1,D1           ;decrement counter
                bne.s   vskip_loop      ;until 0
                bra.s   skip_end


skip_loop:      cmp.b   0(A3,D2.l),D0   ;Zeichen vergleichen und weiterzÑhlen
                bne.s   skip_end        ;Zeichen ungleich dann raus
                addq.l  #1,D2           ;increase pointer
                subq.w  #1,D1           ;decrement counter
                bne.s   skip_loop       ;until 0

skip_end:       move.l  D2,-(A6)        ;ad2
                move.l  D1,-(A6)        ;n2
no_skip:        movem.l (SP)+,D0-D3/A0
xskip:          rts



CHEAD scan, 0
scan:           movem.l D0-D3/A0,-(SP)  ;( ad1 n1 char -- ad2 n2 )
                move.l  (A6)+,D0        ;char
                tst.l   (A6)
                ble.s   no_scan         ;n1<=0?
                move.l  (A6)+,D1        ;n1
                move.l  (A6)+,D2        ;ad1

                cmpi.l  #255,D0         ;what is in D0: char or addr?
                ble.s   scan_loop       ;if char: do 'normal' skip

                movea.l D0,A0           ;D0 seems to be an address
                adda.l  A3,A0           ;convert to absolute address

                moveq   #0,D0
vscan_loop:                             ;if addr: do 'vector-skip'
                move.b  0(A3,D2.l),D0   ;get character from input
                move.l  D0,D3

                lsr.b   #3,D0           ;which byte in vector
                andi.b  #7,D3           ;which bit in that byte

                btst    D3,0(A0,D0.l)   ;test bit in vector
                bne.s   scan_end        ;character equals delimiter
                addq.l  #1,D2           ;increase pointer
                subq.w  #1,D1           ;decrement counter
                bne.s   vscan_loop      ;until 0
                bra.s   scan_end


scan_loop:      cmp.b   0(A3,D2.l),D0   ;Zeichen vergleichen und weiterzÑhlen
                beq.s   scan_end        ;Zeichen gleich dann raus
                addq.l  #1,D2           ;increase pointer
                subq.l  #1,D1           ;ZÑhler dekrementieren
                bne.s   scan_loop       ;bis auf 0 runtergezÑhlt
scan_end:       move.l  D2,-(A6)        ;ad2
                move.l  D1,-(A6)        ;n2
no_scan:        movem.l (SP)+,D0-D3/A0
xscan:          rts





*
* find out, where the input comes from
*
CHEAD source, 0		* ( -- c-addr u )			( CORE )
source:			
				movem.l	d0-d4/a0-a2,-(a7)

				move.l	d5,d0
				addi.l	#otosourceid,d0
				tst.l	0(a3,d0.l)
				ble.s	src_not_file
			
		* source comes from file		
				move.l	d5,d0
				addi.l	#otofileib,d0
				move.l  0(A3,D0.l),-(A6)
				move.l	d5,d0
				addi.l	#o_fileib,d0
				move.l  0(A3,D0.l),-(A6)
				movem.l	(a7)+,d0-d4/a0-a2
				rts
				
src_not_file:				
		* perhaps it comes from a block?
				move.l	d5,d0
				addi.l	#oblk,d0
				tst.l	0(a3,d0.l)
				beq.s	src_not_block
				
		* source comes from block
				move.l	d5,d0
				addi.l	#op_blocksource,d0
				move.l	0(a3,d0.l),d0
				jsr		0(a5,d0.l)
				movem.l	(a7)+,d0-d4/a0-a2
				rts
				
src_not_block:
		* ok, ok. From EVALUATE?
				move.l	d5,d0
				addi.l	#otosourceid,d0
				tst.l	0(a3,d0.l)
				beq.s	src_not_eval
				
		* source comes from EVALUATE		
				move.l	d5,d0
				addi.l	#otoevaluateib,d0
				move.l  0(A3,D0.l),-(A6)
				move.l	d5,d0
				addi.l	#o_evaluateib,d0
				move.l  0(A3,D0.l),-(A6)
				movem.l	(a7)+,d0-d4/a0-a2
				rts
				
src_not_eval:
		* source comes from TIB		
				move.l	d5,d0
				addi.l	#ototib,d0
				move.l  0(A3,D0.l),-(A6)
				move.l	d5,d0
				addi.l	#o_tib,d0
				move.l  0(A3,D0.l),-(A6)
				movem.l	(a7)+,d0-d4/a0-a2
xsource:		rts



CHEAD parse, 0		* ( char "ccc<char>" -- c-addr u )		( CORE EXT )
parse:			movem.l	d0-d2,-(a7)

				bsr		source
				move.l	(A6)+,D1		;len of source
				add.l	(A6),D1			;calculate end of source
				move.l	(A6)+,D2		;pointer to source
				move.l	d2,-(a7)
				move.l	D5,D0
				addi.l	#otoin,D0
				add.l	0(A3,D0.l),D2	;actual pointer in the source

				move.l	(A6)+,D0		;char as delimiter in d0
				sub.l	D2,D1			;length of rest of source in d3

                move.l	D2,-(A6)		;this is the first result: c-addr
                move.l	D2,-(A6)
                move.l	D1,-(A6)
                move.l	D0,-(A6)
				bsr		scan			; scan to delimiter	
									* ( c-addr c-addr' u' )

                move.l  (a7)+,D2        ;
                sub.l   4(A6),D2        ;end - >WORD = >IN
                neg.l   D2
                addq.l  #1,D2
                move.l  D5,D0
                addi.l  #otoin,D0
                move.l  D2,0(A3,D0.l)   ;set new >IN

                move.l  4(A6),D1        ;endaddress
                sub.l   8(a6),D1        ;end-start

				addq.l	#8,a6
				move.l	d1,-(a6)		;the count of parsed string				
	
				movem.l	(a7)+,d0-d2
xparse:			rts


*CHEAD parse_word, 0		* ( "   name " -- c-addr u )
*parse_word:		movem.l	d0-d2,-(a7)
*                bsr		source
*                move.l  (A6)+,D1        ;len of source
*                add.l   (A6),D1         ;calculate end of source
*                move.l  (A6)+,D2
*                move.l  D2,-(SP)
*                move.l  D5,D0
*                addi.l  #otoin,D0
*                add.l   0(A3,D0.l),D2   ;actual pointer in the source
*
*				move.l  D2,-(A6)
*                move.l  D1,-(A6)
*                move.l  #$20,-(A6)
*                bsr     skip
*
*                move.l  (SP)+,D2        ;
*                sub.l   4(A6),D2        ;end - >WORD = >IN
*                neg.l   D2
*                move.l  D5,D0
*                addi.l  #otoin,D0
*                move.l  D2,0(A3,D0.l)   ;set new >IN
*				
*				movem.l	(a7)+,d0-d2
*				
*				addq.l	#8,a6
*				move.l	#$20,-(a6)
*				bra		parse
*xparse_word:	




CHEAD word, 0
word:           movem.l D0-D4/A0,-(SP)  ;( char -- addr )
                move.l  D5,D0
                addi.l  #odata,D0
                move.l  0(A3,D0.l),D1   ;fetch DP
                move.l  D1,D2
                andi.l  #1,D2
                add.l   D2,D1           ;make DP even, DP in d1

                bsr		source
                move.l  (A6)+,D3        ;len of source
                add.l   (A6),D3         ;calculate end of source
                move.l  (A6)+,D2
                move.l  D2,-(SP)
                move.l  D5,D0
                addi.l  #otoin,D0
                add.l   0(A3,D0.l),D2   ;actual pointer in the source

                move.l  (A6)+,D0        ;char as delimiter in d0
                sub.l   D2,D3           ;length of rest of source in d3

                move.l  D2,-(A6)
                move.l  D3,-(A6)
                move.l  D0,-(A6)
                bsr     skip
                move.l  4(A6),-(SP)     ;save startaddress on stack
                move.l  D0,-(A6)
                bsr     scan
                move.l  (SP),D4         ;startaddress of string

                move.l  4(A6),D3        ;endaddress
                sub.l   D4,D3           ;end-start
                move.b  D3,0(A3,D1.l)   ;mark length at HERE
                addq.l  #1,D1           ;increase dest. pointer

                movea.l (SP)+,A0        ;get back startaddr.
                adda.l  A3,A0           ;calc. abs. address

                move.l  (SP)+,D2        ;
                sub.l   4(A6),D2        ;end - >WORD = >IN
                neg.l   D2
                addq.l  #1,D2
                move.l  D5,D0
                addi.l  #otoin,D0
                move.l  D2,0(A3,D0.l)   ;set new >IN

                dbra    D3,word_loop    ;startaddr. in A0
                bra.s   word_end
word_loop:      move.b  (A0)+,0(A3,D1.l)
                addq.l  #1,D1
                dbra    D3,word_loop
                move.b  #0,0(A3,D1.l)
word_end:       addq.l  #8,A6           ;2DROP
                move.l  D5,D0
                addi.l  #odata,D0
                move.l  0(A3,D0.l),D1   ;fetch DP
                move.l  D1,D0
                andi.l  #1,D0
                add.l   D0,D1           ;make it even s.a.
                move.l  D1,-(A6)        ;here's the string now
                movem.l (SP)+,D0-D4/A0
xword:          rts



CHEAD name, 0
name:           *move.l  #$20,-(A6)      ;BL on the stack
				move.l	#whitespace-datas,-(a6)
                bsr     word
xname:          rts




      
CHEAD char, 0
char:			move.l  #$20,-(A6)
				bsr     word
				move.l  (A6),D0
				clr.l   (A6)
				move.b  1(A3,D0.l),3(A6)
xchar:          rts


      
CHEAD b_char, 2
b_char:         bsr.s   char
                bsr     literal
xb_char:        rts





* preparations for FIND
CHEAD vocsearch, 0			* ( str voc -- xt 1 | xt -1 | str 0 )
vocsearch:      movem.l D0-d1/A0-A2,-(SP)  ;( str voc -- cfa controlword / str -1 )
                move.l  (A6)+,D0        ;pointer to vocabulary
                lea     0(A3,D0.l),A0   ;pointer to header of last word
                movea.l (A6),A1         ;str in a1
                adda.l  A3,A1
vocsearch_loop: movea.l (A0),A0         ;link to next LFA
                adda.l  A3,A0           ;make pointer absolute
                tst.l   (A0)            ;das 0-Linkfeld?
                beq.s   vocsearch_false ;-> das Ende des Voc.
                movea.l A0,A2           ;und in a2
                addq.l  #4,A2           ;Zeiger auf String
                move.w  (A2),D1
                cmp.w   (A1),D1         ;gleich ?
                bne.s   vocsearch_loop
                moveq   #0,D0
                move.b  (A2)+,D0        ;LÑnge
                addq.l  #1,A1
                subq.b  #1,D0
exef_str_cmp:   cmpm.b  (A2)+,(A1)+     ;Zeichen vergleichen
                dbne    D0,exef_str_cmp
                movea.l (A6),A1
                adda.l  A3,A1
                bne.s   vocsearch_loop
vocsearch_true: move.l  A0,D0           ;for rel. addressing
                sub.l   A3,D0			;
				move.l 	cfaoffset-lfaoffset(a3,d0.l),d0	;pointer to code
				btst	#0,-1(a5,d0.l)	;smudge?
                bne.s   vocsearch_loop  ;then go on searching
                move.l  D0,(A6)         ;cfa > stack
                btst	#1,-1(a5,d0.l)	; immediate
                bne		found_immediate
				move.l	#-1,-(a6)		; true = "found"
                movem.l (SP)+,D0-d1/A0-A2
                rts                     ;and ready ...
found_immediate: move.l	#1,-(a6)		; true = "found"
                movem.l (SP)+,D0-d1/A0-A2
                rts                     ;and ready ...

vocsearch_false: clr.l	-(A6)       	; false = "not found"
                movem.l (SP)+,D0-d1/A0-A2
xvocsearch:     rts



CHEAD lcfind, 0		* ( c-addr -- c-addr 0 | xt 1 | xt -1 )
lcfind:         move.l  #0,-(A6)       ;ein Dummy-Flag ( str -1 )
                move.l  D5,D0
                addi.l  #ovocpa,D0
                movea.l 0(A3,D0.l),A0   ;Basis des Vocabularstacks
                adda.l  A3,A0           ;convert to abs. pointer
                move.l  (A0)+,D0        ;Hîhe dieses Stacks
find_loop:      subq.w  #4,D0
                bmi.s   find_false      ;Vocabulare alle durch?
                move.l  0(A0,D0.w),(A6) ;( str *name ) 'CONTEXT @'
                bsr   	vocsearch       ;search vocabulary
                tst.l  	(A6)        ;gefunden?
                beq.s   find_loop       ;nein, dann nÑchstes Vocabular
                rts                     ;sonst mit Freudenschrei zurÅck
find_false:     *move.l  #-1,(A6)        ;das widersinnige TRUE-Flag
xlcfind:        rts                     ;und nach Hause



CHEAD find, 0
find:			move.l	d5,d0
				addi.l	#ofind,d0
				move.l	0(a3,d0.l),a0
				adda.l	a5,a0
				jsr		(a0)
xfind:			rts


      
      
CHEAD nulst_quest, 0
nulst_quest:    move.l  (A6),D0
                tst.b   0(A3,D0.l)      ;Countbyte=0?
                beq.s   nulst_true
                clr.l   -(A6)           ;additional falseflag
                rts
nulst_true:     move.l  #-1,(A6)        ;trueflag
xnulst_quest:   rts




CHEAD notfound, 0
notfound:        move.l  #-13,-(A6)       ;ANSI-error-Flag
                bsr     b_error_quote   ;error"
                DC.L (msg_unknown-datas) ;9,' unknown!'
xnotfound:       rts


CHEAD tick, 0
tick:			bsr		name
				bsr.s	find
				tst.l  (A6)+
                beq.s   tick_err
                rts
tick_err:		bsr.s   notfound
xtick:			rts




CHEAD b_tick, 2
b_tick:         bsr.s   tick
                bsr     literal
xb_tick:        rts



CHEAD quest_stack, 0
quest_stack:    movem.l D0-D1,-(SP)
                move.l  D5,D0
                addi.l  #osnull,D0
                move.l  0(A3,D0.l),D1
                add.l   A3,D1
                cmpa.l  D1,A6
                ble.s   stack_ok
                movea.l 0(A3,D0.l),A6
                adda.l  A3,A6
                move.l  #-1,-(A6)
                bsr     b_abort_quote
                DC.L (msg_stkunder-datas) ;
				
stack_ok:       movem.l (SP)+,D0-D1
xquest_stack:   rts



CHEAD compiler, 0
compiler:       bsr     find
                tst.l	(A6)+
                beq.s   cnot_found
                move.l	(a6),d0			; get xt
                btst	#1,-1(a5,d0.l)	; check restrict bit
                beq.s   cnot_immediate

                move.l  (A6)+,D0        ;execute
                jsr     0(A5,D0.l)
                rts                     ;success

cnot_immediate: bsr     com_komma       ;com,
                rts                     ;success

cnot_found:     bsr     number_quest    ;number? ( adr -- string false/n1 .. ni #longs )
                tst.l   (A6)            ;test flag
                beq.s   cno_number      ;no number
                move.l  (A6),D1			;d1<0 => number on floatstack
                bpl.s   comp_num
comp_fnum:      addq.l	#4,a6			; drop #longs
				bsr     fliteral
                rts
comp_num:		cmp.l	#1,(a6)+		; single number
				beq		comp_single       
				bsr		twoliteral		; compile double number
				rts
comp_single:	bsr     literal         ;compile number
                rts                     ;UFF!!!!
cno_number:     addq.l  #4,A6           ;drop falseflag
                bra     notfound        ;neither word nor number
xcompiler:



CHEAD interpreter, 0
interpreter:    bsr     find
                tst.l  	(A6)+
                beq.s   inot_found
                move.l	(a6),d0			; get xt
                btst	#2,-1(a5,d0.l)	; check restrict bit
                beq.s   inorestrict
                move.l  D5,D0
                addi.l  #odata,D0
                move.l  0(A3,D0.l),(A6) ;string is at HERE
                move.l	#-14,-(a6)		;ANS error code: interpreting a compile-only word
                bsr     b_error_quote   ;error"        ( str flag -- )
                DC.L (msg_restrict-datas)
inorestrict:    move.l  (A6)+,D0        ;execute
                jsr     0(A5,D0.l)
                rts                     ;success
inot_found:     bsr     number_quest    ;number? ( adr -- string false/n #longs )
                tst.l   (A6)+           ;test flag
                beq.s   ino_number      ;no_number?
                rts
ino_number:     bra     notfound        ;no success
xinterpreter:



CHEAD parser, 0
parser:			move.l	d5,d0
				addi.l	#oparser,d0
				move.l	0(a3,d0.l),a0
				adda.l	a5,a0
				jsr		(a0)
xparser:		rts



CHEAD interpret, 0
interpret:      bsr     name            ;nÑchstes Wort suchen
                bsr     nulst_quest     ;Ende des Eingabestroms?
                tst.l   (A6)+
                bne.s   xinterpret
                bsr.s   parser
                bsr.s   interpret
                bra		quest_stack
xinterpret:  	rts

*                ENDPART



CHEAD prompt, 0
prompt:         move.l  D5,D0
                addi.l  #ostate,D0
                tst.l   0(A3,D0.l)
                bne.s   xprompt
                bsr     space
                move.l  #'(',-(A6)
                bsr     emit
                bsr     space
                move.l  #'o',-(A6)
                bsr     emit
                move.l  #'k',-(A6)
                bsr     emit
                move.l  #')',-(A6)
                bsr     emit
xprompt:        rts

*                ENDPART

*****************************************************************
*                >PART 'compiler words'
*                                                               *
*****************************************************************
CHEAD left_brack, 2
left_brack:     move.l  D5,D0
                addi.l  #ostate,D0
                clr.l   0(A3,D0.l)
*                move.l  #(interpreter-sys-of),parserptr-datas(A3)
				move.l	d5,d0
				addi.l	#oparser,d0
				move.l	#(interpreter-sys-of),0(a3,d0.l)
xleft_brack:    rts

            
CHEAD right_brack, 0            
right_brack:    move.l  D5,D0
                addi.l  #ostate,D0
                move.l  #-1,0(A3,D0.l)
*                move.l  #(compiler-sys-of),parserptr-datas(A3)
				move.l	d5,d0
				addi.l	#oparser,d0
				move.l	#(compiler-sys-of),0(a3,d0.l)
xright_brack:   rts


CHEAD align, 0              
align:          move.l  D5,D0
                addi.l  #odata,D0
                move.l  0(A3,D0.l),D1
                move.l  D1,D2
                andi.l  #1,D2
                add.l   D1,D2
                move.l  D2,0(A3,D0.l)
xalign:         rts

*                ENDPART

*****************************************************************
*                >PART 'the main loop'
*                                                               *
*****************************************************************

CHEAD quit, 0
quit:           move.l  D5,D0
                addi.l  #ornull,D0
                move.l  0(A3,D0.l),D0
                lea     0(A3,D0.l),SP   ;set returnstack

                move.l  D5,D0
                addi.l  #ostate,D0
                clr.l   0(A3,D0.l)      ;STATE to zero

*				move.l  #(interpreter-sys-of),parserptr-datas(A3)
				move.l	d5,d0
				addi.l	#oparser,d0
				move.l	#(interpreter-sys-of),0(a3,d0.l)


                move.l  D5,D0
                addi.l  #otosourceid,D0
                clr.l   0(A3,D0.l)      ;SOURCE-ID to zero		

                move.l  D5,D0
                addi.l  #osnull,D0
                move.l  0(A3,D0.l),D0
                add.l   A3,D0
                cmpa.l  D0,A6           ;datastack underflow?
                ble.s   test_fstack
                movea.l D0,A6           ;reset datastack
test_fstack:    move.l  D5,D0
                addi.l  #ofnull,D0
                move.l  0(A3,D0.l),D0
                add.l   A3,D0
                cmpa.l  D0,A4           ;floatstack underflow?
                ble.s   quit_loop
                movea.l D0,A4           ;reset floatstack
quit_loop:      bsr     prompt
                bsr     cr
                bsr     query
				move.l	#(interpret-sys-of),-(a6)
				bsr		catch
				move.l	d5,d0
				addi.l	#op_errorhandler,d0
				move.l	0(a3,d0.l),d0
				jsr		0(a5,d0.l)
                bra.s   quit_loop
xquit:



*
* check some of the ANSI-defined error messages
*

CHEAD errorhandler, 0			*( flag -- ? )
errorhandler:	
	* 0: no error
				cmpi.l	#0,(a6)
				bne		perhaps_1

				addq.l	#4,a6
				rts

	* -1: ABORT
perhaps_1:		cmpi.l	#-1,(a6)
				bne		perhaps_2
				
                move.l  D5,D0
                addi.l  #osnull,D0
                move.l  0(A3,D0.l),D0
                add.l   A3,D0
				move.l	d0,a6	
				bra		quit
				
	* -2: ABORT"
perhaps_2:		cmpi.l	#-2,(a6)
				bne		perhaps_10

                move.l  D5,D0
                addi.l  #osnull,D0
                move.l  0(A3,D0.l),D0
                add.l   A3,D0
				move.l	d0,a6	
				
				move.l	d5,d0
				addi.l	#oabortqmess,d0
				move.l	0(a3,d0.l),-(a6)
				move.l	d5,d0
				addi.l	#oabortqcnt,d0
				move.l	0(a3,d0.l),-(a6)
				bsr		type
				
				bra		quit
				
	* -10: division by zero			
perhaps_10:		cmpi.l	#-10,(a6)
				bne		perhaps_11

				addq.l	#4,a6

				move.l	#msg_divbyzero-datas,-(a6)
				bsr		count
				bsr		type				

				bra		quit	

	* -11: result out of range			
perhaps_11:		cmpi.l	#-11,(a6)
				bne		perhaps_13

				addq.l	#4,a6
  
				move.l	#msg_outofrange-datas,-(a6)
				bsr		count
				bsr		type				

				bra		quit	

				
	* -13: undefined word				
perhaps_13:		cmpi.l	#-13,(a6)
				bne		perhaps_14
				bra		ok_14			;handler is the same!
				
perhaps_14:		cmpi.l	#-14,(a6)
				bne		perhaps_16			

ok_14:			addq.l	#4,a6			;DROP

				move.l	d5,d0
				addi.l	#oerrorqmess,d0
				move.l	0(a3,d0.l),-(a6)
				bsr		count
				bsr		type
				
				move.l	d5,d0
				addi.l	#oabortqmess,d0
				move.l	0(a3,d0.l),-(a6)
				move.l	d5,d0
				addi.l	#oabortqcnt,d0
				move.l	0(a3,d0.l),-(a6)
				bsr		type
				
				bra		quit


perhaps_16:		cmpi.l	#-16,(a6)
				bne		perhaps_38			

				addq.l	#4,a6
				move.l	#msg_emptyname-datas,-(a6)
				bsr		count
				bsr		type
							
				bra		quit				

perhaps_38:		cmpi.l	#-38,(a6)
				bne		errundef			

				addq.l	#4,a6
				move.l	#msg_filenotfound-datas,-(a6)
				bsr		count
				bsr		type

				move.l	d5,d0
				addi.l	#oabortqmess,d0
				move.l	0(a3,d0.l),-(a6)
				move.l	d5,d0
				addi.l	#oabortqcnt,d0
				move.l	0(a3,d0.l),-(a6)
				bsr		type
				
				bra		quit
				


errundef:		move.l	#(msg_undef-datas),-(a6)
				bsr		count
				bsr		type

				bra 	quit

xerrorhandler:	rts



CHEAD cold, 0
cold:           move.l  (tcold-datas)(A3),D0
                jsr     0(A5,D0.l)
xcold:          rts

*                ENDPART

*****************************************************************
*                >PART 'convert string --> number'
*****************************************************************

CHEAD digit_quest, 0	* ( char -- digit true | false )
digit_quest:    movem.l D0-D1,-(SP)
                move.l  (A6),D0         ;Zeichen nach d0
                sub.b   #'0',D0         ;Zeichen -> Zahl
                bmi.s   digit_false     ;<0? dann keine Ziffer
                cmp.b   #16,D0          ;vergl. Ziffer mit 15
                bgt.s	dig_quest1      ;Ziffer>15?, dann mach weiter
                cmp.b   #10,D0          ;10<=Ziffer<=15?, dann keine Ziffer
                bge.s   digit_false
                bra.s   dig_quest2
dig_quest1:     sub.b   #7,D0           ;'A' -> 10
dig_quest2:     move.l  D5,D1
                addi.l  #obase,D1
                cmp.l   0(A3,D1.l),D0
                bmi.s   digit_true
digit_false:    clr.l   (A6)            ;FALSE
                movem.l (SP)+,D0-D1
                rts
digit_true:     move.l  D0,(A6)         ;Digit
                move.l  #-1,-(A6)       ;TRUE
                movem.l (SP)+,D0-D1
xdigit_quest:   rts




CHEAD to_number, 0		* ( ud1 c-addr1 u1 -- ud2 c-addr2 u2 )
to_number:		move.l	(a6)+,d0		; get u1
				move.l	(a6)+,a0		; get c-addr1
				adda.l	a3,a0			; make a0 absolute
				
to_num_loop:	move.l	#0,-(a6)
				move.b	(a0),3(a6)		; character on stack
				bsr		digit_quest		; is it a digit?
				tst.l	(a6)+
				beq		to_num_ready

	* digit is on stack now				
	* ACCUMULATE
       			movem.l	d0/a0,-(a7)
       			
                move.l  D5,D0
                addi.l  #obase,D0
                move.l  0(A3,D0.l),d4	; get BASE
				
				movem.w	4(a6),d0-d3		; get ud1

				mulu.w	d4,d0
				mulu.w	d4,d1
				mulu.w	d4,d2
				mulu.w	d4,d3
							
				add.l	(a6)+,d3
				
				swap.w	d1
				add.w	d1,d0				
				swap.w	d1
				swap.w	d2
				add.w	d2,d1				
				swap.w	d2
				swap.w	d3
				add.w	d3,d2
				swap.w	d3
				
				movem.w d0-d3,(a6)		; put ud2

       			movem.l (a7)+,d0/a0

	* c-addr u --> c-addr+1 u-1
				addq.l	#1,a0 
				subq.l	#1,d0
				bne		to_num_loop
				
       
to_num_ready:	suba.l	a3,a0			; make a0 relative
      			move.l	a0,-(a6)
      			move.l	d0,-(a6) 
xto_number:		rts
       
       


CHEAD n_number_quest, 0		*( c-addr -- n1 .. ni #longs | c-addr 0 )
* c-addr is the address of a counted string as delivered by FIND
n_number_quest: * illegal 
				move.l	(a6)+,-(a7)		; save addr
				clr.l	-(a6)
				clr.l	-(a6)			; 0.
				move.l	(a7),-(a6)		; put back on stack, remaining on sys
				clr.w	-(a7)			; allocat a word for sign indicator

				bsr		count			; ( 0. c-addr u )
				move.l	4(a6),d0		; get addr
				move.b	0(a3,d0.l),d0
				cmp.b	#'-',d0			; is the number negative
				bne		not_neg
				add.l	#1,4(a6)		; increase address
				sub.l	#1,(a6)			; decrease count			
				move.w	#-1,(a7)		; save indicator on sys
not_neg:		bsr		to_number
				tst.l	(a6)
				beq		ready_single
			
				cmp.l	#1,(a6)+		; only one character left? 			
				bne		n_num_err
				
	* one character left: is it a dot?
				move.l	(a6),d0
				move.b	0(a3,d0.l),d0	; get remaining character
				cmp.b	#'.',d0			; a dot?
				bne		n_num_err		; oh no, this was not a number
				
				addq.l	#4,a6			; drop c-addr
				tst.w	(a7)+			; check minus flag
				beq		double_exit
				bsr		dnegate
double_exit:	move.l	#2,-(a6)
				addq.l	#4,a7
				rts
			
ready_single:	lea		$c(a6),a6		; drop  ( high-word c-addr u )
				tst.w	(a7)+			; check minus flag
				beq		single_exit
				bsr		negate		
single_exit:	move.l	#1,-(a6)		; #longs = 1
				addq.l	#4,a7			; drop saved c-addr
				rts				
				
n_num_err:		lea 	$c(a6),a6			; drop ( d c-addr ) 
				addq.l	#2,a7			; drop minus flag
				move.l	(a7)+,-(a6)		; restore saved c-addr
				clr.l	-(a6)			; #longs = 0				
xn_number_quest: rts                     ;finish

*                ENDPART

*****************************************************************
*                >PART 'memory manipulation'
*                                                               *
*****************************************************************
CHEAD fetch, 8
fetch:          move.l  (A6),D0         ;( adr -- value )
                move.l  0(A3,D0.l),(A6)
xfetch:         rts


CHEAD cfetch, 8
cfetch:         move.l  (A6),D0
                clr.l   (A6)
                move.b  0(A3,D0.l),3(A6)
xcfetch:        rts

        
CHEAD wfetch, 8        
wfetch:         move.l  (A6),D0
                clr.l   (A6)
                move.w  0(A3,D0.l),2(A6)
xwfetch:        rts

        
CHEAD store, 8        
store:          move.l  (A6)+,D0        ;( value adr -- )
                move.l  (A6)+,0(A3,D0.l)
xstore:         rts



CHEAD cstore, 8
cstore:         move.l  (A6)+,D0
                addq.l  #3,A6
                move.b  (A6)+,0(A3,D0.l)
xcstore:        rts



CHEAD wstore, 8
wstore:         move.l  (A6)+,D0
                addq.l  #2,A6
                move.w  (A6)+,0(A3,D0.l)
xwstore:        rts

*                ENDPART


*****************************************************************
*                >PART 'creating a header'
*****************************************************************


CHEAD header, 0			*( c-addr u -- )
header:   		bsr     align
                move.l  #headsize,-(A6)
				bsr     allot           ;for header fields

	* move name into allocated space
				move.l	d5,d0
				addi.l	#odata,d0
				move.l	0(a3,d0.l),a0	;HERE = dest address for string move
				move.l	a0,-(a7)		;save it on sys

	* allocate data space for name
				move.l	(a6),-(a6)		;DUP
				addi.l	#1,(a6)			;1+
				bsr		allot			;ALLOT

				move.l	(a7),a0			;get dest from sys again
				adda.l	a3,a0			;make it absolute
				
				move.l	(a6)+,d1		;counter for string move
				move.l	(a6)+,a1		;src for string move
				adda.l	a3,a1			;make it absolute
				
		* because the source string often comes from HERE,
		* it is better to use a CMOVE> instead of CMOVE

				move.l	d1,d0
				add.l	d1,a0
				addq.l	#1,a0			;for the countbyte
				add.l	d1,a1
			
				bra		hdr_mv_end
hdr_mv_name:	move.b	-(a1),-(a0)
hdr_mv_end:		dbra	d1,hdr_mv_name			
				
				move.b	d0,-(a0)		;set count byte
				
                move.l  (A7)+,D0        ;address of name again
                subi.l  #headsize,D0    ;to start of header
                move.l  D5,D1
                addi.l  #olast,D1
                move.l  D0,0(A3,D1.l)   ;mark new LAST

                move.l  D5,D2
                addi.l  #ocurrent,D2
                move.l  0(A3,D2.l),D2   ;pointer to pointer to last link
                move.l  0(A3,D2.l),D1   ;LFA of last word
				addi.l 	#lfaoffset, d0
				move.l  D1,0(A3,D0.l)   ;link in voc.
                move.l  D0,0(A3,D2.l)   ;notate new link

                move.l  D5,D0
                addi.l  #odp,D0
                move.l  0(A3,D0.l),D1   ;CP @
				addq.l  #cheadsize,0(A3,D0.l)   ;make room for codeheader
*                move.l  D5,D0
*                addi.l  #oblk,D0
*                move.l  0(A3,D0.l),0(A5,D1.l) ;save BLK@ in view-field
				addq.l  #cheadsize,D1

                move.l  D5,D0
                addi.l  #olast,D0
                move.l  0(A3,D0.l),D0
				move.l  D1,cfaoffset(A3,D0.l)   ;set CFA in header
				move.w	#1,-2(a5,d1.l)		;set smudge-bit
	
                bsr     align           ;make DP even again
xheader:        rts





CHEAD header_colon, 0
header_colon:   bsr     align
                bsr     name            ;get name
                bsr     nulst_quest     ;is there a name?
                tst.l   (A6)+
                bne     hd_col_err

	* type warning when necessary
                move.l  D5,D0
                addi.l  #owarning,D0
                tst.l   0(A3,D0.l)      ;WARNING ?
                beq.s   do_head_col
                move.l  (A6),-(A6)      ;dup name
                move.l  D5,D0
                addi.l  #ocurrent,D0
                move.l  0(A3,D0.l),-(A6) ;CURRENT @
                bsr     vocsearch
                move.l  (A6)+,(A6)      ;NIP, CFA of no interest
                tst.l   (A6)+
                bmi.s   do_head_col     ;not found
                move.l  (A6),-(A6)
                bsr     count
                bsr     type
                bsr     b_str_quote
                DC.L (msg_notunique-datas)
                bsr     count
                bsr     type

do_head_col:    bsr 	count
				bra		header
			
                
hd_col_err:     *move.l  #-1,-(A6)
                *bsr     b_abort_quote
                *DC.L (msg_emptyname-datas)
                move.l	#-16,-(a6)
                bsr		throw
xheader_colon:


*                ENDPART

*****************************************************************
*                >PART 'the ':' compiler'
*                                                               *
*****************************************************************
CHEAD colon, 0
colon:          bsr     header_colon    ;create header
                bsr     right_brack     ;switch compiler on
xcolon:         rts

       
CHEAD m_colon, 0       
m_colon:        bsr.s   colon
                move.l  D5,D0
                addi.l  #ois_macro,D0
                move.l  #-1,0(A3,D0.l)
xm_colon:       rts

         
         
CHEAD reveal, 0         
reveal:         move.l  D5,D0
                addi.l  #olast,D0
                move.l  0(A3,D0.l),D0   ;pointer to last header
				move.l 0(a3,d0.l),d0	;pointer to code
        		andi.w  #$FFFE,-2(A5,D0.l) ;delete SMUDGE-Bit
xreveal:        rts



CHEAD semi_colon, 6
semi_colon:     move.l  D5,D0
                addi.l  #odp,D0
                move.l  0(A3,D0.l),D1
                move.w  #rts_code,0(A5,D1.l)
                addq.l  #2,D1
                move.l  D1,0(A3,D0.l)
                bsr.s   reveal
                bsr     left_brack

                tst.l   (was_local-datas)(A3)
                beq.s   semi_col_m

forget_locals:  clr.l   (was_local-datas)(A3)
                move.l  D5,D0
                addi.l  #ocurrent,D0
                move.l  0(A3,D0.l),D0
                move.l  (save_cur-datas)(A3),0(A3,D0.l)
                move.l  D5,D0
                addi.l  #odata,D0
                move.l  (save_dp-datas)(A3),0(A3,D0.l)

semi_col_m:     move.l  D5,D0
                addi.l  #olast,D0
                move.l  0(A3,D0.l),D1   ;fetch LAST
				move.l  cfaoffset(A3,D1.l),D0   ;fetch CFA
                lea     0(A5,D0.l),A0   ;address of code (abs.)

                move.l  D5,D0
                addi.l  #odp,D0
                move.l  0(A3,D0.l),D0   ;fetch CP
                add.l   A5,D0           ;calc. abs. address

                sub.l   A0,D0           ;length of code
                subq.l  #2,D0           ;-2 for the RTS
                lsr.l   #1,D0           ;length in words
                mulu    #$0100,D0       ;shift 8 bit

	* test is_macro: when set, set macro-bit in codeheader
				move.l 	d5,d1
				addi.l	#ois_macro, d1
				tst.l	0(a3,d1.l)
				beq.s	isnomacro
                bset    #3,D0           ;set macrobit
isnomacro:		or.w	d0,-2(a0)

                move.l  D5,D0
                addi.l  #ois_macro,D0
                clr.l   0(A3,D0.l)      ;clear IS_MACRO
xsemi_colon:    rts



*                ENDPART

*****************************************************************
*                >PART 'simple stack words'
*                                                               *
*****************************************************************
CHEAD dup, 8
dup:            move.l  (A6),-(A6)
xdup:           rts



CHEAD drop, 8
drop:           addq.l  #4,A6
xdrop:          rts



CHEAD swap, 8
swap:           movea.l (A6)+,A0        ;2
                movea.l (A6),A1         ;2
                move.l  A0,(A6)         ;2
                move.l  A1,-(A6)        ;2
xswap:          rts



CHEAD rot, 8 
rot:            move.l  (A6)+,D0
                movea.l (A6)+,A1
                movea.l (A6),A0
                move.l  A1,(A6)
                move.l  D0,-(A6)
                move.l  A0,-(A6)
xrot:           rts



CHEAD tuck, 8	* ( x1 x2 -- x2 x1 x2 )		( CORE EXT )
tuck:			move.l	(a6)+,d0
				move.l	(a6)+,a0
				move.l	d0,-(a6)
				move.l	a0,-(a6)
				move.l	d0,-(a6)
xtuck:			rts



CHEAD quest_dup, 8
quest_dup:      tst.l   (A6)
                beq.s   xquest_dup
                move.l  (A6),-(A6)
xquest_dup:     rts



CHEAD over, 8
over:           move.l  4(A6),-(A6)
xover:          rts



CHEAD nip, 8	* ( n1 n2 -- n2 ) 				( CORE EXT )
nip:			move.l (a6)+,(a6)
xnip:			rts



CHEAD _2drop,8
_2drop:         addq.l  #8,A6
x_2drop:        rts



CHEAD _2dup, 8
_2dup:          move.l  4(A6),-(A6)
                move.l  4(A6),-(A6)
x_2dup:         rts



CHEAD _2over, 8
_2over:         move.l  $C(A6),-(A6)
                move.l  $C(A6),-(A6)
x_2over:        rts



CHEAD _2swap, 8
_2swap:         move.l  (A6)+,D0
                move.l  (A6)+,D1
                move.l  4(A6),-(A6)
                move.l  4(A6),-(A6)
                move.l  D0,8(A6)
                move.l  D1,$0C(A6)
x_2swap:        rts

*                ENDPART

*****************************************************************
*                >PART 'moving memory byte by byte'
*                                                               *
*****************************************************************

CHEAD cmove, 0
cmove:          move.l  (A6)+,D0        ;( from to count -- )
                movea.l (A6)+,A0        ;to
                adda.l  A3,A0           ;convert to abs. address
                movea.l (A6)+,A1        ;from
                adda.l  A3,A1           ;dto.
*                tst.l   D0
*                beq.s   xcmove
			bra startcmove
cmove_loop:     move.b  (A1)+,(A0)+
startcmove:		dbra	d0,cmove_loop
*                subq.l  #1,D0
*                bne.s   cmove_loop
xcmove:         rts



CHEAD cmove_up, 0
cmove_up:       move.l  (A6)+,D0        ;( from to count -- )
                movea.l (A6)+,A0        ;to
                adda.l  A3,A0           ;convert to abs. address
                movea.l (A6)+,A1        ;from
                adda.l  A3,A1           ;dto.
*                tst.l   D0
*                beq.s   xcmove_up
                adda.l  D0,A0
                adda.l  D0,A1
			bra	startmovup
cmove_up_loop:  move.b  -(A1),-(A0)
startmovup:		dbra	d0,cmove_up_loop
*                subq.l  #1,D0
*                bpl.s   cmove_up_loop
xcmove_up:      rts

*                ENDPART

*****************************************************************
*                >PART 'the CREATE ... DOES> structure'
*                                                               *
*****************************************************************
* CREATE <name>  produces the following structure:              *
*       in data segment:        header                          *
*       in code segment:        move.l  seg(DT),seg             *
*                               jsr (dodoes-sys-of)(seg)        *
*                               HERE ,                          *
*****************************************************************
dodoes:         movea.l (SP)+,A0
                move.l  (A0),-(A6)
                rts


CHEAD create, 0
create:         bsr     header_colon
                bsr     reveal
                move.l  #(dodoes-sys-of),-(A6) ;rel. address of dodoes
                bsr     jsr_komma
                move.l  D5,D0
                addi.l  #odata,D0
                move.l  0(A3,D0.l),-(A6)
                bsr     code_komma
xcreate:        rts
* remark:  jsrSB_komma would be possible for CREATE, too, but DOES> needs
*          jsr_komma, because the address of the DOES>-code does not have
*          to be within the first codesegment


b_code:         move.l  (SP)+,D0        ;fetch address of code
                sub.l   A5,D0           ;make it relative
                move.l  D0,-(A6)        ;push it for JSR,
                move.l  D5,D0
                addi.l  #olast,D0
                move.l  0(A3,D0.l),D0   ;address of last header
                move.l  cfaoffset(A3,D0.l),D0   ;address of code
                move.l  D5,D1
                addi.l  #odp,D1
                move.l  0(A3,D1.l),-(SP) ;save CP
                move.l  D0,0(A3,D1.l)   ;set CP to codeaddress
                bsr     jsr_komma
                move.l  (SP)+,0(A3,D1.l) ;restore CP
                rts

does_code:      movea.l (SP)+,A0        ;save return vector
                movea.l (SP)+,A1        ;get pointer to pointer to data
                move.l  (A1),-(A6)      ;push pointer to data
                jmp     (A0)            ;jump thru saved vector


        
CHEAD does, 6
does:           move.l  #(b_code-sys-of),-(A6)
                bsr     jsrSB_komma     ;this runs while definition
                move.l  #(does_code-sys-of),-(A6)
                bsr     jsrSB_komma     ;this runs while execution
xdoes:          rts


codedoes:       movea.l (SP)+,A1
                movea.l (SP)+,A0        ;pointer to pointer to data
                move.l  (A0),D0         ;pointer to data in A0
                jmp     (A1)

      
      
CHEAD semcl_code, 0
semcl_code:     move.l  #(b_code-sys-of),-(A6)
                bsr     jsrSB_komma     ;this runs while definition
                move.l  #(codedoes-sys-of),-(A6)
                bsr     jsrSB_komma     ;this runs while execution
xsemcl_code:    rts

*                ENDPART

*****************************************************************
*                >PART 'variables and constants'
*                                                               *
*****************************************************************

CHEAD variable, 0
variable:       bsr     create
                clr.l   -(A6)
                bra     komma
xvariable:



CHEAD constant, 0
constant:       bsr     header_colon
                bsr     reveal
                move.l  #moveimm_sp,-(A6) ;instead of LIT,
                bsr     code_wkomma     ;real code
                bsr     code_komma      ;is generated
                move.l  #rts_code,-(A6)
                bra     code_wkomma
xconstant:


CHEAD bl, 8
bl:             move.l  #$20,-(A6)
xbl:            rts


*                ENDPART

*****************************************************************
*                >PART 'values and locals'
*                                                               *
*****************************************************************
*
* VALUEs and LOCALs generate the same kind of code and access it
* in a very similar manner:
*
*       Call Fetcher
*       Address of Data
*       Call Storer
*
* The fetcher expects the address of data as an in-line address
* behind his call, whereas the storer expects it in front of it's
* call.
* Fetcher and storer are compiled using 'JSR,', because a defined
* length of code (8 bytes, worst case) is important for 'TO'.

* writing access using 'TO'
CHEAD to, 2
to:             bsr     tick            ;get address of code
                addi.l  #$0C,(A6)       ;> address of storer
                move.l  D5,D0
                addi.l  #ostate,D0
                tst.l   0(A3,D0.l)      ;test STATE
                bne.s   comp_val
                move.l  (A6)+,D0
                jmp     0(A5,D0.l)      ;execute ...
comp_val:       bra     jsr_komma       ;... or compile
xto:




val_fetch:      movea.l (SP)+,A0        ;get pointer to in-line
                move.l  (A0),D0
                move.l  0(A3,D0.l),-(A6)
                rts

val_store:      movea.l (SP)+,A0
                move.l  -8(A0),D0
                move.l  (A6)+,0(A3,D0.l)
                rts


CHEAD value, 0
value:          bsr     header_colon
                bsr     reveal
                move.l  #(val_fetch-sys-of),-(A6)
                bsr     jsr_komma
                move.l  D5,D0
                addi.l  #odata,D0
                move.l  0(A3,D0.l),-(A6)
                bsr     code_komma
                move.l  #(val_store-sys-of),-(A6)
                bsr     jsrSB_komma
                bra     komma
xvalue:




free_loc:       addq.l  #4,SP
                rts

loc_init:       movea.l (SP),A0         ;get pointer to the fetcher
                move.l  (A6)+,(SP)      ;put value on the stack
                move.l  8+cheadsize(A0),D0        ;fetch datapointer
                move.l  SP,0(A3,D0.l)   ;set address of data on stack
                move.l  #(free_loc-sys-of),D0 ;address of free_loc for later use
                pea     0(A5,D0.l)
                jmp     (localcodesize+cheadsize)(A0) ;jump behind storer

loc_fetch:      movea.l (SP)+,A0        ;get inline pointer
                move.l  (A0),D0         ;get offset into data segment
                movea.l 0(A3,D0.l),A0   ;get the pointer to the data
                move.l  (A0),-(A6)      ;fetch the data
                rts

loc_store:      movea.l (SP)+,A0
                move.l  -8(A0),D0
                movea.l 0(A3,D0.l),A0
                move.l  (A6)+,(A0)
                rts



*CHEAD local, 6
*local:          tst.l   (was_local-datas)(A3) ;first local?
*                bne.s   no_save         ;not?, nothing has to be saved
*                move.l  D5,D0           ;otherwise save CURRENT@@ und HERE
*                addi.l  #ocurrent,D0
*                move.l  0(A3,D0.l),D0   ;CURRENT @
*                move.l  0(A3,D0.l),(save_cur-datas)(A3) ;@ SAVE_CUR !
*                move.l  D5,D0
*                addi.l  #odata,D0
*                move.l  0(A3,D0.l),(save_dp-datas)(A3) ;HERE SAVE_DP !
*                move.l  #-1,(was_local-datas)(A3) ;WAS_LOCAL ON
*no_save:        move.l  D5,D0
*                addi.l  #olast,D0
*                move.l  0(A3,D0.l),-(SP) ;LAST PUSH
*			
*                move.l  #(loc_init-sys-of),-(A6)
*                bsr     jsrSB_komma     ;compile loc_init
*
*                bsr     header_colon    ;HEADER:
*                bsr     reveal          ;create a header
*
*                move.l  D5,D0
*                addi.l  #odp,D0
*                move.l  D5,D1
*                addi.l  #olast,D1
*                move.l  0(A3,D1.l),D1   ;LAST @
*                move.l  0(A3,D0.l),cfaoffset(A3,D1.l) ;CP @ SWAP cfaoffset + !                                       
*                	;set pointer in header to current CP
*
*                move.l  #(loc_fetch-sys-of),-(A6)
*                bsr     jsr_komma       ;compile fetcher
*                move.l  save_dp-datas(A3),-(A6)
*                addq.l  #4,save_dp-datas(A3) ;allocate space in data segment
*                bsr     code_komma      ;compile pointer to it
*                move.l  #(loc_store-sys-of),-(A6)
*                bsr     jsrSB_komma     ;compile storer
*
*                move.l  D5,D0
*                addi.l  #olast,D0
*                move.l  (SP)+,0(A3,D0.l) ;restore LAST
*xlocal:         rts


CHEAD b_local, 0				* ( c-addr u -- )
b_local:          tst.l   (was_local-datas)(A3) ;first local?
                bne.s   b_no_save         ;not?, nothing has to be saved
                move.l  D5,D0           ;otherwise save CURRENT@@ und HERE
                addi.l  #ocurrent,D0
                move.l  0(A3,D0.l),D0   ;CURRENT @
                move.l  0(A3,D0.l),(save_cur-datas)(A3) ;@ SAVE_CUR !
                move.l  D5,D0
                addi.l  #odata,D0
                move.l  0(A3,D0.l),(save_dp-datas)(A3) ;HERE SAVE_DP !
                move.l  #-1,(was_local-datas)(A3) ;WAS_LOCAL ON
b_no_save:        move.l  D5,D0
                addi.l  #olast,D0
                move.l  0(A3,D0.l),-(SP) ;LAST PUSH
			
                move.l  #(loc_init-sys-of),-(A6)
                bsr     jsrSB_komma     ;compile loc_init

				bsr 	header
                bsr     reveal          ;create a header

                move.l  D5,D0
                addi.l  #odp,D0
                move.l  D5,D1
                addi.l  #olast,D1
                move.l  0(A3,D1.l),D1   ;LAST @
                move.l  0(A3,D0.l),cfaoffset(A3,D1.l) ;CP @ SWAP cfaoffset + !                                       
                	;set pointer in header to current CP

                move.l  #(loc_fetch-sys-of),-(A6)
                bsr     jsr_komma       ;compile fetcher
                move.l  save_dp-datas(A3),-(A6)
                addq.l  #4,save_dp-datas(A3) ;allocate space in data segment
                bsr     code_komma      ;compile pointer to it
                move.l  #(loc_store-sys-of),-(A6)
                bsr     jsrSB_komma     ;compile storer

                move.l  D5,D0
                addi.l  #olast,D0
                move.l  (SP)+,0(A3,D0.l) ;restore LAST
xb_local:         rts





*                ENDPART

*****************************************************************
*                                                               *
*       structures controlling program flow                     *
*                                                               *
*****************************************************************

*****************************************************************
*                >PART 'a.) LOOPs   and general stuff'
*****************************************************************
CHEAD b_do, 4
b_do:           movea.l (SP)+,A0        ;return pointer
                movem.l D6-D7,-(SP)
                addq.l  #4,A0           ;behind (DO is a pointer to behind LOOP
                move.l  A0,-(SP)
                move.l  (A6)+,D7        ;initial value
                move.l  (A6)+,D6
                sub.l   D6,D7           ;start-limit    (<0)
                jmp     (A0)            ;
xb_do:



CHEAD b_quest_do, 4
b_quest_do:     movea.l (SP)+,A0        ;return pointer
                move.l  (A6),D0
                cmp.l   4(A6),D0
                beq.s   no_do
                movem.l D6-D7,-(SP)
                addq.l  #4,A0           ;behind (DO is a pointer to behind LOOP
                move.l  A0,-(SP)
                move.l  (A6)+,D7        ;initial value
                move.l  (A6)+,D6
                sub.l   D6,D7           ;start-limit    (<0)
                jmp     (A0)            ;
no_do:          addq.l  #8,A6           ;drop limits
                move.l  (A0),D0         ;fetch pointer to behind LOOP
                jmp     0(A5,D0.l)
xb_quest_do:

            
            
CHEAD b_loop, 4
b_loop:         addq.l  #1,D7           ;increase index
                bcs.s   no_more_loop    ;enough?
                addq.l  #4,SP           ;drop return address
                movea.l (SP),A0         ;fetch pointer to (DO
                jmp     (A0)            ;and jump back
no_more_loop:   movea.l (SP)+,A0        ;get return pointer
                addq.l  #4,SP           ;drop pointer to (DO
                movem.l (SP)+,D6-D7     ;restore registers
                jmp     (A0)            ;and LOOP has finished
xb_loop:



CHEAD b_plus_loop, 4
b_plus_loop:    tst.l   (A6)
                bpl.s   incr
                neg.l   (A6)
                sub.l   (A6)+,D7
                blt.s   no_more_pl_lp
                addq.l  #4,SP
                movea.l (SP),A0
                jmp     (A0)
incr:           add.l   (A6)+,D7
                bcs.s   no_more_pl_lp
                addq.l  #4,SP
                movea.l (SP),A0
                jmp     (A0)
no_more_pl_lp:  movea.l (SP)+,A0
                addq.l  #4,SP
                movem.l (SP)+,D6-D7
                jmp     (A0)
xb_plus_loop:



CHEAD i, $C
i:              move.l  D6,-(A6)        ;limit
                add.l   D7,(A6)         ;+index (<0)
xi:             rts



CHEAD j, 4
j:              movea.l (SP)+,A0
                move.l  8(SP),D0
                add.l   4(SP),D0
                move.l  D0,-(A6)
                jmp     (A0)
xj:


CHEAD unloop, 4
unloop:         movea.l (SP)+,A1
                movea.l (SP)+,A0
                movem.l (SP)+,D6-D7
                jmp     (A1)
xunloop:


CHEAD leave, 4
leave:          addq.l  #4,SP           ;drop retrun address
                movea.l (SP)+,A0        ;get LOOP-pointer
                move.l  -4(A0),D0       ;fetch address, that points after LOOP
                movem.l (SP)+,D6-D7     ;restore registers
                jmp     0(A5,D0.l)      ;jump behind loop
xleave:

*                ENDPART

*****************************************************************
*                >PART 'b.) decisions'
*****************************************************************
* IF-Code for high-level branches, see ?BRANCH
if_code:        movea.l (SP)+,A0
                tst.l   (A6)+
                beq.s   if_false
                addq.l  #4,A0           ;adr öberbrÅcken
                jmp     (A0)
if_false:       move.l  (A0),D0
                jmp     0(A5,D0.l)


CHEAD quest_branch, 6
quest_branch:   move.l  #(if_code-sys-of),-(A6)
                bsr     jsrSB_komma
xquest_branch:  rts



* ELSE-Code for high-level branches, s. BRANCH
else_code:      movea.l (SP)+,A0
                move.l  (A0),D0
                jmp     0(A5,D0.l)


CHEAD branch, 6
branch:         move.l  #(else_code-sys-of),-(A6)
                jmp     (jsrSB_komma-sys-of)(A5)
xbranch:

* else_cd:      bra     #$12345678


*xelse:
*               move.l  d5,d0
*               addi.l  #odp,d0
*               move.l  (a3,d0.l),d1            ;CP @
*               move.l  #(else_cd-sys-of),a0
*               adda.l  a5,a0
*               move.l  (a0)+,(a5,d1.l)         ;copy code
*               addq.l  #4,d1
*               move.l  d1,(a3,d0.l)            ;CP !
*               subq.l  #2,d1
*               move.l  (a6)+,d2                ;position of IF
*               move.l  d1,-(a6)                ;something like >MARK
*               addq.l  #2,d1
*               sub.l   d2,d1                   ;distance
*               move.w  d1,(a5,d2.l)            ;fix offset
*               rts

*                ENDPART


*****************************************************************
*                >PART 'comparisons'
*                                                               *
*****************************************************************


CHEAD null_gleich, 8
null_gleich:    tst.l   (A6)
                seq     D0
                ext.w   D0
                ext.l   D0
                move.l  D0,(A6)
xnull_gleich:   rts



CHEAD null_less, 8
null_less:      tst.l   (A6)
                slt     D0
                ext.w   D0
                ext.l   D0
                move.l  D0,(A6)
xnull_less:     rts



CHEAD gleich, 8
gleich: 		cmpm.l  (A6)+,(a6)+
                seq     D0
                ext.w   D0
                ext.l   D0
                move.l  D0,-(A6)
xgleich:        rts



CHEAD uless, 0
uless:			cmpm.l  (A6)+,(a6)+
                scs     D0
                ext.w   D0
                ext.l   D0
                move.l  D0,-(A6)
xuless:			rts



CHEAD less, 0
less:           move.l  (A6)+,D0
                cmp.l   (A6),D0
                sgt     D0
                ext.w   D0
                ext.l   D0
                move.l  D0,(A6)
xless:          rts



CHEAD greater, 8
greater:        move.l  (A6)+,D0
                cmp.l   (A6),D0
                slt     D0
                ext.w   D0
                ext.l   D0
                move.l  D0,(A6)
xgreater:       rts




CHEAD min, 8
min:            move.l  (A6)+,D0
                cmp.l   (A6),D0
                bgt.s   xmin
                move.l  D0,(A6)
xmin:           rts



CHEAD max, 8
max:            move.l  (A6)+,D0
                cmp.l   (A6),D0
                blt.s   xmax
                move.l  D0,(A6)
xmax:			rts




*                ENDPART

*****************************************************************
*                >PART 'words using existing runtimes'
*                                                               *
*****************************************************************
CHEAD string_komma, 0
string_komma:   move.l  #'"',-(A6)
                bsr     word
                moveq   #0,D0
                move.l  (A6)+,D0
                moveq   #0,D1
                move.b  0(A3,D0.l),D1   ;fetch count
                addq.b  #1,D1           ;count byte
                move.l  D1,-(A6)
                bsr     allot
xstring_komma:  rts



CHEAD string_emit, 6
string_emit:    move.l  #(b_string_emit-sys-of),-(A6)
                bsr     jsrSB_komma
                bsr     align
                bsr     here
                bsr     code_komma
                bsr.s   string_komma
xstring_emit:   rts



CHEAD dot_brack, 2
dot_brack:      move.l  #')',-(A6)
                bsr     word
                bsr     count
                bsr     type
xdot_brack:     rts



CHEAD comment_brack, 2
comment_brack:  move.l  #')',-(A6)
                bsr     word
                addq.l  #4,A6
xcomment_brack: rts



CHEAD error_quote, 6
error_quote:    move.l  #(b_error_quote-sys-of),-(A6) ;cfa
                bsr     jsrSB_komma
                bsr     align
                bsr     here
                bsr     code_komma
                bsr     string_komma
xerror_quote:   rts



CHEAD abort, 0
abort:			move.l	#-1,-(a6)
				bsr		throw
xabort:			rts



CHEAD abort_quote, 6
abort_quote:    move.l  #(b_abort_quote-sys-of),-(A6)
                bsr     jsrSB_komma
                bsr     align
                bsr     here
                bsr     code_komma
                bsr     string_komma
xabort_quote:   rts



CHEAD quote, 2
quote:          move.l  D5,D0
                addi.l  #ostate,D0
                tst.l   0(A3,D0.l)      ;STATE @ IF
                beq.s   quote1
                move.l  #(b_str_quote-sys-of),-(A6)
                bsr     jsrSB_komma
                bsr     align
                bsr     here
                bsr     code_komma
                bra     string_komma
quote1:         move.l  #'"',-(A6)      ;ELSE ASCII " WORD
                bsr     word
                bsr     pad
                move.l  4(A6),D0        ;COUNT 1+
                clr.l   -(A6)
                move.b  0(A3,D0.l),3(A6) ;PAD    SWAP CMOVE
                addq.l  #1,(A6)
                bsr     cmove
                bsr     pad             ;PAD
				bra		count			;COUNT
xquote:

******************************************************************

CHEAD postpone, 6
postpone:       bsr     name
                bsr     find
                move.l  (A6)+,D0		; anything found?
                beq.s   post_err
				move.l	(a6),d0
				btst	#1,-1(a5,d0.l)	; immediate?
                bne.s   compile         ;then compile it
                bsr     literal
                move.l  #(com_komma-sys-of),-(A6) ;xt of COM,
compile:        bra     com_komma
post_err:       bra     notfound
xpostpone:

          
          
CHEAD immediate, 0          
immediate:      move.l  D5,D0
                addi.l  #olast,D0
                move.l  0(A3,D0.l),D0   ;header of last word
				move.l 	0(a3,d0.l),d0	;pointer to code
				ori.w   #2,-2(A5,D0.l)   ;set immediate bit
ximmediate:     rts



CHEAD restrict, 0
restrict:       move.l  D5,D0
                addi.l  #olast,D0
                move.l  0(A3,D0.l),D0   ;header of last word
*                ori.w   #4,0(A3,D0.l)   ;set restrict bit
		move.l 0(a3,d0.l),d0	;pointer to code
		ori.w   #4,-2(A5,D0.l)   ;set restrict bit
xrestrict:      rts

*                ENDPART



*****************************************************************
*                >PART 'FILL, ERASE'


CHEAD fill, 0
fill:           move.l  (A6)+,D0
                move.l  (A6)+,D1
                movea.l (A6)+,A0
                adda.l  A3,A0
*                subq.l  #1,D1
			bra	start_fill
fill_loop:      move.b  D0,(A0)+
start_fill:		dbra    D1,fill_loop
xfill:          rts



CHEAD erase, 0
erase:          move.l  (A6)+,D0
                movea.l (A6)+,A0
                adda.l  A3,A0
*                subq.l  #1,D0
			bra	starterase
eraseloop:      clr.b   (A0)+
starterase:		dbra    D0,eraseloop
xerase:         rts

*                ENDPART

*****************************************************************
*                >PART '1+, CELL+, etc.'


CHEAD one_plus, 8
one_plus:       addq.l  #1,(A6)
xone_plus:      rts


CHEAD one_minus, 8
one_minus:      subq.l  #1,(A6)
xone_minus:     rts

           
           
CHEAD two_mult, 8
two_mult:       move.l  (A6),D0
                add.l   D0,D0
                move.l  D0,(A6)
xtwo_mult:      rts



CHEAD two_div, 8
two_div:        move.l  (A6),D0
                asr.l   #1,D0
                move.l  D0,(A6)
xtwo_div:       rts



CHEAD cell_plus, 8
cell_plus:      addq.l  #4,(A6)
xcell_plus:     rts



CHEAD cells, 8
cells:          move.l  (A6),D0
                asl.l   #2,D0
                move.l  D0,(A6)
xcells:         rts



CHEAD char_plus, 8
char_plus:      addq.l  #1,(A6)
xchar_plus:     rts



CHEAD chars, 2
chars:          
xchars:			rts



*                ENDPART



HERE:

