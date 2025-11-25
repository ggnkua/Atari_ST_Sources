* ----- Attack Wave Source File ----- *
* From Marvin's Attack Wave Generator *

Paralax_Event_Table
;	ds.l	$12

	ds.l	$0e
	Dc.l	.Car

	dc.l	.E3D
	ds.l	$6
	dc.l	.E36
	ds.l	$2
	dc.l	.E33
	ds.l	$1
	dc.l	.E31
	ds.l	$2
	dc.l	.E2E
	dc.l	.E2D
	ds.l	$2
	dc.l	.E2A
	ds.l	$2
	dc.l	.E27
	ds.l	$2
	dc.l	.E24
	ds.l	$4
	dc.l	.E1F
	ds.l	$1
	dc.l	.E1D
	ds.l	$3
	dc.l	.E19
	ds.l	$1
	dc.l	.E17
	ds.l	$17
	Ds.l	6

	dc.l	-1

.Car	V_Ent	20,75,480,-165,Car_Seq
	Dc.w	-1

.E3D	V_Ent	1,254,21,-79,pstaystill
	dc.w	-1
.E36	V_Ent	1,254,87,-22,P1tankright
	V_Ent	1,254,147,-22,P1tankright
	V_Ent	1,254,208,-22,P1tankright
	V_Ent	1,254,-57,-22,P1tankright
	dc.w	-1
.E33	V_Ent	1,254,240,-22,P1tankleft
	V_Ent	1,254,280,-22,P1tankleft
	V_Ent	1,254,320,-22,P1tankleft
	V_Ent	1,254,360,-22,P1tankleft
	V_Ent	1,254,480,-22,P1tankleft
	dc.w	-1
.E31	V_Ent	1,254,166,-27,P1tankupang
	V_Ent	1,254,222,-27,P1tankupang
	dc.w	-1
.E2E	V_Ent	1,254,337,-45,P1tankleft
	V_Ent	1,254,447,-45,P1tankleft
	dc.w	-1
.E2D	V_Ent	1,254,136,-32,pstaystill
	V_Ent	1,254,383,-48,P1tankleft
	V_Ent	1,254,493,-47,P1tankleft
	dc.w	-1
.E2A	V_Ent	1,254,46,-54,pstaystill
	dc.w	-1
.E27	V_Ent	1,254,341,-44,P1tankdownang
	V_Ent	1,254,382,-44,P1tankdownang
	V_Ent	1,254,123,-55,P1tankright
	V_Ent	1,254,45,-55,P1tankright
	dc.w	-1
.E24	V_Ent	8,78,464,-58,ptrainleft
	V_Ent	5,80,509,-58,ptrainleft
	V_Ent	5,80,538,-58,ptrainleft
	dc.w	-1
.E1F	V_Ent	8,78,464,-59,ptrainleft
	V_Ent	5,80,509,-59,ptrainleft
	V_Ent	5,80,538,-59,ptrainleft
	dc.w	-1
.E1D	V_Ent	1,254,115,-83,P1tankr2
	V_Ent	1,254,345,-85,P1tank2
	V_Ent	1,254,65,-83,P1tankr2
	V_Ent	1,254,15,-83,P1tankr2
	V_Ent	1,254,395,-85,P1tank2
	V_Ent	1,254,445,-85,P1tank2
	dc.w	-1
.E19	V_Ent	1,254,264,-40,P1tankr2
	V_Ent	1,254,228,-40,P1tank2
	dc.w	-1
.E17	V_Ent	1,254,459,-78,P1tankdownang
	dc.w	-1


ptrainleft
	Add_Train
	Paralax_vector_Move	192,0,3,230
	End_Seq

pstaystill
	Stop_Anim
	Paralax_vector_Move	31,0,0,300
	End_Seq

P1tankright
	Stop_Anim
	Paralax_vector_Move	64,0,0,30
	Start_Anim
	Paralax_vector_Move	64,0,1,130
	Stop_Anim
	Paralax_vector_Move	32767,0,0,100
	End_Seq

P1tankleft
	Stop_Anim
	Paralax_vector_Move	192,0,0,30
	Start_Anim
	Paralax_vector_Move	192,0,1,170
	Stop_Anim
	Paralax_vector_Move	32767,0,0,100
	End_Seq

