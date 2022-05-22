; Wavey grid thingy 1

WaveyGrid1Calc	lea Waveygrid1crds(pc),a0
		lea trig_tab(pc),a1
		lea fuckpntlist(pc),a2 
		movem.w waveptr1(pc),d3-d5
		add #40,d3
		add #24,d4
		add #30,d5
		movem.w d3-d5,waveptr1
		move.w #$7fe,d6
		moveq #49-1,d7
.lp		movem.w (a2)+,d0-d1
		exg d0,d1
		and.w d6,d3
		and.w d6,d4
		and.w d6,d5
		move #400,d2
		muls (a1,d3),d2
		add.l d2,d2
		swap d2
		add.w d0,d2
		move.w d2,(a0)+
		move #400,d2
		muls (a1,d4),d2
		add.l d2,d2
		swap d2
		add.w d1,d2
		move.w d2,(a0)+
		move d1,d2
		muls (a1,d5),d2
		add.l d2,d2
		swap d2
		move.w d2,(a0)+
		add.w #16,d3
		add.w #14,d4
		add.w #18,d5
		dbf d7,.lp
		rts

WaveyGrid	DC.L WaveyGrid1Calc
		DC.W 49
Waveygrid1crds	DS.W 49*3
		DC.W 49
i		SET 0
		REPT 49
		DC.W BALLOBJ,i,03*64
i		SET i+6
		ENDR		
		DC.W 84
		DC.W LINEOBJ,00*6,07*6
		DC.W LINEOBJ,01*6,08*6
		DC.W LINEOBJ,02*6,09*6
		DC.W LINEOBJ,03*6,10*6
		DC.W LINEOBJ,04*6,11*6
		DC.W LINEOBJ,05*6,12*6
		DC.W LINEOBJ,06*6,13*6
		DC.W LINEOBJ,07*6,14*6
		DC.W LINEOBJ,08*6,15*6
		DC.W LINEOBJ,09*6,16*6
		DC.W LINEOBJ,10*6,17*6
		DC.W LINEOBJ,11*6,18*6
		DC.W LINEOBJ,12*6,19*6
		DC.W LINEOBJ,13*6,20*6
		DC.W LINEOBJ,14*6,21*6
		DC.W LINEOBJ,15*6,22*6
		DC.W LINEOBJ,16*6,23*6
		DC.W LINEOBJ,17*6,24*6
		DC.W LINEOBJ,18*6,25*6
		DC.W LINEOBJ,19*6,26*6
		DC.W LINEOBJ,20*6,27*6
		DC.W LINEOBJ,21*6,28*6
		DC.W LINEOBJ,22*6,29*6
		DC.W LINEOBJ,23*6,30*6
		DC.W LINEOBJ,24*6,31*6
		DC.W LINEOBJ,25*6,32*6
		DC.W LINEOBJ,26*6,33*6
		DC.W LINEOBJ,27*6,34*6
		DC.W LINEOBJ,28*6,35*6
		DC.W LINEOBJ,29*6,36*6
		DC.W LINEOBJ,30*6,37*6
		DC.W LINEOBJ,31*6,38*6
		DC.W LINEOBJ,32*6,39*6
		DC.W LINEOBJ,33*6,40*6
		DC.W LINEOBJ,34*6,41*6
		DC.W LINEOBJ,35*6,42*6
		DC.W LINEOBJ,36*6,43*6
		DC.W LINEOBJ,37*6,44*6
		DC.W LINEOBJ,38*6,45*6
		DC.W LINEOBJ,39*6,46*6
		DC.W LINEOBJ,40*6,47*6
		DC.W LINEOBJ,41*6,48*6
i		SET 0
		REPT 7
		DC.W LINEOBJ,(i+0)*6,(i+1)*6
		DC.W LINEOBJ,(i+1)*6,(i+2)*6
		DC.W LINEOBJ,(i+2)*6,(i+3)*6
		DC.W LINEOBJ,(i+3)*6,(i+4)*6
		DC.W LINEOBJ,(i+4)*6,(i+5)*6
		DC.W LINEOBJ,(i+5)*6,(i+6)*6
