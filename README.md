# docsgen
Html generator for product documentation sites. 

This is the tool we use to generate http://docs.elementscompiler.com/, http://docs.dataabstract.com/ and http://docs.hydra4.com/ with.

It expects a directory like the [docs](docs) subdir and generates relocatable html from it, including a Javascript based search index, a table of context generator based on header tags (index:) and highlightJS based highlighting.


Works in both a "live" mode where updating files updates the html live and even refreshes the pages that are open, or in generator mode.

## Modern documentation layout

Add `docs_layout: modern` to a project's `_config` to opt into the modern
layout in the default theme. The masthead uses the project title by default.
A project can set `docs_brand_name` for the bold product name,
`docs_brand_prefix` for the text before it, and `docs_brand_icon` for an icon
path relative to the documentation root.

In a project stylesheet loaded through `extra_css`, set
`--docs-masthead-art` to a CSS image or gradient and `--docs-accent` to a
link color on `.docs-modern`. Use `--docs-surface` and `--docs-line` to tint
the sidebar and pagination cards, and `--docs-nav-hover` and
`--docs-nav-active` to set the sidebar row backgrounds. Relative URLs in those CSS values resolve from
the project stylesheet. The default theme supplies the navigation, article,
and page outline.
