OCMustache
==========

[{{ mustache }}][mustache] templates for Objective-C

Mustache is a code-free templating language with implementations for many
languages. OCMustache aims to provide an efficient framework for parsing and
rending Mustache templates in Objective-C. The parser is built using the [Ragel
State Machine Compiler][ragel] in the hope that it will help ensure fast and
correct parsing.

[mustache]: http://mustache.github.com/
[ragel]: http://www.complang.org/ragel/

Usage
-----

More information on usage etc. will be added when the above are completed.

Current State
-------------

The code is still being worked on and the Mustache support is incomplete.

The following still remains to be implemented/tested:

* Better error reporting/handling
* Proc/lambda tags
* Partials
* iOS compatibility
* Non-Apple platform support (GNUStep) on FreeBSD, Linux

**Note:** Since it isn't possible to dynamically change the parser its unlikely that
the set delimiter tag will ever be supported.

Testing
-------

There are two test targets in the project. The Specs target is a small suite of
specs written for this project. The Mustace-Specs target is a test runner for
the tests specified by the [Mustache Spec][spec] project. Both suites use the
Cedar BDD framework. Cedar, [YAML.framework][yaml] and Mustache-Spec are
submodules of this project. YAML is used to load the Mustache-Spec tests.

[spec]: http://github.com/pvande/Mustache-Spec
[yaml]: http://github.com/mirek/YAML.framework
