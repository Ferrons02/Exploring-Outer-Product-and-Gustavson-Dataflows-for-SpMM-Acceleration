; v0.7 - zerun@ethz.ch	Fri 20 Dec 12:34:00 CET 2024
;  - set the license order of spectre to avoid unsported PRODOCT license: spectre_X_sc, Virtuoso_Acceler_Parallel_sc
; v0.6 - <bmuheim@ethz.ch> - Mon Dec 11 13:31:41 CET 2023
;  - add License order for ADE
; v0.5 - <muheim@ee.ethz.ch> - Wed May 25 14:14:47 CEST 2022
;  - removing of the Spectre/models setting - this will by don correctly thru
;    the load of the libs.
; v0.4 - <muheim@ee.ethz.ch> - Tue Jan 14 09:04:02 CET 2020
;  - seting the modelFiles for ams, UltraSim and spectre
;    "design_wrapper.lib.scs;tt_post" and design_wrapper_rf.lib.scs;tt_post")
; v0.3 - <muheim@ee.ethz.ch> - Mon Mar 11 12:30:13 CET 2019
;  - change seting of the modelFiles for spectre to
;    "design_wrapper.lib.scs;tt_post"
; v0.2 - <muheim@ee.ethz.ch> - Wed Nov 29 09:34:33 CET 2017
;  - change SnapSpacing from 0.005 to 0.001
; v0.1 - <kgf@ee.ethz.ch> - Thu Jun 30 16:39:25 CEST 2016
;  - copy from tsmc28, adapted it, still tons of questionable stuff
;    add spectre modelFiless settings

; 610 settings
envSetVal( "ui"  "webBrowser" 'string  "/usr/bin/firefox")
envSetVal( "graphic" "schematicDefaultApp" 'string  "Schematics XL")
envSetVal( "graphic" "maskLayoutDefaultApp"  'string  "Layout L")


; after 6.13.515 the following will work
;   http://support.cadence.com/wps/myportal/cos/COSHome/viewsolution/!ut/p/a1/tY_NboMwEISfhXsqr8HE5Og2FRQIKC1RMZcIGjexEhvET6Tm6WtHkXpKe-redvbbmV1UoRJVuj7LfT3KVtcn21fz7Qt-JjjKIQ4X7AkY0HW8SbCbUN8A3ABwpxj8tf-OqivyiwM3EfTHI0jTBbAwmb9GtPAgp2ij216ZY9-s106ILpX6iPjYT8Iqy_ZjUkKPxVcnjNoMh1HvZ7tPKe10aE-TfTabVCN6xDH2A0qwe4v1oyWBGHCcP7oUWFSQkGQphtz9p9hOlfDAVeCp7aoQzYUxx_kG1VI85A!!/dl5/d5/L2dBISEvZ0FBIS9nQSEh/
envSetVal( "license" "VLSL_UseNextLicense"   'string "always")
envSetVal( "license" "VLSXL_UseNextLicense"  'string "always")
envSetVal( "license" "VSEL_UseNextLicense"   'string "always")
envSetVal( "license" "ADEL_UseNextLicense"   'string "always")
envSetVal( "license" "ADEXL_UseNextLicense"  'string "always")

; even more funny things
envSetVal( "license" "VLSLicenseCheckoutOrder" 'string "GXL,XL,L")
envSetVal( "license" "VSELicenseCheckoutOrder" 'string "XL,L")
envSetVal( "license" "ADELicenseCheckoutOrder" 'string "GXL,XL,L")

; License order for ADE  {IC6.1.7 ISR10 | Maestro_ADE : ADE Explorer - ADE Assembler - ADE L - ADE XL - ADE GXL}
;   https://support.cadence.com/apex/ArticleAttachmentPortal?id=a1O0V00000679dpUAA&pageName=ArticleContent&oMenu=People%20who%20viewed%20this%20also%20viewed 
envSetVal("asimenv" "adeMaestroCheckoutOrder" 'cyclic "Maestro")

;
envSetVal( "layout"  "xSnapSpacing" 'float  0.005)
envSetVal( "layout"  "ySnapSpacing" 'float  0.005)

; new library should be linked to this tech library
_tcGetNewLibAttachTechForm()
tcNewLibAttachTechForm->attachTechLibList->value= '( "cmos22fdsoi_tech" )

; loadContext(prependInstallPath("etc/context/transUI.cxt"))
; streamInKeys->layerTable="/usr/pack/umc-65-kgf/dz/dfii/610/tech/streamIn.map"
; streamInKeys->textFontTable="/usr/pack/umc-90-kgf/faraday.dz/dfii/5141/pipo/txtfont.tab"

; the following is to keep reference libraries
; streamInKeys->refLib=t
; streamInKeys->refLibOrder="<reference libraries>"

; streamOutKeys->layerTable="/usr/pack/umc-65-kgf/dz/dfii/610/tech/stream.map"
;streamOutKeys->textFontTable="/usr/pack/umc-90-kgf/faraday.dz/dfii/5141/pipo/txtfont.tab"
streamOutKeys->runDirectory="."
streamOutKeys->errorMessageFile="PIPO.LOG"

; get rid of UNSUPPORTED: spectre_X_sc, Virtuoso_Acceler_Parallel_sc
envSetVal("spectre.envOpts" "userCmdLineOption" 'string "+lorder MMSIM:PRODUCT")
;for already saved ADE state
envSetVal("spectre.envOpts" "licOrder" 'string "MMSIM:PRODUCT")



printf("DZ: END OF USER CUSTOMIZATION LOADING\n")

