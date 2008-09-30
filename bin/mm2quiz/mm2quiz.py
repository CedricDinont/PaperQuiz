#!/usr/bin/env python
# -*- encoding: utf-8 -*-
#
# Copyright 2007 Scott Kirkwood

"""Convert a Memory Map File into an S5 presentation

If you create a mind map with FreeMind the title of the mind-map (center circle)
will be the title of the slide.

A top level node called "__meta__" can be used to set the metadata for 
the presentation.  The immediate children are keys and it's first child is a value.
  title: Title of presentation, not needed since I get it from the top node
  subtitle: Witty subtitle of the presentation
  author: You probably want to change this.
  company: And this
  template: which subdirectory to use under the "ui" directory, 'default' is default
  presdate: Date of the presentation
  content_type: defaults to 'application/xhtml+xml; charset=utf-8'
  header:
  footer:


If the first character of the first line is a '<' then we won't add 
the the <ul> list to the markup.

The icons can have special meaning:
  The "Not OK" icon the slide will be skipped.
  The "OK' icon will have no additional markup on the text (i.e. no <ul>)
  The "Stop" icon will build the slide one line at a time.
  The "Priority 1" icon will use an ordered list
"""

__author__ = 'scottkirkwood@google.com (Scott Kirkwood)'

import re
import os
import sys
from optparse import OptionParser
import elementtree.ElementTree
import codecs

class Outputs:
  def __init__(self, l, a):
    self.lines = l
    self.answers = a

