/* Structure to hold data for a virtual workstation */

struct attribute {
    WORD chup;				/* Character Up vector 			*/
    WORD clip;				/* Clipping Flag 			*/
    struct font_head *cur_font;		/* Pointer to current font 		*/
    WORD dda_inc;			/* Fraction to be added to the DDA 	*/
    WORD multifill;			/* Multi-plane fill flag 		*/
    WORD patmsk;			/* Current pattern mask 		*/
    WORD *patptr;			/* Current pattern pointer 		*/
    WORD pts_mode;			/* TRUE if height set in points mode 	*/
    WORD *scrtchp;			/* Pointer to text scratch buffer 	*/
    WORD scrpt2;			/* Offset to large text buffer 		*/
    WORD style;				/* Current text style 			*/
    WORD t_sclsts;			/* TRUE if scaling up 			*/
    WORD fill_color;			/* Current fill color (PEL value) 	*/
    WORD fill_index;			/* Current fill index 			*/
    WORD fill_per;			/* TRUE if fill area outlined 		*/
    WORD fill_style;			/* Current fill style 			*/
    WORD h_align;			/* Current text horizontal alignment 	*/
    WORD handle;			/* The handle this attribute area is for*/
    WORD line_beg;			/* Beginning line endstyle 		*/
    WORD line_color;			/* Current line color (PEL value) 	*/
    WORD line_end;			/* Ending line endstyle 		*/
    WORD line_index;			/* Current line style 			*/
    WORD line_width;			/* Current line width 			*/
    struct font_head *loaded_fonts;	/* Pointer to first loaded font 	*/
    WORD mark_color;			/* Current marker color (PEL value) 	*/
    WORD mark_height;			/* Current marker height 		*/
    WORD mark_index;			/* Current marker style 		*/
    WORD mark_scale;			/* Current scale factor for marker data */
    struct attribute *next_work;	/* Pointer to next virtual workstation	*/
    WORD num_fonts;			/* Total number of faces available 	*/
    WORD scaled;			/* TRUE if font scaled in any way	*/
    struct font_head scratch_head;	/* Holder for the doubled font data	*/
    WORD text_color;			/* Current text color (PEL value) 	*/
    WORD ud_ls;				/* User defined linestyle 		*/
    WORD ud_patrn[4*16];		/* User defined pattern 		*/
    WORD v_align;			/* Current text vertical alignment 	*/
    WORD wrt_mode;			/* Current writing mode 		*/
    WORD xfm_mode;			/* Transformation mode requested 	*/
    WORD xmn_clip;			/* Low x point of clipping rectangle 	*/
    WORD xmx_clip;			/* High x point of clipping rectangle 	*/
    WORD ymn_clip;			/* Low y point of clipping rectangle 	*/
    WORD ymx_clip;			/* High y point of clipping rectangle 	*/
};
