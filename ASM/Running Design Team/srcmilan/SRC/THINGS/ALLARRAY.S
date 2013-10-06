


		data


; ---------------------------------------------------------
; 23.07.00/vk
; definition aller gegenstande (konstanten siehe const.s).
; zeitlimitdauer:
;  0 = 650 sek
;  1 = 327 sek
;  2 = 163 sek
;  3 =  82 sek
;  4 =  41 sek
;  5 =  20 sek
things		dc.l	thing000
		dc.l	thing001
		dc.l	thing002
		dc.l	thing003
		dc.l	thing004
		dc.l	thing005
		dc.l	thing006
		dc.l	thing007
		dc.l	thing008
		dc.l	thing009
		dc.l	thing010
		dc.l	thing011
		dc.l	thing012
		dc.l	thing013
		dc.l	thing014
		dc.l	thing015
		dc.l	thing016
		dc.l	thing017
		dc.l	thing018
		dc.l	thing019
		dc.l	thing020
		dc.l	thing021
		dc.l	thing022
		dc.l	thing023
		dc.l	thing024
		dc.l	thing025
		dc.l	thing026
		dc.l	thing027
		dc.l	thing028
		dc.l	thing029
		dc.l	thing030
		dc.l	thing031
		dc.l	thing032
		dc.l	thing033
		dc.l	thing034
		dc.l	thing035
		dc.l	thing036
		dc.l	thing037
		dc.l	thing038
		dc.l	thing039
		dc.l	thing040
		dc.l	thing041
		dc.l	thing042
		dc.l	thing043
		dc.l	thing044
		dc.l	thing045
		dc.l	thing046
		dc.l	thing047
		dc.l	thing048
		dc.l	thing049
		dc.l	thing050
		dc.l	thing051
		dc.l	thing052
		dc.l	thing053
		dc.l	thing054
		dc.l	thing055
		dc.l	thing056
		dc.l	thing057
		dc.l	thing058
		dc.l	thing059
		dc.l	thing060
		dc.l	thing061
		dc.l	thing062
		dc.l	thing063
		dc.l	thing064
		dc.l	thing065
		dc.l	thing066
		dc.l	thing067
		dc.l	thing068
		dc.l	thing069
		dc.l	thing070
		dc.l	thing071
		dc.l	thing072
		dc.l	thing073
		dc.l	thing074
		dc.l	thing075
		dc.l	thing076
		dc.l	thing077
		dc.l	thing078
		dc.l	thing079
		dc.l	thing080
		dc.l	thing081
		dc.l	thing082
		dc.l	thing083
		dc.l	thing084
		dc.l	thing085
		dc.l	thing086
		dc.l	thing087
		dc.l	thing088
		dc.l	thing089
		dc.l	thing090
		dc.l	thing091
		dc.l	thing092
		dc.l	thing093
		dc.l	thing094
		dc.l	thing095
		dc.l	thing096
		dc.l	thing097
		dc.l	thing098
		dc.l	thing099
		dc.l	thing100
		dc.l	thing101



thing000	; TSTATIC
		dc.l	0
		dc.l	0,0,0,0
		dc.l	0,0
		dc.w	-1,SNDITEM,-1,0
		dc.w	0
thing001	; TREDKEY
		dc.l	thingsRout001
		dc.l	0,0,0,0				
		dc.l	thingsTxt001,thingsNeedTxt001
		dc.w	0,SNDITEM,-1,0
		dc.w	0
thing002	; TGREENKEY
		dc.l	thingsRout002
		dc.l	0,0,0,0
		dc.l	thingsTxt002,thingsNeedTxt002
		dc.w	1,SNDITEM,-1,0
		dc.w	0
thing003	; TBLUEKEY
		dc.l	thingsRout003
		dc.l	0,0,0,0
		dc.l	thingsTxt003,thingsNeedTxt003
		dc.w	2,SNDITEM,-1,0
		dc.w	0
thing004	; TYELLOWKEY
		dc.l	thingsRout004
		dc.l	0,0,0,0
		dc.l	thingsTxt004,thingsNeedTxt004
		dc.w	3,SNDITEM,-1,0
		dc.w	0
thing005	; TAMMO1
		dc.l	thingsRout005
		dc.l	0,0,0,0
		dc.l	thingsTxt005,0
		dc.w	-1,SNDITEM,-1,0
		dc.w	0
thing006	; TAMMO2
		dc.l	thingsRout006
		dc.l	0,0,0,0
		dc.l	thingsTxt006,0
		dc.w	-1,SNDITEM,-1,0
		dc.w	0
thing007	; TAMMO3
		dc.l	thingsRout007
		dc.l	0,0,0,0
		dc.l	thingsTxt007,0
		dc.w	-1,SNDITEM,-1,0
		dc.w	0
thing008	; TAMMO4
		dc.l	thingsRout008
		dc.l	0,0,0,0
		dc.l	thingsTxt008,0
		dc.w	-1,SNDITEM,-1,0
		dc.w	0
thing009	; TSCANNER
		dc.l	thingsRout009
		dc.l	plActionRout009,plActionTxt009,plDeactionRout009,plDeactionTxt009
		dc.l	thingsTxt009,thingsNeedTxt009
		dc.w	4,SNDITEM,$7fff,0
		dc.w	0
thing010	; TNIGHT
		dc.l	thingsRout010
		dc.l	plActionRout010,plActionTxt010,plDeactionRout010,plDeactionTxt010
		dc.l	thingsTxt010,0
		dc.w	5,SNDITEM,-1,0
		dc.w	0
thing011	; TMASK
		dc.l	thingsRout011
		dc.l	plActionRout011,plActionTxt011,plDeactionRout011,plDeactionTxt011
		dc.l	thingsTxt011,thingsNeedTxt011
		dc.w	6,SNDITEM,-1,0
		dc.w	0
