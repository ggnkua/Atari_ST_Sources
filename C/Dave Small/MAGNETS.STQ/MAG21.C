/* MAG21.C - Dave's magplot program, cut 21. */
/* w/ color animation code. */
/* Copyright 1986 ANTIC Publishing */

/* Standard include files: */

/* GEM VDI related variable defines */
        int        contrl[12], intin[256], ptsin[256], intout[256], ptsout[256];
        int        handle;         /* from v_opnvwk */
        int        i;              /* for init loop & general array index */
        int        dummy;          /* for graf_handle call */
        int        key_state;      /* for keyboard call */
        int        set_color;      /* for color setting call */
        int        xcircle,ycircle,rcircle; /* for v_circle */
        int        style;          /* for fill interior style call */
        int        color_flag;     /* true if color, false if mono */
        int        numcolors;      /* # of colors (2,4,16):mono,med,low res */
        int        xscreen,yscreen;  /* from v_opnvwk */
        int        old_color,temp_color;   /* for ext. bios _setColor call */
/* magplot vars */
        int        debug;            /* nz = all sortsa debugging messages */
        int        gridstyle;        /* nz = grid plotting technique */
        int        degreeinc,clipit; /* global vars */
        int        currcolor;        /* current color */
        int        vbl_count;        /* for color rotate */
        double        k2;            /* force constant calc var */
        double        linelength;    /* vector length */
        double        xmax,ymax;     /* GEM: how big screen is */
        double        ymenu;         /* menu size, for offset etc. */
        int        allneg; /* point entry routine: nz if all pts negative */
        int        currpt; /* array index of point being worked on */
        int        degree; /* polar coord of starting place on point */
        int        xcoord[10],ycoord[10],charge[10]; /* stored points */
        int        numpoints;              /* # of points */
        int        xgridpt,ygridpt;        /* for grid-style display */
        double        theta,radius,x1,y1;  /* starting point calcs */
        int        newline;        /* flag for "new line starting"; 0 = yes */
        int        doanotherseg;   /* flag for exiting while segment loop */
        int        mouse_poll;     /* polling flag for input */
        int        xposmin,xposmax,xnegmin,xnegmax; /* polling for input */
        double        xcurrent,ycurrent;     /* saved old loc for calcs */
        double        xvectorsum,yvectorsum; /* internal to summer */
        double        number;             /* scaling divider */
        double        xsqr,ysqr;           /* internal to summer */
        double        xdistance,ydistance; /* internal to summer */
        double        force,forcetemp;     /* internal to summer */
        double        ivtemp;              /* debugging stuff */
        double        ivlength,ivline;     /* after summer */
        double        xdelta,ydelta;       /* for clipping radius check */
        int        height,width;           /* from graf_handle */
        int        xtext,ytext;            /* for v_gtext output */
        int        ctext;                  /* temp */
        int        xmouse,ymouse,smouse;   /* for vq_mouse */
        int        black,white; /* vars to make colors "float" for vdi/palette*/
        char        outstring[80];         /* string output for numbers.. */
        extern        double sin(),cos(),sqrt(); /* trig functions */

main()
{
        appl_init();        /* Gem voodoo */
        gemopen();        /* open a workstation for VDI's kicks, init it */

/* We need a black background and colored foreground. GEM uses hardcoded */
/* color register #'s for a given color, which trips us up. */
/* We tweak color registers */
/* so black=0, white=1, other colors=2,3,4.. */
/* This handles text, etc, so we don't trip over the gem-hardware */
/* palette mapping problem later. */

          do {
             key_state = 0;

             temp_color=xbios(7,0,0x100); /* set "black" (reg 0) to black color */
             temp_color=xbios(7,3,0x777);  /* set 3: "white".. this matters */
             temp_color=xbios(7,15,0x777); /* set 15: "white".. matters to */

             black=0; /* vdi constants for colors.. reassigned to my scheme. */
             white=1; 

             cls();                /* clear screen to white */
             initglobals();        /* Setup variables */
             inputpoints();        /* Input points to work on */
             setupcolors();  /* setup colors to plot with */
             plotit();        /* Plot the screen */

/* Done. Loop, waiting for any shift-alt-ctrl key, so we don't fall out */
/* of the program and erase the plot. If in color mode, rotate colors. */
             vbl_count=0;        /* init vbl_count for # of vblanks / change */
             while (key_state == 0) 
                     {
                     vq_key_s(handle, &key_state) ; /* get state into keystate */
                     /* color rotation stuff */
                     if (color_flag && gridstyle == 0) /* color modes & non grid*/
                             rotate();
                     }        /* loop until key_state is nonzero */
          } while (key_state != 4); /* until CTL key */

/* With apologies to the author, the do {} while (key_state != 4) loop
   was included by the ANTIC Editorial Staff because they felt it
   increased the program's fun quotient. */

        v_clsvwk(handle); /* shut down GEM */
        appl_exit();      /* Exit, stage left */
} /* end main() */


