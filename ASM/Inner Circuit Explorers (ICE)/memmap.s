~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
| Memory-map of the Falcon030. Ver0.1  By T.Nilsson |
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 	
 	$0	OS   RAM  (-$5b4)	
      $800 	User RAM	
	||
   $0fffff 	end of  1Mb
	||
	||
   $3fffff	end of  4Mb 
        ||
        ||
        ||
   $dfffff	end of 14Mb 
   $e00000	OS   ROM, 512Kb
 	|
   $e80000	duplicate
 	|
   $efffff	end of TOS
   $f00000	IDE Controller
   $f00000    	Adspeed conf. reg. 
  	|	($f00000-$f50000)
        |
   $fa0000 	128K cartridge (-$fc)
        |
        |
        |
   $ff8000	ST MMU Controller
   $ff8006	Monitortype (VIDEL)
   $ff8007	F030 Proc. control
    	|	(0d?)
   $ff8200	Shifter (STE)
   $ff820e	VIDEL!
   $ff8240	STE 16 color reg.
        |
   $ff8600	DMA/DISK Controller
        |
   $ff8800	PSG YM2149 Sound
        |
   $ff8900	PCM (DMA sound) system
   $ff8930	DMA/DSP controller
   $ff8937	Codec...
   $ff8941	GPx control (DSP-port)
        |
   $ff8a00	Blitter
        |
   $ff8c81	Zilog 8530 SCC
        |
   $ff9200	Ext. joy ports
        |
   $ff9800	VIDEL 256 col. reg.
        |
   $ffa200	DSP Host interface
        |
        |
   $fffa01	MFP MC68901
        |
   $fffc00	ACIA 6850 I/O  
   	|	(2 ones: key & MIDI)
   $fffc21	Realtime clock
   	
   	
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 		
      
   
   