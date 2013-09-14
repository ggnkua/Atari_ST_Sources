/* MN_TOOLS.H
 * ================================================================
 * DESCRIPTION: structures and defines for menu.c
 */

/* STRUCTURES
 * ================================================================
 */
typedef struct _mrets
{
  WORD x;
  WORD y;
  WORD buttons;
  WORD kstate;
}MRETS;

#if 0     /* Found in AES.H */
typedef struct _moblk
{
  WORD m_x;
  WORD m_y;
  WORD m_w;
  WORD m_h;
  WORD m_out;
}MOBLK;
#endif

/*
 * Object bitfield structures
 */
typedef struct sColorword
{
/*
#if HIBIT_1ST
	unsigned cborder : 4;
	unsigned ctext	 : 4;
	unsigned replace : 1;
	unsigned pattern : 3;
	unsigned cfill	 : 4;
#else
*/
	unsigned cfill	 : 4;
	unsigned pattern : 3;
	unsigned replace : 1;
	unsigned ctext	 : 4;
	unsigned cborder : 4;
/*
#endif
*/
} Colorword;


typedef struct sObInfo
{
	BYTE   letter;
	BYTE   border;
	Colorword	c;
} ObInfo;



/*
 * Object structure access macros ( `tree' must be declared OBJECT * )
 * ----------------------------------------------------------------------
 */
#define ObNext(obj) 	( tree[(obj)].ob_next )
#define ObHead(obj) 	( tree[(obj)].ob_head )
#define ObTail(obj) 	( tree[(obj)].ob_tail )
#define ObType(obj) 	( tree[(obj)].ob_type )
#define ObFlags(obj)	( tree[(obj)].ob_flags )
#define ObState(obj)	( tree[(obj)].ob_state )
#define ObSpec(obj) 	( tree[(obj)].ob_spec )
#define ObIndex(obj)    ( tree[(obj)].ob_spec )

/* ObSpecs for ObBOX, ObIBOX, ObBOXCHAR */
#define ObChar(obj) 	( (*(ObInfo *)&ObSpec(obj)).letter )
#define ObBorder(obj)	( (*(ObInfo *)&ObSpec(obj)).border )
#define ObCBorder(obj)	( (*(ObInfo *)&ObSpec(obj)).c.cborder )
#define ObCText(obj)	( (*(ObInfo *)&ObSpec(obj)).c.ctext )
#define ObReplace(obj)	( (*(ObInfo *)&ObSpec(obj)).c.replace )
#define ObPattern(obj)	( (*(ObInfo *)&ObSpec(obj)).c.pattern )
#define ObCFill(obj)	( (*(ObInfo *)&ObSpec(obj)).c.cfill )

/* TEDINFO access macros, for ObTEXT, ObBOXTEXT, ObFTEXT, ObFBOXTEXT */
#define _TE(obj)	( (TEDINFO *)ObSpec(obj) )
#define TedText(obj)	( _TE(obj)->te_ptext )
#define TedTemplate(obj)( _TE(obj)->te_ptmplt )
#define TedValid(obj)	( _TE(obj)->te_pvalid )
#define TedFont(obj)	( _TE(obj)->te_font )
#define TedJust(obj)	( _TE(obj)->te_just )

#define TedCBorder(obj) ( (*(Colorword *)&_TE(obj)->te_color).cborder )
#define TedCText(obj)	( (*(Colorword *)&_TE(obj)->te_color).ctext )
#define TedReplace(obj) ( (*(Colorword *)&_TE(obj)->te_color).replace )
#define TedPattern(obj) ( (*(Colorword *)&_TE(obj)->te_color).pattern )
#define TedCFill(obj)	( (*(Colorword *)&_TE(obj)->te_color).cfill )

#define TedBorder(obj)	( _TE(obj)->te_thickness )
#define TedLen(obj) 	( _TE(obj)->te_txtlen )
#define TedTempLen(obj) ( _TE(obj)->te_tmplen )

/* ICONBLK access for ObICON */
#define _IB(obj)	( (ICONBLK *)ObSpec(obj) )
#define IconMask(obj)	( _IB(obj)->ib_pmask )
#define IconData(obj)	( _IB(obj)->ib_pdata )
#define IconText(obj)	( _IB(obj)->ib_ptext )
#define IconFColor(obj) ( (*(IconInfo *)&_IB(obj)->ib_char).fcolor )
#define IconBColor(obj) ( (*(IconInfo *)&_IB(obj)->ib_char).bcolor )
#define IconChar(obj)	( (*(IconInfo *)&_IB(obj)->ib_char).letter )
#define IconRect(obj)	( *(GRECT *)&_IB(obj)->ib_xicon )
#define IconTRect(obj)	( *(GRECT *)&_IB(obj)->ib_xtext )

/* BITBLK access for ObIMAGE */
#define _BB(obj)	( (BITBLK *)ObSpec(obj) )
#define ImageData(obj)	( _BB(obj)->bi_pdata )
#define ImageWb(obj)	( _BB(obj)->bi_wb )
#define ImageH(obj) 	( _BB(obj)->bi_hl )
#define ImageColor(obj) ( _BB(obj)->bi_color )

/* String access for ObBUTTON, ObSTRING, ObTITLE */
#define ObString(obj)	( (char *)ObSpec(obj) )

