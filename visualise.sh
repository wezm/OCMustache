#!/bin/sh

OUT=MustacheParserMachine.dot
ragel -p -V MustacheParser.m.rl -o $OUT && open -a Graphviz $OUT
