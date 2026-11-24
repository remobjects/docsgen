namespace DocsGen;

uses System, System.Collections.Generic, System.Linq, System.Text.Json;

type
  EditorManifest = public static class
  private
    class field fRevision: Int64;
  public
    class method Create(aProject: Project): String;
    begin
      var lPages := new List<Dictionary<String, String>>;
      for each lFile in aProject.Files.Values.OrderBy(f -> f.TargetURL) do begin
        var lPage := new Dictionary<String, String>;
        lPage['source'] := aProject.EditorSource(lFile);
        lPage['url'] := lFile.TargetURL;
        lPage['path'] := lFile.RelativeFN;
        lPage['mounted'] := if length(lFile.MountedFrom) > 0 then 'true' else 'false';
        lPages.Add(lPage);
      end;
      var lResult := new Dictionary<String, Object>;
      lResult['revision'] := System.Threading.Interlocked.Increment(var fRevision);
      lResult['output'] := aProject.Output;
      lResult['pages'] := lPages;
      exit JsonSerializer.Serialize(lResult);
    end;
  end;

end.
