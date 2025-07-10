/* AstroPanic ST  by Charles Brannon */
/* adapted from MULTIFDB.C by Charles Brannon */
/* created June 12 1986 */
/* last modified June 27 1986 */
 
#include <define.h>
#include <gemdefs.h>
#include <obdefs.h>
#include <osbind.h>
#include <stdio.h>
 
#define fdb_XOR 6
#define fdb_REPLACE 3
#define fdb_ERASE 4
#define fdb_TRANS 7
#define fdb_REVTRANS 13
#define rnd(x) (Random()%(x))
#define HIDE_MOUSE graf_mouse(M_OFF,&dummy)
#define SHOW_MOUSE graf_mouse(M_ON,&dummy)
#define COLORMODE work_out[35]
#define NUMSPRITES 6
#define MISSILE_H (COLORMODE? 8 : 16)
#define MISSILE_SPEED (COLORMODE? 7 : 12 )
#define TOPSCREEN 4
#define TEXTBOX 32
 
/* global variables */
 
        int dummy,ch,cw;
        int work_handle,contrl[12],pxyarray[10];
        int intin[128],intout[128],ptsin[128],ptsout[128];
        int work_in[11],work_out[57];
 
        struct my_fdb
        {
                char *fd_addr; /* address of raster */
                int fd_w; /* width in pixels */
                int fd_h; /* height in rows */
                int fd_wdwidth; /* width in words */
                int fd_stand; /* 0 for ST, 1 for standard */
                int fd_nplanes; /* how many planes */
                int fd_r1, fd_r2, fd_r3; /* reserved */
        } saucer,screen,cannon;
 
        int colortab[16][3]; /* used to save colors */
        unsigned long score; /* you know what this is! */
        int ships; /* how many cannons are left */
        int missile; /* flag for whether missile is in flight or not */
        int missile_x,missile_y; /* position of missile in flight */
        int cannon_x, cannon_y; /* horizontal & vertical position of cannon */
        int xborder,yborder; /* screen boundaries */
        int x[NUMSPRITES],y[NUMSPRITES]; /* holds x/y position of sprites */
        int xacc[NUMSPRITES],yacc[NUMSPRITES]; /* acceleration factors */
        int isdead[NUMSPRITES]; /* is this sprite dead? */
        int death_toll; /* saucers shot this round */
        int textline; /* line where text box starts */
        int round; /* current level of game */
        int speed; /* saucer speed */
 
main()
{
        int sprite; /* sprite index */
        int prev_x,prev_y; /* stores previous position of a sprite */
        appl_init();
        init_workstation();
        set_colors();
        HIDE_MOUSE;
        clear_sky();
        form_alert(1,"[1][AstroPanic!|Charles Brannon|(C) 1986 COMPUTE!|][ Let's Play! ]");
        init_shapes();
        xborder=work_out[0]-saucer.fd_w-4;
        textline=work_out[1]-((COLORMODE)? TEXTBOX : TEXTBOX<<1);
        yborder=textline-cannon.fd_h;
        cannon_y=yborder;
        reset_game();
        /* ye olde main loope */
        FOREVER
        {
                check_for_pause();
                for (sprite=0;sprite<NUMSPRITES;sprite++)
                {
                        if (isdead[sprite]) { dumdum(); continue; }
                        prev_x=x[sprite]; prev_y=y[sprite];
                        x[sprite]+=xacc[sprite];
                        y[sprite]+=yacc[sprite];
                        if (x[sprite]<4 || x[sprite]>xborder)
                                xacc[sprite]=-xacc[sprite],x[sprite]=prev_x;
                        if (y[sprite]<TOPSCREEN || y[sprite]>yborder)
                                yacc[sprite]=-yacc[sprite],y[sprite]=prev_y;
                        put(&saucer,prev_x,prev_y,fdb_XOR);
                        put(&saucer,x[sprite],y[sprite],fdb_XOR);
                        if (cannon_y-y[sprite]<8)
                                if ( (cannon_x>=x[sprite] && cannon_x<=x[sprite]+saucer.fd_w) ||
                                        (cannon_x+cannon.fd_w>=x[sprite] && cannon_x+cannon.fd_w<=x[sprite]+saucer.fd_w) )
                                {
                                        kill_cannon();
                                        break;
                                }
                } /* end for */
                move_cannon();
                if (missile) update_missile();
        }
}
 
