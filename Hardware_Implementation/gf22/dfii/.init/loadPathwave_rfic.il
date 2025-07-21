;GoldenGate_cdsinit_grep_pattern
; @(#)$Id: .cdsinit_home,v 1.12 2012/10/22 18:58:58 cshyamsu Exp $
; Copyright (C) 2000 - 2012 Keysight Technologies, Inc


if(getShellEnvVar("XPEDION") then
        load(sprintf(nil "%s/aa/.cdsinit" getShellEnvVar("XPEDION")))
else
        printf(".cdsinit/.oceanrc: Environment variable XPEDION is not set!\n")
)


/*
To make GoldenGate your default simulator, you can add the following line to
your ~/.cdsenv file:

asimenv.startup simulator string "GoldenGate"

Alternatively, you can activate the envSetVal line by moving it outside this
comment-block.

envSetVal("asimenv.startup" "simulator" 'string "GoldenGate")
*/

