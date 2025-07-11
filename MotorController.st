b_start : bool;
b_stop  : bool;
MotorRun : bool;
//============================================================

IF b_start AND NOT b_stop THEN
    MotorRun := TRUE;
ELSE
    MotorRun := FALSE;
END_IF


