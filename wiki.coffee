showdown = new Showdown.converter()
currentPage = null
pageHistoryModified = false
pageHistory = null

window.save = (editor) ->
	data = currentPage
	$("#page").html showdown.makeHtml data
	document.title = data.substr 0, data.indexOf("\n")
	$("#page a").click ->
		if this.href and this.href.indexOf("static/") < 0
			event.preventDefault()
			location.hash = "##{this.href.replace(location.href.replace(/#.*$/g, ''), '')}"

	$.post "savePage.do?" + location.hash.replace(/^#/, ''), data

window.addImg = (editor) ->
	$("#fileEl").change (e) ->
		uploadFiles this.files, editor

	$("#fileEl").click()

window.addLink = (editor) ->
	url = prompt("Please enter the Link's URL:")
	editor.getDoc().replaceSelection "[#{editor.getDoc().getSelection() or "Link name"}](#{url})", true
	editor.focus()

window.duplicate = (from) ->
	name = prompt "Please enter the duplicate's name:"
	$.get "duplicate.do?from=#{from}&to=#{name}", ->
		location.hash = "##{name}"

window.viewHistory = (editor) ->

uploadFiles = (files, cm) ->
	for file in files
		fr = new FileReader()

		fr.onload = ((file) ->
			return (event) ->
				if event.loaded >= event.total
					xhr = new XMLHttpRequest()
					xhr.open "POST", "upload.do?" + file.name.replace(/[^a-zA-Z0-9_.-]/g, '-')
					xhr.upload.addEventListener "progress", (e) ->
						if e.lengthComputable
							$("div.CodeMirror-gutter.CodeMirror-linenumbers").addClass("loading").css "height: #{Math.round(e.loaded * 100 / e.total)}%;"
					, false

					xhr.onreadystatechange = (e) ->
							if xhr.readyState is 4 and xhr.status is 200
								$("div.CodeMirror-gutter.CodeMirror-linenumbers").removeClass "loading"
								cm.getDoc().replaceSelection "![#{cm.getDoc().getSelection() or file.name}](#{xhr.responseText.replace(/^\s+|\s+$/g, '')})", true
								cm.focus()
					xhr.setRequestHeader "Content-Type", file.type
					xhr.send event.target.result.substr(event.target.result.indexOf(",") + 1)
		)(file)
		fr.readAsDataURL file

window.editPage = ->
	form = document.createElement("form")
	ta = document.createElement("textarea")
	ta.id = "code"
	$(form).append "<div class='toolbar'><button class='save'></button><button class='addImg'></button><button class='addLink'></button><button class='viewHistory'></button></div>"
	form.appendChild ta
	$("#page").html form.outerHTML
	$("#code").val currentPage

	editor = CodeMirror.fromTextArea $("#code")[0],
		mode: 'markdown'
		lineNumbers: true
		autofocus: true
		lineWrapping: true
		theme: "default"
		extraKeys: "Enter": "newlineAndIndentContinueMarkdownList"

	editor.on "change", (doc, changed) ->
		currentPage = doc.getValue()
	editor.on "drop", (cm, event) ->
		event.preventDefault()
		uploadFiles event.dataTransfer.files, cm

	$(".toolbar button").click (e) ->
		e.preventDefault()
		window[this.className](editor, editor)

updateBreadcrumbs = ->
	i = 0
	# clear previous breadcrumbs
	$("#breadcrumbs").html ""
	while i < pageHistory.length
		entry = pageHistory[i]
		link = document.createElement "a"
		link.innerHTML = entry[1]
		link.href = entry[0]
		link.onclick = ((id) ->
			return (event) ->
				pageHistory = pageHistory.slice 0, id
				pageHistoryModified = true
		)(i)
		$("#breadcrumbs").append link
		i++

hashChange = ->
	$("body").addClass "loading"
	path = location.hash.replace /^#/, ''
	frags = path.split /\//
	$.get "getPage.do?#{path}", (data) ->
		$("body").removeClass "loading"
		title = data.substr 0, data.indexOf("\n")
		if not pageHistory
			pageHistory = []
		else if not pageHistoryModified
			if not pageHistory.some((el) -> el[0] is currentHash)
				pageHistory.push [""+currentHash, ""+document.title]
		pageHistoryModified = false
		currentPage = data
		$("#page").html showdown.makeHtml data
		do updateBreadcrumbs
		document.title = title
		window.currentHash = location.hash
		$("#page a").click (event) ->
			if this.href and this.href.indexOf("static/") < 0
				event.preventDefault()
				location.hash = "##{this.href.replace(location.href.replace(/#.*$/g, ''), '')}"

input = document.createElement("input")
input.type = "file"
input.id = "fileEl"
input.multiple = true
input.accept = "image/*"
document.body.appendChild input
input.style.display = "none"

setInterval ->
	if window.currentHash != location.hash
		do hashChange
, 250