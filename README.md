xtend-contrib
=================

Since the xtend-core library is kept very small (for good reason), there are some extension methods and active annotations that you may be missing in everyday development. This project provides some of the most commonly requested features.

[![Build Status](https://oehme.ci.cloudbees.com/job/xtend-contrib/badge/icon)](https://oehme.ci.cloudbees.com/job/xtend-contrib/)
```xml
<dependency>
  <groupId>com.github.oehme.xtend</groupId>
  <artifactId>xtend-contrib</artifactId>
  <version>...</version>
</dependency>
```
Features
========

Convenience methods for writing active annotations
--------------------------------------------------

There are some AST transformations that you tend to do a lot when writing active annotations.

These include:
 - adding an indirection to a method (for aspect oriented things like logging, caching etc.)
 - implementing a method from an interface
 - checking whether some method/constructor already exists
 - adding simple toString/hashCode/equals methods
 - adding simple constructors
 - adding getters/setters for fields
    
All of these tasks are greatly simplified by the CommonQueries and CommonTransformations classes in this library.

@Cached
-------

Caches invocations of a method, e.g. to make recursive algorithms more efficient.
```xtend
@Cached
def BigInteger fibonacci(int n) {
    switch n {
        case 0: 0bi
        case 1: 1bi
        default: fibonacci(n - 1) + fibonacci(n - 2)
    }
}
```
@ValueObject
------------

Turns a class into an immutable value object, including a fluent builder class.
```xtend
@ValueObject class Address {
	String street
	String city
	String zip
	String postOfficeBox
}

class AddressBuilder {
	/*You can customize the builder if you want, 
	* for instance add Annotations or convenience methods.
	*/
}
```    
@Property
---------

Adds a getter and (if not final) a setter to a field, if not already present. Contrary to the @Property annotation shipped with Xtend, this one will *not* rename the field. This means it follows the JavaBean conventions and will work with reflective frameworks.
```xtend
class Person {
  @Property String name
}
```  
@ExtractInterface
-----------------

There are times where you have only one sensible production implementation of a class, but you want to use an interface for better testing. In such cases you just need to add the @ExtractInterface annotation to your class and Xtend will automatically create an interface with all the public methods of the class.
```xtend
@ExtractInterface
//generates an interface called "Thing"
class DefaultThing {
    override foo() {

    }

    override bar(String baz) {
        "foobar"
    }
}
```
![](http://www.cloudbees.com/sites/default/files/Button-Built-on-CB-1.png)
