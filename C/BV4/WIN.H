/*******************************************************************************
	Bitmap view Copyright (c) 1995 by	Christophe BOYANIQUE
													http://www.raceme.org
													tof@raceme.org
********************************************************************************
	This program is free software; you can redistribute it and/or modify it
	under the terms of the GNU General Public License as published by the Free
	Software Foundation; either version 2 of the License, or any later version.
	This program is distributed in the hope that it will be useful, but WITHOUT
	ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
	FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
	more details.
	You should have received a copy of the GNU General Public License along
	with this program; if not, write to the Free Software Foundation, Inc.,
	59 Temple Place - Suite 330, Boston, MA 02111, USA.
********************************************************************************
	TABULATION: 3 CARACTERES
*******************************************************************************/

/*******************************************************************************
	WINDOW DEFINES
*******************************************************************************/
#define	WIC_DEF	-1
#define	WIC_INF	-2
#define	WIC_MOD	-3
#define	WIC_MEM	-4
#define	WIC_OPT	-5
#define	WIC_SYS	-6

#define	TW_FORM			0						/*	Window type: Form		(reserved)	*/
#define	TW_HELP			1						/*	Window type: Help		(reserved)	*/
#define	TW_IMG			2						/*	Window type: Image					*/

#define	wNAMEMAX			60							/*	Max window name					*/
#define	wINFOMAX			60							/*	Max window info					*/
#define	wSNAMEMAX		10							/*	max iconified window name		*/

/*******************************************************************************
	D‚clarations AES pour les fenˆtres
*******************************************************************************/
#define	W_NAME			0x0001
#define	W_CLOSER			0x0002
#define	W_FULLER			0x0004
#define	W_MOVER			0x0008
#define	W_INFO			0x0010
#define	W_SIZER			0x0020
#define	W_UPARROW		0x0040
#define	W_DNARROW		0x0080
#define	W_VSLIDE			0x0100
#define	W_LFARROW		0x0200
#define	W_RTARROW		0x0400
#define	W_HSLIDE			0x0800
#define	W_SMALLER		0x4000

/*******************************************************************************
	D‚clarations suppl‚mentaires pour les fenˆtres
*******************************************************************************/
#define	W_MODAL			0x0001	/*	Window gadget: Modal window					*/
#define	W_XALIGN			0x0002	/*	Window gadget: Force xwork pos 16 multiple*/
#define	W_SWAP			0x0004	/*	Window feature: swap into file when icon	*/



/*******************************************************************************
	window struct
*******************************************************************************/
typedef struct
{
	int		pos;
	int		obj;
	OBJECT	*tree;
}	WFORM;

typedef union
{
	WFORM	wf;								/*	Data for a Form window						*/
	void	*buf;								/*	Raw data											*/
	int	imem;								/*	Memory manager index							*/
}	WSTR;

typedef struct
{
	WSTR		str;
	int		in;							/*	Memory index for swap file					*/
	int		ipal;							/*	Memory index for color palette			*/
	int		smallflag;					/*	SMALL flag										*/
	int		xslidpos,xslidlen;		/*	Position & lenght of X slider				*/
	int		yslidpos,yslidlen;		/*	Position & lenght of Y slider				*/
	int		x,y,w,h;						/*	dimension free for the user				*/
	int		handle;						/*	AES handle of the window					*/
	int		gadget;						/*	Gadgets											*/
	int		xgadget;
	int		save_gadget;
	int		save_xgadget;
	int		type;							/*	Type of window									*/
	int		id;							/*	Identification of window					*/
	int		xwind;						/*	X pos of the window							*/
	int		ywind;						/*	Y pos of the window							*/
	int		wwind;						/*	W pos of the window							*/
	int		hwind;						/*	H pos of the window							*/
	int		xfull;						/*	X full pos of the window					*/
	int		yfull;						/*	Y full pos of the window					*/
	int		wfull;						/*	W full pos of the window					*/
	int		hfull;						/*	H full pos of the window					*/
	int		xwork;						/*	X work pos of the window					*/
	int		ywork;						/*	Y work pos of the window					*/
	int		wwork;						/*	W work pos of the window					*/
	int		hwork;						/*	H work pos of the window					*/
	int		wmini;						/*	minimum width									*/
	int		hmini;						/*	minimum height									*/
	int		xsmall,xwsmall;			/*	X iconified pos								*/
	int		ysmall,ywsmall;			/*	Y iconified pos								*/
	int		wsmall,wwsmall;			/*	W iconified pos								*/
	int		hsmall,hwsmall;			/*	H iconified pos								*/
	int		ic_tree;						/*	RSC tree number of ICONIFIED window		*/
	int		icon;							/*	RSC object index of ICONIFIED window	*/

	char		name[wNAMEMAX+2];			/*	Name of the window							*/
	char		info[wNAMEMAX+2];			/*	Name of the window							*/
	char		sname[wSNAMEMAX+2];		/*	Name of the iconified window				*/

	void	cdecl (*init)(int i);
	void	cdecl (*redraw)(int i,int x,int y,int w,int h);
	void	cdecl (*top)(int i);
	int	cdecl (*askclose)(int i);
	void	cdecl (*close)(int i);
	void	cdecl (*full)(int i);
	void	cdecl (*arrow)(int i,int type);
	void	cdecl (*hslid)(int i,int size);
	void	cdecl (*vslid)(int i,int size);
	void	cdecl (*size)(int i,int w,int h);
	void	cdecl (*move)(int i,int x,int y);
	void	cdecl (*untop)(int i);
	void	cdecl (*ontop)(int i);
	void	cdecl (*small)(int i);
	void	cdecl (*nsmall)(int i);
	void	cdecl (*clic)(int i,int x,int y,int k,int nb);
	void	cdecl (*keybd)(int i,int key);
	int		modal;						/*	modal priority				*/
	int		xold;							/*	reserved for Fuller		*/
	int		yold;							/*	reserved for Fuller		*/
	int		wold;							/*	reserved for Fuller		*/
	int		hold;							/*	reserved for Fuller		*/
}	window;
