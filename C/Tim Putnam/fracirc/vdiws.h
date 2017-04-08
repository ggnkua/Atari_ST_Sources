/* VDI Workstation data struct	*/
/* From TAC page 7.65			*/

#ifndef	__VDIWS__
#define __VDIWS__
typedef struct vdi_workstation {

    short handle,dev_id;
    short wchar, hchar, wbox, hbox;
    short xres, yres;
    short noscale;
    short wpixel, hpixel;
    short cheights;
    short linetypes, linewidths;
    short markertypes, markersizes;
    short faces, patterns, hatces, colors;
    short ngpds;
    short cangdps[10];
    short gdpattr[10];
    short cancolor, cantextrot;
    short canfillarea, cancellarray;
    short palette;
    short locators, valuators;
    short choicedevs, stringdevs;
    short wstype;
    short minwchar, minhchar;
    short maxwchar, maxhchar;
    short minwline;
    short zero5;
    short maxwline;
    short zero7;
    short minwmark, minhmark;
    short maxwmark, maxhmark;
    short screentype;
    short bgcolors,textfx;
    short canscale;
    short planes, lut;
    short rops;
    short cancontourfill, textrot;
    short writemodes;
    short inputmodes;
    short textalign, inking, rubberbanding;
    short maxvertices, maxshortin;
    short mousebuttons;
    short widestyles, widemodes;
    short reserved[38];
} VDI_Workstation;

short	OpenVwork(VDI_Workstation *);
short	Openwork(short, VDI_Workstation *);
#endif