thing012	; TSMEDKITI
		dc.l	thingsRout012
		dc.l	plActionRout012,plActionTxt012,0,0
		dc.l	thingsTxt012,0
		dc.w	7,SNDITEM,-1,0
		dc.w	0
thing013	; TBMEDKITI
		dc.l	thingsRout013
		dc.l	plActionRout013,plActionTxt013,0,0
		dc.l	thingsTxt013,0
		dc.w	8,SNDITEM,-1,0
		dc.w	0
thing014	; TSMEDKIT
		dc.l	thingsRout014
		dc.l	0,0,0,0
		dc.l	thingsTxt014,0
		dc.w	-1,SNDLIKE,-1,0
		dc.w	0
thing015	; TBMEDKIT
		dc.l	thingsRout015
		dc.l	0,0,0,0
		dc.l	thingsTxt015,0
		dc.w	-1,SNDDOPE,-1,0
		dc.w	0
thing016	; TSARMOR
		dc.l	thingsRout016
		dc.l	0,0,0,0
		dc.l	thingsTxt016,0
		dc.w	-1,SNDGOOD,-1,0
		dc.w	0
thing017	; TBARMOR
		dc.l	thingsRout017
		dc.l	0,0,0,0
		dc.l	thingsTxt017,0
		dc.w	-1,SNDLIKE,-1,0
		dc.w	0
thing018	; TINVUL
		dc.l	thingsRout018
		dc.l	plActionRout018,plActionTxt018,plDeactionRout018,plDeactionTxt018
		dc.l	thingsTxt018,0
		dc.w	9,SNDITEM,$7fff,4
		dc.w	0
thing019	; TINVIS
		dc.l	thingsRout019
		dc.l	plActionRout019,plActionTxt019,plDeactionRout019,plDeactionTxt019
		dc.l	thingsTxt019,0
		dc.w	10,SNDITEM,$7fff,4
		dc.w	0
thing020	; TPISTOL1
		dc.l	thingsRout020
		dc.l	0,0,0,0
		dc.l	thingsTxt020,0
		dc.w	-1,SNDDONT,-1,0
		dc.w	0
thing021	; TPISTOL2
		dc.l	thingsRout021
		dc.l	0,0,0,0
		dc.l	thingsTxt021,0
		dc.w	-1,SNDCHECK,-1,0
		dc.w	0
thing022	; TPISTOL3
		dc.l	thingsRout022
		dc.l	0,0,0,0
		dc.l	thingsTxt022,0
		dc.w	-1,SNDNICE,-1,0
		dc.w	0
thing023	; TPISTOL4
		dc.l	thingsRout023
		dc.l	0,0,0,0
		dc.l	thingsTxt023,0
		dc.w	-1,SNDDONT,-1,0
		dc.w	0
thing024	; TRADSUIT
		dc.l	thingsRout024
		dc.l	plActionRout024,plActionTxt024,plDeactionRout024,plDeactionTxt024
		dc.l	thingsTxt024,thingsNeedTxt024
		dc.w	11,SNDITEM,$7fff,1
		dc.w	0
thing025	; TGEIGERCOUNTER
		dc.l	thingsRout025
		dc.l	plActionRout025,plActionTxt025,plDeactionRout025,plDeactionTxt025
		dc.l	thingsTxt025,thingsNeedTxt025
		dc.w	12,SNDITEM,$7fff,0
		dc.w	0
thing026	; TJETPACK
		dc.l	thingsRout026
		dc.l	plActionRout026,0,0,0
		dc.l	thingsTxt026,thingsNeedTxt026
		dc.w	13,SNDITEM,-1,0
		dc.w	0
thing027	; TBACKPACK
		dc.l	thingsRout027
		dc.l	0,0,0,0
		dc.l	thingsTxt027,0
		dc.w	-1,SNDITEM,-1,0
		dc.w	0
thing028	; TMONDETECTOR
		dc.l	thingsRout028
		dc.l	plActionRout028,plActionTxt028,plDeactionRout028,plDeactionTxt028
		dc.l	thingsTxt028,0
		dc.w	15,SNDITEM,-1,0
		dc.w	0
thing029	; TPLAN
		dc.l	thingsRout029
		dc.l	plActionRout029,plActionTxt029,plDeactionRout029,plDeactionTxt029
		dc.l	thingsTxt029,0
		dc.w	18,SNDITEM,-1,0
		dc.w	0
thing030	; TAMMO0DEF
		dc.l	thingsRout030
		dc.l	0,0,0,0
		dc.l	thingsTxt030,0
		dc.w	-1,SNDITEM,-1,0
		dc.w	0
thing031	; TAMMO1DEF
		dc.l	thingsRout031
		dc.l	0,0,0,0
		dc.l	thingsTxt031,0
		dc.w	-1,SNDITEM,-1,0
		dc.w	0
thing032	; TAMMO2DEF
		dc.l	thingsRout032
		dc.l	0,0,0,0
		dc.l	thingsTxt032,0
		dc.w	-1,SNDITEM,-1,0
		dc.w	0
thing033	; TAMMO3DEF
		dc.l	thingsRout033
		dc.l	0,0,0,0
		dc.l	thingsTxt033,0
		dc.w	-1,SNDITEM,-1,0
		dc.w	0
thing034	; TOPENDOOR
		dc.l	thingsRout034
		dc.l	0,0,0,0
		dc.l	0,0
		dc.w	-1,SNDITEM,-1,0
		dc.w	0
thing035	; TOPENLIFT
		dc.l	thingsRout035
		dc.l	0,0,0,0
		dc.l	0,0
		dc.w	-1,SNDITEM,-1,0
		dc.w	0
thing036	; TCLOSEDOOR
		dc.l	thingsRout036
		dc.l	0,0,0,0
		dc.l	0,0
		dc.w	-1,SNDITEM,-1,0
		dc.w	0
