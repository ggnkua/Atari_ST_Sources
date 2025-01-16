***************************************************************************
*              Programowanie w Assemblerze ~ Quast Magazyn 8              *
*-------------------------------------------------------------------------*
* nazwa      :  Wykres 2-wykresy muzyczne do modulow, mod. graja na 50Khz *
* autor      :  Van Eijk (wykresy) & Lancy (procedura odgrywajaca mody)   *
* inne uwagi :  Nie dziala na ST & nie dziala na monochromie              *
***************************************************************************

TLO		equ		$fff8240
TLO2	equ		$fff8242

START:
		clr.l	-(sp)
		move.w	#32,-(sp)
		trap	#1
		addq.l	#6,sp
EKRAN:
		move.w	#0,-(sp)
		move.l	#$78000+200000,-(sp)
		move.l	#$78000+200000,-(sp)
		move.w	#5,-(sp)
		trap	#14
		add.l	#12,sp

		move.w	#$fff,TLO2

		lea	save_sync,a0
		move.w	$448.w,(a0)+
		move.w	$ffff820a.w,(a0)+

		move.w	#$ff,$448.w
		or.b	#$2,$ffff820a.w	
		move.l	$70,PAM

		move.l	#WK000,a0
		move.w	#99,d0
PL1:	clr.l	(a0)+
		dbf		d0,PL1
		move.w	#0,TERAZ
		move.w	#2,WYK1
		move.w	#2,WYK2
		move.w	#2,WYK3
		move.w	#2,WYK4

		move.l #SAFEREG,a0			* zapamietanie rejestrow MFP
		move.b $fffa07,(a0)+
		move.b $fffa09,(a0)+
		move.b $fffa0b,(a0)+
		move.b $fffa0f,(a0)+
		move.b $fffa13,(a0)+
		move.b $fffa17,(a0)+
		move.b $fffa19,(a0)+	
		move.b $fffa1f,(a0)+	
		move.b $fffa1b,(a0)+
		move.b $fffa1d,(a0)+		
		move.b $fffa21,(a0)+
		move.l $120,OLD_TIMERB		* zapamietanie starego TIMERA B
		move.l $70,OLD_VBL
		andi.b #%11011111,$fffa09
		move.b #$21,$fffffa07	
		move.b #$21,$fffffa13	
		bclr	#3,$ffffa17

		bsr	mt_init

		move.l #VBL,$70.w				* nowa procedura dla VBLa
		move.l #TIMERB000,$120        *     --//--     dla TIMERA B
		move.w #$2300,sr		

T:		bra		T

*-------------------------------------------------------------------------*

VBL:
		clr.b	$fffffa1b
		move.b	#1,$fffffa21
		move.l	#TIMERB000,$120
		move.b	#8,$fffffa1b
		cmp.b	#57,$fffc02
		beq		END
		bsr	mt_Paula
		bsr	mt_music
		movem.l	a0/d0,-(sp)
		jsr		WYKRES
		movem.l	(sp)+,a0/d0
		rte

*-------------------------------------------------------------------------*

END:	
		move.w	#0,$fff8246
		move.w	#0,$fff825e
		move.w	#$fff,$fff8240
		bsr	mt_end
		lea	save_sync,a0
		move.w	(a0)+,$448.w
		move.w	(a0)+,$ffff820a.w
		andi.b 	#%11111110,$fffa07
		andi.b 	#%11111110,$fffa13
		move.l 	OLD_VBL,$70			* zwrocenie starych wartosci przerwan 
		move.l 	OLD_TIMERB,$120		*  VBL'a,TIMERa B i TOMERa A,
		move.l 	#SAFEREG,a0			* zwrocenie starych wartosci timerow,
		move.b 	(a0)+,$fffa07
		move.b 	(a0)+,$fffa09
		move.b 	(a0)+,$fffa0b                              
		move.b 	(a0)+,$fffa0f
		move.b 	(a0)+,$fffa13
		move.b 	(a0)+,$fffa17
		move.b 	(a0)+,$fffa19	
		move.b 	(a0)+,$fffa1f	
		move.b 	(a0)+,$fffa1b
		move.b 	(a0)+,$fffa1d
		move.b 	(a0)+,$fffa21
		move.b 	#$f7,$fffa23
		move.w	#$2700,sr		
		bset	#3,$fffffa17	
		move.w	#$2300,sr		
		move.w	#$000,$fff8246
		move.w	#$000,$fff825e
		move.w	#$fff,$fff8240
		move.b	#0008,$fffc02
		clr.l	-(sp)
		trap	#1
		rts

*----------------------------------------------------------------*

TIMERB000:
		move.l	#TIMERB001,$120
		move.w	WK000,TLO
		rte
TIMERB001:
		move.l	#TIMERB002,$120
		move.w	WK001,TLO
		rte
TIMERB002:
		move.l	#TIMERB003,$120
		move.w	WK002,TLO
		rte
TIMERB003:
		move.l	#TIMERB004,$120
		move.w	WK003,TLO
		rte
TIMERB004:
		move.l	#TIMERB005,$120
		move.w	WK004,TLO
		rte
TIMERB005:
		move.l	#TIMERB006,$120
		move.w	WK005,TLO
		rte
TIMERB006:
		move.l	#TIMERB007,$120
		move.w	WK006,TLO
		rte
TIMERB007:
		move.l	#TIMERB008,$120
		move.w	WK007,TLO
		rte
TIMERB008:
		move.l	#TIMERB009,$120
		move.w	WK008,TLO
		rte
TIMERB009:
		move.l	#TIMERB010,$120
		move.w	WK009,TLO
		rte
TIMERB010:
		move.l	#TIMERB011,$120
		move.w	WK010,TLO
		rte
TIMERB011:
		move.l	#TIMERB012,$120
		move.w	WK011,TLO
		rte
TIMERB012:
		move.l	#TIMERB013,$120
		move.w	WK012,TLO
		rte
TIMERB013:
		move.l	#TIMERB014,$120
		move.w	WK013,TLO
		rte
TIMERB014:
		move.l	#TIMERB015,$120
		move.w	WK014,TLO
		rte
TIMERB015:
		move.l	#TIMERB016,$120
		move.w	WK015,TLO
		rte
TIMERB016:
		move.l	#TIMERB017,$120
		move.w	WK016,TLO
		rte
TIMERB017:
		move.l	#TIMERB018,$120
		move.w	WK017,TLO
		rte
TIMERB018:
		move.l	#TIMERB019,$120
		move.w	WK018,TLO
		rte
TIMERB019:
		move.l	#TIMERB020,$120
		move.w	WK019,TLO
		rte
TIMERB020:
		move.l	#TIMERB021,$120
		move.w	WK020,TLO
		rte
TIMERB021:
		move.l	#TIMERB022,$120
		move.w	WK021,TLO
		rte
TIMERB022:
		move.l	#TIMERB023,$120
		move.w	WK022,TLO
		rte
TIMERB023:
		move.l	#TIMERB024,$120
		move.w	WK023,TLO
		rte
TIMERB024:
		move.l	#TIMERB025,$120
		move.w	WK024,TLO
		rte
TIMERB025:
		move.l	#TIMERB026,$120
		move.w	WK025,TLO
		rte
TIMERB026:
		move.l	#TIMERB027,$120
		move.w	WK026,TLO
		rte
TIMERB027:
		move.l	#TIMERB028,$120
		move.w	WK027,TLO
		rte
TIMERB028:
		move.l	#TIMERB029,$120
		move.w	WK028,TLO
		rte
TIMERB029:
		move.l	#TIMERB030,$120
		move.w	WK029,TLO
		rte
TIMERB030:
		move.l	#TIMERB031,$120
		move.w	WK030,TLO
		rte
TIMERB031:
		move.l	#TIMERB032,$120
		move.w	WK031,TLO
		rte
TIMERB032:
		move.l	#TIMERB033,$120
		move.w	WK032,TLO
		rte
TIMERB033:
		move.l	#TIMERB034,$120
		move.w	WK033,TLO
		rte
TIMERB034:
		move.l	#TIMERB035,$120
		move.w	WK034,TLO
		rte
TIMERB035:
		move.l	#TIMERB036,$120
		move.w	WK035,TLO
		rte
TIMERB036:
		move.l	#TIMERB037,$120
		move.w	WK036,TLO
		rte
TIMERB037:
		move.l	#TIMERB038,$120
		move.w	WK037,TLO
		rte
TIMERB038:
		move.l	#TIMERB039,$120
		move.w	WK038,TLO
		rte
TIMERB039:
		move.l	#TIMERB040,$120
		move.w	WK039,TLO
		rte
TIMERB040:
		move.l	#TIMERB041,$120
		move.w	WK040,TLO
		rte
TIMERB041:
		move.l	#TIMERB042,$120
		move.w	WK041,TLO
		rte
TIMERB042:
		move.l	#TIMERB043,$120
		move.w	WK042,TLO
		rte
TIMERB043:
		move.l	#TIMERB044,$120
		move.w	WK043,TLO
		rte
TIMERB044:
		move.l	#TIMERB045,$120
		move.w	WK044,TLO
		rte
TIMERB045:
		move.l	#TIMERB046,$120
		move.w	WK045,TLO
		rte
TIMERB046:
		move.l	#TIMERB047,$120
		move.w	WK046,TLO
		rte
TIMERB047:
		move.l	#TIMERB048,$120
		move.w	WK047,TLO
		rte
TIMERB048:
		move.l	#TIMERB049,$120
		move.w	WK048,TLO
		rte
TIMERB049:
		move.l	#TIMERB050,$120
		move.w	WK049,TLO
		rte
TIMERB050:
		move.l	#TIMERB051,$120
		move.w	WK050,TLO
		rte
TIMERB051:
		move.l	#TIMERB052,$120
		move.w	WK051,TLO
		rte
TIMERB052:
		move.l	#TIMERB053,$120
		move.w	WK052,TLO
		rte
TIMERB053:
		move.l	#TIMERB054,$120
		move.w	WK053,TLO
		rte
TIMERB054:
		move.l	#TIMERB055,$120
		move.w	WK054,TLO
		rte
TIMERB055:
		move.l	#TIMERB056,$120
		move.w	WK055,TLO
		rte
TIMERB056:
		move.l	#TIMERB057,$120
		move.w	WK056,TLO
		rte
TIMERB057:
		move.l	#TIMERB058,$120
		move.w	WK057,TLO
		rte
TIMERB058:
		move.l	#TIMERB059,$120
		move.w	WK058,TLO
		rte
TIMERB059:
		move.l	#TIMERB060,$120
		move.w	WK059,TLO
		rte
TIMERB060:
		move.l	#TIMERB061,$120
		move.w	WK060,TLO
		rte
TIMERB061:
		move.l	#TIMERB062,$120
		move.w	WK061,TLO
		rte
TIMERB062:
		move.l	#TIMERB063,$120
		move.w	WK062,TLO
		rte
TIMERB063:
		move.l	#TIMERB064,$120
		move.w	WK063,TLO
		rte
TIMERB064:
		move.l	#TIMERB065,$120
		move.w	WK064,TLO
		rte
TIMERB065:
		move.l	#TIMERB066,$120
		move.w	WK065,TLO
		rte
TIMERB066:
		move.l	#TIMERB067,$120
		move.w	WK066,TLO
		rte
TIMERB067:
		move.l	#TIMERB068,$120
		move.w	WK067,TLO
		rte
TIMERB068:
		move.l	#TIMERB069,$120
		move.w	WK068,TLO
		rte
TIMERB069:
		move.l	#TIMERB070,$120
		move.w	WK069,TLO
		rte
TIMERB070:
		move.l	#TIMERB071,$120
		move.w	WK070,TLO
		rte
