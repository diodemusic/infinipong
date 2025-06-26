-- infinipong
-- by saves

------------------- player

function draw_player()
    palt(0, false)
    pal(1, player.colors[player.color])

    if player.moving_left then
        spr(player.sprite_num_right, player.x, player.y, 1, 1, true)
    elseif player.moving_right then
        spr(1, player.x, player.y)
    else
        spr(player.sprite_num, player.x, player.y)
    end

    palt(0, true)
    pal(1, 1)
end

function update_player()
    player.moving_left = false
    player.moving_right = false

    if btn(0) and player.x > 0 and not debug_options.lock_controls then
        player.moving_left = true
        player.x -= player.move_speed
    end

    if btn(1) and player.x < 120 and not debug_options.lock_controls then
        player.moving_right = true
        player.x += player.move_speed
    end

    if player.x < 0 then player.x = 0 end
    if player.x > 120 then player.x = 120 end
end

function lose_life()
    sfx(1)

    if not debug_options.infinite_lives then
        player.lives -= 1
    end

    if player.lives > 0 then
        player.x = 60
        enemy.x = 60
        reset_ball()
        level_progress = 0
    else
        set_game_over()
    end
end

------------------- enemy

function draw_enemy()
    pal(1, 0)

    if enemy.moving_left then
        spr(enemy.sprite_num_right, enemy.x, enemy.y, 1, 1, true)
    elseif enemy.moving_right then
        spr(enemy.sprite_num_right, enemy.x, enemy.y)
    else
        spr(enemy.sprite_num, enemy.x, enemy.y)
    end

    pal(1, 1)
end

function update_enemy()
    enemy.moving_left = false
    enemy.moving_right = false

    if ball.x_speed < 0 then
        enemy.x = ball.x - 3
        enemy.moving_left = true
    elseif ball.x_speed > 0 then
        enemy.x = ball.x - 3
        enemy.moving_right = true
    end

    enemy.x = mid(0, enemy.x, 120)
    enemy.y = (-ball.y + 54) / 4
end

------------------- ball

function draw_ball()
    rectfill(ball.x, ball.y, ball.x + 1, ball.y + 1, 7)
end

function update_ball()
    ball.y += ball.y_speed
    ball.x += ball.x_speed

    if ball.x < 0 then
        ball.x = 0
        ball.x_speed = -ball.x_speed
        sfx(2)
    end

    if ball.x > 126 then
        ball.x = 126
        ball.x_speed = -ball.x_speed
        sfx(2)
    end

    if (
        ball.y >= player.y and ball.y <= player.y + 5
    ) and (
        ball.x >= player.x - 2 and ball.x <= player.x + 8
    ) then
        ball.y = player.y - 3
        ball.y_speed = -ball.y_speed
        calculate_ball_x_angle()
        level_progress += 16
        score += 10 * score_multiplier
        sfx(2)
    end

    if ball.y <= 17 then
        ball.y_speed = -ball.y_speed
        sfx(2)
    end

    if ball.y >= 128 then
        lose_life()
    end
end

function calculate_ball_x_angle()
    ball.x_speed = ((ball.x - player.x) - 3.5) * ball.x_angle_multiplier
end

function reset_ball()
    ball.x = player.x + 3
    ball.y = player.y - 8
    ball.x_speed = 0
    ball.y_speed = -abs(ball.y_speed)
end

------------------- level

