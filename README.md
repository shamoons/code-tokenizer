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

``