TIMERB071:
		move.l	#TIMERB072,$120
		move.w	WK071,TLO
		rte
TIMERB072:
		move.l	#TIMERB073,$120
		move.w	WK072,TLO
		rte
TIMERB073:
		move.l	#TIMERB074,$120
		move.w	WK073,TLO
		rte
TIMERB074:
		move.l	#TIMERB075,$120
		move.w	WK074,TLO
		rte
TIMERB075:
		move.l	#TIMERB076,$120
		move.w	WK075,TLO
		rte
TIMERB076:
		move.l	#TIMERB077,$120
		move.w	WK076,TLO
		rte
TIMERB077:
		move.l	#TIMERB078,$120
		move.w	WK077,TLO
		rte
TIMERB078:
		move.l	#TIMERB079,$120
		move.w	WK078,TLO
		rte
TIMERB079:
		move.l	#TIMERB080,$120
		move.w	WK079,TLO
		rte
TIMERB080:
		move.l	#TIMERB081,$120
		move.w	WK080,TLO
		rte
TIMERB081:
		move.l	#TIMERB082,$120
		move.w	WK081,TLO
		rte
TIMERB082:
		move.l	#TIMERB083,$120
		move.w	WK082,TLO
		rte
TIMERB083:
		move.l	#TIMERB084,$120
		move.w	WK083,TLO
		rte
TIMERB084:
		move.l	#TIMERB085,$120
		move.w	WK084,TLO
		rte
TIMERB085:
		move.l	#TIMERB086,$120
		move.w	WK085,TLO
		rte
TIMERB086
		move.l	#TIMERB087,$120
		move.w	WK086,TLO
		rte
TIMERB087:
		move.l	#TIMERB088,$120
		move.w	WK087,TLO
		rte
TIMERB088:
		move.l	#TIMERB089,$120
		move.w	WK088,TLO
		rte
TIMERB089:
		move.l	#TIMERB090,$120
		move.w	WK089,TLO
		rte
TIMERB090:
		move.l	#TIMERB091,$120
		move.w	WK090,TLO
		rte
TIMERB091:
		move.l	#TIMERB092,$120
		move.w	WK091,TLO
		rte
TIMERB092:
		move.l	#TIMERB093,$120
		move.w	WK092,TLO
		rte
TIMERB093:
		move.l	#TIMERB094,$120
		move.w	WK093,TLO
		rte
TIMERB094:
		move.l	#TIMERB095,$120
		move.w	WK094,TLO
		rte
TIMERB095:
		move.l	#TIMERB096,$120
		move.w	WK095,TLO
		rte
TIMERB096:
		move.l	#TIMERB097,$120
		move.w	WK096,TLO
		rte
TIMERB097:
		move.l	#TIMERB098,$120
		move.w	WK097,TLO
		rte
TIMERB098:
		move.l	#TIMERB099,$120
		move.w	WK098,TLO
		rte
TIMERB099:
		move.l	#TIMERB100,$120
		move.w	WK099,TLO
		rte

TIMERB100:
		move.l	#TIMERB101,$120
		move.w	WK100,TLO
		rte
TIMERB101:
		move.l	#TIMERB102,$120
		move.w	WK101,TLO
		rte
TIMERB102:
		move.l	#TIMERB103,$120
		move.w	WK102,TLO
		rte
TIMERB103:
		move.l	#TIMERB104,$120
		move.w	WK103,TLO
		rte
TIMERB104:
		move.l	#TIMERB105,$120
		move.w	WK104,TLO
		rte
TIMERB105:
		move.l	#TIMERB106,$120
		move.w	WK105,TLO
		rte
TIMERB106:
		move.l	#TIMERB107,$120
		move.w	WK106,TLO
		rte
TIMERB107:
		move.l	#TIMERB108,$120
		move.w	WK107,TLO
		rte
TIMERB108:
		move.l	#TIMERB109,$120
		move.w	WK108,TLO
		rte
TIMERB109:
		move.l	#TIMERB110,$120
		move.w	WK109,TLO
		rte
TIMERB110:
		move.l	#TIMERB111,$120
		move.w	WK110,TLO
		rte
TIMERB111:
		move.l	#TIMERB112,$120
		move.w	WK111,TLO
		rte
TIMERB112:
		move.l	#TIMERB113,$120
		move.w	WK112,TLO
		rte
TIMERB113:
		move.l	#TIMERB114,$120
		move.w	WK113,TLO
		rte
TIMERB114:
		move.l	#TIMERB115,$120
		move.w	WK114,TLO
		rte
TIMERB115:
		move.l	#TIMERB116,$120
		move.w	WK115,TLO
		rte
TIMERB116:
		move.l	#TIMERB117,$120
		move.w	WK116,TLO
		rte
TIMERB117:
		move.l	#TIMERB118,$120
		move.w	WK117,TLO
		rte
TIMERB118:
		move.l	#TIMERB119,$120
		move.w	WK118,TLO
		rte
TIMERB119:
		move.l	#TIMERB120,$120
		move.w	WK119,TLO
		rte
TIMERB120:
		move.l	#TIMERB121,$120
		move.w	WK120,TLO
		rte
TIMERB121:
		move.l	#TIMERB122,$120
		move.w	WK121,TLO
		rte
TIMERB122:
		move.l	#TIMERB123,$120
		move.w	WK122,TLO
		rte
TIMERB123:
		move.l	#TIMERB124,$120
		move.w	WK123,TLO
		rte
TIMERB124:
		move.l	#TIMERB125,$120
		move.w	WK124,TLO
		rte
TIMERB125:
		move.l	#TIMERB126,$120
		move.w	WK125,TLO
		rte
TIMERB126:
		move.l	#TIMERB127,$120
		move.w	WK126,TLO
		rte
TIMERB127:
		move.l	#TIMERB128,$120
		move.w	WK127,TLO
		rte
TIMERB128:
		move.l	#TIMERB129,$120
		move.w	WK128,TLO
		rte
TIMERB129:
		move.l	#TIMERB130,$120
		move.w	WK129,TLO
		rte
TIMERB130:
		move.l	#TIMERB131,$120
		move.w	WK130,TLO
		rte
TIMERB131:
		move.l	#TIMERB132,$120
		move.w	WK131,TLO
		rte
TIMERB132:
		move.l	#TIMERB133,$120
		move.w	WK132,TLO
		rte
TIMERB133:
		move.l	#TIMERB134,$120
		move.w	WK133,TLO
		rte
TIMERB134:
		move.l	#TIMERB135,$120
		move.w	WK134,TLO
		rte
TIMERB135:
		move.l	#TIMERB136,$120
		move.w	WK135,TLO
		rte
TIMERB136:
		move.l	#TIMERB137,$120
		move.w	WK136,TLO
		rte
TIMERB137:
		move.l	#TIMERB138,$120
		move.w	WK137,TLO
		rte
TIMERB138:
		move.l	#TIMERB139,$120
		move.w	WK138,TLO
		rte
TIMERB139:
		move.l	#TIMERB140,$120
		move.w	WK139,TLO
		rte
TIMERB140:
		move.l	#TIMERB141,$120
		move.w	WK140,TLO
		rte
TIMERB141:
		move.l	#TIMERB142,$120
		move.w	WK141,TLO
		rte
TIMERB142:
		move.l	#TIMERB143,$120
		move.w	WK142,TLO
		rte
TIMERB143:
		move.l	#TIMERB144,$120
		move.w	WK143,TLO
		rte
TIMERB144:
		move.l	#TIMERB145,$120
		move.w	WK144,TLO
		rte
TIMERB145:
		move.l	#TIMERB146,$120
		move.w	WK145,TLO
		rte
TIMERB146:
		move.l	#TIMERB147,$120
		move.w	WK146,TLO
		rte
TIMERB147:
		move.l	#TIMERB148,$120
		move.w	WK147,TLO
		rte
TIMERB148:
		move.l	#TIMERB149,$120
		move.w	WK148,TLO
		rte
TIMERB149:
		move.l	#TIMERB150,$120
		move.w	WK149,TLO
		rte
TIMERB150:
		move.l	#TIMERB151,$120
		move.w	WK150,TLO
		rte
TIMERB151:
		move.l	#TIMERB152,$120
		move.w	WK151,TLO
		rte
TIMERB152:
		move.l	#TIMERB153,$120
		move.w	WK152,TLO
		rte
TIMERB153:
		move.l	#TIMERB154,$120
		move.w	WK153,TLO
		rte
TIMERB154:
		move.l	#TIMERB155,$120
		move.w	WK154,TLO
		rte
TIMERB155:
		move.l	#TIMERB156,$120
		move.w	WK155,TLO
		rte
TIMERB156:
		move.l	#TIMERB157,$120
		move.w	WK156,TLO
		rte
TIMERB157:
		move.l	#TIMERB158,$120
		move.w	WK157,TLO
		rte
TIMERB158:
		move.l	#TIMERB159,$120
		move.w	WK158,TLO
		rte
TIMERB159:
		move.l	#TIMERB160,$120
		move.w	WK159,TLO
		rte
TIMERB160:
		move.l	#TIMERB161,$120
		move.w	WK160,TLO
		rte
TIMERB161:
		move.l	#TIMERB162,$120
		move.w	WK161,TLO
		rte
TIMERB162:
		move.l	#TIMERB163,$120
		move.w	WK162,TLO
		rte
TIMERB163:
		move.l	#TIMERB164,$120
		move.w	WK163,TLO
		rte
TIMERB164:
		move.l	#TIMERB165,$120
		move.w	WK164,TLO
		rte
TIMERB165:
		move.l	#TIMERB166,$120
		move.w	WK165,TLO
		rte
TIMERB166:
		move.l	#TIMERB167,$120
		move.w	WK166,TLO
		rte
TIMERB167:
		move.l	#TIMERB168,$120
		move.w	WK167,TLO
		rte
TIMERB168:
		move.l	#TIMERB169,$120
		move.w	WK168,TLO
		rte
TIMERB169:
		move.l	#TIMERB170,$120
		move.w	WK169,TLO
		rte
TIMERB170:
		move.l	#TIMERB171,$120
		move.w	WK170,TLO
		rte
TIMERB171:
		move.l	#TIMERB172,$120
		move.w	WK171,TLO
		rte
TIMERB172:
		move.l	#TIMERB173,$120
		move.w	WK172,TLO
		rte
TIMERB173:
		move.l	#TIMERB174,$120
		move.w	WK173,TLO
		rte
TIMERB174:
		move.l	#TIMERB175,$120
		move.w	WK174,TLO
		rte
TIMERB175:
		move.l	#TIMERB176,$120
		move.w	WK175,TLO
		rte
TIMERB176:
		move.l	#TIMERB177,$120
		move.w	WK176,TLO
		rte
TIMERB177:
		move.l	#TIMERB178,$120
		move.w	WK177,TLO
		rte
TIMERB178:
		move.l	#TIMERB179,$120
		move.w	WK178,TLO
		rte
TIMERB179:
		move.l	#TIMERB180,$120
		move.w	WK179,TLO
		rte
TIMERB180:
		move.l	#TIMERB181,$120
		move.w	WK180,TLO
		rte
TIMERB181:
		move.l	#TIMERB182,$120
		move.w	WK181,TLO
		rte
TIMERB182:
		move.l	#TIMERB183,$120
		move.w	WK182,TLO
		rte
TIMERB183:
		move.l	#TIMERB184,$120
		move.w	WK183,TLO
		rte
TIMERB184:
		move.l	#TIMERB185,$120
		move.w	WK184,TLO
		rte
TIMERB185:
		move.l	#TIMERB186,$120
		move.w	WK185,TLO
		rte
TIMERB186
		move.l	#TIMERB187,$120
		move.w	WK186,TLO
		rte
