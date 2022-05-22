music		

max_pat         EQU 32
i_noise_freq    EQU 0
i_sound_mode    EQU 2
i_env_type      EQU 3
i_env_freq      EQU 4
i_vibr_speed    EQU 6
i_vibr_depth    EQU 8
i_interval1     EQU 252
i_interval2     EQU 254
i_env_attack    EQU 10
i_env_sustain   EQU 12
i_env_release   EQU 14
i_env_start     EQU 16
i_env_len       EQU 112
i_pit_attack    EQU 240
i_pit_sustain   EQU 242
i_pit_release   EQU 244
i_pit_start     EQU 128
i_pit_len       EQU 112
i_total_len     EQU 256

init_music:     
                  bsr   play3v
                  clr.w pat_lin
                  bsr   calc_pos
                  bsr   calc_sam_ptrs
		bsr	snd_init	
		rts

init_digi:        move  sr,-(sp)
                  move  #$2700,sr       ;zet INTs uit
                  bsr.s snd_init        ;initialiseer PSG
                  move.l #intnorm,$0134.w ;set timer A address
                  move.b #1,$fffffa19.w ;start timer A
                  bclr  #5,$fffffa07.w  ;timer A disable
                  bset  #5,$fffffa13.w  ;timer A mask
		move.w (sp)+,sr
                  rts

snd_init:         move  sr,-(sp)
                  move  #$2700,sr
                  bclr  #5,$fffffa07.w  ;zet timer A voor kanaal A stil
                  bset  #0,adata+silent ;zet kanalen uit
                  bclr  #1,adata+silent ;geen sample op kanaal A
                  bset  #0,bdata+silent
                  bset  #0,cdata+silent
                  st    adata+instr_no  ;maak instrumenten nummer $ff zodat bij vergelijking instrument data opnieuw geladen wordt
                  st    bdata+instr_no
                  st    cdata+instr_no
                  lea   $ffff8800.w,a0
                  lea   clear_ym(pc),a1
                  moveq #13-1,d1
cym:              move.w (a1)+,d0
                  movep.w d0,0(a0)
                  dbra  d1,cym
                  move.b #7,(a0)
                  move.b (a0),d0        ;haal waarde reg #7
                  andi.b #%11000000,d0  ;laat A/B I/O staan
                  or.b  #%111111,d0     ;zet alles verder uit
                  move.b d0,2(a0)       ;sla reg #7 op
		move.w (sp)+,sr
		rts

clear_ym:       DC.B 0,0,1,0,2,0,3,0,4,0,5,0,6,0,8,0,9,0,10,0,11,0,12,0,13,0
;
;               ***** SOUND PLAY INIT ROUTINE *****
;
play3v:           move.w #1,last_pat    ;aantal patterns is eerst 1

                  move.w #max_pat-1,d0  ;haal aantal patterns-1 (voor dbra lus)
                  lea   patterns(pc),a0 ;begin adres patterns
                  lea   pat_tab,a1      ;begin adres pattern tabel
init_pat_tab:     move.l a0,(a1)+       ;sla adres pattern op
                  adda.l #64*12,a0      ;naar volgende pattern
                  dbra  d0,init_pat_tab ;net zo lang tot alle pattern geweest zijn

                  move.w #1,note_count  ;begin meteen met noot
                  clr.w pos_now         ;begin bij position #0
                  move.l #patterns,pat_ptr ;pointer IN pattern goed zetten
                  move.l #patterns,pat_base ;pointer NAAR pattern goed zetten

;               ***** INITIALISEER VOICE STATUS STRUCTURE ******
                  clr.b adata+sound_mode
                  move.l #env_0,adata+env_ptr
                  move.w #2,adata+env_att
                  move.w #5,adata+env_sus
                  move.w #9,adata+env_rel
                  move.l #env_0,adata+pit_ptr
                  move.w #2,adata+pit_att
                  move.w #5,adata+pit_sus
                  move.w #9,adata+pit_rel

                  clr.b bdata+sound_mode
                  move.l #env_0,bdata+env_ptr
                  move.w #2,bdata+env_att
                  move.w #5,bdata+env_sus
                  move.w #9,bdata+env_rel
                  move.l #env_0,bdata+pit_ptr
                  move.w #2,bdata+pit_att
                  move.w #5,bdata+pit_sus
                  move.w #9,bdata+pit_rel

                  clr.b cdata+sound_mode
                  move.l #env_0,cdata+env_ptr
                  move.w #2,cdata+env_att
                  move.w #5,cdata+env_sus
                  move.w #9,cdata+env_rel
                  move.l #env_0,cdata+pit_ptr
                  move.w #2,cdata+pit_att
                  move.w #5,cdata+pit_sus
                  move.w #9,cdata+pit_rel
;
                  rts
do_play:        

                  subq.w #1,note_count  ;moet er een nieuwe noot gepakt worden?
                  bne   do_fx_all       ;als niet zo -> spring over noot routine heen
                  move.w speed(pc),note_count ;herstel voordeler
                  movea.l pat_base,a1   ;haal pointer naar begin van pattern
                  move.w pat_lin,d0     ;haal regel#
                  move.w d0,d1
                  lsl.w #3,d0
                  add.w d1,d1
                  add.w d1,d1
                  add.w d1,d0           ;vermenigvuldig met lengte 1 noot
                  adda.w d0,a1          ;en tel op bij pointer in pattern
                  move.l a1,pat_ptr     ;sla pointer op voor later
                  addq.w #1,pat_lin     ;naar volgende regel
                  cmpi.w #64,pat_lin    ;zijn we al bij het einde?
                  bne   read_notes_all  ;als we het einde nog niet bereikt hebben -> ga door
                  bsr   load_pos        ;haal nieuwe positie

read_notes_all:   movea.l pat_ptr,a1    ;haal pointer in pattern weer terug
**************************************************************************
                  lea   adata,a0        ;haal adres channel A data-field
                  bsr   getnote         ;lees noot

                  btst  #1,sound_mode(a0) ;noise on ?
                  beq   next_channelb
                  tst.b instr_no(a0)    ;0-7
                  bmi   next_channelb
                  cmpi.b #8,instr_no(a0)
                  bge   next_channelb
                  move.b instr_no(a0),d0
                  ext.w d0
                  add.w d0,d0
                  add.w d0,d0
                  lea   noise_ptrs,a6
                  move.l 0(a6,d0.w),current_noise_a
                  bra   do_noise_ax
