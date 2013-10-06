exitcode	equ	0<<8
intropiccode	equ	1<<8
bumppiccode	equ	2<<8
kub16code	equ	3<<8
firefxcode	equ	4<<8
strblobcode	equ	5<<8
distrotcode	equ	6<<8
wire50code	equ	7<<8
tunnelcode	equ	8<<8
kaasblok	equ	9<<8
greetcode	equ	10<<8
voxelcode	equ	11<<8

introinitcode	equ	intropiccode|1
introdeinitcode	equ	intropiccode|2

pbumpinitcode	equ	bumppiccode|1
pbumpfuncode	equ	bumppiccode|2
pbumpbeatscode	equ	bumppiccode|3
pbumprescode	equ	bumppiccode|4
pbumpkickcode	equ	bumppiccode|5

kub16resetcode	equ	kub16code|1
kub16fwdcode	equ	kub16code|2
kub16stopcode	equ	kub16code|3
kub16logocode	equ	kub16code|4
kub16bmpfwdcode	equ	kub16code|5
kub16bmpbckcode	equ	kub16code|6
kub16rescode	equ	kub16code|7

firefxinitcode	equ	firefxcode|1
firefxblastcode	equ	firefxcode|2
firefxcntcode	equ	firefxcode|3
firefxtrigcode	equ	firefxcode|4
firefxfuncode	equ	firefxcode|5
firefxglecode	equ	firefxcode|6
firefxbeatscode	equ	firefxcode|7

strblobinitcode	equ	strblobcode|1
strblobinvcode	equ	strblobcode|2
strblobrescode	equ	strblobcode|3

distrotinitcode	equ	distrotcode|1
distrotinvcode	equ	distrotcode|2
distrotfuckcode	equ	distrotcode|3

wire50initcode	equ	wire50code|1
wire50fwdcode	equ	wire50code|2
wire50morphcode	equ	wire50code|3
wire50bumpcode	equ	wire50code|4
wire50chgcode	equ	wire50code|5
wire50inccode	equ	wire50code|6
wire50deccode	equ	wire50code|7
wire50nullcode	equ	wire50code|8
wire50stopcode	equ	wire50code|9
wire50rescode	equ	wire50code|10

tunnelinitcode	equ	tunnelcode|1
tunnelrescode	equ	tunnelcode|2

greetinitcode	equ	greetcode|1
greetrescode	equ	greetcode|2

voxelinitcode	equ	voxelcode|1
voxelrescode	equ	voxelcode|2

funintroevent_tbl:
	dc.w	(.end-.start)/6		* number of events in table
	dc.w	0			* current event (for optimisation)
.start:
	DC.L	0
	DC.W	introinitcode
	DC.L	0
	DC.W	voxelinitcode
	DC.L	0
	DC.W	intropiccode
	DC.L	900
	DC.W	pbumpinitcode
	DC.L	1280				* 1: MUSIC BY COMP7       
	DC.W	pbumprescode
	DC.L	1280
	DC.W	bumppiccode
	DC.L	1280
	DC.W	pbumpfuncode
	DC.L	1280
	DC.W	pbumpkickcode
	DC.L	1400				* 1: MUSIC BY COMP7       
	DC.W	pbumpkickcode
	DC.L	1560				* 1: MUSIC BY COMP7       
	DC.W	pbumpkickcode
	DC.L	1600				* 1    
	DC.W	pbumpkickcode
	DC.L	1720				* 1: MUSIC BY COMP7       
	DC.W	pbumpkickcode
	DC.L	1840				* 1: MUSIC BY COMP7       
	DC.W	pbumpbeatscode
	DC.L	1840
	DC.W	pbumpkickcode
	DC.L	1920				* 6:       * B . S . *    
	DC.W	pbumpkickcode
	DC.L	2040				* 1: MUSIC BY COMP7       
	DC.W	pbumpkickcode
	DC.L	2200				* 1: MUSIC BY COMP7       
	DC.W	pbumpkickcode
	DC.L	2240				* 1    
	DC.W	pbumpkickcode
	DC.L	2360				* 1: MUSIC BY COMP7       
	DC.W	pbumpkickcode
