<?xml version="1.0" encoding="utf-8"?>
<Project DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003" ToolsVersion="4.0">
  <PropertyGroup>
    <ProductVersion>3.5</ProductVersion>
    <RootNamespace>DocsGen</RootNamespace>
    <ProjectGuid>{154230af-41a6-4fa9-ad5f-8e33ac95d7db}</ProjectGuid>
    <OutputType>exe</OutputType>
    <AssemblyName>DocsGen</AssemblyName>
    <AllowGlobals>False</AllowGlobals>
    <AllowLegacyWith>False</AllowLegacyWith>
    <AllowLegacyOutParams>False</AllowLegacyOutParams>
    <AllowLegacyCreate>False</AllowLegacyCreate>
    <AllowUnsafeCode>False</AllowUnsafeCode>
    <ApplicationIcon>Properties\App.ico</ApplicationIcon>
    <Configuration Condition="'$(Configuration)' == ''">Release</Configuration>
    <TargetFrameworkVersion>v4.5</TargetFrameworkVersion>
    <Name>DocsGen</Name>
    <ProjectView>ShowAllFiles</ProjectView>
  </PropertyGroup>
  <PropertyGroup Condition=" '$(Configuration)' == 'Debug' ">
    <Optimize>False</Optimize>
    <OutputPath>..\Bin\</OutputPath>
    <DefineConstants>DEBUG;TRACE;NET_4_5;SECURITY_DEP</DefineConstants>
    <GeneratePDB>True</GeneratePDB>
    <GenerateMDB>True</GenerateMDB>
    <StartMode>Project</StartMode>
    <CpuType>anycpu</CpuType>
    <RuntimeVersion>v25</RuntimeVersion>
    <XmlDoc>False</XmlDoc>
    <XmlDocWarningLevel>WarningOnPublicMembers</XmlDocWarningLevel>
    <EnableUnmanagedDebugging>False</EnableUnmanagedDebugging>
    <WarnOnCaseMismatch>True</WarnOnCaseMismatch>
  </PropertyGroup>
  <PropertyGroup Condition=" '$(Configuration)' == 'Release' ">
    <OutputPath>bin\Release\</OutputPath>
    <EnableAsserts>False</EnableAsserts>
    <CaptureConsoleOutput>False</CaptureConsoleOutput>
    <StartMode>Project</StartMode>
    <CpuType>anycpu</CpuType>
    <RuntimeVersion>v25</RuntimeVersion>
    <XmlDoc>False</XmlDoc>
    <XmlDocWarningLevel>WarningOnPublicMembers</XmlDocWarningLevel>
    <EnableUnmanagedDebugging>False</EnableUnmanagedDebugging>
    <WarnOnCaseMismatch>True</WarnOnCaseMismatch>
    <DefineConstants>NET_4_5;SECURITY_DEP</DefineConstants>
  </PropertyGroup>
  <ItemGroup>
    <Reference Include="Mono.Data.Sqlite">
      <HintPath>..\libraries\sqlite\Mono.Data.Sqlite.dll</HintPath>
    </Reference>
    <Reference Include="mscorlib" />
    <Reference Include="System" />
    <Reference Include="System.Data" />
    <Reference Include="System.Data.SQLite">
      <HintPath>..\libraries\sqlite\System.Data.SQLite.dll</HintPath>
    </Reference>
    <Reference Include="System.Drawing">
      <HintPath>C:\Program Files (x86)\Reference Assemblies\Microsoft\Framework\.NETFramework\v4.5\System.Drawing.dll</HintPath>
    </Reference>
    <Reference Include="System.Xml" />
    <Reference Include="System.Core">
      <RequiredTargetFramework>3.5</RequiredTargetFramework>
    </Reference>
    <Reference Include="System.Xml.Linq">
      <RequiredTargetFramework>3.5</RequiredTargetFramework>
    </Reference>
    <Reference Include="System.Data.DataSetExtensions">
      <RequiredTargetFramework>3.5</RequiredTargetFramework>
    </Reference>
  </ItemGroup>
  <ItemGroup>
    <Compile Include="..\libraries\DotLiquid\Block.cs" />
    <Compile Include="..\libraries\DotLiquid\Condition.cs" />
    <Compile Include="..\libraries\DotLiquid\Context.cs" />
    <Compile Include="..\libraries\DotLiquid\Document.cs" />
    <Compile Include="..\libraries\DotLiquid\Drop.cs" />
    <Compile Include="..\libraries\DotLiquid\Exceptions\ArgumentException.cs" />
    <Compile Include="..\libraries\DotLiquid\Exceptions\ContextException.cs" />
    <Compile Include="..\libraries\DotLiquid\Exceptions\FileSystemException.cs" />
    <Compile Include="..\libraries\DotLiquid\Exceptions\FilterNotFoundException.cs" />
    <Compile Include="..\libraries\DotLiquid\Exceptions\LiquidException.cs" />
    <Compile Include="..\libraries\DotLiquid\Exceptions\StackLevelException.cs" />
    <Compile Include="..\libraries\DotLiquid\Exceptions\SyntaxException.cs" />
    <Compile Include="..\libraries\DotLiquid\FileSystems\BlankFileSystem.cs" />
    <Compile Include="..\libraries\DotLiquid\FileSystems\EmbeddedFileSystem.cs" />
    <Compile Include="..\libraries\DotLiquid\FileSystems\IFileSystem.cs" />
    <Compile Include="..\libraries\DotLiquid\FileSystems\LocalFileSystem.cs" />
    <Compile Include="..\libraries\DotLiquid\Hash.cs" />
    <Compile Include="..\libraries\DotLiquid\IContextAware.cs" />
    <Compile Include="..\libraries\DotLiquid\IIndexable.cs" />
    <Compile Include="..\libraries\DotLiquid\ILiquidizable.cs" />
    <Compile Include="..\libraries\DotLiquid\IRenderable.cs" />
    <Compile Include="..\libraries\DotLiquid\IValueTypeConvertible.cs" />
    <Compile Include="..\libraries\DotLiquid\Liquid.cs" />
    <Compile Include="..\libraries\DotLiquid\LiquidTypeAttribute.cs" />
    <Compile Include="..\libraries\DotLiquid\NamingConventions\CSharpNamingConvention.cs" />
    <Compile Include="..\libraries\DotLiquid\NamingConventions\INamingConvention.cs" />
    <Compile Include="..\libraries\DotLiquid\NamingConventions\RubyNamingConvention.cs" />
    <Compile Include="..\libraries\DotLiquid\Proc.cs" />
    <Compile Include="..\libraries\DotLiquid\RenderParameters.cs" />
    <Compile Include="..\libraries\DotLiquid\StandardFilters.cs" />
    <Compile Include="..\libraries\DotLiquid\Strainer.cs" />
    <Compile Include="..\libraries\DotLiquid\Tag.cs" />
    <Compile Include="..\libraries\DotLiquid\Tags\Assign.cs" />
    <Compile Include="..\libraries\DotLiquid\Tags\Block.cs" />
    <Compile Include="..\libraries\DotLiquid\Tags\Capture.cs" />
    <Compile Include="..\libraries\DotLiquid\Tags\Case.cs" />
    <Compile Include="..\libraries\DotLiquid\Tags\Comment.cs" />
    <Compile Include="..\libraries\DotLiquid\Tags\Cycle.cs" />
    <Compile Include="..\libraries\DotLiquid\Tags\Extends.cs" />
    <Compile Include="..\libraries\DotLiquid\Tags\For.cs" />
    <Compile Include="..\libraries\DotLiquid\Tags\Html\TableRow.cs" />
    <Compile Include="..\libraries\DotLiquid\Tags\If.cs" />
    <Compile Include="..\libraries\DotLiquid\Tags\IfChanged.cs" />
    <Compile Include="..\libraries\DotLiquid\Tags\Include.cs" />
    <Compile Include="..\libraries\DotLiquid\Tags\Literal.cs" />
    <Compile Include="..\libraries\DotLiquid\Tags\Raw.cs" />
    <Compile Include="..\libraries\DotLiquid\Tags\Unless.cs" />
    <Compile Include="..\libraries\DotLiquid\Template.cs" />
    <Compile Include="..\libraries\DotLiquid\Util\EnumerableExtensionMethods.cs" />
    <Compile Include="..\libraries\DotLiquid\Util\ExpressionUtility.cs" />
    <Compile Include="..\libraries\DotLiquid\Util\ListExtensionMethods.cs" />
    <Compile Include="..\libraries\DotLiquid\Util\ObjectExtensionMethods.cs" />
    <Compile Include="..\libraries\DotLiquid\Util\R.cs" />
    <Compile Include="..\libraries\DotLiquid\Util\Range.cs" />
    <Compile Include="..\libraries\DotLiquid\Util\StrFTime.cs" />
    <Compile Include="..\libraries\DotLiquid\Util\Symbol.cs" />
    <Compile Include="..\libraries\DotLiquid\Util\TypeUtility.cs" />
    <Compile Include="..\libraries\DotLiquid\Util\WeakTable.cs" />
    <Compile Include="..\libraries\DotLiquid\Variable.cs" />
    <Compile Include="..\libraries\MarkdownDeep\Abbreviation.cs" />
    <Compile Include="..\libraries\MarkdownDeep\Block.cs" />
    <Compile Include="..\libraries\MarkdownDeep\BlockProcessor.cs" />
    <Compile Include="..\libraries\MarkdownDeep\FootnoteReference.cs" />
    <Compile Include="..\libraries\MarkdownDeep\HtmlTag.cs" />
    <Compile Include="..\libraries\MarkdownDeep\LinkDefinition.cs" />
    <Compile Include="..\libraries\MarkdownDeep\LinkInfo.cs" />
    <Compile Include="..\libraries\MarkdownDeep\MardownDeep.cs" />
    <Compile Include="..\libraries\MarkdownDeep\SpanFormatter.cs" />
    <Compile Include="..\libraries\MarkdownDeep\StringScanner.cs" />
    <Compile Include="..\libraries\MarkdownDeep\TableSpec.cs" />
    <Compile Include="..\libraries\MarkdownDeep\Token.cs" />
    <Compile Include="..\libraries\MarkdownDeep\Utils.cs" />
    <Compile Include="..\libraries\mono.net.httplistener\Mono.Net\AuthenticationSchemes.cs" />
    <Compile Include="..\libraries\mono.net.httplistener\Mono.Net\AuthenticationSchemeSelector.cs" />
    <Compile Include="..\libraries\mono.net.httplistener\Mono.Net\ChunkedInputStream.cs" />
    <Compile Include="..\libraries\mono.net.httplistener\Mono.Net\ChunkStream.cs" />
    <Compile Include="..\libraries\mono.net.httplistener\Mono.Net\EndPointListener.cs" />
    <Compile Include="..\libraries\mono.net.httplistener\Mono.Net\EndPointManager.cs" />
    <Compile Include="..\libraries\mono.net.httplistener\Mono.Net\Extensions.cs" />
    <Compile Include="..\libraries\mono.net.httplistener\Mono.Net\HttpConnection.cs" />
    <Compile Include="..\libraries\mono.net.httplistener\Mono.Net\HttpListener.cs" />
    <Compile Include="..\libraries\mono.net.httplistener\Mono.Net\HttpListenerBasicIdentity.cs" />
    <Compile Include="..\libraries\mono.net.httplistener\Mono.Net\HttpListenerContext.cs" />
    <Compile Include="..\libraries\mono.net.httplistener\Mono.Net\HttpListenerException.cs" />
    <Compile Include="..\libraries\mono.net.httplistener\Mono.Net\HttpListenerPrefixCollection.cs" />
    <Compile Include="..\libraries\mono.net.httplistener\Mono.Net\HttpListenerRequest.cs" />
    <Compile Include="..\libraries\mono.net.httplistener\Mono.Net\HttpListenerResponse.cs" />
    <Compile Include="..\libraries\mono.net.httplistener\Mono.Net\HttpStreamAsyncResult.cs" />
    <Compile Include="..\libraries\mono.net.httplistener\Mono.Net\HttpUtility.cs" />
    <Compile Include="..\libraries\mono.net.httplistener\Mono.Net\ListenerAsyncResult.cs" />
    <Compile Include="..\libraries\mono.net.httplistener\Mono.Net\ListenerPrefix.cs" />
    <Compile Include="..\libraries\mono.net.httplistener\Mono.Net\RequestStream.cs" />
    <Compile Include="..\libraries\mono.net.httplistener\Mono.Net\ResponseStream.cs" />
    <Compile Include="..\libraries\mono.net.httplistener\Mono.Net\WebHeaderCollection.cs" />
    <Compile Include="RegexOptimizations.cs" />
    <Compile Include="HttpWorker.pas" />
    <Compile Include="Indexer.pas" />
    <Compile Include="Logger.pas" />
    <Compile Include="Options.pas" />
    <Compile Include="Program.pas" />
    <Compile Include="Project.pas" />
    <Compile Include="Properties\AssemblyInfo.pas" />
    <Compile Include="Resources.Designer.pas">
      <DependentUpon>Resources.resx</DependentUpon>
    </Compile>
    <Content Include="Properties\App.ico" />
    <Content Include="x64\SQLite.Interop.dll">
      <SubType>Content</SubType>
      <CopyToOutputDirectory>PreserveNewest</CopyToOutputDirectory>
    </Content>
    <Content Include="x86\SQLite.Interop.dll">
      <SubType>Content</SubType>
      <CopyToOutputDirectory>PreserveNewest</CopyToOutputDirectory>
    </Content>
    <EmbeddedResource Include="Properties\Resources.resx">
      <Generator>ResXFileCodeGenerator</Generator>
    </EmbeddedResource>
    <Compile Include="Properties\Resources.Designer.pas" />
    <EmbeddedResource Include="Resources.resx">
      <Generator>ResXFileCodeGenerator</Generator>
    </EmbeddedResource>
    <None Include="Properties\Settings.settings">
      <Generator>SettingsSingleFileGenerator</Generator>
    </None>
    <Compile Include="Properties\Settings.Designer.pas" />
  </ItemGroup>
  <ItemGroup>
    <Folder Include="Properties\" />
    <Folder Include="x64\" />
    <Folder Include="x86\" />
  </ItemGroup>
  <Import Project="$(MSBuildExtensionsPath)\RemObjects Software\Oxygene\RemObjects.Oxygene.Echoes.targets" />
</Project>