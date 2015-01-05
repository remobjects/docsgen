namespace DocsGen;

interface

uses
  NDesk.Options,
  System.IO,
  System.Linq;

type
  ConsoleApp = class
  public
    class var fPort: Integer := 4000;
    class var fLoop: Boolean := false;
    class var fLogger: ILogger := new ConsoleLogger;
    class var fOverrideOptions: System.Collections.Generic.Dictionary<String, String> := new System.Collections.Generic.Dictionary<String, String>;
    class method Main(args: array of String): Integer;
    class method BuildProject(aPath: String);
    class method BuildDocSetProject(aPath: String);
    class method ServeProject(aPath: String);
  end;

implementation

class method ConsoleApp.Main(args: array of String): Integer;
begin
  {$IFDEF DEBUG}
  Console.WriteLine('Argument count: '+length(args));
  for each el in args index n do
    Console.WriteLine(n+': '+el);
  {$ENDIF}
  var lOptionSet := new OptionSet;
  lOptionSet.Add('showinfo', 'Show logger info messages', a-> begin fLogger.ShowInfo := assigned(a) end);
  lOptionSet.Add('showdebug', 'Show logger debug messages', a-> begin fLogger.ShowDebug := assigned(a) end);
  lOptionSet.Add('showwarning', 'Show logger warning messages', a-> begin fLogger.ShowWarn := assigned(a) end);
  lOptionSet.Add('overrideoption:', 'Override a project option', (k,v)-> begin fOverrideOptions.Add(k, v) end );
  lOptionSet.Add('edit', 'Show review/edit options',  a -> begin fOverrideOptions['edit'] := if assigned(a) then 'true' else 'false' end );
  lOptionSet.Add('port|p=', 'Set the port to use when serving; defaults to 4000', a -> begin Int32.TryParse(a, out fPort) end);
  lOptionSet.Add('loop', 'If set serve won''t wait for enter but loop', a -> begin fLoop := assigned(a) end);
  
  args := lOptionSet.Parse(args).ToArray;
  var lCmd := '';
  if length(args) > 0 then
    lCmd := args[0];
  try
    case lCmd:ToLowerInvariant of
      'build': BuildProject(if args.Length > 1 then args[1] else Environment.CurrentDirectory);
      'serve': ServeProject(if args.Length > 1 then args[1] else Environment.CurrentDirectory);
      'docset':BuildDocSetProject(if args.Length > 1 then args[1] else Environment.CurrentDirectory);
    else
      Console.WriteLine('DocsGen [command] [path]');
      Console.WriteLine('  - Build: Generate it');
      Console.WriteLine('  - Serve: Run an http server that serves the files');
      lOptionSet.WriteOptionDescriptions(Console.Out);
      exit 1;
    end;
  except
    on e: Exception do begin
      Console.WriteLine('Got an error: '+e.ToString);
      exit 1;
    end;
  end;
 end;

class method ConsoleApp.BuildProject(aPath: String);
begin
  var lProject := new Project(fLogger, aPath, fOverrideOptions);
  var lTime := new System.Diagnostics.Stopwatch;
  lTime.Start;
  lProject.Build;
  fLogger.Info('Took: '+lTime);
end;

class method ConsoleApp.ServeProject(aPath: String);
begin
  fLogger.ShowInfo := true;
  var lProject := new Project(fLogger, aPath, fOverrideOptions);
  var lWatcher := new System.IO.FileSystemWatcher(aPath);
  lWatcher.IncludeSubdirectories := true;
  lWatcher.Changed += (s,e) -> begin if not e.Name.StartsWith(lProject.Output) and not e.Name.Contains('__review.md') then  lProject.BeginRefresh; end;
  lWatcher.Deleted += (s,e) -> begin if not e.Name.StartsWith(lProject.Output) and not e.Name.Contains('__review.md') then  lProject.BeginRefresh; end;
  lWatcher.Renamed += (s,e) -> begin if not e.Name.StartsWith(lProject.Output) and not e.Name.Contains('__review.md') then  lProject.BeginRefresh; end;
  lWatcher.Created += (s,e) -> begin if not e.Name.StartsWith(lProject.Output) and not e.Name.Contains('__review.md') then  lProject.BeginRefresh; end;
  lWatcher.EnableRaisingEvents := true;
  var lHttp := new Mono.Net.HttpListener();
  lHttp.Prefixes.Add('http://*:'+fPort+'/');
  lHttp.Start();
  lProject.BuildNavRoot;
  lHttp.BeginGetContext(@new HttpWorker(lProject, lHttp).Callback, nil);
  Console.WriteLine('Serving on http://localhost:'+fPort);
  lProject.BackgroundGenerate;
  if fLoop then begin
    loop System.Threading.Thread.Sleep(1000);
  end else begin
    Console.WriteLine('Press Enter to exit');
    Console.ReadLine;
  end;
  lHttp.Close;
end;

class method ConsoleApp.BuildDocSetProject(aPath: String);
begin
  var lProject := new Project(fLogger, aPath, fOverrideOptions);
  var lShortName := coalesce(lProject.Settings['shortname'], lProject.Settings.Get('title'):Replace(' ', ''));
  var lDS := Path.Combine(aPath, lProject.Settings.Get('output'), lShortName+'.docset');
  Directory.CreateDirectory(Path.Combine(lDS, 'Contents', 'Resources', 'Documents'));
  lProject.Settings.Set('output',  Path.Combine(lProject.Settings.Get('output'), lShortName+'.docset', 'Contents', 'Resources', 'Documents'));
  var lTime := new System.Diagnostics.Stopwatch;
  lTime.Start;
  lProject.Build;
  File.WriteAllText(Path.Combine(lDS, 'Contents', 'Info.plist'),
'<?xml version="1.0" encoding="UTF-8"?>'#13#10+
'<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">'#13#10+
'<plist version="1.0">'#13#10+
'<dict>'#13#10+
	'<key>CFBundleIdentifier</key>'#13#10+
	'<string>'+lShortName+'</string>'#13#10+
	'<key>CFBundleName</key>'#13#10+
	'<string>'+lProject.title+'</string>'#13#10+
	'<key>DocSetPlatformFamily</key>'#13#10+
	'<string>'+lShortName+'</string>'#13#10+
	'<key>isDashDocset</key>'#13#10+
	'<true/>'#13#10+
'</dict>'#13#10+
'</plist>'#13#10);

  lProject.CreateDashIndex(Path.Combine(lDS, 'Contents', 'Resources', 'docSet.dsidx'));
  fLogger.Info('Took: '+lTime.Elapsed);
end;

end.
