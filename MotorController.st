b_start : bool;
b_stop  : bool;
MotorRun : bool;

b_start1 : bool;
b_stop1  : bool;
MotorRun1 : bool;


//============================================================

IF b_start AND NOT b_stop THEN
    MotorRun := TRUE;
ELSE
    MotorRun := FALSE;
END_IF

IF b_start1 AND NOT b_stop1 THEN
    MotorRun1 := TRUE;
ELSE
    MotorRun1 := FALSE;
END_IF
