; v0.3 - <muheim@ee.ethz.ch> - Fri Jul  1 16:35:23 CEST 2022
;  - the _calview.cellmap will be taken from the PDK folder 
; v0.2 - <muheim@ee.ethz.ch> - Thu Oct 19 09:39:21 CEST 2017
;  - that the cdl export is adding automatically the file "22fdsoi.devices.cdl"
; v0.1 - <muheim@ee.ethz.ch> - Thu Feb 11 12:05:44 CET 2016
;  - copy from gf28 v0.2 and adapted it


printf("DZ: BEGIN OF CALIBRE INTERACTIVE LOADING\n")


; Load the env variables
load("/usr/pack/calibre-2024.4-dz/DZ_STUFF/skill/calibre_env.il")

;
; check MGC_HOME
;
mgc_home=getShellEnvVar("MGC_HOME")

if( mgc_home!=nil && isDir(mgc_home) && isReadable(mgc_home) then

    ; Load calibre.skl or calibre.4.3.skl, not both!

    ; Load calibre.skl for Cadence versions 4.4 and greater
    load(strcat(mgc_home "/lib/calibre.skl"))


else

    ; MGC_HOME is not set correctly. Report the problem.

    printf("//  Calibre Error: Environment variable ")

    if( mgc_home==nil || mgc_home=="" then
        printf("MGC_HOME is not set.");
    else
        if( !isDir(mgc_home) then
            printf("MGC_HOME does not point to a directory.");
        else
            if( !isReadable(mgc_home) then
                printf("MGC_HOME points to an unreadable directory.");
            )
        )
    )
    printf(" Calibre Skill Interface not loaded.\n")

    ; Display a dialog box message about load failure.

    hiDisplayAppDBox(
        ?name           'MGCHOMEErrorDlg
        ?dboxBanner     "Calibre Error"
        ?dboxText       "Calibre Skill Interface not loaded."
        ?dialogType     hicErrorDialog
        ?dialogStyle    'modal
        ?buttonLayout   'Close
    )
)

;;;  end some variables:
;mgc_eview_globals->cellMapFile = "../calibre/pex/calview.cellmap"
;; $TECHDIR_XACT/calview/22fdsoi_${BEOL_STACK}thick_calview.cellmap
mgc_eview_globals->cellMapFile = strcat(getShellEnvVar("GF_PDK_HOME") "/PEX/xACT/calview/22fdsoi_" getShellEnvVar("BEOL_STACK") "thick_calview.cellmap")
mgc_eview_globals->deviceViewScale = 1.0
mgc_eview_globals->parasiticViewScale = 1.0
mgc_eview_globals->extViewName = "extracted"
;;mgc_eview_globals->extViewType = "maskLayout"
mgc_eview_globals->extViewType = "schematic"

;; seting for the Layout Export - calibre
;streamOutKeys->runDir = "."
  ; is ready set in "loadKit.il"

;;; add extra devices
mgc_rve_init_cdlout_keys()
cdlOutKeys->incFILE = strcat(getShellEnvVar("GF_PDK_HOME") "LVS/Calibre/Include/22fdsoi.devices.cdl")

;; alternative trick
;;mgc_calibre_export_netlist_template_file ="/usr/pack/smic-130-kgf/dz/calibre/2008.3/dfii/mgc_export_template.il"
;;mgc_rve_load_export_netlist_template_file()

printf("DZ: END OF CALIBRE INTERACTIVE LOADING\n")

