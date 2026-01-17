local Domesticatable = Class(function(self, inst)
    self.inst = inst
end)


function Domesticatable:OnSave()
    return {
        --V2C: domesticatable MUST load b4 rideable, and we
        --     aren't using the usual OnLoadPostPass method
        --     so... we did this! lol...
        rideable = self.inst.components.rideable ~= nil and self.inst.components.rideable:OnSaveDomesticatable() or nil,
    }
end

function Domesticatable:OnLoad(data, newents)
    if data ~= nil then
        --V2C: see above comment in OnSave
        if self.inst.components.rideable ~= nil then
            self.inst.components.rideable:OnLoadDomesticatable(data.rideable, newents)
        end
    end
end

return Domesticatable
