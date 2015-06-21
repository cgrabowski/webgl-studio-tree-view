{CompositeDisposable} = require 'event-kit'
path = require 'path'

module.exports =
  config:
    hideVcsIgnoredFiles:
      type: 'boolean'
      default: false
      title: 'Hide VCS Ignored Files'
    hideIgnoredNames:
      type: 'boolean'
      default: false
    showOnRightSide:
      type: 'boolean'
      default: false
    sortFoldersBeforeFiles:
      type: 'boolean'
      default: true

  treeView: null

  activate: (@state) ->
    @disposables = new CompositeDisposable
    @state.attached ?= true if @shouldAttach()

    @createView() if @state.attached

    @disposables.add atom.commands.add('atom-workspace', {
      'webgl-studio-tree-view:show': => @createView().show()
      'webgl-studio-tree-view:toggle': => @createView().toggle()
      'webgl-studio-tree-view:toggle-focus': => @createView().toggleFocus()
      'webgl-studio-tree-view:reveal-active-file': => @createView().revealActiveFile()
      'webgl-studio-tree-view:toggle-side': => @createView().toggleSide()
      'webgl-studio-tree-view:add-file': => @createView().add(true)
      'webgl-studio-tree-view:add-folder': => @createView().add(false)
      'webgl-studio-tree-view:duplicate': => @createView().copySelectedEntry()
      'webgl-studio-tree-view:remove': => @createView().removeSelectedEntries()
      'webgl-studio-tree-view:rename': => @createView().moveSelectedEntry()
      'webgl-studio-tree-view:open-project-tree': =>
    })

  deactivate: ->
    @disposables.dispose()
    @treeView?.deactivate()
    @treeView = null

  serialize: ->
    if @treeView?
      @treeView.serialize()
    else
      @state

  createView: ->
    unless @treeView?
      TreeView = require './webgl-studio-tree-view'
      @treeView = new TreeView(@state)
    @treeView

  shouldAttach: ->
    projectPath = atom.project.getPaths()[0]
    if atom.workspace.getActivePaneItem()
      false
    else if path.basename(projectPath) is '.git'
      # Only attach when the project path matches the path to open signifying
      # the .git folder was opened explicitly and not by using Atom as the Git
      # editor.
      projectPath is atom.getLoadSettings().pathToOpen
    else
      true
