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

Each markdown file should start with three dashes: ---, a header, then ---  again. This is the file header, any properties here are used to influence the generator. Currently only two properties do something : **title** sets the page title, this is used at the heading of the generated file and in the navigation. **index** is used to create entries in the navigation. The root file (index.md) defines the main index. Each file referenced from there will become sub entries in the navigation. While there's no limit to how many can be used there, the default theme is limited to 3 levels.

After the header you can start writing your content in [markdown](Markdown.md) format. 

Other file specific properties are:

* **page_title**: If set this overrides the title shown at the top of the page (making title the one in the toc)
* **toc**: If true a table of content div is generated.
* **tocmaxlevel**: max level up to which a toc is generated; if this is say to 2 h3,h4,h5 and h6 won't show in the table of contents.
* **tocclasses**: extra css classes that will affect the tree li node.
* **bodyclasses**: extra css classes that will affect the body area for this file.
* **title_prefix**: prefix for title in toc
* **title_suffix**: suffix for title in toc
* **status**; set the review status; Possible values: ignore, new, reviewed: byx, needs-review: reason, wip
* **parentindex**; make a "fake" parent; when this is used that item will show "open"/active in the tree
* **absolute**: Makes all links absolute; this is useful for a 404 page.
* **flags**: Used for the "edit mode" flags page
* **review-status**: Used for the "edit mode" status page
* **keywords**: Used for the "edit mode" keywords page
* **sort_by:title**: Sort the index for this file by title instead of original order


## Second document
Writing the secondd document is pretty much the same as the first, generate a new file, add a header with a title and a content.

## Generating the output
To build use the docsgen.exe with the parameter **build** from within the directory containing your file.

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

