
local abs, min, max = math.abs, math.min, math.max
local function rgb2hsv(r, g, b)
	local M, m = max(r, g, b), min(r, g, b)
	local C = M - m
	local K = 1.0/(6.0 * C)
	local h = 0.0

	if C ~= 0.0 then
		if M == r then
            h = ((g - b) * K) % 1.0
		elseif M == g then
            h = (b - r) * K + 1.0/3.0
		else
            h = (r - g) * K + 2.0/3.0
		end
	end
	return h, M == 0.0 and 0.0 or C / M, M
end

local function hsv2rgb(h, s, v)
	local C = v * s
	local m = v - C
	local r, g, b = m, m, m
    local h_ = (h % 1.0) * 6
    local X = C * (1 - abs(h_ % 2 - 1))
    C, X = C + m, X + m

    if h_ < 1 then
        r, g, b = C, X, m
    elseif h_ < 2 then
        r, g, b = X, C, m
    elseif h_ < 3 then
        r, g, b = m, C, X
    elseif h_ < 4 then
        r, g, b = m, X, C
    elseif h_ < 5 then
        r, g, b = X, m, C
    else
        r, g, b = C, m, X
    end
	return r, g, b
end

local function shift_hue(color, dh)
    local h, s, v = rgb2hsv(unpack(color))
    h = h + dh
    return {hsv2rgb(h, s, v)}
end

return {
    rgb2hsv = rgb2hsv,
    hsv2rgb = hsv2rgb,
    shift_hue = shift_hue,
}