P1tankupang
	Stop_Anim
	Paralax_vector_Move	31,0,0,30
	Start_Anim
	Paralax_vector_Move	31,0,1,50
	Stop_Anim
	Paralax_vector_Move	32767,0,0,200
	End_Seq

P1tankdownang
	Paralax_vector_Move	160,0,1,88
	Stop_Anim
	Paralax_vector_Move	32767,0,0,200
	End_Seq

P1tank2
	Stop_Anim
	Paralax_vector_Move	192,0,0,30
	Start_Anim
	Paralax_vector_Move	192,0,1,100
	Stop_Anim
	Paralax_vector_Move	32767,0,0,150
	End_Seq

P1tankr2
	Stop_Anim
	Paralax_vector_Move	64,0,0,30
	Start_Anim
	Paralax_vector_Move	64,0,1,100
	Stop_Anim
	Paralax_vector_Move	32767,0,0,150
	End_Seq

Car_Seq
	Paralax_vector_Move	192,0,0,110
	Paralax_vector_Move	192,0,5,200
	End_Seq

Paralax_Event_Table2
	ds.l	$0b
;	ds.l	$11
	dc.l	.E3E
	dc.l	.E3D
	ds.l	$1
	dc.l	.E3B
	dc.l	.E3A
	ds.l	$1
	dc.l	.E38
	ds.l	$1
	dc.l	.E36
	dc.l	.E35
	dc.l	.E34
	dc.l	.E33
	dc.l	.E32
	dc.l	.E31
	dc.l	.E30
	dc.l	.E2F
	dc.l	.E2E
	dc.l	.E2D
	dc.l	.E2C
	dc.l	.E2B
	dc.l	.E2A
	dc.l	.E29
	dc.l	.E28
	dc.l	.E27
	dc.l	.E26
	dc.l	.E25
	dc.l	.E24
	dc.l	.E23
	dc.l	.E22
	dc.l	.E21
	dc.l	.E20
	dc.l	.E1F
	dc.l	.E1E
	dc.l	.E1D
	dc.l	.E1C
	dc.l	.E1B
	dc.l	.E1A
	dc.l	.E19
	dc.l	.E18
	dc.l	.E17
	dc.l	.E16
	ds.l	$16
	dc.l	-1

.E3E	V_Ent	1,254,139,-51,p2staystill
	dc.w	-1
.E3D	V_Ent	5,83,482,-4,p2trainup
	V_Ent	5,85,505,18,p2trainup
	V_Ent	5,85,524,36,p2trainup
	dc.w	-1
.E3B	V_Ent	1,254,90,-52,p2staystill
	dc.w	-1
.E3A	V_Ent	1,68,282,-32,DARTTHING
	dc.w	-1
.E38	V_Ent	1,254,104,-54,p2stankdown
	dc.w	-1
.E36	V_Ent	1,254,72,-54,p2stankdown
	V_Ent	1,254,480,12,p2stankup
	V_Ent	1,68,202,-32,DARTTHING
	V_Ent	1,68,357,-32,DARTTHING
	dc.w	-1
.E35	V_Ent	1,68,152,-34,DARTTHING
	V_Ent	1,68,326,-31,DARTTHING
	dc.w	-1
.E34	V_Ent	1,254,36,-54,p2stankdown
	V_Ent	1,68,177,-30,DARTTHING
	V_Ent	1,68,401,-33,DARTTHING
	dc.w	-1
.E33	V_Ent	1,254,480,62,p2stankup
	V_Ent	1,68,211,-33,DARTTHING
	V_Ent	1,68,316,-49,DARTTHING
	dc.w	-1
.E32	V_Ent	1,254,1,-54,p2stankdown
	V_Ent	1,68,275,-33,DARTTHING
	V_Ent	1,68,36,-54,DARTTHING
	dc.w	-1
.E31	V_Ent	1,68,204,-31,DARTTHING
	V_Ent	1,68,273,-47,DARTTHING
	dc.w	-1
.E30	V_Ent	1,254,480,110,p2stankup
	V_Ent	1,68,336,-32,DARTTHING
	V_Ent	1,68,49,-32,DARTTHING
	dc.w	-1
.E2F	V_Ent	1,68,94,-33,DARTTHING
	V_Ent	1,68,134,-24,DARTTHING
	dc.w	-1