/* *********** setupcolors() ************* */
/* Configures the colors we want to plot with if color mode. */
/* These can be configured however you like. Format, in hex: */
/* 0xnrgb. n=null. r=red value 0-7, g=green, b=blue */

/* Register 0 always stays black as the background. */

setupcolors()
{
/* setup plotting colors */
        if (numcolors==4)  /* medium res 4-color mode */
/* just use rgb if 3 colors */
                {
                temp_color=xbios(7,1,0x700); /* set "red" */
                temp_color=xbios(7,2,0x070); /* set "green" */
                temp_color=xbios(7,3,0x007); /* set "blue" */
                }
        if (numcolors==16) 
/* Add some variations if 16 colors */
                {
                temp_color=xbios(7,1,0x007); /* set "red" */
                temp_color=xbios(7,2,0x004); /* set "dim red" */
                temp_color=xbios(7,3,0x070); /* set "green" */
                temp_color=xbios(7,4,0x040); /* set "dim green" */
                temp_color=xbios(7,5,0x700); /* set "blue" */
                temp_color=xbios(7,6,0x400); /* set "dim blue" */
                temp_color=xbios(7,7,0x707); /* set "red/blue" */
                temp_color=xbios(7,8,0x404); /* set "dim red/blue" */
                temp_color=xbios(7,9,0x770); /* set "red/green" */
                temp_color=xbios(7,10,0x440); /* set "dim red/green" */
                temp_color=xbios(7,11,0x777); /* set "white" */
                temp_color=xbios(7,12,0x444); /* set "dim white" */
                temp_color=xbios(7,13,0x044); /* set "dim green/blue" */
                temp_color=xbios(7,14,0x040); /* set "dim green" */
                temp_color=xbios(7,15,0x440); /* set "dim red/green" */
                }
}


/* ******** rotate *********** */
/* Rotates colors if in color mode to animate the lines flowing from */
/* + to - points.  We do this by rotating colors in color registers, */
/* which gives onscreen animation, every few vblanks. */

/* Note: at present, Megamax does not support extended bios call names. */
/* Hence, I include a commented-out version of the call, with the proper */
/* name, then make the "generic" xbios call to do the color change. */
/* xbios (7,color register #, color value) is equiv. to set_Color; */
/* if color value is negative, only returns value, doesn't alter. */