class Mm2S5:
  def __init__(self):
    self.et_in = None
    self.meta = {
      'title' : 'Title',
      'subtitle': '',
      'author' : 'Your Name',
      'company' : 'Your Company',
      'template' : 'default',
      'presdate' : 'Today',
      'content_type' : 'application/xhtml+xml; charset=utf-8',
      'header' : '',
      'footer' : None,
      'generator' : 'mm2s5.py',
    }
    
  def open(self, infilename, slideshow):
    """ Open the .mm file and create a S5 file as a list of lines """

    infile = file(infilename).read()
    self.et_in = self.xmlparse(infile)
    outputs = self.convert(slideshow)
    return outputs

  def write(self, outfilename, outputs):
    """ Write out the lines, written as a convenience function 
    
    Writing out the HTML in correct UTF-8 format is a little tricky."""
    
    outfile = codecs.open(outfilename, 'w', 'utf-8')
    outfile.write(u'\n'.join(outputs.lines))
    outfile.close()

  def writeanswers(self, answersfilename, outputs):
    """ Write out the answers, written as a convenience function 
    
    Writing out the txt in correct UTF-8 format is a little tricky."""
    
    outfile = codecs.open(answersfilename, 'w', 'utf-8')
    outfile.write(u''.join(outputs.answers))
    outfile.close()

  def xmlparse(self, text):
    """ import the XML text into self.et_in  """
    return elementtree.ElementTree.XML(text)

  def convert(self, slideshow):
    """ Convert self.et_in to a HTML as a list of lines in S5 format """

    self._grab_meta()

    lines = []
    answers = []
    lines.append("""<?xml version="1.0" encoding="UTF-8"?>""")
    lines.append("""<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" 
      "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
        <html xmlns="http://www.w3.org/1999/xhtml">""")
    lines.append('<head>')
    lines.append("""
      <title>%(title)s</title>
      <meta name="version" content="S5 1.1" />
      <meta name="generator" content="%(generator)s" />
      <meta name="presdate" content="%(presdate)s" />
      <meta name="author" content="%(author)s" />
      <meta name="company" content="%(company)s" />
      <meta http-equiv="Content-type" content="%(content_type)s" />
      <!-- S5 format see Eric A. Meyer, http://meyerweb.com/eric/tools/s5/ -->
      <link rel="stylesheet" href="ui/%(template)s/slides.css" type="text/css" 
        media="projection" id="slideProj" />
      <link rel="stylesheet" href="ui/%(template)s/outline.css" type="text/css" x
        media="screen" id="outlineStyle" />
      <link rel="stylesheet" href="ui/%(template)s/print.css" type="text/css" 
        media="print" id="slidePrint" />
      <link rel="stylesheet" href="ui/%(template)s/opera.css" type="text/css" 
        media="projection" id="operaFix" />
      <script src="ui/%(template)s/slides.js" type="text/javascript"></script>
      """ % self.meta)
    lines.append('</head>')
    lines.append('<body>')
    lines.append("""<div class="layout">
        <div id="controls"><!-- DO NOT EDIT --></div>
        <div id="currentSlide"><!-- DO NOT EDIT --></div>
        <div id="header">%(header)s</div>
        <div id="footer">%(footer)s</div>
      </div>""" % self.meta)
    
    lines.append('<div class="presentation">')
    
    presentation = self.et_in.find('node')
    lines.append('  <div class="slide">')
    lines.append('    <h1>%s</h1>' % (self.meta['title']))
    lines.append('    <h2>%s</h2>' % (self.meta['subtitle']))
    lines.append('    <h3>%s</h3>' % (self.meta['author']))
    lines.append('    <h4>%s</h4>' % (self.meta['company']))
    lines.append('  </div>')

    countPage = 0
    for title in presentation.findall('node'):
      # Skip the __meta__ node, if any
      if title.attrib['TEXT'] == '__meta__':
        continue

      attribs = self._get_list_attributes(title)
      if 'skip' in attribs:
        continue

      for page in title.findall('node'):
        attribs = self._get_list_attributes(page)
        if 'skip' in attribs:
          continue

        if slideshow != 0:
          if slideshow not in page.attrib['TEXT']:
            continue

        countPage = countPage + 1

        self._doPage(lines, page, countPage, title.attrib['TEXT'])
        self._doAnswers(answers, page, countPage, title.attrib['TEXT'])
    
    lines.append('</div>') # Presentation
    lines.append('</body>')
    lines.append('</html>')
    return Outputs(lines, answers)


  def _doAnswers(self, answers, page, countPage, title):
    """  answers.append('%s\n' % title) """
    answers.append('%s;' % (countPage))
    children = page.find('node').getchildren()
    answers.append('%d;' % len(children))
    a = []
    self._doTag(a, page, 0)
    answers.append("\\".join(a))
    answers.append(';1;-0.5,1;0\n')


  def _doTag(self, answers, line, answer):
    children = line.findall('node')

    if len(children) == 0:
      attribs =  self._get_list_attributes(line)
      if 'skip' in attribs:
        return

      if 'ok_question' in attribs:
        answers.append('R%d' % answer)
        return

    answer = 1
    for line in children:
      self._doTag(answers, line, answer)
      answer = answer + 1

    return


  def _doPage(self, lines, page, countPage, title):
    lines.append('  <div class="slide">')
    lines.append('    <h1>%s (Q%s)</h1>' % (title, countPage))
    lines.append('    <div class="slidecontent">')
    self._doList(lines, page, 0)
    lines.append('    </div>') # content
    lines.append('  </div>') # slide


  def _get_list_attributes(self, page):
    """ If there's a special icon, return some attributes
      Also, handle HTML markup a bit differently
    """
    ret = {}
    
    for icon in page.findall('icon'):
      type = icon.attrib['BUILTIN']
      if type == 'attach': # No list (attach icon)
        ret['no_ul'] = True
      elif type == 'stop': # Stop light icon
        ret['ul_class'] = "incremental"
      elif type == 'bookmark': # Star icon
        ret['ul_class'] = "multi"
      elif type == 'button_ok': # Ok icon
        ret['ok_question'] = "ans"
      elif type == 'button_cancel':
        ret['skip'] = True
      elif type == 'full-1':
        ret['ol'] = True

    # Special case, if the first node starts with <
    # Then we'll assume markup and not do 
    # a <ul> etc.
    node = page.find('node')
    if node != None and \
      (node.attrib['TEXT'].startswith('<') or 
      node.attrib['TEXT'] == '__table__'):
      ret['no_ul'] = True
    
    return ret
    
  def _grab_meta(self):
    """ Grab a "page" called __meta__, if any """
    
    titles = self.et_in.find('node').attrib['TEXT'].split('\n')
    
    self.meta['title'] = titles[0]
    if len(titles) > 1:
      self.meta['subtitle'] = titles[1]
    for cur_node in self.et_in.getiterator('node'):
      if cur_node.attrib['TEXT'] == '__meta__':
        for sub_attrib in cur_node.findall('node'):
          key = sub_attrib.attrib['TEXT']
          sub_value = sub_attrib.find('node')
          value = sub_value.attrib['TEXT']
          self.meta[key] = value
    
    if self.meta['footer'] == None:
      self.meta['footer'] = '<h1>%(company)s</h2><h2>%(title)s</h2>' % self.meta
    
  def _doList(self, lines, sub, depth):
    """ Recurse this list of items 
    
    Code is a little messier than I would like """
    
    children = sub.findall('node')
    if sub == None or len(sub) == 0 or len(children) == 0:
      return
    
    attribs =  self._get_list_attributes(sub)

    if 'ul_class' in attribs:
      ul_class = ' class="%s"' % (attribs['ul_class'])
    else:
      ul_class = ''
    indent = '  ' * (depth + 2)
    if 'no_ul' not in attribs:
      if 'ol' in attribs:
        lines.append('%s<ol%s>' % (indent, ul_class,))
        end = '%s</ol>' % (indent)
      else:
        lines.append('%s<ul%s>' % (indent, ul_class,))
        end = '%s</ul>' % (indent)
    else:
      end = None

    for line in children:
      attribs_line =  self._get_list_attributes(line)
      if 'skip' in attribs_line:
        continue
      text = line.attrib['TEXT']
      if text == '__table__':
        lines += self._insert_table(text, line, depth)
      else:
        lines += self._insert_line_item(text, line, depth, attribs, attribs_line)
        self._doList(lines, line, depth + 1)
    
    if end:
      lines.append(end)

  def _insert_line_item(self, text, line, depth, attribs, attribs_line):
    """ Insert a line item <li></li> """
    
    indent = '  ' * (depth + 3)
    lines = []
    text = text.replace('<html>', '')
    if 'LINK'in line.attrib:
      text = '<a href="%s">%s</a>' % (line.attrib['LINK'], text)
    

    if 'ok_question' in attribs_line:
      li_class = ' class="%s"' % (attribs_line['ok_question'])
    else:
      li_class = ''

    if 'no_ul' not in attribs:
      text = text.replace('\n', '<br/>\n')
      lines.append('%s<li%s>%s</li>' % (indent, li_class, text))
    else:
      lines.append('%s' % (text))
    
    return lines

  def _insert_table(self, text, line, depth):
    """ If we get a special node called __table__ insert the children
    as rows in a table (descendants are columns in that row) """
    
    lines = []
    indent = '  ' * (depth + 2)
    table = line
    lines.append('%s<table>' % (indent))
    for row in table.findall('node'):
      lines.append('%s  <tr>' % (indent))
      for col in row.getiterator('node'):
        lines.append('%s    <td>%s</td>' % (indent, col.attrib['TEXT']))
        
      lines.append('%s  </tr>' % (indent))
    lines.append('%s</table>' % (indent))
    return lines

