---
title: Getting Started
---

The first step is to create a _config/_config.json file like:
```
output: "../documentation",
theme: "{builtin}/default",
title: "RemObjects Docs Generator"
```

In this **output** means the path in which the output html files will be placed. 
**theme** is the theme to use, in this case a builtin theme called default, if this is omitted then it uses the default theme.
**title** is the title of the documentation.

other options are:

* **generatesearch**: Generate the search button and index.
* **fullfilename**: If used, the links will include index.html instead of just the path

## First document

The first document must be called index.md, this will be your sites 
```markdown
---
title: Page title 
index: GettingStarted.md
---

Your first document!
```

Each markdown file should start with three dashes: ---, a header, then ---  again. This is the file header, any properties here are used to influence the generator. **title** sets the page title, this is used at the heading of the generated file and in the navigation. **index** is used to create entries in the navigation. The root file (index.md) defines the main index. Each file referenced from there will become sub entries in the navigation. **mount** adds a page or folder from another location to this section, rendering it as if it lived next to the current file. While there's no limit to how many can be used there, the default theme is limited to 3 levels.

After the header you can start writing your content in [markdown](Markdown.md) format. 

Other file specific properties are:

* **page_title**: If set this overrides the title shown at the top of the page (making title the one in the toc)
* **toc**: If true a table of content div is generated.
* **tocmaxlevel**: max level up to which a toc is generated; if this is say to 2 h3,h4,h5 and h6 won't show in the table of contents.
* **tocclasses**: extra css classes that will affect the tree li node.
* **bodyclasses**: extra css classes that will affect the body area for this file.
* **title_prefix**: prefix for title in toc
* **title_suffix**: suffix for title in toc
* **mount**: Mount a markdown file or folder into this section as if it lived next to the current file.
* **status**; set the review status; Possible values: ignore, new, reviewed: byx, needs-review: reason, wip
* **parentindex**; make a "fake" parent; when this is used that item will show "open"/active in the tree
* **absolute**: Makes all links absolute; this is useful for a 404 page.
* **flags**: Used for the "edit mode" flags page
* **review-status**: Used for the "edit mode" status page
* **keywords**: Used for the "edit mode" keywords page
* **sort_by:title**: Sort the index for this file by title instead of original order

## Mounting Shared Pages

Use **mount** to reuse a markdown file or subtree in more than one section without copying it:

```markdown
---
title: CodeBot in Campfire
index: About.md
mount: ../Shared/Chat.md
mount: ../Shared/Common/
index: CampfireOnly.md
---
```

Mounted content is rendered at the destination location. In the example above, `../Shared/Chat.md` is generated as if it were `Chat.md` in the same folder as the current file. Shared files only show in navigation where they are mounted or indexed.


## Second document
Writing the secondd document is pretty much the same as the first, generate a new file, add a header with a title and a content.

## Generating the output
To build use the docsgen.exe with the parameter **build** from within the directory containing your file.

## Markdown corpus

Use **markdown** to export all published documentation into one UTF-8 Markdown file:

```text
docsgen markdown /path/to/docs
```

By default this writes `index_all.md` in the configured output folder (normally `_site`). You can specify an output filename and the public site root:

```text
docsgen markdown /path/to/docs /path/to/export/docs.md https://docs.example.com/
```

Relative output filenames are relative to the current working directory. An output inside the source tree must be in an excluded folder (a folder whose name begins with `_` or `.`), so it will not be imported on the next run. Source files cannot be overwritten.

To include the corpus with every **build**, add these project settings:

```text
markdown: true
markdown-base-url: https://docs.example.com/
```

Set `markdown-skip-generated: true` to omit pages marked `status: auto` from the corpus, while retaining handwritten API concepts and library introductions. `markdown-skip` accepts semicolon-separated source-path wildcards for additional exclusions. These settings affect Markdown only; HTML and help databases remain complete.

The base URL is optional; without it, each page's source URL is site-relative. It can include a deployment subpath. The command-line base URL overrides the setting.

The corpus visits pages in navigation order, then adds published pages outside navigation in ordinal source-path order. Each published URL appears once, even if navigation links to several anchors on that page. Mounted pages appear at their destination paths, just as they do on the site. Hidden pages and standalone include files are omitted. The HTML-only `singlefile-skip` setting does not omit pages from this complete export.

Each page has a `docsgen:page-begin` comment containing its URL-encoded document path, a title, a source URL, a document path, and a `docsgen:page-end` comment. Liquid expressions and includes are expanded using the normal page context, with no surrounding site theme. Template errors fail the export instead of becoming text in the corpus. Output uses stable ordering and LF line endings, without a generated timestamp.

Page bodies remain Markdown: headings, tables, code samples, inline HTML, and link targets are preserved after template expansion. Relative links and reference/footnote labels retain their per-page meaning; consumers should use the page boundaries and document/source metadata rather than treat the corpus as one merged Markdown rendering namespace. This export supplies the source corpus; it does not build a retrieval index or embeddings.

## Docset

# Server mode
DocsGen also has a "server" mode. Instead of build, **serve** should be passed (--port can optionally be useed to override the default port, 4000). In this mode, any changes to the files will automatically update what can be seen in the browser after a refresh.

## Edit mode

When in serve mode --edit can be used to allow "online editing", which enables an Edit button on each page that lets you change the page. Edit mode does live updates of all (open) pages when changes are applied to the file. 

Inside edit mode 4 new virtual pages show up in the tree:

* **review status**: Shows the value of the "reviewstatus" property of each page, grouped by status.
* **flags**: Splits any comma seperated "flags" property in a file and groups then by flag.
* **keywords**: Splits any comma seperated "keywords" property in a file and groups then by flag.
* **missing**: Shows missing files and the documents that reference them.
