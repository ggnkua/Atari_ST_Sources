
struct aline
	{
	int vplanes;
	int vwrap;
	int *contrl;
	int *intin;
	int *ptsin;
	int *intout;
	int *ptsout;
	int colbit0;
	int colbit1;
	int colbit2;
	int colbit3;
	int lstlin;
	int lnmask;
	int wmode;
	int x1,y1,x2,y2;
	int *patptr;
	int patmsk;
	int mfill;
	int clip;
	int xmincl, ymincl, xmaxcl, ymaxcl;
	int xdda;
	int scaledir;
	int mono;
	int sourcex;
	int sourcey;
	int destx;
	int desty;
	int delx;
	int dely;
	int *fbase;
	int fwidth;
	int style;
	int litemask;
	int skewmask;
	int weight;
	int roff;
	int loff;
	int scale;
	int chup;
	int textfg;
	int *scrtchp;
	int scrpt2;
	int textbg;
	int copytran;
	int *seedabort;
	};

struct bbblock
	{
	int b_wd;
	int b_ht;
	int plane_ct;
	int fg_col;
	int bg_col;
	char op_tab[4];
	int s_xmin;
	int s_ymin;
	int *s_form;
	int s_nxwd;
	int s_nxln;
	int s_nxpl;
	int d_xmin;
	int d_ymin;
	int *d_form;
	int d_nxwd;
	int d_nxln;
	int d_nxpl;
	int *p_addr;
	int p_nxln;
	int p_nxpl;
	int p_mask;
	char not_mine[24];
	};

