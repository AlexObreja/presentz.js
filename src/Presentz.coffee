class Presentz

  constructor: () ->
    @videoPlugins = [new Vimeo(this), new Youtube(this)]
    @slidePlugins = [new SlideShare()]
    @defaultVideoPlugin = new Html5Video(this)
    @defaultSlidePlugin = new ImgSlide()

  registerVideoPlugin: (plugin) ->
    @videoPlugins.push(plugin)
    return

  registerSlidePlugin: (plugin) ->
    @slidePlugins.push(plugin)
    return

  init: (@presentation) ->
    @howManyChapters = @presentation.chapters.length
    if @presentation.title
      document.title = @presentation.title
    
    @currentChapterIndex = 0

    #agenda
    totalDuration = 0
    totalDuration += parseInt(chapter.duration) for chapter in @presentation.chapters
    widths = computeBarWidths(totalDuration, $("#agendaContainer").width(), @presentation.chapters)
    agenda = ''
    for chapterIndex in [0..@presentation.chapters.length-1]
      agenda += "<div title='#{ @presentation.chapters[chapterIndex].title }' style='width: #{ widths[chapterIndex] }px' onclick='presentz.changeChapter(#{ chapterIndex }, true);'></div>"

    $("#agendaContainer").html(agenda)
    $("#agendaContainer div[title]").tooltip( {effect : "fade", opacity : 0.7})

    videoPlugins = (plugin for plugin in @videoPlugins when plugin.handle(@presentation))
    if videoPlugins.length > 0
      @videoPlugin = videoPlugins[0]
    else
      @videoPlugin = @defaultVideoPlugin

    slidePlugins = (plugin for plugin in @slidePlugins when plugin.handle(@presentation))
    if slidePlugins.length > 0
      @slidePlugin = slidePlugins[0]
    else
      @slidePlugin = @defaultSlidePlugin

    return

  computeBarWidths= (duration, maxWidth, chapters) ->
    ((chapter.duration * maxWidth / duration) - 10 for chapter in chapters)

  changeChapter: (chapterIndex, play) ->
    @currentChapterIndex = chapterIndex
    currentMedia = @presentation.chapters[@currentChapterIndex].media
    @slidePlugin.changeSlide(currentMedia.slides[0])
    @videoPlugin.changeVideo(currentMedia.video, play)
    for index in [1..$("#agendaContainer div").length]
      $("#agendaContainer div:nth-child(#{index})").removeClass("agendaselected")
    $("#agendaContainer div:nth-child(#{chapterIndex + 1})").addClass("agendaselected")

    return

  checkSlideChange: (currentTime) ->
    slides = @presentation.chapters[@currentChapterIndex].media.slides
    candidateSlide = undefined
    for slide in slides
      if slide.time < currentTime
        candidateSlide = slide

    if candidateSlide != undefined and @slidePlugin.isCurrentSlideDifferentFrom(candidateSlide)
      @slidePlugin.changeSlide(candidateSlide)

    return

  startTimeChecker: () ->
    clearInterval(@interval)
    @intervalSet = true
    caller = this
    eventHandler = `function() {
      caller.checkState();
    }`
    @interval = setInterval(eventHandler, 500);
    return

  stopTimeChecker: () ->
    clearInterval(@interval)
    @intervalSet = false
    return

  checkState: () ->
    @checkSlideChange(@videoPlugin.currentTime())
    return

window.Presentz = Presentz