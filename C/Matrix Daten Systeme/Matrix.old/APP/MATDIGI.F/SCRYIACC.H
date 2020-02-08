# define MATscreyeCookie "mSEY"

extern int _GetScreenEyeParameter ( unsigned magic ) ;
# define GetScreenEyeParameter() _GetScreenEyeParameter((unsigned)sizeof(TScreenEyeParameterBlock))

extern TScreenEyeParameterBlock *ScreenEyeParameter ;

# define GetDmsdType() 				 (ScreenEyeParameter->DmsdParam->dmsd)
# define GetWaitUntilFrameGrabbed()  (ScreenEyeParameter->DigiParam->waituntilgrabbed)
# define GetVideoSignal()			 (ScreenEyeParameter->DmsdParam->signal)
# define GetVideoSource()			 (ScreenEyeParameter->DmsdParam->source)
# define GetVideoStandard()			 (ScreenEyeParameter->DmsdParam->standard)
# define SetWaitUntilFrameGrabbed(b) ScreenEyeParameter->DigiParam->waituntilgrabbed = b
# define SetVideoSignal(s)			 ScreenEyeParameter->DmsdParam->signal = s
# define SetVideoSource(s)			 ScreenEyeParameter->DmsdParam->source = s
# define SetVideoStandard(s)		 ScreenEyeParameter->DmsdParam->standard = s

# define BlitGreyWindow(w,z) 		(*(ScreenEyeParameter->_BlitGreyWindow))(w,z)
# define Blit555SWWindow(w,z) 		(*(ScreenEyeParameter->_Blit555SWWindow))(w,z)
# define Blit555HWSimWindow(w,z) 	(*(ScreenEyeParameter->_Blit555HWSimWindow))(w,z)
# define Blit555Window(w,z) 		(*(ScreenEyeParameter->_Blit555Window))(w,z)
# define BlitRGBWindow(w,z) 		(*(ScreenEyeParameter->_BlitRGBWindow))(w,z)
# define BlitF332Window(w,z) 		(*(ScreenEyeParameter->_BlitF332Window))(w,z)
# define BlitF8GreyWindow(w,z) 		(*(ScreenEyeParameter->_BlitF8GreyWindow))(w,z)
# define BlitFyc224Window(w,z) 		(*(ScreenEyeParameter->_BlitFyc224Window))(w,z)

# define ImageInfo(in,im) (*(ScreenEyeParameter->_ImageInfo))(in,im)
# define WindowInfo(i,w) (*(ScreenEyeParameter->_WindowInfo))(i,w)
# define BlitWindowInfo(w) (*(ScreenEyeParameter->_BlitWindowInfo))(w)
# define ImageWindowInfo(i,w) (*(ScreenEyeParameter->_ImageWindowInfo))(i,w)

# define SetToFullSize(b,d,w,h,p) (*(ScreenEyeParameter->_SetToFullSize))(b,d,w,h,p)

# define PixelPosition(i) (*(ScreenEyeParameter->_PixelPosition))(i)

# define InitGreyTo555Table() (*(ScreenEyeParameter->_InitGreyTo555Table))()
# define InitGreyTo555TableWithColors() (*(ScreenEyeParameter->_InitGreyTo555TableWithColors))()

# define GrabFieldIntoFifo(w,f) (*(ScreenEyeParameter->_GrabFieldIntoFifo))(w,f)

# define DigitiseFrame(b,z,w) (*(ScreenEyeParameter->_DigitiseFrame))(b,z,w)
# define ResetGrabber() (*(ScreenEyeParameter->_ResetGrabber))()

# define chk_set_video_standard(s)  (*(ScreenEyeParameter->_chk_set_video_standard))(s)
# define chk_set_chan_sig(c,s,b) (*(ScreenEyeParameter->_chk_set_chan_sig))(c,s,b)
# define chk_set_signal(c,s,b) (*(ScreenEyeParameter->_chk_set_signal))(c,s,b)
# define set_lumi_cntrl(a,c,b,p,by) (*(ScreenEyeParameter->_set_lumi_cntrl))(a,c,b,p,by)
# define GetDmsdStatus(l,c,f) (*(ScreenEyeParameter->_GetDmsdStatus))(l,c,f)
# define InitMdf(si,so,c)  (*(ScreenEyeParameter->_InitMdf))(si,so,c)
# define InitDmsd(c)  (*(ScreenEyeParameter->_InitDmsd))(c)