thing037	; TCLOSELIFT
		dc.l	thingsRout037
		dc.l	0,0,0,0
		dc.l	0,0
		dc.w	-1,SNDITEM,-1,0
		dc.w	0
thing038	; TTELEPORTER
		dc.l	thingsRout038
		dc.l	0,0,0,0
		dc.l	0,0
		dc.w	-1,SNDITEM,-1,0
		dc.w	0
thing039	; TCAMERAVIEW
		dc.l	thingsRout039
		dc.l	0,0,0,0
		dc.l	0,0
		dc.w	-1,-1,-1,0
		dc.w	0
thing040	; TTERMINAL
		dc.l	thingsRout040
		dc.l	0,0,0,0
		dc.l	0,0
		dc.w	-1,SNDITEM,-1,0
		dc.w	0
thing041	; TWELDER
		dc.l	thingsRout041
		dc.l	0,0,0,0
		dc.l	thingsTxt041,thingsNeedTxt041
		dc.w	16,SNDITEM,-1,0
		dc.w	0
thing042	; TTIMEDEACT
		dc.l	thingsRout042
		dc.l	0,0,0,0
		dc.l	thingsTxt042,0
		dc.w	-1,SNDITEM,-1,0
		dc.w	0
thing043	; TGIFT
		dc.l	thingsRout043
		dc.l	plActionRout043,plActionTxt043,0,0
		dc.l	thingsTxt043,thingsNeedTxt043
		dc.w	17,SNDITEM,-1,0
		dc.w	0
thing044	; TLEVELEND
		dc.l	thingsRout044
		dc.l	0,0,0,0
		dc.l	0,0
		dc.w	-1,SNDITEM,-1,0
		dc.w	0
thing045	; TSAMPLE
		dc.l	thingsRout045
		dc.l	0,0,0,0
		dc.l	0,0
		dc.w	-1,-1,-1,0
		dc.w	0
thing046	; TSMALLPLAN
		dc.l	thingsRout046
		dc.l	plActionRout046,plActionTxt046,plDeactionRout046,plDeactionTxt046
		dc.l	thingsTxt046,0
		dc.w	14,SNDITEM,-1,0
		dc.w	0
thing047	; TNEVERGET
		dc.l	thingsRout047
		dc.l	0,0,0,0
		dc.l	0,0
		dc.w	-1,-1,-1,0
		dc.w	0
thing048	; TSFTOZERO
		dc.l	thingsRout048
		dc.l	0,0,0,0
		dc.l	0,0
		dc.w	-1,-1,-1,0
		dc.w	0
thing049	; TCHANGEVIS
		dc.l	thingsRout049
		dc.l	0,0,0,0
		dc.l	0,0
		dc.w	-1,-1,-1,0
		dc.w	0
thing050	; TLASERDEACT
		dc.l	thingsRout050
		dc.l	0,0,0,0
		dc.l	0,0
		dc.w	-1,SNDITEM,-1,0
		dc.w	0
thing051	; TMESSAGE
		dc.l	thingsRout051
		dc.l	0,0,0,0
		dc.l	0,0
		dc.w	-1,SNDITEM,-1,0
		dc.w	0
thing052	; TSPRENGSTOFF
		dc.l	thingsRout052
		dc.l	0,0,0,0
		dc.l	thingsTxt052,thingsNeedTxt052
		dc.w	19,SNDITEM,-1,0
		dc.w	0
thing053	; TZUENDER
		dc.l	thingsRout053
		dc.l	0,0,0,0
		dc.l	thingsTxt053,thingsNeedTxt053
		dc.w	20,SNDITEM,-1,0
		dc.w	0
thing054	; TPRIMARY
		dc.l	thingsRout054
		dc.l	0,0,0,0
		dc.l	thingsTxt054,thingsNeedTxt054
		dc.w	-1,SNDITEM,-1,0
		dc.w	0
thing055	; TSECONDARY
		dc.l	thingsRout055
		dc.l	0,0,0,0
		dc.l	thingsTxt055,thingsNeedTxt055
		dc.w	-1,SNDITEM,-1,0
		dc.w	0
thing056	; TGENINVUL
		dc.l	thingsRout056
		dc.l	plActionRout056,plActionTxt056,plDeactionRout056,plDeactionTxt056
		dc.l	thingsTxt056,0
		dc.w	21,SNDITEM,-1,0
		dc.w	0
thing057	; TGENINVIS
		dc.l	thingsRout057
		dc.l	plActionRout057,plActionTxt057,plDeactionRout057,plDeactionTxt057
		dc.l	thingsTxt057,0
		dc.w	22,SNDITEM,-1,0
		dc.w	0
thing058	; TCOLOR0
		dc.l	thingsRout058
		dc.l	0,0,0,0
		dc.l	0,0
		dc.w	-1,-1,-1,0
		dc.w	0
thing059	; TCOLOR1
		dc.l	thingsRout059
		dc.l	0,0,0,0
		dc.l	0,0
		dc.w	-1,-1,-1,0
		dc.w	0
thing060	; TCOLOR2
		dc.l	thingsRout060
		dc.l	0,0,0,0
		dc.l	0,0
		dc.w	-1,-1,-1,0
		dc.w	0
thing061	; TCOLOR3
		dc.l	thingsRout061
		dc.l	0,0,0,0
		dc.l	0,0
		dc.w	-1,-1,-1,0
		dc.w	0
thing062	; TCOLOR4
		dc.l	thingsRout062
		dc.l	0,0,0,0
		dc.l	0,0
		dc.w	-1,-1,-1,0
		dc.w	0
thing063	; TCOLOR5
		dc.l	thingsRout063
		dc.l	0,0,0,0
		dc.l	0,0
		dc.w	-1,-1,-1,0
		dc.w	0
thing064	; TCOLOR6
		dc.l	thingsRout064
		dc.l	0,0,0,0
		dc.l	0,0
		dc.w	-1,-1,-1,0
		dc.w	0
