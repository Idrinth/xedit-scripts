unit UserScript;
 
//============================================================================
function Initialize: integer;
begin
end;

//============================================================================
function Process(e: IInterface): integer;
begin
  if Signature(e) <> 'BOOK' then
    Exit;
  SetElementEditValues(e, 'DATA\Weight', 0);
end;

end.
