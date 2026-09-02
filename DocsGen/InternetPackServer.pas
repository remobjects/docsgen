namespace DocsGen;

interface

uses
  System,
  System.Collections.Generic,
  System.Text,
  RemObjects.Elements.RTL,
  RemObjects.InternetPack,
  RemObjects.InternetPack.Http;

type
  HttpUrl = public class
  public
    property AbsolutePath: String;
  end;

  HttpQueryString = public class
  private
    fValues := new Dictionary<String, String>;
  public
    constructor(aQuery: String);
    property Item[aKey: String]: String read GetItem; default;
  private
    method GetItem(aKey: String): String;
  end;

  HttpListenerRequest = public class
  public
    property Url: HttpUrl;
    property HttpMethod: String;
    property QueryString: HttpQueryString;
    property InputStream: Stream;
  end;

  HttpResponseHeaders = public class
  private
    fValues := new Dictionary<String, String>;
  public
    property Item[aKey: String]: String read GetItem write SetItem; default;
    method ApplyTo(aHeader: HttpHeaders);
  private
    method GetItem(aKey: String): String;
    method SetItem(aKey: String; aValue: String);
  end;

  HttpListenerResponse = public class
  public
    constructor;
    method Redirect(aLocation: String);
    method Close;
    property StatusCode: Integer := 200;
    property StatusDescription: String := 'OK';
    property ContentType: String;
    property ContentLength64: Int64;
    property Headers := new HttpResponseHeaders;
    property OutputStream: System.IO.MemoryStream; readonly;
  end;

  HttpListenerContext = public class
  public
    constructor(aRequest: HttpListenerRequest);
    property Request: HttpListenerRequest; readonly;
    property Response := new HttpListenerResponse; readonly;
  end;

  InternetPackServer = public class
  private
    fServer: HttpServer;
    fWorker: HttpWorker;
    method HandleRequest(aSender: Object; aEventArgs: HttpRequestEventArgs);
    method RenderErrorPage(aError: Exception): String;
    method HtmlEncode(aValue: String): String;
    method StatusCodeFor(aCode: Integer): HttpStatusCode;
  public
    constructor(aPort: Integer; aWorker: HttpWorker);
    method Start;
    method Close;
  end;

implementation

constructor HttpQueryString(aQuery: String);
begin
  if length(aQuery) = 0 then
    exit;

  for each lPart in aQuery.TrimStart('?').Split('&') do begin
    if length(lPart) = 0 then
      continue;
    var lEquals := lPart.IndexOf('=');
    var lKey := if lEquals < 0 then lPart else lPart.Substring(0, lEquals);
    var lValue := if lEquals < 0 then '' else lPart.Substring(lEquals+1);
    fValues[System.Uri.UnescapeDataString(lKey.Replace('+', ' '))] := System.Uri.UnescapeDataString(lValue.Replace('+', ' '));
  end;
end;

method HttpQueryString.GetItem(aKey: String): String;
begin
  if fValues.ContainsKey(aKey) then
    result := fValues[aKey];
end;

method HttpResponseHeaders.GetItem(aKey: String): String;
begin
  if fValues.ContainsKey(aKey) then
    result := fValues[aKey];
end;

method HttpResponseHeaders.SetItem(aKey: String; aValue: String);
begin
  fValues[aKey] := aValue;
end;

method HttpResponseHeaders.ApplyTo(aHeader: HttpHeaders);
begin
  for each lHeader in fValues do
    aHeader.SetHeaderValue(lHeader.Key, lHeader.Value);
end;

constructor HttpListenerResponse;
begin
  StatusCode := 200;
  StatusDescription := 'OK';
  OutputStream := new System.IO.MemoryStream;
end;

method HttpListenerResponse.Redirect(aLocation: String);
begin
  StatusCode := 302;
  StatusDescription := 'Found';
  Headers['Location'] := aLocation;
end;

method HttpListenerResponse.Close;
begin
  // Internet Pack sends the buffered response after the request event returns.
end;

constructor HttpListenerContext(aRequest: HttpListenerRequest);
begin
  Request := aRequest;
end;

