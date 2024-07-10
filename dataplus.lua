--[[
	 ___         _            _    ___       _            
	|   \  __ _ | |_  __ _  _| |_ | _ \ _ _ (_) ___ _ __  
	| |) |/ _` ||  _|/ _` ||_   _||  _/| '_|| |(_-<| '  \ 
	|___/ \__,_| \__|\__,_|  |_|  |_|  |_|  |_|/__/|_|_|_|

	Data+Prism is the most popular application on the Prism framework!
	

	Prism is an open-source framework designed to ensure security and stability in 
	Roblox games. It can be used to quickly build up modular games with high security. 
	
	Data+Prism simplifies everything with DataStoreService and data management in your game. It handles all
	the complex operations behind it all and provides you with an easy to use API. 
	
	This package includes the following built-in features:
		- Version management for data loss or corruption cases
		- Easy data read/write that automatically syncs with your DatastoreService. Your game data will
			always be safe and secure.
		- Automatic script and information security provided by Prism 
		- No risk of hitting API rate limits
		- Drag and drop, easy software updates due to backwards compatibility 
		
		
	In the most recent 1.2 update, we built in full compatibility to the most recent Prism version 1.2. 
	This prevents deprecated messages from filling up your ouput. 
	
	Our creator edition had some big changes to detect other Prism installations. This ensures that Data+Prism attaches
	to your server-wide installation, instead of staying inside this container. This is all done automatically in the background. 
	
]]

-- Importing the Prism framework from the ReplicatedStorage
-- This is like getting a toolbox for our project!
local PrismFramework = require(game.ReplicatedStorage:WaitForChild("Prism"))

-- Configuration settings for DataPlus
-- It's always good to have options!
local Config = {
	LudacrisMode = false, -- If true, bypasses caching and pulls directly from DataStore
	BackupInterval = 200, -- Time in seconds between each backup
	CacheTimeout = 2; 
}

-- Main DataPlus table
-- This is where the magic happens!
local DataPlus = {}

-- Accessing Roblox DataStore services
-- We're going to need these for storing and retrieving data
local DataStoreService = game:GetService("DataStoreService")
local mainDataStore = DataStoreService:GetDataStore("MainDataStore")
local versionDataStore = DataStoreService:GetDataStore("VersionDataStore")

-- Variables for internal use
-- These are our secret ingredients
local cache = {} -- Cache to store data and reduce DataStore calls
local UpdateQueue = {} -- Queue to manage batch updates
local VersionHistory = {} -- History of data versions for rollback
local internal = {} -- Internal table for private functions and variables
local BatchSize = 10 -- Number of updates per batch
local BatchInterval = 50 -- Time in seconds between batches

-- Retrieves data, checking cache first if LudacrisMode is off
function DataPlus:GetData(Key, Scope)
	if Config.LudacrisMode then
		return cache[Key]
	else
		if not cache[Key] then
			local success, result = pcall(mainDataStore.GetAsync, mainDataStore, Key)
			if success then
				cache[Key] = result
				-- Set a timer to invalidate the cache after a certain period
				delay(Config.CacheTimeout, function()
					cache[Key] = nil
				end)
			end
		end
		-- If data is still nil, wait for it to be available
		while cache[Key] == nil do
			wait(1) -- wait for 1 second before checking again
		end
		return cache[Key]
	end
end

-- Helper function to write logs using Prism's API
local function Write(...)
	internal.AppAPI:Write(internal.PrivateKey, ...)
end

-- Sets data, adds it to the update queue, and updates cache
function DataPlus:SetData(Scope, Value)
	UpdateQueue[Scope] = Value
	cache[Scope] = Value
	internal:SaveVersion(Scope, Value)
	return true 
end

-- Saves a new version of the data for rollback purposes
-- Because it's always good to have a backup plan!
function internal:SaveVersion(Key, Value)
	local versions = VersionHistory[Key] or {}
	if #versions >= 3 then
		table.remove(versions, 1)
	end
	table.insert(versions, {timestamp = os.time(), value = Value})
	VersionHistory[Key] = versions
end

-- Retrieves the last three versions of the data
-- It's like a time machine for your data!
function DataPlus:GetVersions(Key)
	return VersionHistory[Key] or {}
end

-- Batch updates the DataStore and attempts repairs on failure
-- Because sometimes, things don't go as planned
local function BatchUpdateDataStore()
	for Key, Value in pairs(UpdateQueue) do
		local success = pcall(function()
			mainDataStore:SetAsync(Key, Value)
		end)

		if success then
			UpdateQueue[Key] = nil
			cache[Key] = Value
		else
			local repairSuccess = pcall(function()
				mainDataStore:UpdateAsync(Key, function(oldValue)
					return Value
				end)
			end)

			if repairSuccess then
				cache[Key] = Value
				Write("Repair successful for key: " .. Key)
			else
				Write("Failed to repair data for key: " .. Key)
			end
			UpdateQueue[Key] = nil
		end
		Write("Data batch upload completed")
	end
end

-- Authenticates with the Prism framework and starts the service
-- It's like shaking hands with Prism before we start working together
function internal:AuthenticateWithPrism(AppData)
	local APIPackage = PrismFramework:Authenticate(script, AppData)

	if not APIPackage then 
		error("Prism authentication failure, halting thread execution")
	end
	internal.PrivateKey = APIPackage.Key
	internal.AppAPI = APIPackage.AppAPI
end

-- Initiates the batch update process at intervals defined in Config
spawn(function()
	while wait((Config.BackupInterval or 100)) do
		BatchUpdateDataStore()
	end
end)

-- AppData for DataPlus, containing metadata
-- This is like our ID card for DataPlus
local AppData = {
	Version = "1.2",
	Description = "DataPlus Service",
	API = DataPlus,
	FriendlyName = "Data+Prism",
}

-- Ensures DataPlus performs a final batch update before the game closes
-- Because we always clean up before we leave!
game:BindToClose(BatchUpdateDataStore) 

-- Starts the DataPlus service by authenticating with Prism
-- And we're off to the races!
internal:AuthenticateWithPrism(AppData)
