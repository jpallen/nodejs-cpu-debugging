Node.js Flamegraphs
===================

Flamegraphs help to debug CPU usage problems by showing which functions and call stacks are responsible for using CPU time. The method described below
works out of the box with Node 0.10. You don't need to run your application in profiling mode all the time, and can build in a trigger to take a CPU profile
if and when you hit CPU issues. This is much more flexible than [profiling with the `--perf-basic-prof` option](http://www.brendangregg.com/blog/2014-09-17/node-flame-graphs-on-linux.html), which is only available in Node 0.11.13 and higher anyway. It also doesn't require dtrace, which is not available on Linux systems.

Profiling
---------

To take a CPU profile, use the [v8-profiler](https://github.com/node-inspector/v8-profiler) module:

```
npm install v8-profiler
```

To create a profiling end point in your Express app, include the following code (coffeescript):

```
profiler = require "v8-profiler"
app.get "/profile", (req, res) ->
	time = parseInt(req.query.time || "1000")
	profiler.startProfiling("test")
	setTimeout () ->
		profile = profiler.stopProfiling("test")
		res.json(profile)
	, time
```

This allows you to profile your app for a configurable amount of time by calling the end point with the time to profile in milliseconds:

```
curl localhost:3000/profile?time=5000 > profile.json
```

*Profiling your app will cause a significant increase in CPU activity and potential slow down. Be careful how you use this, and don't profile for too long.*

Building a Flamegraph
---------------------

Included in this repository is a script which will flatten the JSON output from `profile.json` above into a file which can be read by [FlameGraph](https://github.com/brendangregg/FlameGraph), a tool for plotting interactive SVG flamegraphs.

Usage (requires coffeescript):

```
git clone git@github.com:brendangregg/FlameGraph.git
cat profile.json | coffee stackcollapse.coffee | FlameGraph/flamegraph.pl > flamegraph.svg
```

Now open up flamegraph.svg in your favourite viewer. Happy debugging!