constructor InternetPackServer(aPort: Integer; aWorker: HttpWorker);
begin
  fServer := new HttpServer;
  fServer.Port := aPort;
  fServer.KeepAlive := true;
  fServer.CloseConnectionsOnShutdown := true;
  fServer.HttpRequest += HandleRequest;
  fWorker := aWorker;
end;

method InternetPackServer.Start;
begin
  fServer.Open;
end;

method InternetPackServer.Close;
begin
  fServer.Close;
end;

method InternetPackServer.HtmlEncode(aValue: String): String;
begin
  if not assigned(aValue) then
    exit '';

  result := aValue.Replace('&', '&amp;').Replace('<', '&lt;').Replace('>', '&gt;').Replace('"', '&quot;').Replace('''', '&#39;');
end;

method InternetPackServer.RenderErrorPage(aError: Exception): String;
begin
  var lDetails := if assigned(aError) then HtmlEncode(aError.Message) else 'An unknown error occurred.';
  result := '<!doctype html>'+
    '<html lang="en"><head><meta charset="utf-8">'+
    '<meta name="viewport" content="width=device-width, initial-scale=1">'+
    '<title>Request failed</title>'+
    '<style>body{margin:0;background:#f5f7fa;color:#263238;font:16px/1.55 -apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif}'+
    'main{box-sizing:border-box;max-width:720px;margin:8vh auto;padding:0 24px}.card{background:#fff;border-radius:12px;box-shadow:0 12px 35px #26323822;overflow:hidden}'+
    'header{padding:28px 32px;background:linear-gradient(135deg,#c62828,#ef5350);color:#fff}h1{margin:0;font-size:25px;font-weight:650}'+
    'section{padding:28px 32px}p{margin:0 0 18px}code{display:block;padding:14px 16px;background:#f1f3f5;border-radius:6px;color:#9c1c1c;white-space:pre-wrap;word-break:break-word}'+
    'a{color:#1565c0}footer{color:#6b7780;font-size:13px}</style></head><body><main><div class="card">'+
    '<header><h1>Something went wrong</h1></header><section><p>The server could not complete this request.</p>'+
    '<code>'+lDetails+'</code><p><a href="javascript:location.reload()">Try again</a></p>'+
    '<footer>If this keeps happening, check the DocsGen server log for the full exception.</footer></section></div></main></body></html>';
end;

method InternetPackServer.HandleRequest(aSender: Object; aEventArgs: HttpRequestEventArgs);
begin
  var lRequest := new HttpListenerRequest;
  lRequest.Url := new HttpUrl(AbsolutePath := aEventArgs.Request.Path);
  lRequest.HttpMethod := aEventArgs.Request.Header.RequestType;
  lRequest.QueryString := new HttpQueryString(aEventArgs.Request.QueryString.ToString);
  lRequest.InputStream := aEventArgs.Request.ContentStream;

  var lContext := new HttpListenerContext(lRequest);
  try
    fWorker.Run(lContext);
  except
    on e: Exception do begin
      Console.WriteLine('Internet Pack request failed: '+e.ToString);
      lContext.Response.StatusCode := 500;
      lContext.Response.StatusDescription := 'Internal Server Error';
      lContext.Response.ContentType := 'text/html; charset=utf-8';
      var lError := Encoding.UTF8.GetBytes(RenderErrorPage(e));
      lContext.Response.OutputStream.Write(lError, 0, lError.Length);
    end;
  end;

  lContext.Response.Headers.ApplyTo(aEventArgs.Response.Header);
  if length(lContext.Response.ContentType) > 0 then
    aEventArgs.Response.Header.SetHeaderValue('Content-Type', lContext.Response.ContentType);
  aEventArgs.Response.HttpCode := StatusCodeFor(lContext.Response.StatusCode);
  aEventArgs.Response.ContentStream := new MemoryStream(lContext.Response.OutputStream.ToArray);
  aEventArgs.Response.ContentStream.Seek(0, SeekOrigin.Begin);
end;

method InternetPackServer.StatusCodeFor(aCode: Integer): HttpStatusCode;
begin
  result := case aCode of
    200: HttpStatusCode.OK;
    302: HttpStatusCode.Found;
    403: HttpStatusCode.Forbidden;
    404: HttpStatusCode.NotFound;
  else
    HttpStatusCode.InternalServerError;
  end;
end;

end.