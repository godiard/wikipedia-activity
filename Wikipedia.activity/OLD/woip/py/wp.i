// Copyright (C) 2007, One Laptop Per Child
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
//
// Offline Wikipedia database interface for Python
// (or any other SWIG supported language)
//
// Module functions are prefixed with 'wp_' to avoid clashes with functions
// defined in wp.h.

// Note that the Ruby Inline implementation used a '__' prefix, but that won't
// work in Python as the underscores cause the methods to be treated as private.
//
%module wp

%{
#include "../c/wp.h"

#define MAXRES 40
#define MAXSTR 1024

wp_dump d = {0};
wp_article a = {0};

char results[MAXRES][MAXSTR];
int nresults;

char *__exact_match;
int __got_match;

bool __handle_result(char *s) {
  strncpy(results[nresults], s, MAXSTR);
  results[nresults][MAXSTR - 1] = '\0';
  char *end = strrchr(results[nresults], ' ');

  if(end) {
    *(end - 1) = '\0';
    nresults++;
  }

  return nresults < MAXRES;
}

bool __handle_exact_match(char *s) {
  char buf[MAXSTR], *end;
  strncpy(buf, s, MAXSTR);
  
  debug("handle_exact_match(%s)", s);

  end = strrchr(buf, ' ') - 1;
  *end = '\0';

  if(strcasecmp(buf, __exact_match)) return true;
  else {
    __got_match = 1;
    return false;
  }
}

void wp_load_dump(char *dump, char *loc, char *ploc, char *blocks) {
  load_dump(&d, dump, loc, ploc, blocks);
  init_article(&a);
}

char *wp_load_article(char *name) {
  a.block = 0;
  a.text[0] = '\0';
  load_article(&d, name, &a);
  return a.text;
}

int wp_article_block() {
  return a.block;
}

int wp_article_size() {
  return strlen(a.text);
}

int wp_search(char *needle) {
  nresults = 0;
  search(&d.index, needle, __handle_result, NULL, true, true);
  return nresults;
}

char *wp_result(int n) {
  return results[n];
}

int wp_article_exists(char *name) {
  __exact_match = name;
  __got_match = 0;
  debug("wp_article_exists(%s)", name);
  search(&d.index, name, __handle_exact_match, NULL, false, true);
  return __got_match;
}

%}

void wp_load_dump(char *dump, char *loc, char *ploc, char *blocks);

char *wp_load_article(char *name);
int wp_article_block();
int wp_article_size();

int wp_search(char *needle);
char *wp_result(int n);

int wp_article_exists(char *name);
