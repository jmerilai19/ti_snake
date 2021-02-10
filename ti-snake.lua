map_zero = {7, 18}                              -- coordinates of the map's top-left corner
map_size = {19, 11}                             -- map size in tiles
tile_size = 16                                  -- tile size in pixels
snake = {8, 5}                                  -- snake start position
food_pos = {0, 0}                               -- food position
snake_dir = {1, 0}                              -- snake movement direction
snake_dir_request = {0, 0}                      -- user input
trail = {}                                      -- snake's tail part positions
tail = 3                                        -- snake's tail length
score = 0                                       -- game score
highscore = 0                                   -- game highscore
time = {0,0}                                    -- game time
time_scale = 0.2                                -- time between screen updates in seconds
paused = false                                  -- is game paused
game_over = false                               -- is game over
game_on = false                                 -- is game or menu on
menu_selection = 0                              -- which menu selection is "being hovered over"
difficulty = 2                                  -- difficulty (1-3)
difficulty_string = {"EASY", "NORMAL", "HARD"}  -- difficulty names

-- set page background color
platform.window:setBackgroundColor(0xffffff)

function on.paint(gc)
    if game_on == true then
        drawGame(gc)
    else
        drawMenu(gc)
    end
end

function createGame()
    -- initialize variables
    snake = {8, 5}                                  
    snake_dir = {1, 0}                              
    snake_dir_request = {0, 0}                      
    trail = {}                                      
    tail = 3                                        
    score = 0                                       
    time = {0,0}                                    
    time_scale = 0.4 - difficulty/10                
    paused = false                                  
    game_over = false                               
    game_on = true
    
    -- spawn food to new  position
    food_pos[1] = math.floor(math.random(0, map_size[1]-1))
    food_pos[2] = math.floor(math.random(0, map_size[2]-1))   
                                 
    -- start timer
    timer.stop()
    timer.start(time_scale)
end

