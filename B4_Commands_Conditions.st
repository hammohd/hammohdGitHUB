(*= 4.0 ==========  Ejection special conditions control  ==========*)
(*Ejection command of all cigarettes at assembler restart at assembler start program*)
rtVM_ProdStart(CLK:= bAssemblerON AND (bASM_RunningStopMech OR bVM_InchRunMech), Q=> );

(*Command at assembler automatic start program control*)
IF rtVM_ProdStart.Q THEN	(*VM in production or inch mode *)
	FOR  iLoop := arst_Register_Pointer.Y1M TO arst_Register_Pointer.Y2M BY 1 DO	(*Synchro DCP*)
		IF arst_Register[iLoop].bCigaretteProd THEN
			bReStartPhase := TRUE;	(*Ejection command with production cigarette*)
			iLastCig := iLoop;		(*Last cigarette position in the register*)
			EXIT;	(*One cigarette found between assembler inlet and ejection*)
		END_IF
	END_FOR
ELSIF bASM_ProgCentralDrumEject OR(iLastCig >= arst_Register_Pointer.Y2M) THEN
	bReStartPhase := FALSE;		(*Ejection command with production cigarette*)
END_IF

IF rtDCP.Q AND bReStartPhase THEN
	iLastCig := iLastCig + 2;
END_IF

(*= 4.1 ========== Test ejection conditions control  ==========*)
tnTestEjectionCont(IN:= bTestEjectionContY2M AND NOT bASM_RunningStopMech, PT:= T#30S, Q=> , ET=> );
IF tnTestEjectionCont.Q OR bASM_RunningStopMech THEN
	bTestEjectionContY2M := FALSE;
END_IF

tnTestEjectionSync(IN:= bTestEjectionSyncY2M AND NOT bASM_RunningStopMech, PT:= T#30S, Q=> , ET=> );
IF tnTestEjectionSync.Q OR bASM_RunningStopMech THEN
	bTestEjectionSyncY2M := FALSE;
END_IF

	
(*= 4.2 ========== Ejection conditions control  ==========*)
bCommand :=
	bCtrlEjectionY2M
	AND(
		(*->Ejection manual command continuous*)
(*1*)	bTestEjectionContY2M
		(*->Ejection manual command synchronous +/- cigarette*)
(*2*)	OR bTestEjectionSyncY2M
		(*->Ejection manual command synchronous + cigarette*)
(*3*)	OR(
			(bManualEjectionY2M
				OR SI36M)
			AND bCigaretteON		(*Cigarette presence ON*)
			)
		(*->Ejection command of all cigarettes at assembler restart in start program*)
(*4*)	OR(
			bReStartPhase			(*Ejection command with production cigarette*)
			AND bCigaretteProd		(*Cigarette production ON*)
			)
		(*->Rolling hand jam inspection fault*)
(*5*)	OR Fault[322]
		(*->Ejection when iAssemblerSpeed in low speed*)
(*6*)	OR(
			(iAssemblerSpeed < 1500)
			AND NOT Fault[191]		(*Servomotors in manual mode stopped*)
			)
		(*->Ejection at Start program*)
(*7*)	OR(
			bASM_ProgStartAbility
			AND NOT DSCT[39].Q
			)
		(*->Complementary ejection on Y2M*)
(*8*)	OR(
			bAssemblerON
			AND NOT bASM_ProgCentralDrumEject
			AND bASM_RunningStopMech
			AND DSCT[50].Q
			)
		(*->Normal command*)
(*9*)	OR(
			bCigaretteON				(* Cigarette presence ON*)
			AND(
				NOT BA41M						(*Outlet jam sensor BA41M*)
				OR Fault[322] 					(*Rolling hand jam inspection fault*)
				OR Fault[411]					(*RESY-T inlet conveyor jam BC2R*)
				OR NOT bASM_ProgCentralDrumEject	(*Start/Stop program*)
				OR NOT bASM_AutomaticMode		(*Manual mode*)
				OR NOT bASM_RunningStopMech		(*Machine stopped*)
				OR bASM_LaserEjectionCmd		(*LASER ejection*)
				OR b_StopConditionImm			(*Immediate Stop*)
				OR arst_Register[iPointerStart].AsmExternalSplice	(*Assembler external splice ejection*)
				OR arst_Register[iPointerStart].AsmInternalSplice	(*Assembler internal splice ejection*)
				OR arst_Register[iPointerStart].MakerSplice			(*Maker splice ejection*)
				OR arst_Register[iPointerStart].bFilterMissing		(*Filter missing ejection*)
	(*			OR arst_Register[iPointerStart].DieMissing			(*Die missing ejection*)*)	(*Tst*)
				)
			)
	);
	
	
	

	
	
	
	
	