next_channelb:    move.l #-1,current_noise_a
********************************************************************
do_noise_ax:      lea   bdata,a0        ;haal adres channel B data-field
                  bsr   getnote         ;lees noot

                  btst  #1,sound_mode(a0) ;noise on ??
                  beq   next_channelc
                  tst.b instr_no(a0)    ;0-7
                  bmi   next_channelc
                  cmpi.b #8,instr_no(a0)
                  bge   next_channelc
                  move.b instr_no(a0),d0
                  ext.w d0
                  add.w d0,d0
                  add.w d0,d0
                  lea   noise_ptrs,a6
                  move.l 0(a6,d0.w),current_noise_b
                  bra   do_noise_bx
next_channelc:    move.l #-1,current_noise_b
***********************************************************
do_noise_bx:      lea   cdata,a0        ;haal adres channel C data-field
                  bsr   getnote         ;lees noot

                  btst  #1,sound_mode(a0) ;noise on ?
                  beq   last_channel
                  tst.b instr_no(a0)    ;0-7
                  bmi   last_channel
                  cmpi.b #8,instr_no(a0)
                  bge   last_channel
                  move.b instr_no(a0),d0
                  ext.w d0
                  add.w d0,d0
                  add.w d0,d0
                  lea   noise_ptrs,a6
                  move.l 0(a6,d0.w),current_noise_c
                  bra   do_fx_all
last_channel:     move.l #-1,current_noise_c

;               ***** GEEN NOOT, ENKEL EFFECTEN *****
do_fx_all:
                  lea   cdata,a0        ;haal adres channel C data-field
                  bsr   do_fx           ;doe envelope, tremolo etc.

                  lea   bdata,a0        ;haal adres channel B data-field
                  bsr   do_fx           ;doe envelope, tremolo etc.

                  lea   adata,a0        ;haal adres channel A data-field
                  bsr   do_fx           ;doe envelope, tremolo etc.

******************************************************************
                  lea   cdata,a0
                  move.b #%11111111,d0  ;standaard masker voor REG #7
                  moveq #-1,d1

************** REG 7 : KANAAL C *************************************
                  btst  #0,sound_mode(a0) ;toon op kanaal C?
                  beq.s no_tone_c       ;nee -> niks doen
                  bclr  #2,d0           ;ja -> wis bijhorende bit
no_tone_c:
                  btst  #1,sound_mode(a0) ;ruis op kanaal C?
                  beq.s no_nois_c       ;nee -> niks doen

                  movea.l current_noise_c,a6
                  cmpa.l #-1,a6
                  beq   normal_noise_c
                  bclr  #1,sound_mode(a0)
                  cmpi.b #-1,(a6)
                  beq   no_nois_c
                  bset  #1,sound_mode(a0)
                  addq.l #1,current_noise_c
                  cmpi.b #-2,(a6)
                  beq   no_nois_c
                  bclr  #5,d0
                  move.b (a6),d1
                  bra   no_nois_c
normal_noise_c:   bclr  #5,d0
                  move.w noise_freq(a0),d1
no_nois_c:

******* REG 7 : KANAAL B ******************************************
                  lea   bdata,a0

                  btst  #0,sound_mode(a0) ;toon op kanaal B?
                  beq.s no_tone_b       ;nee -> niks doen
                  bclr  #1,d0           ;ja -> wis bijhorende bit
no_tone_b:
                  btst  #1,sound_mode(a0) ;ruis op kanaal B?
                  beq.s no_nois_b       ;nee -> niks doen

                  movea.l current_noise_b,a6
                  cmpa.l #-1,a6
                  beq   normal_noise_b
                  bclr  #1,sound_mode(a0)
                  cmpi.b #-1,(a6)
                  beq   no_nois_b
                  bset  #1,sound_mode(a0)
                  addq.l #1,current_noise_b
                  cmpi.b #-2,(a6)
                  beq   no_nois_b
                  bclr  #4,d0
                  move.b (a6),d1
                  bra   no_nois_b
normal_noise_b:   bclr  #4,d0
                  move.w noise_freq(a0),d1
no_nois_b:

*************** REG 7 : KANAAL A ******************************
                  lea   adata,a0

                  btst  #1,silent(a0)   ;wordt er een sample gespeeld?
                  bne.s no_nois_a       ;ja -> geen toon en geen ruis op kanaal A
                  btst  #0,sound_mode(a0) ;toon op kanaal A?
                  beq.s no_tone_a       ;nee -> niks doen
                  bclr  #0,d0           ;ja -> wis bijhorende bit
no_tone_a:
                  btst  #1,sound_mode(a0) ;ruis op kanaal A?
                  beq.s no_nois_a       ;nee -> niks doen

                  movea.l current_noise_a,a6
                  cmpa.l #-1,a6
                  beq   normal_noise_a
                  bclr  #1,sound_mode(a0)
                  cmpi.b #-1,(a6)
                  beq   no_nois_a
                  bset  #1,sound_mode(a0)
                  addq.l #1,current_noise_a
                  cmpi.b #-2,(a6)
                  beq   no_nois_a
                  bclr  #3,d0
                  move.b (a6),d1
                  bra   no_nois_a
normal_noise_a:   bclr  #3,d0
                  move.w noise_freq(a0),d1
no_nois_a:
                  move  #$2700,sr
                  tst.w d1
                  bmi   no_6
                  move.b #6,$ffff8800.w
                  move.b d1,$ffff8802.w
