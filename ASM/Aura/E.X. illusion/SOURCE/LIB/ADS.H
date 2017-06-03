	IFND	_ADS
_ADS	EQU	$0110

_ads_baseadress:
		INLINE	"ads.inc"

ADS_INSTALL	EQU	_ads_baseadress
ADS_TRA_PRG	EQU	_ads_baseadress+4

; ADS_TRA_PRG:
ADS_DSP_PRG	EQUR	a0	; DSP-Proggy im ADS-Format.
	ENDIF