import std/uri
import httpclient
import strformat
import json
var word = encodeUrl("ラーメン")

var URL = fmt"http://ja.wikipedia.org/w/api.php?format=json&action=query&list=search&srsearch={word}"

type
  Article = object
    title: string
    snippet: string

var client = newHttpClient()
let res: string = client.getContent(URL)
let resJson: JsonNode = parseJson(res)
echo resJson.pretty
let 
  resStr = to(resJson{"query","search"}, seq[Article])

for article in resStr:
  echo article.title