i		SET i+7
		ENDR

; Wavey grid thingy 2

WaveyGrid2Calc	lea Waveygrid2crds(pc),a0
		lea trig_tab(pc),a1
		lea fuckpntlist(pc),a2 
		movem.w waveptr1(pc),d3-d5
		add #40,d3
		add #24,d4
		add #30,d5
		movem.w d3-d5,waveptr1
		move.w #$7fe,d6
		moveq #49-1,d7
.lp		movem.w (a2)+,d0-d1
		and.w d6,d5
		move.w d0,(a0)+
		move.w d1,(a0)+
		move d0,d2
		muls (a1,d5),d2
		add.l d2,d2
		swap d2
		move.w d2,(a0)+
		add.w #16,d5
		dbf d7,.lp
		rts

WaveyGrid2	DC.L WaveyGrid2Calc
		DC.W 49
Waveygrid2crds	DS.W 49*3
		DC.W 49
i		SET 0
		REPT 49
		DC.W BALLOBJ,i,03*64
i		SET i+6
		ENDR		
		DC.W 84
		DC.W LINEOBJ,00*6,07*6
		DC.W LINEOBJ,01*6,08*6
		DC.W LINEOBJ,02*6,09*6
		DC.W LINEOBJ,03*6,10*6
		DC.W LINEOBJ,04*6,11*6
		DC.W LINEOBJ,05*6,12*6
		DC.W LINEOBJ,06*6,13*6
		DC.W LINEOBJ,07*6,14*6
		DC.W LINEOBJ,08*6,15*6
		DC.W LINEOBJ,09*6,16*6
		DC.W LINEOBJ,10*6,17*6
		DC.W LINEOBJ,11*6,18*6
		DC.W LINEOBJ,12*6,19*6
		DC.W LINEOBJ,13*6,20*6
		DC.W LINEOBJ,14*6,21*6
		DC.W LINEOBJ,15*6,22*6
		DC.W LINEOBJ,16*6,23*6
		DC.W LINEOBJ,17*6,24*6
		DC.W LINEOBJ,18*6,25*6
		DC.W LINEOBJ,19*6,26*6
		DC.W LINEOBJ,20*6,27*6
		DC.W LINEOBJ,21*6,28*6
		DC.W LINEOBJ,22*6,29*6
		DC.W LINEOBJ,23*6,30*6
		DC.W LINEOBJ,24*6,31*6
		DC.W LINEOBJ,25*6,32*6
		DC.W LINEOBJ,26*6,33*6
		DC.W LINEOBJ,27*6,34*6
		DC.W LINEOBJ,28*6,35*6
		DC.W LINEOBJ,29*6,36*6
		DC.W LINEOBJ,30*6,37*6
		DC.W LINEOBJ,31*6,38*6
		DC.W LINEOBJ,32*6,39*6
		DC.W LINEOBJ,33*6,40*6
		DC.W LINEOBJ,34*6,41*6
		DC.W LINEOBJ,35*6,42*6
		DC.W LINEOBJ,36*6,43*6
		DC.W LINEOBJ,37*6,44*6
		DC.W LINEOBJ,38*6,45*6
		DC.W LINEOBJ,39*6,46*6
		DC.W LINEOBJ,40*6,47*6
		DC.W LINEOBJ,41*6,48*6
i		SET 0
		REPT 7
		DC.W LINEOBJ,(i+0)*6,(i+1)*6
		DC.W LINEOBJ,(i+1)*6,(i+2)*6
		DC.W LINEOBJ,(i+2)*6,(i+3)*6
		DC.W LINEOBJ,(i+3)*6,(i+4)*6
		DC.W LINEOBJ,(i+4)*6,(i+5)*6
		DC.W LINEOBJ,(i+5)*6,(i+6)*6
i		SET i+7
		ENDR


i		SET -600
fuckpntlist	
		REPT 7
		DC.W -600,i
		DC.W -400,i
		DC.W -200,i
		DC.W  000,i
		DC.W +200,i
		DC.W +400,i
		DC.W +600,i
i		SET i+200
		ENDR

