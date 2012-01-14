#! /usr/bin/env python

import mechanize
import re # regular expression
import os
import sys

if not os.path.isfile("../.tool/config"):
	print 'No config file or not in the good directory.'
	sys.exit()
fconfig = open("../.tool/config", "r")
config = fconfig.read()
user = re.search(r"[ \t]*[\"']user[\"'][ \t]*:[ \t]*[\"'](.*)[\"']", config)
if not user:
	print 'No username specified.'
	sys.exit()

password = re.search(r"[ \t]*[\"']password[\"'][ \t]*:[ \t]*[\"'](.*)[\"']", config)
if not password:
	print 'No password specified.'
	sys.exit()

br = mechanize.Browser()

print "Opening the main page..."
br.open('http://ace.delos.com/usacogate')

br.select_form(nr=0)
br['NAME'] = user.group(1)
br['PASSWORD'] = password.group(1)
print "Entering the name/password combination..."
br.submit()
if br.title() == "USACO Training Program Gateway":
	print 'The name/password combination is invalid. Change it in the config file.'
	sys.exit(1)

br.select_form(nr=1)
br.form.add_file(open("main.cpp"), "text/plain", "main.cpp")
print "Submitting..."
br.submit()

s = br.response().read()
q = re.search(r"<div style=background-color:white;padding:5px;><pre>(([^<]|<[^/]|</[^d])*)", s).group(1)
r = re.sub(r"</?b>", r"", q)
print re.sub(r"\n*$", r"", re.search(r"[^<]*", r).group(0))
error = re.search(r"</pre><table bgcolor='#FFDCEC' cellspacing=8><tr><td><pre>  &gt; ([^<]*)", r)
if error:
	print '   > ', error.group(1)
	n = re.search(r"[0-9]+", error.group(1)).group(0)
	if not os.path.exists("./Test{0}".format(n)):
		os.makedirs("./Test{0}".format(n))
	testinput = open("Test{0}/in".format(n), "w")
	testoutput = open("Test{0}/out".format(n), "w")
	for link in br.links():
		if re.search(r"^/usacodatashow\?a=", link.url):
			break
	print "Gathering input..."
	br.follow_link(link)
	testinput.write(br.response().read())
	br.back()
	for link in br.links():
		if re.search(r"^/usacodatashow\?a=.*&i=out$", link.url):
			break
	print "Gathering output..."
	br.follow_link(link)
	testoutput.write(br.response().read())
	testinput.close()
	testoutput.close()
