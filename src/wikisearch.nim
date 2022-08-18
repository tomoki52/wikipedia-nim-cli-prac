const doc = """
Usage: 
  wikisearch <word> [--sort=[sort]] [-r | --reverse] [--limit=<limit>]

Options:
  <word>          Search word
  --sort=<sort>   Sort by pageid/wordcount [default: pageid]
  -r --reverse    Sort by asc
  --limit=<limit> Limit to display [default: 10]
"""

import std/uri
import httpclient
import strformat
import json
import docopt
import algorithm
import strutils
import sequtils

type
  Sort = enum
    pageid,
    wordcount,

type
  Article = object
    title: string
    snippet: string
    pageid: int
    wordcount: int
type
  SearchInfo = object
    totalhits: int
type
  WikiArticle = object
    searchinfo: SearchInfo
    search: seq[Article]
proc searchArticle(word: string, sort: Sort, order: SortOrder, limit: int): WikiArticle =
  let
    qWord: string = encodeUrl(word)
    qSort: string = $sort
    qLimit: int = limit

    url = fmt"http://ja.wikipedia.org/w/api.php?format=json&action=query&list=search&srsearch={qWord}&srlimit={qLimit}"
    content = newHttpClient().getContent(url)
  #echo parseJson(content).pretty 
  result = to(parseJson(content){"query"}, WikiArticle)

proc main = 

  let
    args = docopt(doc, version= "0.1.0")
    word: string = $args["<word>"]
    sort: Sort = parseEnum[Sort]($args["--sort"])
    order: SortOrder = if args["--reverse"]: SortOrder.Ascending else: SortOrder.Descending
    limit: int = if args["--limit"]: parseInt($args["--limit"]) else: 10

  let serchResult = searchArticle(word, sort, order, limit)
  echo "totalhits:", serchResult.searchinfo.totalhits
  echo"[title] pageid"
  echo serchResult
    .search
    .map(proc(a: Article): string = fmt"[{a.title}] {a.pageid}")
    .join("\n")



main()
