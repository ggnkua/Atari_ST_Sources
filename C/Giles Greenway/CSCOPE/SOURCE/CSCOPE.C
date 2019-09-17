#include<aes.h>
#include<vdi.h>
#include<osbind.h>
#include<linea.h> 
#include<stdlib.h>
#include<stdio.h>
#include<dos.h>
#include<string.h>
#include<math.h>
#include"cscp_res.h"
#include"cscp_res.c"

char *token[] = {"+","-","*","/","^","ln","exp",
                   "sinh","cosh","tanh","sin","cos","tan"};
                   
int prior_tab[] = {1,1,2,2,2,2,2,2,2,2,2,2,2};

int tokenize(input,typ,attrib,val)
char *input;
int typ[40],attrib[40],val[40];
{
    int ptr,tok_ptr,num,val_ptr,prior,loop1,loop2,ok,len,lngth,err;

    ptr = 0; tok_ptr = 0; num = 0; val_ptr = 0; prior = 0; err = 0;
         
    lngth = strlen(input); 


    while(input[ptr] != 0 && ptr < lngth)
    {   

        if (input[ptr] >= '0' && input[ptr] <= '9')
        {
            num = 0;   
                        
            while (input[ptr] >= '0' && input[ptr] <= '9')
            {
                num = 10 * num + (input[ptr] - '0');
                ptr++;
                
                if (num > 999) {err = -4; goto error;}

            }           
                  
            attrib[tok_ptr] = val_ptr;
            typ[tok_ptr] = 1;
            tok_ptr++;

            val[val_ptr] = num;
            val_ptr++;
        }
        else
        {
            switch (input[ptr])
            {
                case '(': prior = prior + 2; ptr++; break;
                case ')': prior = prior - 2; ptr++; 
                if (prior < 0) {err = - 3; goto error;} break;
                case 'z': typ[tok_ptr] = 2; ptr++; tok_ptr++; break;
                case 'u': typ[tok_ptr] = 3; ptr++; tok_ptr++; break;
                case ' ': ptr++; break;
                default:    

                for(loop1 = 0;loop1 <= 12;loop1++)
                {
                    ok = 1;
                    len = strlen(token[loop1]);                                

                    for (loop2 = 0;loop2 < len;loop2++)
                    {
                        if (token[loop1][loop2] != input[ptr + loop2]) 
                        ok = 0;                             
                    }
                                
                    if (ok == 1)
                    {
                        ok = 2;
                        attrib[tok_ptr] = prior_tab[loop1] + prior;
                        typ[tok_ptr] = -loop1;
                        tok_ptr++;
                        ptr = ptr + len;
                        break;               
                    }                        
                }
                if (ok != 2) {err = -1; goto error;}               

            }         
        }
    }           
    if (prior > 0) err = -2; if (prior < 0) err = - 3;
    
    error: if (err >= 0) return tok_ptr; else return err;           
}

int rev_pol(typ_in,attr_in,typ_out,attr_out,num)
int typ_in[40],attr_in[40],typ_out[40],attr_out[40],num;
{
    int tmp_typ[40],tmp_attr[40],tmp_ptr,out_ptr,loop,test_ptr,okay;
    
    tmp_ptr = 0; out_ptr = 0;

    for (loop = 0;loop <= num;loop++)
    {
    
        if (typ_in[loop] > 0)
        {
            typ_out[out_ptr] = typ_in[loop];
            attr_out[out_ptr] = attr_in[loop];
            out_ptr++;
        }
        else
        {
            while(tmp_attr[tmp_ptr-1] > attr_in[loop] && tmp_ptr > 0)
            {
                tmp_ptr--;
                typ_out[out_ptr] = tmp_typ[tmp_ptr];
                attr_out[out_ptr] = tmp_attr[tmp_ptr];
                out_ptr++;      
            }
            tmp_typ[tmp_ptr] = typ_in[loop];
            tmp_attr[tmp_ptr] = attr_in[loop];
            tmp_ptr++;
            
                
        }
    }

    while(tmp_ptr > 0)
    {
        tmp_ptr--;
        typ_out[out_ptr] = tmp_typ[tmp_ptr];
        attr_out[out_ptr] = tmp_attr[tmp_ptr];
        out_ptr++;      
    }

    test_ptr = 0,okay = 1;

    for (loop=0;loop<=num;loop++)
    {
        if (typ_out[loop] > 0) test_ptr++;
        else
        {
            if (typ_out[loop] < -4) test_ptr--;
            else test_ptr = test_ptr - 2; 
                    
            if (test_ptr < 0) {okay = 0; break;}   
            
            test_ptr++;
        }
  
    } 

    if (test_ptr != 1) okay = 0;
    if (okay == 1) return 0; else return -1;

}

