namespace DocsGen;

interface

uses
  System.Collections.Generic,
  System.Linq,
  System.IO,
  System.Data,
  MarkdownDeep,
  System.Text;

type
  FileTocNode = public class
  public
    property Parent: FileTocNode;
    property ID: String;
    property Value: String;
    property Items: List<FileTocNode> := new List<FileTocNode>; readonly;
  end;
  MyNameValueCollection = public class(System.Collections.Specialized.NameValueCollection, DotLiquid.IIndexable)
  public
    method ContainsKey(key: Object): Boolean;
    property Item[key: Object]: Object read inherited Item[key:ToString];
  end;
  Project = public class(DotLiquid.FileSystems.IFileSystem)
  private
    method OnAfterBrokenLink(sb: StringBuilder; link, atitle: String);
    begin 
      if not link.EndsWith('.md') then 
        sb.AppendFormat('<a href="/__edit/__new?path='+Mono.Net.HttpUtility.UrlEncode(link)+'/index.md&title='+Mono.Net.HttpUtility.UrlEncode(atitle)+'">'+atitle+"</a>");
      sb.AppendFormat('<a class="btn btn-warning" href="/__edit/__new?path='+Mono.Net.HttpUtility.UrlEncode(link)+'&title='+Mono.Net.HttpUtility.UrlEncode(atitle)+'">'+atitle+"</a>");
    end;

    method GetRegularDB(s: String): IDbConnection;
    method GetMonoDB(s: String): IDbConnection;
    method get_Missing: String;
    method get_Flags: String;
    method get_Keywords: String;
    method AppendSingleFileContent(aToc: TocEntry; sb: StringBuilder);
    method get_Review: String;
    method WriteToc(sb: StringBuilder; atoc: FileTocNode);
    method AddToToc(aHeadingLevel: Integer; var aIndex: Integer; aTarget: FileTocNode; aMax: Integer);
    method GenerateToc: String;
    class method GetHeadingLevel(s: String): Integer;
    method ProcessContent(fs: StreamWriter; aInput: String);
    method CopyFile(a, b: String);
    fPath: String;
    fOverrides: Dictionary<String, String>;
    fHeadings: List<&Tuple<String, String, String>> := new List<&Tuple<String, String, String>>;
    fFiles: Dictionary<String, ProjectFile> := new Dictionary<String,ProjectFile>;
    fLogger: ILogger;
    fContext: Context;
    fIndexer: Indexer;
    fNavGuard: HashSet<String> := new HashSet<String>;
    fBeforeRefresh: Integer;
    fBackgroundWait: System.Threading.AutoResetEvent;
    fBackgroundList: Queue<ProjectFile>;
    fReview: String;
    fTemplateFiles: Dictionary<String, Tuple<DateTime, String>> := new Dictionary<String, Tuple<DateTime, String>>;
    fUnknownTargets: Dictionary<String, HashSet<String>> := new Dictionary<String,HashSet<String>>;
    method GetCachedTemplateFile(s: String): String;
    method ReadTemplateFile(acontext: DotLiquid.Context; templateName: String): String;
  protected
    method ReadSettings(aFN: String; aOverrides: Dictionary<String, String> := nil);
  public
    class constructor;
    class method StripHtml(s: String): String;
    [Lazy]
    class property StandardThemePath: String := Path.Combine(Path.GetDirectoryName(typeOf(Project).Assembly.Location), '../themes/');
    method AppendUnknownTarget(aTarget, aFrom: String);
    method Refresh;
    method AdjustURL(s: String): String;
    property Logger: ILogger read fLogger;
    constructor(aLogger: ILogger; aPath: String; aOverrides: Dictionary<String, String> := nil);

    property Files: Dictionary<String, ProjectFile> read fFiles;

    event FileUpdated: Action<String, String>; // relative fn, output filename

    method GetDB(s: String): IDbConnection;
    method CreateDashIndex(aFN: String);
    method BuildHelpDB(aFN, aTargetURL, aIcon: String);
    method ExecuteSQLCommand(aConn: IDbConnection; aTrans: IDbTransaction; aCMD: String; aNames: array of String := nil; aValues: array of Object := nil; aLastInsertId: Boolean := false): Int64;
    property Context: Context read fContext;
    property Output: String read Settings.Get('output').IfNullOrEmpty('_site');
    property theme: String read Settings.Get('theme').IfNullOrEmpty('{builtin}/default');
    property ProjectPath: String read fPath;
    property title: String;
    property fullfilename: Boolean;
    property ThemePath: String; // resolved
    property edit: Boolean read Settings.Get('edit').IfNullOrEmpty('false') = 'true';
    property singlefile: Boolean read Settings.Get('singlefile').IfNullOrEmpty('false') = 'true';
    [LazyAspect]
    property singlefileskip: HashSet<String> := new HashSet<String>(Settings.Get('singlefile-skip').IfNullOrEmpty('').Replace('\','/').Split([',', ';'], StringSplitOptions.RemoveEmptyEntries), StringComparer.InvariantCultureIgnoreCase);
    property generatesearch: Boolean read Settings.Get('generatesearch').IfNullOrEmpty('false') = 'true';

    property Keywords: String read get_Keywords;
    property Settings: MyNameValueCollection := new MyNameValueCollection;
    //property ResourceDirs: List<String> := new List<String>; readonly;
    property ThemeResources: List<String> := new List<String>; readonly;
    property ThemeFiles: Dictionary<String, String> := new Dictionary<String,String>; readonly;
    property OtherFiles: List<String> := new List<String>; readonly;
    property OtherFilesDict: HashSet<String> := new HashSet<String>; readonly;

    method LoadTheme;
    method Build;
    method BuildSingleFile(aOut: String);
    method BuildNavRoot;
    property Review: String read get_Review;
    property &Flags: String read get_Flags;
    property Missing: String read get_Missing;

    method BeginRefresh;
    method BackgroundGenerate; 
    method BackgroundGenerate(pf: ProjectFile); 
    method BuildIfNeeded(aFile: ProjectFile);
    method GenerateFile(aFile: ProjectFile);
    method BuildNavigation(aParent: TocEntry; aFile: ProjectFile);
    method FindFiles(aRoot, aStart: String);
    method LoadFileHeader(aFile: ProjectFile);
    method CreateMarkdown: MarkdownDeep.Markdown;
    [Lazy]
    property Markdown : MarkdownDeep.Markdown := CreateMarkdown;
    [Lazy]
    property BaseTemplate: DotLiquid.Template := DotLiquid.Template.Parse(ThemeFiles['base.html']);
    [Lazy]
    property SingleFileTemplate: DotLiquid.Template := DotLiquid.Template.Parse(ThemeFiles['singlefile.html']);
  end;

  Context = public class
  private
    method get_next_page: TocEntry;
    method get_previous_page: TocEntry;
    method get_extra_javascript: List<String>;
    method get_extra_css: List<String>;
    method get_pathdown: sequence of TocEntry; 
  public
    class method ResolvePath(s: String): String;
    property _Project: Project;
    property CurrentFile: ProjectFile;
    property SingleFile: Boolean;

    method MakeRelative(s: String): String;
    method MakeAbsolute(s: String): String;
    property page_title: String read 
      if not String.IsNullOrEmpty(CurrentFile.Properties['page_title']) then CurrentFile.Properties['page_title'] else 
      CurrentFile.Title;

    property base_url: String read 
      if CurrentFile.Absolute then '' else MakeRelative('/');
    property homepage_url: String read MakeRelative(if _Project.fullfilename then '/index.html' else '/');
    property content: String;
    property local_url: String read 'file://'+CurrentFile.FullFN.Replace('\', '/');
    property relative_path: String read CurrentFile.RelativeFN.Replace('\', '/');
    property lastupdateticks: Int64 read CurrentFile.LoadDate.Ticks;
    property lastupdate: String read CurrentFile.LoadDate.ToString('yyyy-MM-dd hh:mm:ss');
    property page_url: String read CurrentFile.TargetURL;
    property file: MyNameValueCollection read CurrentFile.Properties;
    [Lazy]
    property edit: Boolean := _Project.edit;
    
    property showedit: Boolean read edit;
    property project: MyNameValueCollection read _Project.Settings;
    property pathdown: sequence of TocEntry read get_pathdown;
    property extra_css: List<String> read get_extra_css;
    property extra_javascript: List<String> read get_extra_javascript;

    property nav: List<TocEntry> := new List<TocEntry>;
    property next_page: TocEntry read get_next_page;
    property previous_page: TocEntry read get_previous_page;
  end;

  [DotLiquid.LiquidType(['title', 'url', 'visible', 'children', 'active', 'tocclasses', 'title_prefix', 'title_suffix', 'seperatorafter', 'reviewstatus', 'reviewparameter'])]
  TocEntry = public class
  private
    fFile: ProjectFile;
    fContext: Context;
    fParent: TocEntry;
  public
    constructor(aParent: TocEntry; aContext: Context; aFile: ProjectFile);
    property File: ProjectFile read fFile;
    property Parent: TocEntry read fParent;
    property visible: Boolean read active or children.Any(a->a.active or a.children.Any(b->b.active or b.children.Any(c -> c.active or c.children.Any(d -> d.active))));
    property title: String;
    property anchor: String;
    property url: String read fContext.MakeRelative(fFile.TargetURL) + if anchor = '#' then '' else anchor;
    property children: List<TocEntry> := new List<TocEntry>; readonly;
    property tocclasses: String read fFile.Properties['tocclasses'];
    property title_suffix: String read fFile.Properties['title_suffix'];
    property title_prefix: String read 
      if fContext._Project.edit then RenderStatus else fFile.Properties['title_prefix'];
    property seperatorafter: Boolean;
    property reviewstatus: String read fFile.reviewstatus;
    property reviewparameter: String read fFile.reviewparameter;

    method RenderStatus: String;

    property active: Boolean read ((fContext.CurrentFile = fFile) and not url.Contains('#')) or
      (fContext.MakeAbsolute(coalesce(fContext.CurrentFile.Properties['parentindex'], '')) = File.RelativeFN.Replace('\','/'));
  end;

  FileFormat = public (Markdown);
  ProjectFile = public class
  private
  public
    // used for rebuilding in serve mode
    property BuildDate: DateTime;
    property Touched: Boolean;
    property LoadDate: DateTime;
    // /

    property FullFN: String;
    property RelativeFN: String;
    property Format: FileFormat;
    
    property Content: String;
    property TargetFN: String;
    property TargetURL: String;
    property Toc: TocEntry;
    property IncludeFile: Boolean;
    property Hidden: Boolean read Properties['hidden'] in ['1', 'true'];
    property Title: String read Properties['title'];
    property Absolute: Boolean read Properties['absolute'] in ['1', 'true'];
    property Properties: MyNameValueCollection := new MyNameValueCollection; readonly;
    property reviewstatus: String read coalesce(Properties['status']:Split([':',',',' '], 2).FirstOrDefault().Trim.ToLowerInvariant, '');
    property reviewparameter: String read coalesce(Properties['status']:Split([':',',',' '], 2).Skip(1).FirstOrDefault():Trim:ToLowerInvariant, '');
  end;

  Todo = public class(DotLiquid.Tag)
  private
    fValue: String;
  public
    method Initialize(tagname, markup: String; tokens: List<String>); override;
    method Render(context: DotLiquid.Context; &result: TextWriter); override;
  end;
  Lightbox = public class(DotLiquid.Tag)
  private
    fTitle,
    fImg,
    fTarget: String;
  public
    method Initialize(tagName: String; markup: String; tokens: List<String>); override;
    method Render(context: DotLiquid.Context; &result: TextWriter); override;
  end;
  Resolve = public class(DotLiquid.Tag)
  private
    fValue: String;
  public
    method Initialize(tagName: String; markup: String; tokens: List<String>); override;
    method Render(context: DotLiquid.Context; &result: TextWriter); override;
  end;
  MyFilters = public static class
  private
  public
    class method Markdown(ctx: DotLiquid.Context; md: String): String;
  end;

  extension method Dictionary<TKey,TValue>.Get(s: TKey): TValue;
  extension method String.IfNullOrEmpty(NewVal: String): String;
implementation

uses 
  System.Threading.Tasks;

extension method String.IfNullOrEmpty(NewVal: String): String;
begin
  if String.IsNullOrEmpty(self) then exit NewVal;
  exit self;
end;
extension method Dictionary<TKey,TValue>.Get(s: TKey): TValue;
begin
  self.TryGetValue(s, out result);
end;

constructor Project(aLogger: ILogger; aPath: String; aOverrides: Dictionary<String, String> := nil);
begin
  fLogger := aLogger;
  fOverrides := aOverrides;
  if not Directory.Exists(aPath) then 
    raise new ArgumentException('Invalid path: '+aPath);
  fPath := aPath;
  var lSettings := 
    Path.Combine(aPath, '_config');
  if not File.Exists(lSettings) then 
    lSettings := Path.Combine(aPath, '_config.yml');
  if not File.Exists(lSettings) then 
    raise new ArgumentException('config file missing');
  ReadSettings(lSettings, aOverrides);
  var td := theme;
  if td.StartsWith('{builtin}') then
    td := StandardThemePath + td.Substring(9);
  if not Path.IsPathRooted(td) then td := Path.Combine(fPath, theme);
  if not td.EndsWith(Path.DirectorySeparatorChar) then
    td := td + Path.DirectorySeparatorChar;
  ThemePath := Path.GetFullPath(td);
  LoadTheme;

  var lPath := fPath;
  if not lPath.EndsWith(Path.DirectorySeparatorChar) then lPath := lPath + Path.DirectorySeparatorChar;
  FindFiles(lPath, lPath);
  for each el in fFiles.ToArray do
    LoadFileHeader(el.Value);
  fContext := new Context(_Project := self);
end;

method Project.ReadSettings(aFN: String; aOverrides: Dictionary<String, String> := nil);
begin
  fLogger.Debug('Loading settings: '+aFN);
  
  Settings.Clear;
  for each el in File.ReadAllLines(aFN) do begin
    var kv := el.Trim.Split([':'], 2);
    if length(kv) <> 2 then continue;
    var lVal := kv[1].TrimStart;
    if lVal.StartsWith('"') and lVal.EndsWith('",') and (lVal.Length > 2) then
      lVal := lVal.Substring(1, lVal.Length-3)
    else
    if lVal.StartsWith('"') and lVal.EndsWith('"') and (lVal.Length > 1) then
      lVal := lVal.Substring(1, lVal.Length-2);
    Settings.Add(kv[0].TrimEnd, lVal);
  end;
  for each el in aOverrides do
    Settings[el.Key] := el.Value;
  title := Settings.Get('title').IfNullOrEmpty('Title');
  fullfilename := Settings.Get('fullfilename').IfNullOrEmpty('').ToLowerInvariant = 'true';
end;

method Project.LoadTheme;
begin
  ThemeFiles.Clear;
  for each file in Directory.EnumerateFiles(ThemePath, '*.html') do 
    ThemeFiles[Path.GetFileName(file)] := System.IO.File.ReadAllText(file);
  if not ThemeFiles.ContainsKey('base.html') then
    fLogger.Error('Theme has no base.html');
  ThemeResources.Clear;
  for each themedir in Directory.EnumerateDirectories(ThemePath) do begin
    for each file in Directory.EnumerateFiles(themedir, '*.*', SearchOption.AllDirectories) do begin
      ThemeResources.Add(file.Substring(ThemePath.Length));
    end;
  end;
end;

method Project.Build;
begin
  BuildNavRoot;

  fNavGuard.Clear;
  var lOut := Path.Combine(fPath, Output);
  for each el in ThemeResources do begin
    CopyFile(Path.Combine(ThemePath, el), Path.Combine(lOut, el));
  end;

  if generatesearch then
    fIndexer := new Indexer;

  for each el in Files do begin
    try
      GenerateFile(el.Value);
    except
      fLogger.Error('Error processing: '+el.Key);
      raise;
    end;
  end;
  if fIndexer <> nil then begin
    if not Directory.Exists(Path.Combine(lOut, 'js')) then
      Directory.CreateDirectory(Path.Combine(lOut, 'js'));

    using sw := new StreamWriter(Path.Combine(lOut, 'js', 'searchindex.js')) do 
      fIndexer.GenerateJS(sw);
  end;
  for each el in OtherFiles do begin
    CopyFile(Path.Combine(fPath, el), Path.Combine(lOut, el));
  end;
  if singlefile then begin
    BuildSingleFile(lOut);
  end;
end;

method Project.FindFiles(aRoot, aStart: String);
begin
  for each entry in Directory.GetFiles(aStart) do begin
    var sn := Path.GetFileName(entry);
    if entry.Contains(Path.DirectorySeparatorChar+'.') then continue;
      if sn.EndsWith('.md', StringComparison.InvariantCultureIgnoreCase) then begin
        var lVal := entry.Substring(aRoot.Length).Replace('\', '/');
        var pp: ProjectFile;
        if fFiles.TryGetValue(lVal, out pp) then 
          pp.Touched := true
        else begin
          var lFile := new ProjectFile(FullFN := entry, IncludeFile := sn.StartsWith('_'), Touched := true, Format := FileFormat.Markdown, RelativeFN := entry.Substring(aRoot.Length));
          Files.Add(lVal, lFile);
        end;
    end else begin
      OtherFiles.Add(entry.Substring(aRoot.Length));
      OtherFilesDict.Add(entry.Substring(aRoot.Length).Replace('\','/'));
    end;
  end;
  for each entry in Directory.GetDirectories(aStart) do begin
    var sn := Path.GetFileName(entry);
    if sn.StartsWith('_') then continue;
    FindFiles(aRoot, entry);
  end;
end;

method Project.LoadFileHeader(aFile: ProjectFile);
begin
  var fn := Path.GetFileNameWithoutExtension(aFile.FullFN);
  if fn = 'index' then begin
    aFile.TargetFN := Path.Combine(Path.GetDirectoryName(aFile.RelativeFN), 'index.html');
    aFile.TargetURL := Path.GetDirectoryName(aFile.RelativeFN).Replace('\', '/')+'/';
  end else begin
    aFile.TargetFN := Path.Combine(Path.GetDirectoryName(aFile.RelativeFN), fn, 'index.html');
    aFile.TargetURL := Path.Combine(Path.GetDirectoryName(aFile.RelativeFN), fn).Replace('\', '/')+'/';
  end;
  if not aFile.TargetURL.StartsWith('/') then
    aFile.TargetURL :='/' + aFile.TargetURL;
  if fullfilename then
    aFile.TargetURL := aFile.TargetURL + 'index.html';

  using sr := new StreamReader(aFile.FullFN) do begin
    aFile.LoadDate := File.GetLastWriteTimeUtc(aFile.FullFN);
    fLogger.Debug('Loading '+aFile.FullFN+' from disk');
    aFile.Properties.Clear;
    if sr.ReadLine():Trim = '---' then begin
      loop begin
        var s := sr.ReadLine:Trim;
        if (s = nil) or (s.Trim = '---') then break;
        var items := s.Split([':'], 2);
        if length(items) <> 2 then continue;
        var key := items[0].Trim;
        var value := items[1].Trim;
        if (key = 'index-hidden') then begin key := 'index'; value := '!'+value; end;
        aFile.Properties.Add(key, value);
      end;
    end;
      aFile.Content := sr.ReadToEnd;
  end;
  if aFile.Hidden and not edit then begin
    Files.Remove(aFile.RelativeFN.Replace('\', '/'));
  end;
end;

method Project.BuildNavigation(aParent: TocEntry; aFile: ProjectFile);
begin
  if fNavGuard.Contains(aFile.FullFN) then begin
    fLogger.Error('Navigation recursively calls itself in: '+aFile.RelativeFN);
    var lPar := aParent;
    while lPar <> nil do begin
      fLogger.Warn('Call Stack: '+lPar.File:RelativeFN);
      lPar := lPar.Parent;
    end;

    exit;
  end;
  fNavGuard.Add(aFile.FullFN);
  for each index in aFile.Properties.GetValues('index') do begin
    var lIndex := index;
    var hidden := false;
    if lIndex.StartsWith('!') then begin
      if not edit then continue;
      lIndex := lIndex.Substring(1);
      hidden := true;
    end;
    if lIndex = '-' then begin
      if (aParent <> nil) and (aParent.children.Count > 0) then begin
        aParent.children.Last.seperatorafter := true;
      end;
      continue;
    end;
    var lTitle: String := nil;
    var lAnch: String := nil;
    if lIndex.Contains(' ') then begin
      lTitle := lIndex.Substring(lIndex.IndexOf(' ')+1).Trim;
      if lTitle = '' then lTitle := nil;
      lIndex := lIndex.Substring(0, lIndex.IndexOf(' '));
    end;
    if lIndex.Contains('#') then begin
      lAnch := lIndex.Substring(lIndex.IndexOf('#')).Trim;
      lIndex := lIndex.Substring(0, lIndex.IndexOf('#'));
    end;
    var tar := Path.Combine(Path.GetDirectoryName(aFile.RelativeFN), lIndex).Replace('\','/');
    var pf : ProjectFile;
    if not fFiles.TryGetValue(if tar.StartsWith('/') then tar.Substring(1) else tar, out pf) then begin
      fLogger.Warn('Cannot open nav info for '+tar+' referenced from '+aFile.RelativeFN);
      continue;
    end;
    if hidden and (pf.reviewstatus <> 'hidden') then
      pf.Properties['status'] := 'hidden:'+ if not String.IsNullOrEmpty(pf.reviewstatus) then pf.reviewstatus+':'+pf.reviewparameter else '';
    var r := new TocEntry(aParent, fContext, pf);
    if not String.IsNullOrEmpty(lTitle) then
      r.title := lTitle;
    if aParent = nil then
      fContext.nav.Add(r)
    else 
      aParent.children.Add(r);
    if lAnch = nil then begin
      pf.Toc := r;
      BuildNavigation(r, pf);
    end else
      r.anchor := lAnch;
  end;
end;

method Project.CopyFile(a: String; b: String);
begin
  var sp := Path.GetDirectoryName(b);
  if not Directory.Exists(sp) then
    Directory.CreateDirectory(sp);
  if File.Exists(b) then begin
    if File.GetLastWriteTimeUtc(a) <= File.GetLastWriteTimeUtc(b) then exit;
  end;
  fLogger.Debug('Copying '+a);
  File.Copy(a, b, true);
end;

method Project.GenerateFile(aFile: ProjectFile);
begin
  if aFile.IncludeFile then exit;
  if edit then
    fUnknownTargets.Remove(aFile.RelativeFN);
  fContext.CurrentFile := aFile;
  aFile.BuildDate := System.IO.File.GetLastWriteTimeUtc(aFile.FullFN);
  case aFile.Format of 
    FileFormat.Markdown: begin
      
      fLogger.Debug('Processing '+aFile.RelativeFN);
      var cp := new DotLiquid.RenderParameters;
      cp.Registers := new DotLiquid.Hash;
      cp.Registers.Add('__project', self);
      
      cp.LocalVariables := DotLiquid.Hash.FromAnonymousObject(fContext);
      cp.Registers["file_system"] := self;
      fHeadings.Clear;
      var lResolved := DotLiquid.Template.Parse(aFile.Content).Render(cp);
      var lWork := Markdown.Transform(lResolved);
      if String.IsNullOrEmpty(aFile.Title) then
        fLogger.Error(aFile.RelativeFN+' does not have a title!');
      var lTitle := aFile.Properties.Get('unique_title');
      if String.IsNullOrEmpty(lTitle) then begin
        lTitle := aFile.Properties.Get('page_title');
        if String.IsNullOrEmpty(lTitle) then
          lTitle := aFile.Title;
        if not String.IsNullOrEmpty(aFile.Properties.Get('unique_title_suffix')) then
          lTitle := lTitle + ' '+aFile.Properties.Get('unique_title_suffix').TrimStart;
      end;
      for each elv in coalesce(aFile.Properties.Get('keywords'), '').Split([';',','], StringSplitOptions.RemoveEmptyEntries) do 
        fHeadings.Add(Tuple.Create('', '', elv));
      fIndexer:&Index(aFile.TargetURL, lTitle, String.Join(#13#10, fHeadings.Select(a-> a[2])), lWork);
      
      if aFile.Properties['toc']:Trim:ToLowerInvariant = 'true' then begin
        lWork := GenerateToc + lWork;
      end;

      var lTarget := Path.Combine(fPath, Output, aFile.TargetFN);
      if not Directory.Exists(Path.GetDirectoryName(lTarget)) then
        Directory.CreateDirectory(Path.GetDirectoryName(lTarget));
      fLogger.Debug('Processing '+aFile.RelativeFN);
      using fs := new StreamWriter(lTarget) do
        ProcessContent(fs, lWork);
    end;
  else
    fLogger.Error('Unknown format');
  end;
end;

method Project.ProcessContent(fs: StreamWriter; aInput: String);
begin
  var rp := new DotLiquid.RenderParameters();
  fContext.content := aInput;
  rp.Registers := new DotLiquid.Hash;
  rp.Registers.Add('__project', self);
  
  rp.LocalVariables := DotLiquid.Hash.FromAnonymousObject(fContext);
  rp.Registers["file_system"] := self;
  
  BaseTemplate.Render(fs, rp);
end;

method Project.ReadTemplateFile(acontext: DotLiquid.Context; templateName: String): String;
begin
  templateName := templateName.Trim(['"']);
  if not ThemeFiles.TryGetValue(templateName, out result) then  begin
    var lPath := fContext.MakeAbsolute(templateName);
    //fLogger.Debug('Triggered include: '+lPath+' from '+fContext.CurrentFile.RelativeFN);
    exit GetCachedTemplateFile(lPath);
  end;
end;

class constructor Project;
begin
  DotLiquid.Template.RegisterTag<Todo>('todo');
  DotLiquid.Template.RegisterTag<Lightbox>('lightbox');
  DotLiquid.Template.RegisterTag<Resolve>('resolve');
  DotLiquid.Template.RegisterFilter(typeOf(MyFilters));
end;

method Project.AdjustURL(s: String): String;
begin
  if s.StartsWith('http:') or s.StartsWith('https:') or (s.StartsWith('#')) then exit s;

  var anch := '';
  var a := s.LastIndexOf('#');
  if a<> -1 then begin
    anch := s.Substring(a);
    s := s.Substring(0, a);
  end;
  if not s.StartsWith('/') then begin
    var e := fContext.CurrentFile.RelativeFN.Replace('\', '/');// else fContext.CurrentFile.TargetURL;
    if e.EndsWith('/') then
      s := e + s
    else
      s := e.Substring(0, e.LastIndexOf('/')+1) + s;
    s := Context.ResolvePath(s);
  end;
  var p: ProjectFile;

  if OtherFilesDict.Contains(if s.StartsWith('/') then s.Substring(1) else s) then begin
    exit fContext.MakeRelative((if not s.StartsWith('/') then '/' else '')+s);
  end else if fFiles.TryGetValue(if s.StartsWith('/') then s.Substring(1) else s, out p) then
    s := p.TargetURL
  else if fFiles.TryGetValue((if s.StartsWith('/') then s.Substring(1) else s).TrimEnd('/')+'/index.md', out p) then
    s := p.TargetURL
  else if fFiles.TryGetValue((if s.StartsWith('/') then s.Substring(1) else s).TrimEnd('/')+'.md', out p) then
    s := p.TargetURL
  else begin
    if not s.EndsWith('/') then
      s := s +'/';
    if not fFiles.Any(ar-> ar.Value.TargetURL = s) then begin
      //if not edit then 
      AppendUnknownTarget(s, fContext.CurrentFile.RelativeFN);
      fLogger.Warn(fContext.CurrentFile.RelativeFN+': refers to unknown target: '+s);
      exit '';
    end;
  end;
  s := fContext.MakeRelative(coalesce(s, ''));
  exit s + anch;
end;

method Project.CreateMarkdown: MarkdownDeep.Markdown;
begin
  result := new Markdown();

  result.SafeMode := false;
  result.ExtraMode := true;
  result.MarkdownInHtml := true;
  result.AutoHeadingIDs := true;
  result.QualifyUrl := @AdjustURL;
  result.HeadingGenerated += (h, id, value) -> fHeadings.Add(Tuple.Create(h, id, value));
  if edit then 
    result.OnAfterBrokenLink += OnAfterBrokenLink;
end;

class method Project.GetHeadingLevel(s: String): Integer;
begin
  exit case s of
      'h1': 1;
      'h2': 2;
      'h3': 3;
      'h4': 4;
      'h5': 5;
      'h6': 5;
      else 1;
    end;
end;

method Project.AddToToc(aHeadingLevel: Integer; var aIndex:Integer; aTarget: FileTocNode; aMax: Integer);
begin
  if aIndex < fHeadings.Count then begin
    loop begin
      var lItemLevel := GetHeadingLevel(fHeadings[aIndex].Item1);
      if lItemLevel > aMax then begin
        inc(aIndex);
        if (aIndex >= fHeadings.Count) then break;
        continue;
      end;
      if lItemLevel < aHeadingLevel then exit;

      var lNewItem := new FileTocNode();
      lNewItem.ID := fHeadings[aIndex].Item2;
      lNewItem.Value := fHeadings[aIndex].Item3;
      aTarget.Items.Add(lNewItem);
      inc(aIndex);
      if (aIndex >= fHeadings.Count) then break;
      var lSubLevel := GetHeadingLevel(fHeadings[aIndex].Item1);
      if lSubLevel > lItemLevel then begin
        AddToToc(lSubLevel, var aIndex, lNewItem, aMax);
        if (aIndex >= fHeadings.Count) then break;
      end;
    end;
  end;
end;

method Project.GenerateToc: String;
begin
  if fHeadings.Count = 0 then exit;

  var lRoot := new FileTocNode;
  var i: Integer := 0;
  var lMaxTocLevel: Integer;
  if not Int32.TryParse(coalesce(fContext.CurrentFile.Properties['tocmaxlevel'], ''), out lMaxTocLevel) then
    lMaxTocLevel := 6;
  while i < fHeadings.Count -1 do begin
    AddToToc(GetHeadingLevel(fHeadings[i].Item1), var i, lRoot, lMaxTocLevel);

  end;
  var sb := new StringBuilder;
  sb.Append('<div class="doctoc"><h2>Table of contents</h2>');
  WriteToc(sb, lRoot);
  sb.Append('</div>');
  exit sb.ToString;
end;

method Project.WriteToc(sb: StringBuilder; atoc: FileTocNode);
begin
  if atoc.Items.Count = 0 then exit;
  sb.Append('<ul>');
  for i: Integer := 0 to atoc.Items.Count -1 do begin
    sb.AppendFormat('<li><a href="#{0}">', atoc.Items[i].ID);
    Utils.SmartHtmlEncodeAmpsAndAngles(sb, StripHtml(atoc.Items[i].Value));
    sb.Append('</a>');
    WriteToc(sb,atoc.Items[i]);
    sb.Append('</li>')
  end;
  sb.Append('</ul>');
end;

class method Project.StripHtml(s: String): String;
begin
  var sb := new StringBuilder(s.Length);

  var i := 0;
  while i < s.Length do begin
    if s[i] = '<' then begin
      while (i < s.Length) and (s[i] <> '>') do 
        inc(i);
    end else
      sb.Append(s[i]);
    inc(i);
  end;
  exit sb.ToString;
end;

method Project.GetCachedTemplateFile(s: String): String;
begin
  var x: Tuple<DateTime, String>;
  if s.StartsWith('/') then s := s.Substring(1);
  var lRealPath := Path.Combine(fPath, s.Replace('/', Path.DirectorySeparatorChar));
  var fd := if File.Exists(lRealPath) then File.GetLastWriteTimeUtc(lRealPath) else DateTime.MinValue;
  if fTemplateFiles.TryGetValue(s, out x) then begin
    if x.Item1 >= fd  then begin
      if x.Item2 = '' then begin
        fLogger.Error('Include file not found: ' + s+' referenced from '+fContext.CurrentFile.RelativeFN);
        exit '';
      end;
      exit x.Item2;
    end;
  end;
  if File.Exists(lRealPath) then begin
    result := File.ReadAllText(lRealPath);
    if result.StartsWith('---') then begin
      var n := result.IndexOf('---', 5);
      if n <> -1 then begin
        result := result.Substring(n+3).TrimStart;
      end;
    end;
    fTemplateFiles[s] := (fd, result);
    exit;
  end;
  fTemplateFiles[s] := (fd, '');
  fLogger.Error('Include file not found: ' + s+' referenced from '+fContext.CurrentFile.RelativeFN);
  exit '';
end;

method Project.Refresh;
begin
  locking self do begin
    var lSettings := Path.Combine(fPath, '_config');
    if not File.Exists(lSettings) then 
      lSettings := Path.Combine(fPath, '_config.json');
    ReadSettings(lSettings, fOverrides);

    LoadTheme;

    var lPath := fPath;
    if not lPath.EndsWith(Path.DirectorySeparatorChar) then lPath := lPath + Path.DirectorySeparatorChar;
    for each el in fFiles do
      el.Value.Touched := false;

    OtherFiles.Clear;
    OtherFilesDict.Clear;

    FindFiles(lPath, lPath);
    for each el in fFiles.Where(a-> not a.Value.Touched).ToList do
      fFiles.Remove(el.Key);

    for each el in fFiles.ToList do begin
      var date := File.GetLastWriteTimeUtc(el.Value.FullFN);
      fLogger.Debug('Checking '+el.Value.FullFN + ' filedate: '+date+' loaddate:'+el.Value.LoadDate);
      if date > el.Value.LoadDate then begin
        LoadFileHeader(el.Value);
        FileUpdated:Invoke(el.Value.RelativeFN, el.Value.TargetURL);
      end;
    end;
    BuildNavRoot;
  end;
end;

method Project.BeginRefresh;
begin
  if interlockedExchange(var fBeforeRefresh, 1) = 1 then exit;
  async begin
    interlockedExchange(var fBeforeRefresh, 0);
    Refresh;
  end;
end;

method Project.BuildNavRoot;
begin
  fContext.nav.Clear;
  fNavGuard.Clear;

  if not fFiles.ContainsKey('index.md') then
    raise new ArgumentException('index.md file missing');
    
  var lVal := fFiles['index.md'];
  var lEntry := new TocEntry(nil, fContext, lVal);
  lVal.Toc := lEntry;
  fContext.nav.Add(lEntry);
  BuildNavigation(lEntry, lVal);
end;

method Project.get_Review: String;
begin
  var sb := new StringBuilder;
  //var sbrel := new StringBuilder;
  var lGroupings := Files.GroupBy(a -> a.Value.reviewstatus.Trim.ToLowerInvariant).Where(a -> a.Key <> 'ignore').OrderBy(a -> a.Key).ToArray;
  sb.AppendLine('<h4>TOC</h4><ul>');
  for each el in lGroupings do begin
    var lKey := el.Key;
    if String.IsNullOrEmpty(lKey) then lKey := 'missing';
    sb.AppendLine('<li><a href="#'+lKey+'">'+lKey+'</a></li>');
  end;
  sb.AppendLine('</ul>');
  fContext.CurrentFile := Files['index.md'];
  for each el in lGroupings do begin
    var lKey := el.Key;
    if String.IsNullOrEmpty(lKey) then lKey := 'missing';
    sb.Append('<h2 id="'+lKey+'">');
    sb.Append(lKey);
    sb.AppendLine('</h2>');
    for each entry in el do begin
      if (lKey = 'missing') and (entry.Value.IncludeFile) then continue;
      if edit then
      sb.Append('<a href="/__edit/editor.html?path='+ entry.Value.RelativeFN.Replace('\', '/') +'">(edit)</a> ');
      sb.Append('<a href="docsgen://action=edit&url=file://'+ entry.Value.FullFN.Replace('\', '/') +'">(edit externally)</a> ');
      if entry.Value.IncludeFile then begin
        sb.Append((if String.IsNullOrEmpty(entry.Value.Title:Trim) then '(no title '+entry.Value.RelativeFN+')' else  StripHtml(entry.Value.Title)) +' '+StripHtml(entry.Value.reviewparameter));
        sb.Append('<br/>');
      end else begin
        sb.Append('<a href="');
        sb.Append(entry.Value.TargetURL);
        sb.Append('">'+(if String.IsNullOrEmpty(entry.Value.Title:Trim) then '(no title '+entry.Value.RelativeFN+')' else  StripHtml(entry.Value.Title)) +'</a> '+StripHtml(entry.Value.reviewparameter));
        sb.Append('<br/>');
      end;
    end;
    sb.AppendLine;
  end;
  var cp := new DotLiquid.RenderParameters;
  cp.Registers := new DotLiquid.Hash;
  cp.Registers.Add('__project', self);
      
  cp.LocalVariables := DotLiquid.Hash.FromAnonymousObject(fContext);
  cp.Registers["file_system"] := self;
  cp.LocalVariables['content'] := sb.ToString;
  cp.LocalVariables['showedit'] := false;
      
  fReview := BaseTemplate.Render(cp);
  exit fReview;
end;


method Project.AppendUnknownTarget(aTarget: String; aFrom: String);
begin
  var lVal: HashSet<String>;
  if not fUnknownTargets.TryGetValue(aFrom, out lVal) then begin
    lVal := new HashSet<String>;
    fUnknownTargets.Add(aFrom, lVal);
  end;
  lVal.Add(aTarget);
end;

method Project.BuildSingleFile(aOut: String);
begin
  var cp := new DotLiquid.RenderParameters;
  cp.Registers := new DotLiquid.Hash;
  cp.Registers.Add('__project', self);
      
  cp.Registers["file_system"] := self;

  var sbrel := new StringBuilder;
  for each el in fContext.nav do
    AppendSingleFileContent(el, sbrel);
      
  fHeadings.Clear;
  Context.CurrentFile := fContext.nav[0].File; 
  cp.LocalVariables := DotLiquid.Hash.FromAnonymousObject(fContext);
  cp.LocalVariables['content'] := sbrel.ToString;  
  cp.LocalVariables['showedit'] := false;
  File.WriteAllText(Path.Combine(aOut, 'index_all.html'), SingleFileTemplate.Render(cp));

end;

method Project.AppendSingleFileContent(aToc: TocEntry; sb: StringBuilder);
begin
  if singlefileskip.Contains(aToc.File.RelativeFN.Replace('\', '/')) then exit;

  fContext.SingleFile := true;
  fContext.CurrentFile := aToc.File;
  sb.AppendLine('<h1 id="'+aToc.File.TargetURL.Replace('/', '-').Replace('.html', '')+'">'+DotLiquid.StandardFilters.Escape(aToc.title)+'</h1>');
  var cp := new DotLiquid.RenderParameters;
  cp.Registers := new DotLiquid.Hash;
  cp.Registers.Add('__project', self);
      
  cp.LocalVariables := DotLiquid.Hash.FromAnonymousObject(fContext);
  cp.Registers["file_system"] := self;
  var lResolved := DotLiquid.Template.Parse(aToc.File.Content).Render(cp);
  sb.AppendLine('<div class="newpage">');
  sb.Append(Markdown.Transform(lResolved));
  sb.AppendLine('</div>');
  for each el in aToc.children do
    AppendSingleFileContent(el, sb);
  fContext.SingleFile := false;
end;

method Project.GetRegularDB(s: String): IDbConnection;
begin
  var db := new System.Data.SQLite.SQLiteConnection('Data Source='+s+';Version=3;');
  db.Open;
  exit db;
end;

method Project.GetMonoDB(s: String): IDbConnection;
begin
  var db := new Mono.Data.Sqlite.SqliteConnection('Data Source='+s+';Version=3;');
  db.Open;
  exit db;
end;

method Project.GetDB(s: String): IDbConnection;
begin
  if File.Exists(s) then File.Delete(s);
  if &Type.GetType('System.MonoType') = nil then begin
    exit GetRegularDB(s);
  end;
  exit GetMonoDB(s)
end;

method Project.CreateDashIndex(aFN: String);
begin
  using dc := GetDB(aFN) do begin
    var trans := dc.BeginTransaction;
    using db: IDbCommand := dc.CreateCommand do begin
      db.CommandText := 'CREATE TABLE searchIndex(id INTEGER PRIMARY KEY, name TEXT, type TEXT, path TEXT)';
      db.ExecuteNonQuery;
      db.CommandText := 'CREATE UNIQUE INDEX anchor ON searchIndex (name, type, path)';
      db.ExecuteNonQuery;

      db.CommandText := 'insert into searchIndex (name, type, path) values (@name, @type, @path)';
      db.Prepare;
      var lName := db.CreateParameter();
      lName.ParameterName := '@name';
      db.Parameters.Add(lName);
      var lType := db.CreateParameter();
      lType.ParameterName := '@type';
      db.Parameters.Add(lType);
      var lPath := db.CreateParameter();
      lPath.ParameterName := '@path';
      db.Parameters.Add(lPath);

      for each el in fFiles do begin
        if el.Value.Toc = nil then continue;
        var lTypeN := el.Value.Properties['dash_type'];
        if String.IsNullOrEmpty(lTypeN) then lTypeN := 'Guide';
        if not String.IsNullOrEmpty(el.Value.Properties['page_title']) then
          lName.Value := el.Value.Properties['page_title']
        else if not String.IsNullOrEmpty(el.Value.Properties['unique_title']) then
          lName.Value := el.Value.Properties['unique_title']
        else 
          lName.Value := el.Value.Title;
        if not String.IsNullOrEmpty(el.Value.Properties.Get('unique_title_suffix')) then
          lName.Value := lName.Value + " "+el.Value.Properties.Get('unique_title_suffix').TrimStart;

        lName.Value := String(lName.Value):Replace('&lt;', '<');
        lType.Value := lTypeN;
        lPath.Value := el.Value.TargetURL.Substring(1);
        db.ExecuteNonQuery;
        for each elv in coalesce(el.Value.Properties['keywords'], '').Split([';',','], StringSplitOptions.RemoveEmptyEntries) do begin
          var m := elv.Trim;
          if m <> '' then begin
            lName.Value := m;
            lName.Value := String(lName.Value):Replace('&lt;', '<');
            db.ExecuteNonQuery;
          end;
        end;
      end;
    end;
    trans.Commit;
  end;
end;

method Project.get_Keywords: String;
begin
  var sb := new StringBuilder;
  var m := Files.SelectMany(a -> coalesce(a.Value.Properties.Get('keywords'):Split([';', ','], StringSplitOptions.RemoveEmptyEntries), new String[0]), (a,v) -> new class (a := a.Value, v)).Where(a -> a.v  <> '');
  sb.AppendLine('<h4>Keywords</h4><ul>');
  for each d in m.GroupBy(a -> a.v).OrderBy(a->a.Key.ToLowerInvariant) do begin
    sb.AppendLine('<li>');
    
    sb.Append(d.Key);
    sb.Append(' ');
    for each el in d do begin
      if edit then
        sb.Append('<a href="/__edit/editor.html?path='+ el.a.RelativeFN.Replace('\', '/') +'">(edit)</a> ');
      sb.Append('<a href="docsgen://action=edit&url=file://'+ el.a.FullFN.Replace('\', '/') +'">(edit externally)</a> ');
      if el.a.IncludeFile then begin
        sb.Append('/'+el.a.RelativeFN.Replace('\','/')+' '+(if String.IsNullOrEmpty(el.a.Title:Trim) then '' else  StripHtml(el.a.Title)));
      end else begin
      sb.AppendLine('<a href="'+el.a.TargetURL);
      
      sb.Append('">/'+el.a.RelativeFN.Replace('\','/')+' '+(if String.IsNullOrEmpty(el.a.Title:Trim) then '' else  StripHtml(el.a.Title)) +'</a> ');
      end;
    end;
    sb.AppendLine('</li>');
  end;
  sb.AppendLine('</ul>');
  fContext.CurrentFile := Files['index.md'];
  var cp := new DotLiquid.RenderParameters;
  cp.Registers := new DotLiquid.Hash;
  cp.Registers.Add('__project', self);
      
  cp.LocalVariables := DotLiquid.Hash.FromAnonymousObject(fContext);
  cp.Registers["file_system"] := self;
  cp.LocalVariables['content'] := sb.ToString;
  cp.LocalVariables['showedit'] := false;
      
  var lKeywords := BaseTemplate.Render(cp);
  exit lKeywords;

end;

method Project.BackgroundGenerate;
begin
  fBackgroundWait := new System.Threading.AutoResetEvent(false);
  fBackgroundList := new Queue<ProjectFile>();
  var tp := new System.Threading.Thread( -> 
    begin
      loop begin
        var lItem: ProjectFile;
        locking fBackgroundList do begin
          if fBackgroundList.Count = 0 then
            lItem := nil
          else begin
            lItem := fBackgroundList.Dequeue;
          end;
        end;
        if lItem <> nil then begin
          try
            locking self do 
              BuildIfNeeded(lItem);
          except
          end;
          System.Threading.Thread.Sleep(10);
        end else 
          fBackgroundWait.WaitOne;
      end;
    end);  
  tp.Name := 'Background Builder';
  tp.Priority := System.Threading.ThreadPriority.Lowest;
  tp.IsBackground := true;
  tp.Start;
  for each el in fFiles.Select(a->a.Value) do
    BackgroundGenerate(el);
end;

method Project.BackgroundGenerate(pf: ProjectFile); 
begin
  Logger.Debug('Starting background generate for '+pf.RelativeFN);
  
  
  locking fBackgroundList do
    fBackgroundList.Enqueue(pf);
  fBackgroundWait.Set;
end;
    

method Project.BuildIfNeeded(aFile: ProjectFile);
begin
  var date := System.IO.File.GetLastWriteTimeUtc(aFile.FullFN);
  Logger.Debug('Date: '+date);
  if aFile.BuildDate < date then begin
    if aFile.LoadDate < date then begin
      Logger.Info('Forcing refresh because of potential mono bug');
      Refresh;
    end;
    GenerateFile(aFile);
  end;
end;

method Project.get_Missing: String;
begin
  var sb := new StringBuilder;
  for each d in fUnknownTargets.SelectMany(a->a.Value, (a,b) -> new class(caller := a.Key, missing := b)).GroupBy(a->a.missing, a -> a.caller).OrderBy(a->a.Key) do begin
    sb.Append('<b>');
    sb.Append(d.Key);
    sb.Append('</b></br>');
    sb.AppendLine('<ul>');
    for each el in d do begin
      var pf: ProjectFile;
      fFiles.TryGetValue(el.Replace('\', '/'), out pf);
      if pf = nil then begin
        sb.Append('<li>');
        sb.Append(el);
        sb.Append('</li>');
        continue;
      end;
      sb.Append('<li>');
      if edit then begin
        sb.Append('<a href="/__edit/editor.html?path='+ pf.RelativeFN.Replace('\', '/') +'">(edit)</a> ');
        sb.Append('<a href="docsgen://action=edit&url=file://'+ pf.FullFN.Replace('\', '/') +'">(edit externally)</a> ');
      end;
      if pf.IncludeFile then 
        sb.AppendLine('/'+pf.RelativeFN.Replace('\','/')+' </li>')
      else 
        sb.AppendLine('<a href="'+pf.TargetURL+'">/'+pf.RelativeFN.Replace('\','/')+'</a> </li>');
    end;
    sb.AppendLine('</ul>');
  end;
  fContext.CurrentFile := Files['index.md'];
  var cp := new DotLiquid.RenderParameters;
  cp.Registers := new DotLiquid.Hash;
  cp.Registers.Add('__project', self);
      
  cp.LocalVariables := DotLiquid.Hash.FromAnonymousObject(fContext);
  cp.Registers["file_system"] := self;
  cp.LocalVariables['content'] := sb.ToString;
  cp.LocalVariables['showedit'] := false;
      
  var lKeywords := BaseTemplate.Render(cp);
  exit lKeywords;

end;

method Project.get_Flags: String;
begin
var sb := new StringBuilder;
  //var sbrel := new StringBuilder;
  var m := Files.SelectMany(a -> coalesce(a.Value.Properties.Get('flags'):Split([';', ','], StringSplitOptions.RemoveEmptyEntries), new String[0]), (a,v) -> new class (a := a.Value, v)).Where(a -> a.v  <> '').GroupBy(a -> a.v, a -> a.a);
  sb.AppendLine('<h4>TOC</h4><ul>');
  
  for each el in m do begin
    var lKey := el.Key;
    sb.AppendLine('<li><a href="#'+lKey+'">'+lKey+'</a></li>');
  end;
  sb.AppendLine('</ul>');
  fContext.CurrentFile := Files['index.md'];
  for each el in m do begin
    var lKey := el.Key;
    if String.IsNullOrEmpty(lKey) then lKey := 'missing';
    sb.Append('<h2 id="'+lKey+'">');
    sb.Append(lKey);
    sb.AppendLine('</h2>');
    for each entry in el do begin
      if (lKey = 'missing') and (entry.IncludeFile) then continue;
      if edit then
      sb.Append('<a href="/__edit/editor.html?path='+ entry.RelativeFN.Replace('\', '/') +'">(edit)</a> ');
      sb.Append('<a href="docsgen://action=edit&url=file://'+ entry.FullFN.Replace('\', '/') +'">(edit externally)</a> ');
      if entry.IncludeFile then begin
        sb.Append(entry.RelativeFN.Replace('\','/')+' '+(if String.IsNullOrEmpty(entry.Title:Trim) then '' else  StripHtml(entry.Title)) +'<br/>');
      end else begin
        sb.Append('<a href="');
        sb.Append(entry.TargetURL);
        sb.Append('">/'+entry.RelativeFN.Replace('\','/')+' '+(if String.IsNullOrEmpty(entry.Title:Trim) then '' else  StripHtml(entry.Title)) +'</a> ');
        sb.Append('<br/>');
      end;
    end;
    sb.AppendLine;
  end;
  var cp := new DotLiquid.RenderParameters;
  cp.Registers := new DotLiquid.Hash;
  cp.Registers.Add('__project', self);
      
  cp.LocalVariables := DotLiquid.Hash.FromAnonymousObject(fContext);
  cp.Registers["file_system"] := self;
  cp.LocalVariables['content'] := sb.ToString;
  cp.LocalVariables['showedit'] := false;
      
  fReview := BaseTemplate.Render(cp);
  exit fReview;
end;


method Project.ExecuteSQLCommand(aConn: IDbConnection; aTrans: IDbTransaction; aCMD: String; aNames: array of String := nil; aValues: array of Object := nil; aLastInsertId: Boolean := false): Int64;
begin
  using db := aConn.CreateCommand do begin
    db.Transaction := aTrans;
    db.CommandText := aCMD;
    for each el in aNames index n do begin 
      var par := db.CreateParameter();
      par.ParameterName := '@'+el;
      par.Value := aValues[n];
      db.Parameters.Add(par);
    end;
    result := db.ExecuteNonQuery;
    if aLastInsertId then begin
      db.Parameters.Clear;
      db.CommandText := 'select last_insert_rowid()';
      exit Convert.ToInt64(db.ExecuteScalar);
    end;
  end;
end;
method Project.BuildHelpDB(aFN, aTargetURL, aIcon: String);
begin
  BuildNavRoot;
  using dc := GetDB(aFN) do begin
    var trans := dc.BeginTransaction;
    ExecuteSQLCommand(dc, trans, 'create table info (version integer, title varchar (1024), css text, image blob, rooturl varchar(2048))');
    ExecuteSQLCommand(dc, trans, 'create table document (id integer, url varchar(2048), type int, name varchar(1024), parentid int null, haschildren bool, parentindex int null, primary key (id))');
    ExecuteSQLCommand(dc, trans, 'create table keyword (document bigint, keyword varchar (1024), keywordtype int)');
    ExecuteSQLCommand(dc, trans, 'create index  if not exists keyword_keywordtype on keyword (keyword,keywordtype);');
    ExecuteSQLCommand(dc, trans, 'create index if not exists doc_parent on document (parentid);');
    ExecuteSQLCommand(dc, trans, 'insert into info (version, title, rooturl) values (20180113, @v, @q)', ['v', 'q'], [title, aTargetURL]);
    if not String.IsNullOrEmpty(aIcon) then
      ExecuteSQLCommand(dc, trans, 'update info set image=@v', ['v'], [File.ReadAllBytes(aIcon)]);

    var ids := new Dictionary<String, Int64>;
    for each el in Files do begin
      var lTypeN := el.Value.Properties['dash_type'];

      var lTypeID := 0;
      case lTypeN:ToLowerInvariant() of 
        'unknown': lTypeID := 0;
        'alias': lTypeID := 1;
        'class': lTypeID := 2;
        'const': lTypeID := 3;
        'delegate': lTypeID := 4;
        'enum': lTypeID := 5;
        'event': lTypeID := 6;
        'extension': lTypeID := 7;
        'extensionmethod': lTypeID := 8;
        'field': lTypeID := 9;
        'generic': lTypeID := 10;
        'interface': lTypeID := 11;
        'keyword': lTypeID := 12;
        'method': lTypeID := 13;
        'namespace': lTypeID := 14;
        'pointer': lTypeID := 15;
        'property': lTypeID := 16;
        'record', 'valuetype': lTypeID := 17;
        'function': lTypeID := 18;
        'block': lTypeID := 19;
        'type': lTypeID := 20;
        else if Int32.TryParse(lTypeN, out var n) then 
          lTypeID := n;
      end;
      

      var lName: String;
      //if not String.IsNullOrEmpty(el.Value.Properties['page_title']) then
        //lName := el.Value.Properties['page_title']
      //else 
      //if not String.IsNullOrEmpty(el.Value.Properties['unique_title']) then
        //lName := el.Value.Properties['unique_title']
      //else 
        lName := el.Value.Title;
      //if not String.IsNullOrEmpty(el.Value.Properties.Get('unique_title_suffix')) then
        //lName := lName + " "+el.Value.Properties.Get('unique_title_suffix').TrimStart;
      if el.Key = '404.md' then continue;
      var lURL := aTargetURL + el.Value.TargetURL;
      var id := ExecuteSQLCommand(dc, trans, 
        'insert into document (url, name, type, parentid) values (@url, @title ,@type, @parentid)',
        ['url', 'title', 'type', 'parentid'],
        [lURL, lName, lTypeID, 
        if el.Key = 'index.md' then 0 else nil], true);
      ids.Add(el.Value.RelativeFN, id);
      var lKWD := new List<String>;
      lKWD.Add(lName);
      for each elv in coalesce(el.Value.Properties['keywords'], '').Split([';',','], StringSplitOptions.RemoveEmptyEntries) do begin
        var m := elv.Trim;
        if m <> '' then begin
          lKWD.Add(m);
        end;
      end;
      for each item in lKWD do 
        ExecuteSQLCommand(dc, trans, 'insert into keyword (document, keyword, keywordtype) values (@doc, @kwd, 0)',
          ['doc', 'kwd'],
          [id, item]);
    end;
    for each el in Files do begin
      var lPar := el.Value:Toc:Parent;
      if lPar = nil then continue;
      
      ExecuteSQLCommand(dc, trans, 'update document set parentid=@pid, parentindex=@pidx where id=@id',
        ['id', 'pid', 'pidx'],
        [ids[el.Value.RelativeFN], ids[lPar.File.RelativeFN], lPar.children.IndexOf(el.Value.Toc)]);
    end;

    ExecuteSQLCommand(dc, trans, 'update document set haschildren = (case when exists (select * from document d2 where d2.parentid=document.id) then 1 else 0 end)');

    trans.Commit;
  end;
end;


constructor TocEntry(aParent: TocEntry; aContext: Context; aFile: ProjectFile);
begin
  fParent := aParent;
  fContext := aContext;
  fFile := aFile;
  title := fFile.Title;
  fContext.CurrentFile := aFile;
end;

method TocEntry.RenderStatus: String;
begin
  var lStatus := fFile.reviewstatus;
  if lStatus = '' then
    exit '<span class="reviewstatus" style="color: red">[MIS]</span> ';
  lStatus := lStatus.ToLowerInvariant;
  case lStatus of
    'ignore': exit '';
    'hidden': exit '<span class="reviewstatus" style="color: fuchsia">[HID]</span> ';
    'new': exit '<span class="reviewstatus" style="color: red">[NEW]</span> ';
    'reviewed': exit '<span class="reviewstatus" style="color: green">[OKE]</span> ';
    'needs-review': exit '<span class="reviewstatus" style="color: maroon">[REV]</span> ';
    'wip': exit '<span class="reviewstatus" style="color: DeepPink">[WIP]</span> ';
    'auto': exit '<span class="reviewstatus" style="color: yellow">[AUT]</span> ';
  else
     exit '<span class="reviewstatus" style="color: blue">[UNK]</span> ';
  end;
end;

method Context.MakeRelative(s: String): String;
begin
  if CurrentFile.Absolute then exit s;
  if s.StartsWith('/') then begin
    s := s.Substring(1);
    if not SingleFile then
    for i: Integer := 0 to CurrentFile.TargetURL.Count(a -> a = '/') -2 do
      s := '../'+s;
    if length(s) = 0 then 
      exit '.';
  end;
  exit s;
end;

method Context.get_pathdown: sequence of TocEntry;
begin
  var lRes := new List<TocEntry>;
  var lWork := CurrentFile.Toc;
  while assigned(lWork:Parent) do begin
    lRes.Add(lWork.Parent);
    lWork := lWork.Parent;
  end;
  if (lRes.Count = 0) and (self.nav[0].File <> CurrentFile) then
    lRes.Add(self.nav[0]);
  lRes.Reverse;
  exit lRes;
end;

method Context.get_extra_css: List<String>;
begin
  result := new List<String>;
  for each el in self.CurrentFile.Properties['extra_css']:Split([','], StringSplitOptions.RemoveEmptyEntries) do
    result.Add(self.MakeRelative(el));
  for each el in self.project['extra_css']:Split([','], StringSplitOptions.RemoveEmptyEntries) do
    result.Add(self.MakeRelative(el));
end;

method Context.get_extra_javascript: List<String>;
begin
  result := new List<String>;
  for each el in self.CurrentFile.Properties['extra_javascript']:Split([','], StringSplitOptions.RemoveEmptyEntries) do
    result.Add(self.MakeRelative(el));
  for each el in self.project['extra_javascript']:Split([','], StringSplitOptions.RemoveEmptyEntries) do
    result.Add(self.MakeRelative(el));
end;

method Context.MakeAbsolute(s: String): String;
begin
  if s.StartsWith('/') then exit s;
  s := Path.Combine(Path.GetDirectoryName(CurrentFile.RelativeFN), s).Replace('\', '/');
  if s.Contains('/..') then begin
    s := ResolvePath(s);
  end;
  exit s;
end;

class method Context.ResolvePath(s: String): String;
begin
  var lItems := s.Split(['/']).ToList;
  loop begin
    var i := lItems.FindIndex(1, a->a = '..');
    if i = -1 then break;
    lItems.RemoveAt(i-1);
    lItems.RemoveAt(i-1);
  end;
  exit String.Join('/', lItems);
end;

method Context.get_previous_page: TocEntry;
begin
  var lte := CurrentFile.Toc;
  if lte = nil then exit;
  var prev := lte;
  lte := lte.Parent;
  var lIndex := 0;

  if lte <> nil then begin
    lIndex := lte.children.IndexOf(prev) - 1;
    for i: Integer := lIndex downto 0 do
      if String.IsNullOrEmpty(lte.children[i].anchor) then begin
        lte := lte.children[i];
        loop begin
          var lnewlte: TocEntry := nil;
          for j: Integer := lte.children.Count -1 downto 0 do begin
            if String.IsNullOrEmpty(lte.children[j].anchor) then begin
              lnewlte := lte.children[j];
              break;
            end;
          end;
          if lnewlte = nil then break;
          lte := lnewlte;
        end;
        exit lte;
      end;
    exit lte;
  end;
end;

method Context.get_next_page: TocEntry;
begin
  var lte := CurrentFile.Toc;
  if lte = nil then exit;
  if lte.children.Count > 0 then begin
    for i: Integer := 0 to lte.children.Count -1 do
      if String.IsNullOrEmpty(lte.children[i].anchor) then
        exit lte.children[i];
  end;
  var prev := lte;
  lte := lte.Parent;
  var lIndex := 0;

  while lte <> nil do begin
    lIndex := lte.children.IndexOf(prev) + 1;
    for i: Integer := lIndex to lte.children.Count -1 do
      if String.IsNullOrEmpty(lte.children[i].anchor) then
        exit lte.children[i];
    prev := lte;
    lte := lte.Parent;
  end;
end;

method Todo.Initialize(tagname: String; markup: String; tokens: List<String>);
begin
  fValue := markup.Trim;
end;

method Todo.Render(context: DotLiquid.Context; &result: TextWriter);
begin
  var lProject :=Project(context.Registers['__project']);
  lProject.Logger.Info('TODO: '+lProject.Context.CurrentFile.RelativeFN+': '+fValue);
  &result.Write('<font color="grey">'+fValue+'</font>');
end;

method MyNameValueCollection.ContainsKey(key: Object): Boolean;
begin
  exit not String.IsNullOrEmpty(inherited Item[key:ToString]);
end;

method Lightbox.Initialize(tagName: String; markup: String; tokens: List<String>);
begin
  var parts := markup.Split(['|'], 3);
  if parts.Length = 1 then begin
    fTarget := parts[0].Trim;
    fImg := fTarget;
    fTitle := "";
  end else begin
    fTarget := parts[0].Trim;
    fTitle := parts[1].Trim;
    if parts.Length = 3 then
      fImg := parts[2].Trim
    else
      fImg := fTarget
  end;
end;

method Lightbox.Render(context: DotLiquid.Context; &result: TextWriter);
begin
  var c: Integer;
  if not context.Registers.ContainsKey('lightbox_counter') then begin
    c := 0;
  end else begin
    Int32.TryParse(context.Registers['lightbox_counter']:ToString, out c);
  end;
  var lProject := Project(context.Registers['__project']);
  context.Registers['lightbox_counter'] := (c+1).ToString;
  &result.Write('<a href="');
  &result.Write(lProject.AdjustURL(fTarget));
  &result.Write('" data-lightbox="image-');
  &result.Write(c);
  &result.Write('" data-title="');
  &result.Write(fTitle);
  &result.Write('"><img alt="');
  &result.Write(fTitle);
  &result.Write('" src="');
  &result.Write(lProject.AdjustURL(fImg));
  &result.Write('" /></a>');
end;

method Resolve.Initialize(tagName: String; markup: String; tokens: List<String>);
begin
  fValue := markup.Trim;
end;

method Resolve.Render(context: DotLiquid.Context; &result: TextWriter);
begin
  var lProject := Project(context.Registers['__project']);
  &result.Write(lProject.AdjustURL(fValue));
end;

method MyFilters.Markdown(ctx: DotLiquid.Context; md: String): String;
begin
  var lProject := Project(ctx.Registers['__project']);
  result := lProject.Markdown.Transform(md).Trim;
  if result.StartsWith('<p>') and result.EndsWith('</p>') then
    result := result.Substring(3, result.Length -7);
end;

method OnAfterBrokenLink(arg1: StringBuilder; arg2: String);
begin

end;


end.
