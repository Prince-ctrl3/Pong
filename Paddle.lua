Paddle = Class{}

function Paddle:init(x, y, width, height)
    self.x = x
    self.y = y
    self.score = 0
    self.width = width
    self.height = height
    self.speed = 200
    self.upperBound = -(self.height + 20)
    self.lowerBound = VIRTUAL_HEIGHT + 20
end

function Paddle:reset()
    self.score = 0
end

function Paddle:update(dt, factor)
    self.y = self.y + (self.speed  * dt * factor)

    if self.y < self.upperBound then
        self.y = self.lowerBound
    elseif self.y > self.lowerBound then
        self.y = self.upperBound
    end

end

function Paddle:draw()
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end