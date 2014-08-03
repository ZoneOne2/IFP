function love.load()
	--[[TODO:
	
		--Create portal object with fields:
			x
			y
			title
			inFields
			isAnchor (t/f)
		--Create field object with fields:
			anchorPortals
			containsPortals
			level
			area

		]]

	require "JLib"
	
	init()

	--definition of portal object
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

	--definition of field object
	Field = {
				id = 0,
				anchorPortals = {}, 
				containsPortals = {}, 
				level = 0, 
				area = 0,
				fieldType = "unassigned",
			 }
	function Field:new(o)

		totalFields = totalFields+1

		o = o or {}
		setmetatable(o,self)
		self.__index = self
		o.id = #fields+1
		o.anchorPortals = {}
		o.containsPortals = {}
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
	
	portals = {}
	fields = {}

	mode = "place"
	
 end

function love.draw()

	lg.push()
		lg.scale(1,-1)
		lg.translate(window.width/2,-window.height/2)
		lg.setLineJoin("none")

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


		drawButtons()
	
	 lg.pop()

 end

function love.update(dt)
	jupdate(dt)
	
	if #portals >0 then
		closestPortalID = findClosestPoint(mouse,portals)
		closestPortal = closestPortalID[1][closestPortalID[2]]
		currentField = closestPortal.inFields[#closestPortal.inFields]
		print(closestPortal.tipAccess,closestPortal.anchorLevel)
	end

	--print(mode)
	
 end

function love.focus(bool)

 end

function love.keypressed( key, unicode )
	if key == "`" then
		debug.debug()
	end
	if key == "/" then
		testFunc()
	end
	if key == "return" then
		mode = "mainAnchor"
		print("Select 3 main outside portals")
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

				print(tipPortal,sidePortals[1],sidePortals[2])


				table.insert(fields,Field:new{level = closestPortal.anchorLevel, fieldType = "wing"})
				table.insert(fields[#fields].anchorPortals,closestPortal)
				table.insert(fields[#fields].anchorPortals,currentField.anchorPortals[tipPortal])
				table.insert(fields[#fields].anchorPortals,currentField.anchorPortals[sidePortals[1]])
				fields[#fields]:setPortalsInside()


				table.insert(fields,Field:new{level = closestPortal.anchorLevel, fieldType = "wing"})
				table.insert(fields[#fields].anchorPortals,closestPortal)
				table.insert(fields[#fields].anchorPortals,currentField.anchorPortals[tipPortal])
				table.insert(fields[#fields].anchorPortals,currentField.anchorPortals[sidePortals[2]])
				fields[#fields]:setPortalsInside()

				table.insert(fields,Field:new{level = closestPortal.anchorLevel, fieldType = "tail"})
				table.insert(fields[#fields].anchorPortals,closestPortal)
				table.insert(fields[#fields].anchorPortals,currentField.anchorPortals[sidePortals[1]])
				table.insert(fields[#fields].anchorPortals,currentField.anchorPortals[sidePortals[2]])
				fields[#fields]:setPortalsInside()

				if (totalAnchors == totalPortals) then

					print("All fields linked.")

				 end

			 end

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