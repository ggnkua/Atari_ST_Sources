;Keyboard definitions for event_multi call routine

;Keys a-z

key_a   equ     $1E61
key_b   equ     $3062
key_c   equ     $2E63
key_d   equ     $2064
key_e   equ     $1265
key_f   equ     $2166
key_g   equ     $2267
key_h   equ     $2368
key_i   equ     $1769
key_j   equ     $246A
key_k   equ     $256B
key_l   equ     $266C
key_m   equ     $326D
key_n   equ     $316E
key_o   equ     $186F
key_p   equ     $1970
key_q   equ     $1071
key_r   equ     $1372
key_s   equ     $1F73
key_t   equ     $1474
key_u   equ     $1675
key_v   equ     $2F76
key_w   equ     $1177
key_x   equ     $1D78
key_y   equ     $1579
key_z   equ     $2C7A

;SHIFT+keys a-z

key_A   equ     $1E41
key_B   equ     $3042
key_C   equ     $2E43
key_D   equ     $2044
key_E   equ     $1245
key_F   equ     $2146
key_G   equ     $2247
key_H   equ     $2348
key_I   equ     $1749
key_J   equ     $244A
key_K   equ     $254B
key_L   equ     $264C
key_M   equ     $324D
key_N   equ     $314E
key_O   equ     $184F
key_P   equ     $1950
key_Q   equ     $1051
key_R   equ     $1352
key_S   equ     $1F53
key_T   equ     $1454
key_U   equ     $1655
key_V   equ     $2F56
key_W   equ     $1157
key_X   equ     $2D58
key_Y   equ     $1559
key_Z   equ     $2C5A

;CONTROL+ keys A-Z

ctrl_key_A      equ     $1E01
ctrl_key_B      equ     $3002
ctrl_key_C      equ     $2E03
ctrl_key_D      equ     $2004
ctrl_key_E      equ     $1205
ctrl_key_F      equ     $2106
ctrl_key_G      equ     $2207
ctrl_key_H      equ     $2308
ctrl_key_I      equ     $1709
ctrl_key_J      equ     $240A
ctrl_key_K      equ     $250B
ctrl_key_L      equ     $260C
ctrl_key_M      equ     $320D
ctrl_key_N      equ     $310E
ctrl_key_O      equ     $180F
ctrl_key_P      equ     $1910
ctrl_key_Q      equ     $1011
ctrl_key_R      equ     $1312
ctrl_key_S      equ     $1F13
ctrl_key_T      equ     $1414
ctrl_key_U      equ     $1615
ctrl_key_V      equ     $2F16
ctrl_key_W      equ     $1117
ctrl_key_X      equ     $2D18
ctrl_key_Y      equ     $1519
ctrl_key_Z      equ     $2C1A

;ALTERNATE+ keys A-Z

alt_key_A       equ     $1E00
alt_key_B       equ     $3000
alt_key_C       equ     $2E00
alt_key_D       equ     $2000
alt_key_E       equ     $1200
alt_key_F       equ     $2100
alt_key_G       equ     $2200
alt_key_H       equ     $2300
alt_key_I       equ     $1700
alt_key_J       equ     $2400
alt_key_K       equ     $2500
alt_key_L       equ     $2600
alt_key_M       equ     $3200
alt_key_N       equ     $3100
alt_key_O       equ     $1800
alt_key_P       equ     $1900
alt_key_Q       equ     $1000
alt_key_R       equ     $1300
alt_key_S       equ     $1F00
alt_key_T       equ     $1400
alt_key_U       equ     $1600
alt_key_V       equ     $2F00
alt_key_W       equ     $1100
alt_key_X       equ     $2D00
alt_key_Y       equ     $1500
alt_key_Z       equ     $2C00

;Numeric keys 1-0 (main keyboard only)

key_1   equ     $0231
key_2   equ     $0332
key_3   equ     $0433
key_4   equ     $0534
key_5   equ     $0635
key_6   equ     $0736
key_7   equ     $0837
key_8   equ     $0938
key_9   equ     $0a39
key_0   equ     $0b30   

;SHIFT+numeric keys 1-0 (main keyboard only)