void rp_eval(r_z,i_z,r_u,i_u,typ,attr,values,mtok)
double *r_z,*i_z,r_u,i_u;
int *typ,*attr,*values,mtok;
{

	double r_stk[40],i_stk[40],r_tmp1,i_tmp1,r_tmp2,i_tmp2,tmp,tmp1,tmp2;
	int typ_stk[40],attr_stk[40],stk_ptr,loop,ptr1,loop2,n;

	stk_ptr = 0;

	for (loop=0;loop<=mtok;loop++)
	{
		
		if (typ[loop] > 0)
		{
			typ_stk[stk_ptr] = typ[loop];
			attr_stk[stk_ptr] = attr[loop];
			switch(typ[loop])
			{
				case 1:
					r_stk[stk_ptr] = (double)(values[loop]);
					i_stk[stk_ptr] = 0.0;
					stk_ptr++;
				break;
				case 2:
					r_stk[stk_ptr] = *r_z;
					i_stk[stk_ptr] = *i_z;
					stk_ptr++;
				break;
				case 3:
					r_stk[stk_ptr] = r_u;
					i_stk[stk_ptr] = i_u;
					stk_ptr++;
			}
		}	
		else
		{
			switch(typ[loop])
			{
				case 0:
					stk_ptr--;
					ptr1 = stk_ptr - 1;
					r_stk[ptr1] += r_stk[stk_ptr];
					i_stk[ptr1] += i_stk[stk_ptr];
				break;
				case -1:
					stk_ptr--;
					ptr1 = stk_ptr - 1;
					r_stk[ptr1] -= r_stk[stk_ptr];
					i_stk[ptr1] -= r_stk[stk_ptr];
				break;
				case -2:
					stk_ptr--;
					ptr1 = stk_ptr - 1;
					r_tmp1 = r_stk[ptr1];
					i_tmp1 = i_stk[ptr1];
					r_stk[ptr1] = r_stk[stk_ptr] * r_tmp1 
					- i_stk[stk_ptr] * i_tmp1;
					i_stk[ptr1] = r_tmp1 * i_stk[stk_ptr]
					+ i_tmp1 * r_stk[stk_ptr];
				break;							
				case -4:
					stk_ptr--;
					ptr1 = stk_ptr - 1;
					if (typ_stk[stk_ptr] == 1)
					{
						r_tmp1 = r_stk[ptr1];
						i_tmp1 = i_stk[ptr1];
						r_tmp2 = r_tmp1;
						i_tmp2 = i_tmp1;
						n = values[attr[stk_ptr]];
						for(loop2 = 1;loop2 < n;loop2++)
						{
							tmp = r_tmp1;
							r_tmp1 = tmp * r_tmp2 - i_tmp1 * i_tmp2;
							i_tmp1 = tmp * i_tmp2 + i_tmp1 * r_tmp2;	
						}
						r_stk[ptr1] = r_tmp1;
						i_stk[ptr1] = i_tmp1;			
					}
				break;
				case -7:
					ptr1 = stk_ptr - 1;
					r_tmp1 = r_stk[ptr1];
					i_tmp1 = i_stk[ptr1];
					tmp1 = exp(r_tmp1);
					tmp2 = 1.0 / tmp1;
					r_stk[ptr1] = cos(i_tmp1)*(tmp1 - tmp2) / 2.0;
					i_stk[ptr1] = sin(i_tmp1)*(tmp1 + tmp2) / 2.0;
				break;
				case -8:
					ptr1 = stk_ptr - 1;
					r_tmp1 = r_stk[ptr1];
					i_tmp1 = i_stk[ptr1];
					tmp1 = exp(r_tmp1);
					tmp2 = 1.0 / tmp1;
					r_stk[ptr1] = cos(i_tmp1)*(tmp1 + tmp2) / 2.0;
					i_stk[ptr1] = sin(i_tmp1)*(tmp1 - tmp2) / 2.0;
				break;
				case -10:
					ptr1 = stk_ptr - 1;
					r_tmp1 = r_stk[ptr1];
					i_tmp1 = i_stk[ptr1];
					tmp1 = exp(i_tmp1);
					tmp2 = 1.0 / tmp1;
					r_stk[ptr1] = sin(r_tmp1)*(tmp2 + tmp1) / 2.0;
					i_stk[ptr1] = cos(r_tmp1)*(tmp1 - tmp2) / 2.0;	
				break;
				case -11:
					ptr1 = stk_ptr - 1;
					r_tmp1 = r_stk[ptr1];
					i_tmp1 = i_stk[ptr1];
					tmp1 = exp(i_tmp1);
					tmp2 = 1.0 / tmp1;
					r_stk[ptr1] = cos(r_tmp1)*(tmp2 + tmp1) / 2.0;
					i_stk[ptr1] = sin(r_tmp1)*(tmp2 - tmp1) / 2.0;
				 
			}								
		}		
	}
		
		*r_z = r_stk[0];
		*i_z = i_stk[0];

}


