****************************************************************************
*                                                                          *
*                                 LINEA.I                                  *
*                                                                          *
* This header file contains equates for use with the Atari LineA routines. *
* It contains the function numbers and the lineA variable offsets.         *
*                                                                          *
****************************************************************************
*
* LineA routines

A_Init          EQU     $A000
A_SetPixel      EQU     $A001
A_GetPixel      EQU     $A002
A_DrawLine      EQU     $A003
A_DrawHLine     EQU     $A004
A_FillRect      EQU     $A005
A_FillPoly      EQU     $A006
A_BitBlt        EQU     $A007
A_TextBlt       EQU     $A008
A_ShowMouse     EQU     $A009
A_HideMouse     EQU     $A00A
A_TransformMouse EQU    $A00B
A_UndrawSprite  EQU     $A00C
A_DrawSprite    EQU     $A00D

* LineA variable offsets

v_planes        EQU     0
v_lin_wr        EQU     2
CONTRL          EQU     4
INTIN           EQU     8
PTSIN           EQU     12
INTOUT          EQU     16
PTSOUT          EQU     20
_FG_BP_1        EQU     24
_FG_BP_2        EQU     26
_FG_BP_3        EQU     28
_FG_BP_4        EQU     30
_LSTLIN         EQU     32
_LN_MASK        EQU     34
_WRT_MODE       EQU     36
_X1             EQU     38
_Y1             EQU     40
_X2             EQU     42
_Y2             EQU     44
_patptr         EQU     46
_patmsk         EQU     50
_multifill      EQU     52
_CLIP           EQU     54
_XMN_CLIP       EQU     56
_YMN_CLIP       EQU     58
_XMX_CLIP       EQU     60
_YMX_CLIP       EQU     62
_XACC_DDA       EQU     64
_DDA_INC        EQU     66
_T_SCLSTS       EQU     68
_MONO_STATUS    EQU     70
_SOURCEX        EQU     72
_SOURCEY        EQU     74
_DESTX          EQU     76
_DESTY          EQU     78
_DELX           EQU     80
_DELY           EQU     82
_FBASE          EQU     84
_FWIDTH         EQU     88
_STYLE          EQU     90
_LITEMASK       EQU     92
_SHEWMASK       EQU     94
_WEIGHT         EQU     96
_R_OFF          EQU     98
_L_OFF          EQU     100
_SCALE          EQU     102
_CHUP           EQU     104
_TEXT_FG        EQU     106
_scrchp         EQU     108
_scrpt2         EQU     112
_TEXT_BG        EQU     114
_COPYTRAN       EQU     116
_SEEDABORT      EQU     118

* End of LINE.I
