#lang scribble/manual
@(require (for-label scheme/base
                     scheme/gui
                     scheme/contract
                     "main.ss"))

@title{OpenGL World}
@author{@(author+email "Jay McCarthy" "jay@plt-scheme.org")}

OpenGL World is like world, but the rendering functions are in a GL context.

@defmodule[(planet jaymccarthy/gl-world)]

@defproc[(big-bang
          [world/c contract?]
          [init world/c]
          [#:height height (integer-in 0 10000)]
          [#:width width (integer-in 0 10000)]
          [#:on-tick on-tick (world/c . -> . world/c)]
          [#:tick-rate tick-rate number?]
          [#:on-key on-key (world/c (is-a?/c key-event%) . -> . world/c)]
          [#:draw-init draw-init (-> void)]
          [#:on-draw on-draw (world/c . -> . void)]
          [#:stop-when stop-when (world/c . -> . boolean?)]
          [#:stop-timer stop-timer (world/c . -> . boolean?)])
         void]

Creates a @scheme[width] x @scheme[height] window with an OpenGL canvas and calls @scheme[draw-init] in its context to initialize it.
Next @scheme[on-draw] is called in the GL context with @scheme[init] to show the render the first scene. @scheme[init] becomes the current world.

@scheme[big-bang] starts a timer that rings every @scheme[tick-rate] seconds (when @scheme[stop-timer] returns false) and calls @scheme[on-tick] with the current world and expects a new world. When there is user input in the canvas, @scheme[big-bang] calls @scheme[on-key] with the @scheme[key-event%] and expects a new world. In either of these cases, if the returned world is not @scheme[equal?] to the current world then it becomes the current world and @scheme[on-draw] is called to redisplay the scene.

These events occur until @scheme[stop-when] returns @scheme[#t] on the current world.
