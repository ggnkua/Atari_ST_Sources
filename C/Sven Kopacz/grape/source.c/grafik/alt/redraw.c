
void n_pic_dith(int wid, int x, int y, int w, int h)
{
	int	swx, swy, ww, wh, pxy[4], a;
	GRECT ob, soll;
	LAY_LIST	*l=first_lay;
	unsigned char	*b_red, *b_blue, *b_yellow;
	long size, p_off, l_dif;

	if(otoolbar[LAYLED].ob_spec.bitblk->bi_color==3)
	{	/* Solo ist an */
		solo_pic_dith(wid, x, y, w, h);
		return;
	}

	
	wind_get(wid, WF_WORKXYWH, &swx, &swy, &ww, &wh);
	otoolbar[0].ob_x=swx+OTBB/2; otoolbar[0].ob_y=swy+OTBB/2; otoolbar[0].ob_width=ww-OTBB;
	otoolbar[TBR].ob_x=swx+ww-otoolbar[TBR].ob_width-otoolbar[0].ob_x;
	otoolbar[LAYERS].ob_width=otoolbar[TBR].ob_x-otoolbar[TBL].ob_x-otoolbar[TBL].ob_width;
	otoolbar[TBDUM].ob_width=ww;
	swy+=otoolbar[0].ob_height+OTBB; wh-=otoolbar[0].ob_height+OTBB;
	ob.g_x=otoolbar[0].ob_x-OTBB/2; ob.g_y=otoolbar[0].ob_y-OTBB/2;
	ob.g_w=otoolbar[0].ob_width+OTBB; ob.g_h=otoolbar[0].ob_height+OTBB;
	soll.g_x=x; soll.g_y=y; soll.g_w=w; soll.g_h=h;
	if(rc_intersect(&soll, &ob))
		objc_draw(otoolbar, 0, 8, ob.g_x, ob.g_y, ob.g_w, ob.g_h);

	ob.g_x=soll.g_x; ob.g_w=soll.g_w;
	ob.g_y=swy; ob.g_h=wh;
	if(rc_intersect(&soll, &ob))
	{	
		p_width=(((long)(ob.g_w+5))/6)*6;

		size=(long)ob.g_h*(long)p_width;
		b_red=(unsigned char*)malloc(size);
		b_blue=(unsigned char*)malloc(size);
		b_yellow=(unsigned char*)malloc(size);


		a=count_layers();
		if(red_list) free(red_list);
		if(yellow_list) free(yellow_list);
		if(blue_list) free(blue_list);
		if(type_list) free(type_list);
		red_list=(void**)malloc((a+2)*sizeof(unsigned char*));
		yellow_list=(void**)malloc((a+2)*sizeof(unsigned char*));
		blue_list=(void**)malloc((a+2)*sizeof(unsigned char*));
		type_list=(int*)malloc((a+2)*sizeof(int));
		if((!red_list)||(!yellow_list)||(!blue_list)||(!type_list))
		{
			form_alert(1,"[3][Nicht genug Speicher|fr Redraw!][Abbruch]");
			if(red_list) free(red_list);
			if(yellow_list) free(yellow_list);
			if(blue_list) free(blue_list);
			if(type_list) free(type_list);
			return;
		}
		

	  /* Letzte Plane finden, die nicht incl. weiž-deckend ist */
		while(l->next && ((l->this.type != 2) ||
					((l->this.type == 2)	&& !(l->this.visible)))
				 ) l=l->next;

		a=0;
		while(l)
		{
			if(l->this.visible)
			{
				red_list[a]=l->this.red;
				yellow_list[a]=l->this.yellow;
				blue_list[a]=l->this.blue;
				type_list[a]=l->this.type;
				++a;
			}
			l=l->prev;
		}
		if(otoolbar[MASK_VIS-1].ob_state & SELECTED)
		{
			if(mask_col_tab[act_mask->this.col] & 1)
				red_list[a]=act_mask->this.mask; 
			else
				red_list[a]=NULL;
			if(mask_col_tab[act_mask->this.col] & 2)
				yellow_list[a]=act_mask->this.mask; 
			else
				yellow_list[a]=NULL;
			if(mask_col_tab[act_mask->this.col] & 4)
				blue_list[a]=act_mask->this.mask; 
			else
				blue_list[a]=NULL;

			type_list[a]=0;
			++a;
		}

		type_list[a]=-1;
		red_list[a]=NULL;
		yellow_list[a]=NULL;
		blue_list[a]=NULL;


		l_dif=first_lay->this.word_width-p_width;

		dst_lines=ob.g_h;
		dst_width=p_width/6;
		dst_2width=p_width/2;
		src_offset=l_dif;
		dst_red=b_red; dst_blue=b_blue; dst_yellow=b_yellow;
		lsb_used=(long)((long)p_width*(long)dst_lines)/2;
		p_off=(long)(ob.g_y-swy+main_win.oy)*(long)first_lay->this.word_width;
		p_off+=(long)(ob.g_x-swx+main_win.ox);
		lsb_offset=p_off;


		/* Weiž hinterlegen 
		pxy[0]=ob.g_x; pxy[1]=ob.g_y;
		pxy[2]=ob.g_x+ob.g_w-1; pxy[3]=ob.g_y+ob.g_h-1;
		vsf_interior(handle, 1);
		vsf_color(handle, 0);
		vswr_mode(handle, 1);
		vr_recfl(handle, pxy);
		*/
		
		if(a)
		{
			p_red=b_red;
			p_yellow=b_yellow;
			p_blue=b_blue;
			p_screen=(void*)((long)((long)physbase+(long)swy*(long)sw+(long)swx));
			screen_width=sw;
			rel_start_x=ob.g_x-swx;
			rel_start_y=ob.g_y-swy;
			start_x=0;
			start_y=0;
			end_x=ob.g_w-1;
			end_y=ob.g_h-1;
			c_solo=1;
			typ0_dither();
		}
		
		free(red_list); free(blue_list); free(yellow_list);
		free(b_red); free(b_blue); free(b_yellow);
	}
}
