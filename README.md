code-tokenizer
==============

A JS implementation of a tokenizer to split up source code based on tokens

# Install
```
npm install code-tokenizer --save
```

# How to use
```
Tokenizer = require 'code-tokenizer'

tokenizer = new Tokenizer()

tokens = tokenize 'print "Josh"'
# ['print']


tokens = tokenize 'path/to/file.html', 'file'
# ['<div>', 'id', 'class', '</div>']

```

# Uses
This is based on the [Github Linguist](https://github.com/github/linguist) project. This node.js implementation strips any data strings or comments from the data and returns an array of language symbols.

You can use this to do sanity checking of source code, parsing, detection, etc. This is a general purpose library and I'm always looking to hear how you're using it. Happy Coding!

# Testing
All tests are in the **test/tokenizer.coffee** file. It tests a variety of cases from different language types. To run the test for yourself, just do `npm test`.

# Contact
You can contact me [@shamoons](http://twitter.com/shamoons) or read up on my blog: http://shamoon.me