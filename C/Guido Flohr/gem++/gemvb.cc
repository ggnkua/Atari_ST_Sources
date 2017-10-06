#include "gemvb.h"

#include "vdi++.h"

static int abs(int x)
{
	if (x<0) return -x;
	return x;
}

GEMvdibox::GEMvdibox(GEMform& form, int RSCindex, class VDI& vdi) :
	GEMvdiobject(form,RSCindex,vdi)
{
	Color(BackCol());
}

void GEMvdibox::Color(int col)
{
	color=col;
}

int GEMvdibox::Color() const
{
	return color;
}

int GEMvdibox::Draw(int x, int y)
{
	vdi.sf_color(color);
	vdi.sf_perimeter(0);

	int fill=FillPattern();

	if (fill==0) {
		vdi.sf_interior(FIS_HOLLOW);
	} else if (fill==7) {
		vdi.sf_interior(FIS_SOLID);
	} else {
		vdi.sf_interior(FIS_PATTERN);
		vdi.sf_style(fill);
	}

	vdi.bar(x,y,x+Width()-1,y+Height()-1);

	int border=BorderWidth();

	// Outside border (-ve) ignored.
	//
	while (border-- > 0) {
		vdi.sl_color(BorderCol());
		vdi.sl_type(0);
		vdi.sl_width(1);
		int pxy[10]={
			x+border,y+border,
			x+Width()-1-border,y+border,
			x+Width()-1-border,y+Height()-1-border,
			x+border,y+Height()-1-border,
			x+border,y+border
		};
		vdi.pline(5,pxy);
	}

	// Find contrasting color for foreground stuff
	// only if it HAS foreground stuff.

	if (Type()==G_TEXT || Type()==G_BOXTEXT || Checked()) {
		const int MINCONTRAST=700; // 0..1000

		int rgb[3];
		vdi.q_color(color,1,rgb);

		int best_contrast=0;
		int contrast_color=0;

		for (int i=0; i<vdi.NumberOfPredefinedColors() && best_contrast<MINCONTRAST; i++) {
			int rgb_contrast[3];
			vdi.q_color(i,1,rgb_contrast);

			// XXX Naive contrast calculation
			//int contrast=abs(rgb_contrast[0]-rgb[0]) + abs(rgb_contrast[1]-rgb[1]) + abs(rgb_contrast[2]-rgb[2]);

// From Graphics Gems 2.
#define bright(rgb) (int)((67L*(rgb)[0]+168L*(rgb)[1]+21L*(rgb)[2])/256)

			// Contrast calculation 
			int contrast=abs(bright(rgb_contrast)-bright(rgb));

			if (contrast > best_contrast) {	
				best_contrast=contrast;
				contrast_color=i;
			}
#undef bright
		}

		// Only support text on TEXT
		if (Type()==G_TEXT || Type()==G_BOXTEXT) {
			char* text=Text();
			if (*text) {	
				vdi.st_color(contrast_color);
				// Only support centred text
				int j;
				vdi.st_alignment(1,5,&j,&j); // Centre, Top.
				vdi.swr_mode(MD_TRANS);
				vdi.gtext(x+Width()/2,y+(Height()-vdi.CharCellHeight())/2,text);
				vdi.swr_mode(MD_REPLACE);
			}
		}

		if (Checked()) {
			// Draw circle
			vdi.sf_color(contrast_color);
			vdi.ellipse(x+Width()/2,y+Height()/2,Width()/5,Height()/5);
		}
	}

	return States()&~CHECKED;
}