Terminate(flag)
int flag;
{
        reset_colors();
        v_clsvwk(work_handle);
        appl_exit();
        exit(flag);
}
 
/* dummy routine, for short delay */
dumdum()
{
        int i;
        for (i=0;i++<42-(round<<1););
}
 
reset_game()
{
        missile=FALSE; /* kill missile */
        clear_sky();
        speed=2; /* maximum speed */
        score=round=death_toll=0; ships=3;
        update_scorebox();
        cannon_x=0;
        put (&cannon,cannon_x,cannon_y,fdb_XOR); /* cannon appears */
        init_ufos();
}
 
/* fill sky with stars */
clear_sky()
{
        int star;
        v_clrwk(work_handle);
        vsl_color(work_handle,1);
        vswr_mode(work_handle,1); /* replace */
        for (star=0;star<100;star++)
        {
                pxyarray[2]=pxyarray[0]=rnd(work_out[0]);
                pxyarray[3]=pxyarray[1]=rnd(work_out[1]);
                v_pline(work_handle,2,pxyarray);
        }
}
 
/* allow player to pause game by pressing a key */
check_for_pause()
{
        int key,which;
        /* poll keyboard by waiting for a null time duration */
        which=evnt_multi(MU_TIMER|MU_KEYBD,0,0,0,0,0,0,0,0,0,0,0,0,0,&dummy,0,0,
                &dummy,&dummy,&dummy,&dummy,&key,&dummy);
        if (which & MU_KEYBD) evnt_keybd();
}
 
/* initializes positions and vectors for saucers */
init_ufos()
{
        int sprite;
        death_toll=0; /* no sprites dead yet */
        for (sprite=0;sprite<NUMSPRITES;sprite++)
        {
                isdead[sprite]=xacc[sprite]=yacc[sprite]=0;
                while (xacc[sprite]==0) xacc[sprite]=(speed>>1)-rnd(speed+1);
                while (yacc[sprite]==0) yacc[sprite]=(speed>>1)-rnd(speed+1);
                x[sprite]=8+rnd(xborder-8);
                y[sprite]=8+rnd(yborder-50);
                put (&saucer,x[sprite],y[sprite],fdb_XOR); /* make it appear */
        }
}
 
update_scorebox()
{
        char temp[20];
        int y,d;
        pxyarray[0]=0; pxyarray[1]=textline;
        pxyarray[2]=work_out[0]; pxyarray[3]=work_out[1];
        vswr_mode(work_handle,1); /* replace */
        vsf_color(work_handle,1); /* white */
        vsf_interior(work_handle,1); /* solid */
        v_bar(work_handle,pxyarray);
        vswr_mode(work_handle,2); /* transparent */
        vsl_color(work_handle,COLORMODE? 3 : 0);
        for (y=d=0;y<TEXTBOX;y+=d++)
        {
                pxyarray[0]=0; pxyarray[1]=y+textline;
                pxyarray[2]=work_out[0]; pxyarray[3]=y+textline;
                v_pline(work_handle,2,pxyarray);
        }
        vsl_color(work_handle,1);
        /* draw text in red, if possible */
        vst_color(work_handle,COLORMODE? 2 : 0);
        vst_alignment(work_handle,1,0,&dummy,&dummy); /* center */
        v_gtext(work_handle,work_out[0]>>1,textline+(ch<<1)+(COLORMODE? 0 : ch),"ASTROPANIC");
        vst_color(work_handle,0); /* draw text in black */
        vst_alignment(work_handle,0,0,&dummy,&dummy); /* left */
        sprintf(temp,"Cannons:%d  Level:%d",ships,round+1);
        v_gtext(work_handle,cw,textline+ch*3,temp);
        vst_alignment(work_handle,2,0,&dummy,&dummy); /* right */
        sprintf(temp,"Score:%07lu0",score);
        v_gtext(work_handle,work_out[0]-cw,textline+ch*3,temp);
        vst_alignment(work_handle,0,0,&dummy,&dummy);
        vst_color(work_handle,1);
}
 
