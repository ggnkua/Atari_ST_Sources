#include <aes.h>
#include <vdi.h>
#include <osbind.h>
#include <math.h>
#include <stdio.h>

#define PI	3.14159265358979323846

/* Prototypes... */

	void draw_template(void);
	void draw_thermometer(short);
	void draw_barometer(short, short);
	void draw_humidity(short);
	void draw_wind(char *, short);

/* Externals... */

	/* Prototypes... */
	
	/* Globals... */
	
		extern short	vdi_handle;
		extern MFDB	work;

void draw_template(void)
	{
	void *oldlogbase;
	short pxy[6], lpxy[4], i;	
	short junk;
	char	out[5];

	oldlogbase=Logbase();
	Setscreen(work.fd_addr, (void *)-1, -1);

/* Thermometer */

	pxy[0]=15;
	pxy[1]=15;
	pxy[4]=pxy[2]=pxy[0];
	pxy[5]=pxy[3]=pxy[1]+100;

	vsl_ends(vdi_handle, 2, 0);

	vsl_color(vdi_handle, 1);
	vsl_width(vdi_handle, 7);
	v_pline(vdi_handle, 2, pxy);
	vsl_width(vdi_handle, 17);
	v_pline(vdi_handle, 2, &pxy[2]);

	vsl_width(vdi_handle, 1);
	lpxy[0]=15;
	lpxy[2]=25;
	vst_color(vdi_handle, 1);
	vst_height(vdi_handle, 6, &junk, &junk, &junk, &junk);
	for (i=5; i>0; i--)
		{
		lpxy[3]=lpxy[1]=115-(i*20);
		v_pline(vdi_handle, 2, lpxy);
		sprintf(out, "%d",  i*20);
		v_gtext(vdi_handle, 30, 115-(i*20), out);
		}

	vsl_color(vdi_handle, 0);
	vsl_width(vdi_handle, 5);
	v_pline(vdi_handle, 2, pxy);
	vsl_width(vdi_handle, 15);
	v_pline(vdi_handle, 2, &pxy[2]);

	vsl_color(vdi_handle, 2);
	vsl_width(vdi_handle, 13);
	v_pline(vdi_handle, 2, &pxy[2]);

/* Barometer */

	pxy[0]=57;
	pxy[1]=108;
	pxy[2]=83;
	pxy[3]=122;

	vsf_color(vdi_handle, 1);
	v_bar(vdi_handle, pxy);
	pxy[0]++;
	pxy[2]--;
	pxy[3]--;
	vsf_color(vdi_handle, 0);
	v_bar(vdi_handle, pxy);	

	pxy[1]+=5;
	vsf_color(vdi_handle, 8);
	v_bar(vdi_handle, pxy);

	pxy[0]=70;
	pxy[1]=15;
	pxy[2]=pxy[0];
	pxy[3]=pxy[1]+100;

	vsl_ends(vdi_handle, 2, 0);

	vsl_color(vdi_handle, 1);
	vsl_width(vdi_handle, 7);
	v_pline(vdi_handle, 2, pxy);

	vsl_width(vdi_handle, 1);
	lpxy[0]=70;
	lpxy[2]=80;
	vst_color(vdi_handle, 1);
	vst_height(vdi_handle, 6, &junk, &junk, &junk, &junk);
	for (i=3; i>0; i--)
		{
		lpxy[3]=lpxy[1]=145-(i*40);
		v_pline(vdi_handle, 2, lpxy);
		sprintf(out, "%d",  i+28);
		v_gtext(vdi_handle, 85, 145-(i*40), out);
		}

	vsl_color(vdi_handle, 0);
	vsl_width(vdi_handle, 5);
	v_pline(vdi_handle, 2, pxy);

/* Hygrometer */

	vsl_color(vdi_handle, 1);
	vsl_width(vdi_handle, 1);
	v_gtext(vdi_handle, 108, 40, "0");
	v_arc(vdi_handle, 150, 40, 32, 0, 1800);
	v_gtext(vdi_handle, 185, 40, "100");

/* Anemometer */

	vsl_color(vdi_handle, 1);
	vsl_width(vdi_handle, 1);
	v_gtext(vdi_handle, 108, 120, "0");
	v_arc(vdi_handle, 150, 120, 32, 0, 1800);
	v_gtext(vdi_handle, 185, 120, "50");

	Setscreen(oldlogbase, (void *)-1, -1);
	}

