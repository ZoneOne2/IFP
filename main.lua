function love.load()

	exit=false
	require "JLib"
	
	init()

	--definition of Portal object
	Portal = {

		id = 0,
		x=0, y=0, 
		title="untitled portal", 
		inFields={}, 
		isAnchor = false, 
		anchorLevel = 0,
		tipAccess = false,
		inLinks={},

	 }
	function Portal:new(o)

		totalPortals = totalPortals+1

		o = o or {}
		setmetatable(o, self)
		self.__index = self
		o.id = #portals+1
		o.inFields = {}
		o.inLinks = {}
		return o

	 end
	totalAnchors = 0
	totalPortals = 0

	--definition of Field object
	Field = {

		id = 0,
		anchorPortals = {}, 
		containsPortals = {}, 
		level = 0, 
		area = 0,
		fieldType = "unassigned",
		isParent = false,
		tail = nil,
		wing1 = nil,
		wing2 = nil,
		tailCompleted = false,
		wing1Completed = false,
		wing2Completed = false,
		links = {},
		tipPortal = nil,

	 }
	function Field:new(o)

		totalFields = totalFields+1

		o = o or {}
		setmetatable(o,self)
		self.__index = self
		o.id = #fields+1
		o.anchorPortals = {}
		o.containsPortals = {}
		o.links = {}
		--o:setPortalsInside()
		return o

	 end
	function Field:setPortalsInside()

		for i, portal in pairs(portals) do

			if(portal.anchorLevel ~= self.level) then

				if (isInside(portal,self.anchorPortals)) then

					table.insert(self.containsPortals,portal)
					table.insert(portal.inFields,self)

				 end

			 end

		 end

	 end
	totalFields = 0

	--definition of Link object
	Link = {

		id = 0,
		level = 0,
		ends = {},
		isMade = false,
		mid = {},

	 }
	function Link:new(o)

		totalLinks = totalLinks+1

		o = o or {}
		setmetatable(o,self)
		self.__index = self
		o.id = #links+1
		objectTableSort(self.ends,"id")
		o.mid = {x=findMid(o.ends[1],o.ends[2])[1], y=findMid(o.ends[1],o.ends[2])[2]}
		table.insert(o.ends[1].inLinks,o)
		table.insert(o.ends[2].inLinks,o)
		return o

	 end 
	totalLinks = 0
	linksMade = 0

	portals = {}
	fields = {}
	links = {}


	mode = "place"
	--fieldQueue = {}
	--linkQueue = {}
	--priorityField = nil

	temp = 0

	possibleLinks = {}
	outsidePortals = {}

	selectedAnchor = nil
	anchorLinks = {}

	fieldOrder = {}

 end