thing065	; TCOLOR7
		dc.l	thingsRout065
		dc.l	0,0,0,0
		dc.l	0,0
		dc.w	-1,-1,-1,0
		dc.w	0
thing066	; TCOLOR
		dc.l	thingsRout066
		dc.l	0,0,0,0
		dc.l	0,0
		dc.w	-1,-1,-1,0
		dc.w	0
thing067	; TBIERKRUG
		dc.l	thingsRout067
		dc.l	0,0,0,0
		dc.l	thingsTxt067,thingsNeedTxt067
		dc.w	23,SNDLIKE,-1,0
		dc.w	0
thing068	; TTRNDETECTOR
		dc.l	thingsRout068
		dc.l	plActionRout068,plActionTxt068,plDeactionRout068,plDeactionTxt068
		dc.l	thingsTxt068,thingsNeedTxt068
		dc.w	24,SNDITEM,-1,0
		dc.w	0
thing069	; TDCOLOR0
		dc.l	thingsRout069
		dc.l	0,0,0,0
		dc.l	0,0
		dc.w	-1,-1,-1,0
		dc.w	0
thing070	; TDCOLOR1
		dc.l	thingsRout070
		dc.l	0,0,0,0
		dc.l	0,0
		dc.w	-1,-1,-1,0
		dc.w	0
thing071	; TDCOLOR2
		dc.l	thingsRout071
		dc.l	0,0,0,0
		dc.l	0,0
		dc.w	-1,-1,-1,0
		dc.w	0
thing072	; TDCOLOR3
		dc.l	thingsRout072
		dc.l	0,0,0,0
		dc.l	0,0
		dc.w	-1,-1,-1,0
		dc.w	0
thing073	; TDCOLOR4
		dc.l	thingsRout073
		dc.l	0,0,0,0
		dc.l	0,0
		dc.w	-1,-1,-1,0
		dc.w	0
thing074	; TDCOLOR5
		dc.l	thingsRout074
		dc.l	0,0,0,0
		dc.l	0,0
		dc.w	-1,-1,-1,0
		dc.w	0
thing075	; TDCOLOR6
		dc.l	thingsRout075
		dc.l	0,0,0,0
		dc.l	0,0
		dc.w	-1,-1,-1,0
		dc.w	0
thing076	; TDCOLOR7
		dc.l	thingsRout076
		dc.l	0,0,0,0
		dc.l	0,0
		dc.w	-1,-1,-1,0
		dc.w	0
thing077	; TDCOLOR
		dc.l	thingsRout077
		dc.l	0,0,0,0
		dc.l	0,0
		dc.w	-1,-1,-1,0
		dc.w	0
thing078	; TSECCHANGEVIS
		dc.l	thingsRout078
		dc.l	0,0,0,0
		dc.l	0,0
		dc.w	-1,SNDITEM,-1,0
		dc.w	0
thing079	; TBURGER
		dc.l	thingsRout079
		dc.l	0,0,0,0
		dc.l	0,0
		dc.w	-1,SNDITEM,-1,0
		dc.w	0
thing080	; TCONDOM
		dc.l	thingsRout080
		dc.l	0,0,0,0
		dc.l	thingsTxt080,thingsNeedTxt080
		dc.w	25,SNDITEM,-1,0
		dc.w	0
thing081	; TIDCARD
		dc.l	thingsRout081
		dc.l	0,0,0,0
		dc.l	thingsTxt081,thingsNeedTxt081
		dc.w	26,SNDITEM,-1,0
		dc.w	0
thing082	; TWHICHEND
		dc.l	thingsRout082
		dc.l	0,0,0,0
		dc.l	0,0
		dc.w	-1,-1,-1,0
		dc.w	0
thing083	; TAMMO0
		dc.l	thingsRout083
		dc.l	0,0,0,0
		dc.l	thingsTxt083,0
		dc.w	-1,SNDITEM,-1,0
		dc.w	0
thing084	; TAMMO5
		dc.l	thingsRout084
		dc.l	0,0,0,0
		dc.l	thingsTxt084,0
		dc.w	-1,SNDITEM,-1,0
		dc.w	0
thing085	; TAMMO6
		dc.l	thingsRout085
		dc.l	0,0,0,0
		dc.l	thingsTxt085,0
		dc.w	-1,SNDITEM,-1,0
		dc.w	0
thing086	; TAMMO7
		dc.l	thingsRout086
		dc.l	0,0,0,0
		dc.l	thingsTxt086,0
		dc.w	-1,SNDITEM,-1,0
		dc.w	0
thing087	; TAMMO8
		dc.l	thingsRout087
		dc.l	0,0,0,0
		dc.l	thingsTxt087,0
		dc.w	-1,SNDITEM,-1,0
		dc.w	0
thing088	; TAMMO9
		dc.l	thingsRout088
		dc.l	0,0,0,0
		dc.l	thingsTxt088,0
		dc.w	-1,SNDITEM,-1,0
		dc.w	0
thing089	; TAMMO0DEF
		dc.l	thingsRout089
		dc.l	0,0,0,0
		dc.l	thingsTxt089,0
		dc.w	-1,SNDITEM,-1,0
		dc.w	0
thing090	; TAMMO5DEF
		dc.l	thingsRout090
		dc.l	0,0,0,0
		dc.l	thingsTxt090,0
		dc.w	-1,SNDITEM,-1,0
		dc.w	0
thing091	; TAMMO6DEF
		dc.l	thingsRout091
		dc.l	0,0,0,0
		dc.l	thingsTxt091,0
		dc.w	-1,SNDITEM,-1,0
		dc.w	0
thing092	; TAMMO7DEF
		dc.l	thingsRout092
		dc.l	0,0,0,0
		dc.l	thingsTxt092,0
		dc.w	-1,SNDITEM,-1,0
		dc.w	0
