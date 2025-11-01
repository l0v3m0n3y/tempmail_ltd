import asyncdispatch, httpclient, json, strutils, htmlparser, xmltree

var cookie: string = ""
const api = "https://tempmail.ltd/"
var token: string = ""
proc create_headers(): HttpHeaders =
  result = newHttpHeaders({
    "Connection": "keep-alive",
    "Host": "tempmail.ltd",
    "Content-Type": "application/json",
    "accept": "application/json, text/plain, */*"
  })
  if cookie != "":
    result["cookie"] = cookie

proc init_cookie*(): Future[void] {.async.} =
  let client = newAsyncHttpClient()
  try:
    client.headers = create_headers()
    let response = await client.get(api)
    let html = await response.body
    let doc = parseHtml(html)
    
    for meta in doc.findAll("meta"):
      let name = meta.attr("name")
      if name == "csrf-token":
        token = meta.attr("content")
        break  # Останавливаем поиск после нахождения токена
    
    if response.headers.hasKey("set-cookie"):
      cookie = response.headers["set-cookie"]
  finally:
    client.close()

proc get_messages*(): Future[JsonNode] {.async.} =
  let client = newAsyncHttpClient()
  try:
    client.headers = create_headers()
    let json= %*{"_token": token}
    let response = await client.post(api & "get_messages",body = $json)
    if response.headers.hasKey("set-cookie"):
      cookie = response.headers["set-cookie"]
    let body = await response.body
    result = parseJson(body)
  finally:
    client.close()

proc delete_email*(): Future[JsonNode] {.async.} =
  let client = newAsyncHttpClient()
  try:
    client.headers = create_headers()
    let json= %*{"_token": token}
    let response = await client.post(api & "delete",body = $json)
    if response.headers.hasKey("set-cookie"):
      cookie = response.headers["set-cookie"]
    let body = await response.body
    result = parseJson(body)
  finally:
    client.close()
