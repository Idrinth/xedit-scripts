unit userscript;

const
  iESLMaxRecords = $800; // max possible new records in ESL
  iESLMaxFormID = $fff; // max allowed FormID number in ESL
var
  f: IwbFile;
  signatures, flags, lists, blacklist, blockcopy: TStringList;
  i: integer;
  cleanOften, allowInterrupt: boolean;
function Initialize: integer;
var
  buttonSelected: integer;
begin
  buttonSelected := MessageDlg('Do you want to be able to interrupt the script with pressing ESC?',mtConfirmation, [mbYes,mbNO], 0);
  allowInterrupt := (buttonSelected = mrYes);
  for i := 0 to FileCount -1 do
  begin
    if SameText(GetFileName(FileByIndex(i)), 'IdrinthAutoPatch.esp') then
    begin
      f := FileByIndex(i);
    end;
  end;
  if NOT Assigned(f) then
    f := AddNewFileName('IdrinthAutoPatch.esp');
  if wbGameName = 'Skyrim' then
    AddMasterIfMissing(f,'Skyrim.esm');
  cleanOften := (FileCount > 255);
  signatures := TStringList.Create;
  signatures.Add('NPC_');
  signatures.Add('RACE');
  signatures.Add('WEAP');
  signatures.Add('AMMO');
  signatures.Add('PROJ');
  signatures.Add('ARMO');
  signatures.Add('ARMA');
  signatures.Add('ENCH');
  signatures.Add('SPEL');
  signatures.Add('MGEF');
  signatures.Add('BOOK');
  signatures.Add('PERK');
  signatures.Add('LCTN');
  signatures.Add('CELL');
  signatures.Add('WRLD');
  signatures.Add('LVSP');
  signatures.Add('LVLN');
  signatures.Add('ALCH');
  signatures.Add('CLAS');
  signatures.Add('CONT');
  signatures.Add('CSTY');
  signatures.Add('FACT');
  signatures.Add('FLOR');
  signatures.Add('INGR');
  signatures.Add('KEYM');
  signatures.Add('LIGH');
  signatures.Add('MISC');
  signatures.Add('PROJ');
  signatures.Add('SCRL');
  signatures.Add('SHOU');
  signatures.Add('SLGM');
  signatures.Add('TREE');
  signatures.Add('WATR');
  signatures.Add('WOOP');
  signatures.Add('WTHR');
  flags := TStringList.Create;
  flags.Add('Flags');
  flags.Add('Flags2');
  flags.Add('Flags 2');
  flags.Add('Weight Slider - Male');
  flags.Add('Weight Slider - Female');
  flags.Add('Record Flags');
  flags.Add('First Person Flags');
  flags.Add('General Flags');
  flags.Add('Template Flags');
  flags.Add('Nose Morph Flags');
  flags.Add('Brow Morph Flags');
  flags.Add('Eye Morph Flags');
  flags.Add('Lip Morph Flags');
  flags.Add('Eye Morph Flags 1');
  flags.Add('Eye Morph Flags 2');
  flags.Add('Inherits');
  flags.Add('WRLD#DATA');
  flags.Add('CELL#DATA');
  flags.Add('CSTY#DATA');
  lists := TStringList.Create;
  lists.Add('Effects');
  lists.Add('Scripts');
  lists.Add('KWDA');
  lists.Add('Factions');
  lists.Add('Actor Effects');
  lists.Add('XCLR');
  lists.Add('ARMA#MODL');
  lists.Add('Leveled List Entries');
  lists.Add('Armature');
  lists.Add('MODS');
  lists.Add('MO2S');
  lists.Add('MO3S');
  lists.Add('MO4S');
  lists.Add('Perks');
  lists.Add('Skill Boosts');
  lists.Add('Skill Values');
  lists.Add('Skill Offsets');
  lists.Add('Attacks');
  lists.Add('Tint Layers');
  lists.Add('Tint Masks');
  lists.Add('Head Parts');
  lists.Add('MO5S');
  lists.Add('MGEF#SNDD');
  lists.Add('Script Fragments');
  lists.Add('Parts');
  lists.Add('References');
  lists.Add('Relations');
  lists.Add('Words of Power');
  lists.Add('LCSR');
  lists.Add('LCPR');
  lists.Add('LCEP');
  lists.Add('LCEC');
  lists.Add('ACSR');
  lists.Add('ACEP');
  lists.Add('LCUN');
  lists.Add('ACUN');
  lists.Add('ACEC');
  lists.Add('ACPR');
  blockcopy := TStringList.Create;
  blockcopy.Add('VMAD');
  blockcopy.Add('Items');
  blockcopy.Add('Conditions');
  blockcopy.Add('Coordinates');
  blacklist := TStringList.Create;
  blacklist.Add('KSIZ');
  blacklist.Add('PRKZ');
  blacklist.Add('COCT');
  blacklist.Add('LLCT');
  Result := 0;
