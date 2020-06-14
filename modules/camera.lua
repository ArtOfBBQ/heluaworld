camera = {
    width = 1200,
    height = 1000,
    left = 0,
    top = 0,
    speed = 1000,
    zoom = 1,
    zoomspeed = 2}

function camera.x_screen_to_world(x_screen)

    return (x_screen / camera.zoom) + camera.left

end

function camera.y_screen_to_world(y_screen)

    return (y_screen / camera.zoom) + camera.top

end

function camera.x_world_to_screen(x_world)
    return (x_world - camera.left) * camera.zoom
end

function camera.y_world_to_screen(y_world)
    return (y_world - camera.top) * camera.zoom
end

function camera.zoom_in(self, elapsed)

    self.zoom = self.zoom + (self.zoomspeed * elapsed)

end

function camera.zoom_out(self, elapsed)

    self.zoom = self.zoom - (self.zoomspeed * elapsed)

end

function camera.scroll_right(self, elapsed, map_width)

    assert(map_width ~= nil)
    self.left = math.min(self.left + (self.speed * elapsed), map_width - camera.width)

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
    self.top = math.min(self.top + (self.speed * elapsed), map_height - camera.height)

end


return camera
