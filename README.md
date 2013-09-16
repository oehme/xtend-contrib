xtend-contrib
=================

When writing Xtend, you can often safe a lot of boilerplate code
by using a few well designed extension methods or active annotations on top of a given library.

This project aims to collect such small extensions to popular libraries.

[![Build Status](https://oehme.ci.cloudbees.com/job/xtend-contrib/badge/icon)](https://oehme.ci.cloudbees.com/job/xtend-contrib/)

To use it in your Maven build, please add the following repository to your settings.xml:

    <repository>
      <id>oehme-releases</id>
      <url>https://repository-oehme.forge.cloudbees.com/release</url>
      <releases>
        <enabled>true</enabled>
      </releases>
      <snapshots>
        <enabled>false</enabled>
      </snapshots>
    </repository>