rotate()
{
/*      vsync(); */        /* wait until vblank to slow it */ 
        xbios(37);              /* vsync */

/* count # of vblanks. Once per vblank ismuch too fast; tweak this to */
/* your individual taste. */

        vbl_count=vbl_count+1;
        if (vbl_count == 8) /* every 8 vblanks */
                {       
                if (numcolors == 4) /* medium res: rotate 4 */
                        {
/* rotation: First, sample #3 w/o changing it, then write into 1, */
/* getting old 1's value back, put that in 2, then do 3. */
                        temp_color=xbios(7,3,-1); /* get 3 */
                        temp_color=xbios(7,1,temp_color); /* 3->1 */
                        temp_color=xbios(7,2,temp_color); /* 1->2 */
                        temp_color=xbios(7,3,temp_color); /* 2->3 */
                        }
                if (numcolors == 16)
                        {
/* A more complex rotation. GEM colors do NOT match the palette */
/* numbers, so I can either do a table lookup, or do it directly. */
/* Either way, we have to rotate in GEM order since we drew the lines */
/* in GEM order. */

/* I did it directly. */
/* GEM COLOR #      HARDWARE COLOR NUNBER (PALETTE) */
/*  0                 0 */
/*  1                 15 */
/*  2                  1 */
/*  3                  2 */
/*  4                  4 */
/*  5                  6 */
/*  6                  3 */
/*  7                  5 */
/*  8                  7 */
/*  9                  8 */
/*  10                  9 */
/*  11                  10 */
/*  12                  12 */
/*  13                  14 */
/*  14                  11 */
/*  15                  13 */


                        temp_color=xbios(7,13,-1);  /* sample 13; no change */
                        temp_color=xbios(7,15,temp_color); /* 13->15 */
                        temp_color=xbios(7,1,temp_color);/* 15->1 */
                        temp_color=xbios(7,2,temp_color);/* 1->2 */
                        temp_color=xbios(7,4,temp_color);/* 2->4 */
                        temp_color=xbios(7,6,temp_color);/* 4->6 */
                        temp_color=xbios(7,3,temp_color);/* 6->3 */
                        temp_color=xbios(7,5,temp_color);/* 3->5 */
                        temp_color=xbios(7,7,temp_color);/* 5->7 */
                        temp_color=xbios(7,8,temp_color);/* 7->8 */
                        temp_color=xbios(7,9,temp_color);/* 8->9 */
                        temp_color=xbios(7,10,temp_color);/* 9->10 */
                        temp_color=xbios(7,12,temp_color);/* 10->12 */
                        temp_color=xbios(7,14,temp_color);/* 12->14 */
                        temp_color=xbios(7,11,temp_color);/* 14->11 */
                        temp_color=xbios(7,13,temp_color); /* 11->13 */
                        }
                        vbl_count=0; /* reset vbl counter */
              } /* end if vbl_count == rotate it.. */
} /* End rotate() */

/* ****** input points ************* */
/* Inputs points using mouse. Stores points into xcoord[],ycoord[], with a */
/* charge of charge[].  Uses VDI only, so no AES (resource, etc) is required */

inputpoints()

