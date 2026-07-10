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
    method WriteLine(aMsg: String; aColor: ConsoleColor);
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

method ConsoleLogger.WriteLine(aMsg: String; aColor: ConsoleColor);
begin
  try
    var lSave := Console.ForegroundColor;
    Console.ForegroundColor := aColor;
    Console.WriteLine(aMsg);
    Console.ForegroundColor := lSave;
  except
    // The macOS helper can run without a writable stdout/stderr stream.
  end;
end;

method ConsoleLogger.Error(aMsg: String);
begin
  fHasErrors  := true;
  WriteLine('[Err] '+aMsg, ConsoleColor.Red);
end;

method ConsoleLogger.Debug(aMsg: String);
begin
  if not ShowDebug then exit;
  WriteLine('[Dbg] '+aMsg, ConsoleColor.Blue);
end;

method ConsoleLogger.Info(aMsg: String);
begin
  if not ShowInfo then exit;
  WriteLine('[Inf] '+aMsg, ConsoleColor.White);
end;

method ConsoleLogger.Warn(aMsg: String);
begin
  if not ShowWarn then exit;
  WriteLine('[Wrn] '+aMsg, ConsoleColor.Yellow);
end;

class method LogManager.GetCurrentClassLogger: ILogger;
begin
  exit fInstance;
end;

end.
