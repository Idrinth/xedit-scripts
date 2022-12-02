unit userscript;

var
  f: IwbFile;
  signatures, flags, blacklist, blockcopy, wordlists, objectlists: TStringList;
  cleanOften, allowInterrupt, groupedPatches: boolean;
  originalFileCount: integer;

function IsVersionWithCancelButton(): boolean;
var
  main,feature,bug: integer;
begin
  main := wbVersionNumber shr 24;
  feature := wbVersionNumber shr 16 and $FF;
  bug := wbVersionNumber shr 8 and $FF;
  if main < 3 then
  begin
    Result := false;
    Exit;
  end;
  if main < 3 then
  begin
    Result := false;
    Exit;
  end;
  if feature > 0 then
  begin
    Result := true;
    Exit;
  end;
  if bug > 3 then
  begin
    Result := true;
    Exit;
  end;
  Result := false;
end;

function Initialize(): integer;
var
  buttonSelected: integer;
begin
  originalFileCount := FileCount();
  allowInterrupt := false;
  if not IsVersionWithCancelButton() then
  begin
    buttonSelected := MessageDlg('Do you want to be able to interrupt the script by pressing ESC?',mtConfirmation, [mbYes,mbNO], 0);
    allowInterrupt := (buttonSelected = mrYes);
  end;
  cleanOften := (FileCount > 255);
  groupedPatches := false;
  if cleanOften then
  begin
    buttonSelected := MessageDlg('Do you want to clean masters often?',mtConfirmation, [mbYes,mbNO], 0);
    cleanOften := (buttonSelected = mrYes);
    buttonSelected := MessageDlg('Do you want to build patches by record type?',mtConfirmation, [mbYes,mbNO], 0);
    groupedPatches := (buttonSelected = mrYes);
  end;
  signatures := TStringList.Create;
  buttonSelected := MessageDlg('Do you want to patch leveled lists? (pretty safe)',mtConfirmation, [mbYes,mbNO], 0);
  if buttonSelected = mrYes then
  begin
    signatures.Add('LVLI');//leveled item
    signatures.Add('LVSP');//leveled spell
    signatures.Add('LVLN');//leveled npc
  end;
  buttonSelected := MessageDlg('Do you want to patch items? (medium success rate)',mtConfirmation, [mbYes,mbNO], 0);
  if buttonSelected = mrYes then
  begin
    signatures.Add('WEAP');
    signatures.Add('AMMO');
    signatures.Add('PROJ');
    signatures.Add('ARMO');
    signatures.Add('ARMA');
    signatures.Add('BOOK');
    signatures.Add('ALCH');
    signatures.Add('INGR');
    signatures.Add('KEYM');
    signatures.Add('MISC');
    signatures.Add('PROJ');
    signatures.Add('SCRL');
  end;
  buttonSelected := MessageDlg('Do you want to patch characters, races and perks? (medium success rate)',mtConfirmation, [mbYes,mbNO], 0);
  if buttonSelected = mrYes then
  begin
    signatures.Add('NPC_');
    signatures.Add('RACE');
    signatures.Add('PERK');
    signatures.Add('FACT');
  end;
  buttonSelected := MessageDlg('Do you want to patch worldspace related things? (medium success rate)',mtConfirmation, [mbYes,mbNO], 0);
  if buttonSelected = mrYes then
  begin
    signatures.Add('LCTN');
    signatures.Add('CELL');
    signatures.Add('WRLD');
    signatures.Add('FLOR');
    signatures.Add('LIGH');
    signatures.Add('TREE');
    signatures.Add('WATR');
    signatures.Add('WTHR');
    signatures.Add('MHDT');
  end;
  buttonSelected := MessageDlg('Do you want to patch magic related things? (medium success rate)',mtConfirmation, [mbYes,mbNO], 0);
  if buttonSelected = mrYes then
  begin
    signatures.Add('ENCH');
    signatures.Add('SPEL');
    signatures.Add('MGEF');
    signatures.Add('SHOU');
  end;
  buttonSelected := MessageDlg('Do you want to patch remaining records? (medium success rate)',mtConfirmation, [mbYes,mbNO], 0);
  if buttonSelected = mrYes then
  begin
    signatures.Add('CLAS');
    signatures.Add('CONT');
    signatures.Add('CSTY');
    signatures.Add('SLGM');
    signatures.Add('WOOP');
  end;
  if signatures.Count = 0 then
  begin
    AddMessage('Nothing to do with the given selection, exiting.');
    Result := 1;
    Exit;
  end;
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
  flags.Add('LVLN#LVLF');
  flags.Add('LVLI#LVLF');
  wordlists := TStringList.Create;
  wordlists.Add('Perks');
  wordlists.Add('KWDA');
  wordlists.Add('Actor Effects');
  wordlists.Add('ARMA#MODL');
  wordlists.Add('ACID');
  wordlists.Add('LCID');
  wordlists.Add('References');
  wordlists.Add('Movement Type Names');
  wordlists.Add('Packages');
  wordlists.Add('Movement Type Names (sorted)');
  objectlists := TStringList.Create;
  objectlists.Add('Factions');
  objectlists.Add('Effects');
  objectlists.Add('XCLR');
  objectlists.Add('Leveled List Entries');
  objectlists.Add('Armature');
  objectlists.Add('Perks');
  objectlists.Add('Skill Boosts');
  objectlists.Add('Skill Values');
  objectlists.Add('Skill Offsets');
  objectlists.Add('Attacks');
  objectlists.Add('Tint Layers');
  objectlists.Add('Tint Masks');
  objectlists.Add('Head Parts');
  objectlists.Add('Perks');
  objectlists.Add('MGEF#SNDD');
  objectlists.Add('Parts');
  objectlists.Add('Relations');
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
  objectlists.Add('Sounds');
  objectlists.Add('MODS');
  objectlists.Add('MO2S');
  objectlists.Add('MO3S');
  objectlists.Add('MO4S');
  objectlists.Add('MO5S');
  objectlists.Add('Parts');
  blockcopy := TStringList.Create;
  blockcopy.Add('VMAD');
  blockcopy.Add('Conditions');
  blockcopy.Add('Coordinates');
  blockcopy.Add('Scripts');
  blockcopy.Add('Script Fragments');
  blockcopy.Add('WRLD#MNAM - Map Data');
  blacklist := TStringList.Create;
  blacklist.Add('KSIZ');
  blacklist.Add('PRKZ');
  blacklist.Add('COCT');
  blacklist.Add('LLCT');
  blacklist.Add('SPCT');
  Result := 0;
