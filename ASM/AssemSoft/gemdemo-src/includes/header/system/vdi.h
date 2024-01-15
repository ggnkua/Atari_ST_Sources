	ifnd	VDI_H
VDI_H:		set 1
 ********************************
 * VDI function codes (opcodes) *
 ********************************
V_OPENWK		= 1	Open workstation	
V_CLSWK			= 2	Close workstation
V_CLRWK			= 3	Clear workstation
V_UPDWK			= 4	Update workstation
V_ESCAPES		= 5	Variou escape functions
V_PLINE			= 6	polyline
V_PMARKER		= 7	polymarker
V_GTEXT			= 8	Text
V_FILLAREA		= 9	Filled area
V_CALLARRAY		= 10	Call array
V_GDP			= 11	Bar,arc,pie,circle,ellipse,round rects, etc
VST_HEIGHT		= 12	Set character height
VST_ROTATION		= 13	Set character baseline vector
VS_COLOR		= 14	Set colour representation
VSL_TYPE		= 15	Set polyline type
VSL_WIDTH		= 16	Set polyline width
VSL_COLOR		= 17	Set ployline colour
VSM_TYPE		= 18	Set polymarker type
VSM_HEIGHT		= 19	Set polymarker height
VSM_COLOR		= 20	Set ploymarker colour
VST_FONT		= 21	Set text face
VST_COLOR		= 22	Set text colour
VSF_INTERIOR		= 23	Set fill interior style
VSF_STYLE		= 24	Set fill style index
VSF_COLOR		= 25	Set fill colour index
VQ_COLOR		= 26	Inquire colour representation
VQ_CELLARRAY		= 27	Inquire cell array
VI_LOCATOR		= 28	input locator, request/sample
VI_VALUATOR		= 29	input valuator, request/sample
VI_CHOICE		= 30	input choice, request/sample
VI_STRING		= 31	input string, request/sample
VSWR_MODE		= 32	set writing mode
VSIN_MODE		= 33	set input mode

VQL_ATTRIBUTES		= 35	Inquire polyline attributes
VQM_ATTRIBUTES		= 36	Inquire plymarker attributes
VQF_ATTRIBUTES		= 37	Inquire fill area attributes
VQT_ATTRIBUTES		= 38	Inquire graphic text
VST_ALIGNMENT		= 39	Set text alignment

V_OPNVWK		= 100	Open virtual workstation
V_CLSVWK		= 101	Close virtual workstation
VQ_EXTND		= 102	Extended inquire
V_CONTOURFILL		= 103	Contour fill
VSF_PERIMETER		= 104	Set fill perimeter
V_GET_PIXEL		= 105	Get pixel
VST_EFFECTS		= 106	Set text effects
VST_POINT		= 107	Set character cell height
VSL_ENDS		= 108	Set polyline end markers
VRO_CPYFM		= 109	Copy rastor
VR_TRN_FM		= 110	Transform form
VSC_FORM		= 111	Set mouse form
VSF_UDPAT		= 112	Set user-defined fill pattern
VSL_UDSTY		= 113	User defined line pattern
VR_RECFL		= 114	Fill rectangle
VQIN_MODE		= 115	Inquire input mode
VQT_EXTENT		= 116	Inquire text extent
VQT_WIDTH		= 117	Inquire char cell width
VEX_TIMV		= 118	Exchange timer interrupt vector
VST_LOAD_FONTS		= 119	Load fonts
VST_UNLOAD_FONTS	= 120	Unload fonts
VRT_CPYFM		= 121	Copy rastor transparent
V_SHOW_C		= 122	Show cursor
V_HIDE_C		= 123	Hide cursor
VQ_MOUSE		= 124	Sample mouse button
VEX_BUTV		= 125	Exchange button change vector
VEX_MOTV		= 126	Exchange movement vector
VEX_CURV		= 127	Exchange cursor change vector
VQ_KEY_S		= 128	Sample keyboard state
VS_CLIP			= 129	Set clipping rectangle
VQT_NAME		= 130	Inquire face name and index
VQT_FONTINFO		= 131	Inquire current face information
VQT_FONTHEADER		= 232

VQT_TRACKKERN		= 234

**** Fill interiors ****
FIS_HOLLOW:		= 0
FIS_SOLID:		= 1
FIS_PATTERN:		= 2
FIS_HATCH:		= 3
FIS_USER:		= 4

**** Font attributes
THICKENED:		= 0
LIGHT:			= 1
SKEWED:			= 2
UNDERLINED:		= 3
OUTLINED:		= 4
SHADOWED:		= 5

******** MEMORY FORM DEFINITION BLOCK *****
*Memory Form Definition Block*
		rsset 0