TIMERB187:
		move.l	#TIMERB188,$120
		move.w	WK187,TLO
		rte
TIMERB188:
		move.l	#TIMERB189,$120
		move.w	WK188,TLO
		rte
TIMERB189:
		move.l	#TIMERB190,$120
		move.w	WK189,TLO
		rte
TIMERB190:
		move.l	#TIMERB191,$120
		move.w	WK190,TLO
		rte
TIMERB191:
		move.l	#TIMERB192,$120
		move.w	WK191,TLO
		rte
TIMERB192:
		move.l	#TIMERB193,$120
		move.w	WK192,TLO
		rte
TIMERB193:
		move.l	#TIMERB194,$120
		move.w	WK193,TLO
		rte
TIMERB194:
		move.l	#TIMERB195,$120
		move.w	WK194,TLO
		rte
TIMERB195:
		move.l	#TIMERB196,$120
		move.w	WK195,TLO
		rte
TIMERB196:
		move.l	#TIMERB197,$120
		move.w	WK196,TLO
		rte
TIMERB197:
		move.l	#TIMERB198,$120
		move.w	WK197,TLO
		rte
TIMERB198:
		move.l	#TIMERB199,$120
		move.w	WK198,TLO
		rte
TIMERB199:
		move.l	#TIMERB200,$120
		move.w	WK199,TLO
		rte
TIMERB200
		rte
	

*-------------------------------------------------------------------------*

WYKRES:
		move.l	#RURKA,a0
		clr.w	d0
		move.w	WYK1,d0
		mulu.w	#48,d0
		add.l	d0,a0
		move.w	000(a0),WK000
		move.w	002(a0),WK001
		move.w	004(a0),WK002
		move.w	006(a0),WK003
		move.w	008(a0),WK004
		move.w	010(a0),WK005
		move.w	012(a0),WK006
		move.w	014(a0),WK007
		move.w	016(a0),WK008
		move.w	018(a0),WK009
		move.w	020(a0),WK010
		move.w	022(a0),WK011
		move.w	024(a0),WK012
		move.w	026(a0),WK013
		move.w	028(a0),WK014
		move.w	030(a0),WK015
		move.w	032(a0),WK016
		move.w	034(a0),WK017
		move.w	036(a0),WK018
		move.w	038(a0),WK019
		move.w	040(a0),WK020
		move.w	042(a0),WK021
		move.w	044(a0),WK022
		move.w	046(a0),WK023
		move.w	046(a0),WK024
		move.w	044(a0),WK025
		move.w	042(a0),WK026
		move.w	040(a0),WK027
		move.w	038(a0),WK028
		move.w	036(a0),WK029
		move.w	034(a0),WK030
		move.w	032(a0),WK031
		move.w	030(a0),WK032
		move.w	028(a0),WK033
		move.w	026(a0),WK034
		move.w	024(a0),WK035
		move.w	022(a0),WK036
		move.w	020(a0),WK037
		move.w	018(a0),WK038
		move.w	016(a0),WK039
		move.w	014(a0),WK040
		move.w	012(a0),WK041
		move.w	010(a0),WK042
		move.w	008(a0),WK043
		move.w	006(a0),WK044
		move.w	004(a0),WK045
		move.w	002(a0),WK046
		move.w	000(a0),WK047
		move.l	#RURKA,a0
		clr.w	d0
		move.w	WYK2,d0
		mulu.w	#48,d0
		add.l	d0,a0
		move.w	000(a0),WK050
		move.w	002(a0),WK051
		move.w	004(a0),WK052
		move.w	006(a0),WK053
		move.w	008(a0),WK054
		move.w	010(a0),WK055
		move.w	012(a0),WK056
		move.w	014(a0),WK057
		move.w	016(a0),WK058
		move.w	018(a0),WK059
		move.w	020(a0),WK060
		move.w	022(a0),WK061
		move.w	024(a0),WK062
		move.w	026(a0),WK063
		move.w	028(a0),WK064
		move.w	030(a0),WK065
		move.w	032(a0),WK066
		move.w	034(a0),WK067
		move.w	036(a0),WK068
		move.w	038(a0),WK069
		move.w	040(a0),WK070
		move.w	042(a0),WK071
		move.w	044(a0),WK072
		move.w	046(a0),WK073
		move.w	046(a0),WK074
		move.w	044(a0),WK075
		move.w	042(a0),WK076
		move.w	040(a0),WK077
		move.w	038(a0),WK078
		move.w	036(a0),WK079
		move.w	034(a0),WK080
		move.w	032(a0),WK081
		move.w	030(a0),WK082
		move.w	028(a0),WK083
		move.w	026(a0),WK084
		move.w	024(a0),WK085
		move.w	022(a0),WK086
		move.w	020(a0),WK087
		move.w	018(a0),WK088
		move.w	016(a0),WK089
		move.w	014(a0),WK090
		move.w	012(a0),WK091
		move.w	010(a0),WK092
		move.w	008(a0),WK093
		move.w	006(a0),WK094
		move.w	004(a0),WK095
		move.w	002(a0),WK096
		move.w	000(a0),WK097
		move.l	#RURKA,a0
		clr.w	d0
		move.w	WYK3,d0
		mulu.w	#48,d0
		add.l	d0,a0
		move.w	000(a0),WK100
		move.w	002(a0),WK101
		move.w	004(a0),WK102
		move.w	006(a0),WK103
		move.w	008(a0),WK104
		move.w	010(a0),WK105
		move.w	012(a0),WK106
		move.w	014(a0),WK107
		move.w	016(a0),WK108
		move.w	018(a0),WK109
		move.w	020(a0),WK110
		move.w	022(a0),WK111
		move.w	024(a0),WK112
		move.w	026(a0),WK113
		move.w	028(a0),WK114
		move.w	030(a0),WK115
		move.w	032(a0),WK116
		move.w	034(a0),WK117
		move.w	036(a0),WK118
		move.w	038(a0),WK119
		move.w	040(a0),WK120
		move.w	042(a0),WK121
		move.w	044(a0),WK122
		move.w	046(a0),WK123
		move.w	046(a0),WK124
		move.w	044(a0),WK125
		move.w	042(a0),WK126
		move.w	040(a0),WK127
		move.w	038(a0),WK128
		move.w	036(a0),WK129
		move.w	034(a0),WK130
		move.w	032(a0),WK131
		move.w	030(a0),WK132
		move.w	028(a0),WK133
		move.w	026(a0),WK134
		move.w	024(a0),WK135
		move.w	022(a0),WK136
		move.w	020(a0),WK137
		move.w	018(a0),WK138
		move.w	016(a0),WK139
		move.w	014(a0),WK140
		move.w	012(a0),WK141
		move.w	010(a0),WK142
		move.w	008(a0),WK143
		move.w	006(a0),WK144
		move.w	004(a0),WK145
		move.w	002(a0),WK146
		move.w	000(a0),WK147
		move.l	#RURKA,a0
		clr.w	d0
		move.w	WYK4,d0
		mulu.w	#48,d0
		add.l	d0,a0
		move.w	000(a0),WK150
		move.w	002(a0),WK151
		move.w	004(a0),WK152
		move.w	006(a0),WK153
		move.w	008(a0),WK154
		move.w	010(a0),WK155
		move.w	012(a0),WK156
		move.w	014(a0),WK157
		move.w	016(a0),WK158
		move.w	018(a0),WK159
		move.w	020(a0),WK160
		move.w	022(a0),WK161
		move.w	024(a0),WK162
		move.w	026(a0),WK163
		move.w	028(a0),WK164
		move.w	030(a0),WK165
		move.w	032(a0),WK166
		move.w	034(a0),WK167
		move.w	036(a0),WK168
		move.w	038(a0),WK169
		move.w	040(a0),WK170
		move.w	042(a0),WK171
		move.w	044(a0),WK172
		move.w	046(a0),WK173
		move.w	046(a0),WK174
		move.w	044(a0),WK175
		move.w	042(a0),WK176
		move.w	040(a0),WK177
		move.w	038(a0),WK178
		move.w	036(a0),WK179
		move.w	034(a0),WK180
		move.w	032(a0),WK181
		move.w	030(a0),WK182
		move.w	028(a0),WK183
		move.w	026(a0),WK184
		move.w	024(a0),WK185
		move.w	022(a0),WK186
		move.w	020(a0),WK187
		move.w	018(a0),WK188
		move.w	016(a0),WK189
		move.w	014(a0),WK190
		move.w	012(a0),WK191
		move.w	010(a0),WK192
		move.w	008(a0),WK193
		move.w	006(a0),WK194
		move.w	004(a0),WK195
		move.w	002(a0),WK196
		move.w	000(a0),WK197

		sub.w	#1,WYK1
		cmp.w	#0,WYK1
		bne		NIE1
		move.w	#1,WYK1
NIE1:
		move.l	#$78000+200000+32000+00,a0
		clr.w	d0
		move.w	WYK1,d0
MN1:	move.w	#%1111111111111111,(a0)
		sub.w	#160,a0
		dbf		d0,MN1
		move.w	#%0000000000000000,(a0)
*
		sub.w	#1,WYK2
		cmp.w	#0,WYK2
		bne		NIE2
		move.w	#1,WYK2
NIE2:
		move.l	#$78000+200000+32000+16,a0
		clr.w	d0
		move.w	WYK2,d0
MN2:	move.w	#%1111111111111111,(a0)
		sub.w	#160,a0
		dbf		d0,MN2
		move.w	#%0000000000000000,(a0)
*
		sub.w	#1,WYK3
		cmp.w	#0,WYK3
		bne		NIE3
		move.w	#1,WYK3
NIE3:
		move.l	#$78000+200000+32000+32,a0
		clr.w	d0
		move.w	WYK3,d0
MN3:	move.w	#%1111111111111111,(a0)
		sub.w	#160,a0
		dbf		d0,MN3
		move.w	#%0000000000000000,(a0)
*
		sub.w	#1,WYK4
		cmp.w	#0,WYK4
		bne		NIE4
		move.w	#1,WYK4
NIE4:
		move.l	#$78000+200000+32000+48,a0
		clr.w	d0
		move.w	WYK4,d0
MN4:	move.w	#%1111111111111111,(a0)
		sub.w	#160,a0
		dbf		d0,MN4
		move.w	#%0000000000000000,(a0)
*
		rts

*-------------------------------------------------------------------------*

OLD_TIMERB: ds.l 1
OLD_VBL: 	ds.l 1
SAFEREG: 	ds.b 12