/* when cannon is hit, kill it */
kill_cannon()
{
        int lum;
        put (&cannon,cannon_x,cannon_y,fdb_XOR); /* remove cannon */
        if (COLORMODE) setcolor(0,1000,0,0); /* flash screen */
        else setcolor(0,1000,1000,1000); /* monochrome */
        explode(cannon_x+(cannon.fd_w>>1),cannon_y+(cannon.fd_h>>1),8,1);
        if (COLORMODE)
                for (lum=1000;lum>=0;setcolor(0,lum--,0,0));
        else setcolor(0,0,0,0);
        missile=FALSE; /* kill missile */
        --ships; update_scorebox();
        if (ships==0) { end_game(); return; }
        SHOW_MOUSE;
        if (ships==1)
                form_alert(1,"[3][|Last Cannon|][Ready!]");
        else
                form_alert(1,"[3][|Next Cannon|][Ready!]");
        HIDE_MOUSE;
        clear_sky();
        update_scorebox();
        cannon_x=0;
        put (&cannon,cannon_x,cannon_y,fdb_XOR); /* cannon appears */
        init_ufos();
}
 
/* explosion effect radiating from center */
/* flag controls duration of sound effect */
 
explode(xcenter,ycenter,radius,flag)
int xcenter,ycenter,radius,flag;
{
        static char boom[]=
        {0,0, 1,0, 2,0, 3,0, 4,0, 5,0, 6,63, 7,0xf7, 8,0x10, 9,0,
        10,0, 11,0, 12,10, 13,0, 255,0};
        int r;
        boom[25]=flag? 20 : 10;
        Dosound(boom);
        vswr_mode(work_handle,3); /* XOR */
        vsf_interior(work_handle,0); /* hollow circle */
        for (r=0;r<radius;v_circle(work_handle,xcenter,ycenter,r+=2));
        for (r=0;r<radius;v_circle(work_handle,xcenter,ycenter,r+=2));
        vswr_mode(work_handle,1); /* normal */
}
 
end_game()
{
        SHOW_MOUSE;
        if (form_alert(1,"[2][Play Again?][YES|NO]")==1)
        {
                reset_game();
                HIDE_MOUSE;
        }
        else Terminate(0);
}
 
/* moves cannon, checks for fire button */
move_cannon()
{
        int button,x,y,oldx;
        static int released=TRUE;
        static char blip[]=
        {0,0, 1,0, 2,10, 3,0, 4,0, 5,0, 6,0, 7,0xfd, 8,0, 9,16,
        10,0, 11,0, 12,8, 13,4, 255,0};
        oldx=cannon_x;
        vq_mouse(work_handle,&button,&x,&y);
        if (button&2)
        {
                if (released)
                {
                        if (missile) draw_missile(); /* erase old missile */
                        Dosound(blip);
                        missile=TRUE; missile_x=cannon_x+(cannon.fd_h>>1);
                        missile_y=cannon_y;
                        draw_missile();
                        released=FALSE;
                }
        }
        else released=TRUE;
        cannon_x=(x<work_out[0]-cannon.fd_w)? x : work_out[0]-cannon.fd_w;
        if (cannon_x != oldx)
        {
                put (&cannon,oldx,cannon_y,fdb_XOR);
                put (&cannon,cannon_x,cannon_y,fdb_XOR);
        }
}
 