* Lame cube with logo's..
	dc.l	2400
	dc.w	kub16resetcode
	dc.l	2400
	dc.w	kub16code
	dc.l	2400
	dc.w	kub16rescode
	dc.l	2400
	dc.w	kub16fwdcode
	dc.l	2930
	dc.w	kub16stopcode
	dc.l	3000
	dc.w	kub16logocode
	DC.L	3000				* 1: MUSIC BY COMP7       
	DC.W	kub16bmpfwdcode
	DC.L	3020
	DC.W	kub16bmpbckcode
	DC.L	3120				* 1: MUSIC BY COMP7       
	DC.W	kub16bmpfwdcode
	DC.L	3140
	DC.W	kub16bmpbckcode
	DC.L	3200				* 1: MUSIC BY COMP7       
	DC.W	kub16bmpfwdcode
	DC.L	3220
	DC.W	kub16bmpbckcode
	DC.L	3320				* 1: MUSIC BY COMP7       
	DC.W	kub16bmpfwdcode
	DC.L	3340
	DC.W	kub16bmpbckcode
	DC.L	3480				* 1: MUSIC BY COMP7       
	DC.W	kub16bmpfwdcode
	DC.L	3500
	DC.W	kub16bmpbckcode
	DC.L	3520				* 1: MUSIC BY COMP7       
	DC.W	kub16bmpfwdcode
	DC.L	3540
	DC.W	kub16bmpbckcode
	DC.L	3640				* 1: MUSIC BY COMP7       
	DC.W	kub16bmpfwdcode
	DC.L	3680
	DC.W	kub16bmpbckcode
	DC.L	3760				* 1: MUSIC BY COMP7       
	DC.W	kub16bmpfwdcode
	DC.L	3780
	DC.W	kub16bmpbckcode
	DC.L	3800				* 1: MUSIC BY COMP7       
	DC.W	kub16bmpfwdcode
	DC.L	3820
	DC.W	kub16bmpbckcode
	DC.L	3840				* 1: MUSIC BY COMP7       
	DC.W	kub16bmpfwdcode
	DC.L	3860
	DC.W	kub16bmpbckcode
	DC.L	3960				* 1: MUSIC BY COMP7       
	DC.W	kub16bmpfwdcode
	DC.L	3980
	DC.W	kub16bmpbckcode
	DC.L	4120				* 1: MUSIC BY COMP7       
	DC.W	kub16bmpfwdcode
	DC.L	4140
	DC.W	kub16bmpbckcode
	DC.L	4160				* 1: MUSIC BY COMP7       
	DC.W	kub16bmpfwdcode
	DC.L	4180
	DC.W	kub16bmpbckcode
	DC.L	4280				* 1: MUSIC BY COMP7       
	DC.W	kub16bmpfwdcode
	DC.L	4300
	DC.W	kub16bmpbckcode
	DC.L	4400				* 1: MUSIC BY COMP7       
	DC.W	kub16bmpfwdcode
	DC.L	4420
	DC.W	kub16bmpbckcode
	DC.L	4480				* 1: MUSIC BY COMP7       
	DC.W	kub16bmpfwdcode
	DC.L	4500
	DC.W	kub16bmpbckcode
	DC.L	4600				* 1: MUSIC BY COMP7       
	DC.W	kub16bmpfwdcode
	DC.L	4620
	DC.W	kub16bmpbckcode
	DC.L	4760				* 1: MUSIC BY COMP7       
	DC.W	kub16bmpfwdcode
	DC.L	4780
	DC.W	kub16bmpbckcode
	DC.L	4800				* 1: MUSIC BY COMP7       
	DC.W	kub16bmpfwdcode
	DC.L	4820
	DC.W	kub16bmpbckcode
	DC.L	4920				* 1: MUSIC BY COMP7       
	DC.W	kub16bmpfwdcode
	DC.L	4940
	DC.W	kub16bmpbckcode
* C'mon baby light my fungle beats.
	DC.L	4890
	DC.W	intropiccode
	DC.L	4900
	DC.W	firefxinitcode
	DC.L	4900
	DC.W	firefxcode
	DC.L	4960
	DC.W	firefxfuncode
	DC.L	4985
	DC.W	firefxglecode
	DC.L	5035
	DC.W	firefxbeatscode
