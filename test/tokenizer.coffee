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
    tokenize('C/hello.c', 'file').should.eql "#include <stdio.h> int main \( \) { printf \( \) ; return ; }".split(' ')

  it 'should tokenize CPP tokens', ->
    tokenize('C++/bar.h', 'file').should.eql "class Bar { protected char *name ; public void hello \( \) ; }".split(' ')
    tokenize('C++/hello.cpp', 'file').should.eql "#include <iostream> using namespace std ; int main \( \) { cout << << endl ; }".split(' ')

  it 'should tokenize Objective-C tokens', ->
    tokenize("Objective-C/Foo.h", 'file').should.eql "#import <Foundation/Foundation.h> @interface Foo NSObject { } @end".split(' ')
    tokenize("Objective-C/Foo.m", 'file').should.eql "#import @implementation Foo @end".split(' ')
    tokenize("Objective-C/hello.m", 'file').should.eql "#import <Cocoa/Cocoa.h> int main \( int argc char *argv [ ] \) { NSLog \( @ \) ; return ; }".split(' ')

  it.skip 'should extract shebangs', ->
    tokenize('Shell/sh.script!', 'file')[0].should.eql 'SHEBANG#!sh'
    tokenize("Shell/bash.script!", 'file')[0].should.eql 'SHEBANG#!bash'
    tokenize("Shell/zsh.script!", 'file')[0].should.eql 'SHEBANG#!zsh'
    tokenize("Perl/perl.script!", 'file')[0].should.eql 'SHEBANG#!perl'
    tokenize("Python/python.script!", 'file')[0].should.eql 'SHEBANG#!python'
    tokenize("Ruby/ruby.script!", 'file')[0].should.eql 'SHEBANG#!ruby'
    tokenize("Ruby/ruby2.script!", 'file')[0].should.eql 'SHEBANG#!ruby'
    tokenize("JavaScript/js.script!", 'file')[0].should.eql 'SHEBANG#!node'
    tokenize("PHP/php.script!", 'file')[0].should.eql 'SHEBANG#!php'
    tokenize("Erlang/factorial.script!", 'file')[0].should.eql 'SHEBANG#!escript'
    tokenize("Shell/invalid-shebang.sh", 'file')[0].should.eql 'echo'

  it.only 'should tokenize JavaScript tokens', ->
    tokenize('JavaScript/hello.js', 'file').should.eql "( function \( \) { console.log \( \) ; } \) .call \( this \) ;".split(' ')