thing093	; TAMMO8DEF
		dc.l	thingsRout093
		dc.l	0,0,0,0
		dc.l	thingsTxt093,0
		dc.w	-1,SNDITEM,-1,0
		dc.w	0
thing094	; TAMMO9DEF
		dc.l	thingsRout094
		dc.l	0,0,0,0
		dc.l	thingsTxt094,0
		dc.w	-1,SNDITEM,-1,0
		dc.w	0
thing095	; TPISTOL0
		dc.l	thingsRout095
		dc.l	0,0,0,0
		dc.l	thingsTxt095,0
		dc.w	-1,SNDDONT,-1,0
		dc.w	0
thing096	; TPISTOL5
		dc.l	thingsRout096
		dc.l	0,0,0,0
		dc.l	thingsTxt096,0
		dc.w	-1,SNDDONT,-1,0
		dc.w	0
thing097	; TPISTOL6
		dc.l	thingsRout097
		dc.l	0,0,0,0
		dc.l	thingsTxt097,0
		dc.w	-1,SNDDONT,-1,0
		dc.w	0
thing098	; TPISTOL7
		dc.l	thingsRout098
		dc.l	0,0,0,0
		dc.l	thingsTxt098,0
		dc.w	-1,SNDDONT,-1,0
		dc.w	0
thing099	; TPISTOL8
		dc.l	thingsRout099
		dc.l	0,0,0,0
		dc.l	thingsTxt099,0
		dc.w	-1,SNDDONT,-1,0
		dc.w	0
thing100	; TPISTOL9
		dc.l	thingsRout100
		dc.l	0,0,0,0
		dc.l	thingsTxt100,0
		dc.w	-1,SNDDONT,-1,0
		dc.w	0
thing101	; TREVOLVINGPLAN
		dc.l	thingsRout101
		dc.l	plActionRout101,plActionTxt101,plDeactionRout101,plDeactionTxt101
		dc.l	thingsTxt101,0
		dc.w	18,SNDITEM,-1,0
		dc.w	0


		IFEQ LANGUAGE
thingsNeedTxt001	dc.b	"YOU NEED THE RED KEY ...",0
thingsNeedTxt002	dc.b	"YOU NEED THE GREEN KEY ...",0
thingsNeedTxt003	dc.b	"YOU NEED THE BLUE KEY ...",0
thingsNeedTxt004	dc.b	"YOU NEED THE YELLOW KEY ...",0
thingsNeedTxt009	dc.b	"YOU NEED THE ULTRA-SCANNER",0
thingsNeedTxt011	dc.b	"YOU NEED THE GAS MASK ...",0
thingsNeedTxt024	dc.b	"YOU NEED THE RADIATION SUIT",0
thingsNeedTxt025	dc.b	"YOU NEED THE GEIGER COUNTER",0
thingsNeedTxt026	dc.b	"YOU NEED THE JETPACK ...",0
thingsNeedTxt041	dc.b	"YOU NEED THE WELDING TORCH ...",0
thingsNeedTxt043	dc.b	"YOU NEED THE TOXIC SUBSTANCE",0
thingsNeedTxt052	dc.b	"YOU NEED THE DYNAMITE ...",0
thingsNeedTxt053	dc.b	"YOU NEED THE DETONATOR ...",0
thingsNeedTxt054	dc.b	"PRIMARY MISSION NOT COMPLETED",0
thingsNeedTxt055	dc.b	"SECONDARY MISSION NOT COMPLETED",0
thingsNeedTxt067	dc.b	"YOU NEED THE BIER-MUG ...",0
thingsNeedTxt068	dc.b	"YOU NEED THE TRAIN DETECTOR ...",0
thingsNeedTxt080	dc.b	"YOU NEED A CONDOM ...",0
thingsNeedTxt081	dc.b	"YOU NEED THE ID-CARD ...",0
		ELSE
thingsNeedTxt001	dc.b	"ROTER SCHLšSSEL BEN™TIGT",0
thingsNeedTxt002	dc.b	"GRšNER SCHLšSSEL BEN™TIGT",0
thingsNeedTxt003	dc.b	"BLAUER SCHLšSSEL BEN™TIGT",0
thingsNeedTxt004	dc.b	"GELBER SCHLšSSEL BEN™TIGT",0
thingsNeedTxt009	dc.b	"ULTRA-SCANNER BEN™TIGT",0
thingsNeedTxt011	dc.b	"GASMASKE BEN™TIGT",0
thingsNeedTxt024	dc.b	"STRAHLENSCHUTZANZUG BEN™TIGT",0
thingsNeedTxt025	dc.b	"GEIGERZŽHLER BEN™TIGT",0
thingsNeedTxt026	dc.b	"DšSENANZUG BEN™TIGT",0
thingsNeedTxt041	dc.b	"SCHWEISSGERŽT BEN™TIGT",0
thingsNeedTxt043	dc.b	"GIFTIGE SUBSTANZ BEN™TIGT",0
thingsNeedTxt052	dc.b	"DYNAMIT BEN™TIGT",0
thingsNeedTxt053	dc.b	"ZšNDER FšR DYNAMIT BEN™TIGT",0
thingsNeedTxt054	dc.b	"PRIMŽRES MISSIONSZIEL NICHT ERFšLLT",0
thingsNeedTxt055	dc.b	"SEKUNDŽRES MISSIONSZIEL NICHT ERFšLLT",0
thingsNeedTxt067	dc.b	"BIERKRUG BEN™TIGT",0
thingsNeedTxt068	dc.b	"ZUG-ORTUNGSGERŽT BEN™TIGT",0
thingsNeedTxt080	dc.b	"KONDOM BEN™TIGT",0
thingsNeedTxt081	dc.b	"ID-KARTE BEN™TIGT",0
		ENDC
			even

		IFEQ LANGUAGE
