Denna filstruktor „r ett exempel hur det kan se ut med vart olika filer, etc 
ligger.

/System/							System-biblioteket.
	Devices/						Olika drivrutiner f”r Operativsystemet
		Midi.device/*				Midi anv„ndingsrutiner
			Midi.drv
			Parallell.drv
			dsp.drv
		Serial.device/*				Modem-rutiner
			Midi.drv
			Modem1.drv
			Modem2.drv
            ...
			Lan.drv
			Zmodem.drv
			Hydra.drv
			Jekyll.drv
			Xmodem.drv
			Ymodem.drv
			Kermit.drv
		Printer.device/*			Hantering av Printerutskriftar
			parallell.drv
			acsi.drv
			scsi.drv
			seriell.drv
		Remote.device/*				Rutiner f”r att koppla ihop 2 datorer och
			Parallell.drv			dela filer, mm.
			acsi.drv
			seriell.drv
			lan.drv
			scsi.drv
		Disc.device/*				Olika diskformat/Filformat
            Firestorm.drv
			Dos.drv
			Macintosh.drv
			Atari.drv
            Amiga.drv
            ISO9660.drv
            Sierra.drv
            CD.drv
            CD+G.drv
            PhotoCD.drv
            Unix.drv
            PlayStation.drv
            Jaguar.drv
		Window.Device/*				F”nsterhanteringsrutiner, mm
			Dialog.module
            Window.module
		Font.Device/*				Font-hanteringsrutiner
			Truetype.module
			Speedo.module
			Calamus.module
			Postscript.module
			bitmap.module
		Desktop.Device/*			Desktop-rutiner
			Firestorm
			Fontselect.module
			FileSelect.module
			ColourSelect.module
		Graphics.Device/*           anv„ndes f”r att konvertera bilder
			Gif.module
			Targa.module
			Jpeg.module
			Neochrome.module
			AmigaIFF.module
			png.module
		Sound.device/*
			Player
			Mpeg1.module
			Mpeg2.module
			AU.module
			Wav.module
			FM.module
		Movie.device/*
			Fli.module
			Mpeg.module
			AVI.module
			Quicktime.module
        Misc.Device/*
        	Octalyser.module
        	FastTrackerII.module
        	DigitalTracker.module
			GraumfTracker.module
            ...
        Network.device/* 
            TCP.module
            IP.module
            IPX.module
            ICMP.module
            UDP.module
            SLIP.module
            PLIP.module
            CSLIP.module
            PPP.module
            Ethernet.module
            TokenRing.module
            TokenBuss.module
	Programs/
		Format*
		Copy*
		Move*
		Edit*
		Help/*
			St-guide.module
			Windows.module
			FireSTorm.module
		Print*
		ScreenSaver/*
        Chmod*
		User_edit*
        ...
    Icons/
        Image.icon
        music.icon
    Install/
        FireStorm_Web.install
        "program namn".install
/user/
	"username1"/
        firestorm.inf/
        	login.scr
        	program.setup
        	groups.inf
            "Program-info-filer"
        	"Program-config-filer"

		"bilbliotek"/
		"Program"*
		"filer"
	"username2"/
	"username3"/
	.../
/Programs
	FireSTorm_Web/*
		Plugins/*
			MusicPlayer*
			MoviePlayer*
			3DPlayer*
            SoundPlayer*
	Sound_Player*
	Movie_Player*
	Picture_Viewer*
	Music_Player*
    Document_Viewer/*
    	
F”rklaringar.
/ bibliotek
* K”rbart
... osv, se ovan, f”ljer samma struktur.
"namn" beror p†. :)