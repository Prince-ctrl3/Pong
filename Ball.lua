Ball = Class {}



function Ball:init(width, height)
    self.width = width
    self.height = height
    self.track = {}
    self:reset()
end

function Ball:reset(direction)
    self.x = VIRTUAL_WIDTH / 2 - self.width / 2
    self.y = VIRTUAL_HEIGHT / 2 - self.height / 2
    if (direction) then
        self.dx = 100 * direction
    else 
        self.dx = math.random(2) == 1 and 100 or -100
    end
    self.dy = math.random(-50, 50)
end

function Ball:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt


    self.track[#self.track + 1] = {
            x = self.x,
            y = self.y,
            alpha = 0.5
        }



        for index, value in ipairs(self.track) do
            if value.alpha <= 0 then
                table.remove(self.track, index)
            else
                self.track[index].alpha = value.alpha - 0.01
            end
        end
end

function Ball:draw()
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)


    for _, value in ipairs(self.track) do
        love.graphics.setColor(1, 1, 1, value.alpha)
        love.graphics.rectangle("fill", value.x, value.y, self.width, self.height)
    end

    love.graphics.setColor(1, 1, 1, 1)
end

function Ball:collidies(paddle)
    if self.x >= paddle.x + paddle.width or self.x + self.width <= paddle.x then
        return false
    elseif self.y >= paddle.y + paddle.height or self.y + self.height <= paddle.y then
        return false
    end
    return true
end

function Ball:turn()
    self.dx = -self.dx * 1.05
    if self.dy > 0 then
        self.dy = -(math.random(0, 150))
    else
        self.dy = math.random(0, 150)
    end
end