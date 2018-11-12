namespace DocsGen;

interface

uses
  System.Collections.Generic,
  System.Linq,
  System.Text;

type
  IndexerDoc = public class
  public
    property Title: String;
    property Url: String;
  end;
  Indexer = public class
  assembly
    method MakeHash(s: String): Integer;
    fKeywords: Dictionary<String, List<Tuple<Integer, Integer>>> := new Dictionary<String, List<Tuple<Integer, Integer>>>(StringComparer.OrdinalIgnoreCase);
    fFiles: List<IndexerDoc> := new List<IndexerDoc>;
    class var fStopWords: HashSet<String> := new HashSet<String>(['a', 'the', 'on', 'off', 'do', 'an', 'that', 'value'], StringComparer.OrdinalIgnoreCase);
    method RegisterKeyword(s: String; aDoc, aIndex: Integer);
    method IndexFile(s: String; aDoc: Integer);
  protected
  public
    constructor;
    method &Index(aURL, aTitle, aHeadings, aBody: String);

    method GenerateJS(aTarget: System.IO.StreamWriter);
  end;

implementation

method Indexer.Index(aURL: String; aTitle, aHeadings, aBody: String);
begin
  var lIndex := fFiles.Count;
  fFiles.Add(new IndexerDoc(Url := aURL, Title := aTitle));
  IndexFile(aBody, lIndex);
end;

constructor Indexer;
begin
end;

method Indexer.GenerateJS(aTarget: System.IO.StreamWriter);
begin
  var c:= fKeywords.Count / 50;
  var lList := new LinkedList<String>[c];
  for each el in fKeywords do begin
    var s:= el.Key.ToLowerInvariant;
    var q := MakeHash(s) mod c;
    if lList[q] = nil then
      lList[q] := new LinkedList<String>;
    lList[q].AddLast(s);
  end;
  aTarget.Write('dgSearchIndex.index = [');
  for i: Integer := 0 to lList.Count -1 do begin
    if i <> 0 then aTarget.Write(',');
    aTarget.Write('{');
    var lItem := lList[i]:First;
    while lItem <> nil do begin
      aTarget.Write('"'+lItem.Value+'"');
      aTarget.Write(':[');
      var lFirst := true;
      var lRows := fKeywords[lItem.Value];
      for j: Integer := 0 to lRows.Count -1 do begin
        if lFirst then lFirst := false else aTarget.Write(',');
        aTarget.Write(lRows[j].Item1.ToString+','+lRows[j].Item2);
      end;
      aTarget.Write(']');
      lItem := lItem.Next;
      if assigned(lItem) then
        aTarget.Write(',');
    end;
    aTarget.Write('}');
  end;
  aTarget.Write('];');
  aTarget.Write('dgSearchIndex.stopwords = { ');
  for each el in fStopWords index n do
    aTarget.Write('"'+el+'":1'+if n <> fStopWords.Count -1 then ',');
  aTarget.Write('}; dgSearchIndex.documents = [');
  for i: Integer := 0 to fFiles.Count -1 do begin
    if i <> 0 then aTarget.Write(',');
    aTarget.Write('{t:'#39 + coalesce(fFiles[i].Title, '').Replace(#39, '\'#39)+#39', u:'#39+fFiles[i].Url+#39'}');
  end;
  aTarget.Write('];');
end;

method Indexer.RegisterKeyword(s: String; aDoc: Integer; aIndex: Integer);
begin
  if fStopWords.Contains(s) or (s.Length < 2) then exit;
  var idx: List<Tuple<Integer, Integer>>;
  if not fKeywords.TryGetValue(s, out idx) then begin
    idx := new List<Tuple<Integer, Integer>>;
    fKeywords.Add(s, idx);
  end;
  idx.Add(Tuple.Create(aDoc, aIndex));
end;

method Indexer.IndexFile(s: String; aDoc: Integer);
begin
  var i := 0;
  var lIndex := 0;
  var lMark := -1;
  while i < length(s) do begin
    if s[i] = '<' then begin
      inc(i);
      while (i < s.Length) do begin
        if s[i] = '>' then begin
          inc(i);
          break;
        end;
        inc(i);
      end;
    end else
    if s[i] = '&' then begin
      inc(i);
      while (i < s.Length) do begin
        if s[i] = ';' then begin
          inc(i);
          break;
        end;
        inc(i);
      end;
    end else
    if s[i] in ['a'..'z', 'A'..'Z', '_'] then begin
      lMark := i;
      inc(i);
      while (i < s.Length) and (s[i] in ['a'..'z', 'A'..'Z', '_', '-', '0'..'9']) do
        inc(i);
      RegisterKeyword(s.Substring(lMark, i - lMark), aDoc, lIndex);
      inc(lIndex);
    end else
      inc(i);
  end;
end;

method Indexer.MakeHash(s: String): Integer;
begin
  result := 0;
  for i: Integer := 0 to s.Length -1 do
    result := (((result shl 5) - result) + Byte(s[i])) and $7fffffff;
end;

end.