end;

function GetFileByName(nme: string; incr: integer): IwbFile;
var
  i: integer;
  full: string;
  rec: IInterface;
  padNum: string;
begin
  padNum := IntToStr(incr);
  if Length(padNum) = 1 then
    padNum := '0' + padNum;
  if Length(padNum) = 2 then
    padNum := '0' + padNum;
  full := 'IdrinthAutoPatch' + nme + padNum + '.esp';
  for i := FileCount -1 downto originalFileCount do
  begin
    if SameText(GetFileName(FileByIndex(i)), full) then
    begin
      Result := FileByIndex(i);
      Exit;
    end;
  end;
  Result := AddNewFileName(full);
  rec := ElementByIndex(Result, 0);
  if nme = '' then
    SetElementEditValues(rec, 'CNAM', 'Idrinth''s Automatic Patch No.' + padNum)
  else
    SetElementEditValues(rec, 'CNAM', 'Idrinth''s Automatic Patch for ' + nme + ' No.' + padNum);
  SetElementEditValues(rec, 'SNAM', 'An automatically generated patch. You should delete this and regenerate the patch if your loadorder changes.');
  SetElementNativeValues(rec, 'Record Header\Record Flags\ESL', 1);
end;

procedure SetFile(sig: string; incr: integer);
begin
  if not groupedPatches then
  begin
    f := GetFileByName('', incr);
    Exit;
  end;
  if (sig = 'LVLI') or (sig = 'LVSP') or (sig = 'LVLN') then
  begin
    f := GetFileByName('Leveled', incr);
    Exit;
  end;
  if (sig = 'WEAP') or (sig = 'AMMO') or (sig = 'PROJ') or (sig = 'ARMO') or (sig = 'ARMA') or (sig = 'BOOK') or (sig = 'ALCH') or (sig = 'INGR') or (sig = 'KEYM') or (sig = 'MISC') or (sig = 'PROJ') or (sig = 'SCRL') then
  begin
    f := GetFileByName('Items', incr);
    Exit;
  end;
  if (sig = 'NPC_') or (sig = 'RACE') or (sig = 'PERK') or (sig = 'FACT') then
  begin
    f := GetFileByName('NPC', incr);
    Exit;
  end;
  if (sig = 'LCTN') or (sig = 'CELL') or (sig = 'WRLD') or (sig = 'FLOR') or (sig = 'LIGH') or (sig = 'TREE') or (sig = 'WATR') or (sig = 'WTHR') or (sig = 'MHDT') then
  begin
    f := GetFileByName('World', incr);
    Exit;
  end;
  if (sig = 'ENCH') or (sig = 'SPEL') or (sig = 'MGEF') or (sig = 'SHOU') then
  begin
    f := GetFileByName('Magic', incr);
    Exit;
  end;
  if (sig = 'CLAS') or (sig = 'CONT') or (sig = 'CSTY') or (sig = 'SLGM') or (sig = 'WOOP') then
  begin
    f := GetFileByName('Other', incr);
    Exit;
  end;
  f := GetFileByName('', incr);