/* moves missile to next position, if missile is on screen */
update_missile()
{
        int sprite;
        draw_missile(); /* erase old missile */
        if ((missile_y-=MISSILE_SPEED)>TOPSCREEN)
                draw_missile(); /* draw new missile */
        else missile=FALSE; /* end of mission */
        for (sprite=0;sprite<NUMSPRITES;sprite++)
        {
                if (!isdead[sprite] && missile_x>=x[sprite] && missile_x<=x[sprite]+saucer.fd_w)
                        if ( (y[sprite]>=missile_y && y[sprite]<=missile_y+MISSILE_H) ||
                                (y[sprite]+saucer.fd_h>=missile_y && y[sprite]+saucer.fd_h<=missile_y+MISSILE_H) )
                        {
                                killsprite(sprite);
                                break;
                        }
        }
}
 
killsprite(which)
int which;
{
        put (&saucer,x[which],y[which],fdb_XOR); /* remove saucer */
        draw_missile(); /* remove missile */
        missile=FALSE;
        explode(x[which]+(saucer.fd_w>>1),y[which],8,0);
        isdead[which]=TRUE;
        score+=(COLORMODE? y[which] : (y[which]<<1));
        update_scorebox();
        if (++death_toll==NUMSPRITES)
        {
                init_ufos();
                if (round<20)
                {
                        round++; /* next round */
                        update_scorebox();
                }
                if (speed<(COLORMODE? 16 : 24)) speed++;
        }
}
 
/* draws missile at missile_x, missile_y, with XOR */
draw_missile()
{
        vswr_mode(work_handle,3); /* XOR drawing mode */
        vsl_color(work_handle,1); /* white */
        pxyarray[0]=missile_x; pxyarray[1]=missile_y-MISSILE_H;
        pxyarray[2]=missile_x; pxyarray[3]=missile_y;
        v_pline(work_handle,2,pxyarray);
        vswr_mode(work_handle,1); /* replace mode */
        vsl_color(work_handle,1); /* black */
}
 
/* Saves colors in global array colortab[] */
save_colors()
{
        int i;
        for (i=0;i<16;i++)
                vq_color(work_handle,i,0,colortab[i]);
}
 
/* sets colors for this program */
set_colors()
{
        save_colors();
        setcolor(0,0,0,0); /* black */
        setcolor(1,1000,1000,1000); /* white */
}
 
setcolor(index,red,green,blue)
int index,red,green,blue;
{
        int rgb_in[3];
        rgb_in[0]=red; rgb_in[1]=green; rgb_in[2]=blue;
        vs_color(work_handle,index,rgb_in);
}
 
reset_colors()
{
        int i;
        for (i=0;i<16;i++)
                vs_color(work_handle,i,colortab[i]);
}
        
/* waits for a period of time */
delay(period)
int period;
{
        evnt_timer(period,0);
}
 
/* returns TRUE if mouse button clicked, else FALSE */
int clicked()
{
        int pstatus;
        vq_mouse(work_handle,&pstatus,&dummy,&dummy);
        return(pstatus&2);
}
 
/* initializes the shapes according to screen resolution */
init_shapes()
{
        screen.fd_addr=0; /* screen memory */
        switch (work_out[13]) /* number of colors */
        {
        /* high res, 640 x 400 */
        case 2: ufo_high();
                        cannon_high();
                        break;
        /* medium res, 640 x 200 */
        case 4: ufo_med();
                        cannon_med();
                        break;
        /* low res, 320 x 200 */
        case 16: ufo_low();
                         cannon_low();
                         break;
        }
}
 
/* initializes data for high-res saucer shape */
ufo_high()
{
        static int ufohigh[]=
        {7,0x8000,0x18,0x6000,0x20,0x1000,0x40,0x800,0x1ff,0xfc00,
        0x1e49,0x27c0,0x7fff,0xfff0,0x8000,8,0x6aaa,0xaab0,0x1d55,
        0x55c0,0x3ff,0xfe00,0,0};
        saucer.fd_addr=(char *) ufohigh; /* raster memory */
        saucer.fd_w=29; /* width in pixels */
        saucer.fd_h=11; /* height in rows */
        saucer.fd_wdwidth=2; /* width in words */
        saucer.fd_stand=1; /* standard FDB? */
        saucer.fd_nplanes=1; /* one plane */
}
 
