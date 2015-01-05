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
    <Compile Include="..\libraries\DotLiquid\Block.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\DotLiquid\Condition.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\DotLiquid\Context.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\DotLiquid\Document.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\DotLiquid\Drop.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\DotLiquid\Exceptions\ArgumentException.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\DotLiquid\Exceptions\ContextException.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\DotLiquid\Exceptions\FileSystemException.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\DotLiquid\Exceptions\FilterNotFoundException.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\DotLiquid\Exceptions\LiquidException.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\DotLiquid\Exceptions\StackLevelException.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\DotLiquid\Exceptions\SyntaxException.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\DotLiquid\FileSystems\BlankFileSystem.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\DotLiquid\FileSystems\EmbeddedFileSystem.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\DotLiquid\FileSystems\IFileSystem.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\DotLiquid\FileSystems\LocalFileSystem.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\DotLiquid\Hash.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\DotLiquid\IContextAware.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\DotLiquid\IIndexable.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\DotLiquid\ILiquidizable.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\DotLiquid\IRenderable.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\DotLiquid\IValueTypeConvertible.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\DotLiquid\Liquid.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\DotLiquid\LiquidTypeAttribute.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\DotLiquid\NamingConventions\CSharpNamingConvention.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\DotLiquid\NamingConventions\INamingConvention.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\DotLiquid\NamingConventions\RubyNamingConvention.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\DotLiquid\Proc.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\DotLiquid\RenderParameters.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\DotLiquid\StandardFilters.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\DotLiquid\Strainer.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\DotLiquid\Tag.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\DotLiquid\Tags\Assign.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\DotLiquid\Tags\Block.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\DotLiquid\Tags\Capture.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\DotLiquid\Tags\Case.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\DotLiquid\Tags\Comment.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\DotLiquid\Tags\Cycle.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\DotLiquid\Tags\Extends.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\DotLiquid\Tags\For.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\DotLiquid\Tags\Html\TableRow.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\DotLiquid\Tags\If.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\DotLiquid\Tags\IfChanged.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\DotLiquid\Tags\Include.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\DotLiquid\Tags\Literal.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\DotLiquid\Tags\Raw.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\DotLiquid\Tags\Unless.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\DotLiquid\Template.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\DotLiquid\Util\EnumerableExtensionMethods.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\DotLiquid\Util\ExpressionUtility.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\DotLiquid\Util\ListExtensionMethods.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\DotLiquid\Util\ObjectExtensionMethods.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\DotLiquid\Util\R.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\DotLiquid\Util\Range.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\DotLiquid\Util\StrFTime.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\DotLiquid\Util\Symbol.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\DotLiquid\Util\TypeUtility.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\DotLiquid\Util\WeakTable.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\DotLiquid\Variable.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\MarkdownDeep\Abbreviation.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\MarkdownDeep\Block.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\MarkdownDeep\BlockProcessor.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\MarkdownDeep\FootnoteReference.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\MarkdownDeep\HtmlTag.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\MarkdownDeep\LinkDefinition.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\MarkdownDeep\LinkInfo.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\MarkdownDeep\MardownDeep.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\MarkdownDeep\SpanFormatter.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\MarkdownDeep\StringScanner.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\MarkdownDeep\TableSpec.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\MarkdownDeep\Token.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\MarkdownDeep\Utils.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\mono.net.httplistener\Mono.Net\AuthenticationSchemes.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\mono.net.httplistener\Mono.Net\AuthenticationSchemeSelector.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\mono.net.httplistener\Mono.Net\ChunkedInputStream.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\mono.net.httplistener\Mono.Net\ChunkStream.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\mono.net.httplistener\Mono.Net\EndPointListener.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\mono.net.httplistener\Mono.Net\EndPointManager.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\mono.net.httplistener\Mono.Net\Extensions.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\mono.net.httplistener\Mono.Net\HttpConnection.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\mono.net.httplistener\Mono.Net\HttpListener.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\mono.net.httplistener\Mono.Net\HttpListenerBasicIdentity.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\mono.net.httplistener\Mono.Net\HttpListenerContext.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\mono.net.httplistener\Mono.Net\HttpListenerException.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\mono.net.httplistener\Mono.Net\HttpListenerPrefixCollection.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\mono.net.httplistener\Mono.Net\HttpListenerRequest.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\mono.net.httplistener\Mono.Net\HttpListenerResponse.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\mono.net.httplistener\Mono.Net\HttpStreamAsyncResult.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\mono.net.httplistener\Mono.Net\HttpUtility.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\mono.net.httplistener\Mono.Net\ListenerAsyncResult.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\mono.net.httplistener\Mono.Net\ListenerPrefix.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\mono.net.httplistener\Mono.Net\RequestStream.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\mono.net.httplistener\Mono.Net\ResponseStream.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="..\libraries\mono.net.httplistener\Mono.Net\WebHeaderCollection.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="RegexOptimizations.cs">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="HttpWorker.pas" />
    <Compile Include="Indexer.pas" />
    <Compile Include="Logger.pas">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="Options.pas">
      <SubType>Code</SubType>
    </Compile>
    <Compile Include="Program.pas" />
    <Compile Include="Project.pas" />
    <Compile Include="Properties\AssemblyInfo.pas" />
    <Compile Include="Resources.Designer.pas">
      <SubType>Code</SubType>
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