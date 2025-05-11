/////////////////////////////////////////////////////////////////////////////
//
//  VDI
//
//  A VDI is an encapsulation of a VDI [Virtual] Workstation.
//
//  This file is Copyright 1992,1993 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#ifndef VDI_h

#define VDI_h

#include <bool.h>
#include <stddef.h>
#include <gemfast.h>


class VDI
{
public:
	// AES physical screen driver
	VDI();						// Standard screen VDI.

	// META.SYS driver
	VDI(const char* metafile);	// Standard metafile (only if GDOS present).

	// Other devices (printers, etc).  Not supported yet.
	//VDI(int device, int w, int h);


	~VDI();

	int  operator!() { return handle<0; }	// !v == creation failed

	// Global
	void clrwk();
	void updwk();

	// Constants
	int MaxX() const								{ return WorkOut(0); }
	int MaxY() const								{ return WorkOut(1); }
	int Width() const								{ return WorkOut(0)+1; }
	int Height() const								{ return WorkOut(1)+1; }
	bool PreciseScaling() const						{ return WorkOut(2); }
	int PixelWidth() /* microns */ const			{ return WorkOut(3); }
	int PixelHeight() /* microns */ const			{ return WorkOut(4); }
	int NumberOfCharacterHeights() const			{ return WorkOut(5); }
	int NumberOfLineTypes() const					{ return WorkOut(6); }
	/* don't believe */ int NumberOfLineWidths() const	{ return WorkOut(7); }
	int NumberOfMarkerTypes() const					{ return WorkOut(8); }
	int NumberOfMarkerSizes() const					{ return WorkOut(9); }
	int NumberOfTextFaces() const;
	int NumberOfPatterns() const					{ return WorkOut(11); }
	int NumberOfHatchStyles() const					{ return WorkOut(12); }
	int NumberOfPredefinedColours() const			{ return WorkOut(13); }
	int NumberOfAvailableColours() const			{ return WorkOut(39); }
	int NumberOfGDPs() const						{ return WorkOut(14); }
	int GDP(int i /* 0..9 */) const					{ return WorkOut(15+i); }
	int GDPAttribute(int i /* 0..9 */) const		{ return WorkOut(25+i); }
	bool Colour() const								{ return WorkOut(35); }
	bool RotateTExtWorks() const					{ return WorkOut(36); }
	bool FillAreaWorks() const						{ return WorkOut(37); }
	bool CellArrayWorks() const						{ return WorkOut(38); }
	int NumberOfLocators() const					{ return WorkOut(40); }
	int NumberOfValidators() const					{ return WorkOut(41); }
	int NumberOfChoosers() const					{ return WorkOut(42); }
	int NumberOfStringDevices() const				{ return WorkOut(43); }
	int WorkstationType() const						{ return WorkOut(44); }
	bool CanOutput() const							{ return (WorkOut(44)&1)==0; }
	bool CanInput() const							{ return (WorkOut(44)&3)>0; }
	bool IsMetafile() const							{ return WorkOut(44)==4; }

	int ScreenType() const							{ return ExtWorkOut(0); }
	int NumberOfBackgroundColours() const			{ return ExtWorkOut(1); }
	bool TextEffectsSupported() const				{ return ExtWorkOut(2); }
	bool ScalableRasters() const					{ return ExtWorkOut(3); }
	int NumberOfPlanes() const						{ return ExtWorkOut(4); }
	bool PaletteBased() const						{ return ExtWorkOut(5); }
	int Speed() const								{ return ExtWorkOut(6); }
	bool ContourFillSupported() const				{ return ExtWorkOut(7); }
	int CharacterRotationType() const				{ return ExtWorkOut(8); }
	int NumberOfWritingModes() const				{ return ExtWorkOut(9); }
	int InputModesAvailable() const					{ return ExtWorkOut(10); }
	bool TextAlignmentSupported() const				{ return ExtWorkOut(11); }
	bool InkingSupported() const					{ return ExtWorkOut(12); }
	int RubberbandingSupported() const				{ return ExtWorkOut(13); }
	int MaximumVertices() const						{ return ExtWorkOut(14); }
	int MaximumIntin() const						{ return ExtWorkOut(15); }
	int NumberOfMouseButtons() const				{ return ExtWorkOut(16); }
	bool StyledWideLinesSupported() const			{ return ExtWorkOut(17); }
	bool WideLinesWriteModesSupported() const		{ return ExtWorkOut(18); }

	int WorkOut(int index) const;
	int ExtWorkOut(int index) const;

	int CharWidth() const;
	int CharHeight() const;
	int CharCellWidth() const;
	int CharCellHeight() const;

