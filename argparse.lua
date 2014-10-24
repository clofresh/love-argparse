local module = {}

local parseNewArg, parseNamedValue
parseNamedValue = function(args, pos, output, name)
    local argPart = args[pos]
    if argPart == nil then
        -- Reached the end without a new value, assume the option was a flag
        output.named[name] = true
        return output
    elseif string.sub(argPart, 1, 2) == '--' then
        -- Found another option, save as a flag and check the next item
        output.named[name] = true
        return parseNamedValue(args, pos + 1, output, string.sub(argPart, 3))
    else
        -- Found a value for the option, save and continue
        output.named[name] = argPart
        return parseNewArg(args, pos + 1, output)
    end
end

parseNewArg = function(args, pos, output)
    local argPart = args[pos]
    if argPart == nil then
        -- Reached the end, return the output
        return output
    elseif string.sub(argPart, 1, 2) == '--' then
        -- Found the option prefix, check if it's a value or it's just a flag
        return parseNamedValue(args, pos + 1, output, string.sub(argPart, 3))
    else
        -- No option prefix, save it as a positional arg and move one
        table.insert(output.positional, argPart)
        return parseNewArg(args, pos + 1, output)
    end
end

function module.parse(args)
    local output = {
        positional = {},
        named = {}
    }
    setmetatable(output, {
        __tostring = function(self)
            local str = ''
            for name, val in pairs(output.named) do
                str = string.format('%s--%s %s ', str, name, val)
            end
            for i, val in pairs(output.positional) do
                str = string.format('%s %s', str, val)
            end
            return str
        end
    })
    return parseNewArg(args, 1, output)
end

return module