function drawGame(gc)
    -- draw map background
    gc:setColorRGB(242, 209, 96)
    gc:fillRect(map_zero[1] - 1, map_zero[2] - 1, map_size[1] * tile_size + 1, map_size[2] * tile_size + 1)
    
    -- draw score
    gc:setColorRGB(0, 0, 0)
    gc:setFont("sansserif", "b", 11)
    gc:drawString(string.format("%05d", score), 272, -2, "top")
    
    -- draw time
    gc:drawString(string.format("%02u:%02u", time[1], time[2]), 7, -2, "top")
    
    -- draw food
    gc:setColorRGB(255, 0, 0)
    gc:fillArc(map_zero[1] + food_pos[1] * tile_size + 4, map_zero[2] + food_pos[2] * tile_size + 4, tile_size-8, tile_size-8, 0, 360)

    for i=1, table.getn(trail), 1 do
        if i == table.getn(trail) then
            -- draw snake's head
            gc:setColorRGB(49, 99, 0)
            if snake_dir[1] == 1 then
                -- facing right
                gc:fillRect(map_zero[1] + trail[i][1] * tile_size, map_zero[2] + trail[i][2] * tile_size, tile_size/2, tile_size)
                gc:fillArc(map_zero[1] + trail[i][1] * tile_size, map_zero[2] + trail[i][2] * tile_size, tile_size, tile_size, 0, 360)
            elseif snake_dir[1] == -1 then
                -- facing left
                gc:fillRect(map_zero[1] + trail[i][1] * tile_size + tile_size/2, map_zero[2] + trail[i][2] * tile_size, tile_size/2, tile_size)
                gc:fillArc(map_zero[1] + trail[i][1] * tile_size, map_zero[2] + trail[i][2] * tile_size, tile_size, tile_size, 0, 360)
            elseif snake_dir[2] == 1 then
                -- facing down
                gc:fillRect(map_zero[1] + trail[i][1] * tile_size, map_zero[2] + trail[i][2] * tile_size, tile_size, tile_size/2)
                gc:fillArc(map_zero[1] + trail[i][1] * tile_size, map_zero[2] + trail[i][2] * tile_size, tile_size, tile_size, 0, 360)
            elseif snake_dir[2] == -1 then
                -- facing up
                gc:fillRect(map_zero[1] + trail[i][1] * tile_size, map_zero[2] + trail[i][2] * tile_size + tile_size/2, tile_size, tile_size/2)
                gc:fillArc(map_zero[1] + trail[i][1] * tile_size, map_zero[2] + trail[i][2] * tile_size, tile_size, tile_size, 0, 360)
            end
        elseif i == 1 then
            -- draw tail's end
            gc:setColorRGB(49, 120, 0)
            if trail[1][1] == trail[2][1] then
                -- tail is horizontal
                if trail[1][2] < trail[2][2] then
                    -- facing right
                    if trail[2][2] - trail[1][2] == 1 then
                        gc:fillRect(map_zero[1] + trail[i][1] * tile_size, map_zero[2] + trail[i][2] * tile_size + tile_size/2, tile_size, tile_size/2)
                        gc:fillArc(map_zero[1] + trail[i][1] * tile_size, map_zero[2] + trail[i][2] * tile_size, tile_size, tile_size, 0, 360)
                    else
                        gc:fillRect(map_zero[1] + trail[i][1] * tile_size, map_zero[2] + trail[i][2] * tile_size, tile_size, tile_size/2)
                        gc:fillArc(map_zero[1] + trail[i][1] * tile_size, map_zero[2] + trail[i][2] * tile_size, tile_size, tile_size, 0, 360)
                    end
                elseif trail[1][2] > trail[2][2] then
                    -- facing left
                    if trail[1][2] - trail[2][2] == 1 then
                        gc:fillRect(map_zero[1] + trail[i][1] * tile_size, map_zero[2] + trail[i][2] * tile_size, tile_size, tile_size/2)
                        gc:fillArc(map_zero[1] + trail[i][1] * tile_size, map_zero[2] + trail[i][2] * tile_size, tile_size, tile_size, 0, 360)
                    else
                        gc:fillRect(map_zero[1] + trail[i][1] * tile_size, map_zero[2] + trail[i][2] * tile_size + tile_size/2, tile_size, tile_size/2)
                        gc:fillArc(map_zero[1] + trail[i][1] * tile_size, map_zero[2] + trail[i][2] * tile_size, tile_size, tile_size, 0, 360)
                    end
                end            
            elseif trail[1][2] == trail[2][2] then
                -- tail is vertical
                if trail[1][1] < trail[2][1] then
                    -- facing down
                    if trail[2][1] - trail[1][1] == 1 then
                        gc:fillRect(map_zero[1] + trail[i][1] * tile_size + tile_size/2, map_zero[2] + trail[i][2] * tile_size, tile_size/2, tile_size)
                        gc:fillArc(map_zero[1] + trail[i][1] * tile_size, map_zero[2] + trail[i][2] * tile_size, tile_size, tile_size, 0, 360)
                    else
                        gc:fillRect(map_zero[1] + trail[i][1] * tile_size, map_zero[2] + trail[i][2] * tile_size, tile_size/2, tile_size)
                        gc:fillArc(map_zero[1] + trail[i][1] * tile_size, map_zero[2] + trail[i][2] * tile_size, tile_size, tile_size, 0, 360)
                    end
                elseif trail[1][1] > trail[2][1] then
                    -- facing down
                    if trail[1][1] - trail[2][1] == 1 then
                        gc:fillRect(map_zero[1] + trail[i][1] * tile_size, map_zero[2] + trail[i][2] * tile_size, tile_size/2, tile_size)
                        gc:fillArc(map_zero[1] + trail[i][1] * tile_size, map_zero[2] + trail[i][2] * tile_size, tile_size, tile_size, 0, 360)
                    else
                        gc:fillRect(map_zero[1] + trail[i][1] * tile_size + tile_size/2, map_zero[2] + trail[i][2] * tile_size, tile_size/2, tile_size)
                        gc:fillArc(map_zero[1] + trail[i][1] * tile_size, map_zero[2] + trail[i][2] * tile_size, tile_size, tile_size, 0, 360)
                    end
                end            
            end
        else    
            -- draw tail's middle part
            gc:setColorRGB(49, 120, 0)
            gc:fillRect(map_zero[1] + trail[i][1] * tile_size, map_zero[2] + trail[i][2] * tile_size, tile_size, tile_size)
        end
        
        -- if snake hits tail
        if trail[i][1] == snake[1] and trail[i][2] == snake[2] and i ~= table.getn(trail) then
            game_over = true
        end
    end

    -- draw map border
    gc:setColorRGB(48, 39, 27)
    gc:drawRect(map_zero[1] - 1, map_zero[2] - 1, map_size[1] * tile_size + 1, map_size[2] * tile_size + 1)
    
    if paused == true then
        -- paused
        gc:setColorRGB(0, 0, 0)
        gc:setFont("sansserif", "b", 16)
        gc:drawString("PAUSED", 120, 82, "top")
        gc:setFont("sansserif", "b", 6)
        gc:drawString("Press 'esc' to continue", 116, 112, "top")
        gc:drawString("Press 'tab' to go to menu", 110, 124, "top")
    elseif game_over == true then
        -- game over
        if score > highscore then
            highscore = score
        end
        gc:setColorRGB(0, 0, 0)
        gc:setFont("sansserif", "b", 16)
        gc:drawString("GAME OVER", 99, 70, "top")
        gc:setFont("sansserif", "b", 9)
        gc:drawString(string.format("SCORE: %05d", score), 122, 98, "top")
        gc:drawString(string.format("HIGHSCORE: %05d", highscore), 106, 110, "top")
        gc:setFont("sansserif", "b", 6)
        gc:drawString("Press 'esc' to restart", 117, 134, "top")
        gc:drawString("Press 'tab' to go to menu", 110, 146, "top")
    end
