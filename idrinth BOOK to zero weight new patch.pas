unit UserScript;

var f: IInterface;
//============================================================================
function Initialize: integer;
begin
  f := AddNewFile;
  if not Assigned(f) then begin
    Result := 1;
    Exit;
  end;
end;

//============================================================================
function Process(e: IInterface): integer;
var b: IInterface;
begin
  if Signature(e) <> 'BOOK' then
    Exit;
  if not IsMaster(e) then
    exit;
  e := WinningOverride(e);
  if GetElementEditValues(e, 'DATA\Weight') == 0 then
  	Exit;
  AddRequiredElementMasters(e, f, False);
  b := wbCopyElementToFile(e, f, True, True);
  SetElementEditValues(b, 'DATA\Weight', 0);
end;

end.
