#lang scribble/manual
@(require (for-label racket/base
                     racket/gui
                     racket/contract
                     "main.rkt"))

@title{OpenGL World}
@author{@(author+email "Jay McCarthy" "jay@racket-lang.org")}

OpenGL World is like world, but the rendering functions are in a GL context.

@defmodule[(planet jaymccarthy/gl-world)]

@defproc[(big-bang
          [world/c contract?]
          [init world/c]
          [#:height height (integer-in 0 10000)]
          [#:width width (integer-in 0 10000)]
          [#:on-tick on-tick (world/c . -> . world/c)]
          [#:tick-rate tick-rate (integer-in 0 1000000000)]
          [#:on-key on-key (world/c (is-a?/c key-event%) . -> . world/c)]
          [#:draw-init draw-init (-> void)]
          [#:on-draw on-draw (world/c . -> . void)]
          [#:stop-when stop-when (world/c . -> . boolean?)]
          [#:stop-timer stop-timer (world/c . -> . boolean?)])
         void]

Creates a @racket[width] x @racket[height] window with an OpenGL canvas and calls @racket[draw-init] in its context to initialize it.
Next @racket[on-draw] is called in the GL context with @racket[init] to show the render the first scene. @racket[init] becomes the current world.

@racket[big-bang] starts a timer that rings every @racket[tick-rate] milliseconds (when @racket[stop-timer] returns false) and calls @racket[on-tick] with the current world and expects a new world. When there is user input in the canvas, @racket[big-bang] calls @racket[on-key] with the @racket[key-event%] and expects a new world. In either of these cases, if the returned world is not @racket[equal?] to the current world then it becomes the current world and @racket[on-draw] is called to redisplay the scene.

These events occur until @racket[stop-when] returns @racket[#t] on the current world.
