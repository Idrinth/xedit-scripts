unit userscript;

var
  f: IwbFile;
  signatures, flags, blacklist, blockcopy, wordlists, objectlists, sorted: TStringList;
  i: integer;
  cleanOften, allowInterrupt: boolean;
function Initialize: integer;
var
  buttonSelected: integer;
begin
  if wbVersionNumber > 1 then
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
  sorted := TStringList.Create;
  sorted.Add('RACE#Flags 2');
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
  wordlists := TStringList.Create;
  wordlists.Add('Perks');
  wordlists.Add('KWDA');
  wordlists.Add('Effects');
  wordlists.Add('Actor Effects');
  wordlists.Add('MODL');
  wordlists.Add('ACID');
  wordlists.Add('LCID');
  wordlists.Add('References');
  wordlists.Add('Movement Type Names');
  objectlists := TStringList.Create;
  objectlists.Add('Scripts');
  objectlists.Add('Factions');
  objectlists.Add('Actor Effects');
  objectlists.Add('XCLR');
  objectlists.Add('Leveled List Entries');
  objectlists.Add('Armature');
  objectlists.Add('MODS');
  objectlists.Add('MO2S');
  objectlists.Add('MO3S');
  objectlists.Add('MO4S');
  objectlists.Add('Perks');
  objectlists.Add('Skill Boosts');
  objectlists.Add('Skill Values');
  objectlists.Add('Skill Offsets');
  objectlists.Add('Attacks');
  objectlists.Add('Tint Layers');
  objectlists.Add('Tint Masks');
  objectlists.Add('Head Parts');
  objectlists.Add('MO5S');
  objectlists.Add('MGEF#SNDD');
  objectlists.Add('Script Fragments');
  objectlists.Add('Parts');
  objectlists.Add('Relations');
  objectlists.Add('Words of Power');
  objectlists.Add('LCSR');
  objectlists.Add('LCPR');
  objectlists.Add('LCEP');
  objectlists.Add('LCEC');
  objectlists.Add('ACSR');
  objectlists.Add('ACEP');
  objectlists.Add('LCUN');
  objectlists.Add('ACUN');
  objectlists.Add('ACEC');
  objectlists.Add('ACPR');
  objectlists.Add('Items');
  blockcopy := TStringList.Create;
  blockcopy.Add('VMAD');
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
  nme: string;
begin
  for i := 0 to Pred(ElementCount(e)) do
  begin
    element := ElementByIndex(e, i);
    nme := Name(element);
    if nme = '' then
      Continue;
    if nme = 'Record Header' then
    begin
      if list.IndexOf('Record Header\Record Flags') = -1 then
        list.Add('Record Header\Record Flags');
      Continue;
    end;
    if (ElementCount(element) > 0) and not IsInList(wordlists, element, base) and not IsInList(objectlists, element, base) and not IsInList(flags, element, base) and not IsInList(blockcopy, element, base) then
    begin
      GetPaths(element, prefix + nme + '\', list, base);
      Continue;
    end;
    if list.IndexOf(prefix + nme) = -1 then
    begin
      list.Add(prefix + nme);
      Continue;
    end;
  end;
end;

procedure HandleWordList(patched: IInterface; patchedE: IInterface; original: IInterface; element: IInterface; wrapper: string; counter: string);
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
procedure HandleObjectList(container: IInterface; patchedE: IInterface; original: IInterface; element: IInterface; wrapper: string; counter: string);
var
  k: integer;
begin
  if Not Assigned(patchedE) then
    patchedE := Add(container, wrapper, true);
  for k := 0 to Pred(ElementCount(element)) do
  begin
    ElementAssign(patchedE, HighInteger, ElementByIndex(element, k), False)
  end;
  if counter <> '' then
    SetElementEditValues(patched, counter, ElementCount(patchedE));
end;
procedure HandleBlockCopy(patchedE: IInterface; element: IInterface; original: IInterface; container: IInterface);
begin
  if Assigned(patchedE) and (Assigned(element) or Assigned(original)) then
    RemoveElement(container, patchedE);
  if Assigned(element) then
    wbCopyElementToRecord(container, element, false, true);
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
    if parts[i] = '' then
      Exit;
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
  i, j: integer;
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
    winner := WinningOverride(e);
    if SameText(GetFileName(GetFile(winner)), GetFileName(f)) then
      Exit;
    AddMessage('  Processing '+Name(e));
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
      if ConflictAllForElements(previous, override, False, False) <= caNoConflict then
        Continue;
      paths := TStringList.Create;
      GetPaths(e, '', paths, e);
      GetPaths(previous, '', paths, e);
      GetPaths(override, '', paths, e);
      if paths.Count = 0 then
        Continue;
      for j := 0 to paths.Count-1 do
      begin
        path := paths[j];
        if blacklist.IndexOf(path) <> -1 then
          Continue;
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
        if Not Assigned(container) then
          container := patched;
        if IsInList(wordlists, element, e) then
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
          if IsElement(element, 'LCID') then
          begin
            handleWordList(container, patchedE, original, element, 'LCID', '');
            Continue;
          end;
          if IsElement(element, 'ACID') then
          begin
            handleWordList(container, patchedE, original, element, 'ACID', '');
            Continue;
          end;
          if IsElement(element, 'Movement Type Names') then
          begin
            handleWordList(container, patchedE, original, element, 'Movement Type Names', '');
            Continue;
          end;
          HandleBlockCopy(patchedE, element, original, container);
          Continue;
        end;
        if IsInList(objectlists, element, e) then
        begin
          if IsElement(element, 'Leveled List Entries') then
          begin
            handleObjectList(container, patchedE, original, element, 'Leveled List Entries', 'LLCT');
            Continue;
          end;
          if IsElement(element, 'ACPR') then
          begin
            handleObjectList(container, patchedE, original, element, 'ACPR', '');
            Continue;
          end;
          if IsElement(element, 'LCPR') then
          begin
            handleObjectList(container, patchedE, original, element, 'LCPR', '');
            Continue;
          end;
          if IsElement(element, 'ACUN') then
          begin
            handleObjectList(container, patchedE, original, element, 'ACUN', '');
            Continue;
          end;
          if IsElement(element, 'LCUN') then
          begin
            handleObjectList(container, patchedE, original, element, 'LCUN', '');
            Continue;
          end;
          if IsElement(element, 'ACSR') then
          begin
            handleObjectList(container, patchedE, original, element, 'ACSR', '');
            Continue;
          end;
          if IsElement(element, 'LCSR') then
          begin
            handleObjectList(container, patchedE, original, element, 'LCSR', '');
            Continue;
          end;
          HandleBlockCopy(patchedE, element, original, container);
          Continue;
        end;
        if IsInList(blockcopy, element, e) then
        begin
          HandleBlockCopy(patchedE, element, original, container);
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
          begin
            patchedE := wbCopyElementToRecord(container, element, false, true);
            if NOT Assigned(patchedE) then
              AddMessage('Failed to copy element to '+path);
            Continue;
          end;
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
    if ConflictAllForElements(winner, patched, False, False) <= caNoConflict then
      Remove(patched);
  except
    on Ex : Exception do
      AddMessage('    ' + Ex.ClassName+' error raised, with message : '+Ex.Message);
  end;
  if cleanOften then
    CleanMasters(f);
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
