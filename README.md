
Experimental code to query the [Omniture API](https://developer.omniture.com).

## Quickstart 

You'll need a Omniture username and secret putting in `~/.omniture`

```
{
    "user"      : "<user>",
    "secret"    : "<secret>"
}
```

Then make sure you've got all the ruby packages,

```
bundle install
```

Then request an Omniture report to be generated,

```
./bin/clickstream -d "Gallery:swipe" 
```

And you should see the _report id_ in the response,

```
{"status":"queued","statusMsg":"Your report has been queued","reportID":143806103}
```

... which you can then download.

First check the queue,

```
./bin/queue 
```

Then once your job has been completed you can fetch it,

```
./bin/get_report 143806103;
```

# Reports 

## Clickstream

The responsive Guardian site uses the Navigation Interaction Type property (v37) to capture clicks and other user interface events. 

You can generate a clickstream report for this data like so,

```
./bin/clickstream -d "Gallery:swipe"
```

Likewise, to generate a report for multiple properties you can comma separate the values,

```
./bin/clickstream -d "social-fb,social-gplus,social-twitter"
```

## Author 

Ultimately you can generate a report for any page, tag, section and so on. For demonstrative purposes I've included a command-line tool to generate
data about any give author.

```
./bin/author -d "Charlie Brooker"
```

## KPIs

A standard report containing pageViews, visits, visitors, averageTimeSpentOnSite, averageVisitDepth, visitorsNew can be generated,

```
./bin/kpis
```

# Queue

When you request a report Omniture adds it to a job queue.

You can view the queue with the _queue_ command,

```
./bin/queue
```

# Reports

I've included a rudimentary tool to extract data from the Omniture reports,

So,

```
./bin/report-to-text < reports/144084986
```

Yields,

```
2013-05-02T00:00:00Z     63
2013-05-02T01:00:00Z     30  <-- 30 instances of this metric at 1am, 2 May
2013-05-02T02:00:00Z     41
2013-05-02T03:00:00Z     32
2013-05-02T04:00:00Z     26
2013-05-02T05:00:00Z     16
2013-05-02T06:00:00Z     43
2013-05-02T07:00:00Z     65
2013-05-02T08:00:00Z     59
...
```

# Notes

- Omniture's REST API is authenticated by the SOAP [WS-Security standard](http://en.wikipedia.org/wiki/WS-Security)
