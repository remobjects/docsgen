namespace DocsGen;

interface

type
  ILogger = public interface
    method Error(aMsg: String);
    method Debug(aMsg: String);
    method Info(aMsg: String);
    method Warn(aMsg: String);

    property ShowDebug: Boolean read write;
    property ShowInfo: Boolean read write;
    property ShowWarn: Boolean read write;
    property HasErrors: Boolean read;
  end;

  LogManager = public class
  private
    class var fInstance: ILogger := new ConsoleLogger;
  public
    class method GetCurrentClassLogger: ILogger;
  end;

  ConsoleLogger = public class(ILogger)
  private
    fHasErrors : Boolean;
  public
    property ShowDebug: Boolean;
    property ShowInfo: Boolean;
    property ShowWarn: Boolean := true;
    method Error(aMsg: String);
    method Debug(aMsg: String);
    method Info(aMsg: String);
    method Warn(aMsg: String);

    property HasErrors: Boolean read fHasErrors;
  end;

implementation

method ConsoleLogger.Error(aMsg: String);
begin
  var lSave := Console.ForegroundColor;
  fHasErrors  := true;
  Console.ForegroundColor := ConsoleColor.Red;
  Console.WriteLine('[Err] '+aMsg);
  Console.ForegroundColor := lSave;
end;

method ConsoleLogger.Debug(aMsg: String);
begin
  if not ShowDebug then exit;
  var lSave := Console.ForegroundColor;
  Console.ForegroundColor := ConsoleColor.Blue;
  Console.WriteLine('[Dbg] '+aMsg);
  Console.ForegroundColor := lSave;
end;

method ConsoleLogger.Info(aMsg: String);
begin
  if not ShowInfo then exit;
  var lSave := Console.ForegroundColor;
  Console.ForegroundColor := ConsoleColor.White;
  Console.WriteLine('[Inf] '+aMsg);
  Console.ForegroundColor := lSave;
end;

method ConsoleLogger.Warn(aMsg: String);
begin
  if not ShowWarn then exit;
  var lSave := Console.ForegroundColor;
  Console.ForegroundColor := ConsoleColor.Yellow;
  Console.WriteLine('[Wrn] '+aMsg);
  Console.ForegroundColor := lSave;
end;

class method LogManager.GetCurrentClassLogger: ILogger;
begin
  exit fInstance;
end;

end.
