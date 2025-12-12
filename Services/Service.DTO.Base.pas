unit Service.DTO.Base;

interface

uses
  SysUtils, Classes, TypInfo, SuperObject;

type
  TJsonDTO = class(TPersistent)
  public
    procedure FromJson(AJson: ISuperObject); virtual;
  end;

implementation

{ TJsonDTO }

procedure TJsonDTO.FromJson(AJson: ISuperObject);
var
  LIter: TSuperObjectIter;
  LPropInfo: PPropInfo;
  LJsonVal: ISuperObject;
begin
  if AJson = nil then Exit;

  if AJson = nil then Exit;

  if ObjectFindFirst(AJson, LIter) then
  try
    repeat
      LPropInfo := GetPropInfo(Self.ClassInfo, LIter.key);
      if LPropInfo <> nil then
      begin
        LJsonVal := LIter.val;
        if LJsonVal = nil then Continue;

        case LPropInfo^.PropType^.Kind of
          tkInteger, tkInt64:
            SetOrdProp(Self, LPropInfo, LJsonVal.AsInteger);
          tkFloat:
            begin
              if LJsonVal.DataType = stString then
                SetFloatProp(Self, LPropInfo, StrToFloatDef(StringReplace(LJsonVal.AsString, '.', DecimalSeparator, [rfReplaceAll]), 0.0))
              else
                SetFloatProp(Self, LPropInfo, LJsonVal.AsDouble);
            end;
          tkString, tkLString, tkWString:
            SetStrProp(Self, LPropInfo, LJsonVal.AsString);
          tkEnumeration:
             if GetTypeData(LPropInfo^.PropType^)^.BaseType^ = TypeInfo(Boolean) then
               SetOrdProp(Self, LPropInfo, Integer(LJsonVal.AsBoolean));
        end;
      end;
    until not ObjectFindNext(LIter);
  finally
    ObjectFindClose(LIter);
  end;
end;

end.
