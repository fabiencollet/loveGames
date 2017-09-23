
love.graphics.setDefaultFilter("nearest")

worldTab = {}
worldTab.friction = 0.5

windowWidth, windowHeight = love.graphics.getDimensions()

width = 16
win = false
playerTab = {}
playerTab[1] = {
    shot=0,
    size=16,
    x=50,
    y=50,
    width=32,
    speed=200,
    maxVelocity=500,
    rotate=0,
    color={43, 168, 226, 255}
    }
playerTab[2] = {
    shot=0,
    size=16,
    x=1100,
    y=700,
    width=16,
    speed=200,
    maxVelocity=500,
    rotate=0,
    color={177, 226, 42, 255} 
    }   
vertices = {
    width/-2, width/-2,
    width/2, width/-2,
    0,width/2
}
bulletVertices = {
    width/-2, width/-2,
    width/2, width/-2,
    0,width/2
}
playerWin = 0
bulletTab = {}
bulletTab[1] = {}
bulletTab[2] = {}

gameOverImg = love.graphics.newImage( '/assets/images/game_over.png' )
gameOverWidth, gameOverHeight = gameOverImg:getDimensions()
function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

-- Load some default values for our rectangle.
function love.load()

    world = love.physics.newWorld(0,0)
    love.physics.setMeter(128)

    bodyTab = {}

    for id, player in pairs(playerTab) do
        shape = love.physics.newPolygonShape( vertices )
        body = love.physics.newBody( world, player.x, player.y, 'dynamic' )
        fixture = love.physics.newFixture( body, shape, 1 )
        bodyTab[id] = {body=body, fixture=fixture}
    end
  
    -- mesh = love.graphics.newMesh( vertices, 'strip' )
    
    dash=1

    joystickTab = love.joystick.getJoysticks()

end

-- Increase the size of the rectangle every frame.
function love.update(dt)

    if not joystickTab[1] then return end

    world:update(dt) --this puts the world into motion

    for id, player in pairs(bodyTab) do
        angle = player.body:getAngle()

        playerTab[1]['shot'] = playerTab[1]['shot'] + 1

        linVX, linVY = player.body:getLinearVelocity( )
        if tablelength(joystickTab) >= id then
            direction1 = joystickTab[id]:getAxis( 1 )
            direction2 = joystickTab[id]:getAxis( 2 )
            direction3 = joystickTab[id]:getAxis( 3 )
            dashAxis = joystickTab[id]:getGamepadAxis( 'triggerright' )
            brakeAxis = joystickTab[id]:getGamepadAxis( 'triggerleft' )
        else
            direction1 = 0
            direction2 = 0
            direction3 = 0
            dashAxis = 0
        end

        if joystickTab[id]:isGamepadDown( 'guide' ) then
            love.event.quit()
        end

        if joystickTab[id]:isGamepadDown( 'b' ) then
            local fullscreen = love.window.getFullscreen()
            if fullscreen then
                love.window.setFullscreen(false)        
            else
                love.window.setFullscreen(true)
            end
        end
        
        if joystickTab[id]:isGamepadDown( 'y' ) then
            love.event.quit( "restart" )
        end

        posX = player.body:getX()
        posY = player.body:getY()

        if posX > windowWidth then
            player.body:setX(0)
        elseif posX < 0 then
            player.body:setX(windowWidth-playerTab[id]['size'])
        end

        
        if playerTab[1]['shot'] > 33 then
            if joystickTab[id]:isGamepadDown('rightshoulder') then
                playerTab[1]['shot'] = 0
                degree = angle + math.rad(90)
                forceX = math.cos( degree )
                forceY = math.sin( degree )
                bulletShape = love.physics.newRectangleShape( forceX*16, forceY*16, 3, 6, angle )
                bulletBody = love.physics.newBody( world, posX, posY, 'dynamic' )
                bulletFixture = love.physics.newFixture( bulletBody, bulletShape, 1 )
                
                bulletBody:applyForce(forceX*50, forceY*50)
                if tablelength(bulletTab[id]) > 20 then
                    table.remove( bulletTab[id], 1 )
                end
                table.insert( bulletTab[id], {body = bulletBody,shape = bulletShape, fixture= bulletFixture} )
            end
        end

        for id, bullet in pairs(bulletTab[id]) do
            if bullet.body:getX() > windowWidth then
                bullet.body:setX(0)
            elseif bullet.body:getX() < 0 then
                bullet.body:setX(windowWidth)
            end
            if bullet.body:getY() > windowHeight then
                bullet.body:setY(0)
            elseif bullet.body:getY() < 0 then
                bullet.body:setY(windowHeight)
            end
        end

        for i, bullet in pairs(bulletTab[id]) do
            if id == 1 then
                distance, x1, y1, x2, y2 = love.physics.getDistance( bodyTab[2].fixture, bullet.fixture )
                if distance <= 0 then
                    playerWin = id
                    win = true
                end
            elseif id == 2 then
                distance, x1, y1, x2, y2 = love.physics.getDistance( bodyTab[1].fixture, bullet.fixture )
                if distance <= 0 then
                    playerWin = id
                    win = true
                end
            end
            
        end
        

        if posY > windowHeight then
            player.body:setY(0)
        elseif posY < 0 then
            player.body:setY(windowHeight-playerTab[id]['size'])
        end


        degree = angle + math.rad(90)
        forceX = math.cos( degree )
        forceY = math.sin( degree )

        if dashAxis > 0.05 then
            if linVX < playerTab[id]['maxVelocity'] and linVX > playerTab[id]['maxVelocity']*-1 then
                -- character.x = character.x + ((character.speed*dash) * direction1) * dt
                player.body:applyForce(((playerTab[id]['speed'] * forceX) * dt) * dashAxis , 0)
            end
        
            if linVY < playerTab[id]['maxVelocity'] and linVY > playerTab[id]['maxVelocity']*-1 then
                -- character.y = character.y + ((character.speed*dash) * direction2) * dt
                player.body:applyForce(0, ((playerTab[id]['speed'] * forceY) * dt) * dashAxis)
            end
        end
        if linVX > 0 then
            player.body:applyForce(-worldTab.friction-brakeAxis*2, 0)
        elseif linVX < 0 then
            player.body:applyForce(worldTab.friction+brakeAxis*2, 0)
        end

        if linVY > 0 then
            player.body:applyForce(0, -worldTab.friction-brakeAxis*2)
        elseif linVY < 0 then
            player.body:applyForce(0, worldTab.friction+brakeAxis*2)
        end
        

        if direction3 > 0.1 or direction3 < -0.1 then
            angle = angle + ((5) * direction3) * dt
            player.body:setAngle(angle)
        end
    end
end


-- Draw a coloured rectangle.
function love.draw()
    if win==false then
        --love.graphics.setColor(255, 255, 255, 255)
        --love.graphics.print(tostring( playerTab[1]['shot'] ), 800)

        for id, player in pairs(bodyTab) do
            love.graphics.setColor(playerTab[id]['color'])
            love.graphics.polygon("fill", player.body:getWorldPoints(shape:getPoints()))    
        end
        for i, joystick in pairs(joystickTab) do
            for id, bullet in pairs(bulletTab[i]) do
                love.graphics.setColor(playerTab[i]['color'])
                love.graphics.polygon("line", bullet.body:getWorldPoints(bullet.shape:getPoints()))    
            end
        end
    else
        -- love.graphics.print('YOU WIN!! '..tostring(playerWin), 900, 500, 0,2,2)
        love.graphics.draw(gameOverImg, windowWidth/2-(gameOverWidth/2), windowHeight/2-(gameOverHeight/2),0,1,1)
    end
end