no_6:             move.b #7,$ffff8800.w ;register 7
                  move.b d0,$ffff8802.w ;schrijf waarde weg
                  move  #$2500,sr       ;MFP interrupts weer aan

                  lea   $ffff8800.w,a1  ;adres PSG register select
                  lea   $ffff8802.w,a2  ;adres PSG write data
                  move  #$2700,sr       ;MFP interrupts uit

                  btst  #1,silent(a0)   ;wordt er een sample gespeeld?
                  bne.s do_nout_a       ;ja -> doe niks met kanaal A registers
                  clr.b (a1)            ;tone freq register
                  move.b psgfreq+1(a0),(a2) ;haal frequency, schrijf lobyte freq
                  move.b #1,(a1)
                  move.b psgfreq(a0),(a2) ;haal en schrijf frequency hi-byte,
                  tst.b silent(a0)      ;staat dit kanaal aan?
                  bne.s no_hardw_auto_a ;nee -> laat hardware frequency dan -> voorkomt interferentie met andere kanalen
                  btst  #2,sound_mode(a0) ;staat er uberhaupt hardware op dit kanaal?
                  beq.s no_hardw_auto_a
                  btst  #3,sound_mode(a0) ;staat hardware frequency op auto?
                  beq.s no_hardw_auto_a
                  move.w psgfreq(a0),d0
                  lsr.w #4,d0           ;deel frequency door 16, voor hardware frequency
                  move.b #11,(a1)       ;hardware frequency register
                  move.b d0,(a2)        ;schrijf lo-byte frequency
                  move.l #$0c000000,(a1) ;hi-byte frequency = 0
no_hardw_auto_a:  move.b #8,(a1)        ;volume kanaal A
                  move.b psgvol(a0),(a2)

do_nout_a:        lea   bdata,a0        ;adres variabelen gebied kanaal B
                  move.b #2,(a1)        ;tone freq register
                  move.b psgfreq+1(a0),(a2) ;haal en schrijf frequency lo-byte
                  move.b #3,(a1)
                  move.b psgfreq(a0),(a2) ;haal en schrijf frequency hi-byte
                  tst.b silent(a0)      ;staat dit kanaal aan?
                  bne.s no_hardw_auto_b ;nee -> laat hardware frequency dan -> voorkomt interferentie met andere kanalen
                  btst  #2,sound_mode(a0) ;staat er uberhaupt hardware op dit kanaal?
                  beq.s no_hardw_auto_b
                  btst  #3,sound_mode(a0) ;staat hardware frequency op auto?
                  beq.s no_hardw_auto_b
                  move.w psgfreq(a0),d0
                  lsr.w #4,d0           ;deel frequency door 16, voor hardware frequency
                  move.b #11,(a1)       ;hardware frequency register
                  move.b d0,(a2)        ;schrijf lo-byte frequency
                  move.l #$0c000000,(a1) ;hi-byte frequency = 0
no_hardw_auto_b:  move.b #9,(a1)        ;volume kanaal B
                  move.b psgvol(a0),(a2)

                  lea   cdata,a0        ;adres variabelen gebied kanaal C
                  move.b #4,(a1)        ;tone freq register
                  move.b psgfreq+1(a0),(a2) ;haal en schrijf frequency lo-byte
                  move.b #5,(a1)
                  move.b psgfreq(a0),(a2) ;haal en schrijf frequency hi-byte
                  tst.b silent(a0)      ;staat dit kanaal aan?
                  bne.s no_hardw_auto_c ;nee -> laat hardware frequency dan -> voorkomt interferentie met andere kanalen
                  btst  #2,sound_mode(a0) ;staat er uberhaupt hardware op dit kanaal?
                  beq.s no_hardw_auto_c
                  btst  #3,sound_mode(a0) ;staat hardware frequency op auto?
                  beq.s no_hardw_auto_c
                  move.w psgfreq(a0),d0
                  lsr.w #4,d0           ;deel frequency door 16, voor hardware frequency
                  move.b #11,(a1)       ;hardware frequency register
                  move.b d0,(a2)        ;schrijf lo-byte frequency
                  move.l #$0c000000,(a1) ;hi-byte frequency = 0
no_hardw_auto_c:  move.b #10,(a1)       ;volume kanaal C
                  move.b psgvol(a0),(a2)

                  move  #$2300,sr       ;MFP interrupts weer aan
                  rts                   ;kom TERUG van routine

do_fx:            tst.b silent(a0)      ;kijk of dit kanaal stil moet zijn
                  bne   do_silent       ;ja -> clear PSG volume
                  btst  #2,sound_mode(a0) ;kijk of hardware envelope aan staat
                  beq.s no_he           ;nee -> doe niks
                  move.b #$10,psgvol(a0) ;zet volume op hardware envelope
                  bra.s to_tie          ;spring over rest heen

no_he:            move.w env_offs(a0),d0 ;haal envelope offset
                  movea.l env_ptr(a0),a2 ;haal pointer naar envelope
                  move.b 0(a2,d0.w),d1  ;haal lokaal volume
                  move.b g_vol(a0),d2   ;haal globaal volume
                  asl.b #4,d2           ;vermenigvuldig met 16 voor offset naar goede tabel
                  add.b d1,d2           ;tel lokaal volume bij globaal volume
                  andi.w #$ff,d2        ;maak word van volume
                  lea   vols(pc),a2     ;haal adres volume tabellen
                  move.b 0(a2,d2.w),psgvol(a0) ;bereken volume dat uiteindelijk in PSG moet
                  addq.w #1,d0          ;verhoog offset
                  cmp.w env_sus(a0),d0  ;zijn we aan het begin van de release?
                  bne.s no_sus_rep      ;nee -> niet sustain herhalen
                  move.w env_att(a0),d0 ;ja -> zet offset weer op sustain
no_sus_rep:       cmp.w env_rel(a0),d0  ;zijn we al (voor)bij het einde?
                  blo.s no_rel          ;nee -> volume niet 0 maken
                  bset  #0,silent(a0)   ;zet silent bit van dit kanaal zodat dit kanaal zodirekt stil is
no_rel:           move.w d0,env_offs(a0) ;sla offset op
to_tie:           move.w tie_stp(a0),d0 ;haal stap voor tie
                  beq.s no_tie          ;als tie=0 -> geen tie
                  bmi.s tie_lo          ;bij negatieve stap is target lager dan huidige freq
                  add.w p_freq(a0),d0   ;verhoog frequentie met stap
                  cmp.w g_freq(a0),d0   ;is de frequentie op goede hoogte?
                  blt.s no_reach_tie_hi ;als werkelijke frequentie lager is dan echte, zijn we er nog niet
                  clr.w tie_stp(a0)     ;wis tie stap
                  move.w g_freq(a0),d0  ;haal echte frequentie -> soms wijkt de gemaakte af door scheve offsets
