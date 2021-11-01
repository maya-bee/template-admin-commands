--[[


(this was made by maya70i btw)


                 _____ _____ __  __ ____  _        _  _____ _____      _    ____  __  __ ___ _   _
                |_   _| ____|  \/  |  _ \| |      / \|_   _| ____|    / \  |  _ \|  \/  |_ _| \ | |
                  | | |  _| | |\/| | |_) | |     / _ \ | | |  _|     / _ \ | | | | |\/| || ||  \| |
                  | | | |___| |  | |  __/| |___ / ___ \| | | |___   / ___ \| |_| | |  | || || |\  |
                  |_| |_____|_|  |_|_|   |_____/_/   \_\_| |_____| /_/   \_\____/|_|  |_|___|_| \_|


                     Thank you for using my module! I worked hard on making it easy to set up and
                     highly customizable. **This module is intended for developers that know what
                      they're doing.** If you don't know how to script, then you should go with
                       a different Admin Commands module. The point of this module is that you
                         use it as a template and build off of it. By itself, it isn't much.
                                          Hope that clears some things up!


]]                                                                                                                                                                                                                                                      local TemplateAdmin = {}


TemplateAdmin.Prefix = ":" -- This can be anything EXCEPT if it starts with "/e", as that is reserved for hiding commands.

TemplateAdmin.Owners = { -- Put the username of anyone you want to have owner permissions.
    "Maya70i",
    "Builderman",
}

TemplateAdmin.Admins = { -- Put the username of anyone you want to have admin permissions.
    "Roblox",
    "Builderman",
}

TemplateAdmin.Mods = { -- Put the username of anyone you want to have mod permissions.
    "Roblox",
    "Builderman",
}

TemplateAdmin.AutoRankVisitor = true -- Should we automatically rank players Visitor?

-- THAT'S ALL! The point of this module is that you build your administrator commands system on top of this with 
-- our powerful API. Check out our developer forum post here:

return TemplateAdmin