;Falgs that the client can set in the AV_PROTOKOLL message to the avserver to
;tell it the av_stuff it suupports.
;cs_xx = Client Supports
cs_va_setstatus		= 0
cs_va_start		= 1
cs_av_started		= 2
cs_va_fontchanged	= 3
cs_filename_quoting	= 4
cs_va_path_udpate	= 5

;These are the names for the bits returned by the av server in a VA_PROTOSTATUS message
;in reply to a clients AV_PROTOKOLL message.

;Status word 1 (msg word 3)
ss_av_sendkey		= 0
ss_av_askfilefont	= 1
ss_av_askconfont	= 2
ss_av_askobject		= 3
ss_av_openwind		= 4
ss_av_startprog		= 5
ss_av_accwindopen	= 6
ss_av_accwindclosed	= ss_av_accwindopen
ss_av_status		= 7
ss_av_getstatus		= ss_av_status
ss_av_copy_dragged	= 8
ss_av_path_update	= 9
ss_av_what_izit		= ss_av_path_update
ss_av_drag_on_window	= ss_av_path_update
ss_av_exit		= 10
ss_av_xwind		= 11
ss_va_fontchanged	= 12
ss_av_started		= 13
ss_filename_quoting	= 14
ss_av_fileinfo		= 15
ss_va_filechanged	= ss_av_fileinfo

;status word 1 (msg word 4)
ss_av_copyfile		= 0
ss_va_filecopied	= ss_av_copyfile
ss_av_delfile		= 1
ss_va_filedeleted	= ss_av_delfile
ss_va_view		= 2
ss_av_viewed		= ss_va_view
ss_av_setwindpos	= 3



AV_PROTOKOLL	  = $4700
AV_GETSTATUS	  = $4703
AV_STATUS	  = $4704
AV_SENDKEY	  = $4710
AV_ASKFILEFONT	  = $4712
AV_ASKCONFONT	  = $4714
AV_OPENWIND	  = $4720
AV_STARTPROG	  = $4722
AV_ACCWINDOPEN	  = $4724
AV_ACCWINDCLOSED  = $4726
AV_COPY_DRAGGED	  = $4728
AV_PATH_UPDATE	  = $4730
AV_WHAT_IZIT	  = $4732
AV_DRAG_ON_WINDOW = $4734
AV_EXIT		  = $4736
AV_STARTED	  = $4738
AV_XWIND	  = $4740
AV_VIEW		  = $4751
AV_FILEINFO	  = $4753
AV_COPYFILE	  = $4755
AV_DELFILE	  = $4757

VA_PROTOSTATUS	  = $4701
VA_SETSTATUS	  = $4705
VA_START	  = $4711
VA_FILEFONT	  = $4713
VA_CONFONT	  = $4715
VA_WINDOPEN	  = $4721
VA_PROGSTART	  = $4723
VA_DRAGACCWIND	  = $4725
VA_COPY_COMPLETE  = $4729
VA_THAT_IZIT	  = $4733
VA_DRAG_COMPLETE  = $4735
VA_FONTCHANGED	  = $4739
VA_XOPEN	  = $4741
VA_VIEWED	  = $4752
VA_FILECHANGED	  = $4754
VA_FILECOPIED	  = $4756
VA_FILEDELETED	  = $4758
VA_PATH_UPDATE	  = $4760
                    