function love.load()
	--[[TODO:
	
		--ADD PARENT FIELD TO EACH FIELD
		--ADD isParent trait to Field object

		]]
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

	 }
	function Portal:new(o)

		totalPortals = totalPortals+1

		o = o or {}
		setmetatable(o, self)
		self.__index = self
		o.id = #portals+1
		o.inFields = {}
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
		--links = {},

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

	 }
	function Link:new(o)

		totalLinks = totalLinks+1

		o = o or {}
		setmetatable(o,self)
		self.__index = self
		o.id = #links+1
		objectTableSort(self.ends,"id")
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

 end

function love.draw()

	lg.push()
		lg.scale(1,-1)
		lg.translate(window.width/2,-window.height/2)
		lg.setLineJoin("none")
		lg.setLineWidth(1)

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

		if (mode == "mainAnchor") then

			setHexColor(white)
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

			for i, field in pairs(fields) do

				lg.setColor(HEXtoDEC("00"),HEXtoDEC("7b"),HEXtoDEC("a7"),200*(1/#fields))
				pointPolygon("fill",field.anchorPortals)

				lg.setColor(HEXtoDEC("00"),HEXtoDEC("7b"),HEXtoDEC("a7"),255)
				pointPolygon("line",field.anchorPortals)

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
		--print(closestPortal.tipAccess,closestPortal.anchorLevel)
	end

	if (mode == "link" and not isCompleted(fields[1])) then
			
			
			if (temp>0) then
				print("makingLinks")
				love.timer.sleep(2)
				makeField(fields[1])
			end
			temp = temp + 1
	 end

	--print(mode)
	
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
			mode = "mainAnchor"
			print("Select 3 main outside portals")
		end

	end


	if (mode == "mainAnchor") then

		--

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

	if (mode == "mainAnchor") then

		if button == "l" then
			
			if (not closestPortal.isAnchor) then

				closestPortal.isAnchor = true
				closestPortal.anchorLevel = 1

				if (totalAnchors == 0) then
					closestPortal.tipAccess = true
				else
					closestPortal.tipAccess = false
				end

				totalAnchors = totalAnchors+1

				if (totalAnchors == 3) then

					table.insert(fields,Field:new{level = 1, fieldType = "main"})

					for i, portal in pairs(portals) do

						if (portal.isAnchor) then

							table.insert(fields[1].anchorPortals,portal)
							
						 end

					 end

					fields[1]:setPortalsInside()

					table.insert(links,Link:new{level = 1, ends = {fields[1].anchorPortals[1],fields[1].anchorPortals[2]} })
					table.insert(links,Link:new{level = 1, ends = {fields[1].anchorPortals[2],fields[1].anchorPortals[3]} })
					table.insert(links,Link:new{level = 1, ends = {fields[1].anchorPortals[1],fields[1].anchorPortals[3]} })

					mode = "field"
				 
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

				
				--determine which anchor portal is "tip" for assigning field types of wing/tail
				local possibleTipPortals = {}

				for i, portal in pairs(currentField.anchorPortals) do

					if (portal.tipAccess) then

						possibleTipPortals[i] = portal.anchorLevel

					 end

				 end

				local limit, key
				if(currentField.fieldType == "tail") then
					limit, key = tableMax(possibleTipPortals)
				else
					limit, key = tableMin(possibleTipPortals)
				end

				
				local tipPortal = key
				local sidePortals = {}

				for i, portal in pairs(currentField.anchorPortals) do
					if (i ~= key) then
						table.insert(sidePortals,i)
					end
				 end
				--

				currentField.isParent = true

				table.insert(fields,Field:new{level = closestPortal.anchorLevel, fieldType = "wing"})
				table.insert(fields[#fields].anchorPortals,closestPortal)
				table.insert(fields[#fields].anchorPortals,currentField.anchorPortals[tipPortal])
				table.insert(fields[#fields].anchorPortals,currentField.anchorPortals[sidePortals[1]])
				fields[#fields]:setPortalsInside()
				currentField.wing1 = fields[#fields]

				table.insert(fields,Field:new{level = closestPortal.anchorLevel, fieldType = "wing"})
				table.insert(fields[#fields].anchorPortals,closestPortal)
				table.insert(fields[#fields].anchorPortals,currentField.anchorPortals[tipPortal])
				table.insert(fields[#fields].anchorPortals,currentField.anchorPortals[sidePortals[2]])
				fields[#fields]:setPortalsInside()
				currentField.wing2 = fields[#fields]

				table.insert(fields,Field:new{level = closestPortal.anchorLevel, fieldType = "tail"})
				table.insert(fields[#fields].anchorPortals,closestPortal)
				table.insert(fields[#fields].anchorPortals,currentField.anchorPortals[sidePortals[1]])
				table.insert(fields[#fields].anchorPortals,currentField.anchorPortals[sidePortals[2]])
				fields[#fields]:setPortalsInside()
				currentField.tail = fields[#fields]


				table.insert(links,Link:new{level = currentField.level+1, ends = {closestPortal,currentField.anchorPortals[tipPortal]} })
				table.insert(links,Link:new{level = currentField.level+1, ends = {closestPortal,currentField.anchorPortals[sidePortals[1]]} })
				table.insert(links,Link:new{level = currentField.level+1, ends = {closestPortal,currentField.anchorPortals[sidePortals[2]]} })


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


 end


function setFieldLinks()

	for i, field in pairs(fields) do

		for j, link in pairs(links) do

			if (isInTable(link.ends[1],field.anchorPortals) and isInTable(link.ends[2],field.anchorPortals)) then

				table.insert(field.links,link)

			 end

		 end

	 end

 end


function isInTable(val,tab)

	for i, element in pairs(tab) do

		if (element == val) then

			return true

		 end

	 end

	return false

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


function findMid(point1,point2)

	--check to make sure points contain x and
	local p1,p2

	if (point1.x and point1.y) then

		p1 = {x=point1.x, y=point1.y}

	 else

		error("point 1 is missing x and/or y")

	 end

	if (point2.x and point2.y) then

		p2 = {x=point2.x, y=point2.y}

	 else

		error("point 2 is missing x and/or y")

	 end

	return {(p1.x+p2.x)/2, (p1.y+p2.y)/2}
	

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