cannon_high()
{
        static int cannonhigh[]=
        {16,0,16,0,16,0,0x38,0,0x54,0,0x306c,0x19c0,0x68aa,0x2df0,
        0x68aa,0x2c08,0xc4ba,0x46b0,0xd3ab,0x97c0,0xc8ba,0x2600,
        0xd6aa,0xd600,0xd6aa,0xd600,0xc8ba,0x2600,0xd3ab,0x9600,
        0xc4ba,0x4600,0x68aa,0x2c00,0x6828,0x2c00,0x307c,0x1800,0x38,0};        
 
        cannon.fd_addr=(char *) cannonhigh; /* raster memory */
        cannon.fd_w=23; /* width in pixels */
        cannon.fd_h=20; /* height in rows */
        cannon.fd_wdwidth=2; /* width in words */
        cannon.fd_stand=1; /* standard FDB? */
        cannon.fd_nplanes=1; /* one plane */
}
 
/* initializes data for medium-res saucer shape */
ufo_med()
{
        static int ufomed[]=
        {
                0,0,0xf800,0,0,0x701,
                15,8,0xff00,0x100,0,0x800,
                0x1ff,0x1ff,0xfff8,0xfff8,0x28,0x701,
                0xffff,0x5555,0xffff,0x5555,0xf1c0,0x5800,
                0x3fff,0x3fff,0xffff,0xffff,0x8000,0x8000,
                0,0xff,0,0xffe0,0x8b0,0
        };
        saucer.fd_addr=(char *) ufomed; /* raster memory */
        saucer.fd_w=36; /* width in pixels */
        saucer.fd_h=6; /* height in rows */
        saucer.fd_wdwidth=3; /* width in words */
        saucer.fd_stand=0; /* not a standard FDB */
        saucer.fd_nplanes=2; /* two planes */
}
 
cannon_med()
{
        static int cannonmed[]=
        {       /* plane zero */
                0x40,0, 0x40,0, 0xa0,0, 0x1f0,0, 0x21f0,0x8000,
                0x51f1,0x4000, 0xd7fd,0x6000, 0xdfff,0x6000,
                0xd9f3,0x6000, 0x50a1,0x4000, 0x2000,0x8000,
                /* plane one */
                0,0, 0,0, 0xe0,0, 0x1b0,0, 0x21f0,0x8000,
                0x7111,0xc000, 0xf7fd,0xe000, 0xff1f,0xe000,
                0xf9f3,0xe000, 0x70e1,0xc000, 0x2000,0x8000
        };      
 
        cannon.fd_addr=(char *) cannonmed; /* raster memory */
        cannon.fd_w=19; /* width in pixels */
        cannon.fd_h=11; /* height in rows */
        cannon.fd_wdwidth=2; /* width in words */
        cannon.fd_stand=1; /* standard FDB? */
        cannon.fd_nplanes=2; /* two planes */
        vr_trnfm(work_handle,&cannon,&cannon);
}
 
