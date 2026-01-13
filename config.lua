Config = {}

-- Framework Configuration
-- Options: 'qbcore', 'esx', 'qbox'
Config.Framework = 'qbcore'

-- Language Configuration
Config.Language = 'en' 

-- Interaction Settings
Config.CommandName = 'outfits' 
Config.Keybind = nil -- Once set, This will be saved as a keybind in the player's local settings, And the only way to change it is will be through their settings.

-- Clothing Script Support
-- 'qb-clothing', 'fivem-appearance', 'illenium-appearance', 'esx_skin'
Config.ClothingScript = 'qb-clothing' 

-- Restriction Settings
Config.RestrictToShops = true -- when true, players can only change outfits in designated shops
Config.ShopRadius = 3.0 

-- Debug Mode (For support/customers)
-- Set to true to see detailed logs in F8
Config.Debug = false

-- Clothing Shop Locations (change or add more as needed)

Config.ShopLocations = {
    vector3(1693.45, 4823.17, 42.16),
    vector3(-1177.86, -1780.56, 3.90),
    vector3(198.46, -1646.76, 29.80),
    vector3(298.19, -599.43, 43.29),
    vector3(-712.21, -155.35, 37.41),
    vector3(123.77, -301.61, 54.55),
    vector3(-1192.94, -772.68, 17.32),
    vector3(461.05, -996.78, 30.69),
    vector3(425.23, -806.00, 28.49),
    vector3(-162.65, -303.39, 38.73),
    vector3(75.95, -1392.89, 28.37),
    vector3(-822.19, -1074.13, 10.32),
    vector3(-1450.71, -236.83, 48.80),
    vector3(4.25, 6512.81, 30.87),
    vector3(615.18, 2762.93, 41.08),
    vector3(1196.78, 2709.55, 37.22),
    vector3(-3171.45, 1043.85, 19.86),
    vector3(-1100.95, 2710.21, 18.10),
    vector3(-1207.65, -1456.88, 4.37),
    vector3(121.76, -224.6, 53.56),
    vector3(1784.13, 2492.6, 50.43),
    vector3(1861.58, 3689.44, 34.28),
    vector3(-452.57, 6014.21, 31.72),
    vector3(106.2, -1302.79, 27.8),
    vector3(100.19, 3615.83, 40.91)
}