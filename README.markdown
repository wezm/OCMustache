OCMustache
==========

Render Mustache templates in Objective-C

OCMustache aims to provide an efficient framework for parsing and rending
[Mustache][mustache] templates. The parser is built using the [Ragel State Machine
Compiler][ragel] in the hope that it will help ensure fast and correct parsing.

[mustache]: http://mustache.github.com/
[ragel]: http://www.complang.org/ragel/

Current State
-------------

The code is still being worked on and the Mustache support is incomplete.

The following still remains to be implemented:

* Better error reporting/handling
* Proc/lambda tags
* Inverted section tags
* Ensure iOS compatibility

When the template language is fully implemented it is intended that a test
runner be built to run the project against the [Mustache Spec][spec].

Note: Since it isn't possible to dynamically change the parser its unlikely that
the set delimiter tag will ever be supported.

More information on usage etc. will be added when the above are completed.