* Stretch da blobbies wildly just like them b3atZ!
	dc.l	5200
	dc.w	strblobinitcode
	dc.l	5200
	dc.w	strblobcode
	DC.L	5240				* 2: OF THE BASSMENT      
	DC.W	strblobinvcode
	DC.L	5320				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	strblobinvcode
	DC.L	5400				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	strblobinvcode
	DC.L	5440				* 2: OF THE BASSMENT      
	DC.W	strblobinvcode
	DC.L	5520				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	strblobinvcode
	DC.L	5560				* 2: OF THE BASSMENT      
	DC.W	strblobinvcode
	DC.L	5640				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	strblobinvcode
	DC.L	5680				* 5: ADDITIONAL VOCALS BY:
	DC.W	strblobinvcode
	DC.L	5760				* 2: OF THE BASSMENT      
	DC.W	strblobinvcode
	DC.L	5840				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	strblobinvcode
	DC.L	5880				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	strblobinvcode
	DC.L	5940				* 4: EXCL. FOR --FUN--    
	DC.W	strblobinvcode
	DC.L	6000				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	strblobinvcode
	DC.L	6080				* 2: OF THE BASSMENT      
	DC.W	strblobinvcode
	DC.L	6160				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	strblobinvcode
	DC.L	6200				* 2: OF THE BASSMENT      
	DC.W	strblobinvcode
	DC.L	6240				* 4: EXCL. FOR --FUN--    
	DC.W	strblobinvcode
	DC.L	6320				* 5: ADDITIONAL VOCALS BY:
	DC.W	strblobinvcode
	DC.L	6360				* 2: OF THE BASSMENT      
	DC.W	strblobinvcode
* Switch to cube shortly..
	DC.L	6400
	DC.W	kub16rescode
	DC.L	6400
	DC.W	kub16code
* Switch to blobs again..
	DC.L	6680
	DC.W	strblobcode
	DC.L	6680
	DC.W	strblobrescode
	DC.L	6680				* 2: OF THE BASSMENT      
	DC.W	strblobinvcode
	DC.L	6720				* 2: OF THE BASSMENT      
	DC.W	strblobinvcode
	DC.L	6800				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	strblobinvcode
	DC.L	6880				* 4: EXCL. FOR --FUN--    
	DC.W	strblobinvcode
	DC.L	6920				* 2: OF THE BASSMENT      
	DC.W	strblobinvcode
	DC.L	6960				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	strblobinvcode
	DC.L	7000				* 2: OF THE BASSMENT      
	DC.W	strblobinvcode
	DC.L	7040				* 2: OF THE BASSMENT      
	DC.W	strblobinvcode
	DC.L	7120				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	strblobinvcode
	DC.L	7160				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	strblobinvcode
	DC.L	7220				* 4: EXCL. FOR --FUN--    
	DC.W	strblobinvcode
	DC.L	7280				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	strblobinvcode
	DC.L	7360				* 2: OF THE BASSMENT      
	DC.W	strblobinvcode
	DC.L	7440				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	strblobinvcode
	DC.L	7480				* 2: OF THE BASSMENT      
	DC.W	strblobinvcode
	DC.L	7520				* 4: EXCL. FOR --FUN--    
	DC.W	strblobinvcode
	DC.L	7560				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	strblobinvcode
	DC.L	7580				* 2: OF THE BASSMENT      
	DC.W	strblobinvcode
	DC.L	7600				* 5: ADDITIONAL VOCALS BY:
	DC.W	strblobinvcode
	DC.L	7640				* 2: OF THE BASSMENT      
	DC.W	strblobinvcode
	DC.L	7680				* 2: OF THE BASSMENT      
	DC.W	strblobinvcode
* Kick in "FUN" wireframe object shortly..
	DC.L	7680
	DC.W	wire50initcode
	DC.L	7680
	DC.W	wire50code
	DC.L	7680
	DC.W	wire50rescode
