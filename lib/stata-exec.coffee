{CompositeDisposable, Point, Range} = require 'atom'

String::addSlashes = ->
  @replace(/[\\"]/g, "\\$&").replace /\u0000/g, "\\0"

apps =
  stata: 'Stata.app'
  statamp: 'StataMP.app'

module.exports =
  config:
    whichApp:
      type: 'string'
      enum: [apps.stata, apps.statamp]
      default: apps.stata
      description: 'Which application to send code to'
    advancePosition:
      type: 'boolean'
      default: false
      description: 'Cursor advances to the next line after ' +
        'sending the current line when there is no selection'
    focusWindow:
      type: 'boolean'
      default: true
      description: 'After code is sent, bring focus to where it was sent'
    notifications:
      type: 'boolean'
      default: true
      description: 'Send notifications if there is an error sending code'

  subscriptions: null

  activate: (state) ->
    @subscriptions = new CompositeDisposable

    @subscriptions.add atom.commands.add 'atom-workspace',
      'stata-exec:send-lines', => @sendLines()
    @subscriptions.add atom.commands.add 'atom-workspace',
      'stata-exec:send-dofile': => @sendDofile()

    # # this is for testing
    # @subscriptions.add atom.commands.add 'atom-workspace',
    #   'stata-exec:test',  => @getCurrentParagraphRange()

    @subscriptions.add atom.commands.add 'atom-workspace',
      'stata-exec:set-stata', => @setStata()
    @subscriptions.add atom.commands.add 'atom-workspace',
      'stata-exec:set-statamp', => @setStataMP()

  deactivate: ->
    @subscriptions.dispose()

  setStata: ->
    atom.config.set('stata-exec.whichApp', apps.stata)
  setStataMP: ->
    atom.config.set('stata-exec.whichApp', apps.statamp)

  _getEditorAndBuffer: ->
    editor = atom.workspace.getActiveTextEditor()
    buffer = editor.getBuffer()
    return [editor, buffer]

  sendLines: ->
    whichApp = atom.config.get 'stata-exec.whichApp'
    [editor, buffer] = @_getEditorAndBuffer()
    # we store the current position so that we can jump back to it later
    # (if the user wants to)
    currentPosition = editor.getLastSelection().getScreenRange().end
    selection = @getSelection(whichApp)
    @sendCode(selection.selection, whichApp)

    advancePosition = atom.config.get 'stata-exec.advancePosition'
    if advancePosition and not selection.anySelection
      nextPosition = @_findForward(@nonEmptyLine, currentPosition.row + 1)
      if nextPosition?
        nextPosition ?= [currentPosition + 1, 0]
        editor.setCursorScreenPosition(nextPosition)
        editor.moveToFirstCharacterOfLine()
    else
      if not selection.anySelection
        editor.setCursorScreenPosition(currentPosition)

  sendCode: (code, whichApp) ->
    switch whichApp
      when apps.stata then @stataConverter(code)
      when apps.stataMP then @stataConverter(code)
      else console.error 'stata-exec.whichApp "' + whichApp + '" is not supported.'


  getSelection: (whichApp) ->
    # returns an object with keys:
    # selection: the selection or line at which the cursor is present
    # anySelection: if true, the user made a selection.
    [editor, buffer] = @_getEditorAndBuffer()

    selection = editor.getLastSelection()
    anySelection = true

    if selection.getText().addSlashes() == ""
      anySelection = false
      # editor.selectLinesContainingCursors()
      # selection = editor.getLastSelection()
      currentPosition = editor.getCursorBufferPosition().row
      selection = editor.lineTextForBufferRow(currentPosition)
    else
      selection = selection.getText()
    if not (whichApp == apps.chrome or whichApp == apps.safari)
      selection = selection.addSlashes()

    {selection: selection, anySelection: anySelection}

  conditionalWarning: (message) ->
    notifications = atom.config.get 'stata-exec.notifications'
    if notifications
      atom.notifications.addWarning(message)

  onlyWhitespace: (str) ->
    # returns true if string is only whitespace
    return str.replace(/\s/g, '').length is 0

  getCurrentParagraphRange: ->
    [editor, buffer] = @_getEditorAndBuffer()
    currentPosition = editor.getCursorBufferPosition().row

    currentLine = buffer.lineForRow(currentPosition)

    if @onlyWhitespace(currentLine)
      return null

    startIndex = -1
    # if we exhaust loop, then this paragraph begins at the first line
    if currentPosition > 0
      for lineIndex in [(currentPosition - 1)..0]
        currentLine = buffer.lineForRow(lineIndex)
        if @onlyWhitespace(currentLine)
          startIndex = lineIndex
          break
    startIndex += 1

    endIndex = editor.getLineCount()
    numberOfLines = editor.getLineCount() - 1
    if currentPosition < endIndex - 1
      for lineIndex in [(currentPosition + 1)..numberOfLines]
        currentLine = buffer.lineForRow(lineIndex)
        if @onlyWhitespace(currentLine)
          endIndex = lineIndex
          break
    endIndex -= 1

    paragraphRange = new Range([startIndex, 0],
      [endIndex, buffer.lineLengthForRow(endIndex)])

    return paragraphRange

  sendDofile: ->
    pass


  stataConverter: (selection) ->
    osascript = require 'node-osascript'
    command = []
    focusWindow = atom.config.get 'stata-exec.focusWindow'
    if focusWindow
      command.push 'tell application "Stata 13.1" to activate'
    command.push 'tell application "Stata 13.1" to cmd code'
    command = command.join('\n')

    osascript.execute command, {code: selection},
      (error, result, raw) ->
        if error
          console.error error
          console.error 'code: ', selection
          console.error 'Applescript: ', command

  stataConverter: (selection) ->
    osascript = require 'node-osascript'
    command = []
    focusWindow = atom.config.get 'stata-exec.focusWindow'
    if focusWindow
      command.push 'tell application "Stata/MP 12.1" to activate'
    command.push 'tell application "Stata/MP 12.1" to cmd code'
    command = command.join('\n')

    osascript.execute command, {code: selection},
      (error, result, raw) ->
        if error
          console.error error
          console.error 'code: ', selection
          console.error 'Applescript: ', command


  getWhichApp: ->
    return atom.config.get 'stata-exec.whichApp'
