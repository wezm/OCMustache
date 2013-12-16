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

The best way I can think of to add the project to your own is to add is as a
git submodule then add the source to your Xcode project. Do so as follows:

1. `cd YourProject`
2. `git submodule add https://wezm@github.com/wezm/OCMustache.git OCMustache`
3. In the Xcode sidebar right click your project and choose Add > Existing
   Files... then select the OCMustache folder within the OCMustache project.

Once added to your project use the MustacheTemplate class to render templates.

    #import "MustacheTemplate.h"

    // Load and parse the template, this only needs to be done once.
    MustacheTemplate *template = [[MustacheTemplate alloc] initWithString:@"Hello {{place}}!"];
    NSError *error = nil;
    if(![template parseReturningError:error]) {
      NSString *errorMsg = error ? [error localizedDescription] : @"unknown";
      NSLog(@"Error parsing template: %@", errorMsg);
      return;
    }

    // Later in your app when you want to render the template one or more times.
    NSDictionary *context = [NSDictionary dictionaryWithObject:@"World" forKey:@"place"];
    NSString *result = [template renderInContext:context];

    // Result is `Hello World!`

The context argument to `renderInContext:` can be any [Key-Value coding][kvc]
compliant object. For simple variable tags such as `{{place}}` the value
returned by `valueForKey:` is tested to see if it responds to `stringValue`. If
so, the result of calling it is used, otherwise `description` is used.

[kvc]: http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/KeyValueCoding/KeyValueCoding.html

For sections if the value is `nil` or the value responds to `boolValue`, if so
and the result of that is `NO` then the section is skipped. If the value
conforms to the `NSFastEnumeration` then it is treated as a list -- except if
it also responds to objectForKey (like a dictionary). In the latter case or for
any other objects the value is used as the context for the section.

Inverted sections are shown if the value is `nil`, `boolValue` is `NO` or
`count` is 0.

Current State
-------------

The code is feature complete with the exception of lambda and delimiter tags.
The code is a first cut and there is room for refactoring and improvement but
it passes the tests and the bulk of the specs in Mustache-Spec. The failing
tests in Mustache-Spec are to do with whitespace and some false positives on
the handling of sections and inverted sections due to limitations of the YAML
library in use to load the specs.

OCMustache is in use in these published applications:

* [Radiopaedia](http://appstore.com/radiopaedia) (iOS)

The following still remains to be completed:

* Better error reporting/handling
* Proc/lambda tags
* Non-Apple platform support (GNUStep) on FreeBSD, Linux
* Add some examples

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
