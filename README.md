USACO Tool by Benoît Legat
==========================

Introduction
------------

This tool is designed to help you during your training on usaco website.
Automating tasks makes you gain time and efforts to only concentrate on the code.

The strategy used here is

* **Python** scripts to surf the web with mechanize;
* **Bash** scripts to generate new environment and call **Python** scripts.

Github repository
-----------------

You can find this tool on github searching for the project named *usaco-tool*

License
-------

This tool can be modified, and shared without any conditions.
It would be also relevant from you to modify it for another training or even for an online competition
where gaining time is very important like google code jam.
There is already a tool for that at `code.google.com/p/codejam-commandline/`
but you can make script to use them even faster (I have advanced scripts available too, just ask me if you want them).

Version
-------

This is the 1.2 version, this is still a *beta* version so bugs may occur. Please report them.

Environment
-----------

The environment created by the scripts is the following

* main_directory/
    * conf.sh
    * new.sh
    * README
    * .tool/
        * inout.py
        * submit.py
        * config
        * main.cpp
        * run.sh
        * s.sh
* directories containing files for each problem named with the problem name/
    * main.cpp
    * s.sh
    * Test<i\>/
        * in
        * out
	
The scripts in .tool should not be called directly.
They are called by other scripts that you call directly like new.sh, conf.sh and s.sh.

Required packages
-----------------

* python
* python-mechanize

Installation
------------

Create a directory where you want to put all your environment.
Put the _tar_ file in it and make it your current directory with `cd` command (`$ man cd`)

  `$ tar xvfz usacotool-1.2.tar.gz`
  `$ rm usacotool-1.2.tar.gz`

Notice that you are likely to have already untarred the _usacotool-1.2.tar.gz_ file because you are reading this file
Now run `conf.sh`
`$ chmod u+x conf.sh`
`$ ./conf.sh`
Your login and password will be asked, it is the ones you use to connect the usaco website.
Note that the password won't be shown while you enter it.

Use
---

Let's imagine you want to start a problem that usaco website call `ride`.
Go to the directory where you unzipped usacotool.zip

    $ ./new.sh ride
    $ cd ride
    do
      do
        $ vim main.cpp
        Or emacs, gedit or whatever you like. When you are done...
        $ ./s.sh
      while your local tests doesn't work
      $ ./s.sh -s
    while your online test doesn't work

Detailed description
--------------------

* `conf.sh`
> This script change your username and password you use in the usaco website.
> You should call the script at first and everytime you want to change your login or your password.
* `new.sh`
> You can give it the name of the problem used by usaco main page after 'PROGRAM NAME: ' as an argument. It creates your environment for
> this problem downloading the basic input and output file calling inout.py script. It requires an internet connection.
> If you don't specify any argument, it will assume that you want to make the first problem not already solved.
* `s.sh`
> Use it that way

> `$ s.sh [-d] [-s] [<i>]`

> * `-d`
> > Run the tests in debug mode.
> * `-s`
> > Submit the file calling submit.py script. It requires an internet connection.
> > So it can take some time if yours is not good enough.
> * `<i>`
> > Only run the ith test case. By default, it runs all your valid Test cases.

* `config`
> In this file, your name and password you use for the usaco website are stored.
* `inout.py`
> python script called by new.sh. It browses the usaco website with the login and password you've filled in the config file
> and gathers basic input and output examples showed by the main page of the problem. You should not call it yourself.
* `submit.py`
> It browses the usaco website with the login and password you've filled in the config file and submit the main.cpp file in
> the current directory. YOU MUST BE IN THE MAIN DIRECTORY OF A PROBLEM TO CALL THIS SCRIPT. It shows you which test cases you
> have done correctly and which you've failed. If it is the first time you fail a certain case, it records it in known test cases.
> Except if you already have a test case if the same index.
> It requires an internet connection.

Important notes
---------------

`s.sh -s` and `new.sh` require both an internet connection

This tool in in beta, bugs or spelling and grammar mistakes are likely to happen.
Don't blame yourself, it is likely our fault and please report it to us.

New features likely to be in new versions:
A script to create personal test cases probably stored in `test<i>` not to overwrite `Test<i>` which are official test cases
chosen by usaco website

The fields `<...>` in `s.sh` and `main.cpp` should not be replaced by their value manually.
It is done by `new.sh`.

Special thanks
--------------

*Victor Lecomte* and *Floris Kint* for precious help.
