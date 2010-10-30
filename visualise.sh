#!/bin/sh

OUT=MustacheParserMachine.dot
ragel -p -V MustacheParserMachine.m.rl -o $OUT && open -a Graphviz $OUT
