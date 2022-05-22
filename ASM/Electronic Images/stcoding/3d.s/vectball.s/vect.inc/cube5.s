; Cube

Cube5		DC.L 0
		DC.W 64
i		SET -400
		REPT 4
		DC.W -200,i,0
		DC.W  000,i,0
		DC.W +200,i,0
		DC.W +400,i,0

		DC.W -200,i,200
		DC.W  000,i,200
		DC.W +200,i,200
		DC.W +400,i,200

		DC.W -200,i,400
		DC.W  000,i,400
		DC.W +200,i,400
		DC.W +400,i,400

		DC.W -200,i,600
		DC.W  000,i,600
		DC.W +200,i,600
		DC.W +400,i,600
i		SET i+200
		ENDR
		DC.W 64
i		SET 0
		REPT 16
		DC.W BALLOBJ,i*6,01*64
		DC.W BALLOBJ,(i+1)*6,01*64
		DC.W BALLOBJ,(i+2)*6,01*64
		DC.W BALLOBJ,(i+3)*6,01*64
i		SET i+4
		ENDR
		DC.W 0