no_reach_tie_hi:  move.w d0,p_freq(a0)  ;zet frequentie weg
                  bra.s no_tie          ;sla tie lo over
tie_lo:           add.w p_freq(a0),d0   ;verlaag frequentie met stap
                  cmp.w g_freq(a0),d0   ;is de frequentie op goede hoogte?
                  bgt.s no_reach_tie_lo ;als werkelijke frequentie hoger is dan echte, zijn we er nog niet
                  clr.w tie_stp(a0)     ;wis tie stap
                  move.w g_freq(a0),d0  ;haal echte frequentie -> soms wijkt de gemaakte af door scheve offsets
no_reach_tie_lo:  move.w d0,p_freq(a0)  ;sla frequentie op
no_tie:           move.w trem_offs(a0),d1 ;haal offset daarin
                  add.w vibr_speed(a0),d1 ;verhoog offset in tremolo tabel
                  cmpi.w #59,d1         ;zijn we al voorbij het einde
                  bls.s no_re_trem      ;nee -> ga door
                  moveq #0,d1           ;begin opnieuw aan tabel
no_re_trem:       move.w d1,trem_offs(a0) ;sla offset weer op
                  add.w d1,d1           ;vermenig vuldig met 2 voor word tabel
                  lea   trem_tab(pc),a2 ;haal pointer naar tremolo tabel
                  move.w 0(a2,d1.w),d1  ;pak variatie van frequentie
                  move.w vibr_depth(a0),d2 ;haal diepte van tremolo
                  asr.w d2,d1           ;maak goede diepte tremolo aan
                  add.w p_freq(a0),d1   ;tel echte frequentie bij variatie op

                  cmpi.b #9,instr_no(a0)
                  beq   spec_arp1
                  cmpi.b #10,instr_no(a0)
                  beq   spec_arp2
                  move.b int_now(a0),d0 ;bij welke interval zijn we nu?
                  beq.s intr_0          ;0=normale frequentie
                  cmpi.b #1,d0          ;1=interval #1
                  beq.s intr_1
                  add.w int_freq2(a0),d1 ;tel interval #2 bij huidige frequentie
                  clr.b int_now(a0)     ;volgende keer 0
                  bra.s intr_2