RURKA:
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$008
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$008,$001
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$008,$001,$009
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$008,$001,$009,$002
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$008,$001,$009,$002,$00a
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
	dc.w	$000,$000,$000,$000,$000,$000,$000,$001,$008,$009,$002,$00a,$003
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
	dc.w	$000,$000,$000,$000,$000,$000,$008,$001,$009,$002,$00a,$003,$00b
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
	dc.w	$000,$000,$000,$000,$000,$008,$001,$009,$002,$00a,$003,$00b,$004
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
	dc.w	$000,$000,$000,$000,$008,$001,$009,$002,$00a,$003,$00b,$004,$00c
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
	dc.w	$000,$000,$000,$008,$001,$009,$002,$00a,$003,$00b,$004,$00c,$005
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
	dc.w	$000,$000,$008,$001,$009,$002,$00a,$003,$00b,$004,$00c,$005,$00d
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
	dc.w	$000,$008,$001,$009,$002,$00a,$003,$00b,$004,$00c,$005,$00d,$006
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
	dc.w	$008,$001,$009,$002,$00a,$003,$00b,$004,$00c,$005,$00d,$006,$00e
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$008
	dc.w	$001,$009,$002,$00a,$003,$00b,$004,$00c,$005,$00d,$006,$00e,$007
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$008,$001
	dc.w	$009,$002,$00a,$003,$00b,$004,$00c,$005,$00d,$006,$00e,$007,$00f
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$008,$001,$009
	dc.w	$002,$00a,$003,$00b,$004,$00c,$005,$00d,$006,$00e,$007,$00f,$08f
	dc.w	$000,$000,$000,$000,$000,$000,$000,$008,$001,$009,$002
	dc.w	$00a,$003,$00b,$004,$00c,$005,$00d,$006,$00e,$007,$00f,$08f,$01f
	dc.w	$000,$000,$000,$000,$000,$000,$008,$001,$009,$002,$00a
	dc.w	$003,$00b,$004,$00c,$005,$00d,$006,$00e,$007,$00f,$08f,$01f,$09f
	dc.w	$000,$000,$000,$000,$000,$008,$001,$009,$002,$00a,$003
	dc.w	$00b,$004,$00c,$005,$00d,$006,$00e,$007,$00f,$08f,$01f,$09f,$02f
	dc.w	$000,$000,$000,$000,$008,$001,$009,$002,$00a,$003,$00b
	dc.w	$004,$00c,$005,$00d,$006,$00e,$007,$00f,$08f,$01f,$09f,$02f,$0af
	dc.w	$000,$000,$000,$008,$001,$009,$002,$00a,$003,$00b,$004
	dc.w	$00c,$005,$00d,$006,$00e,$007,$00f,$08f,$01f,$09f,$02f,$0af,$03f
	dc.w	$000,$000,$008,$001,$009,$002,$00a,$003,$00b,$004,$00c
	dc.w	$005,$00d,$006,$00e,$007,$00f,$08f,$01f,$09f,$02f,$0af,$03f,$0bf
	dc.w	$000,$008,$001,$009,$002,$00a,$003,$00b,$004,$00c,$005
	dc.w	$00d,$006,$00e,$007,$00f,$08f,$01f,$09f,$02f,$0af,$03f,$0bf,$04f
	dc.w	$008,$001,$009,$002,$00a,$003,$00b,$004,$00c,$005,$00d
	dc.w	$006,$00e,$007,$00f,$08f,$01f,$09f,$02f,$0af,$03f,$0bf,$04f,$0cf

WK000	dc.w	1
WK001	dc.w	1
WK002	dc.w	1
WK003	dc.w	1
WK004	dc.w	1
WK005	dc.w	1
WK006	dc.w	1
WK007	dc.w	1
WK008	dc.w	1
WK009	dc.w	1
WK010	dc.w	1
WK011	dc.w	1
WK012	dc.w	1
WK013	dc.w	1
WK014	dc.w	1
WK015	dc.w	1
WK016	dc.w	1
WK017	dc.w	1
WK018	dc.w	1
WK019	dc.w	1
WK020	dc.w	1
WK021	dc.w	1
WK022	dc.w	1
WK023	dc.w	1
WK024	dc.w	1
WK025	dc.w	1
WK026	dc.w	1
WK027	dc.w	1
WK028	dc.w	1
WK029	dc.w	1
WK030	dc.w	1
WK031	dc.w	1
WK032	dc.w	1
WK033	dc.w	1
WK034	dc.w	1
WK035	dc.w	1
WK036	dc.w	1
WK037	dc.w	1
WK038	dc.w	1
WK039	dc.w	1
WK040	dc.w	1
WK041	dc.w	1
WK042	dc.w	1
WK043	dc.w	1
WK044	dc.w	1
WK045	dc.w	1
WK046	dc.w	1
WK047	dc.w	1
WK048	dc.w	1
WK049	dc.w	1
WK050	dc.w	1
WK051	dc.w	1
WK052	dc.w	1
WK053	dc.w	1
WK054	dc.w	1
WK055	dc.w	1
WK056	dc.w	1
WK057	dc.w	1
WK058	dc.w	1
WK059	dc.w	1
WK060	dc.w	1
WK061	dc.w	1
WK062	dc.w	1
WK063	dc.w	1
WK064	dc.w	1
WK065	dc.w	1
WK066	dc.w	1
WK067	dc.w	1
WK068	dc.w	1
WK069	dc.w	1
WK070	dc.w	1
WK071	dc.w	1
WK072	dc.w	1
WK073	dc.w	1
WK074	dc.w	1
WK075	dc.w	1
WK076	dc.w	1
WK077	dc.w	1
WK078	dc.w	1
WK079	dc.w	1
WK080	dc.w	1
WK081	dc.w	1
WK082	dc.w	1
WK083	dc.w	1
WK084	dc.w	1
WK085	dc.w	1
WK086	dc.w	1
WK087	dc.w	1
WK088	dc.w	1
WK089	dc.w	1
WK090	dc.w	1
WK091	dc.w	1
WK092	dc.w	1
WK093	dc.w	1
WK094	dc.w	1
WK095	dc.w	1
WK096	dc.w	1
WK097	dc.w	1
WK098	dc.w	1
WK099	dc.w	1
WK100	dc.w	1
WK101	dc.w	1
WK102	dc.w	1
WK103	dc.w	1
WK104	dc.w	1
WK105	dc.w	1
WK106	dc.w	1
WK107	dc.w	1
WK108	dc.w	1
WK109	dc.w	1
WK110	dc.w	1
WK111	dc.w	1
WK112	dc.w	1
WK113	dc.w	1
WK114	dc.w	1
WK115	dc.w	1
WK116	dc.w	1
WK117	dc.w	1
WK118	dc.w	1
WK119	dc.w	1
WK120	dc.w	1
WK121	dc.w	1
WK122	dc.w	1
WK123	dc.w	1
WK124	dc.w	1
WK125	dc.w	1
WK126	dc.w	1
WK127	dc.w	1
WK128	dc.w	1
WK129	dc.w	1
WK130	dc.w	1
WK131	dc.w	1
WK132	dc.w	1
WK133	dc.w	1
WK134	dc.w	1
WK135	dc.w	1
WK136	dc.w	1
WK137	dc.w	1
WK138	dc.w	1
WK139	dc.w	1
WK140	dc.w	1
WK141	dc.w	1
WK142	dc.w	1
WK143	dc.w	1
WK144	dc.w	1
WK145	dc.w	1
WK146	dc.w	1
WK147	dc.w	1
WK148	dc.w	1
WK149	dc.w	1
WK150	dc.w	1
WK151	dc.w	1
WK152	dc.w	1
WK153	dc.w	1
WK154	dc.w	1
WK155	dc.w	1
WK156	dc.w	1
WK157	dc.w	1
WK158	dc.w	1
WK159	dc.w	1
WK160	dc.w	1
WK161	dc.w	1
WK162	dc.w	1
WK163	dc.w	1
WK164	dc.w	1
WK165	dc.w	1
WK166	dc.w	1
WK167	dc.w	1
WK168	dc.w	1
WK169	dc.w	1
WK170	dc.w	1
WK171	dc.w	1
WK172	dc.w	1
WK173	dc.w	1
WK174	dc.w	1
WK175	dc.w	1
WK176	dc.w	1
WK177	dc.w	1
WK178	dc.w	1
WK179	dc.w	1
WK180	dc.w	1
WK181	dc.w	1
WK182	dc.w	1
WK183	dc.w	1
WK184	dc.w	1
WK185	dc.w	1
WK186	dc.w	1
WK187	dc.w	1
WK188	dc.w	1
WK189	dc.w	1
WK190	dc.w	1
WK191	dc.w	1
WK192	dc.w	1
WK193	dc.w	1
WK194	dc.w	1
WK195	dc.w	1
WK196	dc.w	1
WK197	dc.w	1
WK198	dc.w	1
WK199	dc.w	1

WYK1:		dc.w	1
			even
WYK2:		dc.w	1
			even
WYK3:		dc.w	1
			even
WYK4:		dc.w	1
			even
TERAZ:		dc.w	1
			even

PAM:	dc.l	1
		even

save_sync	dc.w	0,0

n_note	equ	0  ; w
n_cmd	equ	2  ; w
n_cmdlo	equ	3  ; b
n_start	equ	4  ; l
n_length	equ	8  ; w
n_loopstart	equ	10 ; l
n_replen	equ	14 ; w
n_period	equ	16 ; w
n_finetune	equ	18 ; b
n_volume	equ	19 ; b
n_dmabit	equ	20 ; w
n_toneportdirec	equ	22 ; b
n_toneportspeed	equ	23 ; b
n_wantedperiod	equ	24 ; w
n_vibratocmd	equ	26 ; b
n_vibratopos	equ	27 ; b
n_tremolocmd	equ	28 ; b
n_tremolopos	equ	29 ; b
n_wavecontrol	equ	30 ; b
n_glissfunk	equ	31 ; b
n_sampleoffset	equ	32 ; b
n_pattpos	equ	33 ; b
n_loopcount	equ	34 ; b
n_funkoffset	equ	35 ; b
n_wavestart	equ	36 ; l
n_reallength	equ	40 ; w

*	opt	a+,o+

	section	text

mt_init	lea	mt_data,a0
	move.l	a0,mt_songdataptr
	move.l	a0,a1
	lea	952(a1),a1
	moveq	#127,d0
	moveq	#0,d1
mtloop	move.l	d1,d2
	subq.w	#1,d0
mtloop2	move.b	(a1)+,d1
	cmp.b	d2,d1
	bgt.s	mtloop
	dbra	d0,mtloop2
	addq.b	#1,d2
			
	lea	mt_samplestarts(pc),a1
	asl.l	#8,d2
	asl.l	#2,d2
	add.l	#1084,d2
	add.l	a0,d2
	move.l	d2,a2
	moveq	#30,d0
	moveq	#0,d2
	lea	42(a0),a0
mtloop3	clr.l	(a2)
	move.l	a2,d1
	add.l	d2,d1
	move.l	d1,(a1)+
	moveq	#0,d1
	move.w	(a0),d1
	asl.l	#1,d1
	add.l	d1,a2
	add.w	#640,d2
	tst.w	4(a0)
	bne.s	.mt_no_test
	cmp.w	#1,6(a0)
	ble.s	.mt_no_test
	subq.w	#1,6(a0)
	move.w	#1,4(a0)
.mt_no_test	add.l	#30,a0
	dbra	d0,mtloop3
	add.w	d2,a2
	lea	mt_module_end,a1
	move.l	a2,(a1)
	move.b	#6,mt_speed
	move.b	#6,mt_counter
	clr.b	mt_songpos
	clr.w	mt_patternpos

	lea	-31*640(a2),a1

	moveq	#30,d7
mt_init_loops	sub.w	#30,a0
	lea	-640(a2),a2
	lea	(a2),a3
	move.w	(a0),d0
	beq.s	.mt_just_loop
	subq.w	#1,d0
.mt_copy_spl	move.w	-(a1),-(a2)
	dbra	d0,.mt_copy_spl

.mt_just_loop	moveq	#0,d0
	move.w	4(a0),d0
	sne	d1
	andi.w	#$4,d1
	move.l	mt_loop_point(pc,d1.w),a4
	jsr	(a4)
	dbra	d7,mt_init_loops

	bsr	mt_init_Paula
	rts
mt_end	bsr	mt_stop_Paula
	rts
mt_loop_point	dc.l	.mt_no_loop
	dc.l	.mt_yes_loop
.mt_no_loop	move.w	#640/4-1,d0
.mt_clear_loop	clr.l	(a3)+
	dbra	d0,.mt_clear_loop
	rts
.mt_yes_loop	add.l	d0,d0
	lea	(a2,d0.l),a4
	lea	(a4),a5
	moveq	#0,d1
	move.w	4(a0),d1
	add.w	6(a0),d1
	move.w	d1,(a0)
	add.l	d1,d1
	lea	(a2,d1.l),a3
	move.w	6(a0),d1
	move.w	#320-1,d2