/* initializes shapes for low resolution */
ufo_low()
{
        static int ufolow[]=
        {0,7,0,7,0,0x8000,0,0x8000,
         1,0x1e,0,0x1e,0x8000,0x6000,0,0x6000,
         0,0x3f,0,0x3f,0x4000,0xb000,0,0xb000,
         0,0x7f,0,0x7f,0,0xf800,0,0xf800,
         0x1ff,0,0,0,0xfc00,0,0,0,
         0,1e49,0x1b6,0x1b6,0,0x27c0,0xd800,0xd800,
         0,0x7fff,0x7fff,0x7fff,0,0xfff0,0xfff0,0xfff0,
         0x8000,0,0xffff,0,8,0,0xfff8,0,
         0x6aaa,0x1555,0x7fff,0,0xaab0,0x5540,0xfff0,0,
         0x1d55,0x1d55,0x1d55,0x1d55,0x55c0,0x55c0,0x55c0,0x55c0,
         0x3ff,0x3ff,0,0,0xfe00,0xfe00,0,0};
 
        saucer.fd_addr=(char *) ufolow; /* raster memory */
        saucer.fd_w=29; /* width in pixels */
        saucer.fd_h=11; /* height in rows */
        saucer.fd_wdwidth=2; /* width in words */
        saucer.fd_stand=0; /* not a standard FDB */
        saucer.fd_nplanes=4; /* four planes */
}
 
cannon_low()
{
        static int cannonlow[]=
        {0,16,0,0,0,0,0,0,
         0,16,0,0,0,0,0,0,
         0,16,0,0,0,0,0,0,
         0,0x38,0,0,0,0,0,0,
         0x28,0x54,0,0,0,0,0,0,
         0,0x307c,0x3010,0x3000,0x1c0,0x1800,0x1800,0x1800,
         0x1000,0x78fe,0x7854,0x7800,0x11f0,0x3c00,0x3c00,0x3c00,
         0x1000,0x78fe,0x7854,0x7800,0x1008,0x3c00,0x3c00,0x3c00,
         0x3800,0xfcfe,0xfc44,0xfc00,0x38b0,0x7e00,0x7e00,0x7e00,
         0x2c00,0xefff,0xff55,0xef01,0x69c0,0xee00,0xfe00,0xee00,
         0x3701,0xf7ff,0xff45,0xf701,0xd800,0xde00,0xfe00,0xde00,
         0x2901,0xe9ff,0xff55,0xe901,0x2800,0x2e00,0xfe00,0x2e00,
         0x2901,0xe9ff,0xff55,0xe901,0x2800,0x2e00,0xfe00,0x2e00,
         0x3701,0xf7ff,0xff45,0xf701,0xd800,0xde00,0xfe00,0xde00,
         0x2c00,0xefff,0xff55,0xef01,0x6800,0xee00,0xfe00,0xee00,
         0x3800,0xfcfe,0xfc44,0xfc00,0x3800,0x7e00,0x7e00,0x7e00,
         0x1000,0x78fe,0x7854,0x7800,0x1000,0x3c00,0x3c00,0x3c00,
         0x1000,0x787c,0x7854,0x7800,0x1000,0x3c00,0x3c00,0x3c00,
         0,0x307c,0x3000,0x3000,0,0x1800,0x1800,0x1800,
         0x38,0,0,0,0,0,0,0};   
 
        cannon.fd_addr=(char *) cannonlow; /* raster memory */
        cannon.fd_w=23; /* width in pixels */
        cannon.fd_h=20; /* height in rows */
        cannon.fd_wdwidth=2; /* width in words */
        cannon.fd_stand=0; /* not standard FDB */
        cannon.fd_nplanes=4; /* four planes */
}
 
put(shape,xpos,ypos,mode)
struct my_fdb *shape;
int xpos,ypos,mode;
{
        pxyarray[0]=0; pxyarray[1]=0;
        pxyarray[2]=shape->fd_w-1; pxyarray[3]=shape->fd_h-1;
        pxyarray[4]=xpos; pxyarray[5]=ypos;
        pxyarray[6]=xpos+pxyarray[2];
        pxyarray[7]=ypos+pxyarray[3];
        vro_cpyfm(work_handle,mode,pxyarray,shape,&screen);
}
 
init_workstation()
{
        int i, handle;
        work_handle=handle=graf_handle(&cw,&ch,&dummy,&dummy);
        for (i=0;i<10;work_in[i++]=1); work_in[10]=2;
        v_opnvwk(work_in,&work_handle,work_out);
        if (!work_handle) exit(-1); /* error if we can't open */
}
 