intr_1:           add.w int_freq1(a0),d1 ;tel interval #1 bij huidige frequentie
intr_0:           addi.b #1,int_now(a0) ;verhoog interval count
intr_2:                                 ; laat frequentie in d1
dope_demand:
;               ***** EFFECTEN : PITCH ENVELOPE *****
                  tst.b pit_mode(a0)    ;staat pitch aan (vergelijkbaar met silent bit#0 voor amplitude envelope)
                  beq.s no_pitch        ;pitch uit -> tel er geen frequentie bij op

                  move.w pit_offs(a0),d0 ;haal pitch envelope offset
                  movea.l pit_ptr(a0),a2 ;haal pointer naar envelope
                  move.b 0(a2,d0.w),d2  ;haal relatieve frequentie
                  ext.w d2              ;sign-extend byte tot word
;; Mega Bassdrum ;;
                  cmpi.b #0,instr_no(a0)
                  blt   no_high
                  cmpi.b #5,instr_no(a0) ;*X
                  bgt   no_high         ;*X
                  mulu  #6,d2
                  addq.w #2,d0          ;*X
;;;;;;;;;;;;;;;;;;;
no_high:          add.w d2,d1           ;tel relatieve frequentie bij huidige frequentie
; bereken volgende offset
                  addq.w #1,d0          ;verhoog offset

                  cmp.w pit_sus(a0),d0  ;zijn we aan het begin van de release?
                  bne.s no_pit_sus_rep  ;nee -> niet sustain herhalen
                  move.w pit_att(a0),d0 ;ja -> zet offset weer op sustain
no_pit_sus_rep:
                  cmp.w pit_rel(a0),d0  ;zijn we al (voor)bij het einde?
                  blo.s no_pit_rel      ;nee -> volume niet 0 maken
                  clr.b pit_mode(a0)    ;pitch afgelopen -> zet pitch afhandeling uit
no_pit_rel:
                  move.w d0,pit_offs(a0) ;sla offset op
no_pitch:
                  move.w d1,psgfreq(a0) ;sla frequentie op
;
                  rts

do_silent:        clr.b psgvol(a0)      ;wis PSG volume
                  rts
;
spec_arp1:        addq.w #1,sparp_1
                  move.w sparp_1,d0
                  bra   use_spec1
spec_arp2:        addq.w #1,sparp_2
                  move.w sparp_2,d0
use_spec1:        cmp.w #1,d0
                  bne   no_interv
                  add.w int_freq1(a0),d1
no_interv:        bra   dope_demand

getnote:          tst.b (a1)            ;bekijk noot/octaaf
                  beq   test_env        ;als octaaf/noot = 0 -> geen verandering, maar bekijk envelope
                  bmi   sam_note        ;als octaaf/noot < 0 -> lees sample
                  move.b 2(a1),d1       ;haal instrument nummer
;                  cmp.b instr_no(a0),d1 ;hebben we dit instrument al?
;                  beq   same_instr      ;ja -> ga door
                  cmp.b #$3f,d1         ;vergelijk YMS# met maximum ($3f=63)
                  bhi   same_instr      ;als d0>maximum -> verkeerd nummer en negeer dit instrument dus
                  move.b d1,instr_no(a0) ;sla instrument nummer op voor vergelijking
                  andi.w #$3f,d1        ;maak word van YM sound
                  lea   ym_sounds(pc),a2 ;haal adres begin YM sounds
                  asl.w #8,d1           ;maal 256(=lengte 1 ym sound)
                  adda.w d1,a2          ;tel die offset op bij start adres
                  move.w i_noise_freq(a2),d0 ;haal frequentie ruis
                  move.w d0,noise_freq(a0) ;sla op
                  btst  #1,i_sound_mode(a2) ;heeft dit instrument noise aan?
                  beq.s no_instr_noise  ;nee -> zet frequentie dan niet in PSG
                  move  #$2700,sr       ;disable MFP interrupts
                  move.b #6,$ffff8800.w ;register #6 : noise freq
                  move.b d0,$ffff8802.w
                  move  #$2300,sr       ;re-enable MFP interrupts
no_instr_noise:   move.b i_sound_mode(a2),sound_mode(a0) ;haal sound mode
                  move.w i_env_freq(a2),h_env_freq(a0) ;haal frequentie hardware envelope
                  move.b i_env_type(a2),h_env_type(a0) ;haal type hardware envelope
                  move.w i_vibr_speed(a2),vibr_speed(a0) ;haal snelheid van vibrato
                  move.w i_vibr_depth(a2),vibr_depth(a0) ;haal diepte van vibrato
                  move.w i_interval1(a2),interval1(a0) ;haal interval #1
                  move.w i_interval2(a2),interval2(a0) ;haal interval #2
                  clr.w env_offs(a0)    ;clear envelope offset
                  move.w i_env_attack(a2),env_att(a0) ;haal attack einde
                  move.w i_env_sustain(a2),env_sus(a0) ;haal sustain einde
                  move.w i_env_release(a2),env_rel(a0) ;haal release einde
                  lea   i_env_start(a2),a3 ;haal start envelope tabel
                  move.l a3,env_ptr(a0)
                  clr.w pit_offs(a0)    ;clear pitch envelope offset
                  move.w i_pit_attack(a2),pit_att(a0) ;haal pitch attack einde
                  move.w i_pit_sustain(a2),pit_sus(a0) ;haal pitch sustain einde
                  move.w i_pit_release(a2),pit_rel(a0) ;haal pitch release einde
                  lea   i_pit_start(a2),a3 ;haal start pitch envelope tabel
                  move.l a3,pit_ptr(a0)
                  st    pit_mode(a0)    ;zet pitch aan

                  cmpi.b #9,instr_no(a0)
                  bne   next_arp
                  clr.w sparp_1
next_arp:         cmpi.b #10,instr_no(a0)
                  bne   next_arp2
                  clr.w sparp_2
next_arp2:

same_instr:       moveq #0,d0           ;maak d0 leeg zodat we het zodirekt als word kunnen behandelen
                  move.b (a1),d0        ;haal octaaf(0-7) & noot (0-24 in stappen van 2)
                  move.w d0,d1          ;maak backup van octaaf
                  lsr.w #4,d1           ;haal octaaf# naar goede plaats
                  lea   note_2_freq(pc),a2 ;haal pointer naar noot->freq omreken tabel
                  andi.w #$0f,d0        ;maskeer noot
                  move.w d0,d2          ;bewaar noot en gebruik d2
                  add.w d2,d2           ;maal 2 voor offset in word tabel
                  move.w 0(a2,d2.w),d2  ;haal bijhorende frequentie in octaaf 1 (is hier octaaf 0)
                  lsr.w d1,d2           ;verdubbel frequentie zovaak als octaaf nummer-1
                  move.w d2,g_freq(a0)  ;sla verkregen frequentie op
                  move.w d0,d3          ;bewaar noot en gebruik d3
                  add.w interval1(a0),d3 ;tel interval bij noot# op
                  add.w d3,d3           ;maal 2 voor offset in word tabel
                  move.w 0(a2,d3.w),d3  ;haal bijhorende frequentie in octaaf 1 (is hier octaaf 0)
                  lsr.w d1,d3           ;verdubbel frequentie zovaak als octaaf nummer-1
                  sub.w d2,d3           ;haal van nieuwe frequentie oorspronkelijke frequentie af, voor relative frequentie
                  move.w d3,int_freq1(a0) ;sla interval frequency op
                  add.w interval2(a0),d0 ;tel interval bij noot# op
                  add.w d0,d0           ;maal 2 voor offset in word tabel
                  move.w 0(a2,d0.w),d0  ;haal bijhorende frequentie in octaaf 1 (is hier octaaf 0)
                  lsr.w d1,d0           ;verdubbel frequentie zovaak als octaaf nummer-1
                  sub.w d2,d0           ;haal van nieuwe frequentie oorspronkelijke frequentie af, voor relative frequentie
                  move.w d0,int_freq2(a0) ;sla interval frequency op
                  move.b 1(a1),d1       ;haal tie waarde
                  beq.s no_calc_tie     ;als tie value=0 dan is er geen tie
calc_tie:                               ;in d2 zit huidige frequentie nog
                  sub.w p_freq(a0),d2   ;trek huidige frequentie van target freq af voor step
                  ext.l d2              ;maak long van step voor delen
                  andi.l #$ff,d1        ;maak long van aantal te 'tie'en noten
                  muls  speed,d1        ;vermenigvuldig " met speed
                  divs  d1,d2           ;deel d2 door snelheid*noten voor tie stap
                  beq.s no_calc_tie     ;als tie stap=0 zet freq meteen goed
                  move.w d2,tie_stp(a0) ;sla tie stap op
                  bra.s yes_calc_tie
no_calc_tie:      move.w g_freq(a0),p_freq(a0) ;zet globale frequentie meteen als huidige frequentie
                  clr.w tie_stp(a0)     ;clear tie stap
yes_calc_tie:     move.b 3(a1),d0       ;haal envelope/volume
                  andi.w #$1f,d0        ;maskeer volume en verwijder envelope en maak er tegelikertijd een word van
                  move.b d0,g_vol(a0)   ;sla volume op
test_env:         addq.l #3,a1
                  move.b (a1)+,d1       ;haal envelope value(& volume)
                  lsr.b #6,d1           ;verschuif hem naar de onderste bits en verwijder volume
                  tst.b d1              ;*******
                  beq.s same_env        ;als envelope value=0 (NO_CHANGE), dan niks veranderen
                  btst  #2,sound_mode(a0) ;wordt hardware envelope op dit kanaal gespeeld?
                  bne.s he_adsr         ;ja -> voer dat soort envelope uit
                  cmpi.b #1,d1          ;is envelope value dan 1?
                  beq.s attack_env      ;ja -> doe attack deel van envelope
                  cmpi.b #2,d1          ;is envelope value dan 2?
                  beq.s sustain_env     ;ja -> begin envelope bij sustain
;********                               ;dan maar release doen :
                  move.w env_sus(a0),env_offs(a0) ;zet offset op begin release
                  move.w pit_sus(a0),pit_offs(a0) ;zet pitch offset op begin release
                  bclr  #0,silent(a0)   ;clear silent bit
                  st    pit_mode(a0)    ;zet pitch aan
                  rts

sustain_env:      move.w env_att(a0),env_offs(a0) ;zet offset op begin sustain
                  move.w pit_att(a0),pit_offs(a0) ;zet pitch offset op begin sustain
                  bclr  #0,silent(a0)   ;clear silent bit
                  st    pit_mode(a0)    ;zet pitch aan
                  rts

attack_env:       clr.w env_offs(a0)    ;doe attack deel van envelope -> zet offset op 0
                  clr.w pit_offs(a0)    ;zet pitch envelope goed
                  clr.w trem_offs(a0)   ;zet tremolo offset op begin zodat iedere noot hetzelfde klinkt
                  bclr  #0,silent(a0)   ;clear silent bit
                  st    pit_mode(a0)    ;zet pitch aan
                  move  #$2700,sr       ;interrupts uit
                  bclr  #1,silent(a0)   ;clear sample bit
                  beq.s dont_stop_sam   ;als er geen sample op dit kanaal gespeeld werd -> doe niks
                  bclr  #5,$fffffa07.w  ;wel sample hier -> zet timer A uit
dont_stop_sam:    move  #$2300,sr       ;interrupts weer aan
same_env:         rts                   ;kom terug van subroutine

he_adsr:          tst.b d1              ;is envelope value dan 0?
                  beq.s cont_he         ;ja -> laat envelope als hij is
                  cmpi.b #2,d1          ;is envelope value dan 2?
                  beq.s sustain_he      ;ja -> begin envelope bij sustain
                  cmpi.b #3,d1          ;is envelope value dan 3?
                  beq   release_he      ;ja -> begin envelope bij release
                  move  #$2700,sr       ;geen oderbreking graag
                  btst  #3,sound_mode(a0) ;staat hardware automatic frequency aan?
                  bne.s attack_hardw_auto ;ja -> zet frequency niet; dat doet PSGfreq later
                  move.b #11,$ffff8800.w ;hardware envelope frequency
                  move.b h_env_freq+1(a0),$ffff8802.w
                  move.b #12,$ffff8800.w ;...
                  move.b h_env_freq(a0),$ffff8802.w
attack_hardw_auto:move.b #13,$ffff8800.w ;selecteer hardware envelope type register
                  btst  #0,h_env_type(a0) ;is dit een enkelvoudige envelope(niet continious)
                  bne.s yes_hardw_type  ;ja -> zet hardware type in PSG om weer aan het begin te beginnen
                  move.b $ffff8800.w,d0 ;nee -> zet hardware frequentie alleen neer als die er niet al staat -> zet hardware freq zo min mogelijk in PSG, om kraken tegen te gaan
                  cmp.b h_env_type(a0),d0 ;staat goede hardware type al in PSG?
                  beq.s no_hardw_type   ;ja -> laat het maar
yes_hardw_type:   move.b h_env_type(a0),$ffff8802.w ;zet hardware envelope type in PSG
no_hardw_type:    clr.w trem_offs(a0)   ;zet tremolo offset op begin zodat iedere noot hetzelfde klinkt
                  clr.w pit_offs(a0)    ;zet pitch offset op begin attack
                  st    pit_mode(a0)    ;zet pitch envelope aan
                  bclr  #0,silent(a0)   ;clear silent bit
                  bclr  #1,silent(a0)   ;clear sample bit
                  beq.s same_he         ;als er geen sample op dit kanaal gespeeld werd -> doe niks
                  bclr  #5,$fffffa07.w  ;wel sample hier -> zet timer A uit
same_he:          move  #$2300,sr
cont_he:          rts

sustain_he:       move  #$2700,sr       ;geen oderbreking graag
                  btst  #3,sound_mode(a0) ;staat hardware automatic frequency aan?
                  bne.s sustain_hardw_auto ;ja -> zet frequency niet; dat doet PSGfreq later
                  move.b #11,$ffff8800.w ;hardware envelope frequency
                  move.b h_env_freq+1(a0),$ffff8802.w
                  move.b #12,$ffff8800.w ;...
                  move.b h_env_freq(a0),$ffff8802.w
sustain_hardw_auto:move.b #13,$ffff8800.w ;selecteer hardware envelope type register
                  btst  #0,h_env_type(a0) ;is dit een enkelvoudige envelope(niet continious)
                  bne.s yes_sus_htype   ;ja -> zet hardware type in PSG om weer aan het begin te beginnen
                  move.b $ffff8800.w,d0 ;nee -> zet hardware frequentie alleen neer als die er niet al staat -> zet hardware freq zo min mogelijk in PSG, om kraken tegen te gaan
                  cmp.b h_env_type(a0),d0 ;staat goede hardware type al in PSG?
                  beq.s no_sus_htype    ;ja -> laat het maar
yes_sus_htype:    move.b h_env_type(a0),$ffff8802.w ;zet hardware envelope type in PSG
no_sus_htype:     clr.w trem_offs(a0)   ;zet tremolo offset op begin zodat iedere noot hetzelfde klinkt
                  move.w pit_att(a0),pit_offs(a0) ;zet pitch offset op begin sustain(=einde attack)
                  st    pit_mode(a0)    ;zet pitch envelope aan
                  bclr  #0,silent(a0)   ;clear silent bit
                  bclr  #1,silent(a0)   ;clear sample bit
                  beq.s same_sus_he     ;als er geen sample op dit kanaal gespeeld werd -> doe niks
                  bclr  #5,$fffffa07.w  ;wel sample hier -> zet timer A uit
same_sus_he:      move  #$2300,sr
                  rts

release_he:       bset  #0,silent(a0)   ;zet silent bit
                  rts

sam_note:         btst  #2,silent(a0)   ;moeten we muten?
                  bne.s no_new_sam      ;als mute bit=1 -> kanaal wordt gemute
                  move.b 2(a1),d0       ;haal sample nummer
                  andi.w #$0f,d0        ;neem alleen laagste nibble en maak er een word van
                  lea   sam_tab,a2      ;haal adres sample tabel
                  add.w d0,d0
                  add.w d0,d0           ;voor offset in tabel met longs
                  move  #$2700,sr       ;MFP interrupts uit
                  move.l 0(a2,d0.w),ss_start+2 ;schrijf adres sample in sample adres
                  move.b 1(a1),d0       ;haal hertz
                  andi.w #$0f,d0        ;neem alleen laagste nibble en maak er een word van
                  lea   hertz(pc),a2    ;start of hertz -> speed conversion table
                  move.b 0(a2,d0.w),$fffffa1f.w ;convert hertz into timer A data
                  move.b #%10,silent(a0) ;zodat de REG 7 routine weet dat er een sample gespeeld wordt en toon en ruis dus uit moeten
                  bset  #5,$fffffa07.w  ;timer A weer aan
                  move  #$2300,sr       ;MFP interrupts weer aan
no_new_sam:       addq.l #4,a1          ;schuif pointer in pattern regel op
                  rts                   ;einde

                OPT O-

intnorm:          move.b #8,$ffff8800.w ;PSG register 8 = volume kanaal A
ss_start:         move.b ss_start,$ffff8802.w ;       zet volume
                  bmi.s nextsam         ;if volume<0 -> sample finished -> clear interrupt
                  addq.w #1,ss_start+4
                  rte                   ;return from exception

                OPT O+

nextsam:          clr.b $ffff8802.w     ;zet volume op 0
                  move.b #%1,adata+silent ;er wordt geen sample gespeeld maar wees toch stil
                  bclr  #5,$fffffa07.w  ;zet timer A uit
                  rte                   ;return from exception

load_pos:         clr.w pat_lin         ;zet regelnummer op 0
load_pos_without_0:
                  move.w pos_now,d0     ;haal position
                  addq.w #1,d0          ;naar volgende position
                  cmp.w last_pos(pc),d0 ;zijn we voorbij de laatste position
                  bls.s no_restart      ;nee -> niet restarten
                  move.w restart(pc),d0 ;haal restart position
no_restart:       move.w d0,pos_now     ;sla position op
calc_pos:         lea   pos_tab(pc),a0  ;haal adres position tabel
                  move.w pos_now,d0     ;haal position nummer
                  move.b 0(a0,d0.w),d0  ;haal huidige pattern nummer (voor als we net aankomen met calc_pos)
                  andi.w #$7f,d0        ;maak er een word van
                  move.w d0,pat_now     ;sla op
                  lea   pat_tab,a0      ;haal tabel met patterns
                  add.w d0,d0
                  add.w d0,d0           ;vermenigvuldig met 4 voor tabel met longs
                  move.l 0(a0,d0.w),pat_base ;haal pointer naar pattern
                  rts

calc_sam_ptrs:    lea   sam_tab,a0      ;haal adres tabel met pointers
                  lea   sam_len,a1      ;haal adres tabel met lengtes
                  lea   sam_first(pc),a2 ;haal begin adres eerste sample
                  moveq #15,d0          ;pointers van 16 samples berekenen
                  moveq #0,d1           ;lengte alle samples samen is eerst 0
calc_next_sam:    move.l a2,(a0)+       ;sla pointer naar sample op
                  adda.l (a1),a2        ;verhoog pointer met lengte sample
                  add.l (a1)+,d1        ;verhoog totale lengte met lengte sample
                  dbra  d0,calc_next_sam
                  move.l d1,sam_tot     ;sla totale lengte samples op
                  rts
sparp_1:        DC.W 0
sparp_2:        DC.W 0

current_noise_a:DC.L 0
current_noise_b:DC.L 0
current_noise_c:DC.L 0

noise_ptrs:     DC.L prenoise_tab0,prenoise_tab1,prenoise_tab2,prenoise_tab3
                DC.L prenoise_tab4,prenoise_tab5,prenoise_tab6,prenoise_tab7

prenoise_tab0:  DC.B $1a,-1
prenoise_tab1:  DC.B $10,-2,-2,$1c,$1d,$20,3,12,10,$12,$26,$2c,-1
prenoise_tab2:  DC.B 8,-1
prenoise_tab3:  DC.B 7,-1
prenoise_tab4:  DC.B 6,-1
prenoise_tab5:  DC.B 5,-1
prenoise_tab6:  DC.B 4,-1
prenoise_tab7:  DC.B 3,-1

vols:           DC.B 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                DC.B 0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1
                DC.B 0,0,0,0,1,1,1,1,1,1,1,1,2,2,2,2
                DC.B 0,0,0,1,1,1,1,1,2,2,2,2,2,3,3,3
                DC.B 0,0,1,1,1,1,2,2,2,2,3,3,3,3,4,4
                DC.B 0,0,1,1,1,2,2,2,3,3,3,4,4,4,5,5
                DC.B 0,0,1,1,2,2,2,3,3,4,4,4,5,5,6,6
                DC.B 0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7
                DC.B 0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8
                DC.B 0,1,1,2,2,3,4,4,5,5,6,7,7,8,8,9
                DC.B 0,1,1,2,3,3,4,5,5,6,7,7,8,8,9,10
                DC.B 0,1,1,2,3,4,4,5,6,7,7,8,9,10,10,11
                DC.B 0,1,2,2,3,4,5,6,6,7,8,9,10,10,11,12
                DC.B 0,1,2,3,3,4,5,6,7,8,9,10,10,11,12,13
                DC.B 0,1,2,3,4,5,6,7,7,8,9,10,11,12,13,14
                DC.B 0,1,2,3,4,5,6,7,8,9,$0a,$0b,$0c,$0d,$0e,$0f
                EVEN

note_2_freq:    DS.W 1          ;lege ruimte want als noot=0 -> geen verandering
                DC.W 3822,3607,3405,3214,3033,2863
                DC.W 2702,2551,2407,2272,2145,2024
                DC.W 1991,1804,1703,1607,1517,1432
                DC.W 1351,1276,1204,1136,1073,1012

hertz:          DC.B 110,110,110,110
                DC.B 110,110,94,82
                DC.B 73,66,60,55
                DC.B 51,47,44,41

trem_tab:       DC.W 0,428,852,1266,1666,2048,2408,2741,3044,3314
                DC.W 3547,3742,3896,4006,4074,4096,4074,4006,3896,3742
                DC.W 3547,3314,3044,2741,2408,2048,1666,1266,852,428
                DC.W 0,-428,-852,-1266,-1666,-2048,-2408,-2741,-3044,-3314
                DC.W -3547,-3742,-3896,-4006,-4074,-4096,-4074,-4006,-3896,-3742
                DC.W -3547,-3314,-3044,-2741,-2408,-2048,-1666,-1266,-852,-428

voice_set:      INCBIN ANALOG2.TVS
evs:            EVEN

ym_names        EQU voice_set+4 ;ym sound namen
ym_sounds       EQU ym_names+64*8 ;reserveer ruimte voor ym sounds
sam_names       EQU ym_sounds+64*i_total_len ;sample namen
sam_len         EQU sam_names+16*8 ;sample lengtes (laaste 16 zijn loze lengtes)
sam_rates       EQU sam_len+32*4 ;sample rates
sam_first       EQU sam_rates+16
sam_last        EQU evs

song:           INCBIN NONAME.TRI
                EVEN

speed           EQU song+4      ;snelheid
restart         EQU speed+2     ;restart position
last_pos        EQU restart+2   ;aantal positions (max. 120)
last_pat        EQU last_pos+2  ;aantal patterns
pos_tab         EQU last_pat+2  ;positions
patterns        EQU pos_tab+120
pat_last        EQU patterns+max_pat*64*12 ;de patterns

bdata:
psgfreq         EQU *-bdata
                DS.W 1          ;frequentie die uiteindelijk in PSG moet
g_freq          EQU *-bdata
                DS.W 1          ;globale (noot-) frequentie (waarom long? -upper word gaat naar PSG, lower word is achter de komma)
p_freq          EQU *-bdata
                DS.W 1          ;huidige frequentie zonder tremolo(bij TIE belangrijk)
tie_stp         EQU *-bdata
                DS.W 1          ;stap van tie
trem_offs       EQU *-bdata
                DS.W 1          ;offset in tremolo tabel
vibr_speed      EQU *-bdata
                DS.W 1          ;snelheid van tremolo
vibr_depth      EQU *-bdata
                DS.W 1          ;diepte van tremolo
psgvol          EQU *-bdata
                DS.B 1          ;volume dat uiteindelijk in PSG moet
g_vol           EQU *-bdata
                DS.B 1          ;globaal volume
                EVEN
env_ptr         EQU *-bdata
                DS.L 1          ;pointer naar envelope tabel
env_offs        EQU *-bdata
                DS.W 1          ;offset in die tabel
env_att         EQU *-bdata
                DS.W 1          ;offset einde attack
env_sus         EQU *-bdata
                DS.W 1          ;offset einde sustain
env_rel         EQU *-bdata
                DS.W 1          ;offset einde release
                EVEN
pit_ptr         EQU *-bdata
                DS.L 1          ;pointer naar pitch envelope tabel
pit_offs        EQU *-bdata
                DS.W 1          ;offset in pitch envelope tabel
pit_att         EQU *-bdata
                DS.W 1          ;offset einde pitch attack
pit_sus         EQU *-bdata
                DS.W 1          ;offset einde pitch sustain
pit_rel         EQU *-bdata
                DS.W 1          ;offset einde pitch release
pit_mode        EQU *-bdata
                DS.B 1          ;<>0 : pitch staat aan
                EVEN
noise_freq      EQU *-bdata
                DS.W 1          ;frequentie ruis voor PSG
sound_mode      EQU *-bdata
                DS.B 1          ;masker voor reg #7
h_env_type      EQU *-bdata
                DS.B 1          ;type hardware envelope
                EVEN
h_env_freq      EQU *-bdata
                DS.W 1          ;frequentie hardware envelope
interval1       EQU *-bdata
                DS.W 1          ;interval #1 in aantal noten
interval2       EQU *-bdata
                DS.W 1          ;interval #2 in aantal noten
int_freq1       EQU *-bdata
                DS.W 1          ;interval #1 in relatieve frequency
int_freq2       EQU *-bdata
                DS.W 1          ;interval #2 in relatieve frequency
int_now         EQU *-bdata
                DS.B 1          ;welke interval zijn we? (0=normaal, 1=interval #1, 2=interval #2)
instr_no        EQU *-bdata     ;nummer huidige instrument (om te vergelijken)
                DS.B 1
silent          EQU *-bdata     ;als byte<>0 moeten we sil zijn
                DS.B 1
v_s_s_len       EQU *-bdata     ;lengte hele tabel om zo in 1 keer voice status structure voor channel C te definieren
                EVEN
cdata:          DS.B v_s_s_len  ;zelfde tabel als boven voor kanaal C
                EVEN
adata:          DS.B v_s_s_len  ;en nog een keer voor kanaal A
                EVEN


note_count:     DS.W 1          ;voordeler voor noot-snelheid (ALTIJD beginnen met 1)
pos_now:        DS.W 1          ;huidige POSITION
pat_now:        DS.W 1          ;huidige PATTERN
pat_tab:        DS.L 120        ;tabel met pointers naar patterns
pat_base:       DS.L 1          ;pointer naar BEGIN huidige pattern
pat_lin:        DS.W 1          ;pattern regel
pat_ptr:        DS.L 1          ;pointer naar huidige plaats in patter(=pat_base+14*
env_0:          DS.B 10         ;10 lege bytes als valse envelope
sam_tab:        DS.L 32         ;pointers naar samples (laatste 16 zijn loze pointers)
sam_tot:        DS.L 1          ;totale lengte samples
