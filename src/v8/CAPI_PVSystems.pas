UNIT CAPI_PVSystems;
{$inline on}

INTERFACE

USES CAPI_Utils;

PROCEDURE PVSystems_Get_AllNames(var ResultPtr: PPAnsiChar; var ResultCount: Integer);cdecl;
PROCEDURE PVSystems_Get_RegisterNames(var ResultPtr: PPAnsiChar; var ResultCount: Integer);cdecl;
PROCEDURE PVSystems_Get_RegisterValues(var ResultPtr: PDouble; var ResultCount: Integer);cdecl;
function PVSystems_Get_First():Integer;cdecl;
function PVSystems_Get_Next():Integer;cdecl;
function PVSystems_Get_Count():Integer;cdecl;
function PVSystems_Get_idx():Integer;cdecl;
procedure PVSystems_Set_idx(Value: Integer);cdecl;
function PVSystems_Get_Name():PAnsiChar;cdecl;
procedure PVSystems_Set_Name(const Value: PAnsiChar);cdecl;
function PVSystems_Get_Irradiance():Double;cdecl;
procedure PVSystems_Set_Irradiance(Value: Double);cdecl;
function PVSystems_Get_kvar():Double;cdecl;
function PVSystems_Get_kVArated():Double;cdecl;
function PVSystems_Get_kW():Double;cdecl;
function PVSystems_Get_PF():Double;cdecl;
procedure PVSystems_Set_kVArated(Value: Double);cdecl;
procedure PVSystems_Set_PF(Value: Double);cdecl;
procedure PVSystems_Set_kvar(Value: Double);cdecl;

IMPLEMENTATION

USES CAPI_Constants, DSSGlobals, PVSystem, SysUtils;

PROCEDURE PVSystems_Get_AllNames(var ResultPtr: PPAnsiChar; var ResultCount: Integer);cdecl;
VAR
  Result: PPAnsiCharArray;
  PVSystemElem:TPVSystemObj;
  k:Integer;

Begin
    Result := DSS_CreateArray_PPAnsiChar(ResultPtr, ResultCount, (0) + 1);
    Result[0] := DSS_CopyStringAsPChar('NONE');
    IF ActiveCircuit[ActiveActor] <> Nil THEN
     WITH ActiveCircuit[ActiveActor] DO
     If PVSystems.ListSize>0 Then
     Begin
       DSS_RecreateArray_PPAnsiChar(Result, ResultPtr, ResultCount, (PVSystems.ListSize-1) + 1);
       k:=0;
       PVSystemElem := PVSystems.First;
       WHILE PVSystemElem<>Nil DO  Begin
          Result[k] := DSS_CopyStringAsPChar(PVSystemElem.Name);
          Inc(k);
          PVSystemElem := PVSystems.Next;
       End;
     End;
end;
//------------------------------------------------------------------------------
PROCEDURE PVSystems_Get_RegisterNames(var ResultPtr: PPAnsiChar; var ResultCount: Integer);cdecl;
VAR
  Result: PPAnsiCharArray;
    k :integer;

Begin
    Result := DSS_CreateArray_PPAnsiChar(ResultPtr, ResultCount, (NumPVSystemRegisters - 1) + 1);
    For k := 0 to  NumPVSystemRegisters - 1  Do Begin
       Result[k] := DSS_CopyStringAsPChar(PVSystemClass[ActiveActor].RegisterNames[k + 1]);
    End;
end;
//------------------------------------------------------------------------------
PROCEDURE PVSystems_Get_RegisterValues(var ResultPtr: PDouble; var ResultCount: Integer);cdecl;
VAR
  Result: PDoubleArray;
   PVSystem :TPVSystemObj;
   k     :Integer;
Begin

   IF ActiveCircuit[ActiveActor] <> Nil THEN
   Begin
        PVSystem :=  TPVSystemObj(ActiveCircuit[ActiveActor].PVSystems.Active);
        If PVSystem <> Nil Then
        Begin
            Result := DSS_CreateArray_PDouble(ResultPtr, ResultCount, (numPVSystemRegisters-1) + 1);
            FOR k := 0 to numPVSystemRegisters-1 DO
            Begin
                Result[k] := PVSystem.Registers[k+1];
            End;
        End
        Else
            Result := DSS_CreateArray_PDouble(ResultPtr, ResultCount, (0) + 1);
   End
   ELSE Begin
        Result := DSS_CreateArray_PDouble(ResultPtr, ResultCount, (0) + 1);
   End;



