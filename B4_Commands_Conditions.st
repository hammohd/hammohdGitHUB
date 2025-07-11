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
    bCtrlEjectionY2M AND (
        // 1. Ejection manual command continuous
        bTestEjectionContY2M

        // 2. Ejection manual command synchronous +/- cigarette
        OR bTestEjectionSyncY2M

        // 3. Ejection manual command synchronous + cigarette
        OR (
            (bManualEjectionY2M OR SI36M)
            AND bCigaretteON
        )

        // 4. Ejection command of all cigarettes at assembler restart in start program
        OR (
            bReStartPhase
            AND bCigaretteProd
        )

        // 5. Rolling hand jam inspection fault
        OR Fault[322]

        // 6. Ejection when iAssemblerSpeed in low speed
        OR (
            (iAssemblerSpeed < 1500)
            AND NOT Fault[191]
        )

        // 7. Ejection at Start program
        OR (
            bASM_ProgStartAbility
            AND NOT DSCT[39].Q
        )

        // 8. Complementary ejection on Y2M
        OR (
            bAssemblerON
            AND NOT bASM_ProgCentralDrumEject
            AND bASM_RunningStopMech
            AND DSCT[50].Q
        )

        // 9. Normal command
        OR (
            bCigaretteON AND (
                NOT BA41M
                OR Fault[322]
                OR Fault[411]
                OR NOT bASM_ProgCentralDrumEject
                OR NOT bASM_AutomaticMode
                OR NOT bASM_RunningStopMech
                OR bASM_LaserEjectionCmd
                OR b_StopConditionImm
                OR arst_Register[iPointerStart].AsmExternalSplice
                OR arst_Register[iPointerStart].AsmInternalSplice
                OR arst_Register[iPointerStart].MakerSplice
                OR arst_Register[iPointerStart].bFilterMissing
                // TODO: Uncomment if needed
                // OR arst_Register[iPointerStart].DieMissing
            )
        )
    );








