camera = {
    width = 1025,
    height = 1025,
    left = 0,
    top = 0,
    speed = 1000,
    zoom = 2,
    zoomspeed = 2}

function camera.x_screen_to_world(self, x_screen)

    return (x_screen / camera.zoom) + self.left

end

function camera.y_screen_to_world(self, y_screen)

    return (y_screen / camera.zoom) + self.top 
    
end

function camera.x_world_to_screen(x_world)
    return (x_world - camera.left) * camera.zoom
end

function camera.y_world_to_screen(y_world)
    return (y_world - camera.top) * camera.zoom
end

function camera.zoom_in(self, elapsed)

    self.zoom = self.zoom + (self.zoomspeed * elapsed)
    if self.zoom > 2.5 then
        self.zoom = 2.5
    else
        self.left = self.left + (10 * self.zoomspeed * elapsed)
        self.top = self.top + (10 * self.zoomspeed * elapsed)
    end

end

function camera.zoom_out(self, elapsed)

    self.zoom = self.zoom - (self.zoomspeed * elapsed)
    if self.zoom < 0.65 then
        self.zoom = 0.65
        self.left = self.left - (10 * self.zoomspeed * elapsed)
        self.top = self.top - (10 * self.zoomspeed * elapsed)
    end

end

function camera.scroll_right(self, elapsed, map_width)

    assert(map_width ~= nil)
    self.left = math.max(math.min(self.left + (self.speed * elapsed), map_width - (1000 / self.zoom)), 0)

end

function camera.scroll_left(self, elapsed)

    assert(map.width ~= nil)
    self.left = math.max(self.left - (self.speed * elapsed), 0)

end

function camera.scroll_up(self, elapsed)

    self.top = math.max(self.top - (self.speed * elapsed), 0)

end

function camera.scroll_down(self, elapsed, map_height)

    assert(map_height ~= nil)
    self.top = math.max(math.min(self.top + (self.speed * elapsed), map_height - (1000 / self.zoom)), 0)

end


return camera