{
        clearpn();            /* clear off menu bar */

        numpoints=0;          /* total # of points */
        i=0;                  /* pointer for coord arrays */
key_state= 0;                 /* flag to exit input loop */    
while (key_state == 0)
        {                        /* id=1 */
        if (numcolors != 16) /* anything but low res */
          {
          v_gtext(handle,1*width,(height)-2,"Exit: (SHIFT=pt-pt; ALT=grid).");
          v_gtext(handle,50*width,(height)-2,"   Select a Point or Exit.");
          }
        else /* velly few characters across.. */
     v_gtext(handle,1*width,(height)-2,"Select pt or (SHIFT=pt-pt; ALT=grid).");
        
      /* update shift key state for possible exit */
        vq_key_s(handle,&key_state); 
      /* Update mouse button state */
        vq_mouse(handle,&smouse,&xmouse,&ymouse);
        smouse=(smouse&1); /* mask to mouse button bit */
        if (smouse==1)  /* mouse down event */          /* id=2 */
                {
             /* Erase the "select a point" stuff */
                clearpn();
             /* Store circle's co-ords there */
                xcircle=xmouse;
                ycircle=ymouse; /* okay coord system: scrn-scrn */
                rcircle=radius;
             /* Put up the pos/neg menu */
                plotpn();
             /* Now get a plus/minus in from him. */
                mouse_poll=1;
             /* Wait for him to get into <20 y,*/
             /* and in pos or neg field ranges with */
             /* mouse down. */
                while(mouse_poll==1)        /* id=3 */
                        {
                        vq_mouse(handle,&smouse,&xmouse,&ymouse);
                      /* look for mouse down and Y <20 */
                        if (ymouse<20 && smouse == 1) /* go looking */ 
                            {        /*id=4*/
                            if (xmouse>xposmin && xmouse < xposmax)
                                { /*id=5*/
                                ctext=1; /* charge = 1 */
                                mouse_poll=0; /* terminate loop */
                                } /*endid=5*/
                            if (xmouse>xnegmin && xmouse < xnegmax)
                                { /*id=5a*/
                                ctext = -1; /* charge = -1 */
                                mouse_poll=0; /* terminate loop */
                                } /*endid=5a*/
                            } /* end if smouse && y < 20 loop */ /*endid=4*/
                } /* end mouse_poll ==1 loop (polling mouse x,y for +/- */
                         /*endid=3*/
                  /* e.g., while waiting for plus/minus decision */
                clearpn(); /* clear pos/neg area */
             /* Set circle styling; draw circle */
                set_color=vsf_color(handle,white);        /* fill color */
                set_color=vsf_interior(handle,0); /* fill interior: 0 = hollow */
                v_circle(handle,xcircle,ycircle,rcircle); /* circle */
             /* store into array */
                xcoord[i]=xcircle;
             /* y coord is upside down */
                ycoord[i]=(ymax-ycircle)+20; /* scrn-> array */
                charge[i]=ctext;
                i=i+1; /* bump array pointer */
                numpoints=numpoints+1; /* totl # points to plot */
             /* plot a +/- in circle there. Offset differently if color.*/
                if (!color_flag) /* mono */
                        {
                        xtext=(xcircle-4); /* offset to mid-circle */
                        ytext=(ycircle+6); /* Him too. */
                        }
                else
                        {
                        xtext=(xcircle-4); /* offset to mid-circle */
                        ytext=(ycircle+2); /* Him too. */
                        }
                /* ctext is charge set above */
                if(ctext>0)
                        { /*id=3a*/
                        v_gtext(handle,xtext,ytext,"+");
                        } /*endid=3a*/
                else
                        { /*id=3a*/
                        v_gtext(handle,xtext,ytext,"-");
                        } /*endid=3a*/
/* Wait for mouse to come up, since otherwise, it will just plot a circle */
/* on the pos/neg box we just picked.. */
                waitmup();
                } /* terminate while mouse_poll==1 mouse down paragraph id=2 */        
        } /* terminate while key_state==0: he pressed SHIFT id=1 */
        /* Erase the "select a point" stuff */
                clearpn();
        numpoints=numpoints-1; /* because we were one over.. */

        /* if no points picked, ANY key_state exits program */
        if (numpoints < 0)
            key_state = 4;

        /* Now determine if grid mode or pt-pt mode. ALT=grid mode. */
        if (key_state==8) /* ALT pressed */
                gridstyle=1;  /* grid mode */
        else
                gridstyle=0;  /* point-point mode */

/* Wait for mouse to come up, to prevent instant program stop on line start. */
waitmup();
slow();        /* debounce */
}


