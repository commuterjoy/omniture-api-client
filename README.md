
Experimental code to query the [Omniture API](https://developer.omniture.com).

## Quickstart 

You'll need a Omniture username and secret putting in `~/.omniture`

```
{
    "user"      : "<user>",
    "secret"    : "<secret>"
}
```

Then request a report to be generated, 

```
ruby trended 
```

And you should see the _report id_ in the response,

```
{"status":"queued","statusMsg":"Your report has been queued","reportID":143806103}
```

... which you can then download.

```
ruby get_report 143806103; cat reports/143806103 
```
