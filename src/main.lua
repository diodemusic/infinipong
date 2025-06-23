-- infinipong
-- by saves

function draw_player()
    if player.moving_left then
        spr(2, player.x, player.y)
    elseif player.moving_right then
        spr(1, player.x, player.y)
    else
        spr(0, player.x, player.y)
    end

    rect(
        player.x,
        player.y,
        player.x + 7,
        player.y + 6,
        player.colors[player.color]
    )
    line(
        player.x + 3,
        player.y + 7,
        player.x + 4,
        player.y + 7,
        player.colors[player.color]
    )
end

function update_player()
    player.moving_left = false
    player.moving_right = false

    if btn(0) and player.x > 0 and not debug_options.lock_controls then
        player.moving_left = true
        player.x -= 1
    end

    if btn(1) and player.x < 120 and not debug_options.lock_controls then
        player.moving_right = true
        player.x += 1
    end
end

function draw_enemy()
    if enemy.moving_left then
        spr(5, enemy.x, enemy.y)
    elseif enemy.moving_right then
        spr(4, enemy.x, enemy.y)
    else
        spr(3, enemy.x, enemy.y)
    end
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

    if debug_options.aim_bot then
        player.x = ball.x - 3
    end
end

function draw_ball()
    rectfill(ball.x, ball.y, ball.x + 1, ball.y + 1, 7)
end

function update_ball()
    ball.y += ball.y_speed
    ball.x += ball.x_speed

    if ball.x < 1 then
        ball.x_speed = -ball.x_speed
        sfx(2)
    end
    if ball.x > 126 then
        ball.x_speed = -ball.x_speed
        sfx(2)
    end

    if (
        ball.y >= player.y - 2 and ball.y <= player.y - 1
    ) and (
        ball.x >= player.x - 3 and ball.x <= player.x + 9
    ) then
        ball.y_speed += 0.2
        ball.y_speed = -ball.y_speed
        ball.x_speed = rnd(2) - 1
        ball.bounces += 1
        score += 1 * score_multiplier
        sfx(2)
    end
    if ball.y <= 17 then
        ball.y_speed = -ball.y_speed
        score += 1 * score_multiplier
        sfx(2)
    end
    if ball.y >= 128 then
        lose_life()
    end
end

function update_level()
    if (
        (
            ball.bounces % 5 == 0
        ) and (
            ball.bounces ~= last_color_change_bounce
        )
    ) then
        level += 1
        last_color_change_bounce = ball.bounces
        score_multiplier += 1
        sfx(0)
    end

    player.color = level % #player.colors + 1
end

function lose_life()
    sfx(1)

    if player.lives > 1 then
        if not debug_options.infinite_lives then
            player.lives -= 1
        end

        player.x = 60

        enemy.x = 60

        ball.x = 63
        ball.y = 63
        ball.x_speed = 0
        ball.y_speed /= 2
    else
        player.lives -= 1
        set_game_over()
    end
end

function set_game_over()
    game_over = true
    music(-1, 10, 1)
end

function draw_lives()
    for i = 1, player.lives do
        spr(11, 96 + (i * 8), 1)
    end
end

function draw_stats()
    rectfill(0, 0, 128, 6, 0)
    -- print("level: " .. level .. "  score: " .. score .. "  lives: ", 0, 1)
    line(0, 0, 1, 0, 0)
    draw_lives()
end

------------------------------- debug functions

function draw_pixel_inspector()
    if debug_options.pixel_inspect then
        pset(debug_options.pixel_inspector.x, debug_options.pixel_inspector.y, 7)

        print("[" .. debug_options.pixel_inspector.x .. ", " .. debug_options.pixel_inspector.y .. "]",
        debug_options.pixel_inspector.x + 3,
        debug_options.pixel_inspector.y - 2)
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

------------------------------- pico-8 callbacks

function _init()
    palt(0, false)

    music(0, 10, 1)

    player = {
        x=60,
        y=120,
        colors={8, 9, 10, 11, 12, 14, 15},
        color=0,
        color_updated=false,
        moving_left=false,
        moving_right=false,
        lives = 3
    }
    enemy = {
        x=60,
        y=8,
        moving_left=false,
        moving_right=false
    }
    ball = {
        x=63,
        y=63,
        x_speed=0,
        y_speed=1,
        bounces=0
    }
    level = 1
    score = 0
    score_multiplier = 1
    game_over = false
    last_color_change_bounce = 0

    debug_options = {
        pixel_inspect = false,
        aim_bot = false,
        infinite_lives = false,
        lock_controls = false,
        pixel_inspector = {
            x = 63,
            y = 63
        }
    }
end

function _update()
    if game_over then
        if btnp(5) then
            _init()
        end
        return
    end

    update_player()
    update_enemy()
    update_ball()
    update_level()

    update_pixel_inspector()
end

function _draw()
    cls(1)
    map(0, 0)
    draw_stats()
    draw_ball()
    draw_player()
    draw_enemy()

    if game_over then
        rectfill(20, 50, 108, 78, 0)
        print("game over!", 44, 58, 7)
        print("press x", 49, 68, 7)
    end

    draw_pixel_inspector()
end