end

function drawMenu(gc)
    -- draw title
    gc:setColorRGB(29, 79, 0)
    gc:setFont("sansserif", "b", 18)
    gc:drawString("TI-SNAKE", 82, 0, "top")
    
    -- draw buttons
    gc:setColorRGB(0, 0, 0)
    gc:setFont("sansserif", "b", 12)
    gc:drawString("PLAY", 139, 80, "top")
    if difficulty == 1 then
        gc:drawString(difficulty_string[difficulty], 139, 105, "top")
    elseif difficulty == 2 then
        gc:drawString(difficulty_string[difficulty], 128, 105, "top")
    elseif difficulty == 3 then
        gc:drawString(difficulty_string[difficulty], 138, 105, "top")
    end
    gc:drawString("←                      →", 102, 103, "top")
    
    -- draw selection rectangle
    gc:drawRect(98, 80 + menu_selection * 25, 127, 20)
    
    -- draw bottom text
    gc:setFont("sansserif", "b", 8)
    gc:drawString("Joona Meriläinen", 128, 190, "baseline")
    gc:drawString("2020", 152, 201, "baseline")
end

function update()
    -- check if move is allowed
    if snake_dir_request[1] ~= 0 then
        if snake_dir_request[1] ~= -1 * snake_dir[1] then
            snake_dir[1] = snake_dir_request[1]
            snake_dir[2] = 0
        end
    end
    if snake_dir_request[2] ~= 0 then
        if snake_dir_request[2] ~= -1 * snake_dir[2] then
            snake_dir[2] = snake_dir_request[2]
            snake_dir[1] = 0
        end
    end
    
    -- set new snake position
    snake[1] = snake[1] + snake_dir[1]
    snake[2] = snake[2] + snake_dir[2]
    
    -- loop when crossing the map border
    if snake[1] > map_size[1] - 1 then
        snake[1] = 0
    end
    if snake[1] < 0 then
        snake[1] = map_size[1] - 1
    end
    if snake[2] > map_size[2] - 1 then
        snake[2] = 0
    end
    if snake[2] < 0 then
        snake[2] = map_size[2] - 1
    end
    
    -- if head hits food
    if food_pos[1] == snake[1] and food_pos[2] == snake[2] then
        score = score +  difficulty
        tail = tail + 1
        food_pos[1] = math.floor(math.random(0, map_size[1]-1))
        food_pos[2] = math.floor(math.random(0, map_size[2]-1))
    end
    
    for i=1, table.getn(trail), 1 do
        -- prevent food from spawning under snake
        while food_pos[1] == trail[i][1] and food_pos[2] == trail[i][2] do
            food_pos[1] = math.floor(math.random(0, map_size[1]-1))
            food_pos[2] = math.floor(math.random(0, map_size[2]-1))
        end
    end
    
    -- force draw update
    platform.window:invalidate()
    
    -- add last head position to trail
    table.insert(trail, {snake[1], snake[2]})
    
    -- remove trail overflow
    while table.getn(trail) > tail do
        table.remove(trail, 1)
    end
end

function on.timer()
    -- game is on
    if paused == false and game_over == false then
        time[2] = time[2] + time_scale
        -- check for minute
        if time[2] > 60 then
            time[1] = time[1] + 1
            time[2] = 0
        end
        update()
    end
end

function on.enterKey()
    if game_on == false then
        if menu_selection == 0 then
            createGame()
            game_on = true
        end
    end
end

function on.escapeKey()
    if game_over == false then
        -- pause game
        paused = not paused
        -- force draw update
        platform.window:invalidate()
    else
        createGame()
        -- force draw update
        platform.window:invalidate()
    end
end

function on.tabKey()
    if paused == true or game_over == true then
        game_on = false
        -- force draw update
        platform.window:invalidate()
    end
end

function on.charIn(char)
     if char == "8" then
        if game_on == true then
            -- move up
            snake_dir_request[2] = -1
            snake_dir_request[1] = 0
        else
            if menu_selection > 0 then
                menu_selection = menu_selection - 1
            end
        end
     elseif char == "6" then
        if game_on == true then
            -- move right
            snake_dir_request[1] = 1
            snake_dir_request[2] = 0
        else
            if menu_selection == 1 and difficulty < 3 then
                difficulty = difficulty + 1
            end
        end
     elseif char == "5" then
        if game_on == true then
            -- move down
            snake_dir_request[2] = 1
            snake_dir_request[1] = 0
        else
            if menu_selection < 1 then
                menu_selection = menu_selection + 1
            end
        end
     elseif char == "4" then
        if game_on == true then
            -- move left
            snake_dir_request[1] = -1
            snake_dir_request[2] = 0
        else
            if menu_selection == 1 and difficulty > 1 then
                difficulty = difficulty - 1
            end
        end
     end
     
     -- force draw update
     platform.window:invalidate()
 end