.mt_loop_loop	move.w	(a4)+,(a3)+
	subq.w	#1,d1
	bne.s	.mt_no_restart
	lea	(a5),a4
	move.w	6(a0),d1
.mt_no_restart	dbra	d2,.mt_loop_loop
	rts

mt_music	movem.l	d0-d4/a0-a6,-(sp)
	addq.b	#1,mt_counter
	move.b	mt_counter(pc),d0
	cmp.b	mt_speed(pc),d0
	blo.s	mt_nonewnote
	clr.b	mt_counter
	tst.b	mt_pattdeltime2
	beq.s	mt_getnewnote
	bsr.s	mt_nonewallchannels
	bra	mt_dskip

mt_nonewnote
	bsr.s	mt_nonewallchannels
	bra	mt_nonewposyet

mt_nonewallchannels
	lea	mt_channel_0,a5
	lea	mt_chan1temp(pc),a6
	bsr	mt_checkefx
	lea	mt_channel_1,a5
	lea	mt_chan2temp(pc),a6
	bsr	mt_checkefx
	lea	mt_channel_2,a5
	lea	mt_chan3temp(pc),a6
	bsr	mt_checkefx
	lea	mt_channel_3,a5
	lea	mt_chan4temp(pc),a6
	bra	mt_checkefx

mt_getnewnote
	move.l	mt_songdataptr(pc),a0
	lea	12(a0),a3
	lea	952(a0),a2	;pattpo
	lea	1084(a0),a0	;patterndata
	moveq	#0,d0
	moveq	#0,d1
	move.b	mt_songpos(pc),d0
	move.b	(a2,d0.w),d1
	asl.l	#8,d1
	asl.l	#2,d1
	add.w	mt_patternpos(pc),d1
	clr.w	mt_dmacontemp

	lea	mt_channel_0,a5
	lea	mt_chan1temp(pc),a6
	move.w	#1,TERAZ			***********
	bsr.s	mt_playvoice
	lea	mt_channel_1,a5
	lea	mt_chan2temp(pc),a6
	move.w	#2,TERAZ			***********
	bsr.s	mt_playvoice
	lea	mt_channel_2,a5
	lea	mt_chan3temp(pc),a6
	move.w	#3,TERAZ			***********
	bsr.s	mt_playvoice
	lea	mt_channel_3,a5
	lea	mt_chan4temp(pc),a6
	move.w	#4,TERAZ			***********
	bsr.s	mt_playvoice
	bra	mt_setdma

mt_playvoice	tst.l	(a6)
	bne.s	mt_plvskip
	bsr	mt_pernop
mt_plvskip	move.l	(a0,d1.l),(a6)
	addq.l	#4,d1
	moveq	#0,d2
	move.b	n_cmd(a6),d2
	and.b	#$f0,d2
	lsr.b	#4,d2
	move.b	(a6),d0
	and.b	#$f0,d0
	or.b	d0,d2
	tst.b	d2
	beq	mt_setregs
	moveq	#0,d3
	lea	mt_samplestarts(pc),a1
	move	d2,d4
	subq.l	#1,d2
	asl.l	#2,d2
	mulu	#30,d4
	move.l	(a1,d2.l),n_start(a6)
	move.w	(a3,d4.l),n_length(a6)
	move.w	(a3,d4.l),n_reallength(a6)
	move.b	2(a3,d4.l),n_finetune(a6)
	move.b	3(a3,d4.l),n_volume(a6)
	move.w	4(a3,d4.l),d3 ; get repeat
	tst.w	d3
	beq.s	mt_noloop
	move.l	n_start(a6),d2		; get start
	asl.w	#1,d3
	add.l	d3,d2		; add repeat
	move.l	d2,n_loopstart(a6)
	move.l	d2,n_wavestart(a6)
	move.w	4(a3,d4.l),d0	; get repeat
	add.w	6(a3,d4.l),d0	; add replen
	move.w	d0,n_length(a6)
	move.w	6(a3,d4.l),n_replen(a6)	; save replen
	moveq	#0,d0
	move.b	n_volume(a6),d0
	move.w	d0,12(a5)	; set volume
	bra.s	mt_setregs

mt_noloop	move.l	n_start(a6),d2
	move.l	d2,n_loopstart(a6)
	move.l	d2,n_wavestart(a6)
	move.w	6(a3,d4.l),n_replen(a6)	; save replen
	moveq	#0,d0
	move.b	n_volume(a6),d0
	move.w	d0,12(a5)	; set volume

mt_setregs	move.w	(a6),d0
	and.w	#$0fff,d0
	beq	mt_checkmoreefx	; if no note
	move.w	2(a6),d0
	and.w	#$0ff0,d0
	cmp.w	#$0e50,d0
	beq.s	mt_dosetfinetune
	move.b	2(a6),d0
	and.b	#$0f,d0
	cmp.b	#3,d0	; toneportamento
	beq.s	mt_chktoneporta
	cmp.b	#5,d0
	beq.s	mt_chktoneporta
	cmp.b	#9,d0	; sample offset
	bne.s	mt_setperiod
	bsr	mt_checkmoreefx
	bra.s	mt_setperiod

mt_dosetfinetune
	bsr	mt_setfinetune
	bra.s	mt_setperiod

mt_chktoneporta
	bsr	mt_settoneporta
	bra	mt_checkmoreefx

mt_setperiod
	cmp.w	#1,TERAZ
	bne		TONIE1
	move.w	#23,WYK1
TONIE1:
	cmp.w	#2,TERAZ
	bne		TONIE2
	move.w	#23,WYK2
TONIE2:
	cmp.w	#3,TERAZ
	bne		TONIE3
	move.w	#23,WYK3
TONIE3:
	cmp.w	#4,TERAZ
	bne		TONIE4
	move.w	#23,WYK4
TONIE4:
	movem.l	d0-d1/a0-a1,-(sp)
	move.w	(a6),d1
	and.w	#$0fff,d1
	lea	mt_periodtable(pc),a1
	moveq	#0,d0
	moveq	#36,d7
mt_ftuloop	cmp.w	(a1,d0.w),d1
	bhs.s	mt_ftufound
	addq.l	#2,d0
	dbra	d7,mt_ftuloop
mt_ftufound
	moveq	#0,d1
	move.b	n_finetune(a6),d1
	mulu	#36*2,d1
	add.l	d1,a1
	move.w	(a1,d0.w),n_period(a6)
	movem.l	(sp)+,d0-d1/a0-a1

	move.w	2(a6),d0
	and.w	#$0ff0,d0
	cmp.w	#$0ed0,d0 ; notedelay
	beq	mt_checkmoreefx

	btst	#2,n_wavecontrol(a6)
	bne.s	mt_vibnoc
	clr.b	n_vibratopos(a6)
mt_vibnoc
	btst	#6,n_wavecontrol(a6)
	bne.s	mt_trenoc
	clr.b	n_tremolopos(a6)
mt_trenoc
	move.l	n_start(a6),(a5)	; set start
	moveq	#0,d0
	move.w	n_length(a6),d0		; set length
	add.l	d0,d0
	add.l	(a5),d0
	move.l	d0,8(a5)
	move.l	n_loopstart(a6),d0
	cmp.l	(a5),d0
	bne.s	.mt_set_loop
	moveq	#0,d0
.mt_set_loop	move.l	d0,4(a5)
	move.w	n_period(a6),d0
	move.w	d0,14(a5)		; set period
	move.w	n_dmabit(a6),d0
	or.w	d0,mt_dmacontemp
	bra	mt_checkmoreefx
 
mt_setdma
mt_dskip	add.w	#16,mt_patternpos
	move.b	mt_pattdeltime,d0
	beq.s	mt_dskc
	move.b	d0,mt_pattdeltime2
	clr.b	mt_pattdeltime
mt_dskc	tst.b	mt_pattdeltime2
	beq.s	mt_dska
	subq.b	#1,mt_pattdeltime2
	beq.s	mt_dska
	sub.w	#16,mt_patternpos
mt_dska	tst.b	mt_pbreakflag
	beq.s	mt_nnpysk
	sf	mt_pbreakflag
	moveq	#0,d0
	move.b	mt_pbreakpos(pc),d0
	clr.b	mt_pbreakpos
	lsl.w	#4,d0
	move.w	d0,mt_patternpos
mt_nnpysk	cmp.w	#1024,mt_patternpos
	blo.s	mt_nonewposyet
mt_nextposition	
	moveq	#0,d0
	move.b	mt_pbreakpos(pc),d0
	lsl.w	#4,d0
	move.w	d0,mt_patternpos
	clr.b	mt_pbreakpos
	clr.b	mt_posjumpflag
	addq.b	#1,mt_songpos
	and.b	#$7f,mt_songpos
	move.b	mt_songpos(pc),d1
	move.l	mt_songdataptr(pc),a0
	cmp.b	950(a0),d1
	blo.s	mt_nonewposyet
	clr.b	mt_songpos
mt_nonewposyet	
	tst.b	mt_posjumpflag
	bne.s	mt_nextposition
	movem.l	(sp)+,d0-d4/a0-a6
	rts

mt_checkefx
	bsr	mt_updatefunk
	move.w	n_cmd(a6),d0
	and.w	#$0fff,d0
	beq.s	mt_pernop
	move.b	n_cmd(a6),d0
	and.b	#$0f,d0
	beq.s	mt_arpeggio
	cmp.b	#1,d0
	beq	mt_portaup
	cmp.b	#2,d0
	beq	mt_portadown
	cmp.b	#3,d0
	beq	mt_toneportamento
	cmp.b	#4,d0
	beq	mt_vibrato
	cmp.b	#5,d0
	beq	mt_toneplusvolslide
	cmp.b	#6,d0
	beq	mt_vibratoplusvolslide
	cmp.b	#$e,d0
	beq	mt_e_commands
setback	move.w	n_period(a6),14(a5)
	cmp.b	#7,d0
	beq	mt_tremolo
	cmp.b	#$a,d0
	beq	mt_volumeslide
mt_return2
	rts

mt_pernop
	move.w	n_period(a6),14(a5)
	rts

mt_arpeggio
	moveq	#0,d0
	move.b	mt_counter(pc),d0
	divs	#3,d0
	swap	d0
	cmp.w	#0,d0
	beq.s	mt_arpeggio2
	cmp.w	#2,d0
	beq.s	mt_arpeggio1
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	lsr.b	#4,d0
	bra.s	mt_arpeggio3

mt_arpeggio1
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#15,d0
	bra.s	mt_arpeggio3

mt_arpeggio2
	move.w	n_period(a6),d2
	bra.s	mt_arpeggio4

mt_arpeggio3
	asl.w	#1,d0
	moveq	#0,d1
	move.b	n_finetune(a6),d1
	mulu	#36*2,d1
	lea	mt_periodtable(pc),a0
	add.l	d1,a0
	moveq	#0,d1
	move.w	n_period(a6),d1
	moveq	#36,d7
mt_arploop
	move.w	(a0,d0.w),d2
	cmp.w	(a0),d1
	bhs.s	mt_arpeggio4
	addq.l	#2,a0
	dbra	d7,mt_arploop
	rts

mt_arpeggio4	move.w	d2,14(a5)
	rts

mt_fineportaup
	tst.b	mt_counter
	bne.s	mt_return2
	move.b	#$0f,mt_lowmask
mt_portaup
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	mt_lowmask(pc),d0
	move.b	#$ff,mt_lowmask
	sub.w	d0,n_period(a6)
	move.w	n_period(a6),d0
	and.w	#$0fff,d0
	cmp.w	#113,d0
	bpl.s	mt_portauskip
	and.w	#$f000,n_period(a6)
	or.w	#113,n_period(a6)