end;

function IsInList(list: TStringList; element: IInterface; e: IInterface): boolean;
var
  sig: string;
begin
  Result := true;
  if list.IndexOf(Signature(element)) <> -1 then
    Exit;
  if list.IndexOf(BaseName(element)) <> -1 then
    Exit;
  if list.IndexOf(Name(element)) <> -1 then
    Exit;
  sig := Signature(e);
  if list.IndexOf(sig + '#' + Signature(element)) <> -1 then
    Exit;
  if list.IndexOf(sig + '#' + BaseName(element)) <> -1 then
    Exit;
  if list.IndexOf(sig + '#' + Name(element)) <> -1 then
    Exit;
  Result := false;
end;

procedure AddAllMasters(e: IInterface);
var
  i: integer;
  masters: TStringList;
begin
  AddMasterIfMissing(f, GetFileName(GetFile(e)), false);
  masters := TStringList.Create;
  ReportRequiredMasters(e, masters, true, false);
  for i := 0 to masters.Count - 1 do
    AddMasterIfMissing(f, masters[i], false);
end;

procedure GetPaths(e: IInterface; prefix: string; list: TStringList; base: IInterface);
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
      if (nme = 'SNAM - SNAM') and (Signature(base) = 'SHOU') then
      begin
        GetPaths(element, prefix + nme + ' #1\', list, base);
        GetPaths(element, prefix + nme + ' #2\', list, base);
      end;
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
    if (keywordsE.IndexOf(keyword) = -1) AND (keywordsP.IndexOf(keyword) <> -1) AND (keywordsO.IndexOf(keyword) <> -1) then
      keywordsP.Delete(keywordsP.IndexOf(keyword));
  end;
  RemoveElement(patched, patchedE);
  patchedE := Add(patched, wrapper, true);
  for k:=0 to keywordsP.Count -1 do
  begin
    if (keywordsP[k] <> '') then
      SetEditValue(ElementAssign(patchedE, HighInteger, nil, False), keywordsP[k]);
  end;
  if keywordsP.Count < ElementCount(patchedE) then
    RemoveElement(patchedE, ElementByIndex(patchedE, 0));
  if counter <> '' then
    SetElementEditValues(patched, counter, ElementCount(patchedE));
end;

function ToJSONObject(Obj: TJsonObject; element: IInterface; prefix: string): TJsonObject;
var
  i: integer;
  el: IInterface;
begin
  for i:=0 to ElementCount(element)-1 do
  begin
    el := ElementByIndex(element, i);
    if ElementCount(el) > 0 then
      ToJSONObject(Obj, el, prefix + Name(el)+'\')
    else
      Obj.S[prefix + Name(el)] := GetEditValue(el);
  end;
  Result := Obj
end;

function ToJSON(element: IInterface): string;
var
  i: integer;
  Obj: TJsonObject;
  el: IInterface;
begin
  Obj := ToJSONObject(TJsonObject.Create, element, '');
  Result := Obj.ToJSON(true);
  Obj.Free();
end;

procedure FromJSON(parent: IInterface; json: string);
var
  Obj: TJsonObject;
  key, value: string;
  i: integer;
begin
  Obj := TJsonObject.Parse(json);
  for i := 0 to Obj.Count - 1 do
  begin
    key := Obj.Names[i];
    value := Obj.S[key];
    SetElementEditValues(parent, key, value);
  end;
  Obj.Free();
end;

procedure HandleObjectList(container: IInterface; patchedE: IInterface; original: IInterface; element: IInterface; wrapper: string; counter: string);
var
  k: integer;
  keywordsP, keywordsO, keywordsE: TStringList;
  keyword: string;
  el: IInterface;
begin
  if Not Assigned(patchedE) then
    patchedE := Add(container, wrapper, true);
  keywordsO := TStringList.Create;
  keywordsE := TStringList.Create;
  keywordsP := TStringList.Create;
  for k := 0 to Pred(ElementCount(original)) do
  begin
    el := ElementByIndex(original, k);
    keywordsO.Add(ToJSON(el));
  end;
  for k := 0 to Pred(ElementCount(patchedE)) do
  begin
    keyword := ToJSON(ElementByIndex(patchedE, k));
    if (keywordsP.IndexOf(keyword) = -1) AND (keyword <> '') then
      keywordsP.Add(keyword);
  end;
  for k := 0 to Pred(ElementCount(element)) do
  begin
    el := ElementByIndex(element, k);
    keyword := ToJSON(el);
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
  RemoveElement(container, patchedE);
  patchedE := Add(container, wrapper, true);
  for k:=0 to keywordsP.Count -1 do
    FromJSON(ElementAssign(patchedE, HighInteger, el, False), keywordsP[k]);
  if counter <> '' then
    SetElementEditValues(container, counter, ElementCount(patchedE));
end;

procedure HandleBlockCopy(patchedE: IInterface; element: IInterface; original: IInterface; container: IInterface);
begin
  if Assigned(patchedE) and (Assigned(element) or Assigned(original)) then
    RemoveElement(container, patchedE);
  if Assigned(element) then
    wbCopyElementToRecord(element, container, false, true);
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

function IsObjectListSame(list1: IInterface; list2: IInterface): boolean;
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
    keyword := ToJSON(ElementByIndex(list1, k));
    keywords.Add(keyword);
  end;
  for k := 0 to Pred(ElementCount(list2)) do
  begin
    keyword := ToJSON(ElementByIndex(list2, k));
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
  overrideRec: IInterface;
  overrideRecFile: IwbFile;
begin
  masters := TStringList.Create;
  masters.Add(GetFileName(GetFile(e)));
  for i := 0 to Pred(OverrideCount(e)) do
  begin
    overrideRec := OverrideByIndex(e, i);
    overrideRecFile := GetFile(overrideRec);
    masters.Add(GetFileName(overrideRecFile));
    if MasterCount(overrideRecFile) = 0 then
      Continue;
    for j := 0 to MasterCount(overrideRecFile) - 1 do
    begin
      pos := masters.IndexOf(GetFileName(MasterByIndex(overrideRecFile, j)));
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
  if countname <> '' then
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
    if GetElementNativeValues(original, flag) <> GetElementNativeValues(element, flag) then
      SetElementNativeValues(patched, flag, GetElementNativeValues(element, flag));
  end;
end;

function ignore(): boolean;
begin
  Result := true;
end;

function CreateElements(e: IInterface; path: string; element: IInterface): IInterface;
var
  i: integer;
  create, prev: string;
  parts: TStringDynArray;
  el, el2: IInterface;
begin
  Result := e;
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
    el2 := ElementByPath(element, create);
    if NOT Assigned(el) then
      if prev <> '' then
        Result := ElementAssign(ElementByPath(e, prev), LowInteger, el2, False)
      else
        if Signature(el2) <> '' then
          Result := Add(e, Signature(el2), true)
        else
          Result := Add(e, BaseName(el2), true)
    else
      Result := el;
  end;
end;

function Same (one: IInterface; two: IInterface): boolean;
var
  paths: TStringList;
  i: integer;
  conflicts: boolean;
  e1,e2: IInterface;
begin
  if ConflictAllForElements(one, two, False, False) <> caNoConflict then
  begin
    Result := false;
    Exit;
  end;
  Result := false;
  paths := TStringList.Create;
  GetPaths(one, '', paths, one);
  GetPaths(two, '', paths, two);
  for i:=0 to paths.Count - 1 do
  begin
    e1 := ElementByPath(one, paths[i]);
    e2 := ElementByPath(two, paths[i]);
    if IsInList(flags, e1, one) then
    begin
      if GetNativeValue(e1) <> GetNativeValue(e2) then
        Exit;
      Continue;
    end;
    if IsInList(wordlists, e1, one) then
    begin
      if NOT IsWordListSame(e1, e2) then
        Exit;
      Continue;
    end;
    if IsInList(objectlists, e1, one) then
    begin
      if NOT IsObjectListSame(e1, e2) then
        Exit;
      Continue;
    end;
    if GetEditValue(e1) <> GetEditValue(e2) then
      Exit;
  end;
  Result := true;
end;

procedure WrapMastersSafely(sig: string; e: IInterface);
var
  i: integer;
  success: boolean;
begin
  success := false;
  i := 0;
  while not success do
  begin
    try
      SetFile(sig, i);
      AddAllMasters(e);
      success := true;
    except
      on Ex: Exception do
        success := false;
    end;

    success := success and (MasterCount(f) < 200);
    if not success then
      CleanMasters(f);
    i := i +1;
  end;
end;

function isPatched(filename: string; e: IInterface): boolean;
var
  i, j: integer;
  fn, cfn: string;
  overrideRecFile: IwbFile;
begin
  cfn := GetFileName(f);
  for i := 0 to Pred(OverrideCount(e)) do
  begin
    overrideRecFile := GetFile(OverrideByIndex(e, i));
    for j := 0 to MasterCount(overrideRecFile) - 1 do
    begin
      fn := GetFileName(MasterByIndex(overrideRecFile, j));
      if not SameText(cfn, filename) and SameText(fn, filename) then
        Result := true;
        Exit;
    end;
  end;
  Result := false;
end;

function Process(e: IInterface): integer;
var
  i, j, k: integer;
  overrideRec: IInterface;
  winner: IInterface;
  patched: IwbElement;
  element: IwbElement;
  patchedE: IwbElement;
  original: IwbElement;
  previous: IwbElement;
  container: IInterface;
  overrideRecFile: IwbFile;
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
    WrapMastersSafely(s, e);
    winner := WinningOverride(e);
    AddMessage('  Processing '+Name(e));
    patched := wbCopyElementToFile(e, f, false, true);
    for i := 0 to Pred(OverrideCount(e)) do
    begin
      overrideRec := OverrideByIndex(e, i);
      previous := e;
      overrideRecFile := GetFile(overrideRec);
      if SameText(GetFileName(overrideRecFile), GetFileName(f)) then
        Continue;
      if isPatched(GetFileName(overrideRecFile), e) then
      begin
        AddMessage('  Skipping none-leaf ' + GetFileName(overrideRecFile));
        Continue;
      end;
      AddAllMasters(overrideRec);
      for j := 0 to Pred(MasterCount(overrideRecFile)) do
        if ElementExists(MasterByIndex(overrideRecFile, j), Name(e)) then
          previous = ElementByName(MasterByIndex(overrideRecFile, j), Name(e));
      if Same(previous, overrideRec) then
        Continue;
      paths := TStringList.Create;
      GetPaths(e, '', paths, e);
      GetPaths(previous, '', paths, e);
      GetPaths(overrideRec, '', paths, e);
      if paths.Count = 0 then
        Continue;
      for j := 0 to paths.Count-1 do
      begin
        path := paths[j];
        if blacklist.IndexOf(path) <> -1 then
          Continue;
        element := ElementByPath(overrideRec, path);
        original := ElementByPath(previous, path);
        patchedE := ElementByPath(patched, path);
        container := CreateElements(patched, path, element);
        if not Assigned(container) then
          container := patched;
        if NOT Assigned(patchedE) AND Assigned(element) AND Assigned(container) then
        begin
          patchedE := wbCopyElementToRecord(element, container, false, true);
          if NOT Assigned(patchedE) then
            AddMessage('      Failed to copy element to '+path);
          Continue;
        end;
        if IsInList(wordlists, element, e) then
        begin
          if NOT Assigned(original) AND NOT Assigned(element) then
            Continue;
          if IsElement(element, 'KWDA') then
          begin
            if not IsWordListSame(original, element) then
              handleWordList(patched, patchedE, original, element, 'KWDA', 'KSIZ');
            RemoveInvalidEntries(patched, 'KWDA', 'Keyword', 'KZIS');
            Continue;
          end;
          if IsElement(element, 'Perks') then
          begin
            if not IsWordListSame(original, element) then
              handleWordList(patched, patchedE, original, element, 'Perks', 'PRKZ');
            Continue;
          end;
          if IsElement(element, 'ARMA#MODL') then
          begin
            handleWordList(patched, patchedE, original, 'Armature', 'MODL', '');
            Continue;
          end;
          if not IsWordListSame(original, element) then
            handleWordList(patched, patchedE, original, element, Name(element), '');
          Continue;
        end;
        if IsInList(objectlists, element, e) then
        begin
          if IsElement(element, 'Leveled List Entries') then
          begin
            handleObjectList(container, patchedE, original, element, 'Leveled List Entries', 'LLCT');
            Continue;
          end;
          handleObjectList(container, patchedE, original, element, Name(element), '');
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
        if GetElementEditValues(overrideRec, path) <> GetElementEditValues(previous, path) then
        begin
          try
            SetElementEditValues(patched, path, StrToFloat(GetElementEditValues(overrideRec, path)));
          except
            on Ex : Exception do
              ignore();
          end;
          if GetElementEditValues(overrideRec, path) <> GetElementEditValues(patched, path) then
            try
              SetElementEditValues(patched, path,  Round(StrToFloat(GetElementEditValues(overrideRec, path))));
            except
              on Ex : Exception do
                ignore();
            end;
          if GetElementEditValues(overrideRec, path) <> GetElementEditValues(patched, path) then
            try
              SetElementEditValues(patched, path, GetElementEditValues(overrideRec, path));
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
    if Same(winner, patched) then
      Remove(patched);
  except
    on Ex : Exception do
      AddMessage('    ' + Ex.ClassName+' error raised, with message : '+Ex.Message);
  end;
  if cleanOften and (MasterCount(f) > 100) then
    CleanMasters(f);
end;

function Finalize: integer;
var
  i: integer;
  fi: IwbFile;
begin
  Result := 0;
  for i := originalFileCount to FileCount -1 do
  begin
    fi := FileByIndex(i);
    if SameText(Copy(GetFileName(fi), 1, 16), 'IdrinthAutoPatch') then
    begin
      CleanMasters(fi);
      SortMasters(fi);
    end;
  end;
end;

end.