# define DigitiseMatrix(nx,ny,bw,z,w) (*(ScreenEyeParameter->_DigitiseMatrix))(nx,ny,bw,z,w)
# define InterPolate555(s,d,z) (*(ScreenEyeParameter->_InterPolate555))(s,d,z)
# define StretchBlit(s,d) (*(ScreenEyeParameter->_StretchBlit))(s,d)

# define WriteRGBFiles(f,w,h,d) 	(*(ScreenEyeParameter->_WriteRGBFiles))(f,w,h,d)
# define WriteTargaFile(f,w,h,d) 	(*(ScreenEyeParameter->_WriteTargaFile))(f,w,h,d)
# define WriteFrame(s,b,f) 			(*(ScreenEyeParameter->_WriteFrame))(s,b,f)
# define WriteSequenceHeader(s,b,m) (*(ScreenEyeParameter->_WriteSequenceHeader))(s,b,m)
# define SequenceWrite(s,b,f,t,m) 	(*(ScreenEyeParameter->_SequenceWrite))(s,b,f,t,m)

# define ReadTargaFrame(s,b,f) (*(ScreenEyeParameter->_ReadTargaFrame))(s,b,f)
# define ReadBlockFrame(s,b,f) (*(ScreenEyeParameter->_ReadBlockFrame))(s,b,f)
# define ReadFrame(s,b,f) (*(ScreenEyeParameter->_ReadFrame))(s,b,f)
# define ReadSequenceHeader(s,b) (*(ScreenEyeParameter->_ReadSequenceHeader))(s,b)
# define SequenceRead(s,b,f,t) (*(ScreenEyeParameter->_SequenceRead))(s,b,f,t)

# define FreeConvBuffer() (*(ScreenEyeParameter->_FreeConvBuffer))()

# define InitSequence(s) (*(ScreenEyeParameter->_InitSequence))(s)
# define MallocSequence(s,n,w,z) (*(ScreenEyeParameter->_MallocSequence))(s,n,w,z)
# define FreeSequence(s) (*(ScreenEyeParameter->_FreeSequence))(s)
# define SequenceInfo(s) (*(ScreenEyeParameter->_SequenceInfo))(s)
# define RecordSequence(s,w) (*(ScreenEyeParameter->_RecordSequence))(s,w)
# define PlaySequence(s,w) (*(ScreenEyeParameter->_PlaySequence))(s,w)

# define RecordStart(s) (*(ScreenEyeParameter->_RecordStart))(s)
# define RecordStop(s) (*(ScreenEyeParameter->_RecordStop))(s)
# define RecordRestart(s) (*(ScreenEyeParameter->_RecordRestart))(s)
# define RecordCurrFrame(s,w) (*(ScreenEyeParameter->_RecordCurrFrame))(s,w)
# define RecordFrame(s,f,w) (*(ScreenEyeParameter->_RecordFrame))(s,f,w)

# define PlayStart(s,st) (*(ScreenEyeParameter->_PlayStart))(s,st)
# define PlayRestart(s) (*(ScreenEyeParameter->_PlayRestart))(s)
# define PlayStop(s) (*(ScreenEyeParameter->_PlayStop))(s)

# define PlaySyncCurrent(s) (*(ScreenEyeParameter->_PlaySyncCurrent))(s)

# define ActivateFrame(s,f) (*(ScreenEyeParameter->_ActivateFrame))(s,f)
# define DisplayCurrentFrame(s,w) (*(ScreenEyeParameter->_DisplayCurrentFrame))(s,w)

# define ChkAndSetCurrentFrame(s,f) (*(ScreenEyeParameter->_ChkAndSetCurrentFrame))(s,f)
# define DisplayFrame(s,f,w) (*(ScreenEyeParameter->_DisplayFrame))(s,f,w)

# define AbortLoopFunction() (*(ScreenEyeParameter->_AbortLoopFunction))()

# define LoadMdfLcaFile(t,v,r) (*(ScreenEyeParameter->_LoadMdfLcaFile))(t,v,r)
# define SetDmsdType(c,l) 		 (*(ScreenEyeParameter->_SetDmsdType))(c,l)
# define ResetDigiWindows(w) 	 (*(ScreenEyeParameter->_ResetDigiWindows))(w)
# define CheckDigiWindows(w,z,d) (*(ScreenEyeParameter->_CheckDigiWindows))(w,z,d)

# define LoadMatDigiFLcaData(c,m,z,i) (*(ScreenEyeParameter->_LoadMatDigiFLcaData))(c,m,z,i)

# define yuv_to_rgb(o,y,cr,cb) (*(ScreenEyeParameter->_yuv_to_rgb))(o,y,cr,cb)
# define CheckCalcCSCtables(co) (*(ScreenEyeParameter->_CheckCalcCSCtables))(co)
