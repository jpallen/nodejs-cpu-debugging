Debugging Node.js CPU usage with flamegraphs
============================================

This is a quick how-to guide for debugging mysterious CPU usage in your Node.js app. It works with Node 0.10 on Linux, something which I don't think has been documented much, if at all. The idea is to grab a CPU profile of what our app is doing using [v8-profiler](https://github.com/node-inspector/v8-profiler), and then parse the output of that to produce a [flamegraph](https://github.com/brendangregg/FlameGraph) to give us a nice visual representation of what's going on.

Unlike previously documented approaches, you don't need to run your application in profiling mode all the time, and can build in a trigger to take a CPU profile for a few seconds in an already running app. This is much more flexible than [profiling with the `--perf-basic-prof` option](http://www.brendangregg.com/blog/2014-09-17/node-flame-graphs-on-linux.html), which is only available in Node 0.11.13 and higher anyway. This method also doesn't require dtrace, which is not available on Linux systems.

Profiling
---------

To take a CPU profile, use the [v8-profiler](https://github.com/node-inspector/v8-profiler) module:

```sh
$ npm install v8-profiler
```

To create a profiling end point in your Express app, include the following code (coffeescript):

```coffee
profiler = require "v8-profiler"
app.get "/profile", (req, res) ->
	time = parseInt(req.query.time || "1000")
	profiler.startProfiling("test")
	setTimeout () ->
		profile = profiler.stopProfiling("test")
		res.json(profile)
	, time
```

This allows you to profile your app for a configurable amount of time by calling the end point with a parameter for the time to profile in milliseconds:

```sh
$ curl localhost:3000/profile?time=5000 > profile.json
```

*Profiling your app will cause a significant increase in CPU activity and potential slow down. Be careful how you use this, and don't profile for too long.*

Building a Flamegraph
---------------------

Included in this repository is a script which will flatten the JSON output from `profile.json` above into a file which can be read by [FlameGraph](https://github.com/brendangregg/FlameGraph), a tool for plotting interactive SVG flamegraphs.

Usage (requires coffeescript):

```sh
$ git clone git@github.com:brendangregg/FlameGraph.git
$ cat profile.json | coffee stackcollapse.coffee | FlameGraph/flamegraph.pl > flamegraph.svg
```

Now open up flamegraph.svg in your favourite viewer. Each block represents proportion of time spent in a function (including calls to child functions), with the function name and file location labelled. The stacked blocks represent the call stack of nested functions. Happy debugging!