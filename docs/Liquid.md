---
title: Liquid syntax
---

Liquid is a templating language that can be used to do conditional coding in templates and in markdown files. It has two kinds of tags both start with {:

# Liquid Expressions

``` text
{% literal %}{{ variable }}{% endliteral %}
```

This accesses a variable or expression.

| Name 	| Value 	| 
|----------	|-------	|
| file | access the file object, through this you can access all properties defined at the top of the file, like file.title |
| local_url | a local path (ie file://) to this file |
| project | access the project object, through this you can access all properties defined in the root of the settings.json, like project.theme |
| base_url | a string you can use as a link prefix that always points to the relative root |
| content | the current generator content, only applicable from outside a template. |
| page_title | the title of the current page, essentially the same as file.title	|
| page_url | the current page's url|
| homepage_url | relative path to the root index.html |
| pathdown | the breadcrumbs down to the root, used for the template |
| nav | the navigation list, this is a list with a recursive structure with these fields: tocclasses, title_prefix, title_postfix (Read from the file), visible, title, url, seperatorafter, active and children |
| extra_javascript | Extra javascript is a foreach-able list of the extra_javascript entries in both the current file and the project |
| extra_css | Extra javascript is a foreach-able list of the extra_javascript entries in both the current file and the project |
| edit | If true, we're in "edit" mode |
| gacode | google analytics; if set a ga block is emitted | 

# Liquid Blocks
A block is something executables, the meaning dependent on the implementation, with this syntax:

``` text
{% literal %}{% block parameters %}{% endliteral %}
```

| Name | Meaning |
| ---- | ------- | 
| capture varname | Captures everything until an endcapture block into varname, after which {% literal %}{{varname}}{% endliteral %} can be used to extract it. |
| comment | ignores everything until endcomment. |
| for | For in loop over the expression executing the body for each entry: {% literal %}{% for item in collection %} {{ forloop.index }}: {{ item.name }} {% endfor %}{% endliteral %} |
| if expression / else / endif | If expression is true the body till else or endif is evaluated, else if there's an else block that will be evaluated |
| include filename | include the content of a file |
| literal | raw content without liquid evaluation up until endliteral |
| todo | shows a todo entry in the DocsGen build log |
| lightbox | Emits a lightbox tag {%literal%}{% lightbox /path/to/image.png | title | smallversion.png %}{%endliteral%}, only the first parameter is required. |
| resolve | Resolves an absolute link to it final location |

# More information on Liquid

[Liquid for Designers](https://github.com/Shopify/liquid/wiki/Liquid-for-Designers)