* Switch back again..
	DC.L	7960
	DC.W	strblobcode
	DC.L	7960       
	DC.W	strblobrescode
	DC.L	8080				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	strblobinvcode
	DC.L	8120				* 2: OF THE BASSMENT      
	DC.W	strblobinvcode
	DC.L	8200				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	strblobinvcode
	DC.L	8240				* 5: ADDITIONAL VOCALS BY:
	DC.W	strblobinvcode
	DC.L	8320				* 2: OF THE BASSMENT      
	DC.W	strblobinvcode
	DC.L	8400				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	strblobinvcode
	DC.L	8440				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	strblobinvcode
	DC.L	8500				* 4: EXCL. FOR --FUN--    
	DC.W	strblobinvcode
	DC.L	8560				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	strblobinvcode
	DC.L	8640				* 2: OF THE BASSMENT      
	DC.W	strblobinvcode
	DC.L	8720				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	strblobinvcode
	DC.L	8760				* 2: OF THE BASSMENT      
	DC.W	strblobinvcode
	DC.L	8800				* 4: EXCL. FOR --FUN--    
	DC.W	strblobinvcode
	DC.L	8880				* 5: ADDITIONAL VOCALS BY:
	DC.W	strblobinvcode
	DC.L	8920				* 2: OF THE BASSMENT      
	DC.W	strblobinvcode
* Kick in "/|\" wireframe object shortly..
	DC.L	8960
	DC.W	wire50chgcode
	DC.L	8960
	DC.W	wire50rescode
	DC.L	8960
	DC.W	wire50code
* Switch back again..
	DC.L	9240      
	DC.W	strblobcode
	DC.L	9240       
	DC.W	strblobrescode
	DC.L	9280				* 2: OF THE BASSMENT      
	DC.W	strblobinvcode
	DC.L	9360				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	strblobinvcode
	DC.L	9440				* 4: EXCL. FOR --FUN--    
	DC.W	strblobinvcode
	DC.L	9480				* 2: OF THE BASSMENT      
	DC.W	strblobinvcode
	DC.L	9520				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	strblobinvcode
	DC.L	9560				* 2: OF THE BASSMENT      
	DC.W	strblobinvcode
	DC.L	9600				* 2: OF THE BASSMENT      
	DC.W	strblobinvcode
	DC.L	9680				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	strblobinvcode
	DC.L	9720				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	strblobinvcode
	DC.L	9780				* 4: EXCL. FOR --FUN--    
	DC.W	strblobinvcode
	DC.L	9840				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	strblobinvcode
	DC.L	9920				* 2: OF THE BASSMENT      
	DC.W	strblobinvcode
	DC.L	10000				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	strblobinvcode
	DC.L	10040				* 2: OF THE BASSMENT      
	DC.W	strblobinvcode
	DC.L	10080				* 4: EXCL. FOR --FUN--    
	DC.W	strblobinvcode
	DC.L	10120				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	strblobinvcode
	DC.L	10140				* 2: OF THE BASSMENT      
	DC.W	strblobinvcode
	DC.L	10160				* 5: ADDITIONAL VOCALS BY:
	DC.W	strblobinvcode
	DC.L	10200				* 2: OF THE BASSMENT      
	DC.W	strblobinvcode
	DC.L	10240				* 10: MICROSOFT, INTEL,    
	DC.W	distrotinitcode
	DC.L	10240    
	DC.W	distrotcode
	DC.L	10520				* 11: MABN (SELLS CRAP)    
	DC.W	distrotinvcode
	DC.L	10560				* 11: MABN (SELLS CRAP)    
	DC.W	distrotinvcode
	DC.L	10800				* 10: MICROSOFT, INTEL,    
	DC.W	distrotinvcode
	DC.L	10840				* 10: MICROSOFT, INTEL,    
	DC.W	distrotinvcode
	DC.L	10880				* 10: MICROSOFT, INTEL,    
	DC.W	distrotinvcode
	DC.L	11140				* 10: MICROSOFT, INTEL,    
	DC.W	distrotinvcode
	DC.L	11160				* 12: ACN (SELLS PIRACY)   
	DC.W	distrotinvcode
	DC.L	11200				* 12: ACN (SELLS PIRACY)   
	DC.W	distrotinvcode
	DC.L	11360				* 1: MUSIC BY COMP7       
	DC.W	distrotinvcode
	DC.L	11400				* 1: MUSIC BY COMP7       
	DC.W	distrotinvcode
	DC.L	11440				* 1: MUSIC BY COMP7       
	DC.W	distrotinvcode
	DC.L	11480				* 1: MUSIC BY COMP7       
	DC.W	distrotinvcode
	DC.L	11520				* 1: MUSIC BY COMP7       
	DC.W	distrotinvcode
	DC.L	11640				* 1: MUSIC BY COMP7       
	DC.W	distrotinvcode
	DC.L	11780				* 10: MICROSOFT, INTEL,    
	DC.W	distrotinvcode
	DC.L	11800				* 11: MABN (SELLS CRAP)    
	DC.W	distrotinvcode
	DC.L	11840				* 11: MABN (SELLS CRAP)    
	DC.W	distrotinvcode
	DC.L	11960				* 1: MUSIC BY COMP7       
	DC.W	distrotinvcode
	DC.L	12080				* 10: MICROSOFT, INTEL,    
	DC.W	distrotinvcode
	DC.L	12120				* 10: MICROSOFT, INTEL,    
	DC.W	distrotinvcode
	DC.L	12160				* 10: MICROSOFT, INTEL,    
	DC.W	distrotinvcode
	DC.L	12280				* 1: MUSIC BY COMP7       
	DC.W	distrotinvcode
	DC.L	12420				* 10: MICROSOFT, INTEL,    
	DC.W	distrotinvcode
	DC.L	12440				* 12: ACN (SELLS PIRACY)   
	DC.W	distrotinvcode
	DC.L	12480				* 4: EXCL. FOR --FUN--    
	DC.W	distrotinvcode
	DC.L	12560				* 4: EXCL. FOR --FUN--    
	DC.W	distrotinvcode
	DC.L	12600				* 1: MUSIC BY COMP7       
	DC.W	distrotinvcode
	DC.L	12640				* 5: ADDITIONAL VOCALS BY:
	DC.W	distrotinvcode