end;

function IsInList(list: TStringList; element: IInterface; e: IInterface): boolean;
var
  nme: string;
  sig: string;
begin
  Result := false;
  nme := Signature(element);
  if nme = '' then
    nme := BaseName(element);
  if nme = '' then
    nme := Name(element);
  if nme = '' then
    Exit;
  Result := true;
  if list.IndexOf(nme) <> -1 then
    Exit;
  sig := Signature(e);
  if list.IndexOf(sig + '#' + nme) <> -1 then
    Exit;
  Result := false;
end;
procedure AddAllMasters(ef: IwbFile);
var
  i, c: integer;
begin
  c := MasterCount(ef);
  AddMasterIfMissing(f, GetFileName(ef));
  if MasterCount(ef) = 0 then
    Exit;
  if NOT cleanOften AND (MasterCount(ef) = c) then
    Exit;
  for i := 0 to MasterCount(ef) - 1 do
    AddAllMasters(MasterByIndex(ef, i));
end;

procedure GetPaths(e: IInterface;prefix: string;list: TStringList; base: IInterface);
var
  i: integer;
  element: IInterface;
  name: string;
begin
  for i := 0 to ElementCount(e)-1 do
  begin
    element := ElementByIndex(e, i);
    name := Name(element);
    if name = '' then
      Continue;
    if name = 'Record Header' then
    begin
      if list.IndexOf('Record Header\Record Flags') = -1 then
        list.Add('Record Header\Record Flags');
      Continue;
    end;
    if (ElementCount(element) > 0) and not IsInList(lists, element, base) and not IsInList(flags, element, base) and not IsInList(blockcopy, element, base) then
    begin
      GetPaths(element, prefix + name + '\', list, base);
      Continue;
    end;
    if list.IndexOf(prefix + name) = -1 then
    begin
      list.Add(prefix + name);
      Continue;
    end;
  end;
end;

function Same(e: IInterface; d: IInterface): boolean;
var
  paths: TStringList;
  path: string;
  element: IInterface;
  winner: IInterface;
  i: integer;
begin
  paths := TStringList.Create;
  GetPaths(e, '', paths, e);
  GetPaths(d, '', paths, e);
  for i := 0 to paths.Count -1 do
  begin
    path := paths[i];
    element := ElementByPath(e, path);
    winner := ElementByPath(d, path);
    Result:= False;
    if Assigned(element) and NOT Assigned (winner) then
      Exit;
    if NOT Assigned(element) and Assigned (winner) then
      Exit;
    if IsInList(flags, element, e) then
    begin
      if GetNativeValue(winner) <> GetNativeValue(element) then
        Exit;
      Continue;
    end;
    if IsInList(lists, element, e) then
    begin
      if ElementCount(element) <> ElementCount(winner) then
        Exit;
      if IsElement(element, 'Perks') or IsElement(element, 'KWDA') or IsElement(element, 'Effects') or IsElement(element, 'Actor Effects') or IsElement(element, 'MODL') then
        if NOT IsWordListSame(element, winner) then
          Exit;
      Continue;
    end;
    if GetElementEditValues(e, path) <> GetElementEditValues(d, path) then
      Exit;
  end;
  Result := True
end;

procedure handleWordList(patched: IInterface; patchedE: IInterface; original: IInterface; element: IInterface; wrapper: string; counter: string);
var
  keywordsP, keywordsO, keywordsE: TStringList;
  k: integer;
  keyword: string;
begin
  keywordsO := TStringList.Create;
  keywordsE := TStringList.Create;
  keywordsP := TStringList.Create;
  keywordsP.Duplicates := dupIgnore;
  for k := 0 to Pred(ElementCount(original)) do
  begin
    keywordsO.Add(GetEditValue(ElementByIndex(original, k)));
  end;
  for k := 0 to Pred(ElementCount(patchedE)) do
  begin
    keyword := GetEditValue(ElementByIndex(patchedE, k));
    if (keywordsP.IndexOf(keyword) = -1) AND (keyword <> '') then
      keywordsP.Add(keyword);
  end;
  for k := 0 to Pred(ElementCount(element)) do
  begin
    keyword := GetEditValue(ElementByIndex(element, k));
    if (keywordsO.IndexOf(keyword) = -1) AND (keywordsP.IndexOf(keyword) = -1) AND (keyword <> '') then
      keywordsP.Add(keyword);
    keywordsE.Add(keyword);
  end;
  for k := 0 to keywordsO.Count -1 do
  begin
    keyword := keywordsO[k];
    if (keywordsE.IndexOf(keyword) = -1) AND (keywordsP.IndexOf(keyword) <> -1) then
      keywordsP.Delete(keywordsP.IndexOf(keyword));
  end;
  RemoveElement(patched, patchedE);
  patchedE := Add(patched, wrapper, true);
  for k:=0 to keywordsP.Count -1 do
  begin
    if keywordsP[k] <> '' then
      SetEditValue(ElementAssign(patchedE, HighInteger, nil, False), keywordsP[k]);
  end;
  if counter <> '' then
    SetElementEditValues(patched, counter, ElementCount(patchedE));
end;

function IsWordListSame(list1: IInterface; list2: IInterface): boolean;
var
  k: integer;
  keywords: TStringList;
  keyword: string;
begin
  Result := false;
  if ElementCount(list2) <> ElementCount(list1) then
    Exit;
  keywords := TStringList.Create;
  for k := 0 to Pred(ElementCount(list1)) do
  begin
    keyword := GetEditValue(ElementByIndex(list1, k));
    keywords.Add(keyword);
  end;
  for k := 0 to Pred(ElementCount(list2)) do
  begin
    keyword := GetEditValue(ElementByIndex(list2, k));
    if keywords.IndexOf(keyword) = -1 then
      Exit;
    keywords.Delete(keywords.IndexOf(keyword));
  end;
  Result := keywords.Count = 0;
end;

function HasUnpatchedMaster(e: IInterface): boolean;
var
  i, j, pos: integer;
  masters: TStringList;
  override: IInterface;
  overrideFile: IwbFile;
begin
  masters := TStringList.Create;
  masters.Add(GetFileName(GetFile(e)));
  for i := 0 to Pred(OverrideCount(e)) do
  begin
    override := OverrideByIndex(e, i);
    overrideFile := GetFile(override);
    masters.Add(GetFileName(overrideFile));
    if MasterCount(overrideFile) = 0 then
      Continue;
    for j := 0 to MasterCount(overrideFile) - 1 do
    begin
      pos := masters.IndexOf(GetFileName(MasterByIndex(overrideFile, j)));
      if pos > -1 then
        masters.Delete(pos);
    end;
  end;
  Result := masters.Count > 1;
end;

procedure RemoveInvalidEntries(rec: IInterface; lstname: string; refname: string; countname: string);
var
  i, num: integer;
  lst, ent: IInterface;
begin
  lst := ElementByName(rec, lstname);
  if not Assigned(lst) then
    Exit;

  for i := Pred(ElementCount(lst)) downto 0 do
  begin
    ent := ElementByIndex(lst, i);
    if Check(ElementByPath(ent, refname)) <> '' then
      Remove(ent);
  end;
  SetElementEditValues(rec, countname, ElementCount(lst))
end;

function IsElement(element:IInterface; nme: string): boolean;
begin
  Result := SameText(Signature(element), nme) or SameText(BaseName(element), nme) or SameText(Name(element), nme);
end;

procedure MergeFlags(patched: IInterface; original: IInterface; element: IInterface);
var
  flags: TStringDynArray;
  i: integer;
  flag: string;
begin
  flags := SplitString(FlagValues(element), #13#10);
  for i:=0 to Length(flags) - 1 do
  begin
    flag := flags[i];
    if flag = '' then
      Continue;
    try
      if GetElementNativeValues(original, flag) <> GetElementNativeValues(element, flag) then
        SetElementNativeValues(patched, flag, GetElementNativeValues(element, flag));
    except
      on Ex : Exception do
        AddMessage('    ' + Ex.ClassName+' error raised while setting flags, with message : '+Ex.Message);
    end;
  end;
end;

function ignore(): boolean;
begin
  Result := true;
end;

procedure CreateElements(e: IInterface; path: string);
var
  i: integer;
  create, prev: string;
  parts: TStringDynArray;
  el: IInterface;
begin
  parts := SplitString(FlagValues(e), '\');
  create := '';
  for i:=0 to Length(parts) - 2 do
  begin
    prev := create;
    if create <> '' then
      create := create + '\';
    create := create + parts[i];
    el := ElementByPath(e, create);
    if NOT Assigned(el) then
      if prev <> '' then
        Add(ElementByPath(e, prev), parts[i], true);
      else
        Add(e, parts[i], true);
  end;
end;

function Process(e: IInterface): integer;
var
  i, k, j: integer;
  override: IInterface;
  winner: IInterface;
  patched: IwbElement;
  element: IwbElement;
  patchedE: IwbElement;
  original: IwbElement;
  previous: IwbElement;
  container: IInterface;
  overrideFile: IwbFile;
  paths: TStringList;
  path: string;
  s: string;
begin
  if allowInterrupt and (getKeyState(VK_ESCAPE) < 0) then
  begin
    AddMessage('Esc pressed, terminating script.');
    Result := 1;
    Exit;
  end;
  Result := 0;
  try
    if not IsMaster(e) then
      Exit;
    s := Signature(e);
    if signatures.IndexOf(s) = -1 then
      Exit;
    if OverrideCount(e) < 2 then
      Exit;
    if NOT HasUnpatchedMaster(e) then
      Exit;
    AddMessage('  Processing '+Name(e));
    winner := WinningOverride(e);
    if SameText(GetFileName(GetFile(winner)), GetFileName(f)) then
      Exit;
    AddAllMasters(GetFile(e));
    patched := wbCopyElementToFile(e, f, false, true);
    for i := 0 to Pred(OverrideCount(e)) do
    begin
      override := OverrideByIndex(e, i);
      previous := e;
      overrideFile := GetFile(override);
      if SameText(GetFileName(overrideFile), GetFileName(f)) then
        Continue;
      AddAllMasters(overrideFile);
      for j := 0 to Pred(MasterCount(overrideFile)) do
        if ElementExists(MasterByIndex(overrideFile, j), Name(e)) then
          previous = ElementByName(MasterByIndex(overrideFile, j), Name(e));
      paths := TStringList.Create;
      GetPaths(e, '', paths, e);
      GetPaths(previous, '', paths, e);
      GetPaths(override, '', paths, e);
      if paths.Count = 0 then
        Continue;
      if blacklist.IndexOf(path) <> -1 then
        Continue;
      for j := 0 to paths.Count-1 do
      begin
        path := paths[j];
        element := ElementByPath(override, path);
        original := ElementByPath(previous, path);
        patchedE := ElementByPath(patched, path);
        if NOT Assigned(patchedE) AND Assigned(element) then
        begin
          CreateElements(patched, path);
          patchedE := ElementByPath(patched, path);
        end;
        container := GetContainer(patchedE);
        if Not Assigned(container) then
          container := ElementByPath(patched, Path(GetContainer(element)));
        if IsInList(lists, element, e) then
        begin
          if NOT Assigned(original) AND NOT Assigned(element) then
            Continue;
          if IsElement(element, 'KWDA') then
          begin
            if not IsWordListSame(original, element) then
              handleWordList(patched, patchedE, original, element, 'KWDA', 'KSIZ');
            Continue;
          end;
          if IsElement(element, 'Perks') then
          begin
            if not IsWordListSame(original, element) then
              handleWordList(patched, patchedE, original, element, 'Perks', 'PRKZ');
            Continue;
          end;
          if IsElement(element, 'MODL') then
          begin
            if not IsWordListSame(original, element) then
              handleWordList(patched, patchedE, original, element, 'MODL', '');
            Continue;
          end;
          if IsElement(element, 'Actor Effects') then
          begin
            if not IsWordListSame(original, element) then
              handleWordList(patched, patchedE, original, element, 'Actor Effects', '');
            Continue;
          end;
          if IsElement(element, 'Effects') then
          begin
            if not IsWordListSame(original, element) then
              handleWordList(patched, patchedE, original, element, 'Effects', '');
            Continue;
          end;
          if IsElement(element, 'Leveled List Entries') then
          begin
            if Not Assigned(patchedE) then
              patchedE := Add(container, 'Leveled List Entries', true);
            for k := 0 to Pred(ElementCount(element)) do
            begin
              ElementAssign(patchedE, HighInteger, ElementByIndex(element, k), False)
            end;
            SetElementEditValues(patched, 'LLCT', ElementCount(patchedE));
            Continue;
          end;
          if Assigned(patchedE) and (Assigned(element) or Assigned(original)) then
            RemoveElement(container, patchedE);
          if Assigned(element) then
            wbCopyElementToRecord(container, element, false, true);
          Continue;
        end;
        if IsInList(blockcopy, element, e) then
        begin
          if Assigned(patchedE) and (Assigned(element) or Assigned(original)) then
            RemoveElement(container, patchedE);
          if Assigned(element) then
            wbCopyElementToRecord(container, element, false, true);
          Continue;
        end;
        if IsInList(flags, element, e) then
        begin
          if NOT Assigned(patchedE) then
            patchedE := Add(patched, Signature(element), true);
          MergeFlags(patchedE, original, element);
          Continue;
        end;
        if NOT Assigned(element) AND Assigned(patchedE) AND Assigned(original) then
        begin
          RemoveElement(patched, patchedE);
          Continue;
        end;
        if GetElementEditValues(override, path) <> GetElementEditValues(previous, path) then
        begin
          if NOT Assigned(patchedE) then
            patchedE := Add(container, Signature(element), true);
          try
            SetElementEditValues(patched, path, StrToFloat(GetElementEditValues(override, path)));
          except
            on Ex : Exception do
              ignore();
          end;
          if GetElementEditValues(override, path) <> GetElementEditValues(patched, path) then
            try
              SetElementEditValues(patched, path,  Round(StrToFloat(GetElementEditValues(override, path))));
            except
              on Ex : Exception do
                ignore();
            end;
          if GetElementEditValues(override, path) <> GetElementEditValues(patched, path) then
            try
              SetElementEditValues(patched, path, GetElementEditValues(override, path));
            except
              on Ex : Exception do
                ignore();
            end;
          Continue;
        end;
      end;      
    end;
    if s = 'CONT' then
      RemoveInvalidEntries(patched, 'Items', 'CNTO\Item', 'COCT');
    if (s = 'LVLI') or (s = 'LVLN') or (s = 'LVSP') then
      RemoveInvalidEntries(patched, 'Leveled List Entries', 'LVLO\Reference', 'LLCT');
    if (s = 'KWDA') then
      RemoveInvalidEntries(patched, 'KWDA', 'Keyword', 'KZIS');
    if (s = 'MODL') then
      RemoveInvalidEntries(patched, 'MODL', 'MODL', '');
    if Same(patched, winner) then
      Remove(patched);
  except
    on Ex : Exception do
      AddMessage('    ' + Ex.ClassName+' error raised, with message : '+Ex.Message);
  end;
  if cleanOften then
    CleanMasters(f);
end;


function isESLable(): integer;
var
  i: Integer;
  e: IInterface;
  RecCount, RecMaxFormID, fid: Cardinal;
  HasCELL: Boolean;
begin
  // iterate over all records in plugin
  for i := 0 to Pred(RecordCount(f)) do begin
    e := RecordByIndex(f, i);
    
    // override doesn't affect ESL
    if not IsMaster(e) then
      Continue;
    
    if Signature(e) = 'CELL' then
      HasCell := True;
    
    // increase the number of new records found
    Inc(RecCount);
    
    // no need to check for more if we are already above the limit
    if RecCount > iESLMaxRecords then
    begin
      Result := 0;
      Exit;
    end;
    
    // get raw FormID number
    fid := FormID(e) and $FFFFFF;
    
    // determine the max one
    if fid > RecMaxFormID then
      RecMaxFormID := fid;
  end;

  // too many new records, can't be ESL
  if RecCount > iESLMaxRecords then
    Exit;
  
  AddMessage(Name(f));
  
  if RecMaxFormID <= iESLMaxFormID then
    AddMessage(#9'Can be turned into ESL by adding ESL flag in TES4 header')
  else
    AddMessage(#9'Can be turned into ESL by compacting FormIDs first, then adding ESL flag in TES4 header');
    
  // check if plugin has new cell(s)
  if HasCELL then
    AddMessage(#9'Warning: Plugin has new CELL(s) which won''t work when turned into ESL and overridden by other mods due to the game bug');
end;

function Finalize: integer;
var
  i: IInterface;
begin
  if NOT cleanOften then
    CleanMasters(f);
  Result := 0;
  SortMasters(f);
  i := ElementByIndex(f, 0);
  SetElementEditValues(i, 'CNAM', 'Idrinth''s Automatic Patch');
  SetElementEditValues(i, 'SNAM', 'An automatically generated patch. You should delete this and regenerate the patch if your loadorder changes.');
  SetElementNativeValues(i, 'Record Header\Record Flags\ESL', 1);
end;

end.
