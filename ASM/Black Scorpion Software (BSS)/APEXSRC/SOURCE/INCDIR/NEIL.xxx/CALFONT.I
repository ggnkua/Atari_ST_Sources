
; Calamus Font (CFN) File Structures

CFN_Header		= 0
CFN_AddSpace		= $1a

CFN_FontName		= $20
CFN_Creator		= $3a
CFN_Company1		= $58
CFN_Company2		= $72

CFN_BitImageWidth	= $90
CFN_BitImageHeight	= $92
CFN_BitImage		= $94

CFN_CharHeight		= $1d6
CFN_CharWidth		= $1d8
CFN_TopLine		= $1da
CFN_Ascender		= $1dc
CFN_HalfLine		= $1de
CFN_BaseLine		= $1e0
CFN_Descender		= $1e2
CFN_BottomLine		= $1e4
CFN_LeftLine		= $1e6
CFN_MiddleLine		= $1e8
CFN_RightLine		= $1ea

CFN_DisplayableChars	= $2b2
CFN_Kerning		= $2b4
CFN_KernLeft		= 0	(Offsets to the byte values for each char)
CFN_KernRight		= 8
CFN_KerningShift	= 4	(shift to get to a char's kern offset)

CFN_NumberChars		= $10e0
CFN_CharOffsets		= $10bc	(list of longword offsets from CharData)
CFN_BlankChar		= -2	(longword value for blank chars)

CFN_CharDataSize	= $143e
CFN_CharData		= $1442

CFN_WidthTableOffset	= 4	(offset skip after data block)
CFN_WidthMinX		= 0	(offsets to x/y bytes in each word)
CFN_WidthMinY		= 1
CFN_WidthShift		= 6	(to multiply byte value into 0-16383)

; Path control codes

CFN_PathStart	= 0
CFN_PathEnd	= $f
CFN_PathLine	= 1
CFN_PathBezier	= 2