.E2E	V_Ent	1,68,268,-32,DARTTHING
	V_Ent	1,68,404,-41,DARTTHING
	dc.w	-1
.E2D	V_Ent	1,68,389,-29,DARTTHING
	V_Ent	1,68,40,-46,DARTTHING
	dc.w	-1
.E2C	V_Ent	1,254,335,-65,p2stankdown
	V_Ent	1,68,203,-30,DARTTHING
	V_Ent	1,68,301,-23,DARTTHING
	V_Ent	1,68,56,-49,DARTTHING
	dc.w	-1
.E2B	V_Ent	1,68,201,-30,DARTTHING
	V_Ent	1,68,51,-45,DARTTHING
	V_Ent	1,68,357,-49,DARTTHING
	dc.w	-1
.E2A	V_Ent	1,68,319,-36,DARTTHING
	V_Ent	1,68,135,-27,DARTTHING
	V_Ent	1,68,257,-24,DARTTHING
	dc.w	-1
.E29	V_Ent	1,254,288,-65,p2stankdown
	V_Ent	1,68,55,-30,DARTTHING
	dc.w	-1
.E28	V_Ent	1,68,125,-32,DARTTHING
	V_Ent	1,68,276,-49,DARTTHING
	dc.w	-1
.E27	V_Ent	1,68,126,-32,DARTTHING
	V_Ent	1,68,255,-49,DARTTHING
	dc.w	-1
.E26	V_Ent	1,254,238,-65,p2stankdown
	V_Ent	1,68,387,-37,DARTTHING
	V_Ent	1,68,113,-45,DARTTHING
	dc.w	-1
.E25	V_Ent	1,68,91,-31,DARTTHING
	V_Ent	1,68,350,-37,DARTTHING
	dc.w	-1
.E24	V_Ent	1,68,340,-28,DARTTHING
	V_Ent	1,68,97,-49,DARTTHING
	dc.w	-1
.E23	V_Ent	1,254,190,-65,p2stankdown
	V_Ent	1,68,190,-33,DARTTHING
	V_Ent	1,68,383,-49,DARTTHING
	V_Ent	1,68,16,-49,DARTTHING
	dc.w	-1
.E22	V_Ent	1,68,112,-32,DARTTHING
	V_Ent	1,68,278,-46,DARTTHING
	dc.w	-1
.E21	V_Ent	1,68,239,-31,DARTTHING
	V_Ent	1,68,88,-41,DARTTHING
	dc.w	-1
.E20	V_Ent	1,254,143,-65,p2stankdown
	V_Ent	1,68,298,-47,DARTTHING
	dc.w	-1
.E1F	V_Ent	1,68,203,-33,DARTTHING
	dc.w	-1
.E1E	V_Ent	1,68,119,-31,DARTTHING
	dc.w	-1
.E1D	V_Ent	1,254,95,-65,p2stankdown
	V_Ent	1,68,310,-30,DARTTHING
	V_Ent	1,68,43,-33,DARTTHING
	dc.w	-1
.E1C	V_Ent	1,68,175,-33,DARTTHING
	dc.w	-1
.E1B	V_Ent	1,68,65,-39,DARTTHING
	dc.w	-1
.E1A	V_Ent	1,68,219,-25,DARTTHING
	dc.w	-1
.E19	V_Ent	1,68,52,-38,DARTTHING
	V_Ent	1,68,385,-31,DARTTHING
	dc.w	-1
.E18	V_Ent	1,68,189,-30,DARTTHING
	V_Ent	1,68,44,-42,DARTTHING
	dc.w	-1
.E17	V_Ent	1,68,133,-33,DARTTHING
	dc.w	-1
.E16	V_Ent	1,68,294,-45,DARTTHING
	dc.w	-1

p2staystill
	Stop_Anim
	Paralax_Vector_Move	96,0,0,250
	End_Seq

p2stankdown
	Paralax_Vector_Move	95,0,1,381
	End_Seq

p2stankup
	Stop_Anim
	Paralax_Vector_Move	224,0,0,30
	Start_Anim
	Paralax_Vector_Move	224,0,2,349
	End_Seq

p2trainup
	Add_Train
	Paralax_Vector_Move	224,0,0,30
	Paralax_Vector_Move	224,0,2,400
	End_Seq

DARTTHING
	Vector_Move	128,0,3,15
	Arrow_Home	$80,50
	End_Seq