thingsTxt001		dc.b	"RED KEY FOUND",0
thingsTxt002		dc.b	"GREEN KEY FOUND",0
thingsTxt003		dc.b	"BLUE KEY FOUND",0
thingsTxt004		dc.b	"YELLOW KEY FOUND",0
thingsTxt005		dc.b	"AMMO FOR $(XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX) FOUND",0
thingsTxt006		dc.b	"AMMO FOR $(XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX) FOUND",0
thingsTxt007		dc.b	"AMMO FOR $(XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX) FOUND",0
thingsTxt008		dc.b	"AMMO FOR $(XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX) FOUND",0
thingsTxt009		dc.b	"ULTRA-SCANNER FOUND",0
thingsTxt010		dc.b	"NIGHTVIEWER FOUND",0
thingsTxt011		dc.b	"GAS MASK FOUND",0
thingsTxt012		dc.b	"SMALL MEDIKIT FOUND",0
thingsTxt013		dc.b	"BIG MEDIKIT FOUND",0
thingsTxt014		dc.b	"SMALL MEDIKIT FOUND",0
thingsTxt015		dc.b	"BIG MEDIKIT FOUND",0
thingsTxt016		dc.b	"SMALL SHIELD BONUS",0
thingsTxt017		dc.b	"BIG SHIELD BONUS",0
thingsTxt018		dc.b	"INVULNERABILITY FOUND",0
thingsTxt019		dc.b	"INVISIBILITY FOUND",0
thingsTxt020		dc.b	"WEAPON $(XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX) FOUND",0
thingsTxt021		dc.b	"WEAPON $(XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX) FOUND",0
thingsTxt022		dc.b	"WEAPON $(XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX) FOUND",0
thingsTxt023		dc.b	"WEAPON $(XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX) FOUND",0
thingsTxt024		dc.b	"RADIATION SUIT FOUND",0
thingsTxt025		dc.b	"GEIGER COUNTER FOUND",0
thingsTxt026		dc.b	"JETPACK FOUND",0
thingsTxt027		dc.b	"BACKPACK FOUND",0
thingsTxt028		dc.b	"MONSTER DETECTOR FOUND",0
thingsTxt029		dc.b	"FULL PLAN FOUND",0
thingsTxt030		dc.b	"AMMO FOR $(XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX) FOUND",0
thingsTxt031		dc.b	"AMMO FOR $(XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX) FOUND",0
thingsTxt032		dc.b	"AMMO FOR $(XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX) FOUND",0
thingsTxt033		dc.b	"AMMO FOR $(XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX) FOUND",0
thingsTxt041		dc.b	"WELDING TORCH FOUND",0
thingsTxt042		dc.b	"TIME LIMIT DEACTIVATED",0
thingsTxt043		dc.b	"TOXIC SUBSTANCE FOUND",0
thingsTxt046		dc.b	"PLAN FOUND",0
thingsTxt052		dc.b	"DYNAMITE FOUND",0
thingsTxt053		dc.b	"DETONATOR FOR DYNAMITE FOUND",0
thingsTxt054		dc.b	"PRIMARY MISSION COMPLETED",0
thingsTxt055		dc.b	"SECONDARY MISSION COMPLETED",0
thingsTxt056		dc.b	"PERMANENT INVULNERABILITY FOUND",0
thingsTxt057		dc.b	"PERMANENT INVISIBILITY FOUND",0
thingsTxt067		dc.b	"BEER-MUG FOUND",0
thingsTxt068		dc.b	"TRAIN DETECTOR FOUND",0
thingsTxt080		dc.b	"CONDOM FOUND",0
thingsTxt081		dc.b	"ID-CARD FOUND",0
thingsTxt083		dc.b	"AMMO FOR $(XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX) FOUND",0
thingsTxt084		dc.b	"AMMO FOR $(XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX) FOUND",0
thingsTxt085		dc.b	"AMMO FOR $(XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX) FOUND",0
thingsTxt086		dc.b	"AMMO FOR $(XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX) FOUND",0
thingsTxt087		dc.b	"AMMO FOR $(XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX) FOUND",0
thingsTxt088		dc.b	"AMMO FOR $(XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX) FOUND",0
thingsTxt089		dc.b	"AMMO FOR $(XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX) FOUND",0
thingsTxt090		dc.b	"AMMO FOR $(XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX) FOUND",0
thingsTxt091		dc.b	"AMMO FOR $(XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX) FOUND",0
thingsTxt092		dc.b	"AMMO FOR $(XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX) FOUND",0
thingsTxt093		dc.b	"AMMO FOR $(XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX) FOUND",0
thingsTxt094		dc.b	"AMMO FOR $(XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX) FOUND",0
thingsTxt095		dc.b	"WEAPON $(XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX) FOUND",0
thingsTxt096		dc.b	"WEAPON $(XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX) FOUND",0
thingsTxt097		dc.b	"WEAPON $(XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX) FOUND",0
thingsTxt098		dc.b	"WEAPON $(XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX) FOUND",0
thingsTxt099		dc.b	"WEAPON $(XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX) FOUND",0
thingsTxt100		dc.b	"WEAPON $(XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX) FOUND",0
thingsTxt101		dc.b	"REVOLVING PLAN FOUND",0
		ELSE
