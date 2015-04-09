---
title: Markdown syntax
---

Docsgen uses the [^markdown] with the following extensions:

* Github style syntax highlighting is added, which is done by using \`\`\` lang on one line, closed with \`\`\` on another line.
 
		``` oxygene
		namespace test;
		interface
		implementation
		end.
		```
 
becomes:
``` oxygene
namespace test;
interface
implementation
end.
```



[^markdown]:
The [standard markdown syntax](http://daringfireball.net/projects/markdown/syntax) is used for docsgen.