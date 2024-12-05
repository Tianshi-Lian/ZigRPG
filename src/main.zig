const rl = @import("raylib");

const TILE_WIDTH: u32 = 8;
const TILE_HEIGHT: u32 = 8;

const MAX_TEXTURES: u32 = 1;

const WORLD_WIDTH: u32 = 20;
const WORLD_HEIGHT: u32 = 20;

const TextureAsset = enum {
    TextureTilemap,
};

const Tile = struct {
    x: i32,
    y: i32,
};

var textures: [MAX_TEXTURES]rl.Texture2D = undefined;
var world: [WORLD_WIDTH][WORLD_HEIGHT]Tile = undefined;
var camera: rl.Camera2D = undefined;

fn gameStartup() void {
    rl.initAudioDevice();

    const image = rl.loadImage("resources/colored_tilemap.png");
    defer rl.unloadImage(image);
    textures[@intFromEnum(TextureAsset.TextureTilemap)] = rl.loadTextureFromImage(image);

    for (&world, 0..) |*row, i| {
        for (row, 0..) |*tile, j| {
            tile.x = @intCast(i);
            tile.y = @intCast(j);
        }
    }

    camera = rl.Camera2D{
        .target = rl.Vector2{ .x = 0, .y = 0 },
        .offset = rl.Vector2{ .x = @as(f32, @floatFromInt(rl.getScreenWidth())) / 2.0, .y = @as(f32, @floatFromInt(rl.getScreenHeight())) / 2.0 },
        .rotation = 0.0,
        .zoom = 3.0,
    };
}

fn gameUpdate() void {
    const wheel = rl.getMouseWheelMove();
    if (wheel != 0) {
        camera.zoom += wheel * 0.125;

        if (camera.zoom < 3.0) {
            camera.zoom = 3.0;
        } else if (camera.zoom > 8.0) {
            camera.zoom = 8.0;
        }
    }

    camera.target = rl.Vector2{ .x = 0, .y = 0 };
}

fn gameRender() void {
    rl.beginMode2D(camera);

    var last_tile: Tile = undefined;
    var tex_index_x: i32 = 0;
    var tex_index_y: i32 = 0;
    for (world) |row| {
        for (row) |tile| {
            last_tile = tile;
            tex_index_x = 4;
            tex_index_y = 4;

            const source_rec = rl.Rectangle{
                .x = @floatFromInt(tex_index_x * TILE_WIDTH),
                .y = @floatFromInt(tex_index_y * TILE_HEIGHT),
                .width = @floatFromInt(TILE_WIDTH),
                .height = @floatFromInt(TILE_HEIGHT),
            };

            const dest_rec = rl.Rectangle{
                .x = @floatFromInt(tile.x * TILE_WIDTH),
                .y = @floatFromInt(tile.y * TILE_HEIGHT),
                .width = @floatFromInt(TILE_WIDTH),
                .height = @floatFromInt(TILE_HEIGHT),
            };

            const origin = rl.Vector2{
                .x = 0,
                .y = 0,
            };

            rl.drawTexturePro(textures[@intFromEnum(TextureAsset.TextureTilemap)], source_rec, dest_rec, origin, 0.0, rl.Color.white);
        }
    }

    rl.endMode2D();

    // Debug UI
    {
        rl.drawRectangle(5, 5, 330, 120, rl.Color.fade(rl.Color.sky_blue, 0.5));
        rl.drawRectangleLines(5, 5, 330, 120, rl.Color.blue);

        rl.drawText(rl.textFormat("Camera Target: (%06.2f, %06.2f)", .{ camera.target.x, camera.target.y }), 15, 10, 14, rl.Color.yellow);
        rl.drawText(rl.textFormat("Camera Zoom: %04.2f", .{camera.zoom}), 15, 30, 14, rl.Color.yellow);
    }
}

fn gameShutdown() void {
    rl.closeAudioDevice();

    for (textures) |texture| {
        rl.unloadTexture(texture);
    }
}

pub fn main() anyerror!void {
    const screenWidth: i32 = 800;
    const screenHeight: i32 = 600;

    rl.initWindow(screenWidth, screenHeight, "Raylib 2D RPG");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    gameStartup();

    while (!rl.windowShouldClose()) {
        gameUpdate();

        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.gray);
        gameRender();
    }

    gameShutdown();
}