function love.draw()

	lg.push()
		lg.scale(1,-1)
		lg.translate(window.width/2,-window.height/2)
		lg.setLineJoin("none")
		lg.setLineWidth(1)

		drawGrid(100)
		lg.circle("fill",0,0,4)


		if (mode == "place") then

			setHexColor(white)
			for i, portal in pairs(portals) do

				if(portal == closestPortal) then

					setHexColor(red)
					lg.circle("fill",portal.x,portal.y,4)

				 end

				setHexColor(white)
				lg.circle("fill",portal.x,portal.y,3)

			 end
		 end

		if (mode == "anchors") then

			setHexColor(white)
			for i, portal in pairs(portals) do

				lg.circle("fill",portal.x,portal.y,3)

			 end


			setHexColor(red)

			for i, portal in pairs(outsidePortals) do

				lg.push()
				lg.translate( portal.x,portal.y )
				lg.scale(1,-1)
					lg.print( i, 0,0 )
				lg.pop()


			end

			for i, link in pairs(links) do

				setHexColor(white)

				pointLine(link.ends)

			 end


		 end

		if (mode == "anchorLinks") then

			
			setHexColor(white)
			for i, portal in pairs(portals) do

				if((portal==closestPortal or portal==selectedPortal)and portal.isAnchor) then

					setHexColor(red)
					lg.circle("fill",portal.x,portal.y,4)

				 end

				setHexColor(white)
				if(portal ~= selectedPortal) then
					lg.circle("fill",portal.x,portal.y,3)
				end

			 end


			for i, field in pairs(fields) do

				lg.setColor(HEXtoDEC("00"),HEXtoDEC("7b"),HEXtoDEC("a7"),200)
				pointPolygon("fill",field.anchorPortals)

			end

			for i, link in pairs(links) do

				setHexColor(white)

				pointLine(link.ends)

				setHexColor(red)
				lg.push()
				lg.translate( unpack(findMid( link.ends[1] , link.ends[2] )) )
				lg.scale(1,-1)
					lg.print( link.id, 0,0 )
				lg.pop()

			 end


		 end
		
		if (mode == "field") then

			setHexColor(white)
			
			for i, field in pairs(fields) do

				lg.setColor(HEXtoDEC("00"),HEXtoDEC("7b"),HEXtoDEC("a7"),200*(1/10))
				pointPolygon("fill",field.anchorPortals)

				if (field.fieldType == "tail") then
					lg.setColor(255,0,0,255)
				elseif (field.fieldType == "wing") then
					lg.setColor(0,255,0)
				else
					lg.setColor(HEXtoDEC("00"),HEXtoDEC("7b"),HEXtoDEC("a7"),255)
				end
				pointPolygon("line",field.anchorPortals)

			 end

			for i, portal in pairs(portals) do

				if(portal == closestPortal and not portal.isAnchor) then

					setHexColor(red)
					lg.circle("fill",portal.x,portal.y,4)

				 end

				if (portal.isAnchor) then
					setHexColor(cerulean)
				 else
					setHexColor(white)
				 end
				lg.circle("fill",portal.x,portal.y,3)

			 end

			if (not closestPortal.isAnchor) then

				lg.setColor(HEXtoDEC("00"),HEXtoDEC("7b"),HEXtoDEC("a7"),255)

				for i, anchor in pairs(currentField.anchorPortals) do

					pointLine({{x=closestPortal.x,y=closestPortal.y}},{{x=anchor.x,y=anchor.y}})

				 end

			 end

			--[[for i, link in pairs(links) do

				setHexColor(white)
				--lg.setLineWidth(3)

				pointLine(link.ends)

				setHexColor(red)
				lg.push()
				lg.translate( unpack(findMid( link.ends[1] , link.ends[2] )) )
				lg.scale(1,-1)
					lg.print( link.id, 0,0 )
				lg.pop()

			 end]]

		 end

		if (mode == "link") then
			
			setHexColor(white)
			
			for i, field in pairs(fields) do

				lg.setColor(HEXtoDEC("00"),HEXtoDEC("7b"),HEXtoDEC("a7"),200*(1/10))
				pointPolygon("fill",field.anchorPortals)

				if (field.fieldType == "tail") then

					lg.setColor(255,0,0,255)

				elseif (field.fieldType == "wing") then

					lg.setColor(0,255,0)

				else

					lg.setColor(HEXtoDEC("00"),HEXtoDEC("7b"),HEXtoDEC("a7"),255)

				end

				

				pointPolygon("line",field.anchorPortals)

				
				if (field == priorityField) then

					lg.setColor(255,0,0,255)
					pointPolygon("fill",field.anchorPortals)

				 end

			end


			setHexColor(cerulean)
			for i, portal in pairs(portals) do

				lg.circle("fill",portal.x,portal.y,3)

			end


			for i, link in pairs(links) do

				setHexColor(white)
				--lg.setLineWidth(3)

				lg.push()
				lg.translate( unpack(findMid( link.ends[1] , link.ends[2] )) )
				lg.scale(1,-1)
					lg.print( link.id, 0,0 )
				lg.pop()

			 end

		 end

		
		drawButtons()
	
	 lg.pop()

 end