/* ************* Plot the field lines ************* */
/* This is the procedure that controls plotting the lines. */
plotit()
{

         v_hide_c(handle);
/* Select which plotting style: grid or point-point */

/* grid style: go across screen, horiz & vertical, draw 1 line. */
         if (gridstyle==1)
                {
                linelength=3;
/* Go X across; for each X, do a Y from bottom to top of screen. */
                for(xgridpt=0;xgridpt<xmax;xgridpt=xgridpt+2)
                    {
                        for(ygridpt=0;ygridpt<yscreen;ygridpt=ygridpt+2)
                                {
                                xcurrent=xgridpt; /* for input to cruncher */
                                ycurrent=ygridpt; /* for input to cruncher */
                                x1=xcurrent; /* setup */
                                y1=ycurrent;
                                calcnewxy(); /* crunch out x1,y1 */
/*  old "currents", recorded from x1,y1, above, for "draw from" info. */

/* Set color based on force vector size */
/* 4 color mode: */
                                if (numcolors == 4)
                                    {
                                    if(ivlength < 2.0)
                                        set_color=vsl_color(handle,1); /* b */
                                    if(ivlength >= 2.0 && ivlength <= 5.0)
                                        set_color=vsl_color(handle,2); /* g */
                                    if(ivlength > 5.0)
                                        set_color=vsl_color(handle,3); /* r */
                                      }
/* 16 color mode: */
                                if(numcolors==16)
                                     {
                                    if(ivlength < 0.2)
                                        set_color=vsl_color(handle,1); /* 1 */
                                    if(ivlength > 0.2 && ivlength <= 0.4)
                                        set_color=vsl_color(handle,2); /* 2 */
                                    if(ivlength > 0.4 && ivlength <= 0.6)
                                        set_color=vsl_color(handle,3); /* 3 */
                                    if(ivlength > 0.6 && ivlength <= 0.8)
                                        set_color=vsl_color(handle,4); /* 4 */
                                    if(ivlength > 1.0 && ivlength <= 1.2)
                                        set_color=vsl_color(handle,5); /* 5 */
                                    if(ivlength > 1.2 && ivlength <= 1.4)
                                        set_color=vsl_color(handle,6); /* 6 */
                                    if(ivlength > 1.4 && ivlength <= 1.8)
                                        set_color=vsl_color(handle,7); /* 7 */
                                    if(ivlength > 1.8 && ivlength <= 2.2)
                                        set_color=vsl_color(handle,8); /* 8 */
                                    if(ivlength > 2.2 && ivlength <= 3.0)
                                        set_color=vsl_color(handle,9); /* 9 */
                                    if(ivlength > 3.0 && ivlength <= 4.0)
                                        set_color=vsl_color(handle,10); /* 10 */
                                    if(ivlength > 4.0 && ivlength <= 5.0)
                                        set_color=vsl_color(handle,11); /* 11 */
                                    if(ivlength > 5.0 && ivlength <= 6.0)
                                        set_color=vsl_color(handle,12); /* 12 */
                                    if(ivlength > 6.0 && ivlength <= 8.0)
                                        set_color=vsl_color(handle,13); /* 13 */
                                    if(ivlength > 8.0 && ivlength <= 15.0)
                                        set_color=vsl_color(handle,14); /* 14 */
                                    if(ivlength > 15.0)
                                        set_color=vsl_color(handle,15); /* 15 */
                                        }

/* check screen bounds, try to draw. */

                                if (x1 < xmax && x1 > 1 && y1 < ymax && y1 > 1)
                                {
                                ptsin[0]=xcurrent; /* old  x,y */
                                ptsin[1]=((ymax-ycurrent)+20); 
                                ptsin[2]=x1;                /* calced x */
                                ptsin[3]=((ymax-y1)+20); /* calced y */
                                v_pline(handle,2,ptsin); /* draw line */

/*      sprintf(outstring,"ivl=%f",ivlength);
        v_gtext(handle,width*1,height*6,outstring); */
        
                                } /* terminate bounds check if */
                        } /* terminate y loop */

/* If shift key held down when a new line starts, abort. */

                vq_key_s(handle, &key_state) ; /* get state into keystate */
                if(key_state != 0)
                        goto quit;

                } /* terminate x loop */                                
        } /* terminate if gridmode loop */
        else
        { /* non-grid mode (normal)

/* **************************************** */

/* point-point plotting style. Draw continuous lines. */

/* Select which point to begin plotting from. */

    for(currpt=0;currpt<=numpoints;currpt=currpt+1)
        {
/* can't plot negative points, since they attract the line. */
        if(charge[currpt]<=0)
            continue;        /* bypass the rest of the loop (reloop) */

/* Calc starting point for this line. Use polar coordinates in a  */
/* radius around each positive point. */

/* Generate initial x1,y1. from radius and theta (standard polar stuff) */

        for(degree=1;degree<360;degree=degree+degreeinc)
        {
        theta = degree; 
        theta = theta * (3.14159/180);
        x1 = (radius * cos(theta) );
        y1 = (radius * sin(theta) );
        x1 = ( x1 + xcoord[currpt] );
        y1 = ( y1 + ycoord[currpt] );

        newline = 0; /* flag: do "begin line" draw if 0. */

        doanotherseg = 1; /* flag for following while loop..do another seg..*/

        currcolor=1; /* init color at line's start */
        set_color=vsl_color(handle,currcolor); /* init color */

/* *************************************************************/
/* Next segment entry point */
/* Comes here to draw the next segment of a line. */

        while(doanotherseg == 1)
{
/* ************************************************************ */
/* terminate line test.. if fails, a new line begins.*/
/* if big screen, use 2500 x 2500 field. If little, screensize only. */

        if (clipit == 0)
                /* little screen size check.. */
                {
                if (x1 > xmax || y1 > ymax || x1 <1 || y1 < 1)
                        {
                        doanotherseg=0; /* no new seg.. */
                        }
                }
        else /* clipit != 0 */
                /* big screen size check */
                {
                if (x1 > 2500 || y1 > 2500 || x1 < -2500 || y1 < -2500)
                        doanotherseg=0; /* no new seg.. */
                }

/* ************************************************************ */
/* Test if we are so close to a negative point we are ping-ponging */
/* around it. If so, clip off this line. */

        for(i=0;i<=numpoints;i=i+1)
                {
                if (charge[i]<0)
                        {
                        xdelta = (xcoord[i]-x1);
                        if (xdelta < 0)
                                xdelta = (-1*xdelta); /* abs(xdelta) */
                        ydelta = (ycoord[i]-y1);
                        if (ydelta < 0)
                                ydelta = (-1*ydelta); /* abs(ydelta) */

                        if (xdelta < radius && ydelta < radius)
                                doanotherseg = 0; /* terminate line */
                        } /* end if-charge is neg */
                } /* end for loop */

/* Line drawing. Do we need to begin a line? (Since we essentially do */
/* drawto's later.) */

        if (newline == 0)  /* begin a new line? */
                {
/* don't attempt to start a new line if we're offscreen.. while in */
/* bigscreen mode. */

        if (x1 < xmax && x1 > 1 && y1 < ymax && y1 > 1)
                        {
                        ptsin[0]=x1;
                        ptsin[1]=(( ymax - y1)+20);
                        ptsin[2]=ptsin[0]+1; /* just do a 2 dot draw */
                        ptsin[3]=ptsin[1];

                        xcurrent=x1+1; /* reset these for drawto below */
                        ycurrent=y1;

                        v_pline(handle,2,ptsin); /* Actual line draw */
                        newline=1; /* flag: we have started a new line. */
                        }
                }

/* Line draw. If out-of-bounds, implies big screen mode, and still */
/* in bigscreen range. If so, just set newline flag, so we begin draw */
/* where it re-enters bounds. Otherwise, do a "drawto" from where we were, */
/* using the old ptsin array values. */

        if (x1 < xmax && y1 < ymax && x1 > 1 && y1 > 1 )
                {
/* old "currents", recorded from x1,y1, above, for "draw from" info. */
                ptsin[0]=xcurrent; /* old x */
                ptsin[1]=((ymax-ycurrent)+20); /* old y, offset for menu */

                ptsin[2]=x1;                /* new x */
                ptsin[3]=((ymax-y1)+20); /* new y */
                v_pline(handle,2,ptsin); /* draw line */

/* bump color if in living color. If we go over maximum color #, */
/* wrap to color #1. Leave color 0 alone; that's background. */
/* Hence, it' 1-2-3-1-2-3 or 1-2-3..14-15-1-2-3- .. */

                if (color_flag)
                        {
                        currcolor=currcolor+1;
                        if (currcolor==numcolors) /* if past limit */
                                currcolor=1;        /* reset color */
                        set_color=vsl_color(handle,currcolor); /* vdi color */
                        }
                 }
        else /* we went offscreen in big screen mode */
                {
                newline=0; /* specify a new starting place of line if */
                           /* it ever re-enters the atmosphere */
                }
/* We calc new xy after first pass through loop so it starts at + circle */
/* boundary.. */
        calcnewxy(); /* calc new x1,y1 (see below..complex)*/

        }        /* end "while doanotherseg = 1" loop */

/* If shift key held down when a new line starts, abort. */

                vq_key_s(handle, &key_state) ; /* get state into keystate */
                if(key_state != 0)
                        goto quit;
/* Indenting was too much for screen (all these nested loops) so had to */
/* do it this way. */

    } /* end "next degree" loop */
  } /* end "next point" loop */
 } /* end point-point or grid if-else */

/* entry for early abort. Yes, I used a GOTO, so what? */

quit:
         v_show_c(handle,0);
         slow(); /* debounce */
         if (key_state != 4)
             v_gtext(handle,width*0,height*1,
                 "End MagPlot. CTL exits; SHIFT restarts.");
} /* end of plot-it */


