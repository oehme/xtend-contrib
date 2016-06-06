xtend-contrib
=================

A collection of Active Annotations that will be useful in many projects, but which would be too controversial to include in the Xtend standard library.

[![Build Status](https://travis-ci.org/oehme/xtend-contrib.svg)](https://travis-ci.org/oehme/xtend-contrib)
[ ![Download](https://api.bintray.com/packages/oehme/maven/xtend-contrib/images/download.svg) ](https://bintray.com/oehme/maven/xtend-contrib/_latestVersion)
Features
========

You can see all the features in action in the [examples project](https://github.com/oehme/xtend-contrib/tree/master/xtend-contrib-examples/src/main/java/de/oehme/xtend/contrib/examples)

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

@Buildable
--------
Creates a fluent Builder for ValueObjects. Works nicely with the @Data annotation that is shipped with Xtend by default.
```xtend
@Data
@Buildable
class Person {
    String firstName
    String lastName
    int age
}
```

@Messages
---------
Creates a statically typed facade for localization ResourceBundles.
The generated methods take an argument for each placeholder in the message.
The type of the argument will be inferred from the message format.

```properties
Hello=Hello {0}, the time currently is {1, time}!
Trains={0,number} trains spotted.
```

```xtend
@Messages class MyMessages {
    def static void main(String[] args) {
        val messages = new MyMessages(Locale.GERMAN)
        println(messages.hello("Stefan", new Date))
        print(messages.trains(3))
    }
}
```

@Log
----
Adds a java.util.logging.Logger to your class
```xtend
@Log class Commander {
    def whatIsThis() {
        log.warning("It's a trap!")
    }
}
```

Similar annotations for other major logging frameworks are also avaiable.

Convenience classes for writing Active Annotations
--------------------------------------------------
- [SignatureHelper](https://github.com/oehme/xtend-contrib/blob/master/xtend-contrib/src/main/java/de/oehme/xtend/contrib/SignatureHelper.xtend) simplifies copying methods, e.g. to implement an interface or to add an indirection.
- [Reflections](https://github.com/oehme/xtend-contrib/blob/master/xtend-contrib/src/main/java/de/oehme/xtend/contrib/Reflections.xtend) allows you to scan packages for types in order to aggregate them