* Tunnel!!
	DC.L	12680				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	tunnelcode
	DC.L	12720				* 5: ADDITIONAL VOCALS BY:
	DC.W	distrotcode
	DC.L	12760				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	tunnelcode
	DC.L	12800				* 2: OF THE BASSMENT      
	DC.W	distrotcode
	DC.L	12920				* 2: OF THE BASSMENT      
	DC.W	tunnelcode
	DC.L	14000				* 1: MUSIC BY COMP7       
	DC.W	distrotfuckcode
	DC.L	14000
* Back to zoomrotate again..
	DC.W	distrotcode
	DC.L	14040				* 2: OF THE BASSMENT      
	DC.W	distrotinvcode
	DC.L	14080				* 2: OF THE BASSMENT      
	DC.W	distrotinvcode
	DC.L	14160				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	distrotinvcode
	DC.L	14200				* 2: OF THE BASSMENT      
	DC.W	distrotinvcode
	DC.L	14280				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	distrotinvcode
	DC.L	14340				* 10: MICROSOFT, INTEL,    
	DC.W	distrotinvcode
	DC.L	14360				* 4: EXCL. FOR --FUN--    
	DC.W	distrotinvcode
	DC.L	14400				* 2: OF THE BASSMENT      
	DC.W	distrotinvcode
	DC.L	14480				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	distrotinvcode
	DC.L	14520				* 2: OF THE BASSMENT      
	DC.W	distrotinvcode
	DC.L	14600				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	distrotinvcode
	DC.L	14640				* 10: MICROSOFT, INTEL,    
	DC.W	distrotinvcode
	DC.L	14680				* 10: MICROSOFT, INTEL,    
	DC.W	distrotinvcode
	DC.L	14720				* 2: OF THE BASSMENT      
	DC.W	distrotinvcode
	DC.L	14800				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	distrotinvcode
	DC.L	14840				* 2: OF THE BASSMENT      
	DC.W	distrotinvcode
	DC.L	14920				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	distrotinvcode
	DC.L	14980				* 10: MICROSOFT, INTEL,    
	DC.W	distrotinvcode
	DC.L	15000				* 4: EXCL. FOR --FUN--    
	DC.W	distrotinvcode
	DC.L	15040				* 8: GRTZ TO ALL ON #ATARI
	DC.W	distrotinvcode
