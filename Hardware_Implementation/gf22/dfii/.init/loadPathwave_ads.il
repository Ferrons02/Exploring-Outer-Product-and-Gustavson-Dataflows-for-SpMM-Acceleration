; v0.1 - <muheim@ee.ethz.ch> - Fri Dec  9 10:27:25 CET 2022
;  - cange from unless to if elso strukture
; v0.1 - <muheim@ee.ethz.ch> - Thu Aug 11 15:59:29 CEST 2022
;  - copy from "/usr/pack/pathwave_ads-2023-bt/idf/examples/.cdsinit"

; An ADS DLC user setup example
if( getShellEnvVar("HPEESOF_DIR")
  then

    let( (fileName bindkeyFiles cdsHome)
  
      cdsHome = getShellEnvVar("CDSHOME")
      unless( cdsHome
          cdsHome = simplifyFilename(prependInstallPath("/../.."))
          setShellEnvVar(strcat("CDSHOME=" cdsHome))
      )
      
      ; NOTE: The following DL initialization file must be loaded to run DL
      fileName = strcat(getShellEnvVar("HPEESOF_DIR") "/idf/config/.cdsinit")
      if( isFile( fileName ) then
          load( fileName ) 
  ;        unless( getShellEnvVar("RFDE_CDS_VERSION") setShellEnvVar("RFDE_CDS_VERSION=6.1.8"))
      else
          warn( strcat("$HPEESOF_DIR/idf/config/.cdsinit not found! " 
                "DLC may not work!\n") )
      )
; Arianna (Thu Jan  9 11:31:43 CET 2025) Commented because redundant in .cdsinit  
      ; load Cadence sample bindkey definitions for schematic and layout editors.
;      bindkeyFiles='(
;          "samples/local/schBindKeys.il"
;          "samples/local/leBindKeys.il"
;      )
;      foreach( bkFile bindkeyFiles
;          bkFile = prependInstallPath( bkFile )
;          when( isFile( bkFile )
;              loadi( bkFile )
;          ) 
;      )
;  
      ; sample RFDE/DL options:
      ; envSetVal( "asimenv.startup" "simulator" 'string "ADSsim" )
      ; envSetVal( "asimenv" "saveDir" 'string "./artist_states" )
      ; envSetVal( "asimenv.startup" "projectDir" 'string "./simulation" )
      ; envSetVal( "ADSsim.envOpts" "stopViewList" 'string  "spectre ads" )
      ; NOTE: For DL, use IDF_SWITCH_VIEW_LIST in idf.cfg file instead of the following line:
      ; envSetVal( "ADSsim.envOpts" "switchViewList" 'string  "spectre ads schematic extracted veriloga" )
      ; envSetVal( "ADSsim.envOpts" "spectreCompatibility" 'boolean nil)
      ; envSetVal( "ADSsim.envOpts" "translateResults" 'boolean t )
      ; envSetVal( "ADSsim.envOpts" "nativeSimulation" 'boolean nil )
      ; envSetVal( "ADSsim.envOpts" "noOsslcSimulation" 'boolean nil )
    )
  else
     warn( "HPEESOF_DIR is not defined. ADS DLC may not work!\n" )
)