/* ***** charge summer ************ */
/*  Summer of charges at this x,y  */
/* At the current x,y, calculate the vector force on us for each point. */
/* Sum up the vectors as an X and Y displacement, then setup a line draw */
/* of a fixed segment length with the same X and Y slope. Note we cannot */
/* actually calculate the slope because if delta Y is 0, we divide by 0 */
/* (delta X / delta Y) */

calcnewxy()
{
                xcurrent=x1; /* save x,ycurrent as copy of current x1,y1. */
                ycurrent=y1;
                xvectorsum = 0;  /* initialize totals */
                yvectorsum = 0;
                number = 64;     /* quick scaler */
/* Loop through all points: */
                for(i=0;i<=numpoints;i++)
                        {
/* Calculate force with formula:  */
/* constant * charge1 * charge2 / (distance squared) */
/* I used X*X instead of X squared  to try to optimize speed. */

/* xsqr = (current point x - old x) ^ 2 ; same with ysqr. */
                        xsqr=( (xcoord[i]-xcurrent) * (xcoord[i]-xcurrent) );
                        ysqr=( (ycoord[i]-ycurrent) * (ycoord[i]-ycurrent) );
/* FORCE = (ABS(CHARGE(I) * K2) / (XSQR+YSQR)) * NUMBER*/
                        forcetemp = charge[i];
                        if (forcetemp<0)        /* ABS(forcetemp) */
                                forcetemp = (-1*forcetemp);
                        force=( (forcetemp*k2) / (xsqr+ysqr) );
                        xdistance = ( -1* (xcurrent-xcoord[i]) * force );
                        ydistance = ( -1* (ycurrent-ycoord[i]) * force );
                        /* Reverse "polarity" based on charge */
                        if (charge[i]>0)
                                {
                                xdistance = (-1*xdistance);
                                ydistance = (-1*ydistance);
                                }
/* Okay, now add these vectors to our running totals */
                        xvectorsum = xdistance+xvectorsum; /* Add to vector */
                        yvectorsum = ydistance+yvectorsum; /* summation */
                        }        /* end for loop of summer */
/* Now scale the vectors */
                xvectorsum = ( xvectorsum / number );
                yvectorsum = ( yvectorsum / number );
/* Now scale a linelength-sized line to the slope indicated by the vector */
/* sums. */
        xsqr = (xvectorsum * xvectorsum);
        ysqr = (yvectorsum * yvectorsum);
        ivtemp = (xsqr + ysqr); /* determine total length of calced vector */
        ivlength = sqrt ( xsqr + ysqr); /* via pythagoras */
        ivline = ( ivlength / linelength ); /* now adjust it to our fixed len */
/* Make new x1,y1 out of old x1,y1 (xcurrent,ycurrent) and adjustment. */
        x1 = (xcurrent + (xvectorsum / ivline) ); /* and add adjusted to x,y */
        y1 = (ycurrent + (yvectorsum / ivline) );
}

