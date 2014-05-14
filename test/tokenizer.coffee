_ = require 'lodash'
fs = require 'fs'
path = require 'path'
should = require 'should'
{Tokenizer} = require '../src/tokenizer'

Tokenizer = new Tokenizer()

tokenize = (data, type = 'string') ->
  if type is 'file'
    data = fs.readFileSync(path.join(__dirname, '../samples', data))

  Tokenizer.tokenize(data)

describe 'Tokenizer', ->
  it 'should skip string literals', ->
    tokenize('print ""').should.eql ['print']
    tokenize('print "Josh"').should.eql ['print']
    tokenize("print 'Josh'").should.eql ['print']
    tokenize('print "Hello \\"Josh\\""').should.eql ['print']
    tokenize("print 'Hello \\'Josh\\''").should.eql ['print']
    tokenize("print \"Hello\", \"Josh\"").should.eql ['print']
    tokenize("print 'Hello', 'Josh'").should.eql ['print']
    tokenize("print \"Hello\", \"\", \"Josh\"").should.eql ['print']
    tokenize("print 'Hello', '', 'Josh'").should.eql ['print']

  it 'should skip number literals', ->
    tokenize('1 + 1').should.eql ['+']
    tokenize('add(123, 456)').should.eql ['add', '(', ')']
    tokenize('0x01 | 0x10').should.eql ['|']
    tokenize('500.42 * 1.0').should.eql ['*']

  it 'should skip comments', ->
    tokenize("foo\n# Comment").should.eql ['foo']
    tokenize("foo\n# Comment\nbar").should.eql ['foo', 'bar']
    tokenize("foo\n// Comment").should.eql ['foo']
    tokenize("foo /* Comment */").should.eql ['foo']
    tokenize("foo /* \nComment\n */").should.eql ['foo']
    tokenize("foo <!-- Comment -->").should.eql ['foo']
    tokenize("foo {- Comment -}").should.eql ['foo']
    tokenize("foo (* Comment *)").should.eql ['foo']
    tokenize("2 % 10\n% Comment").should.eql ['%']

  it 'should tokenize SGML tags', ->
    tokenize("<html></html>").should.eql ['<html>', '</html>']
    tokenize("<div id></div>").should.eql ['<div>', 'id', '</div>']
    tokenize("<div id=foo></div>").should.eql ['<div>', 'id=', "</div>"]
    tokenize("<div id class></div>").should.eql ['<div>', 'id', 'class', '</div>']
    tokenize("<div id=\"foo bar\"></div>").should.eql ['<div>', 'id=', "</div>"]
    tokenize("<div id='foo bar'></div>").should.eql ['<div>', 'id=', "</div>"]
    tokenize("<?xml version=\"1.0\"?>").should.eql ['<?xml>', 'version=']

  it 'should tokenize operators', ->
    tokenize("1 + 1").should.eql ['+']
    tokenize("1 - 1").should.eql ['-']
    tokenize("1 * 1").should.eql ['*']
    tokenize("1 / 1").should.eql ['/']
    tokenize("2 % 5").should.eql ['%']
    tokenize("1 & 1").should.eql ['&']
    tokenize("1 && 1").should.eql ['&&']
    tokenize("1 | 1").should.eql ['|']
    tokenize("1 || 1").should.eql ['||']
    tokenize("1 < 0x01").should.eql ['<']
    tokenize("1 << 0x01").should.eql ['<<']

  it 'should tokenize C tokens', ->
    tokenize('C/hello.h', 'file').should.eql "#ifndef HELLO_H #define HELLO_H void hello \( \) ; #endif".split(' ')



