# tempmail_ltd
temp email web api tempmail.ltd
# Example
```nim
import asyncdispatch, tempmail_ltd, json
waitFor init_cookie()
let data = waitFor get_messages()
echo data["mailbox"].getStr
let messages = waitFor get_messages()
echo messages["messages"]
```
# Launch (your script)
```
nim c -d:ssl -r  your_app.nim
```
