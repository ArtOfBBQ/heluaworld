camera = {
    width = 1200,
    height = 1000,
    left = 0,
    top = 0,
    speed = 200,
    zoom = 1,
    zoomspeed = 2}

-- masterfully explained by javidx9
-- https://www.youtube.com/watch?v=ZQ8qtAizis4&t=260s 
function camera.x_world_to_screen(x_world)
    return (x_world - camera.left) * camera.zoom
end

function camera.y_world_to_screen(y_world)
    return (y_world - camera.top) * camera.zoom
end

return camera
