# docsgen
Html generator for product documentation sites. 

This is the tool we use to generate http://docs.elementscompiler.com/, http://docs.dataabstract.com/ and http://docs.hydra4.com/ with.

It expects a directory like the [docs](docs) subdir and generates relocatable html from it, including a Javascript based search index, a table of context generator based on header tags (index:) and highlightJS based highlighting.


Works in both a "live" mode where updating files updates the html live and even refreshes the pages that are open, or in generator mode.
