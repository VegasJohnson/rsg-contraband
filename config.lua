Config = Config or {}

Config.Debug = false

Config.MinimumLawmen = 0 -- number of lawmen on server to be able to deal
Config.LawmenJob = 'police' -- job name for the lawmen on your server--

-- contraband list
Config.ContrabandList = {
	"weed",
    "mweed",
	"60coke",
    "40coke",
    "20coke",
    "10coke",
    "5coke",
    "coke",
    "morphine",
    "opium",
    "moonshine",
    "moonshine20",
    "moonshine30",
    "moonshine50",
    "moonshine80",
    "moonshine100"
}

-- contraband price
Config.ContrabandPrice = { -- minimum price for sell
	["weed"] = { price = 4, priceh = 6 },
    ["mweed"] = { price = 4, priceh = 6 },
    ["morphine"] = { price = 12, priceh = 18 },
    ["opium"] = { price = 4, priceh = 6 },
	["60coke"] = { price = 3, priceh = 5 },
    ["40coke"] = { price = 4, priceh = 6 },
	["20coke"] = { price = 8, priceh = 12 },
	["10coke"] = { price = 16, priceh = 26 },
	["5coke"] = { price = 21, priceh = 29 },
	["coke"] = { price = 24, priceh = 36 },
    ["moonshine"] = { price = 3, priceh = 5 },
    ["moonshine20"] = { price = 4, priceh = 6 },
    ["moonshine30"] = { price = 8, priceh = 12 },
    ["moonshine50"] = { price = 16, priceh = 26 },
    ["moonshine80"] = { price = 21, priceh = 29 },
    ["moonshine100"] = { price = 24, priceh = 36 },
}