int main()
{
        char *input,path[FMSIZE],fname[FNSIZE];
        
        int typ[40],attrib[40],val[40],rp_typ[40],rp_attr[40],
        n_tokens,max_tok,bail_out,syntax,mode;
        
        double re_min,re_max,im_min,im_max,re_u,im_u,cut_off,cut_sq,
        r_range,i_range,swap,u_real,u_imag,
		z_real,z_imag;       
       
		void *scrn_1,*scrn_2;

		unsigned long mask,block;

        short f_x,f_y,f_w,f_h,i_x,i_y,i_w,i_h,junk,choice,res,
        xpix,ypix,n_cols,handle,wrk_in[11],wrk_out[57],x_loop,y_loop,
		i_loop,button,loop,col_mod,escape,col,esc_col,fsel,ok_but;

		short old_col[16];
		short col_dat[3][16] = {{1792,1808,1840,1872,1904,1392,880,112,
								 97,83,69,55,551,1047,1543,0},
								{1792,112,7,0,0,0,0,0,0,0,0,0,0,0,0,0},
								{1911,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}};	


		TEDINFO *txt;

		FILE *f_ptr;

		mask = ~255;
		
		linea0();

        appl_init();
        
		rsrc_init();

		scrn_1 = Physbase();
       	block = calloc(32768,1);
		scrn_2 = (block & mask) + 256;
		
        
    graf_mouse(0,0); 
    
    handle = graf_handle(&junk,&junk,&junk,&junk);
    wrk_in[10] = 2;
    v_opnvwk(wrk_in,&handle,wrk_out);    

    xpix = wrk_out[0]; ypix = wrk_out[1]; n_cols = wrk_out[13];

    res = -1;
    
    if (xpix == 319 & ypix == 199 & n_cols == 16) {res = 0; col_mod = 15;}
    if (xpix == 639 & ypix == 199 & n_cols == 4) {res = 1; col_mod = 3;}
    if (xpix == 639 & ypix == 399 & n_cols == 2) {res = 2; col_mod = 2;}
    
	if (res == 2) esc_col = 1; else esc_col = col_mod;

    if (res < 0) 
    {
        form_alert(1,"[1][This display is not supported !][ Okay ]");
        v_clsvwk(handle);
        goto exit;
    }
          

    use_form: choice = INF_BUT;
   
    while (choice == INF_BUT)
    {

		form_center(MAIN_FRM,&f_x,&f_y,&f_w,&f_h);
    	form_center(INF_FRM,&i_x,&i_y,&i_w,&i_h);



        form_dial(FMD_START,junk,junk,junk,junk,f_x,f_y,f_w,f_h);        
        objc_draw(MAIN_FRM,0,32767,f_x,f_y,f_w,f_h);
        choice = form_do(MAIN_FRM,FZ_BOX);        
        form_dial(FMD_FINISH,junk,junk,junk,junk,f_x,f_y,f_w,f_h);
		MAIN_FRM[OK_BUT].ob_state &= ~SELECTED;

      
        if (choice == INF_BUT)
        {
			MAIN_FRM[INF_BUT].ob_state &= ~SELECTED;  
            form_dial(FMD_START,junk,junk,junk,junk,i_x,i_y,i_w,i_h);        
            objc_draw(INF_FRM,0,32767,f_x,f_y,f_w,f_h);
            form_do(INF_FRM,0);
            form_dial(FMD_FINISH,junk,junk,junk,junk,i_x,i_y,i_w,i_h);
			INF_FRM[INF_OK].ob_state &= ~SELECTED;    
        
        }
    }

    if (choice == QUI_BUT) goto exit;
    
    txt = MAIN_FRM[FZ_BOX].ob_spec;
	input = txt->te_ptext;

    n_tokens = tokenize(input,typ,attrib,val);

    if (n_tokens < 1)
    {
        switch(n_tokens)
        {
            case 0: form_alert(1,"[1][Nothing to do !][ Okay ]"); break;
            case -1: form_alert(1,
            "[1][Unrecognized token !][ Okay ]"); break; 
            case -2: form_alert(1,"[1][Unmatched '(' !][ Okay ]"); break;
            case -3: form_alert(1,"[1][Unmatched ')' !][ Okay ]"); break; 
            case -4: form_alert(1,
            "[1][Constant too big !][ Okay ]"); break;  
        }
        goto use_form;    
    }

    max_tok = n_tokens - 1;
    
    syntax = rev_pol(typ,attrib,rp_typ,rp_attr,max_tok);
    
    if (syntax < 0)
    {
        form_alert(1,"[1][Syntax error !][ Okay ]");
        goto use_form;
    }

	txt = MAIN_FRM[RMIN_BOX].ob_spec;
    re_min = atof(txt->te_ptext);
	txt = MAIN_FRM[RMAX_BOX].ob_spec;
    re_max = atof(txt->te_ptext);
    
	txt = MAIN_FRM[IMIN_BOX].ob_spec;
    im_min = atof(txt->te_ptext);
	txt = MAIN_FRM[IMAX_BOX].ob_spec;
    im_max = atof(txt->te_ptext);
    
	txt = MAIN_FRM[REU_BOX].ob_spec;
    re_u = atof(txt->te_ptext);
	txt = MAIN_FRM[IMU_BOX].ob_spec;
    im_u = atof(txt->te_ptext);

    if (re_min > re_max)
    {
        swap = re_min; re_min = re_max; re_max = swap;
    }
    
    if (im_min > im_max)
    {
        swap = im_min; im_min = im_max; im_max = swap;    
    }
    
    r_range = fabs(re_max - re_min);
    
    if (r_range < 0.0001)
    {
        form_alert(1,"[1][Real range too small !][ Okay ]");
        goto use_form;
    }

    i_range = fabs(im_max - im_min);
    
    if (i_range < 0.0001)
    {
        form_alert(1,"[1][Imaginary range too small !][ Okay ]");
        goto use_form;
    }
   
	txt = MAIN_FRM[CUT_BOX].ob_spec; 
    cut_off = atof(txt->te_ptext);
	cut_sq = cut_off * cut_off;
    
	txt = MAIN_FRM[MAXIT_BOX].ob_spec;
    bail_out = atoi(txt->te_ptext);
    

	if (MAIN_FRM[MAN_BUT].ob_state == SELECTED)
		mode = 1;
	else
		mode = 0;

	
	if (mode == 0) 
	{
		u_real = re_u; u_imag = im_u;
	}
	
	graf_mouse(256,0);
	Setscreen(scrn_2,scrn_2,-1);
	for (loop=0;loop <= 15;loop++) 
	old_col[loop] = Setcolor(loop,col_dat[res][loop]);
		
	v_clrwk(handle);

	for (x_loop = 0; x_loop <= xpix; x_loop++)
	{
		for (y_loop	= 0; y_loop <= ypix; y_loop++)
		{
			
			if (mode == 1)
			{		
				z_real = 0; z_imag = 0;
				u_real = re_min + (x_loop * r_range) / xpix;
				u_imag = im_min + ((ypix - y_loop) * i_range) / ypix;
			}
			else
			{
				z_real = re_min + (x_loop * r_range) / xpix;
				z_imag = im_min + ((ypix - y_loop) * i_range) / ypix;
			}
			
			escape = 0;		

			for (i_loop = 0; i_loop <= bail_out; i_loop++)
			{
				
				rp_eval(&z_real,&z_imag,u_real,u_imag,
				rp_typ,rp_attr,val,max_tok);
				
				if (z_real * z_real + z_imag * z_imag > cut_sq) 
				{escape = 1; break;}
				
			}
	
			if (escape) col = i_loop % col_mod; else col = esc_col;

			putpixel(x_loop,y_loop,col);
	
			graf_mkstate(&junk,&junk,&button,&junk);
			if (button)
			{
				Setpallete(old_col);
				Setscreen(scrn_1,scrn_1,-1);
				graf_mouse(257,0);
				choice = form_alert(1,
				"[2][ Plotting Interrupted !][Continue|Re-start|Quit]");
				switch(choice)
				{
					case 1: 
						graf_mouse(256,0); 
						Setscreen(scrn_2,scrn_2,-1);
						Setpallete(col_dat[res]);
					break; 
					case 2: goto use_form;
					case 3: goto exit;
				}
			}
		}
 
	}
		Setpallete(old_col);
		Setscreen(scrn_1,scrn_1,-1);
		graf_mouse(257,0);
		
		choice = form_alert(1,"[2][Save the image ?][Yea|Neigh]");

		if (choice == 1)
		{
			Dgetpath(path,0);
			switch(res)
			{
				case 0: 
					sprintf(fname,"FRAC.PI1"); 
					strcat(path,"\\*.PI1");
				break;
				case 1:
					sprintf(fname,"FRAC.PI2");
					strcat(path,"\\*.PI2");
				break;
				case 2:
					sprintf(fname,"FRAC.PI3");
					strcat(path,"\\*.PI3");
			}

			fsel = fsel_exinput(path,fname,&ok_but,"Save .PI? file:");

			if (fsel && ok_but)
			{
				chdir(path);

				f_ptr = fopen(fname,"wb");

				if (f_ptr)
				{
					fwrite(&res,2,1,f_ptr);
					fwrite(col_dat[res],32,1,f_ptr);
					fwrite(scrn_2,32000,1,f_ptr);
					fclose(f_ptr);
				}

			}			

		}

		goto use_form;

	exit:

    v_clsvwk(handle);   
        
        appl_exit();

		free(block);

    return 0;
}
            
 