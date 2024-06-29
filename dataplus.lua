-- Importing the Prism framework from the ReplicatedStorage
local PrismFramework = require(game.RequiredService:WaitForChild("Prism"))

-- Configuration settings for DataPlus
local Config = {
	LudacrisMode = false, -- If true, bypasses caching and pulls directly from DataStore
	BackupInterval = 200, -- Time in seconds between each backup
	CacheTimeout = 2; 
}

-- Main DataPlus table
local DataPlus = {}

-- Accessing Roblox DataStore services
local DataStoreService = game:GetService("DataStoreService")
local mainDataStore = DataStoreService:GetDataStore("MainDataStore")
local versionDataStore = DataStoreService:GetDataStore("VersionDataStore")

-- Variables for internal use
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
function internal:SaveVersion(Key, Value)
	local versions = VersionHistory[Key] or {}
	if #versions >= 3 then
		table.remove(versions, 1)
	end
	table.insert(versions, {timestamp = os.time(), value = Value})
	VersionHistory[Key] = versions
end

-- Retrieves the last three versions of the data
function DataPlus:GetVersions(Key)
	return VersionHistory[Key] or {}
end

-- Batch updates the DataStore and attempts repairs on failure
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
function internal:AuthenticateWithPrism(AppData)
	local APIPackage = PrismFramework:Authenticate(script, AppData)
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
local AppData = {
	Version = "1.0",
	Description = "DataPlus Service",
	API = DataPlus,
	FriendlyName = "Data+Prism",
	Depend = {""}
}

-- Ensures DataPlus performs a final batch update before the game closes
game:BindToClose(BatchUpdateDataStore) 

-- Starts the DataPlus service by authenticating with Prism
internal:AuthenticateWithPrism(AppData)