MFDB_addr	rs.l 1
MFDB_width	rs.w 1	;4
MFDB_height	rs.w 1	;6
MFDB_wdwidth	rs.w 1	;8
MFDB_stand	rs.w 1	;10
MFDB_planes	rs.w 1	;12
MFDB_resrv0	rs.w 1 	;14
MFDB_resrv1	rs.w 1 	;16
MFDB_resrv2	rs.w 1 	;18
MFDB_resrv3	rs.w 1 	;20

MFDB_ssize	= __RS


*********** NVDI STUFF ***********

;VQT_NAME()
;== High byte (flag) returned by VQT_NAME in intout [34] if extended mode exists (35 or more entries in intout)
;ff_proportional	= 0
ff_monospaced	= 0

;== Low byte (flags)  returned by VQT_NAME in intout[34] if extended mode exists (35 or more entries in intout)
ft_bitmap	= 0
ft_speedo	= 1
ft_truetype	= 2
ft_type1	= 3

*********** SPEEDO FONTHEADER STRUCTURE *****************
;Flags for FH_FFLGS
FHFF_EXTENDED	= 0

;=== Flags for FH_CFLGS
FHCF_ITALIC	= 0
FHCF_MONOSPACED	= 1
FHCF_SERIF	= 2
FHCF_DISPLAY	= 3

;=== Flags for FH_FCFLG
FHFC_IGNORE	= 0
FHFC_SERIF	= 1
FHFC_SANSSERIF	= 2
FHFC_MONOSPACED	= 3
FHFC_SCRIPT	= 4
FHFC_DECORATIVE	= 5

;=== Value meanings for FH_FFCLS
FHFF_CONDENSED	= 4
FHFF_SEMICONDENSED = 6
FHFF_NORMAL	= 8
FHFF_SEMIEXPANDED = 10
FHFF_EXPANDED	= 12

	rsset 0
FH_FMTID	rs.l 2	;Format ID
FH_FFSIZ	rs.l 1	;Font file size in bytes
FH_MFBFS	rs.l 1	;Minimum font buffer size
FH_MCBFS	rs.w 1	;Minimum character buffer size
FH_HDSIZ	rs.w 1	;Header size
FH_FNTID	rs.w 1	;Font ID
FH_FVRSN	rs.w 1	;Font Version number
FH_FNTNM	rs.b 70	;Full font name
FH_MDATE	rs.b 10	;Manufacturing date
FH_CSTNM	rs.b 66	;Character set name
FH_VNDID	rs.w 1	;Vendor  ID
FH_CSTID	rs.w 1	;Character set ID
FH_CPYRT	rs.b 78	;Copyright notice
FH_NCICS	rs.w 1	;Number of character indexes in character set
FH_TNCIF	rs.w 1	;Total number of character indexes in font
FH_INDFC	rs.w 1	;Index of 1st character
FH_NKTKS	rs.w 1	;Number of kerning tracks
FH_NKPRS	rs.w 1	;Number of kerning pairs
FH_FFLGS	rs.b 1	;Font Flags
FH_CFLGS	rs.b 1	;Classification flags
FH_FCFLG	rs.b 1	;Family classification
FH_FFCLS	rs.b 1	;Font form classification
FH_SFNTN	rs.b 32	;Short font name
FH_SFACN	rs.b 16	;Short Face name
FH_FNTFM	rs.b 14	;Font form
FH_IANGL	rs.w 1	;Italic angle
FH_ORUPM	rs.w 1	;ORUs per Em's
FH_WWRDS	rs.w 1	;Width of word space
FH_WEMSP	rs.w 1	;Width of Em space
FH_WENSP	rs.w 1	;Width of En space
FH_WTHNS	rs.w 1	;Width of thin space
FH_WFIGS	rs.w 1	;Width of figure space
FH_FXMIN	rs.w 1	;Min X coord in font
FH_FYMIN	rs.w 1	;Min Y coord in font
FH_FXMAX	rs.w 1	;Max X coord in font
FH_FYMAX	rs.w 1	;Max Y coord in font
FH_ULPOS	rs.w 1	;Underline position
FH_ULTHC	rs.w 1	;Underline thickness
FH_SCAPS	rs.b 6	;Small Caps
FH_DSPRS	rs.b 6	;Display superiors
FH_FSPRS	rs.b 6	;Footnote superiors
FH_ASPRS	rs.b 6	;Alpha superiors
FH_CIFRS	rs.b 6	;Chemical superiors
FH_SNRTR	rs.b 6	;Small numerations
FH_SDNRT	rs.b 6	;Small denominators
FH_MNRTR	rs.b 6	;Medium Numerators
FH_MDNRT	rs.b 6	;Medium denominators
FH_LNRTR	rs.b 6	;Large numerators
FH_LDNRT	rs.b 6	;Large denominators


	endc	;VDI_H
*EOF*
