		rsreset
sshapenum	rs.l	1	; Shape to display
stictime	rs.w	1	; Time before next state
sthink		rs.l	1	; Think logic index
saction		rs.l	1	; Action code
snext		rs.w	1	; Next state
state_t		=	__RS

		rsreset		; State Enumeration
ST_GRD_STND	rs.b	state_t	
ST_GRD_WLK1	rs.b	state_t
ST_GRD_WLK2	rs.b	state_t
ST_GRD_WLK3	rs.b	state_t
ST_GRD_WLK4	rs.b	state_t
ST_GRD_ATK1	rs.b	state_t
ST_GRD_ATK2	rs.b	state_t
ST_GRD_ATK3	rs.b	state_t
ST_GRD_PAIN	rs.b	state_t
ST_GRD_DIE	rs.b	state_t
ST_GRD_DTH1	rs.b	state_t
ST_GRD_DTH2	rs.b	state_t
ST_GRD_DTH3	rs.b	state_t
ST_DOG_STND	rs.b	state_t
ST_DOG_WLK1	rs.b	state_t
ST_DOG_WLK2	rs.b	state_t
ST_DOG_WLK3	rs.b	state_t
ST_DOG_WLK4	rs.b	state_t
ST_DOG_ATK1	rs.b	state_t
ST_DOG_ATK2	rs.b	state_t
ST_DOG_ATK3	rs.b	state_t
ST_DOG_ATK4	rs.b	state_t
ST_DOG_DIE	rs.b	state_t
ST_DOG_DTH2	rs.b	state_t
ST_DOG_DTH3	rs.b	state_t
ST_DOG_DTH4	rs.b	state_t
ST_SS_STND	rs.b	state_t
ST_SS_WLK1	rs.b	state_t
ST_SS_WLK2	rs.b	state_t
ST_SS_WLK3	rs.b	state_t
ST_SS_WLK4	rs.b	state_t
ST_SS_ATK1	rs.b	state_t
ST_SS_ATK2	rs.b	state_t
ST_SS_ATK3	rs.b	state_t
ST_SS_ATK4	rs.b	state_t
ST_SS_ATK5	rs.b	state_t
ST_SS_ATK6	rs.b	state_t
ST_SS_ATK7	rs.b	state_t
ST_SS_ATK8	rs.b	state_t
ST_SS_ATK9	rs.b	state_t
ST_SS_PAIN	rs.b	state_t
ST_SS_DIE	rs.b	state_t
ST_SS_DTH1	rs.b	state_t
ST_SS_DTH2	rs.b	state_t
ST_SS_DTH3	rs.b	state_t
ST_OFC_STND	rs.b	state_t
ST_OFC_WLK1	rs.b	state_t
ST_OFC_WLK2	rs.b	state_t
ST_OFC_WLK3	rs.b	state_t
ST_OFC_WLK4	rs.b	state_t
ST_OFC_ATK1	rs.b	state_t
ST_OFC_ATK2	rs.b	state_t
ST_OFC_ATK3	rs.b	state_t
ST_OFC_PAIN	rs.b	state_t
ST_OFC_DIE	rs.b	state_t
ST_OFC_DTH1	rs.b	state_t
ST_OFC_DTH2	rs.b	state_t
ST_OFC_DTH3	rs.b	state_t
ST_MUTANT_STND	rs.b	state_t
ST_MUTANT_WLK1	rs.b	state_t
ST_MUTANT_WLK2	rs.b	state_t
ST_MUTANT_WLK3	rs.b	state_t
ST_MUTANT_WLK4	rs.b	state_t
ST_MUTANT_ATK1	rs.b	state_t
ST_MUTANT_ATK2	rs.b	state_t
ST_MUTANT_ATK3	rs.b	state_t
ST_MUTANT_ATK4	rs.b	state_t
ST_MUTANT_PAIN	rs.b	state_t
ST_MUTANT_DIE	rs.b	state_t
ST_MUTANT_DTH1	rs.b	state_t
ST_MUTANT_DTH2	rs.b	state_t
ST_MUTANT_DTH3	rs.b	state_t
ST_HANS_STND	rs.b	state_t
ST_HANS_WLK1	rs.b	state_t
ST_HANS_WLK2	rs.b	state_t
ST_HANS_WLK3	rs.b	state_t
ST_HANS_WLK4	rs.b	state_t
ST_HANS_ATK1	rs.b	state_t
ST_HANS_ATK2	rs.b	state_t
ST_HANS_ATK3	rs.b	state_t
ST_HANS_ATK4	rs.b	state_t
ST_HANS_ATK5	rs.b	state_t
ST_HANS_ATK6	rs.b	state_t
ST_HANS_ATK7	rs.b	state_t
ST_HANS_DIE	rs.b	state_t
ST_HANS_DTH2	rs.b	state_t
ST_HANS_DTH3	rs.b	state_t
ST_SCHABBS_STND	rs.b	state_t
ST_SCHABBS_WLK1	rs.b	state_t
ST_SCHABBS_WLK2	rs.b	state_t
ST_SCHABBS_WLK3	rs.b	state_t
ST_SCHABBS_WLK4	rs.b	state_t
ST_SCHABBS_ATK1	rs.b	state_t
ST_SCHABBS_ATK2	rs.b	state_t
ST_SCHABBS_DIE	rs.b	state_t
ST_SCHABBS_DTH2	rs.b	state_t
ST_SCHABBS_DTH3	rs.b	state_t
ST_TRANS_STND	rs.b	state_t
ST_TRANS_WLK1	rs.b	state_t
ST_TRANS_WLK2	rs.b	state_t
ST_TRANS_WLK3	rs.b	state_t
ST_TRANS_WLK4	rs.b	state_t
ST_TRANS_ATK1	rs.b	state_t
ST_TRANS_ATK2	rs.b	state_t
ST_TRANS_ATK3	rs.b	state_t
ST_TRANS_ATK4	rs.b	state_t
ST_TRANS_ATK5	rs.b	state_t
ST_TRANS_ATK6	rs.b	state_t
ST_TRANS_ATK7	rs.b	state_t
ST_TRANS_DIE	rs.b	state_t
ST_TRANS_DTH2	rs.b	state_t
ST_TRANS_DTH3	rs.b	state_t
ST_UBER_STND	rs.b	state_t
ST_UBER_WLK1	rs.b	state_t
ST_UBER_WLK2	rs.b	state_t
ST_UBER_WLK3	rs.b	state_t
ST_UBER_WLK4	rs.b	state_t
ST_UBER_ATK1	rs.b	state_t
ST_UBER_ATK2	rs.b	state_t
ST_UBER_ATK3	rs.b	state_t
ST_UBER_ATK4	rs.b	state_t
ST_UBER_ATK5	rs.b	state_t
ST_UBER_ATK6	rs.b	state_t
ST_UBER_ATK7	rs.b	state_t
ST_UBER_DIE	rs.b	state_t
ST_UBER_DTH2	rs.b	state_t
ST_UBER_DTH3	rs.b	state_t
ST_DKNIGHT_STND	rs.b	state_t
ST_DKNIGHT_WLK1	rs.b	state_t
ST_DKNIGHT_WLK2	rs.b	state_t
ST_DKNIGHT_WLK3	rs.b	state_t
ST_DKNIGHT_WLK4	rs.b	state_t
ST_DKNIGHT_ATK1	rs.b	state_t
ST_DKNIGHT_ATK2	rs.b	state_t
ST_DKNIGHT_ATK3	rs.b	state_t
ST_DKNIGHT_ATK4	rs.b	state_t
ST_DKNIGHT_ATK5	rs.b	state_t
ST_DKNIGHT_DIE	rs.b	state_t
ST_DKNIGHT_DTH2	rs.b	state_t
ST_DKNIGHT_DTH3	rs.b	state_t
ST_MHITLER_STND	rs.b	state_t
ST_MHITLER_WLK1	rs.b	state_t
ST_MHITLER_WLK2	rs.b	state_t
ST_MHITLER_WLK3	rs.b	state_t
ST_MHITLER_WLK4	rs.b	state_t
ST_MHITLER_ATK1	rs.b	state_t
ST_MHITLER_ATK2	rs.b	state_t
ST_MHITLER_ATK3	rs.b	state_t
ST_MHITLER_ATK4	rs.b	state_t
ST_MHITLER_ATK5	rs.b	state_t
ST_MHITLER_ATK6	rs.b	state_t
ST_MHITLER_ATK7	rs.b	state_t
ST_MHITLER_DIE1	rs.b	state_t
ST_MHITLER_DIE2	rs.b	state_t
ST_MHITLER_DIE3	rs.b	state_t
ST_MHITLER_DIE4	rs.b	state_t
ST_HITLER_WLK1	rs.b	state_t
ST_HITLER_WLK2	rs.b	state_t
ST_HITLER_WLK3	rs.b	state_t
ST_HITLER_WLK4	rs.b	state_t
ST_HITLER_ATK1	rs.b	state_t
ST_HITLER_ATK2	rs.b	state_t
ST_HITLER_ATK3	rs.b	state_t
ST_HITLER_ATK4	rs.b	state_t
ST_HITLER_ATK5	rs.b	state_t
ST_HITLER_DIE	rs.b	state_t
ST_HITLER_DTH2	rs.b	state_t
ST_HITLER_DTH3	rs.b	state_t
ST_HITLER_DTH4	rs.b	state_t
NUMSTATES	=	__RS/state_t

		section	data