thingsTxt001		dc.b	"ROTEN SCHLšSSEL GEFUNDEN",0
thingsTxt002		dc.b	"BLAUEN SCHLšSSEL GEFUNDEN",0
thingsTxt003		dc.b	"GRUENEN SCHLšSSEL GEFUNDEN",0
thingsTxt004		dc.b	"GELBEN SCHLšSSEL GEFUNDEN",0
thingsTxt005		dc.b	"MUNITION FšR $(XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX) GEFUNDEN",0
thingsTxt006		dc.b	"MUNITION FšR $(XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX) GEFUNDEN",0
thingsTxt007		dc.b	"MUNITION FšR $(XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX) GEFUNDEN",0
thingsTxt008		dc.b	"MUNITION FšR $(XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX) GEFUNDEN",0
thingsTxt009		dc.b	"ULTRA-SCANNER GEFUNDEN",0
thingsTxt010		dc.b	"NACHTSICHTGERŽT GEFUNDEN",0
thingsTxt011		dc.b	"GASMASKE GEFUNDEN",0
thingsTxt012		dc.b	"KLEINEN MEDIKIT GEFUNDEN",0
thingsTxt013		dc.b	"GROSSEN MEDIKIT GEFUNDEN",0
thingsTxt014		dc.b	"KLEINEN MEDIKIT GEFUNDEN",0
thingsTxt015		dc.b	"GROSSEN MEDIKIT GEFUNDEN",0
thingsTxt016		dc.b	"SMALL SHIELD BONUS",0
thingsTxt017		dc.b	"BIG SHIELD BONUS",0
thingsTxt018		dc.b	"UNVERWUNDBARKEIT GEFUNDEN",0
thingsTxt019		dc.b	"UNSICHTBARKEIT GEFUNDEN",0
thingsTxt020		dc.b	"WAFFE $(XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX) GEFUNDEN",0
thingsTxt021		dc.b	"WAFFE $(XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX) GEFUNDEN",0
thingsTxt022		dc.b	"WAFFE $(XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX) GEFUNDEN",0
thingsTxt023		dc.b	"WAFFE $(XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX) GEFUNDEN",0
thingsTxt024		dc.b	"STRAHLENSCHUTZANZUG GEFUNDEN",0
thingsTxt025		dc.b	"GEIGERZŽHLER GEFUNDEN",0
thingsTxt026		dc.b	"DšSENANZUG GEFUNDEN",0
thingsTxt027		dc.b	"RUCKSACK GEFUNDEN",0
thingsTxt028		dc.b	"GEGNERANZEIGE FšR KARTE GEFUNDEN",0
thingsTxt029		dc.b	"GESAMTKARTE GEFUNDEN",0
thingsTxt030		dc.b	"MUNITION FšR $(XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX) GEFUNDEN",0
thingsTxt031		dc.b	"MUNITION FšR $(XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX) GEFUNDEN",0
thingsTxt032		dc.b	"MUNITION FšR $(XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX) GEFUNDEN",0
thingsTxt033		dc.b	"MUNITION FšR $(XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX) GEFUNDEN",0
thingsTxt041		dc.b	"SCHWEISSGERŽT GEFUNDEN",0
thingsTxt042		dc.b	"ZEITLIMIT DEAKTIVIERT",0
thingsTxt043		dc.b	"GIFTIGE SUBSTANZ GEFUNDEN",0
thingsTxt046		dc.b	"KARTE GEFUNDEN",0
thingsTxt052		dc.b	"DYNAMIT GEFUNDEN",0
thingsTxt053		dc.b	"ZšNDER FšR DYNAMIT GEFUNDEN",0
thingsTxt054		dc.b	"PRIMŽRES MISSIONSZIEL ERFšLLT",0
thingsTxt055		dc.b	"SEKUNDŽRES MISSIONSZIEL ERFšLLT",0
thingsTxt056		dc.b	"PERMANENTE UNVERWUNDBARKEIT GEFUNDEN",0
thingsTxt057		dc.b	"PERMANENTE UNSICHTBARKEIT GEFUNDEN",0
thingsTxt067		dc.b	"BIERKRUG GEFUNDEN",0
thingsTxt068		dc.b	"ZUG-ORTUNGSGERŽT FšR KARTE GEFUNDEN",0
thingsTxt080		dc.b	"KONDOM GEFUNDEN",0
thingsTxt081		dc.b	"ID-KARTE GEFUNDEN",0
thingsTxt083		dc.b	"MUNITION FšR $(XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX) GEFUNDEN",0
thingsTxt084		dc.b	"MUNITION FšR $(XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX) GEFUNDEN",0
thingsTxt085		dc.b	"MUNITION FšR $(XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX) GEFUNDEN",0
thingsTxt086		dc.b	"MUNITION FšR $(XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX) GEFUNDEN",0
thingsTxt087		dc.b	"MUNITION FšR $(XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX) GEFUNDEN",0
thingsTxt088		dc.b	"MUNITION FšR $(XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX) GEFUNDEN",0
thingsTxt089		dc.b	"MUNITION FšR $(XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX) GEFUNDEN",0
thingsTxt090		dc.b	"MUNITION FšR $(XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX) GEFUNDEN",0
thingsTxt091		dc.b	"MUNITION FšR $(XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX) GEFUNDEN",0
thingsTxt092		dc.b	"MUNITION FšR $(XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX) GEFUNDEN",0
thingsTxt093		dc.b	"MUNITION FšR $(XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX) GEFUNDEN",0
thingsTxt094		dc.b	"MUNITION FšR $(XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX) GEFUNDEN",0
thingsTxt095		dc.b	"WAFFE $(XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX) GEFUNDEN",0
thingsTxt096		dc.b	"WAFFE $(XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX) GEFUNDEN",0
thingsTxt097		dc.b	"WAFFE $(XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX) GEFUNDEN",0
thingsTxt098		dc.b	"WAFFE $(XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX) GEFUNDEN",0
thingsTxt099		dc.b	"WAFFE $(XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX) GEFUNDEN",0
thingsTxt100		dc.b	"WAFFE $(XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX) GEFUNDEN",0
thingsTxt101		dc.b	"DREHBARE KARTE GEFUNDEN",0
		ENDC
			even

		IFEQ LANGUAGE