mt_portauskip
	move.w	n_period(a6),d0
	and.w	#$0fff,d0
	move.w	d0,14(a5)
	rts	
 
mt_fineportadown
	tst.b	mt_counter
	bne	mt_return2
	move.b	#$0f,mt_lowmask
mt_portadown
	clr.w	d0
	move.b	n_cmdlo(a6),d0
	and.b	mt_lowmask(pc),d0
	move.b	#$ff,mt_lowmask
	add.w	d0,n_period(a6)
	move.w	n_period(a6),d0
	and.w	#$0fff,d0
	cmp.w	#856,d0
	bmi.s	mt_portadskip
	and.w	#$f000,n_period(a6)
	or.w	#856,n_period(a6)
mt_portadskip
	move.w	n_period(a6),d0
	and.w	#$0fff,d0
	move.w	d0,14(a5)
	rts

mt_settoneporta
	move.l	a0,-(sp)
	move.w	(a6),d2
	and.w	#$0fff,d2
	moveq	#0,d0
	move.b	n_finetune(a6),d0
	mulu	#37*2,d0
	lea	mt_periodtable(pc),a0
	add.l	d0,a0
	moveq	#0,d0
mt_stploop
	cmp.w	(a0,d0.w),d2
	bhs.s	mt_stpfound
	addq.w	#2,d0
	cmp.w	#37*2,d0
	blo.s	mt_stploop
	moveq	#35*2,d0
mt_stpfound
	move.b	n_finetune(a6),d2
	and.b	#8,d2
	beq.s	mt_stpgoss
	tst.w	d0
	beq.s	mt_stpgoss
	subq.w	#2,d0
mt_stpgoss
	move.w	(a0,d0.w),d2
	move.l	(sp)+,a0
	move.w	d2,n_wantedperiod(a6)
	move.w	n_period(a6),d0
	clr.b	n_toneportdirec(a6)
	cmp.w	d0,d2
	beq.s	mt_cleartoneporta
	bge	mt_return2
	move.b	#1,n_toneportdirec(a6)
	rts

mt_cleartoneporta
	clr.w	n_wantedperiod(a6)
	rts

mt_toneportamento
	move.b	n_cmdlo(a6),d0
	beq.s	mt_toneportnochange
	move.b	d0,n_toneportspeed(a6)
	clr.b	n_cmdlo(a6)
mt_toneportnochange
	tst.w	n_wantedperiod(a6)
	beq	mt_return2
	moveq	#0,d0
	move.b	n_toneportspeed(a6),d0
	tst.b	n_toneportdirec(a6)
	bne.s	mt_toneportaup
mt_toneportadown
	add.w	d0,n_period(a6)
	move.w	n_wantedperiod(a6),d0
	cmp.w	n_period(a6),d0
	bgt.s	mt_toneportasetper
	move.w	n_wantedperiod(a6),n_period(a6)
	clr.w	n_wantedperiod(a6)
	bra.s	mt_toneportasetper

mt_toneportaup
	sub.w	d0,n_period(a6)
	move.w	n_wantedperiod(a6),d0
	cmp.w	n_period(a6),d0
	blt.s	mt_toneportasetper
	move.w	n_wantedperiod(a6),n_period(a6)
	clr.w	n_wantedperiod(a6)

mt_toneportasetper
	move.w	n_period(a6),d2
	move.b	n_glissfunk(a6),d0
	and.b	#$0f,d0
	beq.s	mt_glissskip
	moveq	#0,d0
	move.b	n_finetune(a6),d0
	mulu	#36*2,d0
	lea	mt_periodtable(pc),a0
	add.l	d0,a0
	moveq	#0,d0
mt_glissloop
	cmp.w	(a0,d0.w),d2
	bhs.s	mt_glissfound
	addq.w	#2,d0
	cmp.w	#36*2,d0
	blo.s	mt_glissloop
	moveq	#35*2,d0
mt_glissfound
	move.w	(a0,d0.w),d2
mt_glissskip
	move.w	d2,14(a5) ; set period
	rts

mt_vibrato
	move.b	n_cmdlo(a6),d0
	beq.s	mt_vibrato2
	move.b	n_vibratocmd(a6),d2
	and.b	#$0f,d0
	beq.s	mt_vibskip
	and.b	#$f0,d2
	or.b	d0,d2
mt_vibskip
	move.b	n_cmdlo(a6),d0
	and.b	#$f0,d0
	beq.s	mt_vibskip2
	and.b	#$0f,d2
	or.b	d0,d2
mt_vibskip2
	move.b	d2,n_vibratocmd(a6)
mt_vibrato2
	move.b	n_vibratopos(a6),d0
	lea	mt_vibratotable(pc),a4
	lsr.w	#2,d0
	and.w	#$001f,d0
	moveq	#0,d2
	move.b	n_wavecontrol(a6),d2
	and.b	#$03,d2
	beq.s	mt_vib_sine
	lsl.b	#3,d0
	cmp.b	#1,d2
	beq.s	mt_vib_rampdown
	move.b	#255,d2
	bra.s	mt_vib_set
mt_vib_rampdown
	tst.b	n_vibratopos(a6)
	bpl.s	mt_vib_rampdown2
	move.b	#255,d2
	sub.b	d0,d2
	bra.s	mt_vib_set
mt_vib_rampdown2
	move.b	d0,d2
	bra.s	mt_vib_set
mt_vib_sine
	move.b	0(a4,d0.w),d2
mt_vib_set
	move.b	n_vibratocmd(a6),d0
	and.w	#15,d0
	mulu	d0,d2
	lsr.w	#7,d2
	move.w	n_period(a6),d0
	tst.b	n_vibratopos(a6)
	bmi.s	mt_vibratoneg
	add.w	d2,d0
	bra.s	mt_vibrato3
mt_vibratoneg
	sub.w	d2,d0
mt_vibrato3
	move.w	d0,14(a5)
	move.b	n_vibratocmd(a6),d0
	lsr.w	#2,d0
	and.w	#$003c,d0
	add.b	d0,n_vibratopos(a6)
	rts

mt_toneplusvolslide
	bsr	mt_toneportnochange
	bra	mt_volumeslide

mt_vibratoplusvolslide
	bsr.s	mt_vibrato2
	bra	mt_volumeslide

mt_tremolo
	move.b	n_cmdlo(a6),d0
	beq.s	mt_tremolo2
	move.b	n_tremolocmd(a6),d2
	and.b	#$0f,d0
	beq.s	mt_treskip
	and.b	#$f0,d2
	or.b	d0,d2
mt_treskip
	move.b	n_cmdlo(a6),d0
	and.b	#$f0,d0
	beq.s	mt_treskip2
	and.b	#$0f,d2
	or.b	d0,d2
mt_treskip2
	move.b	d2,n_tremolocmd(a6)
mt_tremolo2
	move.b	n_tremolopos(a6),d0
	lea	mt_vibratotable(pc),a4
	lsr.w	#2,d0
	and.w	#$001f,d0
	moveq	#0,d2
	move.b	n_wavecontrol(a6),d2
	lsr.b	#4,d2
	and.b	#$03,d2
	beq.s	mt_tre_sine
	lsl.b	#3,d0
	cmp.b	#1,d2
	beq.s	mt_tre_rampdown
	move.b	#255,d2
	bra.s	mt_tre_set
mt_tre_rampdown
	tst.b	n_vibratopos(a6)
	bpl.s	mt_tre_rampdown2
	move.b	#255,d2
	sub.b	d0,d2
	bra.s	mt_tre_set
mt_tre_rampdown2
	move.b	d0,d2
	bra.s	mt_tre_set
mt_tre_sine
	move.b	0(a4,d0.w),d2
mt_tre_set
	move.b	n_tremolocmd(a6),d0
	and.w	#15,d0
	mulu	d0,d2
	lsr.w	#6,d2
	moveq	#0,d0
	move.b	n_volume(a6),d0
	tst.b	n_tremolopos(a6)
	bmi.s	mt_tremoloneg
	add.w	d2,d0
	bra.s	mt_tremolo3
mt_tremoloneg
	sub.w	d2,d0
mt_tremolo3
	bpl.s	mt_tremoloskip
	clr.w	d0
mt_tremoloskip
	cmp.w	#$40,d0
	bls.s	mt_tremolook
	move.w	#$40,d0
mt_tremolook
	move.w	d0,12(a5)
	move.b	n_tremolocmd(a6),d0
	lsr.w	#2,d0
	and.w	#$003c,d0
	add.b	d0,n_tremolopos(a6)
	rts

mt_sampleoffset
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	beq.s	mt_sononew
	move.b	d0,n_sampleoffset(a6)
mt_sononew
	move.b	n_sampleoffset(a6),d0
	lsl.w	#7,d0
	cmp.w	n_length(a6),d0
	bge.s	mt_sofskip
	sub.w	d0,n_length(a6)
	lsl.w	#1,d0
	add.l	d0,n_start(a6)
	add.l	n_loopstart(a6),d0
	cmp.l	n_start(a6),d0
	ble.s	.mt_set_loop
	move.l	n_loopstart(a6),d0
.mt_set_loop	move.l	d0,n_loopstart(a6)
	rts
mt_sofskip	move.w	#$0001,n_length(a6)
	rts

mt_volumeslide
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	lsr.b	#4,d0
	tst.b	d0
	beq.s	mt_volslidedown
mt_volslideup
	add.b	d0,n_volume(a6)
	cmp.b	#$40,n_volume(a6)
	bmi.s	mt_vsuskip
	move.b	#$40,n_volume(a6)
mt_vsuskip
	move.b	n_volume(a6),d0
	move.w	d0,12(a5)
	rts

mt_volslidedown
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
mt_volslidedown2
	sub.b	d0,n_volume(a6)
	bpl.s	mt_vsdskip
	clr.b	n_volume(a6)
mt_vsdskip
	move.b	n_volume(a6),d0
	move.w	d0,12(a5)
	rts

mt_positionjump
	move.b	n_cmdlo(a6),d0
	subq.b	#1,d0
	move.b	d0,mt_songpos
mt_pj2	clr.b	mt_pbreakpos
	st 	mt_posjumpflag
	rts

mt_volumechange
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	cmp.b	#$40,d0
	bls.s	mt_volumeok
	moveq	#$40,d0
mt_volumeok
	move.b	d0,n_volume(a6)
	move.w	d0,12(a5)
	rts

mt_patternbreak
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	move.l	d0,d2
	lsr.b	#4,d0
	mulu	#10,d0
	and.b	#$0f,d2
	add.b	d2,d0
	cmp.b	#63,d0
	bhi.s	mt_pj2
	move.b	d0,mt_pbreakpos
	st	mt_posjumpflag
	rts

mt_setspeed
	move.b	3(a6),d0
	beq	mt_return2
	clr.b	mt_counter
	move.b	d0,mt_speed
	rts

mt_checkmoreefx
	bsr	mt_updatefunk
	move.b	2(a6),d0
	and.b	#$0f,d0
	cmp.b	#$9,d0
	beq	mt_sampleoffset
	cmp.b	#$b,d0
	beq	mt_positionjump
	cmp.b	#$d,d0
	beq.s	mt_patternbreak
	cmp.b	#$e,d0
	beq.s	mt_e_commands
	cmp.b	#$f,d0
	beq.s	mt_setspeed
	cmp.b	#$c,d0
	beq	mt_volumechange
	bra	mt_pernop