	// Attributes
	int  swr_mode (int mode);
	void s_color (int index, int rgb[]);
	int	 sl_type (int style);
	void sl_udsty (int pat);
	int	 sl_width (int width);
	int	 sl_color (int index);
	void sl_ends (int begstyle, int endstyle);
	int	 sm_type (int symbol);
	void sm_height (int height);
	int	 sm_color (int index);
	int  st_height (int height, int *charw, int *charh, int *cellw, int *cellh);
	int	 st_point (int point, int *charw, int *charh, int *cellw, int *cellh);
	int	 st_rotation (int ang);
	int	 st_font (int font);
	int	 st_color (int index);
	int	 st_effects (int effects);
	void st_alignment (int hin, int vin, int *hout, int *vout); 
	int	 sf_interior (int style);
	int	 sf_fill (int style);
	int	 sf_style (int style);
	int	 sf_color (int index);
	int	 sf_perimeter (int vis);
	void sf_udpat (int pat[], int planes);

	// NOTE: In GEM++, fonts are unloaded automatically.
	//       Also, st_load_fonts MAY be called without GDOS (int returns 0).
	//
	int	 st_load_fonts (int select=0);
	void st_unload_fonts (int select=0);

	void s_clip (int clip_flag, int pxyarray[]);

	// Outputs
	void bar (int pxyarray[]);
	void arc (int x, int y, int radius, int begang, int endang); 
	void pieslice (int x, int y, int radius, int begang, int endang);
	void circle (int x, int y, int radius);
	void ellarc (int x, int y, int xrad, int yrad, int begang, int endang);
	void ellpie (int x, int y, int xrad, int yrad, int begang, int endang);
	void ellipse (int x, int y, int xrad, int yrad);
	void rbox (int pxyarray[]);
	void rfbox (int pxyarray[]);
	void justified (int x, int y, char *str, int len, int word_space, int char_space);
	void pline (int count, int pxyarray[]);
	void pmarker (int count, int pxyarray[]);
	int	 gtext (int x, int y, char *str);
	void fillarea (int count, int pxyarray[]);
	void cellarray (int pxyarray[], int row_length, int elements, int nrows, int write_mode, int colarray[]);
	void contourfill (int x, int y, int index);
	void r_recfl (int pxyarray[]);

	void ro_cpyfm (int mode, int pxyarray[], const MFDB& src, const MFDB& dst);
	void rt_cpyfm (int mode, int pxyarray[], const MFDB& src, const MFDB& dst, int color[]);  
	void r_trnfm (const MFDB& src, const MFDB& dst);
	void get_pixel (int x, int y, int *pel, int *indx); 


	// Inputs
	int	 sin_mode  (int dev, int mode);
	void rq_locator (int x, int y, int *xout, int *yout, int *term);  
	int	 sm_locator (int x, int y, int *xout, int *yout, int *term);

	void rq_valuator (int in, int *out, int *term);
	void sm_valuator (int in, int *out, int *term, int *status);
	void rq_choice (int cin, int *cout);
	int	 sm_choice (int *choice);
	void rq_string (int len, int echo, int echoxy[], char *str);
	int	 sm_string (int len, int echo, int echoxy[], char *str);
	void sc_form (int form[]);
	void ex_timv (void *time_addr, void **otime_addr, int *time_conv); 
	void show_c (int reset);
	void hide_c ();
	void q_mouse (int *pstatus, int *x, int *y);
	void ex_butv (void *new_p, void **old);
	void ex_motv (void *new_p, void **old);
	void ex_curv (void *new_p, void **old);
	void q_key_s (int *state);

	// Inquiries
	void q_extnd (int flag, int work_out[]) const;
	int	 q_color (int index, int flag, int rgb[]) const;
	void ql_attribute (int atrib[]) const;
	void qm_attributes (int atrib[]) const;
	void qf_attributes (int atrib[]) const;
	void qt_attributes (int atrib[]) const;
	void qt_extent (char *str, int extent[]) const;
	int	 qt_width (int chr, int *cw, int *ldelta, int *rdelta) const;
	int	 qt_name (int element, char *name) const;
	void qt_fontinfo (int *minade, int *maxade, int distances[], int *maxwidth, int effects[]);  
	void qt_font_info (int *minade, int *maxade, int distances[], int *maxwidth, int effects[]);  


	void q_cellarray (int pxyarray[], int row_len, int nrows, int *el_used, int *rows_used, int *status, int color[]);  
	void qin_mode (int dev, int *mode);

