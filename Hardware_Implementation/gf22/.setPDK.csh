#!/bin/csh
# v0.10 - zerun@ethz.ch -Tue  9 Aug 15:57:07 CEST 2022
# - the default DESIGN_TYPE is set back to CELL to check max density
# v0.9 - <muheim@ee.ethz.ch> - Mon Aug 23 10:17:55 CEST 2021
# - set 'DENSITY_DEBUG NO'
# - the default DESIGN_TYPE is set back to CELL_NODEN
# v0.8 - <muheim@ee.ethz.ch> - Tue Oct 27 08:40:54 CET 2020
# - copy from the EXT-V1.0_0.0 version, adapt it
# - remove 'DENSITY_RULES YES' and add 'DENSITY_DEBUG ALL'
# - the default DESIGN_TYPE is new set to CELL, so that DENSITY_DEBUG can be set
#   to ALL, otherwise the change is high that on the end the density god forgotten.
# v0.7 - <muheim@ee.ethz.ch> - Tue Aug 18 12:10:20 CEST 2020
# - add the DFM_DRCPLUS part
# - change LAYOUT_SYSTEM from GDS to GDSII
# v0.6 - <muheim@ee.ethz.ch> - Fri Nov  2 15:30:21 CET 2018
# - copy from the EXT-V1.0_0.0 version, adapt it
# - add set CHIP_DIE_COUNT
# v0.5 - <muheim@ee.ethz.ch> - Fri Nov  2 15:30:21 CET 2018
# - copy from the V1.3_1.0 version, adapt it
# v0.4 - <muheim@ee.ethz.ch> - Tue Mar 20 10:47:41 CET 2018
# - copy from the V1.3_0.0 version, adapt it
# v0.3 - <muheim@ee.ethz.ch> - Thu Jan  4 09:34:50 CET 2018
# - add suport for FILLGEN
# v0.3 - <muheim@ee.ethz.ch> - Thu Nov 23 11:20:49 CET 2017
# - copy from the V1.2_0.0 version
# v0.2 - <muheim@ee.ethz.ch> - Fri Sep 15 17:13:33 CEST 2017
# - add XACT
# v0.1 - <muheim@ee.ethz.ch> - Wed Aug 30 13:28:28 CEST 2017
# - copy from the V1.1_2.0 version
#   updatet it 


setenv PDK_HOME /usr/pack/gf-22-kgf/gf/pdk-22FDX-PLUS-V1.0_3.0a/
setenv GF_PDK_HOME $PDK_HOME
setenv BEOL_STACK 10M_2Mx_6Cx_2Ix_LB

## LDE (Layout Dependent Effects)
# LDE (tool lea - we do not have the licens) is not setup jet.- new we schuld have a licens
#    $PDK_HOME/DesignAids/LDE/

#setenv CDS_LDE_TECHFILE ${PDK_HOME}/DesignAids/LDE
#setenv CDS_LDE_MODEL ${PDK_HOME}/Models/Spectre/models/design_include.scs


## EAD (Early Accurate Design) 
# EAD is not setup jet.
#    $PDK_HOME/DesignAids/EAD/


## DRC/LVS/PEX (calibre)

# Calibre default runsets
setenv MGC_CALIBRE_DRC_RUNSET_FILE "../calibre/drc/runset.drc"
setenv MGC_CALIBRE_LVS_RUNSET_FILE "../calibre/lvs/runset.lvs"
# setenv MGC_CALIBRE_PEX_RUNSET_FILE "../calibre/pex/runset.pex"
setenv MGC_CALIBRE_XACT_RUNSET_FILE "../calibre/pex/xact.runset"

#setenv TECHDIR $PDK_HOME/Calibre

## DRC
# for info to the environment variables see:
#   docs/22FDX-EXT_DRC_Calibre_ReleaseNotes.pdf

setenv TECHDIR_DRC $PDK_HOME/DRC/Calibre

# Required Switches/Variable Settings
setenv LAYOUT_SYSTEM GDSII

setenv DESIGN_TYPE CELL
# setenv DESIGN_TYPE CELL_NODEN
# setenv DESIGN_TYPE CHIP
# setenv DESIGN_TYPE CHIP_NODEN

setenv IOTYPE      INLINE

# Optional Switches/Variable Settings
setenv C_ORIENTATION VERTICAL

setenv CHIP_DIE_COUNT OVER_5CHIP_SHOT

#  This would creating a directory with all density check value. This makes only sense
#  for a debug of on specified metal and then with no limits to the amount of report.
setenv DENSITY_DEBUG NO

setenv DP_LAYOUT_OUT GDSII

#- When running in CHIP mode, Environment variable MOB_OPTION should be set to either: NMOB or WMOB.
setenv MOB_OPTION NMOB

setenv BATCH NO

setenv DENSITY_RESULTS   ./density.results


## LVS
# for info to the envaerment variables see:
#   docs/22FDX-EXT_LVS_Calibre_ReleaseNotes.pdf

setenv TECHDIR_LVS $PDK_HOME/LVS/Calibre

setenv PKG_OPTION LBthick


## XACT
# for info to the envaerment variables see:
#   docs/22FDX-EXT_PEX_xACT_ReleaseNotes.pdf

setenv TECHDIR_XACT $PDK_HOME/PEX/xACT/


## FILL
# for info to the envaerment variables see:
#   docs/22FDX-EXT_FILLGEN_Calibre_ReleaseNotes.pdf
#   docs/22FDX-EXT-FILLGEN-UserGuide-*.pdf

setenv TECHDIR_FILLGEN $PDK_HOME/FILLGEN/Calibre


## DFM_DRCPLUS
# for info to the envaerment variables see:
#   docs/22FDX-EXT_DFM_DRCplus_Calibre_UserGuide.pdf

setenv TECHDIR_DFM_DRCPLUS $PDK_HOME/DFM/DRCplus/Calibre/PM

# WA setenv OUTPUT_DIR ../calibre/dfm
setenv OUTPUT_DIR ..
setenv DRCPLUS_MODE GUI
setenv RUN_PATTERNS LV1
