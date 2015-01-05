---
title: Markdown syntax
---

Docsgen uses the [standard markdown syntax](http://daringfireball.net/projects/markdown/syntax) except for the following adjustments:

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