states		dc.l	S_GUARD_WLK4
		dc.w	0
		dc.l	T_STAND,A_NULL
		dc.w	ST_GRD_STND

		dc.l	S_GUARD_WLK1
		dc.w	12
		dc.l	T_CHASE,A_TARGET
		dc.w	ST_GRD_WLK2

		dc.l	S_GUARD_WLK2
		dc.w	12
		dc.l	T_CHASE,A_TARGET
		dc.w	ST_GRD_WLK3

		dc.l	S_GUARD_WLK3
		dc.w	12
		dc.l	T_CHASE,A_TARGET
		dc.w	ST_GRD_WLK4

		dc.l	S_GUARD_WLK4
		dc.w	12
		dc.l	T_CHASE,A_TARGET
		dc.w	ST_GRD_WLK1

		dc.l	S_GUARD_ATK1
		dc.w	16
		dc.l	T_NULL,A_NULL
		dc.w	ST_GRD_ATK2

		dc.l	S_GUARD_ATK2
		dc.w	16
		dc.l	T_NULL,A_NULL
		dc.w	ST_GRD_ATK3

		dc.l	S_GUARD_ATK3
		dc.w	16
		dc.l	T_NULL,A_SHOOT
		dc.w	ST_GRD_WLK1

		dc.l	S_GUARD_PAIN
		dc.w	12
		dc.l	T_NULL,A_NULL
		dc.w	ST_GRD_WLK1

		dc.l	S_GUARD_PAIN
		dc.w	8
		dc.l	T_NULL,A_NULL
		dc.w	ST_GRD_DTH1

		dc.l	S_GUARD_DTH1
		dc.w	8
		dc.l	T_NULL,A_SCREAM
		dc.w	ST_GRD_DTH2

		dc.l	S_GUARD_DTH2
		dc.w	8
		dc.l	T_NULL,A_THUD
		dc.w	ST_GRD_DTH3

		dc.l	S_GUARD_DTH3
		dc.w	0
		dc.l	T_NULL,A_NULL
		dc.w	ST_GRD_DTH3

		dc.l	S_DOG_WLK4
		dc.w	0
		dc.l	T_STAND,A_NULL
		dc.w	ST_DOG_STND

		dc.l	S_DOG_WLK1
		dc.w	8
		dc.l	T_CHASE,A_TARGET
		dc.w	ST_DOG_WLK2

		dc.l	S_DOG_WLK2
		dc.w	8
		dc.l	T_CHASE,A_TARGET
		dc.w	ST_DOG_WLK3

		dc.l	S_DOG_WLK3
		dc.w	8
		dc.l	T_CHASE,A_TARGET
		dc.w	ST_DOG_WLK4

		dc.l	S_DOG_WLK4
		dc.w	8
		dc.l	T_CHASE,A_TARGET
		dc.w	ST_DOG_WLK1

		dc.l	S_DOG_ATK1
		dc.w	8
		dc.l	T_NULL,A_NULL
		dc.w	ST_DOG_ATK2

		dc.l	S_DOG_ATK2
		dc.w	8
		dc.l	T_NULL,A_NULL
		dc.w	ST_DOG_ATK3

		dc.l	S_DOG_ATK3
		dc.w	20
		dc.l	T_NULL,A_BITE
		dc.w	ST_DOG_ATK4

		dc.l	S_DOG_WLK1
		dc.w	8
		dc.l	T_NULL,A_NULL
		dc.w	ST_DOG_WLK1

		dc.l	S_DOG_DTH1
		dc.w	8
		dc.l	T_NULL,A_NULL
		dc.w	ST_DOG_DTH2

		dc.l	S_DOG_DTH2
		dc.w	8
		dc.l	T_NULL,A_SCREAM
		dc.w	ST_DOG_DTH3

		dc.l	S_DOG_DTH3
		dc.w	8
		dc.l	T_NULL,A_THUD
		dc.w	ST_DOG_DTH4

		dc.l	S_DOG_DTH3
		dc.w	0
		dc.l	T_NULL,A_NULL
		dc.w	ST_DOG_DTH4

		dc.l	S_SS_WLK4
		dc.w	0
		dc.l	T_STAND,A_NULL
		dc.w	ST_SS_STND

		dc.l	S_SS_WLK1
		dc.w	20
		dc.l	T_CHASE,A_TARGET
		dc.w	ST_SS_WLK2

		dc.l	S_SS_WLK2
		dc.w	20
		dc.l	T_CHASE,A_TARGET
		dc.w	ST_SS_WLK3

		dc.l	S_SS_WLK3
		dc.w	20
		dc.l	T_CHASE,A_TARGET
		dc.w	ST_SS_WLK4

		dc.l	S_SS_WLK4
		dc.w	20
		dc.l	T_CHASE,A_TARGET
		dc.w	ST_SS_WLK1

		dc.l	S_SS_ATK1
		dc.w	20
		dc.l	T_NULL,A_NULL
		dc.w	ST_SS_ATK2

		dc.l	S_SS_ATK2
		dc.w	20
		dc.l	T_NULL,A_NULL
		dc.w	ST_SS_ATK3

		dc.l	S_SS_ATK3
		dc.w	8
		dc.l	T_NULL,A_SHOOT
		dc.w	ST_SS_ATK4

		dc.l	S_SS_ATK2
		dc.w	8
		dc.l	T_NULL,A_NULL
		dc.w	ST_SS_ATK5

		dc.l	S_SS_ATK3
		dc.w	8
		dc.l	T_NULL,A_SHOOT
		dc.w	ST_SS_ATK6

		dc.l	S_SS_ATK2
		dc.w	8
		dc.l	T_NULL,A_NULL
		dc.w	ST_SS_ATK7

		dc.l	S_SS_ATK3
		dc.w	8
		dc.l	T_NULL,A_SHOOT
		dc.w	ST_SS_ATK8

		dc.l	S_SS_ATK2
		dc.w	8
		dc.l	T_NULL,A_NULL
		dc.w	ST_SS_ATK9

		dc.l	S_SS_ATK3
		dc.w	8
		dc.l	T_NULL,A_SHOOT
		dc.w	ST_SS_WLK1

		dc.l	S_SS_PAIN
		dc.w	8
		dc.l	T_NULL,A_NULL
		dc.w	ST_SS_WLK1

		dc.l	S_SS_PAIN
		dc.w	8
		dc.l	T_NULL,A_NULL
		dc.w	ST_SS_DTH1

		dc.l	S_SS_DTH1
		dc.w	8
		dc.l	T_NULL,A_SCREAM
		dc.w	ST_SS_DTH2

		dc.l	S_SS_DTH2
		dc.w	8
		dc.l	T_NULL,A_THUD
		dc.w	ST_SS_DTH3

		dc.l	S_SS_DTH3
		dc.w	0
		dc.l	T_NULL,A_NULL
		dc.w	ST_SS_DTH3

		dc.l	S_OFFICER_WLK4
		dc.w	0
		dc.l	T_STAND,A_NULL
		dc.w	ST_OFC_STND

		dc.l	S_OFFICER_WLK1
		dc.w	12
		dc.l	T_CHASE,A_TARGET
		dc.w	ST_OFC_WLK2

		dc.l	S_OFFICER_WLK2
		dc.w	8
		dc.l	T_CHASE,A_TARGET
		dc.w	ST_OFC_WLK3

		dc.l	S_OFFICER_WLK3
		dc.w	12
		dc.l	T_CHASE,A_TARGET
		dc.w	ST_OFC_WLK4

		dc.l	S_OFFICER_WLK4
		dc.w	8
		dc.l	T_CHASE,A_TARGET
		dc.w	ST_OFC_WLK1

		dc.l	S_OFFICER_ATK1
		dc.w	8
		dc.l	T_NULL,A_NULL
		dc.w	ST_OFC_ATK2

		dc.l	S_OFFICER_ATK2
		dc.w	8
		dc.l	T_NULL,A_NULL
		dc.w	ST_OFC_ATK3

		dc.l	S_OFFICER_ATK3
		dc.w	16
		dc.l	T_NULL,A_SHOOT
		dc.w	ST_OFC_WLK1

		dc.l	S_OFFICER_PAIN
		dc.w	8
		dc.l	T_NULL,A_NULL
		dc.w	ST_OFC_WLK1

		dc.l	S_OFFICER_PAIN
		dc.w	8
		dc.l	T_NULL,A_NULL
		dc.w	ST_OFC_DTH1

		dc.l	S_OFFICER_DTH1
		dc.w	8
		dc.l	T_NULL,A_SCREAM
		dc.w	ST_OFC_DTH2

		dc.l	S_OFFICER_DTH2
		dc.w	8
		dc.l	T_NULL,A_THUD
		dc.w	ST_OFC_DTH3

		dc.l	S_OFFICER_DTH3
		dc.w	0
		dc.l	T_NULL,A_NULL
		dc.w	ST_OFC_DTH3

		dc.l	S_MUTANT_WLK4
		dc.w	0
		dc.l	T_STAND,A_NULL
		dc.w	ST_MUTANT_STND

		dc.l	S_MUTANT_WLK1
		dc.w	16
		dc.l	T_CHASE,A_TARGET
		dc.w	ST_MUTANT_WLK2

		dc.l	S_MUTANT_WLK2
		dc.w	16
		dc.l	T_CHASE,A_TARGET
		dc.w	ST_MUTANT_WLK3

		dc.l	S_MUTANT_WLK3
		dc.w	16
		dc.l	T_CHASE,A_TARGET
		dc.w	ST_MUTANT_WLK4

		dc.l	S_MUTANT_WLK4
		dc.w	16
		dc.l	T_CHASE,A_TARGET
		dc.w	ST_MUTANT_WLK1

		dc.l	S_MUTANT_ATK1
		dc.w	8
		dc.l	T_NULL,A_NULL
		dc.w	ST_MUTANT_ATK2

		dc.l	S_MUTANT_ATK2
		dc.w	20
		dc.l	T_NULL,A_SHOOT
		dc.w	ST_MUTANT_ATK3

		dc.l	S_MUTANT_ATK1
		dc.w	8
		dc.l	T_NULL,A_NULL
		dc.w	ST_MUTANT_ATK4

		dc.l	S_MUTANT_ATK3
		dc.w	20
		dc.l	T_NULL,A_SHOOT
		dc.w	ST_MUTANT_WLK1

		dc.l	S_MUTANT_PAIN
		dc.w	8
		dc.l	T_NULL,A_NULL
		dc.w	ST_MUTANT_WLK1

		dc.l	S_MUTANT_PAIN
		dc.w	8
		dc.l	T_NULL,A_NULL
		dc.w	ST_MUTANT_DTH1

		dc.l	S_MUTANT_DTH1
		dc.w	8
		dc.l	T_NULL,A_SCREAM
		dc.w	ST_MUTANT_DTH2

		dc.l	S_MUTANT_DTH2
		dc.w	8
		dc.l	T_NULL,A_THUD
		dc.w	ST_MUTANT_DTH3

		dc.l	S_MUTANT_DTH3
		dc.w	0
		dc.l	T_NULL,A_NULL
		dc.w	ST_MUTANT_DTH3

		dc.l	S_HANS_WLK4
		dc.w	0
		dc.l	T_STAND,A_NULL
		dc.w	ST_HANS_STND

		dc.l	S_HANS_WLK1
		dc.w	20
		dc.l	T_CHASE,A_TARGET
		dc.w	ST_HANS_WLK2

		dc.l	S_HANS_WLK2
		dc.w	20
		dc.l	T_CHASE,A_TARGET
		dc.w	ST_HANS_WLK3

		dc.l	S_HANS_WLK3
		dc.w	20
		dc.l	T_CHASE,A_TARGET
		dc.w	ST_HANS_WLK4

		dc.l	S_HANS_WLK4
		dc.w	20
		dc.l	T_CHASE,A_TARGET
		dc.w	ST_HANS_WLK1

		dc.l	S_HANS_ATK1
		dc.w	40
		dc.l	T_NULL,A_NULL
		dc.w	ST_HANS_ATK2

		dc.l	S_HANS_ATK2
		dc.w	12
		dc.l	T_NULL,A_SHOOT
		dc.w	ST_HANS_ATK3

		dc.l	S_HANS_ATK3
		dc.w	12
		dc.l	T_NULL,A_SHOOT
		dc.w	ST_HANS_ATK4

		dc.l	S_HANS_ATK2
		dc.w	12
		dc.l	T_NULL,A_SHOOT
		dc.w	ST_HANS_ATK5

		dc.l	S_HANS_ATK3
		dc.w	12
		dc.l	T_NULL,A_SHOOT
		dc.w	ST_HANS_ATK6

		dc.l	S_HANS_ATK2
		dc.w	12
		dc.l	T_NULL,A_SHOOT
		dc.w	ST_HANS_ATK7

		dc.l	S_HANS_ATK3
		dc.w	12
		dc.l	T_NULL,A_SHOOT
		dc.w	ST_HANS_WLK1

		dc.l	S_HANS_DTH1
		dc.w	16
		dc.l	T_NULL,A_SCREAM
		dc.w	ST_HANS_DTH2

		dc.l	S_HANS_DTH2
		dc.w	16
		dc.l	T_NULL,A_THUD
		dc.w	ST_HANS_DTH3

		dc.l	S_HANS_DTH3
		dc.w	0
		dc.l	T_NULL,A_NULL
		dc.w	ST_HANS_DTH3

		dc.l	S_SCHABBS_WLK4
		dc.w	0
		dc.l	T_STAND,A_NULL
		dc.w	ST_SCHABBS_STND

		dc.l	S_SCHABBS_WLK1
		dc.w	20
		dc.l	T_CHASE,A_TARGET
		dc.w	ST_SCHABBS_WLK2

		dc.l	S_SCHABBS_WLK2
		dc.w	20
		dc.l	T_CHASE,A_TARGET
		dc.w	ST_SCHABBS_WLK3

		dc.l	S_SCHABBS_WLK3
		dc.w	20
		dc.l	T_CHASE,A_TARGET
		dc.w	ST_SCHABBS_WLK4

		dc.l	S_SCHABBS_WLK4
		dc.w	20
		dc.l	T_CHASE,A_TARGET
		dc.w	ST_SCHABBS_WLK1

		dc.l	S_SCHABBS_ATK1
		dc.w	28
		dc.l	T_NULL,A_NULL
		dc.w	ST_SCHABBS_ATK2

		dc.l	S_SCHABBS_ATK2
		dc.w	12
		dc.l	T_NULL,A_THROW
		dc.w	ST_SCHABBS_WLK1

		dc.l	S_SCHABBS_DTH1
		dc.w	16
		dc.l	T_NULL,A_SCREAM
		dc.w	ST_SCHABBS_DTH2

		dc.l	S_SCHABBS_DTH2
		dc.w	16
		dc.l	T_NULL,A_THUD
		dc.w	ST_SCHABBS_DTH3

		dc.l	S_SCHABBS_DTH3
		dc.w	0
		dc.l	T_NULL,A_NULL
		dc.w	ST_SCHABBS_DTH3

		dc.l	S_TRANS_WLK4
		dc.w	0
		dc.l	T_STAND,A_NULL
		dc.w	ST_TRANS_STND

		dc.l	S_TRANS_WLK1
		dc.w	20
		dc.l	T_CHASE,A_TARGET
		dc.w	ST_TRANS_WLK2

		dc.l	S_TRANS_WLK2
		dc.w	20
		dc.l	T_CHASE,A_TARGET
		dc.w	ST_TRANS_WLK3

		dc.l	S_TRANS_WLK3
		dc.w	20
		dc.l	T_CHASE,A_TARGET
		dc.w	ST_TRANS_WLK4

		dc.l	S_TRANS_WLK4
		dc.w	20
		dc.l	T_CHASE,A_TARGET
		dc.w	ST_TRANS_WLK1

		dc.l	S_TRANS_ATK1
		dc.w	48
		dc.l	T_NULL,A_NULL
		dc.w	ST_TRANS_ATK2

		dc.l	S_TRANS_ATK2
		dc.w	12
		dc.l	T_NULL,A_SHOOT
		dc.w	ST_TRANS_ATK3

		dc.l	S_TRANS_ATK3
		dc.w	12
		dc.l	T_NULL,A_SHOOT
		dc.w	ST_TRANS_ATK4

		dc.l	S_TRANS_ATK2
		dc.w	12
		dc.l	T_NULL,A_SHOOT
		dc.w	ST_TRANS_ATK5

		dc.l	S_TRANS_ATK3
		dc.w	12
		dc.l	T_NULL,A_SHOOT
		dc.w	ST_TRANS_ATK6

		dc.l	S_TRANS_ATK2
		dc.w	12
		dc.l	T_NULL,A_SHOOT
		dc.w	ST_TRANS_ATK7

		dc.l	S_TRANS_ATK3
		dc.w	12
		dc.l	T_NULL,A_SHOOT
		dc.w	ST_TRANS_WLK1

		dc.l	S_TRANS_DTH1
		dc.w	16
		dc.l	T_NULL,A_SCREAM
		dc.w	ST_TRANS_DTH2

		dc.l	S_TRANS_DTH2
		dc.w	16
		dc.l	T_NULL,A_THUD
		dc.w	ST_TRANS_DTH3

		dc.l	S_TRANS_DTH3
		dc.w	0
		dc.l	T_NULL,A_NULL
		dc.w	ST_TRANS_DTH3

		dc.l	S_UBER_WLK4
		dc.w	0
		dc.l	T_STAND,A_NULL
		dc.w	ST_UBER_STND

		dc.l	S_UBER_WLK1
		dc.w	12
		dc.l	T_CHASE,A_TARGET
		dc.w	ST_UBER_WLK2

		dc.l	S_UBER_WLK2
		dc.w	12
		dc.l	T_CHASE,A_TARGET
		dc.w	ST_UBER_WLK3

		dc.l	S_UBER_WLK3
		dc.w	12
		dc.l	T_CHASE,A_TARGET
		dc.w	ST_UBER_WLK4

		dc.l	S_UBER_WLK4
		dc.w	12
		dc.l	T_CHASE,A_TARGET
		dc.w	ST_UBER_WLK1

		dc.l	S_UBER_ATK1
		dc.w	40
		dc.l	T_NULL,A_NULL
		dc.w	ST_UBER_ATK2

		dc.l	S_UBER_ATK2
		dc.w	8
		dc.l	T_NULL,A_SHOOT
		dc.w	ST_UBER_ATK3

		dc.l	S_UBER_ATK3
		dc.w	8
		dc.l	T_NULL,A_SHOOT
		dc.w	ST_UBER_ATK4

		dc.l	S_UBER_ATK2
		dc.w	8
		dc.l	T_NULL,A_SHOOT
		dc.w	ST_UBER_ATK5

		dc.l	S_UBER_ATK3
		dc.w	8
		dc.l	T_NULL,A_SHOOT
		dc.w	ST_UBER_ATK6

		dc.l	S_UBER_ATK2
		dc.w	8
		dc.l	T_NULL,A_SHOOT
		dc.w	ST_UBER_ATK7

		dc.l	S_UBER_ATK3
		dc.w	8
		dc.l	T_NULL,A_SHOOT
		dc.w	ST_UBER_WLK1

		dc.l	S_UBER_DTH1
		dc.w	16
		dc.l	T_NULL,A_SCREAM
		dc.w	ST_UBER_DTH2

		dc.l	S_UBER_DTH2
		dc.w	16
		dc.l	T_NULL,A_THUD
		dc.w	ST_UBER_DTH3

		dc.l	S_UBER_DTH3
		dc.w	0
		dc.l	T_NULL,A_NULL
		dc.w	ST_UBER_DTH3

		dc.l	S_DKNIGHT_WLK4
		dc.w	0
		dc.l	T_STAND,A_NULL
		dc.w	ST_DKNIGHT_STND

		dc.l	S_DKNIGHT_WLK1
		dc.w	20
		dc.l	T_CHASE,A_TARGET
		dc.w	ST_DKNIGHT_WLK2

		dc.l	S_DKNIGHT_WLK2
		dc.w	20
		dc.l	T_CHASE,A_TARGET
		dc.w	ST_DKNIGHT_WLK3

		dc.l	S_DKNIGHT_WLK3
		dc.w	20
		dc.l	T_CHASE,A_TARGET
		dc.w	ST_DKNIGHT_WLK4

		dc.l	S_DKNIGHT_WLK4
		dc.w	20
		dc.l	T_CHASE,A_TARGET
		dc.w	ST_DKNIGHT_WLK1

		dc.l	S_DKNIGHT_ATK1
		dc.w	28
		dc.l	T_NULL,A_NULL
		dc.w	ST_DKNIGHT_ATK2

		dc.l	S_DKNIGHT_ATK2
		dc.w	12
		dc.l	T_NULL,A_LAUNCH
		dc.w	ST_DKNIGHT_ATK3

		dc.l	S_DKNIGHT_ATK4
		dc.w	12
		dc.l	T_NULL,A_SHOOT
		dc.w	ST_DKNIGHT_ATK4

		dc.l	S_DKNIGHT_ATK3
		dc.w	12
		dc.l	T_NULL,A_LAUNCH
		dc.w	ST_DKNIGHT_ATK5

		dc.l	S_DKNIGHT_ATK4
		dc.w	12
		dc.l	T_NULL,A_SHOOT
		dc.w	ST_DKNIGHT_WLK1

		dc.l	S_DKNIGHT_DTH1
		dc.w	16
		dc.l	T_NULL,A_SCREAM
		dc.w	ST_DKNIGHT_DTH2

		dc.l	S_DKNIGHT_DTH2
		dc.w	16
		dc.l	T_NULL,A_THUD
		dc.w	ST_DKNIGHT_DTH3

		dc.l	S_DKNIGHT_DTH3
		dc.w	0
		dc.l	T_NULL,A_NULL
		dc.w	ST_DKNIGHT_DTH3

		dc.l	S_MHITLER_WLK4
		dc.w	0
		dc.l	T_STAND,A_NULL
		dc.w	ST_MHITLER_STND

		dc.l	S_MHITLER_WLK1
		dc.w	20
		dc.l	T_CHASE,A_MECHSTEP
		dc.w	ST_MHITLER_WLK2

		dc.l	S_MHITLER_WLK2
		dc.w	20
		dc.l	T_CHASE,A_TARGET
		dc.w	ST_MHITLER_WLK3

		dc.l	S_MHITLER_WLK3
		dc.w	20
		dc.l	T_CHASE,A_MECHSTEP
		dc.w	ST_MHITLER_WLK4

		dc.l	S_MHITLER_WLK4
		dc.w	20
		dc.l	T_CHASE,A_TARGET
		dc.w	ST_MHITLER_WLK1

		dc.l	S_MHITLER_ATK1
		dc.w	28
		dc.l	T_NULL,A_NULL
		dc.w	ST_MHITLER_ATK2

		dc.l	S_MHITLER_ATK2
		dc.w	8
		dc.l	T_NULL,A_SHOOT
		dc.w	ST_MHITLER_ATK3

		dc.l	S_MHITLER_ATK3
		dc.w	8
		dc.l	T_NULL,A_SHOOT
		dc.w	ST_MHITLER_ATK4

		dc.l	S_MHITLER_ATK2
		dc.w	8
		dc.l	T_NULL,A_SHOOT
		dc.w	ST_MHITLER_ATK5

		dc.l	S_MHITLER_ATK3
		dc.w	8
		dc.l	T_NULL,A_SHOOT
		dc.w	ST_MHITLER_ATK6

		dc.l	S_MHITLER_ATK2
		dc.w	8
		dc.l	T_NULL,A_SHOOT
		dc.w	ST_MHITLER_ATK7

		dc.l	S_MHITLER_ATK3
		dc.w	8
		dc.l	T_NULL,A_SHOOT
		dc.w	ST_MHITLER_WLK1

		dc.l	S_MHITLER_DIE1
		dc.w	12
		dc.l	T_NULL,A_NULL
		dc.w	ST_MHITLER_DIE2

		dc.l	S_MHITLER_DIE2
		dc.w	12
		dc.l	T_NULL,A_NULL
		dc.w	ST_MHITLER_DIE3

		dc.l	S_MHITLER_DIE3
		dc.w	12
		dc.l	T_NULL,A_NULL
		dc.w	ST_MHITLER_DIE4

		dc.l	S_HITLER_WLK4
		dc.w	8
		dc.l	T_NULL,A_HITLERMORPH
		dc.w	ST_HITLER_WLK1

		dc.l	S_HITLER_WLK1
		dc.w	12
		dc.l	T_CHASE,A_TARGET
		dc.w	ST_HITLER_WLK2

		dc.l	S_HITLER_WLK2
		dc.w	8
		dc.l	T_CHASE,A_TARGET
		dc.w	ST_HITLER_WLK3

		dc.l	S_HITLER_WLK3
		dc.w	12
		dc.l	T_CHASE,A_TARGET
		dc.w	ST_HITLER_WLK4

		dc.l	S_HITLER_WLK4
		dc.w	8
		dc.l	T_CHASE,A_TARGET
		dc.w	ST_HITLER_WLK1

		dc.l	S_HITLER_ATK1
		dc.w	28
		dc.l	T_NULL,A_NULL
		dc.w	ST_HITLER_ATK2

		dc.l	S_HITLER_ATK2
		dc.w	8
		dc.l	T_NULL,A_SHOOT
		dc.w	ST_HITLER_ATK3

		dc.l	S_HITLER_ATK3
		dc.w	8
		dc.l	T_NULL,A_SHOOT
		dc.w	ST_HITLER_ATK4

		dc.l	S_HITLER_ATK2
		dc.w	8
		dc.l	T_NULL,A_SHOOT
		dc.w	ST_HITLER_ATK5

		dc.l	S_HITLER_ATK3
		dc.w	8
		dc.l	T_NULL,A_SHOOT
		dc.w	ST_HITLER_WLK1

		dc.l	S_HITLER_DTH1
		dc.w	16
		dc.l	T_NULL,A_SCREAM
		dc.w	ST_HITLER_DTH2

		dc.l	S_HITLER_DTH2
		dc.w	16
		dc.l	T_NULL,A_NULL
		dc.w	ST_HITLER_DTH3

		dc.l	S_HITLER_DTH3
		dc.w	120
		dc.l	T_NULL,A_THUD
		dc.w	ST_HITLER_DTH4

		dc.l	S_HITLER_DTH3
		dc.w	0
		dc.l	T_NULL,A_VICTORY
		dc.w	ST_HITLER_DTH4