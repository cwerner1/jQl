
jQl =
    ###
    the ready function that collect calls and put it in the queue
    ###
    ready: (f) ->
        jQl.q.push f if typeof f is "function"
        jQl
        
    ###
    unqueue function
    run all queues inline calls
    in the right order and purge the queue
    ###   
    unq: ->
        jQl.q[i]() for i in [0..jQl.q.length]
        jQl.q=[]
        
    ###
    boot function
    call it after calling jQuery in order to wait it's loaded
    or use it in onload='' on script defer/async element
    
    @param function callback
    a callback to call after jQuery is loaded
    
    ###
    bId: null
    
    boot: (callback) ->
        
        if typeof window.jQuery.fn is "undefined"
            unless jQl.bId
                jQl.bId = setInterval(->
                    jQl.boot callback
                , 25)
            true
            
        clearInterval jQl.bId if jQl.bId
        jQl.bId = 0
        # OK, Jquery is loaded
        # We can load additional JQuery dependents modules
        jQl.unqjQdep()
        
        # then unqueue all inline calls
	# (when document is ready)

        $ jQl.unq()
        callback() if typeof callback is "function"
    
    booted: ->
        jQl.bId ==0
        
    ###
    load jQuery script asynchronously in all browsers
    by delayed dom injection
    @param strinc src
      jQuery url to use, can be a CDN hosted,
    or a compiled js including jQuery
    ###
        
    loadjQ: (src,callback) ->
        setTimeout( ->
            s = document.createElement 'script'
            s.src = src
            document.getElementsByTagName('head')[0].appendChild s
        ,1)
        jQl.boot callback
        
    ###
    load a jQuery-dependent script
    parallel loading in most browsers by xhr loading and injection
    the jQ-dependant script is queued or run when loaded,
    depending of jQuery loading state
    ###
    
    loadjQdep:(src) ->
        jQl.loadxhr src, jQl.qdep
    
    ###
    queue jQuery-dependent script if download finish before jQuery loading
    or run it directly if jQuery loaded, and previous loaded modules are run
    (preserve initial order)

    @param string txt
        the js script to inject inline in dom
    @param string src
        the source url of the script, not used here
    ###  
     
    qdep: (txt,src) ->
        if txt
            if typeof window.jQuery.fn isnt "undefined" and not jQl.dq.length
                jQl.rs txt
            else
                jQl.dq.push txt

    ###
    dequeue jQuery-dependent modules loaded before jQuery
    call once only
    ###
    unqjQdep: ->
        if typeof window.jQuery.fn is "undefined"
          setTimeout jQl.unqjQdep, 50
          true
        jQl.rs jQl.dq[i] for i in [0..jQl.dq.length]
        jQl.dq = []
        
        
    ###
     run a text script as inline js
     @param string txt
       js script
     @param string src
       original source of the script (not used here)
    ###
    
    
    rs: (txt,src) ->
        se = document.createElement 'script'
        document.getElementsByTagName('head')[0].appendChild se
        se.text= txt
        
    ###
    multi-browsers XHr loader,
    credits http://www.stevesouders.com/blog/2009/04/27/loading-scripts-without-blocking/
    ###
    
    loadxhr: (src,callback) ->
        xoe= jQl.getxo()
        xoe.onreadystatechange = ->
            return true if xoe.readyState isnt 4 or 200 isnt xoe.status
            callback xoe.responseText, src
            
        try
            xoe.open 'GET',src,true
            xoe.send ''
        catch e
        
    ###
    facilitie for XHr loader
    credits http://www.stevesouders.com/blog/2009/04/27/loading-scripts-without-blocking/
    ###
    
    getxo: ->
        xhrObj = false
        try
            xhrObj = new XMLHTTPRequest()
        catch e
            progid = [ "MSXML2.XMLHTTP.5.0", "MSXML2.XMLHTTP.4.0", "MSXML2.XMLHTTP.3.0", "MSXML2.XMLHTTP", "Microsoft.XMLHTTP" ]
            

            for i in [0..progid.length]
                try
                    xhrObj = new ActiveXObject(progid[i])
                catch e
                    continue
                break
        finally
            return xhrObj
            
            
###
 
  map $ and jQuery to the jQl.ready() function in order to catch all
  inline calls like :
  $(function(){...})
  jQuery(function(){...})
  $('document').ready(function(){...})
  jQuery('document').ready(function(){...})
 
  only if jQuery is not already loaded
###
if typeof window.jQuery is "undefined"
    $ = jQl.ready
    jQuery = $