
level_files
		dc.w	2-1			; anzahl episoden
		dc.l	lf_episode_0
		dc.l	lf_episode_1

lf_episode_0
		dc.w	5-1			; anzahl level der episode
		dc.l	lfe0_level_0
		dc.l	lfe0_level_1
		dc.l	lfe0_level_2
		dc.l	lfe0_level_3
		dc.l	lfe0_level_4

lf_episode_1
		dc.w	2-1			; anzahl level der episode
		dc.l	lfe1_level_0
		dc.l	lfe1_level_1

		ifeq	disk
lfe0_level_0	dc.b	"data\outlying.rld",0
lfe0_level_1	dc.b	"data\outlying.rld",0
lfe0_level_2	dc.b	"data\outlying.rld",0
lfe0_level_3	dc.b	"data\outlying.rld",0
lfe0_level_4	dc.b	"data\outlying.rld",0
		else
lfe0_level_0	dc.b	"a:\kanal.rld",0
lfe0_level_1	dc.b	"a:\kanal.rld",0
lfe0_level_2	dc.b	"a:\kanal.rld",0
lfe0_level_3	dc.b	"a:\kanal.rld",0
lfe0_level_4	dc.b	"a:\kanal.rld",0
		endc

lfe1_level_0	dc.b	"data\e1l0.rld",0
lfe1_level_1	dc.b	"data\e1l1.rld",0
		
		even