end;
//------------------------------------------------------------------------------
function PVSystems_Get_First():Integer;cdecl;
Var
   pPVSystem:TpVSystemObj;

Begin

   Result := 0;
   If ActiveCircuit[ActiveActor] <> Nil Then
   Begin
        pPVSystem := ActiveCircuit[ActiveActor].pVSystems.First;
        If pPVSystem <> Nil Then
        Begin
          Repeat
            If pPVSystem.Enabled
            Then Begin
              ActiveCircuit[ActiveActor].ActiveCktElement := pPVSystem;
              Result := 1;
            End
            Else pPVSystem := ActiveCircuit[ActiveActor].pVSystems.Next;
          Until (Result = 1) or (pPVSystem = nil);
        End
        Else
            Result := 0;  // signify no more
   End;

end;
//------------------------------------------------------------------------------
function PVSystems_Get_Next():Integer;cdecl;
Var
   pPVSystem:TPVSystemObj;

Begin

   Result := 0;
   If ActiveCircuit[ActiveActor] <> Nil Then
   Begin
        pPVSystem := ActiveCircuit[ActiveActor].PVSystems.Next;
        If pPVSystem <> Nil Then
        Begin
          Repeat
            If pPVSystem.Enabled
            Then Begin
              ActiveCircuit[ActiveActor].ActiveCktElement := pPVSystem;
              Result := ActiveCircuit[ActiveActor].PVSystems.ActiveIndex;
            End
            Else pPVSystem := ActiveCircuit[ActiveActor].PVSystems.Next;
          Until (Result > 0) or (pPVSystem = nil);
        End
        Else
            Result := 0;  // signify no more
   End;

end;
//------------------------------------------------------------------------------
function PVSystems_Get_Count():Integer;cdecl;
begin
    If Assigned(ActiveCircuit[ActiveActor]) Then
          Result := ActiveCircuit[ActiveActor].PVSystems.ListSize;
end;
//------------------------------------------------------------------------------
function PVSystems_Get_idx():Integer;cdecl;
begin
    if ActiveCircuit[ActiveActor] <> Nil then
       Result := ActiveCircuit[ActiveActor].PVSystems.ActiveIndex
    else Result := 0;
end;
//------------------------------------------------------------------------------
procedure PVSystems_Set_idx(Value: Integer);cdecl;
Var
    pPVSystem:TPVSystemObj;
begin
    if ActiveCircuit[ActiveActor] <> Nil then   Begin
        pPVSystem := ActiveCircuit[ActiveActor].PVSystems.Get(Value);
        If pPVSystem <> Nil Then ActiveCircuit[ActiveActor].ActiveCktElement := pPVSystem;
    End;
end;
//------------------------------------------------------------------------------
function PVSystems_Get_Name_AnsiString():AnsiString;inline;
Var
   pPVSystem:TPVSystemObj;

Begin
   Result := '';
   If ActiveCircuit[ActiveActor] <> Nil Then
   Begin
        pPVSystem := ActiveCircuit[ActiveActor].PVSystems.Active;
        If pPVSystem <> Nil Then
        Begin
          Result := pPVSystem.Name;
        End
        Else
            Result := '';  // signify no name
   End;

end;

function PVSystems_Get_Name():PAnsiChar;cdecl;
begin
    Result := DSS_GetAsPAnsiChar(PVSystems_Get_Name_AnsiString());
end;
//------------------------------------------------------------------------------
procedure PVSystems_Set_Name(const Value: PAnsiChar);cdecl;
VAR
    activesave :integer;
    PVSystem:TPVSystemObj;
    S: String;
    Found :Boolean;
Begin


  IF ActiveCircuit[ActiveActor] <> NIL
  THEN Begin      // Search list of PVSystems in active circuit for name
       WITH ActiveCircuit[ActiveActor].PVSystems DO
         Begin
             S := Value;  // Convert to Pascal String
             Found := FALSE;
             ActiveSave := ActiveIndex;
             PVSystem := First;
             While PVSystem <> NIL Do
             Begin
                IF (CompareText(PVSystem.Name, S) = 0)
                THEN Begin
                    ActiveCircuit[ActiveActor].ActiveCktElement := PVSystem;
                    Found := TRUE;
                    Break;
                End;
                PVSystem := Next;
             End;
             IF NOT Found
             THEN Begin
                 DoSimpleMsg('PVSystem "'+S+'" Not Found in Active Circuit.', 5003);
                 PVSystem := Get(ActiveSave);    // Restore active PVSystem
                 ActiveCircuit[ActiveActor].ActiveCktElement := PVSystem;
             End;
         End;
  End;

