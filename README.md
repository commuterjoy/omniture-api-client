
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
ruby clickstream -d "Gallery:swipe" 
```

And you should see the _report id_ in the response,

```
{"status":"queued","statusMsg":"Your report has been queued","reportID":143806103}
```

... which you can then download.

First check the queue,

```
ruby queue 
```

Then once your job has been completed you can fetch it,

```
ruby get_report 143806103; cat reports/143806103 
```

# Reports 

## Clickstream

```
ruby clickstream -d "Gallery:swipe"
```

```
ruby clickstream -d "social-fb,social-gplus,social-twitter"
```

## Author 

```
ruby author -d "Charlie Brooker"
```

# Queue

When you request a report Omniture adds it to a job queue.

You can view the queue with the _queue_ command,

```
ruby queue
```

# Reports

I've included a rudimentary tool to extract data from the Omniture reports,

So,

```
ruby tools/report-to-text < reports/144084986
```

Yields,

```
Thu.  2 May 2013 0   4437 
Thu.  2 May 2013 1   2594  <-- 2,594 instances of this metric at 1am, 2 May
Thu.  2 May 2013 2   2462
Thu.  2 May 2013 3   2713
Thu.  2 May 2013 4   2667
Thu.  2 May 2013 5   2420
Thu.  2 May 2013 6   4049
...
```

# Notes

- Omniture's REST API is authenticated by the SOAP [WS-Security standard](http://en.wikipedia.org/wiki/WS-Security)