function update_level()
    if (level_progress >= 128) then
        level += 1
        score_multiplier += 1
        level_progress = 0

        local speed = abs(ball.y_speed)

        print(speed, 70, 50, 11)

        if speed < ball.y_speed_cap then
            speed = min(speed + ball.y_speed_increase, ball.y_speed_cap)
        end

        if ball.y_speed < 0 then
            ball.y_speed = -speed
        else
            ball.y_speed = speed
        end

        sfx(0)
    end

    player.color = ((level-1) % #player.colors) + 1
end

------------------- game state

function set_game_over()
    game_over = true
    music(-1, 10, 1)
end

function draw_stats()
    rectfill(0, 0, 128, 6, 0)
    print("level: " .. level, 1, 1, 7)
    print("score: " .. score, 49, 1, 7)
    draw_lives()
    draw_level_progress()
end

function draw_lives()
    for i = 1, player.lives do
        spr(player.lives_sprite_num, 96 + (i * 8), 1)
    end
end

function draw_level_progress()
    line(0, 7, level_progress, 7, 7)
end

function update_game_over()
    if game_over then
        if btnp(5) then
            _init()
            main_menu.start_game = true
        end
    end
end

function draw_game_over()
    if game_over then
        rectfill(20, 50, 108, 78, 0)
        print("game over!", 44, 58, 7)
        print("press ❎", 49, 68, 7)
    end
end
------------------------------- debug

function draw_pixel_inspector()
    if debug_options.pixel_inspect then
        pset(
            debug_options.pixel_inspector.x,
            debug_options.pixel_inspector.y,
            11
        )

        print(
        "[" .. debug_options.pixel_inspector.x .. ", " .. debug_options.pixel_inspector.y .. "]",
        96,
        122,
            11
        )
    end
end

function update_pixel_inspector()
    if debug_options.pixel_inspect then
        if btnp(0) then
            debug_options.pixel_inspector.x -= 1
        end
        if btnp(1) then
            debug_options.pixel_inspector.x += 1
        end
        if btnp(2) then
            debug_options.pixel_inspector.y -= 1
        end
        if btnp(3) then
            debug_options.pixel_inspector.y += 1
        end
    end
end

function update_aim_bot()
    if btnp(4) and debug_options.aim_bot then
        debug_options.aim_bot_toggle = not debug_options.aim_bot_toggle
    end

    if debug_options.aim_bot_toggle then
        player.x = ball.x - 3
    end
end

function draw_debug_stats()
    if not debug_options.show_debug_stats then return end

    local stats = {
        "p_x: " .. player.x,
        "p_lives: " .. player.lives,
        "p_move_speed: " .. player.move_speed,
        "p_col: " .. player.colors[player.color],
        "e_x: " .. enemy.x,
        "e_y: " .. enemy.y,
        "b_x: " .. ball.x,
        "b_y: " .. ball.y,
        "b_x_s: " .. ball.x_speed,
        "b_y_s: " .. ball.y_speed,
        "b_y_s_abs: " .. abs(ball.y_speed),
        "aim_bot: " .. tostr(debug_options.aim_bot),
        "aim_bot_t: " .. tostr(debug_options.aim_bot_toggle),
    }
    local y = 9

    for i = 1, #stats do
        print(stats[i], 1, y, 11)
        y += 6
    end
end

function draw_hitboxes()
    if not debug_options.show_hitboxes then return end

    rect( -- player
        player.x - 2,
        player.y,
        player.x + 8,
        player.y + 5,
        11
    )

    rect( -- ball
        ball.x,
        ball.y,
        ball.x,
        ball.y,
        11
    )
end

------------------------------- main menu

function draw_main_menu()
    cls(0)
    map(16, 0)

    pal(1, player.colors[player.color])
    spr(
        player.sprite_num,
        sin(time() * (2 * 3.14159) * 0.015) * 60 + 60,
        120
    )
    pal(1, 1)
    spr(
        enemy.sprite_num,
        -sin(time() * (2 * 3.14159) * 0.015) * 60 + 60,
        10
    )

    print("press [🅾️] to start", 28, 82, 7)
end

function update_main_menu()
    if not main_menu.music_is_playing then
        music(main_menu.music_num, 10, 1)
        main_menu.music_is_playing = true
    end

    main_menu.frame_counter += 1

    if main_menu.frame_counter >= 30 then
        if player.color > 12 then
            player.color = 1
        else
            player.color += 1
        end

        main_menu.frame_counter = 0
    end

    if btn(4) then
        main_menu.start_game = true
        music(-1, 10, 1)
        player.color = 1
    end
end

------------------------------- pico-8 callbacks

function _init()
    main_menu = {
        start_game = false,
        music_num = 0,
        music_is_playing = false,
        frame_counter = 0
    }

    player = {
        sprite_num = 0,
        sprite_num_right = 1,
        x = 60,
        y = 120,
        move_speed = 1.5,
        colors = {2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 0},
        color = 1,
        color_updated = false,
        moving_left = false,
        moving_right = false,
        lives = 3,
        lives_sprite_num = 9
    }
    enemy = {
        sprite_num = 2,
        sprite_num_right = 3,
        x = 60,
        y = -100,
        moving_left = false,
        moving_right = false
    }
    ball = {
        x = 63,
        y = 63,
        x_speed = 0,
        y_speed = 2,
        y_speed_increase = 0.2,
        y_speed_cap = 4,
        x_angle_multiplier = 0.4
    }
    level = 1
    level_progress = 0
    score = 0
    score_multiplier = 10
    game_over = false

    debug_options = {
        show_debug_stats = false,
        pixel_inspect = false,
        aim_bot = false,
        aim_bot_toggle = false, -- use aim_bot instead
        infinite_lives = false,
        lock_controls = false,
        pixel_inspector = {
            x = 63,
            y = 63
        },
        show_hitboxes = false
    }
end

function _update()
    if not main_menu.start_game then
        update_main_menu()
        return
    end

    update_game_over()

    if game_over then
        return
    end

    update_player()
    update_enemy()
    update_ball()
    update_level()
    update_aim_bot()
    update_pixel_inspector()
end

function _draw()
    if not main_menu.start_game then
        draw_main_menu()
        return
    end

    cls(1)
    map(0, 0)
    draw_ball()
    draw_enemy()
    draw_stats()
    draw_player()
    draw_game_over()
    draw_pixel_inspector()
    draw_debug_stats()
    draw_hitboxes()
end