/* Object extents */
#define ObX(obj)	( tree[(obj)].ob_x )
#define ObY(obj)	( tree[(obj)].ob_y )
#define ObW(obj)	( tree[(obj)].ob_width )
#define ObH(obj)	( tree[(obj)].ob_height )
#define ObRect(obj) 	( *(GRECT *)&tree[(obj)].ob_x )


/*
 * Object flags & states macros
 */
#define IsSelectable(obj)	( ObFlags(obj) & SELECTABLE )
#define IsDefault(obj)		( ObFlags(obj) & DEFAULT )
#define IsExit(obj) 		( ObFlags(obj) & EXIT )
#define IsEditable(obj) 	( ObFlags(obj) & EDITABLE )
#define IsRadio(obj)		( ObFlags(obj) & RBUTTON )
#define IsRButton(obj)		IsRadio(obj)
#define IsLast(obj) 		( ObFlags(obj) & LASTOB )
#define IsLastob(obj)		IsLast(obj)
#define IsTouchexit(obj)	( ObFlags(obj) & TOUCHEXIT )
#define IsHidden(obj)		( ObFlags(obj) & HIDETREE )
#define IsVisible(obj)		( !IsHidden(obj) )
#define IsIndirect(obj) 	( ObFlags(obj) & INDIRECT )

#define IsSelected(obj) 	( ObState(obj) & SELECTED )
#define IsCrossed(obj)		( ObState(obj) & CROSSED )
#define IsChecked(obj)		( ObState(obj) & CHECKED )
#define IsDisabled(obj) 	( ObState(obj) & DISABLED )
#define IsEnabled(obj)		( !IsDisabled(obj) )
#define IsOutlined(obj) 	( ObState(obj) & OUTLINED )
#define IsShadowed(obj) 	( ObState(obj) & SHADOWED )
#define IsTed(obj)		( (ObType(obj) == G_TEXT)	|| \
				  (ObType(obj) == G_BOXTEXT)	|| \
				  (ObType(obj) == G_FTEXT)	|| \
				  (ObType(obj) == G_FBOXTEXT) )
#define ActiveTree( newtree )	( tree = newtree )
#define IsActiveTree( newtree ) ( tree == newtree )

/*
 * Object flags & states manipulation macros.
 * NOTE: These do not affect the visual appearance of the object.
 */
#define MakeSelectable(obj) 	( ObFlags(obj) |= SELECTABLE )
#define MakeDefault(obj)	( ObFlags(obj) |= DEFAULT )
#define MakeExit(obj)		( ObFlags(obj) |= EXIT )
#define MakeEditable(obj)	( ObFlags(obj) |= EDITABLE )
#define MakeRadio(obj)		( ObFlags(obj) |= RBUTTON )
#define MakeRButton(obj)	MakeRadio(obj)
#define MakeLast(obj)		( ObFlags(obj) |= LASTOB )
#define MakeLastob(obj) 	MakeLast(obj)
#define MakeTouchexit(obj)	( ObFlags(obj) |= TOUCHEXIT )
#define HideObj(obj)		( ObFlags(obj) |= HIDETREE )
#define MakeHidden(obj) 	HideObj(obj)
#define MakeHidetree(obj)	HideObj(obj)
#define MakeIndirect(obj)	( ObFlags(obj) |= INDIRECT )

#define NoSelect(obj)		( ObFlags(obj) &= ~SELECTABLE )
#define NoDefault(obj)		( ObFlags(obj) &= ~DEFAULT )
#define NoExit(obj) 		( ObFlags(obj) &= ~EXIT )
#define NoEdit(obj) 		( ObFlags(obj) &= ~EDITABLE )
#define NoRadio(obj)		( ObFlags(obj) &= ~RBUTTON )
#define NoRButton(obj)		NoRadio(obj)
#define NoLast(obj) 		( ObFlags(obj) &= ~LASTOB )
#define NoLastob(obj)		NoLast(obj)
#define NoTouchexit(obj)	( ObFlags(obj) &= ~TOUCHEXIT )
#define ShowObj(obj)		( ObFlags(obj) &= ~HIDETREE )
#define NoHidetree(obj) 	ShowObj(obj)
#define NoIndirect(obj) 	( ObFlags(obj) &= ~INDIRECT )

#define SelectObj(obj)		( ObState(obj) |= SELECTED )
#define CrossObj(obj)		( ObState(obj) |= CROSSED )
#define CheckObj(obj)		( ObState(obj) |= CHECKED )
#define DisableObj(obj) 	( ObState(obj) |= DISABLED )
#define OutlineObj(obj) 	( ObState(obj) |= OUTLINED )
#define ShadowObj(obj)		( ObState(obj) |= SHADOWED )
#define Select(obj)		( ObState(obj) |= SELECTED )
#define Disable(obj)		( ObState(obj) |= DISABLED )

#define DeselectObj(obj)	( ObState(obj) &= ~SELECTED )
#define UnCrossObj(obj) 	( ObState(obj) &= ~CROSSED )
#define UnCheckObj(obj) 	( ObState(obj) &= ~CHECKED )
#define EnableObj(obj)		( ObState(obj) &= ~DISABLED )
#define NoOutlineObj(obj)	( ObState(obj) &= ~OUTLINED )
#define NoShadowObj(obj)	( ObState(obj) &= ~SHADOWED )
#define Deselect(obj)		( ObState(obj) &= ~SELECTED )
#define Enable(obj)		( ObState(obj) &= ~DISABLED )
#define SetNormal(obj)		( ObState(obj) = NORMAL	   )