	// ASCII terminal
	void q_chcells (int *n_rows, int *n_cols);
	void exit_cur ();
	void enter_cur ();
	void curup ();
	void curdown ();
	void curright ();
	void curleft ();
	void curhome ();
	void eeos ();
	void eeol ();
	void s_curaddress (int row, int col);
	void curtext (char *s);
	void rvon ();
	void rvoff ();
	void q_curaddress (int *cur_row, int *cur_col);
	int  q_tabstatus ();
	void hardcopy ();
	void dspcur  (int x, int y);
	void rmcur ();
	void form_adv ();
	void output_window (int *pxyarray);
	void clear_disp_list ();
	void bit_image (const char *filename, int aspect, int x_scale, int y_scale, int h_align, int v_align, int *pxyarray);
	void q_scan (int *g_slice, int *g_page, int *a_slice, int *a_page, int *div_fac);
	void alpha_text (const char *string);
	int  s_palette (int palette);
	void sound (int frequency, int duration);
	int  s_mute (int action);
	void t_resolution (int xres, int yres, int *xset, int *yset);
	void t_axis (int xres, int yres, int *xset, int *yset);
	void t_origin (int xorigin, int yorigin);
	void q_dimensions (int *xdimension, int *ydimension);
	void t_alignment (int dx, int dy);
	void sp_film (int index, int lightness);
	int  qp_filmname (int index, char *name);
	void sc_expose (int state);
	void meta_extents (int min_x, int min_y, int max_x, int max_y);
	void write_meta (int num_intin, int *a_intin, int num_ptsin, int *a_ptsin);
	void m_pagesize (int pgwidth, int pgheight);
	void m_coords (int llx, int lly, int urx, int ury);
	void m_filename (const char *filename);
	void escape2000 (int times);
	unsigned long q_vgdos ();
	void getbitmap_info (int ch, long *advancex, long *advancey, long *xoffset, long *yoffset, int *width, int *height, short **bitmap);
	void qt_f_extent (const char *str, int extent[]);
	void ftext (int x, int y, const char *str);
	//void killoutline (void *component); OBSOLETE
	void getoutline (int ch, int *xyarray, char *bezarray, int maxverts, int *numverts);
	void st_scratch (int mode);
	void st_error (int mode, short *errorvar);
	int  st_arbpt (int point, int *wchar, int *hchar, int *wcell, int *hcell);
	void qt_advance (int ch, int *xadv, int *yadv, int *xrem, int *yrem); 
	void qt_devinfo (int device, int *isdev, char *drivername);
	int  savecache (char *filename);
	int  loadcache (char *filename, int mode);
	int  flushcache ();
	int  st_setsize (int point, int *wchar, int *hchar, int *wcell, int *hcell);
	int  st_skew (int skew);
//	void qt_get_tables (void **gascii, void **style); OBSOLETE
	void qt_get_table (short **map);
	void qt_cachesize (int which_cache, size_t *size);
	int  bez (int count, int *xyarr, char *bezarr, int extent[4], int *npts, int *nmvs);
	int  bez_fill (int count, int *xyarr, char *bezarr, int extent[4], int *npts, int *nmvs);
	int  bez_qual (int percent, int *actual);
	int  bez_on ();
	void bez_off ();

	void shtext (int wsid, int x, int y, const char *text, int color, int xshadow, int yshadow);
	void set_app_buff (void **buf_p, int size);

// Shorthands...
	// As standard calls, but do not return cell dimensions / other values
	int  st_height(int height);
	int	 st_point(int point);
	void st_alignment(int hin, int vin);

	// Clip to full area of device
	void clip();
	// Clip to area
	void clip(int x1, int y1, int x2, int y2);
	// No clipping
	void clip_off();


	// Non Pxyarray versions...
	void bar(int x1, int y1, int x2, int y2);
	void rbox(int x1, int y1, int x2, int y2);
	void rfbox(int x1, int y1, int x2, int y2);
	void line(int x1, int y1, int x2, int y2);
	void marker(int x, int y);
	void r_recfl(int x1, int y1, int x2, int y2);

	// Combine SRC and DST using any logical operators.
	// eg. SRC|DST gives "or" mode.
	const int SRC=3;
	const int DST=5;

	// Unary version - destination is this VDI
	void ro_cpyfm(int mode, int pxyarray[], VDI& from);
	void rt_cpyfm(int mode, int pxyarray[], VDI& from, int color[]);  
	void r_trnfm(VDI& from);

	// Nullary version - source and destination is this VDI
	void ro_cpyfm(int mode, int pxyarray[]);
	void rt_cpyfm(int mode, int pxyarray[], int color[]);  
	void r_trnfm();

	const MFDB& MF();

private:
	short handle;
	short flags;
};

#endif
