class SlideShare

  constructor: () ->
    @slideShareInit = false
  
  handle: (presentation) ->
    presentation.chapters[0].media.slides[0].url.toLowerCase().indexOf("http://www.slideshare.net") != -1
    
  changeSlide: (slide) ->
    if $("#slideContainer").children().length == 0
      $("#slideContainer").append("<div id='slidesharecontainer'></div>")
      docId = slide.url.substr(slide.url.lastIndexOf("/") + 1, slide.url.lastIndexOf("#") - 1 - slide.url.lastIndexOf("/"))
      params =
        allowScriptAccess : "always"
      atts = 
        id : "slideshareplayer"
      flashvars = 
        doc: docId
        rel: 0
      
      swfobject.embedSWF("http://static.slidesharecdn.com/swf/ssplayer2.swf", "slidesharecontainer", "598", "480", "8", null, flashvars, params, atts);
    else
    	player = $("#slideshareplayer")[0]
    	nextSlide = slideNumber(slide)
    	currentSlide = player.getCurrentSlide()
    	if nextSlide == (currentSlide + 1)
    		player.next()
    	else
    		player.jumpTo(slideNumber(slide))
    return
    
  isCurrentSlideDifferentFrom: (slide) ->
    player = $("#slideshareplayer")[0]
    if player.getCurrentSlide
      return slideNumber(slide) != player.getCurrentSlide()
    return false
    
  slideNumber= (slide) ->
    parseInt(slide.url.substr(slide.url.lastIndexOf("#") + 1))