function love.update(dt)
	
	jupdate(dt)
	
	if #portals >0 then
		closestPortalID = findClosestPoint(mouse,portals)
		closestPortal = closestPortalID[1][closestPortalID[2]]
		currentField = closestPortal.inFields[#closestPortal.inFields]
	end

	if (mode == "link" and not isCompleted(fieldOrder[#fieldOrder])) then
		for i, field in pairs(fieldOrder) do
			print("makingLinks"..i)
			love.timer.sleep(2)
			makeField(field)
			print("field "..i.." is completed.")
		end

	 end

	
 end

function love.focus(bool)

 end

function love.keypressed( key, unicode )
	
	if key == "`" then
		debug.debug()
	end
	
	if (mode == "place") then

		if key == "/" then
			testFunc()
		end

		if key == "return" then
			setAnchorPortals()
			mode = "anchorLinks"
			--print("Select 3 main outside portals")
		end

	end

	if (mode == "field") then

		--

	end

	if (mode == "link") then

		if key == "return" then

			--

		end

	end

	if (mode == "temp") then

		if key == "return" then

			--

		end

	end

 end

function love.keyreleased( key, unicode )
 
 end

function love.mousepressed( x, y, button )

	if (mode == "place") then

		if button == "l" then
			table.insert(portals,Portal:new{x=mx,y=my})
		 end

	 end

	if (mode == "anchors") then

		if button == "l" then
			--setAnchorPortals()
		 end

		if button == "r" then
			
		 end

		if button == "m" then
			
		 end

	 end

	if (mode == "anchorLinks") then

		if button == "l" then

			if (closestPortal.isAnchor) then

				if (selectedPortal == nil) then
					selectedPortal = closestPortal
				elseif(closestPortal == selectedPortal) then
					selectedPortal = nil
				else

					local crossesLink = false

					for i, link in pairs(links) do

						if (findIntersect(link.ends,{selectedPortal,closestPortal},false)==true) then
							crossesLink = true
						end

					 end

					if (not crossesLink) then

						table.insert(links,Link:new{level = 1, ends = {selectedPortal,closestPortal} })
						

						for i, portal in pairs(outsidePortals) do

							if (not isInTable(portal,links[#links].ends)) then

								local allEnds = {}
								local allPortals = {}

								for i, link in pairs(portal.inLinks) do
									table.insert(allEnds,link.ends[1])
									table.insert(allEnds,link.ends[2])
								end

								if (isInTable(selectedPortal,allEnds) and isInTable(closestPortal,allEnds)) then
									table.insert(fields,Field:new{level = 1, fieldType = "main"})

									table.insert(fields[#fields].anchorPortals,portal)
									table.insert(fields[#fields].anchorPortals,selectedPortal)
									table.insert(fields[#fields].anchorPortals,closestPortal)

									allPortals = {portal,selectedPortal,closestPortal}
									for i, link in pairs(portal.inLinks) do
										if ( isInTable(link.ends[1],allPortals) and isInTable(link.ends[2],allPortals) ) then
											table.insert(fields[#fields].links,link)
										end
									end
									table.insert(fields[#fields].links,links[#links])

									fields[#fields]:setPortalsInside()
								end

							 end

						 end

						selectedPortal = nil

						if (#fields == (#outsidePortals-2)) then
							setFieldTips()
							mode = "field"
						end

					 end

				 end



			 end


		 end

		if button == "r" then
			
		 end

		if button == "m" then
			
		 end

	 end

	if (mode == "field") then

		if button == "l" then
			
			if (not closestPortal.isAnchor) then

				closestPortal.isAnchor = true
				closestPortal.anchorLevel = currentField.level+1
				closestPortal.tipAccess = true
				totalAnchors = totalAnchors+1

				local sidePortals = {}

				for i, portal in pairs(currentField.anchorPortals) do
					if (currentField.tipPortal ~= portal) then
						table.insert(sidePortals,portal)
					end
				end
				if (#sidePortals ~= 2) then error("side portals = "..#sidePortals) end


				currentField.isParent = true

				table.insert(fields,Field:new{level = closestPortal.anchorLevel, fieldType = "wing", tipPortal = currentField.tipPortal})
				table.insert(fields[#fields].anchorPortals,closestPortal)
				table.insert(fields[#fields].anchorPortals,currentField.tipPortal)
				table.insert(fields[#fields].anchorPortals,sidePortals[1])
				fields[#fields]:setPortalsInside()
				currentField.wing1 = fields[#fields]

				table.insert(fields,Field:new{level = closestPortal.anchorLevel, fieldType = "wing", tipPortal = currentField.tipPortal})
				table.insert(fields[#fields].anchorPortals,closestPortal)
				table.insert(fields[#fields].anchorPortals,currentField.tipPortal)
				table.insert(fields[#fields].anchorPortals,sidePortals[2])
				fields[#fields]:setPortalsInside()
				currentField.wing2 = fields[#fields]

				table.insert(fields,Field:new{level = closestPortal.anchorLevel, fieldType = "tail", tipPortal = closestPortal})
				table.insert(fields[#fields].anchorPortals,closestPortal)
				table.insert(fields[#fields].anchorPortals,sidePortals[1])
				table.insert(fields[#fields].anchorPortals,sidePortals[2])
				fields[#fields]:setPortalsInside()
				currentField.tail = fields[#fields]


				table.insert(links,Link:new{level = currentField.level+1, ends = {closestPortal,currentField.tipPortal} })
				table.insert(links,Link:new{level = currentField.level+1, ends = {closestPortal,sidePortals[1]} })
				table.insert(links,Link:new{level = currentField.level+1, ends = {closestPortal,sidePortals[2]} })


				if (totalAnchors == totalPortals) then

					print("All fields linked.")
					setFieldLinks()
					--table.insert(fieldQueue,fields[1])
					--setPriorityField()
					--print("Field priority is now Field "..priorityField.id)
					mode = "link"

				 end

			 end

		 end

		if button == "r" then
			
		 end

		if button == "m" then
			
		 end

	 end
	
	if (mode == "link") then

		if button == "l" then

		 end

		if button == "r" then
			
		 end

		if button == "m" then
			
		 end

	 end

	if (mode == "temp") then

		if button == "l" then
			
		 end

		if button == "r" then
			
		 end

		if button == "m" then
			
		 end

	 end

 end

function love.mousereleased( x, y, button )

 end

function love.quit()

 end

function setButtons()

	buttons = {}
	
	--shape: rectangle, circle, or polygon
		--rectangle:
			--x: top-left corner x-coordinate
			--y: top-left corner y-coordinate
			--width: button width
			--height: button height
		--circle:
			--x: center x-coordinate
			--y: center y-coordinate
			--width: button radius
		--polygon:
			--p: table containing points
				--p[1]: x
				--p[2]: y
	--color: color of button
	--image: image of button (if one exists)
	--text: text to display on button
	--mouseOver: true/false for mouseover text
	--mouseOverText: text to display on mouseover if mouse-over is true
	--action: function to execute upon click
	
	--createButton("Test Button R",testFunc,"rectangle",0,0,100,30)
	--buttons[#buttons].color = lime
	--buttons[#buttons].image = love.graphics.newImage("test.png")
	--buttons[#buttons].bounds = getButtonBounds(buttons[#buttons])

	--100x30
	
	--createButton("Test Button C",nil,"circle",8,8,7)
	--buttons[#buttons].color = cerulean
	

 end


function makeField(field)

	local wingTailsCompleted = false
	 
	if (field.isParent) then
	
		while(not isCompleted(field)) do

		if (not isCompleted(field.tail)) then

			if (field.tail.isParent) then

				makeField(field.tail)

			 else

			 	for i, link in pairs(field.tail.links) do

					makeLink(link)

				 end

				field.tailCompleted = true

			 end

		elseif (not wingTailsCompleted) then

			--print("making wing tails 1")

			makeWingTails(field.wing1)

			--print("making wing tails 2")

			makeWingTails(field.wing2)

			--print("wing tails completed")

			wingTailsCompleted = true

		elseif (not isCompleted(field)) then

			makeJetLinks(field)

			if (field == fields[1]) then

				print("All links made.")

			 end

		else

			print("found nothing to do")
			love.timer.sleep(1)
			exit = true

	 	 end


	 end

	 exit = true

	else

	 	for i, link in pairs(field.links) do

	 		makeLink(link)

	 	 end

	 end

 end


function setFieldLinks()

	for i, field in pairs(fields) do

		field.links = {}

		for j, link in pairs(links) do

			if (isInTable(link.ends[1],field.anchorPortals) and isInTable(link.ends[2],field.anchorPortals)) then

				table.insert(field.links,link)

			 end

		 end

	 end

 end


function makeLink(link)

	if (not link.isMade) then

		link.isMade = true
		print("made link "..link.id)

	 else

		--print("re-made link that was already made ".."(link "..link.id..")")

	 end

	 love.timer.sleep(0)

	 

  end


function setPriorityField()

	priorityField = fieldQueue[#fieldQueue]
	print("new priority is Field "..priorityField.id)

 end


function makeWingTails(wing)


	if (wing.isParent) then

		if (wing.wing1.isParent) then
			makeWingTails(wing.wing1)
		end
		if (wing.wing2.isParent) then
			makeWingTails(wing.wing2)
		end

		if (wing.tail.isParent) then

			makeField(wing.tail)

		else

			for i, link in pairs(wing.tail.links) do

		 		makeLink(link)

		 	 end

	 	 wing.tailCompleted = true

	 	end

	 end


 end


function isCompleted(field)

	for i, link in pairs(field.links) do

		if (not link.isMade) then

			return false

		 end

	 end

	return true

 end


function makeJetLinks(field)

	for i, link in pairs(field.wing1.links) do

		if (not isInTable(link,field.wing2.links)) then
				
			makeLink(link)

		 end

	 end


	for i, link in pairs(field.wing2.links) do

		if (not isInTable(link,field.wing1.links)) then
				
			makeLink(link)

		 end

	 end


	for i, link in pairs(field.wing1.links) do

		if (isInTable(link,field.wing2.links)) then
				
			makeLink(link)

		 end

	 end


	if (field.wing1.isParent) then

		makeJetLinks(field.wing1)

	 end

	if (field.wing2.isParent) then

		makeJetLinks(field.wing2)

	 end


 end

function setAnchorPortals()

	local leftmostPortal = portals[1]
	local currentPortal
	local currentAngle = 0
	local largestAngle = 0
	local nextPortal
	local fullCircle = false

	for i, portal in pairs(portals) do

		if (portal.x<leftmostPortal.x) then

			leftmostPortal = portal

		 end

	 end

	table.insert(outsidePortals,leftmostPortal)


	for i, portal in pairs(portals) do

		if (portal.id ~= leftmostPortal.id) then

			currentAngle = findAngle({x=leftmostPortal.x+1,y=leftmostPortal.y},leftmostPortal,portal)

			if (currentAngle > largestAngle) then

				largestAngle = currentAngle
				nextPortal = portal

			 end

		 end



	 end
	table.insert(links,Link:new{level = 1, ends = {leftmostPortal,nextPortal} })
	table.insert(outsidePortals,nextPortal)
	currentPortal = nextPortal
	


	while (not fullCircle) do

		largestAngle = 0
		currentAngle = 0

		for i, portal in pairs(portals) do

			if (portal.id ~= currentPortal.id and portal.id ~= outsidePortals[#outsidePortals-1].id) then

				currentAngle = findAngle(outsidePortals[#outsidePortals-1],currentPortal,portal)

				if (currentAngle > largestAngle) then

					largestAngle = currentAngle
					nextPortal = portal

				 end

			 end

		end

		if (nextPortal == leftmostPortal) then
			fullCircle = true
			table.insert(links,Link:new{level = 1, ends = {currentPortal,nextPortal} })
		else
			table.insert(links,Link:new{level = 1, ends = {currentPortal,nextPortal} })
			table.insert(outsidePortals,nextPortal)
			currentPortal = nextPortal
			
		end

	 end


	for i, portal in pairs(outsidePortals) do

		portal.isAnchor = true
		portal.anchorLevel = 1

	 end


	 mode = "anchorLinks"
	 totalAnchors = #outsidePortals


 end


function setFieldTips()

	local processedFields = {}
	local processedLinks = {}

	

	for i, portal in pairs(portals) do

		if (#portal.inLinks == 2) then

			firstTip = portal

		 end

	 end


	for i, field in pairs(fields) do

		if ( isInTable(firstTip.inLinks[1],field.links) and isInTable(firstTip.inLinks[2],field.links)) then

			firstField = field
			field.tipPortal = firstTip

		 end

	 end
	table.insert(processedFields,firstField)
	table.insert(processedLinks,firstField.links[1])
	table.insert(processedLinks,firstField.links[2])
	table.insert(processedLinks,firstField.links[3])



	while(#processedFields ~= #fields) do

		
		for i, field in pairs(fields) do

			if (not isInTable(field, processedFields)) then

				local numberOfProcessedLinks = 0
				local bottomLink

				for j, link in pairs(field.links) do

					if (isInTable(link,processedLinks)) then

						numberOfProcessedLinks = numberOfProcessedLinks+1
						bottomLink = link

					 end

				 end


				if (numberOfProcessedLinks == 1) then

					for k, portal in pairs(field.anchorPortals) do

						if (not isInTable(portal,bottomLink.ends)) then

							field.tipPortal = portal

						 end

					 end

					table.insert(processedFields,field)
					table.insert(processedLinks,field.links[1])
					table.insert(processedLinks,field.links[2])
					table.insert(processedLinks,field.links[3])

				 end



			 end

		 end


	 end




	fieldOrder = processedFields



 end




