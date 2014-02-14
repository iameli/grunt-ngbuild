grunt-ngbuild
=============

ngbuild is a grunt task for building Angular modules based on their dependencies. The files containing the dependencies of the specified Angular module will be concatenated into the output file. See the test directory for an example.

Why ngbuild?
------------

ngbuild is useful for large Angular projects that may have multiple compilation targets. Perhaps you have a big Angular webapp that runs on your website, but one module of it can also be embedded on other sites. Rather than manually keeping track of which source files end up where, just point ngbuild at your entire src and let it work out which files need to get included.


Limitations
-----------

The current version of ngbuild works by running your Angular source code in a sandboxed node environment and keeping track of all the calls to angular.module. This makes it smart in some ways and dumb in some other ways. It's smart in that it will correctly parse something like `angular["mod"+"ule"]('name', "dep1,dep2,dep3".split(','))`. This means it will (probably) correctly parse minified source code.

It's dumb in that it'll choke on anything that's either the call `angular.module` or a call on the returned module functions themselves. 

    angular.module("mod", [])
    window.alert("Hooray, I created a module!") 
    //TypeError: Object #<Object> has no method 'alert'

So if you're doing a lot of non-angular things in your angular source files this is probably not the module for you. But why are you doing that? You're (probably) breaking angular's sandboxing and making me sad. 

License
-------

Copyright (c) 2014, Eli Mallon

Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.