void draw_barometer(short p, short dec)
	{
	void *oldlogbase;
	short pxy[4];
	char out[8];

	pxy[2]=pxy[0]=70;
	pxy[3]=115;
	pxy[1]=65-(2*(100*p+dec-3000)/5);

	if (pxy[1]>115)	pxy[1]=115;
	else if (pxy[1]<15) pxy[1]=15;

	vsl_color(vdi_handle, 8);
	vsl_ends(vdi_handle, 0, 0);
	vsl_width(vdi_handle, 3);

	sprintf(out, "%2.2d.%2.2d\"", p, dec);

	oldlogbase=Logbase();
	Setscreen(work.fd_addr, (void *)-1, -1);
	v_pline(vdi_handle, 2, pxy);
	v_gtext(vdi_handle, 55, 140, "P(atm)");
	v_gtext(vdi_handle, 55, 148, out);
	Setscreen(oldlogbase, (void *)-1, -1);
	}

void draw_thermometer(short temp)
	{
	void *oldlogbase;
	short pxy[4];
	char out[15];

	pxy[2]=pxy[0]=15;
	pxy[3]=115;

	if (temp>100)		pxy[1]=15;
	else if (temp<0)	pxy[1]=115;
	else			pxy[1]=115-temp;

	vsl_color(vdi_handle, 2);
	vsl_ends(vdi_handle, 0, 0);
	vsl_width(vdi_handle, 3);

	sprintf(out, "%døF", temp);

	oldlogbase=Logbase();
	Setscreen(work.fd_addr, (void *)-1, -1);
	v_pline(vdi_handle, 2, pxy);
	v_gtext(vdi_handle, 0, 140, "Temp");
	v_gtext(vdi_handle, 0, 148, out);
	Setscreen(oldlogbase, (void *)-1, -1);
	}

void draw_humidity(short r)
	{
	void *oldlogbase;
	float x,y;
	short pxy[4];
	short out[5];

	vsl_color(vdi_handle, 1);
	vsl_ends(vdi_handle, 2, 1);
	vsl_width(vdi_handle, 3);

	x=36*cos(((float)r*PI)/100);
	y=36*sin(((float)r*PI)/100);

	if (x>36)	x=36;
	else if (x<-36)	x=-36;
	
	if (y>36)	y=36;
	else if (y<0)	y=0;

	pxy[0]=150;
	pxy[1]=40;
	pxy[2]=pxy[0]-(short)x;
	pxy[3]=pxy[1]-(short)y;

	sprintf(out, "%d%", r);
	
	oldlogbase=Logbase();
	Setscreen(work.fd_addr, (void *)-1, -1);
	v_pline(vdi_handle, 2, pxy);
	v_gtext(vdi_handle, 120, 50, "Humidity");
	v_gtext(vdi_handle, 140, 58, out);
	Setscreen(oldlogbase, (void *)-1, -1);
	}

void draw_wind(char *dir, short r)
	{
	void *oldlogbase;
	float x,y;
	short pxy[4];
	char out[10];

	vsl_color(vdi_handle, 1);
	vsl_ends(vdi_handle, 2, 1);
	vsl_width(vdi_handle, 3);

	x=36*cos(((float)r*PI)/50);
	y=36*sin(((float)r*PI)/50);

	if (x>36)	x=36;
	else if (x<-36)	x=-36;
	
	if (y>36)	y=36;
	else if (y<0)	y=0;

	pxy[0]=150;
	pxy[1]=120;
	pxy[2]=pxy[0]-(short)x;
	pxy[3]=pxy[1]-(short)y;

	sprintf(out, "%s at %d", dir, r);

	oldlogbase=Logbase();
	Setscreen(work.fd_addr, (void *)-1, -1);
	v_pline(vdi_handle, 2, pxy);
	v_gtext(vdi_handle, 130, 140, "Winds");
	v_gtext(vdi_handle, 110, 148, out);
	Setscreen(oldlogbase, (void *)-1, -1);
	}
