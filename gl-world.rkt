#lang racket/gui
(require sgl)

(define world-canvas%
  (class canvas%
    (init-field world on-key on-draw draw-init stop-when stop! timer stop-timer timer-rate)
    (init width height)
    
    (super-new)
    
    (define dc (send this get-dc))
    (define gl-ctx (send dc get-gl-context))
    
    (send gl-ctx call-as-current
          (lambda ()
            (draw-init)
            (send gl-ctx swap-buffers)))
    
    (define/public (update-world new-world)
      (cond
        [(equal? world new-world)
         (void)]
        [(stop-when new-world)
         (stop!)]
        [else
         (local [(define pre-timer (stop-timer world))
                 (define post-timer (stop-timer new-world))]
           (unless (eq? pre-timer post-timer)
             (if post-timer
                 (send timer stop)
                 (send timer start timer-rate)))               
           (set! world new-world)             
           (send this refresh))]))
    
    (define/override (on-char event)
      (update-world (on-key world event)))
    
    (define/override (on-paint)
      (send gl-ctx call-as-current
            (lambda ()
              (on-draw world)
              (gl-flush)
              (send gl-ctx swap-buffers))))))

(define world-frame%
  (class frame%
    (init-field stop!)
    
    (define/augment (on-close)
      (stop!))
    
    (super-new)))

(define (big-bang world/c init 
                  #:height height
                  #:width width
                  #:on-tick the-on-tick
                  #:tick-rate timer-rate
                  #:on-key the-on-key
                  #:draw-init the-draw-init
                  #:on-draw the-on-draw
                  #:stop-when the-stop-when
                  #:stop-timer the-stop-timer)      
  
  (define (stop!)
    (send timer stop)
    (send canvas enable #f)
    (send frame enable #f)
    (send frame show #f))
  
  (define frame 
    (new world-frame% 
         [label ""]
         [stop! stop!]
         [min-width width]
         [min-height height]
         [stretchable-width #f]
         [stretchable-height #f]
         [style '(no-resize-border metal)]))
  
  (define timer
    (new timer%
         [notify-callback
          (lambda ()
            (when (object? canvas)
              (send canvas update-world (the-on-tick (get-field world canvas)))))]
         [interval timer-rate]))
  
  (define canvas
    (new world-canvas% 
         [world init]
         [on-key the-on-key]
         [draw-init the-draw-init]
         [on-draw the-on-draw]
         [stop-when the-stop-when]
         [stop-timer the-stop-timer]
         [timer timer]
         [timer-rate timer-rate]
         [stop! stop!]
         [parent frame]
         [width width]
         [height height]
         [style '(no-autoclear)]))
  
  (send canvas focus)
  (send frame center)
  (send frame show #t)
  
  (call-with-exception-handler
   (lambda (x)
     ((error-display-handler) (exn-message x) x))
   (lambda ()      
     (yield 'wait))))

(provide/contract
 [big-bang (->d ([world/c contract?]
                 [init world/c]
                 #:height [height (integer-in 0 10000)]
                 #:width [width (integer-in 0 10000)]
                 #:on-tick [the-on-tick (world/c . -> . world/c)]
                 #:tick-rate [tick-rate (integer-in 0 1000000000)]
                 #:on-key [the-on-key (world/c (is-a?/c key-event%) . -> . world/c)]
                 #:draw-init [the-draw-init (-> void)]
                 #:on-draw [the-on-draw (world/c . -> . void)]
                 #:stop-when [the-stop-when (world/c . -> . boolean?)]
                 #:stop-timer [the-stop-timer (world/c . -> . boolean?)])
                ()
                [_ void])])