shft_key_1      equ     $0221
shft_key_2      equ     $0340
shft_key_3      equ     $0423
shft_key_4      equ     $0524
shft_key_5      equ     $0625
shft_key_6      equ     $075e
shft_key_7      equ     $0826
shft_key_8      equ     $092a
shft_key_9      equ     $0a28
shft_key_0      equ     $0b29   

;CONTROL+numeric keys 1-0 (main keyboard only)

ctrl_key_1      equ     $0211
ctrl_key_2      equ     $0300
ctrl_key_3      equ     $0413
ctrl_key_4      equ     $0514
ctrl_key_5      equ     $0615
ctrl_key_6      equ     $071e
ctrl_key_7      equ     $0817
ctrl_key_8      equ     $0918
ctrl_key_9      equ     $0a19
ctrl_key_0      equ     $0b10   

;ALTERNATE+numeric keys 1-0 (main keyboard only)

alt_key_1       equ	$7800
alt_key_2       equ	$7900
alt_key_3       equ	$7a00
alt_key_4       equ	$7b00
alt_key_5       equ	$7c00
alt_key_6       equ	$7d00
alt_key_7	equ	$7e00
alt_key_8	equ	$7f00
alt_key_9	equ	$8000
alt_key_0	equ	$8100

;Miscellaneous keys

key_help	equ	$6200
key_undo	equ	$6100
key_ins	equ	$5200
key_shft_ins	equ	$5230
key_home	equ	$4700
key_up	equ	$4800
key_down	equ	$5000
key_right	equ	$4b00
key_left	equ	$4d00
key_space	equ	$3920
key_escape	equ	$011b
key_back	equ	$0e08
key_delete	equ	$537f
key_return	equ	$1c0d
key_tab	equ	$0f09

shft_home	equ	$4737
shft_up	equ	$4838
shft_down	equ	$5032
shft_left	equ	$4d36
shft_right	equ	$4b34

ctrl_home	equ	$7700
ctrl_right	equ	$7300
ctrl_left	equ	$7400
ctrl_space	equ	$3900
ctrl_delete	equ	$531f
ctrl_return	equ	$1c0a

;Control pad keys

pad_lpar	equ	$6328
pad_rpar	equ	$6429
pad_slash	equ	$652f
pad_star	equ	$662a
pad_minus	equ	$4a2d
pad_plus	equ	$4e2b
pad_.	equ	$712e
pad_enter	equ	$720d
pad_0	equ	$7030
pad_1	equ	$6d31
pad_2	equ	$6e32
pad_3	equ	$6f33
pad_4	equ	$6a34
pad_5	equ	$6b35
pad_6	equ	$6c36
pad_7	equ	$6737
pad_8	equ	$6838
pad_9	equ	$6939

ctrl_pad_lpar	equ	$6308
ctrl_pad_rpar	equ	$6409
ctrl_pad_slash	equ	$650f
ctrl_pad_star	equ	$660a
ctrl_pad_minus	equ	$4a1f
ctrl_pad_plus	equ	$4e0b
ctrl_pad_.	equ	$710e
ctrl_pad_enter	equ	$720a
ctrl_pad_0	equ	$7010
ctrl_pad_1	equ	$6d11
ctrl_pad_2	equ	$6e00
ctrl_pad_3	equ	$6f13
ctrl_pad_4	equ	$6a14
ctrl_pad_5	equ	$6b15
ctrl_pad_6	equ	$6c1e
ctrl_pad_7	equ	$6717
ctrl_pad_8	equ	$6818
ctrl_pad_9	equ	$6919

;Function keys

f_key_1	equ	$3b00
f_key_2	equ	$3c00
f_key_3	equ	$3d00
f_key_4	equ	$3e00
f_key_5	equ	$3f00
f_key_6	equ	$4000
f_key_7	equ	$4100
f_key_8	equ	$4200
f_key_9	equ	$4300
f_key_10	equ	$4400

shft_f_key_1	equ	$5400
shft_f_key_2	equ	$5500
shft_f_key_3	equ	$5600
shft_f_key_4	equ	$5700
shft_f_key_5	equ	$5800
shft_f_key_6	equ	$5900
shft_f_key_7	equ	$5a00
shft_f_key_8	equ	$5b00
shft_f_key_9	equ	$5c00
shft_f_key_10	equ	$5d00