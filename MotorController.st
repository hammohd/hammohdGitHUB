b_start : bool;
b_stop  : bool;
MotorRun : bool;

b_start1 : bool;
b_stop1  : bool;
MotorRun1 : bool;

b_start2 : bool;
b_stop2  : bool;
MotorRun2 : bool;


//================Motor Controller 1 ============================================

IF b_start AND NOT b_stop THEN
    MotorRun := TRUE;
ELSE
    MotorRun := FALSE;
END_IF

//================Motor Controller 2 ============================================
IF b_start1 AND NOT b_stop1 THEN
    MotorRun1 := TRUE;
ELSE
    MotorRun1 := FALSE;
END_IF

//================Motor Controller 13============================================
IF b_start2 AND NOT b_stop1 THEN
    MotorRun2 := TRUE;
ELSE
    MotorRun2 := FALSE;
END_IF