mt_e_commands
	move.b	n_cmdlo(a6),d0
	and.b	#$f0,d0
	lsr.b	#4,d0
	beq.s	mt_filteronoff
	cmp.b	#1,d0
	beq	mt_fineportaup
	cmp.b	#2,d0
	beq	mt_fineportadown
	cmp.b	#3,d0
	beq.s	mt_setglisscontrol
	cmp.b	#4,d0
	beq.s	mt_setvibratocontrol
	cmp.b	#5,d0
	beq.s	mt_setfinetune
	cmp.b	#6,d0
	beq.s	mt_jumploop
	cmp.b	#7,d0
	beq	mt_settremolocontrol
	cmp.b	#9,d0
	beq	mt_retrignote
	cmp.b	#$a,d0
	beq	mt_volumefineup
	cmp.b	#$b,d0
	beq	mt_volumefinedown
	cmp.b	#$c,d0
	beq	mt_notecut
	cmp.b	#$d,d0
	beq	mt_notedelay
	cmp.b	#$e,d0
	beq	mt_patterndelay
	cmp.b	#$f,d0
	beq	mt_funkit
	rts

mt_filteronoff	rts	

mt_setglisscontrol
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	and.b	#$f0,n_glissfunk(a6)
	or.b	d0,n_glissfunk(a6)
	rts

mt_setvibratocontrol
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	and.b	#$f0,n_wavecontrol(a6)
	or.b	d0,n_wavecontrol(a6)
	rts

mt_setfinetune
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	move.b	d0,n_finetune(a6)
	rts

mt_jumploop
	tst.b	mt_counter
	bne	mt_return2
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	beq.s	mt_setloop
	tst.b	n_loopcount(a6)
	beq.s	mt_jumpcnt
	subq.b	#1,n_loopcount(a6)
	beq	mt_return2
mt_jmploop	move.b	n_pattpos(a6),mt_pbreakpos
	st	mt_pbreakflag
	rts

mt_jumpcnt
	move.b	d0,n_loopcount(a6)
	bra.s	mt_jmploop

mt_setloop
	move.w	mt_patternpos(pc),d0
	lsr.w	#4,d0
	move.b	d0,n_pattpos(a6)
	rts

mt_settremolocontrol
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	lsl.b	#4,d0
	and.b	#$0f,n_wavecontrol(a6)
	or.b	d0,n_wavecontrol(a6)
	rts

mt_retrignote	move.l	d1,-(sp)
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	beq.s	mt_rtnend
	moveq	#0,d1
	move.b	mt_counter(pc),d1
	bne.s	mt_rtnskp
	move.w	(a6),d1
	and.w	#$0fff,d1
	bne.s	mt_rtnend
	moveq	#0,d1
	move.b	mt_counter(pc),d1
mt_rtnskp	divu	d0,d1
	swap	d1
	tst.w	d1
	bne.s	mt_rtnend
mt_doretrig	move.l	n_start(a6),(a5)	; set sampledata pointer
	moveq	#0,d0
	move.w	n_length(a6),d0		; set length
	add.l	d0,d0
	add.l	(a5),d0
	move.l	d0,8(a5)

	move.l	n_loopstart(a6),d0
	cmp.l	(a5),d0
	bne.s	.mt_set_loop
	moveq	#0,d0
.mt_set_loop	move.l	d0,4(a5)

mt_rtnend	move.l	(sp)+,d1
	rts

mt_volumefineup
	tst.b	mt_counter
	bne	mt_return2
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#$f,d0
	bra	mt_volslideup

mt_volumefinedown
	tst.b	mt_counter
	bne	mt_return2
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	bra	mt_volslidedown2

mt_notecut
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	cmp.b	mt_counter(pc),d0
	bne	mt_return2
	clr.b	n_volume(a6)
	move.w	#0,12(a5)
	rts

mt_notedelay
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	cmp.b	mt_counter,d0
	bne	mt_return2
	move.w	(a6),d0
	beq	mt_return2
	move.l	d1,-(sp)
	bra	mt_doretrig

mt_patterndelay
	tst.b	mt_counter
	bne	mt_return2
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	tst.b	mt_pattdeltime2
	bne	mt_return2
	addq.b	#1,d0
	move.b	d0,mt_pattdeltime
	rts

mt_funkit
	tst.b	mt_counter
	bne	mt_return2
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	lsl.b	#4,d0
	and.b	#$0f,n_glissfunk(a6)
	or.b	d0,n_glissfunk(a6)
	tst.b	d0
	beq	mt_return2
mt_updatefunk
	movem.l	a0/d1,-(sp)
	moveq	#0,d0
	move.b	n_glissfunk(a6),d0
	lsr.b	#4,d0
	beq.s	mt_funkend
	lea	mt_funktable(pc),a0
	move.b	(a0,d0.w),d0
	add.b	d0,n_funkoffset(a6)
	btst	#7,n_funkoffset(a6)
	beq.s	mt_funkend
	clr.b	n_funkoffset(a6)

	move.l	n_loopstart(a6),d0
	moveq	#0,d1
	move.w	n_replen(a6),d1
	add.l	d1,d0
	add.l	d1,d0
	move.l	n_wavestart(a6),a0
	addq.l	#1,a0
	cmp.l	d0,a0
	blo.s	mt_funkok
	move.l	n_loopstart(a6),a0
mt_funkok
	move.l	a0,n_wavestart(a6)
	moveq	#-1,d0
	sub.b	(a0),d0
	move.b	d0,(a0)
mt_funkend
	movem.l	(sp)+,a0/d1
	rts

mt_init_Paula	bsr.s	mt_make_freq
	bsr	mt_make_tables
	bsr	mt_setup_voltab
	bsr	mt_make_zero
mt_init_Trap0	lea	mt_save_Trap0,a0
	move.l	$80.w,(a0)
	lea	mt_return,a0
	move.l	a0,$80.w
	rts

mt_make_freq	move.l	mt_freq_code_0,a0
	move.l	mt_freq_code_1,a1
	move.l	mt_freq_table0,a2
	move.l	mt_freq_table1,a3
	moveq	#$f,d0
.mt_make_loop	move.l	a0,(a2)+
	move.l	a1,(a3)+
	move.l	d0,d1
	swap	d1
	divu.w	#200,d1
	move.w	#199,d7
	move.l	d1,d2
	swap	d2
	cmp.w	#100,d2
	blt.s	.mt_zero
	addq.w	#1,d1
.mt_zero	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
.mt_maker	moveq	#0,d5

	add.w	d1,d2
	addx.w	d5,d3
	move.w	d3,d5
	move.w	d2,d6
	add.w	d6,d6
	negx.w	d5
	neg.w	d5
	cmp.w	d4,d5
	beq.s	.mt_put_op
	move.w	d5,d4
	move.w	d3,d5
	move.w	d2,d6
	add.w	d1,d6
	negx.w	d5
	neg.w	d5
	add.w	d6,d6
	negx.w	d5
	neg.w	d5
	cmp.w	d4,d5
	beq.s	.mt_just_one_inc

	move.l	mt_one_inc10,(a0)+
	move.w	mt_one_inc10+4,(a0)+
	move.l	mt_one_inc01,(a1)+
	move.l	mt_one_inc01+4,(a1)+
	bra.s	.mt_go_on_loop
.mt_just_one_inc
	move.l	mt_one_inc00,(a0)+
	move.l	mt_one_inc00+4,(a0)+
	move.l	mt_one_inc01,(a1)+
	move.l	mt_one_inc01+4,(a1)+
	bra.s	.mt_go_on_loop
.mt_put_op	move.w	mt_copy0,(a0)+
	move.w	mt_copy1,(a1)+
.mt_go_on_loop	dbra	d7,.mt_maker
	move.w	#$4ed5,(a0)+
	move.w	#$4ed5,(a1)+
	addq.l	#1,d0
	cmp.l	#126,d0
	bne	.mt_make_loop

	rts
mt_one_inc00	move.b	(a3)+,d0
	move.l	d0,a4
	move.b	(a4),d0
	move.b	d0,(sp)+

mt_one_inc01	move.b	(a3)+,d0
	move.l	d0,a4
	move.b	(a4),d0
	add.b	d0,(sp)+

mt_one_inc10	move.b	(a3)+,d0
	move.l	d0,a4
	move.b	(a4),(sp)+

mt_copy0	move.b	d0,(sp)+
mt_copy1	add.b	d0,(sp)+

mt_make_tables	move.l	mt_period_tab,a0

	move.w	#$72-1,d0
	moveq	#110,d1
.mt_copy_loop	move.l	d1,(a0)+
	dbra	d0,.mt_copy_loop

	move.w	#$72,d0
.mt_maker	move.l	mt_amiga_freq,d1
	divu.w	d0,d1
	move.w	d0,d3
	moveq	#0,d2
	asr.w	#1,d3
	addx.w	d2,d3
	move.l	d1,d2
	swap	d2
	cmp.w	d3,d2
	blt.s	.mt_no_add
	addq.w	#1,d1
.mt_no_add	andi.l	#$ffff,d1
	divu.w	#250,d1
	move.w	d1,d2
	clr.w	d1
	divu.w	#250,d1
	swap	d1
	moveq	#0,d3
	cmp.w	#125,d1
	blt.s	.mt_no_add1
	add.l	#$10000,d1
	addx.w	d3,d2
.mt_no_add1	move.w	d2,d1
	sub.w	#$f,d1
	bpl.s	.mt_no_dang
	moveq	#0,d1
.mt_no_dang	move.l	d1,(a0)+
	addq.w	#1,d0
	cmp.w	#$400,d0
	bne.s	.mt_maker
	rts
mt_setup_voltab
	lea	mt_volume_tab,a0
	move.l	(a0),d0
	andi.w	#$ff00,d0
	add.l	#$100,d0
	move.l	d0,(a0)
	move.l	d0,a0
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d3
.mt_clop	move.w	d1,d2
	ext.w	d2
	muls.w	d0,d2
	asr.w	#7,d2
	move.b	d2,(a0)+
	addq.w	#1,d1
	cmp.w	#$100,d1
	bne.s	.mt_clop
	moveq	#0,d1
	addq.w	#1,d0
	cmp.w	#$41,d0
	bne.s	.mt_clop	
	rts

mt_make_zero	move.l	mt_zero_code,a0
	move.w	.mt_zero_op,d0
	move.w	#500-1,d1
.mt_make_lop	move.w	d0,(a0)+
	dbra	d1,.mt_make_lop
	move.w	#$4ed2,(a0)
	rts
.mt_zero_op	move.l	d0,(a0)+

mt_stop_Paula
mt_rest_Trap0	move.l	mt_save_Trap0,$80.w
	rts
;Paula(Ste) table
;dc.l	sample_start		+0
;dc.l	sample_loop_start	+4
;dc.l	sample_end		+8
;dc.w	volume		+12
;dc.w	period		+14
;dc.w	old_period		+16
;dc.w	float_add		+18
;
;Offset Paula table
	rsreset
mt_sample_start	rs.l	1
mt_sample_loop	rs.l	1
mt_sample_end	rs.l	1
mt_volume	rs.w	1
mt_period	rs.w	1
mt_oldperiod	rs.w	1
mt_add_iw	rs.w	1
mt_old_sample	rs.w	1

mt_channel	macro
	move.l	mt_sample_start(a0),d0
	beq	.mt_continue
.mt_no_reset	move.w	mt_period(a0),d0
	and.w	#$3ff,d0
	cmp.w	mt_oldperiod(a0),d0
	beq.s	.mt_noreset_add
	clr.w	mt_add_iw(a0)
	move.w	d0,mt_oldperiod(a0)