* Zap to the tunnel fx!
	DC.L	15280				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	tunnelcode
	DC.L	15300				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	distrotcode
	DC.L	15320				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	tunnelcode
	DC.L	15340				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	distrotcode
	DC.L	15360				* 2: OF THE BASSMENT      
	DC.W	tunnelcode
	DC.L	16180				* 4: EXCL. FOR --FUN--    
	DC.W	strblobcode
	DC.L	16240				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	strblobinvcode
	DC.L	16260				* 10: MICROSOFT, INTEL,    
	DC.W	strblobinvcode
	DC.L	16280				* 12: ACN (SELLS PIRACY)   
	DC.W	strblobinvcode
	DC.L	16320				* 2: OF THE BASSMENT      
	DC.W	strblobinvcode
	DC.L	16400				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	strblobinvcode
	DC.L	16440				* 2: OF THE BASSMENT      
	DC.W	strblobinvcode
	DC.L	16480				* 4: EXCL. FOR --FUN--    
	DC.W	strblobinvcode
	DC.L	16560				* 5: ADDITIONAL VOCALS BY:
	DC.W	strblobinvcode
	DC.L	16600
	DC.W	distrotcode
	DC.L	16640				* 2: OF THE BASSMENT      
	DC.W	distrotinvcode
	DC.L	16720				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	distrotinvcode
	DC.L	16760				* 2: OF THE BASSMENT      
	DC.W	distrotinvcode
	DC.L	16800				* 6:       * B . S . *    
	DC.W	distrotinvcode
	DC.L	16840				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	distrotinvcode
	DC.L	16900				* 10: MICROSOFT, INTEL,    
	DC.W	distrotinvcode
	DC.L	16920				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	distrotinvcode
	DC.L	16960				* 2: OF THE BASSMENT      
	DC.W	distrotinvcode
	DC.L	17040				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	distrotinvcode
	DC.L	17080				* 2: OF THE BASSMENT      
	DC.W	distrotinvcode
	DC.L	17120				* 6:       * B . S . *    
	DC.W	distrotinvcode
	DC.L	17160				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	distrotinvcode
	DC.L	17200				* 5: ADDITIONAL VOCALS BY:
	DC.W	distrotinvcode
	DC.L	17240				* 10: MICROSOFT, INTEL,    
	DC.W	distrotinvcode
	DC.L	17280				* 2: OF THE BASSMENT      
	DC.W	distrotinvcode
	DC.L	17360				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	distrotinvcode
	DC.L	17400				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	distrotinvcode
	DC.L	17440				* 6:       * B . S . *    
	DC.W	strblobcode
	DC.L	17460				* 4: EXCL. FOR --FUN--    
	DC.W	strblobinvcode
	DC.L	17520				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	strblobinvcode
	DC.L	17540				* 10: MICROSOFT, INTEL,    
	DC.W	strblobinvcode
	DC.L	17560				* 12: ACN (SELLS PIRACY)   
	DC.W	strblobinvcode
	DC.L	17600				* 2: OF THE BASSMENT      
	DC.W	strblobinvcode
	DC.L	17680				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	strblobinvcode
	DC.L	17720				* 2: OF THE BASSMENT      
	DC.W	strblobinvcode
	DC.L	17760				* 4: EXCL. FOR --FUN--    
	DC.W	strblobinvcode
	DC.L	17840				* 5: ADDITIONAL VOCALS BY:
	DC.W	strblobinvcode
	DC.L	17880				* 2: OF THE BASSMENT      
	DC.W	strblobinvcode
	DC.L	17920				* 2: OF THE BASSMENT      
	DC.W	strblobinvcode
	DC.L	18000				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	strblobinvcode
	DC.L	18040				* 2: OF THE BASSMENT      
	DC.W	strblobinvcode
	DC.L	18080				* 6:       * B . S . *    
	DC.W	strblobinvcode
	DC.L	18120				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	strblobinvcode
	DC.L	18180				* 10: MICROSOFT, INTEL,    
	DC.W	strblobinvcode
	DC.L	18200				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	distrotcode
	DC.L	18240				* 2: OF THE BASSMENT      
	DC.W	distrotinvcode
	DC.L	18320				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	distrotinvcode
	DC.L	18360				* 2: OF THE BASSMENT      
	DC.W	distrotinvcode
	DC.L	18400				* 6:       * B . S . *    
	DC.W	distrotinvcode
	DC.L	18440				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	distrotinvcode
	DC.L	18480				* 5: ADDITIONAL VOCALS BY:
	DC.W	distrotinvcode
	DC.L	18520				* 10: MICROSOFT, INTEL,    
	DC.W	distrotinvcode
	DC.L	18560				* 2: OF THE BASSMENT      
	DC.W	distrotinvcode
	DC.L	18640				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	distrotinvcode
	DC.L	18680				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	distrotinvcode
	DC.L	18720				* 6:       * B . S . *    
	DC.W	distrotinvcode
	DC.L	18740				* 4: EXCL. FOR --FUN--    
	DC.W	distrotinvcode
	DC.L	18800				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	distrotinvcode
	DC.L	18820				* 10: MICROSOFT, INTEL,    
	DC.W	distrotinvcode
	DC.L	18840				* 12: ACN (SELLS PIRACY)   
	DC.W	distrotinvcode
	DC.L	18880				* 2: OF THE BASSMENT      
	DC.W	distrotinvcode
	DC.L	18960				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	distrotinvcode
	DC.L	19000				* 2: OF THE BASSMENT      
	DC.W	distrotinvcode
	DC.L	19040				* 4: EXCL. FOR --FUN--    
	DC.W	distrotinvcode
	DC.L	19120				* 5: ADDITIONAL VOCALS BY:
	DC.W	distrotinvcode
	DC.L	19160				* 2: OF THE BASSMENT      
	DC.W	distrotinvcode
	DC.L	19200				* 2: OF THE BASSMENT      
	DC.W	distrotinvcode
	DC.L	19280				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	distrotinvcode
	DC.L	19320				* 2: OF THE BASSMENT      
	DC.W	distrotinvcode
	DC.L	19360				* 6:       * B . S . *    
	DC.W	distrotinvcode
	DC.L	19400				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	distrotinvcode
	DC.L	19460				* 10: MICROSOFT, INTEL,    
	DC.W	distrotinvcode
	DC.L	19480				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	distrotinvcode
	DC.L	19520				* 2: OF THE BASSMENT      
	DC.W	distrotinvcode
	DC.L	19600				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	distrotinvcode
	DC.L	19640				* 2: OF THE BASSMENT      
	DC.W	distrotinvcode
	DC.L	19680				* 6:       * B . S . *    
	DC.W	distrotinvcode
	DC.L	19720				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	distrotinvcode
	DC.L	19760				* 5: ADDITIONAL VOCALS BY:
	DC.W	distrotinvcode
	DC.L	19800				* 10: MICROSOFT, INTEL,    
	DC.W	distrotinvcode
	DC.L	19840				* 2: OF THE BASSMENT      
	DC.W	distrotinvcode
	DC.L	19920				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	distrotinvcode
	DC.L	19960				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	distrotinvcode
	DC.L	20000				* 6:       * B . S . *    
	DC.W	distrotinvcode
	DC.L	20020				* 4: EXCL. FOR --FUN--    
	DC.W	distrotinvcode
	DC.L	20080				* 3: WWW.BASSMENT.DEMON.NL
	DC.W	distrotinvcode
	DC.L	20100				* 10: MICROSOFT, INTEL,    
	DC.W	distrotinvcode
	DC.L	20120				* 12: ACN (SELLS PIRACY)   
	DC.W	distrotinvcode
	DC.L	20160				* 12: ACN (SELLS PIRACY)   
	DC.W	distrotinvcode
	DC.L	20280				* 1: MUSIC BY COMP7       
	DC.W	distrotinvcode
* Voxel space (Votze spaž)
	DC.L	20320				* 14: KNARF (KGMD),        
	DC.W	voxelcode
* Greetscreen..
	DC.L	28200
	DC.W	intropiccode
	DC.L	28200
	DC.W	greetinitcode
	DC.L	28200
	DC.W	greetrescode
	DC.L	28200
	DC.W	greetcode
	DC.L	40000
	DC.W	exitcode
.end: