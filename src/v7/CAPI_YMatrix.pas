// Created by PMeira based on DDLL/DYMatrix.pas, revision 2091
// Note: YMatrix_GetCompressedYMatrix is different from the original since 
// I wanted to export the original, non-factorized YMatrix in CSC form too.
unit CAPI_YMatrix;

interface

Uses Arraydef, UComplex, Solution;

Procedure YMatrix_GetCompressedYMatrix(factor: wordbool; var nBus, nNz:Longword; var ColPtr, RowIdxPtr:pInteger; var cValsPtr: PDouble); cdecl;

procedure YMatrix_ZeroInjCurr; cdecl;
procedure YMatrix_GetSourceInjCurrents; cdecl;
procedure YMatrix_GetPCInjCurr; cdecl;
procedure YMatrix_BuildYMatrixD(BuildOps, AllocateVI: longint); cdecl;
procedure YMatrix_AddInAuxCurrents(SType: integer); cdecl;
procedure YMatrix_getIpointer(var IvectorPtr: pNodeVarray);cdecl;
procedure YMatrix_getVpointer(var VvectorPtr: pNodeVarray);cdecl;
function YMatrix_SolveSystem(var NodeV:pNodeVarray): integer; cdecl;

procedure YMatrix_Set_SystemYChanged(arg: WordBool); cdecl;
function YMatrix_Get_SystemYChanged(): WordBool; cdecl;
procedure YMatrix_Set_UseAuxCurrents(arg: WordBool); cdecl;
function YMatrix_Get_UseAuxCurrents(): WordBool; cdecl;


implementation

Uses DSSGlobals, Ymatrix, KLUSolve, CAPI_Utils;

Procedure YMatrix_GetCompressedYMatrix(factor: wordbool; var nBus, nNz:Longword; Var ColPtr, RowIdxPtr:pInteger; Var cValsPtr: PDouble); cdecl;
{Returns Pointers to column and row and matrix values}
Var 
    Yhandle: NativeUInt;
    NumNZ, NumBuses: LongWord;
    YColumns, YRows: pIntegerArray;
  
    tmpColPtrN, tmpRowIdxPtrN, tmpValsPtrN: Integer;
Begin
    If ActiveCircuit=Nil then Exit;
    Yhandle := ActiveCircuit.Solution.hY;
    If Yhandle <= 0 Then 
    Begin
        DoSimpleMsg('Y Matrix not Built.', 222);
        Exit;
    End;
     
    if factor then FactorSparseMatrix(Yhandle);

    GetNNZ(Yhandle, @NumNz);
    GetSize(Yhandle, @NumBuses);

    YColumns := Arraydef.PIntegerArray(DSS_CreateArray_PInteger(ColPtr, tmpColPtrN, NumBuses + 1));
    YRows := Arraydef.PIntegerArray(DSS_CreateArray_PInteger(RowIdxPtr, tmpRowIdxPtrN, NumNZ));
    DSS_CreateArray_PDouble(cValsPtr, tmpValsPtrN, 2 * NumNZ);
    
    nBus := NumBuses;
    nNZ  := NumNZ;
    
    // Fill in the memory
    GetCompressedMatrix(
        Yhandle, 
        NumBuses + 1, 
        NumNZ, 
        @ColPtr[0], 
        @RowIdxPtr[0], 
        pComplex(cValsPtr)
    );
    
End;

procedure YMatrix_ZeroInjCurr; cdecl;
Begin
    IF ActiveCircuit <> Nil THEN ActiveCircuit.Solution.ZeroInjCurr;
end;

procedure YMatrix_GetSourceInjCurrents; cdecl;
Begin
    IF ActiveCircuit <> Nil THEN ActiveCircuit.Solution.GetSourceInjCurrents;
end;

procedure YMatrix_GetPCInjCurr; cdecl;
Begin
    IF ActiveCircuit <> Nil THEN ActiveCircuit.Solution.GetPCInjCurr;
end;

procedure YMatrix_Set_SystemYChanged(arg: WordBool); cdecl;
begin
    ActiveCircuit.Solution.SystemYChanged := arg;
end;

function YMatrix_Get_SystemYChanged(): WordBool; cdecl;
begin
    Result := ActiveCircuit.Solution.SystemYChanged;
end;

procedure YMatrix_BuildYMatrixD(BuildOps, AllocateVI: longint); cdecl;
var
    AllocateV: boolean;
begin
    AllocateV := (AllocateVI <> 0);
    BuildYMatrix(BuildOps, AllocateV);
end;

procedure YMatrix_Set_UseAuxCurrents(arg: WordBool); cdecl;
begin
    ActiveCircuit.Solution.UseAuxCurrents := arg;
end;

function YMatrix_Get_UseAuxCurrents(): WordBool; cdecl;
begin
    Result := ActiveCircuit.Solution.UseAuxCurrents;
end;

procedure YMatrix_AddInAuxCurrents(SType: integer); cdecl;
begin
    ActiveCircuit.Solution.AddInAuxCurrents(SType);
end;

procedure YMatrix_getIpointer(var IvectorPtr: pNodeVarray);cdecl;
begin
    IVectorPtr := ActiveCircuit.Solution.Currents;
end;

procedure YMatrix_getVpointer(var VvectorPtr: pNodeVarray);cdecl;
begin
    VVectorPtr := ActiveCircuit.Solution.NodeV;
end;

function YMatrix_SolveSystem(var NodeV: pNodeVarray): integer; cdecl;
begin
    Result := ActiveCircuit.Solution.SolveSystem(NodeV);
end;

//---------------------------------------------------------------------------------
end.