def parse_command_line():
    usage = """%prog <mmfile> [<htmloutput>]
Create a FreeMind (.mm) document (see http://freemind.sourceforge.net/wiki/index.php/Main_Page)
the main node will be the title page and the lower nodes will be pages.
"""
    parser = OptionParser(usage)
    (options, args) = parser.parse_args()
    if len(args) == 0:
        parser.print_usage()
        sys.exit(-1)
    
    infilename = args[0]
    if not infilename.endswith('.mm'):
        print "Input file must end with '.mm'"
        parser.print_usage()
        sys.exit(-1)
        
    if len(args) == 1:
        outfilename = infilename.replace('.mm', '.html')
        answersfilename = infilename.replace('.mm', '.txt')
        slideshow = 0
    elif len(args) == 2:
        outfilename = args[1]
        answersfilename = args[1].replace('.html', '.txt')
        slideshow = 0
    elif len(args) == 3:
        outfilename = args[1]
        answersfilename = args[1].replace('.html', '.txt')
        slideshow = args[2]
    else:
        parser.print_usage()
        sys.exit(-1)
    
    mm2s5 = Mm2S5()
    outputs = mm2s5.open(infilename, slideshow)
    mm2s5.write(outfilename, outputs)
    mm2s5.writeanswers(answersfilename, outputs)

if __name__ == "__main__":
    parse_command_line()