/* ****** init globals *********************** */
/* Initglobals: just sets up controlling vars. */
/* You can have a lot of fun playing with these. */

initglobals()
{
/* starting and ending radius of point. Please leave be. */
        radius=10;                /* radius around each starting point */
/* How "strong" magnetism is. Play your favorite diety! */
        k2=10000;                /* force constant */
/* How far to draw a given segment. Lower makes for finer, slower plot. */
        linelength=5;                /* length plotted of each calced vector */
/* How many degrees to increment polar coords of starting point. Less */
/* gives more lines (denser plot) but takes more time. */
        degreeinc=5;                /* amt of inc in circle at starting point */
/* Boolean. If 0, clips plot to screen size. If nonzero, lets plot go */
/* offscreen, which slows down plot but makes it more "complete". */
        clipit=0;                /* 0 = screen size only, 1 = full screen */
/* Boolean. Turns debugging messages on in earlier revisions. */
        debug=0;              /* my debug messages off */
}

/* **** plot pos/neg ************ */

/* Plot POS NEG  up on menu bar..2 spaces between. */
/* Note that this is more-or-less resolution independent, and where */
/* the POS and NEG plot determines where we look for a mouse-down to */
/* set the + / - charge. */

plotpn()
{
/* Calc text position as 3/4 of full screen.. */
        xtext=(0.75 * xmax); /* absolute starting screen co-ords */
/* Calc all fields as offsets * character width from this.. */
        v_gtext(handle,xtext,(height)-2,"POS  NEG");
/*                                        01234567890 */
/* Set xposmin,max, xnegmin,xnegmax. These are used when inputting */
/* points to make this work in all modes. */

                xposmin=xtext-width;        /* start of POS area */
                xposmax=xtext+(3*width); /* end of POS area */

                xnegmin=xtext+(5*width); /* start of NEG area */
                xnegmax=xtext+(8*width); /* end of NEG area */
}