end;
//------------------------------------------------------------------------------
function PVSystems_Get_Irradiance():Double;cdecl;
begin
   Result := -1.0;  // not set
   IF ActiveCircuit[ActiveActor]<> NIL THEN Begin
         WITH ActiveCircuit[ActiveActor].PVSystems Do Begin
             IF ActiveIndex<>0 THEN Begin
                 Result := TPVSystemObj(Active).PVSystemVars.FIrradiance;
             End;
         End;
   End;
end;
//------------------------------------------------------------------------------
procedure PVSystems_Set_Irradiance(Value: Double);cdecl;
begin
   IF ActiveCircuit[ActiveActor]<> NIL THEN Begin
         WITH ActiveCircuit[ActiveActor].PVSystems Do Begin
             IF ActiveIndex<>0 THEN Begin
                  TPVSystemObj(Active).PVSystemVars.FIrradiance  := Value;
             End;
         End;
   End;
end;
//------------------------------------------------------------------------------
function PVSystems_Get_kvar():Double;cdecl;
begin
   Result := 0.0;  // not set
   IF ActiveCircuit[ActiveActor]<> NIL THEN Begin
         WITH ActiveCircuit[ActiveActor].PVSystems Do Begin
             IF ActiveIndex<>0 THEN Begin
                 Result := TPVSystemObj(Active).Presentkvar;
             End;
         End;
   End;
end;
//------------------------------------------------------------------------------
function PVSystems_Get_kVArated():Double;cdecl;
begin
   Result := -1.0;  // not set
   IF ActiveCircuit[ActiveActor]<> NIL THEN Begin
         WITH ActiveCircuit[ActiveActor].PVSystems Do Begin
             IF ActiveIndex<>0 THEN Begin
                 Result := TPVSystemObj(Active).kVARating ;
             End;
         End;
   End;
end;
//------------------------------------------------------------------------------
function PVSystems_Get_kW():Double;cdecl;
begin
   Result := 0.0;  // not set
   IF ActiveCircuit[ActiveActor]<> NIL THEN Begin
         WITH ActiveCircuit[ActiveActor].PVSystems Do Begin
             IF ActiveIndex<>0 THEN Begin
                 Result := TPVSystemObj(Active).PresentkW;
             End;
         End;
   End;
end;
//------------------------------------------------------------------------------
function PVSystems_Get_PF():Double;cdecl;
begin
   Result := 0.0;  // not set
   IF ActiveCircuit[ActiveActor]<> NIL THEN Begin
         WITH ActiveCircuit[ActiveActor].PVSystems Do Begin
             IF ActiveIndex<>0 THEN Begin
                 Result := TPVSystemObj(Active).PowerFactor ;
             End;
         End;
   End;
end;
//------------------------------------------------------------------------------
procedure PVSystems_Set_kVArated(Value: Double);cdecl;
begin
   IF ActiveCircuit[ActiveActor]<> NIL THEN Begin
         WITH ActiveCircuit[ActiveActor].PVSystems Do Begin
             IF ActiveIndex<>0 THEN Begin
                  TPVSystemObj(Active).kVARating  := Value;
             End;
         End;
   End;
end;
//------------------------------------------------------------------------------
procedure PVSystems_Set_PF(Value: Double);cdecl;
begin
   IF ActiveCircuit[ActiveActor]<> NIL THEN Begin
         WITH ActiveCircuit[ActiveActor].PVSystems Do Begin
             IF ActiveIndex<>0 THEN Begin
                  TPVSystemObj(Active).PowerFactor  := Value;
             End;
         End;
   End;
end;
//------------------------------------------------------------------------------
procedure PVSystems_Set_kvar(Value: Double);cdecl;
begin
   IF ActiveCircuit[ActiveActor]<> NIL THEN Begin
         WITH ActiveCircuit[ActiveActor].PVSystems Do Begin
             IF ActiveIndex<>0 THEN Begin
                  TPVSystemObj(Active).Presentkvar := Value;
             End;
         End;
   End;
end;
//------------------------------------------------------------------------------
END.