.mt_noreset_add	add.w	d0,d0
	add.w	d0,d0
	move.l	mt_period_tab,a4
	move.l	(a4,d0.w),d2
	move.w	d2,d4
	swap	d2
	move.w	mt_add_iw(a0),d3


	move.w	mt_volume(a0),d0
	andi.w	#$7f,d0
	asl.w	#8,d0
	move.l	mt_volume_tab,a4
	lea	(a4,d0.w),a4
	move.l	a4,d0
	move.l	mt_sample_start(a0),a3
	move.b	mt_old_sample(a0),d0

	moveq	#0,d5

	add.w	d2,d3
	addx.w	d4,d5
	add.w	d5,d5
	add.w	d5,d5
	lea	.mt_return_0,a5
	move.l	(a1,d5.w),a2
	jmp	(a2)

.mt_return_0	moveq	#0,d5
	add.w	d2,d3
	addx.w	d4,d5
	add.w	d5,d5
	add.w	d5,d5
	lea	.mt_return_1,a5
	move.l	(a1,d5.w),a2
	jmp	(a2)

.mt_return_1	moveq	#0,d5
	add.w	d2,d3
	addx.w	d4,d5
	add.w	d5,d5
	add.w	d5,d5
	lea	.mt_return_2,a5
	move.l	(a1,d5.w),a2
	jmp	(a2)

.mt_return_2	moveq	#0,d5
	add.w	d2,d3
	addx.w	d4,d5
	add.w	d5,d5
	add.w	d5,d5
	lea	.mt_return_3,a5
	move.l	(a1,d5.w),a2
	jmp	(a2)

.mt_return_3	moveq	#0,d5
	add.w	d2,d3
	addx.w	d4,d5
	add.w	d5,d5
	add.w	d5,d5
	lea	.mt_return_4,a5
	move.l	(a1,d5.w),a2
	jmp	(a2)

.mt_return_4	move.w	d3,mt_add_iw(a0)
	move.b	d0,mt_old_sample(a0)
	move.l	a3,mt_sample_start(a0)
	move.l	mt_sample_end(a0),d1
	cmp.l	d1,a3
	blt.s	.mt_continue
	move.l	mt_sample_loop(a0),d0
	beq.s	.mt_no_loop
	move.l	d0,mt_sample_start(a0)
	sub.l	d1,d0
	neg.l	d0
	neg.l	d1
	add.l	a3,d1
	cmp.l	d0,d1
	ble.s	.mt_no_div
	divu.w	d0,d1
	clr.w	d1
	swap	d1
.mt_no_div	add.l	d1,mt_sample_start(a0)
	bra.s	.mt_continue
.mt_no_loop	lea	mt_dummy_spl_tab,a1
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
.mt_continue
	endm

mt_Paula	move.w	#$ffff8900,a0
	clr.w	(a0)
	move.l	mt_physic_buf,d0
	movep.l	d0,$1(a0)
	add.l	mt_buf_length,d0
	movep.l	d0,$d(a0)
	move.w	mt_frequency,$20(a0)
	move.w	#1,(a0)
	lea	mt_save_SSP,a0
	move.l	sp,(a0)
	pea	mt_emulate
	move.w	mt_SR,-(sp)
	rte
mt_return	move.l	mt_save_SSP,sp
	lea	mt_physic_buf,a0
	lea	mt_logic_buf,a1
	move.l	(a0),d0
	move.l	(a1),(a0)
	move.l	d0,(a1)
	rts

mt_emulate	lea	mt_save_USP,a0
	move.l	sp,(a0)

	move.l	mt_channel_0,d0
	seq	d1
	move.l	mt_channel_1,d0
	seq	d0
	or.b	d0,d1
	beq.s	mt_no_clear_buf

	moveq	#0,d0
	move.l	mt_logic_buf,a0
	move.l	mt_zero_code,a1
	lea	mt_no_clear_buf,a2
	jmp	(a1)

mt_no_clear_buf	move.l	mt_logic_buf,sp
	lea	mt_channel_0,a0
	move.l	mt_freq_table0,a1
mt_left0	mt_channel

	move.l	mt_logic_buf,sp
	lea	1(sp),sp
	lea	mt_channel_1,a0
	move.l	mt_freq_table0,a1
mt_right0	mt_channel

	move.l	mt_logic_buf,sp
	lea	mt_channel_3,a0
	move.l	mt_freq_table1,a1
mt_left1	mt_channel

	move.l	mt_logic_buf,sp
	lea	1(sp),sp
	lea	mt_channel_2,a0
	move.l	mt_freq_table1,a1
mt_right1	mt_channel

	move.l	mt_save_USP,sp
	trap	#0

	section	data
mt_funktable dc.b 0,5,6,7,8,10,11,13,16,19,22,26,32,43,64,128

mt_vibratotable	
	dc.b   0, 24, 49, 74, 97,120,141,161
	dc.b 180,197,212,224,235,244,250,253
	dc.b 255,253,250,244,235,224,212,197
	dc.b 180,161,141,120, 97, 74, 49, 24

mt_periodtable
; tuning 0, normal
	dc.w	856,808,762,720,678,640,604,570,538,508,480,453
	dc.w	428,404,381,360,339,320,302,285,269,254,240,226
	dc.w	214,202,190,180,170,160,151,143,135,127,120,113
; tuning 1
	dc.w	850,802,757,715,674,637,601,567,535,505,477,450
	dc.w	425,401,379,357,337,318,300,284,268,253,239,225
	dc.w	213,201,189,179,169,159,150,142,134,126,119,113
; tuning 2
	dc.w	844,796,752,709,670,632,597,563,532,502,474,447
	dc.w	422,398,376,355,335,316,298,282,266,251,237,224
	dc.w	211,199,188,177,167,158,149,141,133,125,118,112
; tuning 3
	dc.w	838,791,746,704,665,628,592,559,528,498,470,444
	dc.w	419,395,373,352,332,314,296,280,264,249,235,222
	dc.w	209,198,187,176,166,157,148,140,132,125,118,111
; tuning 4
	dc.w	832,785,741,699,660,623,588,555,524,495,467,441
	dc.w	416,392,370,350,330,312,294,278,262,247,233,220
	dc.w	208,196,185,175,165,156,147,139,131,124,117,110
; tuning 5
	dc.w	826,779,736,694,655,619,584,551,520,491,463,437
	dc.w	413,390,368,347,328,309,292,276,260,245,232,219
	dc.w	206,195,184,174,164,155,146,138,130,123,116,109
; tuning 6
	dc.w	820,774,730,689,651,614,580,547,516,487,460,434
	dc.w	410,387,365,345,325,307,290,274,258,244,230,217
	dc.w	205,193,183,172,163,154,145,137,129,122,115,109
; tuning 7
	dc.w	814,768,725,684,646,610,575,543,513,484,457,431
	dc.w	407,384,363,342,323,305,288,272,256,242,228,216
	dc.w	204,192,181,171,161,152,144,136,128,121,114,108
; tuning -8
	dc.w	907,856,808,762,720,678,640,604,570,538,508,480
	dc.w	453,428,404,381,360,339,320,302,285,269,254,240
	dc.w	226,214,202,190,180,170,160,151,143,135,127,120
; tuning -7
	dc.w	900,850,802,757,715,675,636,601,567,535,505,477
	dc.w	450,425,401,379,357,337,318,300,284,268,253,238
	dc.w	225,212,200,189,179,169,159,150,142,134,126,119
; tuning -6
	dc.w	894,844,796,752,709,670,632,597,563,532,502,474
	dc.w	447,422,398,376,355,335,316,298,282,266,251,237
	dc.w	223,211,199,188,177,167,158,149,141,133,125,118
; tuning -5
	dc.w	887,838,791,746,704,665,628,592,559,528,498,470
	dc.w	444,419,395,373,352,332,314,296,280,264,249,235
	dc.w	222,209,198,187,176,166,157,148,140,132,125,118
; tuning -4
	dc.w	881,832,785,741,699,660,623,588,555,524,494,467
	dc.w	441,416,392,370,350,330,312,294,278,262,247,233
	dc.w	220,208,196,185,175,165,156,147,139,131,123,117
; tuning -3
	dc.w	875,826,779,736,694,655,619,584,551,520,491,463
	dc.w	437,413,390,368,347,328,309,292,276,260,245,232
	dc.w	219,206,195,184,174,164,155,146,138,130,123,116
; tuning -2
	dc.w	868,820,774,730,689,651,614,580,547,516,487,460
	dc.w	434,410,387,365,345,325,307,290,274,258,244,230
	dc.w	217,205,193,183,172,163,154,145,137,129,122,115
; tuning -1
	dc.w	862,814,768,725,684,646,610,575,543,513,484,457
	dc.w	431,407,384,363,342,323,305,288,272,256,242,228
	dc.w	216,203,192,181,171,161,152,144,136,128,121,114

	dc.w	$416E,$6F74,$6865,$7220
	dc.w	$6772,$6561,$7420,$636F
	dc.w	$6465,$2062,$793A,$204C
	dc.w	$616E,$6365,$2000

mt_chan1temp	dc.l	0,0,0,0,$3ff0000,$00010000,0,0,0,0,0
mt_chan2temp	dc.l	0,0,0,0,$3ff0000,$00020000,0,0,0,0,0
mt_chan3temp	dc.l	0,0,0,0,$3ff0000,$00040000,0,0,0,0,0
mt_chan4temp	dc.l	0,0,0,0,$3ff0000,$00080000,0,0,0,0,0

mt_samplestarts	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

mt_songdataptr	dc.l	0
mt_module_end	dc.l	0

mt_speed	dc.b	6
mt_counter	dc.b	0
mt_songpos	dc.b	0
mt_pbreakpos	dc.b	0
mt_posjumpflag	dc.b	0
mt_pbreakflag	dc.b	0
mt_lowmask	dc.b	0
mt_pattdeltime	dc.b	0
mt_pattdeltime2	dc.b	0,0

mt_patternpos	dc.w	0
mt_dmacontemp	dc.w	0

mt_amiga_freq	dc.l	3545000
mt_save_Trap0	dc.l	0
mt_physic_buf	dc.l	mt_physic_base
mt_logic_buf	dc.l	mt_logic_base
mt_buf_length	dc.l	2000
mt_save_USP	dc.l	0
mt_save_SSP	dc.l	0
mt_volume_tab	dc.l	mt_volume_data
mt_zero_code	dc.l	mt_zero_data
mt_freq_code_0	dc.l	mt_freq_0
mt_freq_code_1	dc.l	mt_freq_1
mt_freq_table0	dc.l	mt_freq_points0
mt_freq_table1	dc.l	mt_freq_points1
mt_period_tab	dc.l	mt_period_count
mt_frequency	dc.w	$0003
mt_SR	dc.w	$0300

mt_channel_0	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
	dc.w	$3ff
	dc.w	$3ff,0
	dc.w	0
	dc.w	0
mt_channel_1	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
	dc.w	$3ff
	dc.w	$3ff,0
	dc.w	0
	dc.w	0
mt_channel_2	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
	dc.w	$3ff
	dc.w	$3ff,0
	dc.w	0
	dc.w	0
mt_channel_3	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
	dc.w	$3ff
	dc.w	$3ff,0
	dc.w	0
	dc.w	0

mt_dummy_spl_tab
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
	dc.w	$3ff
	dc.w	$3ff,0
	dc.w	0
	dc.w	0

mt_data	incbin	"A:ASEMBLER.S\DANE.DAT\*.MOD"
	ds.w	31*640/2	;These zeroes are necessary!
	section	bss
mt_freq_points0	ds.l	111
mt_freq_points1	ds.l	111
mt_period_count	ds.l	1024
mt_physic_base	ds.w	1000+2
mt_logic_base	ds.w	1000+2
mt_volume_data	ds.w	128+$41*128
mt_zero_data	ds.w	501
mt_freq_0	ds.w	44971
mt_freq_1	ds.w	45621
