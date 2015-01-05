namespace DocsGen;

interface

uses
  System.Collections.Generic,
  System.Linq,
  Mono.Net,
  System.Threading.Tasks,
  System.Text;

type
  WaitingRequest = public class
  public
    property Item: HttpListenerContext;
  end;
  HttpWorker = public class
  private
    method StartUpdateCheck(aContext: HttpListenerContext);
    method ServeFile(aContext: HttpListenerContext; aFile: ProjectFile);
    method SendError(aCtx: HttpListenerContext; aCode: Integer; aReason: String; aBody: String);
    method WriteString(aCtx: HttpListenerContext; s: String): Task;
    method SendFile(aCtx: HttpListenerContext; aFileName: String);
    fProject: Project;
    fInTimer: Boolean;
    fServer: HttpListener;
    fTimer: System.Threading.Timer;
    fWaitingRequests: Dictionary<String, LinkedList<WaitingRequest>> := new Dictionary<String,LinkedList<WaitingRequest>>;
  protected
    method Editor(aContext: HttpListenerContext; aPath: String): Boolean;
    method Run(aContext: HttpListenerContext); async; // run on threadpool
    method SendHtml(aCtx: HttpListenerContext; s: String);
    method RefreshWaiting(o: Object);
  public
    method FileUpdated(s: String);
    constructor(aProject: Project; aServer: HttpListener);
    method Callback(ar: IAsyncResult);
  end;

implementation

