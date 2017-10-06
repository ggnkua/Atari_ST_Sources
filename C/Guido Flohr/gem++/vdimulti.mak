VDICLASS = gclass.o

VDIATRIB = gswr_mo.o gs_colo.o gsl_typ.o gsl_uds.o gsl_wid.o \
	   gsl_col.o gsl_end.o gsm_typ.o gsm_hei.o gsm_col.o \
	   gst_hei.o gst_poi.o gst_rot.o gst_fon.o gst_col.o \
	   gst_eff.o gst_ali.o gsf_int.o gsf_fil.o gsf_col.o \
	   gsf_per.o gsf_udp.o gsf_sty.o

VDICTRL1 = gopnwk.o gclswk.o gopnvw.o gclsvw.o 

VDICTRL2 = gclrwk.o gupdwk.o gst_loa.o gst_unl.o gs_clip.o 

VDIESC = gq_chce.o gexit_.o genter.o gcurup.o  gcurdow.o \
	 gcurrig.o gcurlef.o gcurhom.o geeos.o   geeol.o   \
	 gs_cura.o gcurtex.o grvoff.o  grvon.o   gq_cura.o

VDIESC1 = gq_tabs.o ghardco.o gdspcur.o grmcur.o  gform_a.o \
	  goutput.o gclear_.o gbit_im.o gq_scan.o  galpha_.o \
	  gs_pale.o gsound.o  gs_mute.o  gt_reso.o gt_axis.o  \
	  gt_orig.o gq_dime.o gt_alig.o gsp_fil.o gqp_fil.o \
	  gsc_exp.o gmeta_e.o gwrite_.o gm_page.o gm_coor.o \
	  gm_file.o gescape.o 

VDIFSM = gqt_fex.o gftext.o gfteof.o ggetout.o gst_scr.o gst_err.o \
	 gshtext.o gst_arb.o gst_ar3.o gqt_adv.o gqt_ad3.o gqt_dev.o \
	 gsaveca.o gloadca.o gflushc.o gst_set.o gst_se3.o gst_ske.o \
	 gqt_get.o gqt_cac.o gst_cha.o gst_ker.o gqt_fnt.o gqt_tra.o \
	 gqt_pai.o ggetbit.o

VDIGDP = gbar.o    garc.o  gpiesli.o gcircle.o gellarc.o \
	 gellpie.o gellips.o grbox.o grfbox.o  gjustif.o 

VDIINP = gsin_mo.o gsm_loc.o grq_val.o gsm_val.o grq_cho.o \
	 gsm_cho.o gsm_str.o gsc_for.o gex_tim.o gshow_c.o \
	 ghide_c.o gq_mous.o gex_but.o gex_mot.o gex_cur.o \
	 gq_key_.o 

VDIINQ = gq_extn.o gq_colo.o gql_att.o gqm_att.o \
	 gqf_att.o gqt_att.o gqt_ext.o gqt_wid.o \
	 gqt_nam.o gq_cell.o gqin_mo.o gqt_fon.o 

VDIOUT = gpline.o  gpmarke.o ggtext.o gfillar.o gcellar.o \
	 gcontou.o gr_recf.o 

VDIQGDOS = gq_gdos.o gq_vgdo.o 

VDIRAS = gro_cpy.o grt_cpy.o gr_trnf.o gget_pi.o 

VDIBEZ = gset_ap.o gbez_co.o gbez_on.o gbez_of.o gbez.o gbez_fi.o gbez_qu.o

VDIOBJ = $(VDICLASS) $(VDIATRIB) $(VDICTRL1) $(VDICTRL2) $(VDIESC) $(VDIESC1) $(VDIFSM) \
	$(VDIGDP) $(VDIINP) $(VDIINQ) $(VDIOUT) $(VDIQGDOS) $(VDIRAS) $(VDIBEZ)


#compilation rules

$(VDIOBJ): %.o: vdi++.cc
	$(COMPILE) -DL_$* vdi++.cc -o $@

#$(VDICLASS): %.o: vdi.cc
#	$(CCC) $(CXXFLAGS) '-DL_$*' -c vdi.cc -o '$@'
#
#$(VDIATRIB): %.o: vdi.cc
#	$(CCC) $(CXXFLAGS) '-DL_$*' -c vdi.cc -o '$@'
#
#$(VDICTRL1): %.o: vdi.cc
#	$(CCC) $(CXXFLAGS) '-DL_$*' -c vdi.cc -o '$@'
#
#$(VDICTRL2): %.o: vdi.cc
#	$(CCC) $(CXXFLAGS) '-DL_$*' -c vdi.cc -o '$@'
#
#$(VDIESC): %.o: vdi.cc
#	$(CCC) $(CXXFLAGS) '-DL_$*' -c vdi.cc -o '$@'
#
#$(VDIESC1): %.o: vdi.cc
#	$(CCC) $(CXXFLAGS) '-DL_$*' -c vdi.cc -o '$@'
#
#$(VDIFSM): %.o: vdi.cc
#	$(CCC) $(CXXFLAGS) '-DL_$*' -c vdi.cc -o '$@'
#
#$(VDIGDP): %.o: vdi.cc
#	$(CCC) $(CXXFLAGS) '-DL_$*' -c vdi.cc -o '$@'
#
#$(VDIINP): %.o: vdi.cc
#	$(CCC) $(CXXFLAGS) '-DL_$*' -c vdi.cc -o '$@'
#
#$(VDIINQ): %.o: vdi.cc
#	$(CCC) $(CXXFLAGS) '-DL_$*' -c vdi.cc -o '$@'
#
#$(VDIOUT): %.o: vdi.cc
#	$(CCC) $(CXXFLAGS) '-DL_$*' -c vdi.cc -o '$@'
#
#$(VDIQGDOS): %.o: vdi.cc
#	$(CCC) $(CXXFLAGS) '-DL_$*' -c vdi.cc -o '$@'
#
#$(VDIRAS): %.o: vdi.cc
#	$(CCC) $(CXXFLAGS) '-DL_$*' -c vdi.cc -o '$@'
#
#$(VDIBEZ): %.o: vdi.cc
#	$(CCC) $(CXXFLAGS) '-DL_$*' -c vdi.cc -o '$@'
#
#