plActionTxt009		dc.b 	"ULTRA-SCANNER ACTIVATED",0
plActionTxt010		dc.b	"NIGHTVIEWER ACTIVATED",0
plActionTxt011		dc.b	"GAS MASK SET ON",0
plActionTxt012		dc.b	"ENERGY INCREASED",0
plActionTxt013		dc.b	"ENERGY INCREASED",0
plActionTxt018		dc.b	"INVULNERABILITY ACTIVATED",0
plActionTxt019		dc.b	"INVISIBILITY ACTIVATED",0
plActionTxt024		dc.b	"RADIATION SUIT PUT ON",0
plActionTxt025		dc.b	"GEIGER COUNTER ACTIVATED",0
plActionTxt028		dc.b	"MONSTER DETECTOR ACTIVATED",0
plActionTxt029		dc.b	"FULL PLAN ACTIVATED",0
plActionTxt041		dc.b	"WELDING TORCH ACTIVATED",0
plActionTxt043		dc.b	"TOXIC SUBSTANCE RELEASED",0
plActionTxt046		dc.b	"PLAN ACTIVATED",0
plActionTxt056		dc.b	"PERM. INVULNERABILITY ACT.",0
plActionTxt057		dc.b	"PERM. INVISIBILITY ACTIVATED",0
plActionTxt068		dc.b	"TRAIN DETECTOR ACTIVATED",0
plActionTxt101		dc.b	"REVOLVING PLAN ACTIVATED",0
		ELSE
plActionTxt009		dc.b 	"ULTRA-SCANNER AKTIVIERT",0
plActionTxt010		dc.b	"NACHTSICHTGERŽT AKTIVIERT",0
plActionTxt011		dc.b	"GASMASKE AUFGESETZT",0
plActionTxt012		dc.b	"ENERGIEZUNAHME",0
plActionTxt013		dc.b	"ENERGIEZUNAHME",0
plActionTxt018		dc.b	"UNVERWUNDBARKEIT AKTIVIERT",0
plActionTxt019		dc.b	"UNSICHTBARKEIT AKTIVIERT",0
plActionTxt024		dc.b	"STRAHLENSCHUTZANZUG ANGEZOGEN",0
plActionTxt025		dc.b	"GEIGERZŽHLER AKTIVIERT",0
plActionTxt028		dc.b	"GEGNERANZEIGE FšR KARTE AKTIVIERT",0
plActionTxt029		dc.b	"GESAMTPLAN AKTIVIERT",0
plActionTxt041		dc.b	"SCHWEISSGERŽT AKTIVIERT",0
plActionTxt043		dc.b	"GIFTIGE SUBSTANZ FREIGESETZT",0
plActionTxt046		dc.b	"KARTE AKTIVIERT",0
plActionTxt056		dc.b	"PERMANENTE UNVERWUNDBARKEIT AKTIVIERT",0
plActionTxt057		dc.b	"PERMANENTE UNSICHTBARKEIT AKTIVIERT",0
plActionTxt068		dc.b	"ZUG-ORTUNGSGERŽT AKTIVIERT",0
plActionTxt101		dc.b	"DREHBARE KARTE AKTIVIERT",0
		ENDC
			even

		IFEQ LANGUAGE
plDeactionTxt009	dc.b	"ULTRA-SCANNER DEACTIVATED",0
plDeactionTxt010	dc.b	"NIGHTVIEWER DEACTIVATED",0
plDeactionTxt011	dc.b	"GAS MASK TAKEN OFF",0
plDeactionTxt018	dc.b	"INVULNERABILITY DEACTIVATED",0
plDeactionTxt019	dc.b	"INVISIBILITY DEACTIVATED",0
plDeactionTxt024	dc.b	"RADIATION SUIT TAKEN OFF",0
plDeactionTxt025	dc.b	"GEIGER COUNTER DEACTIVATED",0
plDeactionTxt028	dc.b	"MONSTER DETECTOR DEACTIVATED",0
plDeactionTxt029	dc.b	"FULL PLAN DEACTIVATED",0
plDeactionTxt041	dc.b	"WELDING TORCH DEACTIVATED",0
plDeactionTxt046	dc.b	"PLAN DEACTIVATED",0
plDeactionTxt056	dc.b	"PERM. INVULNERABILITY DEACT.",0
plDeactionTxt057	dc.b	"PERM. INVISIBILITY DEACTIVATED",0
plDeactionTxt068	dc.b	"TRAIN DETECTOR DEACTIVATED",0
plDeactionTxt101	dc.b	"REVOLVING PLAN DEACTIVATED",0
		ELSE
plDeactionTxt009	dc.b	"ULTRA-SCANNER DEAKTIVIERT",0
plDeactionTxt010	dc.b	"NACHTSICHTGERŽT DEAKTIVIERT",0
plDeactionTxt011	dc.b	"GASMASKE ABGESETZT",0
plDeactionTxt018	dc.b	"UNVERWUNDBARKEIT DEAKTIVIERT",0
plDeactionTxt019	dc.b	"UNSICHTBARKEIT DEAKTIVIERT",0
plDeactionTxt024	dc.b	"STRAHLENSCHUTZANZUG AUSGEZOGEN",0
plDeactionTxt025	dc.b	"GEIGERZŽHLER DEAKTIVIERT",0
plDeactionTxt028	dc.b	"GEGNERANZEIGE FšR KARTE DEAKTIVIERT",0
plDeactionTxt029	dc.b	"GESAMTPLAN DEAKTIVIERT",0
plDeactionTxt041	dc.b	"SCHWEISSGERŽT DEAKTIVIERT",0
plDeactionTxt046	dc.b	"KARTE DEAKTIVIERT",0
plDeactionTxt056	dc.b	"PERMANENTE UNVERWUNDBARKEIT DEAKTIVIERT",0
plDeactionTxt057	dc.b	"PERMANENTE UNSICHTBARKEIT DEAKTIVIERT",0
plDeactionTxt068	dc.b	"ZUG-ORTUNGSGERŽT DEAKTIVIERT",0
plDeactionTxt101	dc.b	"DREHBARE KARTE DEAKTIVIERT",0
		ENDC
			even
