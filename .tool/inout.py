#! /usr/bin/python
import mechanize
import re # regular expression
import sys
import os
import time

if not os.path.isfile("../../.tool/config"):
	print 'No config file or not in the good directory.'
	sys.exit(1)
fconfig = open("../../.tool/config", "r")
config = fconfig.read()
user = re.search(r"[ \t]*[\"']user[\"'][ \t]*:[ \t]*[\"'](.*)[\"']", config)
if not user:
	print 'No username specified.'
	sys.exit(1)

password = re.search(r"[ \t]*[\"']password[\"'][ \t]*:[ \t]*[\"'](.*)[\"']", config)
if not password:
	print 'No password specified.'
	sys.exit(1)

desc = input()
try:
	name = raw_input()
except (EOFError):
	name = ""
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

prevl = None
print "Looking for the problem link..."
while not prevl:
	for link in br.links():
		if name == "":
			S = re.search(r"/usaco([a-z]*)2\?a=.*&S=(.*)", link.url)
			if S:
				t = S.group(1)
				s = S.group(2)
				if t == "anal":
					prev = ""
					prevl = None
				elif t == "prob":
					if prevl:
						break
					else:
						prev = s
						prevl = link
		else:
			if re.match(r"/usacoprob2\?a=.*&S={0}".format(name), link.url):
				prevl = link
				break
	if not prevl: # go to previous chapter
		exp = '1'
		prevlink = None
		for link in br.links():
			if re.match(r".*/usacogate\?a=.*&C=[0-9]*", link.url):
				if link.url[-1] != exp: # There is the current chapter between exp and link.url[-1]
					break
				prevlink = link
				exp = chr(ord(link.url[-1])+1)
		if not prevlink:
			break
		br.follow_link(prevlink)

if not prevl:
	if name == "":
		print 'No problem available.'
	else:
		print 'Invalid problem name. Unable to gather input/output files.'
	sys.exit(1)

if name == "":
	ftaskname = open("taskname", "w")
	ftaskname.write(prev)
	ftaskname.close()
	name = prev
print "Downloading problem page..."
br.follow_link(prevl)
fin = open("in", "w")
fout = open("out", "w")

if desc == 1:
	fdesc = open("desc.html", "w")
	print "Gathering task description."
	fdesc.write(br.response().read())

print "Gathering input/output for Test0."
inp = re.search(r"<h3> *SAMPLE INPUT \(file {0}.in\) *</h3>\n*<pre>\n*([^<]*)".format(name), br.response().read())
if inp:
	fin.write(inp.group(1))
else:
	print 'Error, input not found. Check if your inout.py file has not been manually modified. If it hasn\'t, please report this error to the tool\'s developers.'
	sys.exit(1)

out = re.search(r"<h3> *SAMPLE OUTPUT \(file {0}.out\) *</h3>\n*<pre>\n*([^<]*)".format(name), br.response().read())
if out:
	fout.write(re.sub(r"( *\n*)*$", r"\n", re.sub(r"\nOUTPUT DETAILS *:([^0]*0*)*", r"", out.group(1))))
else:
	print 'Error, output not found. Check if your inout.py file has not been manually modified. If it hasn\'t, please report this error to the tool\'s developers.'
	sys.exit(1)

fin.close()
fout.close()