constructor HttpWorker(aProject: Project; aServer: HttpListener);
begin
  fProject := aProject;
  fServer := aServer;
  fProject.FileUpdated += (a,b) -> FileUpdated(a.Replace('\', '/'));
  if &Type.GetType('System.MonoType') <> nil then
    fTimer := new System.Threading.Timer(@RefreshWaiting, nil, TimeSpan.FromSeconds(4), TimeSpan.FromSeconds(4));
end;

method HttpWorker.Callback(ar: IAsyncResult);
begin
  try
    Run(fServer.EndGetContext(ar));
    fServer.BeginGetContext(@Callback, nil);
  except
    // can fail on closing
  end;
end;

method HttpWorker.Run(aContext: HttpListenerContext);
begin
  var s := aContext.Request.Url.AbsolutePath;
  if s.StartsWith('/__updatecheck') and fProject.edit then begin
    StartUpdateCheck(aContext);
    exit;
  end;
  if s.StartsWith('/__edit/') and fProject.edit then begin
    if Editor(aContext, s.Substring(8)) then exit;
  end;
  case aContext.Request.HttpMethod:ToUpperInvariant of
    'GET', 'HEAD': begin
      while s.StartsWith('/') do s := s.Substring(1);
      locking fProject do begin
        if s = '__missing.html'then begin
          try
            SendHtml(aContext, fProject.Missing);
          except
            on e: Exception do
              SendError(aContext, 500, 'Internal Error', e.Message);
          end;
          exit;
        end else 
        if s = '__keywords.html'then begin
          try
            SendHtml(aContext, fProject.Keywords);
          except
            on e: Exception do
              SendError(aContext, 500, 'Internal Error', e.Message);
          end;
          exit;
        end else 
        if s = '__status.html' then begin
          try
            SendHtml(aContext, fProject.Review);
          except
            on e: Exception do
              SendError(aContext, 500, 'Internal Error', e.Message);
          end;
          exit;
        end else if s = '__status_release.html' then begin
          try
            SendHtml(aContext, fProject.ReviewRelease);
          except
            on e: Exception do
              SendError(aContext, 500, 'Internal Error', e.Message);
          end;
          exit;
        end;

        var lPath: ProjectFile;
        if s.EndsWith('index.html') then s := s.Substring(0, s.Length - 10);
        if (s = '') and fProject.Files.TryGetValue('index.md', out lPath)  then begin 
          ServeFile(aContext, lPath);
          exit;
        end;
        if s.EndsWith('/') then begin
          if fProject.Files.TryGetValue(s+'index.md', out lPath) then begin
            ServeFile(aContext, lPath);
            exit;
          end;
          if fProject.Files.TryGetValue(s.Substring(0, s.Length-1) + '.md', out lPath) then begin
            ServeFile(aContext, lPath);
            exit;
          end;
        end;
        if fProject.Files.ContainsKey(s+'.md') then begin
          aContext.Response.Redirect(s +'/');
          aContext.Response.Close;
          exit;
        end;

        
        if fProject.OtherFilesDict.Contains(s) then begin
          SendFile(aContext, System.IO.Path.Combine(fProject.ProjectPath, s));
          exit;
        end;
        if fProject.ThemeResources.Contains(s.Replace('/', System.IO.Path.DirectorySeparatorChar)) then begin
          SendFile(aContext, System.IO.Path.Combine(fProject.ThemePath, s));
          exit;
        end;
        SendError(aContext, 404, 'Not Found', 'Could not find that file');
      end;
    end;
    else 
      SendError(aContext, 403, 'Forbidden', 'Only GET and HEAD are allowed');
  end;
end;

method HttpWorker.SendError(aCtx: HttpListenerContext; aCode: Integer; aReason: String; aBody: String);
begin
  try
    aCtx.Response.StatusCode := aCode;
    aCtx.Response.StatusDescription := aReason;
    aCtx.Response.ContentType := 'text/html';
  
    await WriteString(aCtx, String.Format("<html>
  <head>
    <title>{0} {1}</title>
  </head>
  <body>
    <h1>{0} {1}</h1>
    {2}
  </body>
  </html>", aCode, aReason, aBody));
  except
  end;
  aCtx.Response.OutputStream.Close;
end;

method HttpWorker.WriteString(aCtx: HttpListenerContext; s: String): System.Threading.Tasks.Task;
begin
  var b := Encoding.UTF8.GetBytes(s);
  exit aCtx.Response.OutputStream.WriteAsync(b, 0, b.Length);
end;

method HttpWorker.SendFile(aCtx: HttpListenerContext; aFileName: String);
begin
  try
    using fs := System.IO.File.OpenRead(aFileName) do begin
      aCtx.Response.ContentType :=  case System.IO.Path.GetExtension(aFileName) of
        '.html': 'text/html';
        '.md': 'text/markdown';
        '.js': 'text/javascript';
        '.css': 'text/css';
        '.png': 'image/png';
        '.jpg', '.jpeg': 'image/jpeg';
        '.gif': '.gif';
      else
        'application/octet-stream';
      end;
      aCtx.Response.ContentLength64 := fs.Length;
      await fs.CopyToAsync(aCtx.Response.OutputStream);

      aCtx.Response.Close;
    end;
  except
    on e: Exception do begin
      try
        SendError(aCtx, 500, 'Internal Error', e.Message);
      except
        //
      end;
    end;
  end;
end;

method HttpWorker.ServeFile(aContext: HttpListenerContext; aFile: ProjectFile);
begin
  try
    fProject.Logger.Debug('Serving file: '+aFile.FullFN+'; Last build date: '+aFile.BuildDate);
    fProject.BuildIfNeeded(aFile);
            
    SendFile(aContext, System.IO.Path.Combine(fProject.ProjectPath, fProject.Output, aFile.TargetFN));
    exit;
  except
    on e: Exception do begin
      SendError(aContext, 500, 'Internal Error', 'Error generating file: '+e.Message);
      exit;
    end;
  end;
end;

method HttpWorker.Editor(aContext: HttpListenerContext; aPath: String): Boolean;
begin
  try
    if aPath = '__load' then begin
      var lFile := aContext.Request.QueryString['path'];
      var pf: ProjectFile;
      if not fProject.Files.TryGetValue(lFile, out pf) then begin
        SendError(aContext, 404, 'Not Found', 'File not found!');
        exit true;
      end;
      SendFile(aContext, pf.FullFN);
      exit true;
    end;
    if aPath = '__save' then begin
      var lFile := aContext.Request.QueryString['path'];
      var pf: ProjectFile;
      if not fProject.Files.TryGetValue(lFile, out pf) then begin
        SendError(aContext, 404, 'Not Found', 'File not found!');
        exit true;
      end;
      var fs := new System.IO.MemoryStream;
      var lTask := aContext.Request.InputStream.CopyToAsync(fs).GetAwaiter;
      lTask.OnCompleted(-> begin
        try
          lTask.GetResult;
          fs.Position := 0;
          System.IO.File.WriteAllBytes(pf.FullFN, fs.ToArray);
          SendError(aContext, 200, 'Ok', '');
        except
          on e: Exception do begin
            SendError(aContext, 500, 'Internal Error', e.Message);
          end;
        end;
        end);
      exit true;
    end;
    var tp := System.IO.Path.GetFullPath(System.IO.Path.Combine(Project.StandardThemePath.Replace('/', System.IO.Path.DirectorySeparatorChar), 'editor'));

    var nf :=System.IO. Path.Combine(tp, aPath.Replace('/', System.IO.Path.DirectorySeparatorChar));
    if System.IO. Path.GetFullPath(nf).StartsWith(tp) and System.IO.File.Exists(nf) then begin
      SendFile(aContext, nf);
      exit true;
    end;
  except
    exit false;
  end;
end;

method HttpWorker.StartUpdateCheck(aContext: HttpListenerContext);
begin
  var lPath := aContext.Request.QueryString['path'];
  var lSince: Int64;
  var lData: ProjectFile;
  Int64.TryParse(aContext.Request.QueryString['since'], out lSince);
  locking fProject do begin
    if not fProject.Files.TryGetValue(lPath, out lData) then begin
      try
      SendError(aContext, 404, 'Not Found', 'Not Found');
      except end;
      exit;
    end;
    if lData.LoadDate.Ticks > lSince then begin
      try
      SendError(aContext, 200, 'OK', 'UPDATED');
      except end;
      exit;
    end;
  end;
  locking fWaitingRequests do begin
    var lWork:  LinkeDList<WaitingRequest>;
    if not fWaitingRequests.TryGetValue(lPath, out lWork) then begin
      lWork := new LinkedList<WaitingRequest>;
      fWaitingRequests.Add(lPath, lWork);
    end;
    lWork.AddLast(new WaitingRequest(Item := aContext));
  end;
  await Task.Delay(60000);
  locking fWaitingRequests do begin
    var lWork: LinkedList<WaitingRequest>;
    if not fWaitingRequests.TryGetValue(lPath, out lWork) then exit;
    var lItem := lWork.FirstOrDefault(a->a.Item = aContext);
    if lItem = nil then exit;
    lWork.Remove(lItem);
  end;
  try
    aContext.Response.StatusCode := 200;
    aContext.Response.StatusDescription := 'OK';
    aContext.Response.ContentType := 'text/plain';
  
    await WriteString(aContext, 'NOT UPDATED');
  except 
  end;
  try
    aContext.Response.Close();
  except
  end;
end;

method HttpWorker.FileUpdated(s: String);
begin
  locking fProject do begin
    var pf: ProjectFile;
    if fProject.Files.TryGetValue(s, out pf) then
      fProject.BackgroundGenerate(pf);
  end;
  var lWork: LinkedList<WaitingRequest>;
  locking fWaitingRequests do begin
    if not fWaitingRequests.TryGetValue(s, out lWork) then exit;
    fWaitingRequests.Remove(s);
  end;
  for each el in lWork do begin
    try
      el.Item.Response.StatusCode := 200;
      el.Item.Response.StatusDescription := 'OK';
      el.Item.Response.ContentType := 'text/plain';
  
      await WriteString(el.Item, 'UPDATED');
    except 
    end;
    try el.Item.Response.OutputStream.Close; except end;
  end;
end;

method HttpWorker.SendHtml(aCtx: HttpListenerContext; s: String);
begin
  try
    aCtx.Response.StatusCode := 200;
    aCtx.Response.StatusDescription := 'OK';
    aCtx.Response.ContentType := 'text/html';
  
    await WriteString(aCtx, s);
  except
  end;
  aCtx.Response.OutputStream.Close;
end;

method HttpWorker.RefreshWaiting(o: Object);
begin
  if fInTimer then exit;
  fInTimer := true;
  var lFiles: List<String>;
  locking fWaitingRequests do begin
    lFiles := fWaitingRequests.Keys.ToList;
  end;

  if lFiles.Count > 0 then begin
    for each el in lFiles do begin
      locking fProject do begin
        var pf: ProjectFile;
        if not fProject.Files.TryGetValue(el, out pf) then continue;
        try
          var date := System.IO.File.GetLastWriteTimeUtc(pf.FullFN);
          if pf.LoadDate < date then 
            FileUpdated(el);
        except
        end;
      end;
    end;
  end;
  fInTimer := false;
end;

end.