/* **** Clear pos/neg ******** */

/* Clear pos/neg field, including pesky line fragments */
/* Clears entire menu bar, to be frank (or bill.. Ack!) */
clearpn()
{
        set_color=vsf_color(handle,0);        /* 0 = white, 1 = black */
        ptsin[0] = 0; /* upper left x */
        ptsin[1] = 0;                /* Upper left Y */
        ptsin[2] = xmax;         /* lower right x */
        ptsin[3] = ymenu+1;        /* lower right y. Needs +1. */
        vr_recfl(handle,ptsin); /* do fill.. */
}
/* **** cls ********* */
/* Clears screen to black screen. Since GEM has funny ideas about */
/* what register Black color is, force it to "white", which we have */
/* tweaked in hardware to black, using a constant. */

cls()
{
        v_hide_c(handle);        /* hide cursor, otherwise foulup happens */
        set_color=vsf_color(handle,black);
        ptsin[0] = 0;              /* upper right x */
        ptsin[1] = ymenu-1;        /* Leave menu bar area alone.. up right y */
        ptsin[2] = xmax;           /* lower right x */
        ptsin[3] = yscreen;        /* true y max..lower right y */
        vr_recfl(handle,ptsin);    /* do "fill" */
        v_show_c(handle,0);        /* show cursor, 0=regardless of nesting */
}
/* **** gemopen ******** */
/* This is just the standard workstation stuff. Note, however, we save */
/* the screen size and some color info for later use. */

gemopen()
{
        handle=graf_handle(&width,&height,&dummy,&dummy); /* more magic */
        for(i=0; i<10; i++)
        {
        intin[i]=1; /* set them all to 1 */
        }
        intin[10]=2; /* except for the last one (use "RC coord sys" flag) */
        v_opnvwk(intin, &handle, intout);
        graf_mouse(0,0); /* make a mouse look like an arrow */

        numcolors=intout[13]; /* 2,4, or 16, depending on resolution. */
        color_flag = (numcolors == 4 || numcolors == 16); /* true/false */
/* Determine size of menu bar for fill & offset operations */
        if        (numcolors==2)
                ymenu=20;
        if        (numcolors==4)
                ymenu=10;
        if        (numcolors==16)
                ymenu=10;

        xmax=intout[0]; /* set color / mono width */
        xscreen=intout[0];
        ymax=intout[1]; /* set color / mono heighth */
        yscreen=intout[1];
/* all Y outputs are done as (ymax-y) because screen is inverted.. */
        ymax=ymax-20;        /* (bypass menu bar - 1st 20 scan lines )*/
/* workstation open. */
}

/* ***** waitmup ******** */
waitmup()
/* Waits for mouse button up. */

{
while (smouse == 1) /* 0 = means button up */
        {
        vq_mouse(handle,&smouse,&xmouse,&ymouse);
        smouse=(smouse&1); /* mask to mouse bit; fall into loop test. */
        }
}

/* ***** slow ***** */
/* slow is just a delay loop. Counts up to 32000. */
/* It is used to debounce the mouse (and the user); otherwise you can't */
/* get off the mouse fast enough to start a plot without aborting it. */
slow()
{
int        slowcnt;        /* local */

        slowcnt = 0;
        for (slowcnt=1;slowcnt<32000;slowcnt++);  
}

/* end of code */
