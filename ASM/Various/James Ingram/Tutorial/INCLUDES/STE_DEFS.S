* macros and definitions for playing samples on the STe

enable	equ	$ffff8900

base_high	equ	$ffff8902
base_mid	equ	$ffff8904
base_low	equ	$ffff8906

address_high	equ	$ffff8908
address_mid	equ	$ffff890a
address_low	equ	$ffff890c

end_high	equ	$ffff890e
end_mid		equ	$ffff8910
end_low		equ	$ffff8912

sound_mode	equ	$ffff8920


micro_data	equ	$ffff8922
micro_mask	equ	$ffff8924

master_vol	equ	%10011000000
left_vol	equ	%10101000000
right_vol	equ	%10100000000
treble		equ	%10010000000
bass		equ	%10001000000
mix		equ	%10000000000


