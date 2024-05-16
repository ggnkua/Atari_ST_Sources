;=======================================================*
;	DSP constants: updated 12/06/97			*
;=======================================================*
;	Used by *both* 68k and DSP56k sources!		*
;-------------------------------------------------------*

;-------------------------------------------------------*
;	Max viewport size (bigger = needs DSP ram!)	*
;-------------------------------------------------------*

max_columns		=	320		; max viewport width
max_rows		=	200		; max viewport height

min_distance		=	12		; z-clipping plane

;-------------------------------------------------------*
;	Host -> DSP command set				*
;-------------------------------------------------------*

wall_command		=	0
upper_command		=	1
lower_command		=	2
resize_command		=	3
newscene_command	=	4
newssector_command	=	5
getssector_command	=	6
nodeincone_command	=	7
rotatemap_command	=	8
linear_command		=	9
perspected_command	=	10
setluminance_command	=	11
projectwall_command	=	12
projectsprite_command	=	13
trans_command		=	14

;-------------------------------------------------------*
;	DSP status report codes				*
;-------------------------------------------------------*

end_code		=	0
wall_code		=	1
startfloor_code		=	2
endfloor_code		=	3
startceiling_code	=	4
endceiling_code		=	5

invisible_code		=	0
visible_code		=	1

;-------------------------------------------------------*
